import 'package:flutter/material.dart';

import 'performance_metrics_dashboard.dart';
import 'performance_optimization_dashboard.dart';
import 'performance_profiler_dashboard.dart';
import 'performance_trend_analyzer_dashboard.dart';

/// Главный дашборд для системы аналитики производительности
class PerformanceAnalyticsMainDashboard extends StatefulWidget {
  const PerformanceAnalyticsMainDashboard({super.key});

  @override
  State<PerformanceAnalyticsMainDashboard> createState() => _PerformanceAnalyticsMainDashboardState();
}

class _PerformanceAnalyticsMainDashboardState extends State<PerformanceAnalyticsMainDashboard> {
  int _selectedIndex = 0;

  final List<Widget> _dashboards = [
    const PerformanceMetricsDashboard(),
    const PerformanceProfilerDashboard(),
    const PerformanceOptimizationDashboard(),
    const PerformanceTrendAnalyzerDashboard(),
  ];

  final List<String> _dashboardTitles = [
    'Metrics',
    'Profiler',
    'Optimization',
    'Trend Analysis',
  ];

  final List<IconData> _dashboardIcons = [
    Icons.analytics,
    Icons.speed,
    Icons.tune,
    Icons.trending_up,
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Performance Analytics - ${_dashboardTitles[_selectedIndex]}'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        elevation: 2,
      ),
      body: Row(
        children: [
          // Боковая панель навигации
          NavigationRail(
            selectedIndex: _selectedIndex,
            onDestinationSelected: (index) {
              setState(() {
                _selectedIndex = index;
              });
            },
            labelType: NavigationRailLabelType.all,
            destinations: _dashboardTitles.asMap().entries.map((entry) {
              return NavigationRailDestination(
                icon: Icon(_dashboardIcons[entry.key]),
                selectedIcon: Icon(_dashboardIcons[entry.key]),
                label: Text(entry.value),
              );
            }).toList(),
          ),
          const VerticalDivider(thickness: 1, width: 1),
          // Основной контент
          Expanded(
            child: _dashboards[_selectedIndex],
          ),
        ],
      ),
    );
  }
}
