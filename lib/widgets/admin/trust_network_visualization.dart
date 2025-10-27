import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../services/trust_network/models/trust_identity.dart';
import '../../services/trust_network/models/trust_verification.dart';
import '../../services/trust_network/trust_network_service.dart';

/// Виджет для визуализации сети доверия
class TrustNetworkVisualization extends StatefulWidget {
  const TrustNetworkVisualization({super.key});

  @override
  State<TrustNetworkVisualization> createState() => _TrustNetworkVisualizationState();
}

class _TrustNetworkVisualizationState extends State<TrustNetworkVisualization> with TickerProviderStateMixin {
  final TrustNetworkService _trustService = TrustNetworkService();

  late AnimationController _animationController;
  late Animation<double> _animation;

  List<TrustIdentity> _identities = [];
  List<TrustVerification> _verifications = [];
  final Map<String, Offset> _nodePositions = {};

  String _selectedNodeId = '';
  bool _isLoading = true;
  double _zoomLevel = 1.0;
  Offset _panOffset = Offset.zero;

  // Фильтры
  double _minTrustScore = 0.0;
  String _selectedProtocol = 'All';
  bool _showOnlyVerified = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _loadNetworkData();
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadNetworkData() async {
    try {
      final identities = await _trustService.getAllIdentities();
      final verifications = await _trustService.getAllVerifications();

      setState(() {
        _identities = identities;
        _verifications = verifications;
        _isLoading = false;
      });

      _generateNodePositions();
    } catch (e) {
      setState(() => _isLoading = false);
      _showErrorSnackBar('Failed to load network data: $e');
    }
  }

  void _generateNodePositions() {
    final filteredIdentities = _getFilteredIdentities();
    const center = Offset(400, 300); // Центр экрана
    const radius = 200.0;

    _nodePositions.clear();

    for (int i = 0; i < filteredIdentities.length; i++) {
      final angle = (2 * math.pi * i) / filteredIdentities.length;
      final x = center.dx + radius * math.cos(angle);
      final y = center.dy + radius * math.sin(angle);

      _nodePositions[filteredIdentities[i].id] = Offset(x, y);
    }
  }

  List<TrustIdentity> _getFilteredIdentities() {
    return _identities.where((identity) {
      if (_minTrustScore > 0 && identity.reputationScore < _minTrustScore) {
        return false;
      }

      if (_selectedProtocol != 'All' && identity.protocol != _selectedProtocol) {
        return false;
      }

      if (_showOnlyVerified && !identity.isVerified) {
        return false;
      }

      return true;
    }).toList();
  }

  List<TrustVerification> _getFilteredVerifications() {
    final filteredIdentities = _getFilteredIdentities();
    final filteredIds = filteredIdentities.map((i) => i.id).toSet();

    return _verifications.where((verification) {
      return filteredIds.contains(verification.fromIdentityId) && filteredIds.contains(verification.toIdentityId);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          _buildControls(),
          Expanded(
            child: _isLoading ? const Center(child: CircularProgressIndicator()) : _buildNetworkVisualization(),
          ),
        ],
      ),
    );
  }

  Widget _buildControls() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).dividerColor,
            width: 1,
          ),
        ),
      ),
      child: Column(
        children: [
          // Основные контролы
          Row(
            children: [
              Expanded(
                child: _buildFilterControls(),
              ),
              const SizedBox(width: 16),
              _buildActionButtons(),
            ],
          ),
          const SizedBox(height: 12),
          // Статистика
          _buildStatistics(),
        ],
      ),
    );
  }

  Widget _buildFilterControls() {
    final protocols = ['All', ..._identities.map((i) => i.protocol).toSet()];

    return Row(
      children: [
        // Фильтр по минимальному уровню доверия
        Expanded(
          flex: 2,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Min Trust Score: ${_minTrustScore.toStringAsFixed(1)}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              Slider(
                value: _minTrustScore,
                min: 0.0,
                max: 10.0,
                divisions: 20,
                onChanged: (value) {
                  setState(() {
                    _minTrustScore = value;
                    _generateNodePositions();
                  });
                },
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),

        // Фильтр по протоколу
        Expanded(
          flex: 2,
          child: DropdownButtonFormField<String>(
            initialValue: _selectedProtocol,
            decoration: const InputDecoration(
              labelText: 'Protocol',
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
            items: protocols.map((protocol) {
              return DropdownMenuItem<String>(
                value: protocol,
                child: Text(protocol),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedProtocol = value!;
                _generateNodePositions();
              });
            },
          ),
        ),
        const SizedBox(width: 16),

        // Фильтр только проверенных
        Expanded(
          flex: 1,
          child: CheckboxListTile(
            title: const Text('Verified Only'),
            value: _showOnlyVerified,
            onChanged: (value) {
              setState(() {
                _showOnlyVerified = value!;
                _generateNodePositions();
              });
            },
            contentPadding: EdgeInsets.zero,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: const Icon(Icons.zoom_in),
          onPressed: _zoomIn,
          tooltip: 'Zoom In',
        ),
        IconButton(
          icon: const Icon(Icons.zoom_out),
          onPressed: _zoomOut,
          tooltip: 'Zoom Out',
        ),
        IconButton(
          icon: const Icon(Icons.center_focus_strong),
          onPressed: _resetView,
          tooltip: 'Reset View',
        ),
        IconButton(
          icon: const Icon(Icons.refresh),
          onPressed: _loadNetworkData,
          tooltip: 'Refresh',
        ),
        IconButton(
          icon: const Icon(Icons.fullscreen),
          onPressed: _toggleFullscreen,
          tooltip: 'Fullscreen',
        ),
      ],
    );
  }

  Widget _buildStatistics() {
    final filteredIdentities = _getFilteredIdentities();
    final filteredVerifications = _getFilteredVerifications();

    return Row(
      children: [
        _buildStatChip('Nodes', '${filteredIdentities.length}'),
        const SizedBox(width: 8),
        _buildStatChip('Connections', '${filteredVerifications.length}'),
        const SizedBox(width: 8),
        _buildStatChip('Avg Trust', _getAverageTrustScore(filteredIdentities)),
        const SizedBox(width: 8),
        _buildStatChip('Verified', '${filteredIdentities.where((i) => i.isVerified).length}'),
      ],
    );
  }

  Widget _buildStatChip(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        '$label: $value',
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.w500,
            ),
      ),
    );
  }

  String _getAverageTrustScore(List<TrustIdentity> identities) {
    if (identities.isEmpty) return '0.0';
    final average = identities.map((i) => i.reputationScore).reduce((a, b) => a + b) / identities.length;
    return average.toStringAsFixed(1);
  }

  Widget _buildNetworkVisualization() {
    return GestureDetector(
      onPanUpdate: _onPanUpdate,
      onScaleUpdate: _onScaleUpdate,
      child: Container(
        width: double.infinity,
        height: double.infinity,
        color: Theme.of(context).colorScheme.surface,
        child: AnimatedBuilder(
          animation: _animation,
          builder: (context, child) {
            return CustomPaint(
              painter: NetworkPainter(
                identities: _getFilteredIdentities(),
                verifications: _getFilteredVerifications(),
                nodePositions: _nodePositions,
                selectedNodeId: _selectedNodeId,
                zoomLevel: _zoomLevel,
                panOffset: _panOffset,
                animationValue: _animation.value,
              ),
              child: GestureDetector(
                onTapDown: _onNodeTap,
                child: Container(),
              ),
            );
          },
        ),
      ),
    );
  }

  void _onPanUpdate(DragUpdateDetails details) {
    setState(() {
      _panOffset += details.delta;
    });
  }

  void _onScaleUpdate(ScaleUpdateDetails details) {
    setState(() {
      _zoomLevel = (_zoomLevel * details.scale).clamp(0.5, 3.0);
    });
  }

  void _onNodeTap(TapDownDetails details) {
    final filteredIdentities = _getFilteredIdentities();

    for (final identity in filteredIdentities) {
      final position = _nodePositions[identity.id];
      if (position != null) {
        final screenPosition = (position * _zoomLevel) + _panOffset;
        final distance = (screenPosition - details.localPosition).distance;

        if (distance < 20) {
          // Радиус узла
          setState(() {
            _selectedNodeId = identity.id;
          });
          _showNodeDetails(identity);
          return;
        }
      }
    }

    // Если клик не по узлу
    setState(() {
      _selectedNodeId = '';
    });
  }

  void _zoomIn() {
    setState(() {
      _zoomLevel = (_zoomLevel * 1.2).clamp(0.5, 3.0);
    });
  }

  void _zoomOut() {
    setState(() {
      _zoomLevel = (_zoomLevel / 1.2).clamp(0.5, 3.0);
    });
  }

  void _resetView() {
    setState(() {
      _zoomLevel = 1.0;
      _panOffset = Offset.zero;
      _selectedNodeId = '';
    });
  }

  void _toggleFullscreen() {
    // TODO: Implement fullscreen mode
    _showInfoSnackBar('Fullscreen mode not implemented yet');
  }

  void _showNodeDetails(TrustIdentity identity) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(identity.name),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow('ID', identity.id),
            _buildDetailRow('Protocol', identity.protocol),
            _buildDetailRow('Trust Score', identity.reputationScore.toStringAsFixed(2)),
            _buildDetailRow('Verified', identity.isVerified ? 'Yes' : 'No'),
            _buildDetailRow('Last Seen', identity.lastSeen.toString()),
            _buildDetailRow('Created', identity.createdAt.toString()),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _showNodeConnections(identity);
            },
            child: const Text('View Connections'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }

  void _showNodeConnections(TrustIdentity identity) {
    final connections =
        _verifications.where((v) => v.fromIdentityId == identity.id || v.toIdentityId == identity.id).toList();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Connections for ${identity.name}'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: connections.length,
            itemBuilder: (context, index) {
              final verification = connections[index];
              final otherIdentityId =
                  verification.fromIdentityId == identity.id ? verification.toIdentityId : verification.fromIdentityId;
              final otherIdentity = _identities.firstWhere((i) => i.id == otherIdentityId);

              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: _getTrustColor(verification.trustScore),
                  child: Text(
                    verification.trustScore.toStringAsFixed(1),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                title: Text(otherIdentity.name),
                subtitle: Text('${otherIdentity.protocol} • ${verification.trustScore.toStringAsFixed(2)}'),
                trailing: Text(
                  verification.status.name,
                  style: TextStyle(
                    color: _getStatusColor(verification.status),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Color _getTrustColor(double trustScore) {
    if (trustScore >= 8.0) return Colors.green;
    if (trustScore >= 6.0) return Colors.blue;
    if (trustScore >= 4.0) return Colors.orange;
    return Colors.red;
  }

  Color _getStatusColor(VerificationStatus status) {
    switch (status) {
      case VerificationStatus.verified:
        return Colors.green;
      case VerificationStatus.pending:
        return Colors.orange;
      case VerificationStatus.failed:
        return Colors.red;
      case VerificationStatus.revoked:
        return Colors.grey;
      case VerificationStatus.expired:
        return Colors.blueGrey;
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _showInfoSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.blue,
      ),
    );
  }
}

/// Кастомный painter для отрисовки сети
class NetworkPainter extends CustomPainter {
  final List<TrustIdentity> identities;
  final List<TrustVerification> verifications;
  final Map<String, Offset> nodePositions;
  final String selectedNodeId;
  final double zoomLevel;
  final Offset panOffset;
  final double animationValue;

  NetworkPainter({
    required this.identities,
    required this.verifications,
    required this.nodePositions,
    required this.selectedNodeId,
    required this.zoomLevel,
    required this.panOffset,
    required this.animationValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Отрисовка соединений
    _drawConnections(canvas);

    // Отрисовка узлов
    _drawNodes(canvas);

    // Отрисовка меток
    _drawLabels(canvas);
  }

  void _drawConnections(Canvas canvas) {
    final connectionPaint = Paint()
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    for (final verification in verifications) {
      final fromPos = nodePositions[verification.fromIdentityId];
      final toPos = nodePositions[verification.toIdentityId];

      if (fromPos != null && toPos != null) {
        final startPos = (fromPos * zoomLevel) + panOffset;
        final endPos = (toPos * zoomLevel) + panOffset;

        // Цвет соединения зависит от уровня доверия
        connectionPaint.color = _getTrustColor(verification.trustScore).withOpacity(0.6);

        // Толщина линии зависит от уровня доверия
        connectionPaint.strokeWidth = (verification.trustScore / 10.0 * 3.0).clamp(0.5, 3.0);

        canvas.drawLine(startPos, endPos, connectionPaint);

        // Анимация соединения
        if (animationValue < 1.0) {
          final animatedEndPos = Offset.lerp(startPos, endPos, animationValue)!;
          connectionPaint.color = connectionPaint.color.withOpacity(0.3);
          canvas.drawLine(startPos, animatedEndPos, connectionPaint);
        }
      }
    }
  }

  void _drawNodes(Canvas canvas) {
    for (final identity in identities) {
      final position = nodePositions[identity.id];
      if (position != null) {
        final screenPos = (position * zoomLevel) + panOffset;
        final isSelected = identity.id == selectedNodeId;

        // Основной круг узла
        final nodePaint = Paint()
          ..style = PaintingStyle.fill
          ..color = _getTrustColor(identity.reputationScore);

        final nodeRadius = isSelected ? 25.0 : 15.0;
        canvas.drawCircle(screenPos, nodeRadius, nodePaint);

        // Обводка
        final borderPaint = Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = isSelected ? 3.0 : 1.0
          ..color = isSelected ? Colors.white : Colors.black.withOpacity(0.3);

        canvas.drawCircle(screenPos, nodeRadius, borderPaint);

        // Статус верификации
        if (identity.isVerified) {
          final verifiedPaint = Paint()
            ..style = PaintingStyle.fill
            ..color = Colors.green;

          canvas.drawCircle(
            screenPos + Offset(nodeRadius * 0.7, -nodeRadius * 0.7),
            5.0,
            verifiedPaint,
          );
        }

        // Анимация появления
        if (animationValue < 1.0) {
          final animatedRadius = nodeRadius * animationValue;
          final animatedPaint = Paint()
            ..style = PaintingStyle.fill
            ..color = nodePaint.color.withOpacity(0.3);

          canvas.drawCircle(screenPos, animatedRadius, animatedPaint);
        }
      }
    }
  }

  void _drawLabels(Canvas canvas) {
    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
    );

    for (final identity in identities) {
      final position = nodePositions[identity.id];
      if (position != null && zoomLevel > 0.8) {
        // Показываем метки только при достаточном зуме
        final screenPos = (position * zoomLevel) + panOffset;

        textPainter.text = TextSpan(
          text: identity.name,
          style: TextStyle(
            color: Colors.black87,
            fontSize: 12 * zoomLevel,
            fontWeight: FontWeight.w500,
          ),
        );

        textPainter.layout();
        textPainter.paint(
          canvas,
          screenPos + Offset(-textPainter.width / 2, 35),
        );
      }
    }
  }

  Color _getTrustColor(double trustScore) {
    if (trustScore >= 8.0) return Colors.green;
    if (trustScore >= 6.0) return Colors.blue;
    if (trustScore >= 4.0) return Colors.orange;
    return Colors.red;
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return oldDelegate is! NetworkPainter ||
        oldDelegate.animationValue != animationValue ||
        oldDelegate.selectedNodeId != selectedNodeId ||
        oldDelegate.zoomLevel != zoomLevel ||
        oldDelegate.panOffset != panOffset;
  }
}
