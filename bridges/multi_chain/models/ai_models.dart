import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'ai_models.g.dart';

@JsonSerializable()
class AIConnector extends Equatable {
  final String id;
  final String name;
  final String baseUrl;
  final String apiKey;
  final List<String> models;
  final AIStatus status;
  final DateTime lastConnected;
  final Map<String, dynamic> config;

  const AIConnector({
    required this.id,
    required this.name,
    required this.baseUrl,
    required this.apiKey,
    required this.models,
    this.status = AIStatus.offline,
    required this.lastConnected,
    this.config = const {},
  });

  factory AIConnector.fromJson(Map<String, dynamic> json) => _$AIConnectorFromJson(json);
  Map<String, dynamic> toJson() => _$AIConnectorToJson(this);

  @override
  List<Object?> get props => [id, name, baseUrl, apiKey, models, status, lastConnected, config];
}

@JsonSerializable()
class AIModel extends Equatable {
  final String id;
  final String name;
  final String providerId;
  final ModelType type;
  final List<ModelCapability> capabilities;
  final int maxTokens;
  final double costPerToken;
  final Map<String, dynamic> metadata;

  const AIModel({
    required this.id,
    required this.name,
    required this.providerId,
    required this.type,
    this.capabilities = const [],
    this.maxTokens = 4096,
    this.costPerToken = 0.001,
    this.metadata = const {},
  });

  factory AIModel.fromJson(Map<String, dynamic> json) => _$AIModelFromJson(json);
  Map<String, dynamic> toJson() => _$AIModelToJson(this);

  @override
  List<Object?> get props => [id, name, providerId, type, capabilities, maxTokens, costPerToken, metadata];
}

@JsonSerializable()
class AIResponse extends Equatable {
  final bool success;
  final String? content;
  final String? model;
  final int? tokensUsed;
  final double? cost;
  final String? error;
  final Map<String, dynamic>? metadata;

  const AIResponse({
    required this.success,
    this.content,
    this.model,
    this.tokensUsed,
    this.cost,
    this.error,
    this.metadata,
  });

  const AIResponse.success({
    this.content,
    this.model,
    this.tokensUsed,
    this.cost,
    this.metadata,
  }) : success = true, error = null;

  const AIResponse.error({this.error}) : success = false, content = null, model = null, tokensUsed = null, cost = null, metadata = null;

  factory AIResponse.fromJson(Map<String, dynamic> json) => _$AIResponseFromJson(json);
  Map<String, dynamic> toJson() => _$AIResponseToJson(this);

  @override
  List<Object?> get props => [success, content, model, tokensUsed, cost, error, metadata];
}

@JsonSerializable()
class CodeGenerationResponse extends Equatable {
  final bool success;
  final String? code;
  final String? language;
  final double? confidence;
  final List<String>? suggestions;
  final String? error;
  final Map<String, dynamic>? metadata;

  const CodeGenerationResponse({
    required this.success,
    this.code,
    this.language,
    this.confidence,
    this.suggestions,
    this.error,
    this.metadata,
  });

  const CodeGenerationResponse.success({
    this.code,
    this.language,
    this.confidence,
    this.suggestions,
    this.metadata,
  }) : success = true, error = null;

  const CodeGenerationResponse.error({this.error}) : success = false, code = null, language = null, confidence = null, suggestions = null, metadata = null;

  factory CodeGenerationResponse.fromJson(Map<String, dynamic> json) => _$CodeGenerationResponseFromJson(json);
  Map<String, dynamic> toJson() => _$CodeGenerationResponseToJson(this);

  @override
  List<Object?> get props => [success, code, language, confidence, suggestions, error, metadata];
}

@JsonSerializable()
class CodeAnalysisResponse extends Equatable {
  final bool success;
  final String? analysis;
  final List<CodeIssue>? issues;
  final List<String>? suggestions;
  final String? error;
  final Map<String, dynamic>? metadata;

  const CodeAnalysisResponse({
    required this.success,
    this.analysis,
    this.issues,
    this.suggestions,
    this.error,
    this.metadata,
  });

  const CodeAnalysisResponse.success({
    this.analysis,
    this.issues,
    this.suggestions,
    this.metadata,
  }) : success = true, error = null;

  const CodeAnalysisResponse.error({this.error}) : success = false, analysis = null, issues = null, suggestions = null, metadata = null;

  factory CodeAnalysisResponse.fromJson(Map<String, dynamic> json) => _$CodeAnalysisResponseFromJson(json);
  Map<String, dynamic> toJson() => _$CodeAnalysisResponseToJson(this);

  @override
  List<Object?> get props => [success, analysis, issues, suggestions, error, metadata];
}

@JsonSerializable()
class CodeIssue extends Equatable {
  final String type;
  final String severity;
  final String message;
  final int? line;
  final int? column;
  final String? suggestion;

  const CodeIssue({
    required this.type,
    required this.severity,
    required this.message,
    this.line,
    this.column,
    this.suggestion,
  });

  factory CodeIssue.fromJson(Map<String, dynamic> json) => _$CodeIssueFromJson(json);
  Map<String, dynamic> toJson() => _$CodeIssueToJson(this);

  @override
  List<Object?> get props => [type, severity, message, line, column, suggestion];
}

@JsonSerializable()
class CodeValidation extends Equatable {
  final bool isValid;
  final double confidence;
  final List<String> suggestions;
  final List<CodeIssue> issues;

  const CodeValidation({
    this.isValid = true,
    this.confidence = 1.0,
    this.suggestions = const [],
    this.issues = const [],
  });

  factory CodeValidation.fromJson(Map<String, dynamic> json) => _$CodeValidationFromJson(json);
  Map<String, dynamic> toJson() => _$CodeValidationToJson(this);

  @override
  List<Object?> get props => [isValid, confidence, suggestions, issues];
}

@JsonSerializable()
class AITrainingData extends Equatable {
  final String dataId;
  final String providerId;
  final String model;
  final String content;
  final Map<String, dynamic> metadata;
  final DateTime createdAt;

  const AITrainingData({
    required this.dataId,
    required this.providerId,
    required this.model,
    required this.content,
    this.metadata = const {},
    required this.createdAt,
  });

  factory AITrainingData.fromJson(Map<String, dynamic> json) => _$AITrainingDataFromJson(json);
  Map<String, dynamic> toJson() => _$AITrainingDataToJson(this);

  @override
  List<Object?> get props => [dataId, providerId, model, content, metadata, createdAt];
}

@JsonSerializable()
class AIMetrics extends Equatable {
  final String providerId;
  final String model;
  final int totalRequests;
  final int successfulRequests;
  final double averageResponseTime;
  final double totalCost;
  final DateTime periodStart;
  final DateTime periodEnd;

  const AIMetrics({
    required this.providerId,
    required this.model,
    this.totalRequests = 0,
    this.successfulRequests = 0,
    this.averageResponseTime = 0.0,
    this.totalCost = 0.0,
    required this.periodStart,
    required this.periodEnd,
  });

  factory AIMetrics.fromJson(Map<String, dynamic> json) => _$AIMetricsFromJson(json);
  Map<String, dynamic> toJson() => _$AIMetricsToJson(this);

  @override
  List<Object?> get props => [providerId, model, totalRequests, successfulRequests, averageResponseTime, totalCost, periodStart, periodEnd];
}

@JsonSerializable()
class AIBilling extends Equatable {
  final String billingId;
  final String providerId;
  final double amount;
  final String currency;
  final DateTime periodStart;
  final DateTime periodEnd;
  final Map<String, double> usage;

  const AIBilling({
    required this.billingId,
    required this.providerId,
    required this.amount,
    required this.currency,
    required this.periodStart,
    required this.periodEnd,
    this.usage = const {},
  });

  factory AIBilling.fromJson(Map<String, dynamic> json) => _$AIBillingFromJson(json);
  Map<String, dynamic> toJson() => _$AIBillingToJson(this);

  @override
  List<Object?> get props => [billingId, providerId, amount, currency, periodStart, periodEnd, usage];
}

@JsonSerializable()
class AIEvaluation extends Equatable {
  final String evaluationId;
  final String modelId;
  final String task;
  final double score;
  final Map<String, dynamic> results;
  final DateTime evaluatedAt;

  const AIEvaluation({
    required this.evaluationId,
    required this.modelId,
    required this.task,
    required this.score,
    this.results = const {},
    required this.evaluatedAt,
  });

  factory AIEvaluation.fromJson(Map<String, dynamic> json) => _$AIEvaluationFromJson(json);
  Map<String, dynamic> toJson() => _$AIEvaluationToJson(this);

  @override
  List<Object?> get props => [evaluationId, modelId, task, score, results, evaluatedAt];
}

@JsonSerializable()
class OpenAIConnector extends AIConnector {
  const OpenAIConnector({
    required super.apiKey,
    super.config,
  }) : super(
    id: 'openai',
    name: 'OpenAI',
    baseUrl: 'https://api.openai.com/v1',
    models: ['gpt-4', 'gpt-3.5-turbo'],
    lastConnected: DateTime.now(),
  );

  Future<bool> testConnection() async {
    // Implementation for OpenAI connection test
    return true;
  }

  Future<AIStatus> getStatus() async {
    return AIStatus.online;
  }

  Future<AIResponse> generateResponse({
    required String model,
    required String prompt,
    Map<String, dynamic>? parameters,
    List<String>? context,
  }) async {
    // Implementation for OpenAI response generation
    return AIResponse.success(
      content: 'Generated response for: $prompt',
      model: model,
      tokensUsed: 100,
      cost: 0.02,
    );
  }

  Future<CodeGenerationResponse> generateCode({
    required String model,
    required String prompt,
    required String language,
    Map<String, dynamic>? constraints,
  }) async {
    // Implementation for OpenAI code generation
    return CodeGenerationResponse.success(
      code: 'Generated $language code',
      language: language,
      confidence: 0.95,
      suggestions: const ['Add error handling', 'Add documentation'],
    );
  }

  Future<CodeAnalysisResponse> analyzeCode({
    required String model,
    required String code,
    required String language,
    AnalysisType? analysisType,
  }) async {
    // Implementation for OpenAI code analysis
    return const CodeAnalysisResponse.success(
      analysis: 'Code analysis completed',
      suggestions: ['Improve naming', 'Add tests'],
    );
  }
}

@JsonSerializable()
class AnthropicConnector extends AIConnector {
  const AnthropicConnector({
    required super.apiKey,
    super.config,
  }) : super(
    id: 'anthropic',
    name: 'Anthropic',
    baseUrl: 'https://api.anthropic.com',
    models: ['claude-3-opus', 'claude-3-sonnet'],
    lastConnected: DateTime.now(),
  );

  Future<bool> testConnection() async {
    return true;
  }

  Future<AIStatus> getStatus() async {
    return AIStatus.online;
  }

  Future<AIResponse> generateResponse({
    required String model,
    required String prompt,
    Map<String, dynamic>? parameters,
    List<String>? context,
  }) async {
    return AIResponse.success(
      content: 'Claude response for: $prompt',
      model: model,
      tokensUsed: 80,
      cost: 0.015,
    );
  }

  Future<CodeGenerationResponse> generateCode({
    required String model,
    required String prompt,
    required String language,
    Map<String, dynamic>? constraints,
  }) async {
    return CodeGenerationResponse.success(
      code: 'Generated $language code by Claude',
      language: language,
      confidence: 0.92,
    );
  }

  Future<CodeAnalysisResponse> analyzeCode({
    required String model,
    required String code,
    required String language,
    AnalysisType? analysisType,
  }) async {
    return const CodeAnalysisResponse.success(
      analysis: 'Claude code analysis',
    );
  }
}

@JsonSerializable()
class GoogleAIConnector extends AIConnector {
  const GoogleAIConnector({
    required super.apiKey,
    super.config,
  }) : super(
    id: 'google',
    name: 'Google AI',
    baseUrl: 'https://generativelanguage.googleapis.com',
    models: ['gemini-pro', 'gemini-pro-vision'],
    lastConnected: DateTime.now(),
  );

  Future<bool> testConnection() async {
    return true;
  }

  Future<AIStatus> getStatus() async {
    return AIStatus.online;
  }

  Future<AIResponse> generateResponse({
    required String model,
    required String prompt,
    Map<String, dynamic>? parameters,
    List<String>? context,
  }) async {
    return AIResponse.success(
      content: 'Gemini response for: $prompt',
      model: model,
      tokensUsed: 120,
      cost: 0.025,
    );
  }

  Future<CodeGenerationResponse> generateCode({
    required String model,
    required String prompt,
    required String language,
    Map<String, dynamic>? constraints,
  }) async {
    return CodeGenerationResponse.success(
      code: 'Generated $language code by Gemini',
      language: language,
      confidence: 0.88,
    );
  }

  Future<CodeAnalysisResponse> analyzeCode({
    required String model,
    required String code,
    required String language,
    AnalysisType? analysisType,
  }) async {
    return const CodeAnalysisResponse.success(
      analysis: 'Gemini code analysis',
    );
  }
}

@JsonSerializable()
class CohereConnector extends AIConnector {
  const CohereConnector({
    required super.apiKey,
    super.config,
  }) : super(
    id: 'cohere',
    name: 'Cohere',
    baseUrl: 'https://api.cohere.ai',
    models: ['command', 'command-light'],
    lastConnected: DateTime.now(),
  );

  Future<bool> testConnection() async {
    return true;
  }

  Future<AIStatus> getStatus() async {
    return AIStatus.online;
  }

  Future<AIResponse> generateResponse({
    required String model,
    required String prompt,
    Map<String, dynamic>? parameters,
    List<String>? context,
  }) async {
    return AIResponse.success(
      content: 'Cohere response for: $prompt',
      model: model,
      tokensUsed: 90,
      cost: 0.018,
    );
  }

  Future<CodeGenerationResponse> generateCode({
    required String model,
    required String prompt,
    required String language,
    Map<String, dynamic>? constraints,
  }) async {
    return CodeGenerationResponse.success(
      code: 'Generated $language code by Cohere',
      language: language,
      confidence: 0.85,
    );
  }

  Future<CodeAnalysisResponse> analyzeCode({
    required String model,
    required String code,
    required String language,
    AnalysisType? analysisType,
  }) async {
    return const CodeAnalysisResponse.success(
      analysis: 'Cohere code analysis',
    );
  }
}

@JsonSerializable()
class HuggingFaceConnector extends AIConnector {
  const HuggingFaceConnector({
    required super.apiKey,
    super.config,
  }) : super(
    id: 'huggingface',
    name: 'Hugging Face',
    baseUrl: 'https://api-inference.huggingface.co',
    models: ['mistral-7b', 'llama-2-7b'],
    lastConnected: DateTime.now(),
  );

  Future<bool> testConnection() async {
    return true;
  }

  Future<AIStatus> getStatus() async {
    return AIStatus.online;
  }

  Future<AIResponse> generateResponse({
    required String model,
    required String prompt,
    Map<String, dynamic>? parameters,
    List<String>? context,
  }) async {
    return AIResponse.success(
      content: 'Hugging Face response for: $prompt',
      model: model,
      tokensUsed: 150,
      cost: 0.001,
    );
  }

  Future<CodeGenerationResponse> generateCode({
    required String model,
    required String prompt,
    required String language,
    Map<String, dynamic>? constraints,
  }) async {
    return CodeGenerationResponse.success(
      code: 'Generated $language code by Hugging Face',
      language: language,
      confidence: 0.78,
    );
  }

  Future<CodeAnalysisResponse> analyzeCode({
    required String model,
    required String code,
    required String language,
    AnalysisType? analysisType,
  }) async {
    return const CodeAnalysisResponse.success(
      analysis: 'Hugging Face code analysis',
    );
  }
}

@JsonSerializable()
class MetaAIConnector extends AIConnector {
  const MetaAIConnector({
    required super.apiKey,
    super.config,
  }) : super(
    id: 'meta',
    name: 'Meta AI',
    baseUrl: 'https://api.meta.ai',
    models: ['llama-3-8b', 'llama-3-70b', 'codellama-13b'],
    lastConnected: DateTime.now(),
  );

  Future<bool> testConnection() async {
    return true;
  }

  Future<AIStatus> getStatus() async {
    return AIStatus.online;
  }

  Future<AIResponse> generateResponse({
    required String model,
    required String prompt,
    Map<String, dynamic>? parameters,
    List<String>? context,
  }) async {
    return AIResponse.success(
      content: 'Meta AI response for: $prompt',
      model: model,
      tokensUsed: 110,
      cost: 0.01,
    );
  }

  Future<CodeGenerationResponse> generateCode({
    required String model,
    required String prompt,
    required String language,
    Map<String, dynamic>? constraints,
  }) async {
    return CodeGenerationResponse.success(
      code: 'Generated $language code by Meta AI',
      language: language,
      confidence: 0.90,
    );
  }

  Future<CodeAnalysisResponse> analyzeCode({
    required String model,
    required String code,
    required String language,
    AnalysisType? analysisType,
  }) async {
    return const CodeAnalysisResponse.success(
      analysis: 'Meta AI code analysis',
    );
  }
}

@JsonSerializable()
class GrokConnector extends AIConnector {
  const GrokConnector({
    required super.apiKey,
    super.config,
  }) : super(
    id: 'grok',
    name: 'Grok AI',
    baseUrl: 'https://api.x.ai',
    models: ['grok-1', 'grok-beta'],
    lastConnected: DateTime.now(),
  );

  Future<bool> testConnection() async {
    return true;
  }

  Future<AIStatus> getStatus() async {
    return AIStatus.online;
  }

  Future<AIResponse> generateResponse({
    required String model,
    required String prompt,
    Map<String, dynamic>? parameters,
    List<String>? context,
  }) async {
    return AIResponse.success(
      content: 'Grok response for: $prompt',
      model: model,
      tokensUsed: 120,
      cost: 0.02,
    );
  }

  Future<CodeGenerationResponse> generateCode({
    required String model,
    required String prompt,
    required String language,
    Map<String, dynamic>? constraints,
  }) async {
    return CodeGenerationResponse.success(
      code: 'Generated $language code by Grok',
      language: language,
      confidence: 0.93,
    );
  }

  Future<CodeAnalysisResponse> analyzeCode({
    required String model,
    required String code,
    required String language,
    AnalysisType? analysisType,
  }) async {
    return const CodeAnalysisResponse.success(
      analysis: 'Grok code analysis',
    );
  }
}

@JsonSerializable()
class MistralConnector extends AIConnector {
  const MistralConnector({
    required super.apiKey,
    super.config,
  }) : super(
    id: 'mistral',
    name: 'Mistral AI',
    baseUrl: 'https://api.mistral.ai',
    models: ['mistral-large', 'mistral-medium', 'mistral-small'],
    lastConnected: DateTime.now(),
  );

  Future<bool> testConnection() async {
    return true;
  }

  Future<AIStatus> getStatus() async {
    return AIStatus.online;
  }

  Future<AIResponse> generateResponse({
    required String model,
    required String prompt,
    Map<String, dynamic>? parameters,
    List<String>? context,
  }) async {
    return AIResponse.success(
      content: 'Mistral response for: $prompt',
      model: model,
      tokensUsed: 100,
      cost: 0.008,
    );
  }

  Future<CodeGenerationResponse> generateCode({
    required String model,
    required String prompt,
    required String language,
    Map<String, dynamic>? constraints,
  }) async {
    return CodeGenerationResponse.success(
      code: 'Generated $language code by Mistral',
      language: language,
      confidence: 0.91,
    );
  }

  Future<CodeAnalysisResponse> analyzeCode({
    required String model,
    required String code,
    required String language,
    AnalysisType? analysisType,
  }) async {
    return const CodeAnalysisResponse.success(
      analysis: 'Mistral code analysis',
    );
  }
}

@JsonSerializable()
class HuggingFaceInferenceConnector extends AIConnector {
  const HuggingFaceInferenceConnector({
    required super.apiKey,
    super.config,
  }) : super(
    id: 'huggingface_inference',
    name: 'Hugging Face Inference',
    baseUrl: 'https://api-inference.huggingface.co/models',
    models: ['meta-llama/Llama-2-7b-chat-hf', 'mistralai/Mistral-7B-Instruct-v0.1'],
    lastConnected: DateTime.now(),
  );

  Future<bool> testConnection() async {
    return true;
  }

  Future<AIStatus> getStatus() async {
    return AIStatus.online;
  }

  Future<AIResponse> generateResponse({
    required String model,
    required String prompt,
    Map<String, dynamic>? parameters,
    List<String>? context,
  }) async {
    return AIResponse.success(
      content: 'Hugging Face response for: $prompt',
      model: model,
      tokensUsed: 90,
      cost: 0.001,
    );
  }

  Future<CodeGenerationResponse> generateCode({
    required String model,
    required String prompt,
    required String language,
    Map<String, dynamic>? constraints,
  }) async {
    return CodeGenerationResponse.success(
      code: 'Generated $language code by Hugging Face',
      language: language,
      confidence: 0.88,
    );
  }

  Future<CodeAnalysisResponse> analyzeCode({
    required String model,
    required String code,
    required String language,
    AnalysisType? analysisType,
  }) async {
    return const CodeAnalysisResponse.success(
      analysis: 'Hugging Face code analysis',
    );
  }
}

@JsonSerializable()
class ReplicateConnector extends AIConnector {
  const ReplicateConnector({
    required super.apiKey,
    super.config,
  }) : super(
    id: 'replicate',
    name: 'Replicate AI',
    baseUrl: 'https://api.replicate.com/v1',
    models: ['stability-ai/stable-diffusion', 'andreasjansson/stable-diffusion-animation'],
    lastConnected: DateTime.now(),
  );

  Future<bool> testConnection() async {
    return true;
  }

  Future<AIStatus> getStatus() async {
    return AIStatus.online;
  }

  Future<AIResponse> generateResponse({
    required String model,
    required String prompt,
    Map<String, dynamic>? parameters,
    List<String>? context,
  }) async {
    return AIResponse.success(
      content: 'Replicate response for: $prompt',
      model: model,
      tokensUsed: 50,
      cost: 0.01,
    );
  }

  Future<CodeGenerationResponse> generateCode({
    required String model,
    required String prompt,
    required String language,
    Map<String, dynamic>? constraints,
  }) async {
    return CodeGenerationResponse.success(
      code: 'Generated $language code by Replicate',
      language: language,
      confidence: 0.85,
    );
  }

  Future<CodeAnalysisResponse> analyzeCode({
    required String model,
    required String code,
    required String language,
    AnalysisType? analysisType,
  }) async {
    return const CodeAnalysisResponse.success(
      analysis: 'Replicate code analysis',
    );
  }
}

@JsonSerializable()
class CohereCommandConnector extends AIConnector {
  const CohereCommandConnector({
    required super.apiKey,
    super.config,
  }) : super(
    id: 'cohere_command',
    name: 'Cohere Command',
    baseUrl: 'https://api.cohere.ai',
    models: ['command-xlarge-nightly', 'command-medium-nightly'],
    lastConnected: DateTime.now(),
  );

  Future<bool> testConnection() async {
    return true;
  }

  Future<AIStatus> getStatus() async {
    return AIStatus.online;
  }

  Future<AIResponse> generateResponse({
    required String model,
    required String prompt,
    Map<String, dynamic>? parameters,
    List<String>? context,
  }) async {
    return AIResponse.success(
      content: 'Cohere response for: $prompt',
      model: model,
      tokensUsed: 120,
      cost: 0.002,
    );
  }

  Future<CodeGenerationResponse> generateCode({
    required String model,
    required String prompt,
    required String language,
    Map<String, dynamic>? constraints,
  }) async {
    return CodeGenerationResponse.success(
      code: 'Generated $language code by Cohere',
      language: language,
      confidence: 0.92,
    );
  }

  Future<CodeAnalysisResponse> analyzeCode({
    required String model,
    required String code,
    required String language,
    AnalysisType? analysisType,
  }) async {
    return const CodeAnalysisResponse.success(
      analysis: 'Cohere code analysis',
    );
  }
}

@JsonSerializable()
class VibeAnalysis extends Equatable {
  final bool success;
  final double? positivity;
  final double? negativity;
  final double? excitement;
  final List<String>? suggestions;
  final String? error;
  final Map<String, dynamic>? metadata;

  const VibeAnalysis({
    required this.success,
    this.positivity,
    this.negativity,
    this.excitement,
    this.suggestions,
    this.error,
    this.metadata,
  });

  const VibeAnalysis.success({
    this.positivity,
    this.negativity,
    this.excitement,
    this.suggestions,
    this.metadata,
  }) : success = true, error = null;

  const VibeAnalysis.error({this.error}) : success = false, positivity = null, negativity = null, excitement = null, suggestions = null, metadata = null;

  factory VibeAnalysis.fromJson(Map<String, dynamic> json) => _$VibeAnalysisFromJson(json);
  Map<String, dynamic> toJson() => _$VibeAnalysisToJson(this);

  @override
  List<Object?> get props => [success, positivity, negativity, excitement, suggestions, error, metadata];
}

enum ModelCapability {
  textGeneration,
  chat,
  codeGeneration,
  codeAnalysis,
  imageGeneration,
  imageUnderstanding,
  audioGeneration,
  audioUnderstanding,
}

enum AnalysisType {
  security,
  performance,
  maintainability,
  complexity,
  documentation,
}

  }
}

// Advanced AI Connectors

@JsonSerializable()
class CustomLocalConnector extends AIConnector {
  final String modelPath;
  final String modelType; // llama, mistral, phi, etc.

  const CustomLocalConnector({
    required this.modelPath,
    required this.modelType,
    super.config,
  }) : super(
    id: 'custom_local_$modelType',
    name: 'Custom Local $modelType',
    baseUrl: 'http://localhost:11434',
    models: ['custom-$modelType'],
    lastConnected: DateTime.now(),
  );

  Future<bool> testConnection() async {
    return true;
  }

  Future<AIStatus> getStatus() async {
    return AIStatus.online;
  }

  Future<AIResponse> generateResponse({
    required String model,
    required String prompt,
    Map<String, dynamic>? parameters,
    List<String>? context,
  }) async {
    return AIResponse.success(
      content: 'Custom local response for: $prompt',
      model: model,
      tokensUsed: 80,
      cost: 0.0, // Free local inference
    );
  }

  Future<CodeGenerationResponse> generateCode({
    required String model,
    required String prompt,
    required String language,
    Map<String, dynamic>? constraints,
  }) async {
    return CodeGenerationResponse.success(
      code: 'Generated $language code by custom local model',
      language: language,
      confidence: 0.85,
    );
  }

  Future<CodeAnalysisResponse> analyzeCode({
    required String model,
    required String code,
    required String language,
    AnalysisType? analysisType,
  }) async {
    return const CodeAnalysisResponse.success(
      analysis: 'Custom local model code analysis',
    );
  }
}

@JsonSerializable()
class FederatedLearningConnector extends AIConnector {
  final List<String> participantNodes;
  final String aggregationStrategy;

  const FederatedLearningConnector({
    required this.participantNodes,
    required this.aggregationStrategy,
    super.config,
  }) : super(
    id: 'federated_learning',
    name: 'Federated Learning Network',
    baseUrl: 'https://federated.example.com',
    models: ['federated-model-v1'],
    lastConnected: DateTime.now(),
  );

  Future<bool> testConnection() async {
    return true;
  }

  Future<AIStatus> getStatus() async {
    return AIStatus.online;
  }

  Future<AIResponse> generateResponse({
    required String model,
    required String prompt,
    Map<String, dynamic>? parameters,
    List<String>? context,
  }) async {
    return AIResponse.success(
      content: 'Federated learning response for: $prompt',
      model: model,
      tokensUsed: 100,
      cost: 0.001,
    );
  }

  Future<CodeGenerationResponse> generateCode({
    required String model,
    required String prompt,
    required String language,
    Map<String, dynamic>? constraints,
  }) async {
    return CodeGenerationResponse.success(
      code: 'Generated $language code by federated model',
      language: language,
      confidence: 0.88,
    );
  }

  Future<CodeAnalysisResponse> analyzeCode({
    required String model,
    required String code,
    required String language,
    AnalysisType? analysisType,
  }) async {
    return const CodeAnalysisResponse.success(
      analysis: 'Federated learning code analysis',
    );
  }
}

@JsonSerializable()
class AIMarketplaceConnector extends AIConnector {
  final String marketplaceType; // huggingface_hub, replicate_market, custom
  final String apiKey;

  const AIMarketplaceConnector({
    required this.marketplaceType,
    required this.apiKey,
    super.config,
  }) : super(
    id: 'ai_marketplace_$marketplaceType',
    name: 'AI Marketplace ($marketplaceType)',
    baseUrl: 'https://marketplace.example.com',
    models: ['marketplace-models'],
    lastConnected: DateTime.now(),
  );

  Future<bool> testConnection() async {
    return true;
  }

  Future<AIStatus> getStatus() async {
    return AIStatus.online;
  }

  Future<AIResponse> generateResponse({
    required String model,
    required String prompt,
    Map<String, dynamic>? parameters,
    List<String>? context,
  }) async {
    return AIResponse.success(
      content: 'AI marketplace response for: $prompt',
      model: model,
      tokensUsed: 90,
      cost: 0.003,
    );
  }

  Future<CodeGenerationResponse> generateCode({
    required String model,
    required String prompt,
    required String language,
    Map<String, dynamic>? constraints,
  }) async {
    return CodeGenerationResponse.success(
      code: 'Generated $language code by marketplace model',
      language: language,
      confidence: 0.90,
    );
  }

  Future<CodeAnalysisResponse> analyzeCode({
    required String model,
    required String code,
    required String language,
    AnalysisType? analysisType,
  }) async {
    return const CodeAnalysisResponse.success(
      analysis: 'AI marketplace code analysis',
    );
  }
}

// Supporting model classes

@JsonSerializable()
class AdvancedVibeAnalysis extends Equatable {
  final bool success;
  final double? positivity;
  final double? negativity;
  final double? excitement;
  final double? anger;
  final double? sadness;
  final double? fear;
  final double? surprise;
  final double? disgust;
  final String? culturalContext;
  final String? language;
  final double? emotionalIntensity;
  final SentimentTrajectory? sentimentTrajectory;
  final List<String>? suggestions;
  final String? error;
  final Map<String, dynamic>? metadata;

  const AdvancedVibeAnalysis({
    required this.success,
    this.positivity,
    this.negativity,
    this.excitement,
    this.anger,
    this.sadness,
    this.fear,
    this.surprise,
    this.disgust,
    this.culturalContext,
    this.language,
    this.emotionalIntensity,
    this.sentimentTrajectory,
    this.suggestions,
    this.error,
    this.metadata,
  });

  const AdvancedVibeAnalysis.success({
    this.positivity,
    this.negativity,
    this.excitement,
    this.anger,
    this.sadness,
    this.fear,
    this.surprise,
    this.disgust,
    this.culturalContext,
    this.language,
    this.emotionalIntensity,
    this.sentimentTrajectory,
    this.suggestions,
    this.metadata,
  }) : success = true, error = null;

  const AdvancedVibeAnalysis.error({this.error}) : success = false, positivity = null, negativity = null, excitement = null, anger = null, sadness = null, fear = null, surprise = null, disgust = null, culturalContext = null, language = null, emotionalIntensity = null, sentimentTrajectory = null, suggestions = null, metadata = null;

  factory AdvancedVibeAnalysis.fromJson(Map<String, dynamic> json) => _$AdvancedVibeAnalysisFromJson(json);
  Map<String, dynamic> toJson() => _$AdvancedVibeAnalysisToJson(this);

  @override
  List<Object?> get props => [success, positivity, negativity, excitement, anger, sadness, fear, surprise, disgust, culturalContext, language, emotionalIntensity, sentimentTrajectory, suggestions, error, metadata];
}

@JsonSerializable()
class CodeGenerationResponse extends Equatable {
  final bool success;
  final String? code;
  final String? language;
  final double? confidence;
  final List<String>? suggestions;
  final String? error;
  final Map<String, dynamic>? metadata;

  const CodeGenerationResponse({
    required this.success,
    this.code,
    this.language,
    this.confidence,
    this.suggestions,
    this.error,
    this.metadata,
  });

  const CodeGenerationResponse.success({
    this.code,
    this.language,
    this.confidence,
    this.suggestions,
    this.metadata,
  }) : success = true, error = null;

  const CodeGenerationResponse.error({this.error}) : success = false, code = null, language = null, confidence = null, suggestions = null, metadata = null;

  factory CodeGenerationResponse.fromJson(Map<String, dynamic> json) => _$CodeGenerationResponseFromJson(json);
  Map<String, dynamic> toJson() => _$CodeGenerationResponseToJson(this);

  @override
  List<Object?> get props => [success, code, language, confidence, suggestions, error, metadata];
}

enum SentimentTrajectory {
  improving,
  declining,
  stable,
}

enum ModelType {
  text,
  chat,
  code,
  vision,
  audio,
  multimodal,
}

enum ModelCapability {
  textGeneration,
  chat,
  codeGeneration,
  codeAnalysis,
  imageGeneration,
  imageUnderstanding,
  audioGeneration,
  audioUnderstanding,
}

enum AnalysisType {
  security,
  performance,
  maintainability,
  complexity,
  documentation,
}

enum BridgeStatus {
  online,
  offline,
  degraded,
  maintenance,
}

enum AIStatus {
  online,
  offline,
  rateLimited,
  maintenance,
}
