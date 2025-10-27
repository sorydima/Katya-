import 'dart:async';
import 'dart:math';

import 'package:equatable/equatable.dart';

/// Сервис для голосования и консенсуса в сети доверия
class ConsensusVotingService {
  static final ConsensusVotingService _instance = ConsensusVotingService._internal();

  // Активные голосования и предложения
  final Map<String, ConsensusProposal> _activeProposals = {};
  final Map<String, List<Vote>> _votes = {};
  final Map<String, ConsensusResult> _consensusResults = {};

  // Участники консенсуса
  final Map<String, ConsensusParticipant> _participants = {};
  final Map<String, ParticipantReputation> _participantReputations = {};

  // Конфигурация
  static const Duration _defaultVotingPeriod = Duration(hours: 24);
  static const double _minimumQuorumPercentage = 0.5;
  static const double _superMajorityThreshold = 0.67;
  static const int _maxProposalsPerParticipant = 10;

  factory ConsensusVotingService() => _instance;
  ConsensusVotingService._internal();

  /// Инициализация сервиса
  Future<void> initialize() async {
    await _loadParticipants();
    _setupProposalMonitoring();
    _setupConsensusProcessing();
  }

  /// Создание предложения для голосования
  Future<ConsensusProposal> createProposal({
    required String proposalId,
    required String proposerId,
    required String title,
    required String description,
    required ProposalType type,
    required Map<String, dynamic> details,
    Duration? votingPeriod,
    List<String>? eligibleVoters,
  }) async {
    // Проверяем права участника на создание предложений
    final participant = _participants[proposerId];
    if (participant == null) {
      throw Exception('Participant not found');
    }

    final activeProposals =
        _activeProposals.values.where((p) => p.proposerId == proposerId && p.status == ProposalStatus.active).length;

    if (activeProposals >= _maxProposalsPerParticipant) {
      throw Exception('Maximum active proposals limit reached');
    }

    final proposal = ConsensusProposal(
      proposalId: proposalId,
      proposerId: proposerId,
      title: title,
      description: description,
      type: type,
      details: details,
      votingPeriod: votingPeriod ?? _defaultVotingPeriod,
      eligibleVoters: eligibleVoters ?? _getAllEligibleVoters(),
      status: ProposalStatus.active,
      createdAt: DateTime.now(),
      votingStartsAt: DateTime.now(),
      votingEndsAt: DateTime.now().add(votingPeriod ?? _defaultVotingPeriod),
      totalVotes: 0,
      yesVotes: 0,
      noVotes: 0,
      abstainVotes: 0,
      requiredQuorum: _calculateRequiredQuorum(eligibleVoters ?? _getAllEligibleVoters()),
      requiredSuperMajority: _calculateRequiredSuperMajority(type),
    );

    _activeProposals[proposalId] = proposal;
    _votes[proposalId] = [];

    return proposal;
  }

  /// Голосование по предложению
  Future<VoteResult> castVote({
    required String proposalId,
    required String voterId,
    required VoteChoice choice,
    String? comment,
    Map<String, dynamic>? metadata,
  }) async {
    final proposal = _activeProposals[proposalId];
    if (proposal == null) {
      return const VoteResult(
        success: false,
        errorMessage: 'Proposal not found',
        voteId: '',
      );
    }

    if (proposal.status != ProposalStatus.active) {
      return const VoteResult(
        success: false,
        errorMessage: 'Proposal is not active for voting',
        voteId: '',
      );
    }

    if (DateTime.now().isAfter(proposal.votingEndsAt)) {
      return const VoteResult(
        success: false,
        errorMessage: 'Voting period has ended',
        voteId: '',
      );
    }

    // Проверяем право голоса
    if (!proposal.eligibleVoters.contains(voterId)) {
      return const VoteResult(
        success: false,
        errorMessage: 'Voter not eligible for this proposal',
        voteId: '',
      );
    }

    // Проверяем, не голосовал ли уже
    final existingVote = _votes[proposalId]?.firstWhere(
      (v) => v.voterId == voterId,
      orElse: () => throw Exception('No existing vote'),
    );

    if (existingVote != null) {
      return VoteResult(
        success: false,
        errorMessage: 'Vote already cast',
        voteId: existingVote.voteId,
      );
    }

    try {
      // Создаем голос
      final vote = Vote(
        voteId: _generateVoteId(),
        proposalId: proposalId,
        voterId: voterId,
        choice: choice,
        comment: comment,
        metadata: metadata ?? {},
        castAt: DateTime.now(),
        voterReputation: _getParticipantReputation(voterId),
        voteWeight: _calculateVoteWeight(voterId),
      );

      // Добавляем голос
      _votes[proposalId]!.add(vote);

      // Обновляем статистику предложения
      _updateProposalStats(proposal, vote);

      return VoteResult(
        success: true,
        voteId: vote.voteId,
      );
    } catch (e) {
      return VoteResult(
        success: false,
        errorMessage: e.toString(),
        voteId: '',
      );
    }
  }

  /// Получение результатов голосования
  Future<ConsensusResult?> getConsensusResult(String proposalId) async {
    if (_consensusResults.containsKey(proposalId)) {
      return _consensusResults[proposalId];
    }

    final proposal = _activeProposals[proposalId];
    if (proposal == null) {
      return null;
    }

    // Если голосование еще активно, возвращаем предварительные результаты
    if (proposal.status == ProposalStatus.active) {
      return _calculatePreliminaryResult(proposal);
    }

    return null;
  }

  /// Получение активных предложений
  Future<List<ConsensusProposal>> getActiveProposals({
    ProposalType? type,
    String? proposerId,
    int limit = 50,
  }) async {
    var proposals = _activeProposals.values.where((p) => p.status == ProposalStatus.active).toList();

    if (type != null) {
      proposals = proposals.where((p) => p.type == type).toList();
    }

    if (proposerId != null) {
      proposals = proposals.where((p) => p.proposerId == proposerId).toList();
    }

    // Сортировка по времени создания (новые сначала)
    proposals.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    return proposals.take(limit).toList();
  }

  /// Получение голосов по предложению
  Future<List<Vote>> getProposalVotes(String proposalId) async {
    return _votes[proposalId] ?? [];
  }

  /// Создание делегированного голосования
  Future<DelegatedVoting> createDelegatedVoting({
    required String delegatorId,
    required String delegateId,
    required List<ProposalType> allowedTypes,
    Duration? duration,
  }) async {
    final delegation = DelegatedVoting(
      delegationId: _generateDelegationId(),
      delegatorId: delegatorId,
      delegateId: delegateId,
      allowedTypes: allowedTypes,
      createdAt: DateTime.now(),
      expiresAt: DateTime.now().add(duration ?? const Duration(days: 30)),
      status: DelegationStatus.active,
    );

    return delegation;
  }

  /// Анализ консенсуса
  Future<ConsensusAnalysis> analyzeConsensus({
    required String proposalId,
    bool includeDetailedBreakdown = false,
  }) async {
    final proposal = _activeProposals[proposalId];
    if (proposal == null) {
      throw Exception('Proposal not found');
    }

    final votes = _votes[proposalId] ?? [];
    final result = _consensusResults[proposalId];

    return ConsensusAnalysis(
      proposalId: proposalId,
      totalEligibleVoters: proposal.eligibleVoters.length,
      totalVotesCast: votes.length,
      participationRate: votes.length / proposal.eligibleVoters.length,
      consensusLevel: _calculateConsensusLevel(votes),
      outcome: result?.outcome ?? ConsensusOutcome.pending,
      confidence: _calculateConfidence(votes, proposal),
      breakdown: includeDetailedBreakdown ? _generateDetailedBreakdown(votes) : null,
      recommendations: _generateRecommendations(proposal, votes),
      analyzedAt: DateTime.now(),
    );
  }

  /// Получение статистики участника
  Future<ParticipantVotingStats> getParticipantStats(String participantId) async {
    final participant = _participants[participantId];
    if (participant == null) {
      throw Exception('Participant not found');
    }

    final allVotes = <Vote>[];
    for (final votes in _votes.values) {
      allVotes.addAll(votes.where((v) => v.voterId == participantId));
    }

    final proposalsCreated = _activeProposals.values.where((p) => p.proposerId == participantId).length;

    return ParticipantVotingStats(
      participantId: participantId,
      totalVotesCast: allVotes.length,
      proposalsCreated: proposalsCreated,
      averageParticipationRate: _calculateAverageParticipationRate(participantId),
      votingAccuracy: _calculateVotingAccuracy(participantId),
      reputationScore: _getParticipantReputation(participantId),
      lastVoteAt: allVotes.isNotEmpty ? allVotes.map((v) => v.castAt).reduce((a, b) => a.isAfter(b) ? a : b) : null,
      timestamp: DateTime.now(),
    );
  }

  /// Загрузка участников
  Future<void> _loadParticipants() async {
    // В реальной реализации здесь будет загрузка из базы данных
    // Для демонстрации создаем тестовых участников
    _createTestParticipants();
  }

  /// Создание тестовых участников
  void _createTestParticipants() {
    final testParticipants = [
      {
        'participantId': 'participant_001',
        'name': 'Alice',
        'reputation': 0.9,
        'votingPower': 1.0,
      },
      {
        'participantId': 'participant_002',
        'name': 'Bob',
        'reputation': 0.8,
        'votingPower': 0.8,
      },
      {
        'participantId': 'participant_003',
        'name': 'Charlie',
        'reputation': 0.7,
        'votingPower': 0.7,
      },
    ];

    for (final participantData in testParticipants) {
      final participant = ConsensusParticipant(
        participantId: participantData['participantId']! as String,
        name: participantData['name']! as String,
        reputation: participantData['reputation']! as double,
        votingPower: participantData['votingPower']! as double,
        joinedAt: DateTime.now(),
        status: ParticipantStatus.active,
      );

      _participants[participant.participantId] = participant;
      _participantReputations[participant.participantId] = ParticipantReputation(
        participantId: participant.participantId,
        reputationScore: participant.reputation,
        votingAccuracy: 0.85,
        participationRate: 0.9,
        lastUpdated: DateTime.now(),
      );
    }
  }

  /// Настройка мониторинга предложений
  void _setupProposalMonitoring() {
    Timer.periodic(const Duration(minutes: 1), (timer) async {
      await _checkExpiredProposals();
    });
  }

  /// Проверка истекших предложений
  Future<void> _checkExpiredProposals() async {
    final now = DateTime.now();
    final expiredProposals = <String>[];

    for (final entry in _activeProposals.entries) {
      final proposal = entry.value;
      if (proposal.status == ProposalStatus.active && now.isAfter(proposal.votingEndsAt)) {
        expiredProposals.add(entry.key);
      }
    }

    for (final proposalId in expiredProposals) {
      await _finalizeProposal(proposalId);
    }
  }

  /// Завершение предложения
  Future<void> _finalizeProposal(String proposalId) async {
    final proposal = _activeProposals[proposalId];
    if (proposal == null) return;

    final votes = _votes[proposalId] ?? [];
    final result = _calculateFinalResult(proposal, votes);

    _consensusResults[proposalId] = result;
    proposal.status = ProposalStatus.completed;

    // Выполняем действия на основе результата
    await _executeProposalResult(proposal, result);
  }

  /// Настройка обработки консенсуса
  void _setupConsensusProcessing() {
    Timer.periodic(const Duration(seconds: 30), (timer) async {
      await _processConsensusUpdates();
    });
  }

  /// Обработка обновлений консенсуса
  Future<void> _processConsensusUpdates() async {
    // В реальной реализации здесь будет обработка обновлений консенсуса
    // Например, обновление репутации участников на основе их голосования
  }

  /// Получение всех имеющих право голоса
  List<String> _getAllEligibleVoters() {
    return _participants.keys.toList();
  }

  /// Расчет требуемого кворума
  int _calculateRequiredQuorum(List<String> eligibleVoters) {
    return (eligibleVoters.length * _minimumQuorumPercentage).ceil();
  }

  /// Расчет требуемого большинства
  int _calculateRequiredSuperMajority(ProposalType type) {
    switch (type) {
      case ProposalType.governance:
        return (_getAllEligibleVoters().length * _superMajorityThreshold).ceil();
      case ProposalType.technical:
        return (_getAllEligibleVoters().length * 0.51).ceil(); // Простое большинство
      case ProposalType.economic:
        return (_getAllEligibleVoters().length * _superMajorityThreshold).ceil();
      case ProposalType.social:
        return (_getAllEligibleVoters().length * 0.51).ceil(); // Простое большинство
    }
  }

  /// Обновление статистики предложения
  void _updateProposalStats(ConsensusProposal proposal, Vote vote) {
    proposal.totalVotes++;

    switch (vote.choice) {
      case VoteChoice.yes:
        proposal.yesVotes++;
      case VoteChoice.no:
        proposal.noVotes++;
      case VoteChoice.abstain:
        proposal.abstainVotes++;
    }
  }

  /// Генерация ID голоса
  String _generateVoteId() {
    return 'vote_${DateTime.now().millisecondsSinceEpoch}_${Random().nextInt(10000)}';
  }

  /// Получение репутации участника
  double _getParticipantReputation(String participantId) {
    return _participantReputations[participantId]?.reputationScore ?? 0.5;
  }

  /// Расчет веса голоса
  double _calculateVoteWeight(String voterId) {
    final participant = _participants[voterId];
    if (participant == null) return 0.0;

    final reputation = _getParticipantReputation(voterId);
    return participant.votingPower * reputation;
  }

  /// Расчет предварительного результата
  ConsensusResult _calculatePreliminaryResult(ConsensusProposal proposal) {
    final votes = _votes[proposal.proposalId] ?? [];
    return _calculateFinalResult(proposal, votes, isPreliminary: true);
  }

  /// Расчет финального результата
  ConsensusResult _calculateFinalResult(ConsensusProposal proposal, List<Vote> votes, {bool isPreliminary = false}) {
    final totalVotes = votes.length;
    final yesVotes = votes.where((v) => v.choice == VoteChoice.yes).length;
    final noVotes = votes.where((v) => v.choice == VoteChoice.no).length;
    final abstainVotes = votes.where((v) => v.choice == VoteChoice.abstain).length;

    final hasQuorum = totalVotes >= proposal.requiredQuorum;
    final hasMajority = yesVotes > noVotes;
    final hasSuperMajority = yesVotes >= proposal.requiredSuperMajority;

    ConsensusOutcome outcome;
    if (!hasQuorum) {
      outcome = ConsensusOutcome.noQuorum;
    } else if (proposal.type == ProposalType.governance || proposal.type == ProposalType.economic) {
      outcome = hasSuperMajority ? ConsensusOutcome.approved : ConsensusOutcome.rejected;
    } else {
      outcome = hasMajority ? ConsensusOutcome.approved : ConsensusOutcome.rejected;
    }

    return ConsensusResult(
      proposalId: proposal.proposalId,
      outcome: outcome,
      totalVotes: totalVotes,
      yesVotes: yesVotes,
      noVotes: noVotes,
      abstainVotes: abstainVotes,
      hasQuorum: hasQuorum,
      hasMajority: hasMajority,
      hasSuperMajority: hasSuperMajority,
      participationRate: totalVotes / proposal.eligibleVoters.length,
      finalizedAt: isPreliminary ? null : DateTime.now(),
      isPreliminary: isPreliminary,
    );
  }

  /// Выполнение результата предложения
  Future<void> _executeProposalResult(ConsensusProposal proposal, ConsensusResult result) async {
    if (result.outcome == ConsensusOutcome.approved) {
      // В реальной реализации здесь будет выполнение действий предложения
      switch (proposal.type) {
        case ProposalType.governance:
          await _executeGovernanceProposal(proposal, result);
        case ProposalType.technical:
          await _executeTechnicalProposal(proposal, result);
        case ProposalType.economic:
          await _executeEconomicProposal(proposal, result);
        case ProposalType.social:
          await _executeSocialProposal(proposal, result);
      }
    }
  }

  /// Выполнение предложения по управлению
  Future<void> _executeGovernanceProposal(ConsensusProposal proposal, ConsensusResult result) async {
    // Реализация выполнения предложений по управлению
  }

  /// Выполнение технического предложения
  Future<void> _executeTechnicalProposal(ConsensusProposal proposal, ConsensusResult result) async {
    // Реализация выполнения технических предложений
  }

  /// Выполнение экономического предложения
  Future<void> _executeEconomicProposal(ConsensusProposal proposal, ConsensusResult result) async {
    // Реализация выполнения экономических предложений
  }

  /// Выполнение социального предложения
  Future<void> _executeSocialProposal(ConsensusProposal proposal, ConsensusResult result) async {
    // Реализация выполнения социальных предложений
  }

  /// Расчет уровня консенсуса
  double _calculateConsensusLevel(List<Vote> votes) {
    if (votes.isEmpty) return 0.0;

    final yesVotes = votes.where((v) => v.choice == VoteChoice.yes).length;
    final noVotes = votes.where((v) => v.choice == VoteChoice.no).length;

    if (yesVotes + noVotes == 0) return 0.0;

    return (yesVotes - noVotes).abs() / (yesVotes + noVotes);
  }

  /// Расчет уверенности
  double _calculateConfidence(List<Vote> votes, ConsensusProposal proposal) {
    if (votes.isEmpty) return 0.0;

    final participationRate = votes.length / proposal.eligibleVoters.length;
    final consensusLevel = _calculateConsensusLevel(votes);

    return (participationRate + consensusLevel) / 2.0;
  }

  /// Генерация детального разбора
  Map<String, dynamic> _generateDetailedBreakdown(List<Vote> votes) {
    final breakdown = <String, dynamic>{};

    breakdown['by_choice'] = {
      'yes': votes.where((v) => v.choice == VoteChoice.yes).length,
      'no': votes.where((v) => v.choice == VoteChoice.no).length,
      'abstain': votes.where((v) => v.choice == VoteChoice.abstain).length,
    };

    breakdown['by_reputation'] = {
      'high_reputation': votes.where((v) => v.voterReputation > 0.8).length,
      'medium_reputation': votes.where((v) => v.voterReputation > 0.5 && v.voterReputation <= 0.8).length,
      'low_reputation': votes.where((v) => v.voterReputation <= 0.5).length,
    };

    breakdown['weighted_votes'] = {
      'yes_weight': votes.where((v) => v.choice == VoteChoice.yes).fold(0.0, (sum, v) => sum + v.voteWeight),
      'no_weight': votes.where((v) => v.choice == VoteChoice.no).fold(0.0, (sum, v) => sum + v.voteWeight),
      'abstain_weight': votes.where((v) => v.choice == VoteChoice.abstain).fold(0.0, (sum, v) => sum + v.voteWeight),
    };

    return breakdown;
  }

  /// Генерация рекомендаций
  List<String> _generateRecommendations(ConsensusProposal proposal, List<Vote> votes) {
    final recommendations = <String>[];

    final participationRate = votes.length / proposal.eligibleVoters.length;
    if (participationRate < 0.3) {
      recommendations.add('Low participation rate - consider extending voting period');
    }

    final consensusLevel = _calculateConsensusLevel(votes);
    if (consensusLevel < 0.2) {
      recommendations.add('Low consensus level - consider additional discussion');
    }

    if (proposal.type == ProposalType.governance && participationRate < 0.5) {
      recommendations.add('Governance proposal requires higher participation for legitimacy');
    }

    return recommendations;
  }

  /// Расчет средней частоты участия
  double _calculateAverageParticipationRate(String participantId) {
    // В реальной реализации здесь будет расчет на основе истории голосований
    return 0.85; // Заглушка
  }

  /// Расчет точности голосования
  double _calculateVotingAccuracy(String participantId) {
    // В реальной реализации здесь будет расчет на основе результатов голосований
    return 0.9; // Заглушка
  }

  /// Генерация ID делегирования
  String _generateDelegationId() {
    return 'delegation_${DateTime.now().millisecondsSinceEpoch}_${Random().nextInt(10000)}';
  }

  /// Освобождение ресурсов
  void dispose() {
    _activeProposals.clear();
    _votes.clear();
    _consensusResults.clear();
    _participants.clear();
    _participantReputations.clear();
  }
}

/// Предложение для консенсуса
class ConsensusProposal extends Equatable {
  final String proposalId;
  final String proposerId;
  final String title;
  final String description;
  final ProposalType type;
  final Map<String, dynamic> details;
  final Duration votingPeriod;
  final List<String> eligibleVoters;
  final ProposalStatus status;
  final DateTime createdAt;
  final DateTime votingStartsAt;
  final DateTime votingEndsAt;
  int totalVotes;
  int yesVotes;
  int noVotes;
  int abstainVotes;
  final int requiredQuorum;
  final int requiredSuperMajority;

  ConsensusProposal({
    required this.proposalId,
    required this.proposerId,
    required this.title,
    required this.description,
    required this.type,
    required this.details,
    required this.votingPeriod,
    required this.eligibleVoters,
    required this.status,
    required this.createdAt,
    required this.votingStartsAt,
    required this.votingEndsAt,
    required this.totalVotes,
    required this.yesVotes,
    required this.noVotes,
    required this.abstainVotes,
    required this.requiredQuorum,
    required this.requiredSuperMajority,
  });

  @override
  List<Object?> get props => [
        proposalId,
        proposerId,
        title,
        description,
        type,
        details,
        votingPeriod,
        eligibleVoters,
        status,
        createdAt,
        votingStartsAt,
        votingEndsAt,
        totalVotes,
        yesVotes,
        noVotes,
        abstainVotes,
        requiredQuorum,
        requiredSuperMajority,
      ];
}

/// Типы предложений
enum ProposalType {
  governance,
  technical,
  economic,
  social,
}

/// Статусы предложений
enum ProposalStatus {
  draft,
  active,
  completed,
  cancelled,
}

/// Голос
class Vote extends Equatable {
  final String voteId;
  final String proposalId;
  final String voterId;
  final VoteChoice choice;
  final String? comment;
  final Map<String, dynamic> metadata;
  final DateTime castAt;
  final double voterReputation;
  final double voteWeight;

  const Vote({
    required this.voteId,
    required this.proposalId,
    required this.voterId,
    required this.choice,
    this.comment,
    required this.metadata,
    required this.castAt,
    required this.voterReputation,
    required this.voteWeight,
  });

  @override
  List<Object?> get props =>
      [voteId, proposalId, voterId, choice, comment, metadata, castAt, voterReputation, voteWeight];
}

/// Выбор голоса
enum VoteChoice {
  yes,
  no,
  abstain,
}

/// Результат голосования
class VoteResult extends Equatable {
  final bool success;
  final String? errorMessage;
  final String voteId;

  const VoteResult({
    required this.success,
    this.errorMessage,
    required this.voteId,
  });

  @override
  List<Object?> get props => [success, errorMessage, voteId];
}

/// Результат консенсуса
class ConsensusResult extends Equatable {
  final String proposalId;
  final ConsensusOutcome outcome;
  final int totalVotes;
  final int yesVotes;
  final int noVotes;
  final int abstainVotes;
  final bool hasQuorum;
  final bool hasMajority;
  final bool hasSuperMajority;
  final double participationRate;
  final DateTime? finalizedAt;
  final bool isPreliminary;

  const ConsensusResult({
    required this.proposalId,
    required this.outcome,
    required this.totalVotes,
    required this.yesVotes,
    required this.noVotes,
    required this.abstainVotes,
    required this.hasQuorum,
    required this.hasMajority,
    required this.hasSuperMajority,
    required this.participationRate,
    this.finalizedAt,
    required this.isPreliminary,
  });

  @override
  List<Object?> get props => [
        proposalId,
        outcome,
        totalVotes,
        yesVotes,
        noVotes,
        abstainVotes,
        hasQuorum,
        hasMajority,
        hasSuperMajority,
        participationRate,
        finalizedAt,
        isPreliminary
      ];
}

/// Исходы консенсуса
enum ConsensusOutcome {
  pending,
  approved,
  rejected,
  noQuorum,
}

/// Участник консенсуса
class ConsensusParticipant extends Equatable {
  final String participantId;
  final String name;
  final double reputation;
  final double votingPower;
  final DateTime joinedAt;
  final ParticipantStatus status;

  const ConsensusParticipant({
    required this.participantId,
    required this.name,
    required this.reputation,
    required this.votingPower,
    required this.joinedAt,
    required this.status,
  });

  @override
  List<Object?> get props => [participantId, name, reputation, votingPower, joinedAt, status];
}

/// Статусы участников
enum ParticipantStatus {
  active,
  suspended,
  inactive,
}

/// Репутация участника
class ParticipantReputation extends Equatable {
  final String participantId;
  final double reputationScore;
  final double votingAccuracy;
  final double participationRate;
  final DateTime lastUpdated;

  const ParticipantReputation({
    required this.participantId,
    required this.reputationScore,
    required this.votingAccuracy,
    required this.participationRate,
    required this.lastUpdated,
  });

  @override
  List<Object?> get props => [participantId, reputationScore, votingAccuracy, participationRate, lastUpdated];
}

/// Делегированное голосование
class DelegatedVoting extends Equatable {
  final String delegationId;
  final String delegatorId;
  final String delegateId;
  final List<ProposalType> allowedTypes;
  final DateTime createdAt;
  final DateTime expiresAt;
  final DelegationStatus status;

  const DelegatedVoting({
    required this.delegationId,
    required this.delegatorId,
    required this.delegateId,
    required this.allowedTypes,
    required this.createdAt,
    required this.expiresAt,
    required this.status,
  });

  @override
  List<Object?> get props => [delegationId, delegatorId, delegateId, allowedTypes, createdAt, expiresAt, status];
}

/// Статусы делегирования
enum DelegationStatus {
  active,
  expired,
  revoked,
}

/// Анализ консенсуса
class ConsensusAnalysis extends Equatable {
  final String proposalId;
  final int totalEligibleVoters;
  final int totalVotesCast;
  final double participationRate;
  final double consensusLevel;
  final ConsensusOutcome outcome;
  final double confidence;
  final Map<String, dynamic>? breakdown;
  final List<String> recommendations;
  final DateTime analyzedAt;

  const ConsensusAnalysis({
    required this.proposalId,
    required this.totalEligibleVoters,
    required this.totalVotesCast,
    required this.participationRate,
    required this.consensusLevel,
    required this.outcome,
    required this.confidence,
    this.breakdown,
    required this.recommendations,
    required this.analyzedAt,
  });

  @override
  List<Object?> get props => [
        proposalId,
        totalEligibleVoters,
        totalVotesCast,
        participationRate,
        consensusLevel,
        outcome,
        confidence,
        breakdown,
        recommendations,
        analyzedAt
      ];
}

/// Статистика голосования участника
class ParticipantVotingStats extends Equatable {
  final String participantId;
  final int totalVotesCast;
  final int proposalsCreated;
  final double averageParticipationRate;
  final double votingAccuracy;
  final double reputationScore;
  final DateTime? lastVoteAt;
  final DateTime timestamp;

  const ParticipantVotingStats({
    required this.participantId,
    required this.totalVotesCast,
    required this.proposalsCreated,
    required this.averageParticipationRate,
    required this.votingAccuracy,
    required this.reputationScore,
    this.lastVoteAt,
    required this.timestamp,
  });

  @override
  List<Object?> get props => [
        participantId,
        totalVotesCast,
        proposalsCreated,
        averageParticipationRate,
        votingAccuracy,
        reputationScore,
        lastVoteAt,
        timestamp
      ];
}
