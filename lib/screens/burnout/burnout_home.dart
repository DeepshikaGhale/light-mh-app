import 'package:flutter/material.dart';
import '../../theme/obs_theme.dart';
import '../../services/mock_rootly_service.dart';
import 'burnout_dashboard.dart';
import 'incident_timeline.dart';
import 'circuit_breaker.dart';
import '../breathe/breathe_screen.dart';
import '../journal/journal_screen.dart';

class BurnoutHome extends StatefulWidget {
  const BurnoutHome({super.key});

  @override
  State<BurnoutHome> createState() => _BurnoutHomeState();
}

class _BurnoutHomeState extends State<BurnoutHome> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final pages = [
      const BurnoutDashboard(),
      const IncidentTimeline(),
      const CircuitBreaker(),
      const _RecoveryScreen(),
    ];

    return Scaffold(
      body: pages[_currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (i) => setState(() => _currentIndex = i),
        backgroundColor: ObsTheme.surfaceOf(context),
        indicatorColor: ObsTheme.safeOf(context).withValues(alpha: 0.12),
        destinations: [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined, color: ObsTheme.textSecondaryOf(context)),
            selectedIcon: Icon(Icons.dashboard, color: ObsTheme.safeOf(context)),
            label: 'Dashboard',
          ),
          NavigationDestination(
            icon: Icon(Icons.timeline_outlined, color: ObsTheme.textSecondaryOf(context)),
            selectedIcon: Icon(Icons.timeline, color: ObsTheme.safeOf(context)),
            label: 'Timeline',
          ),
          NavigationDestination(
            icon: Icon(Icons.shield_outlined, color: ObsTheme.textSecondaryOf(context)),
            selectedIcon: Icon(Icons.shield, color: ObsTheme.critical),
            label: 'Breaker',
          ),
          NavigationDestination(
            icon: Icon(Icons.self_improvement_outlined, color: ObsTheme.textSecondaryOf(context)),
            selectedIcon: Icon(Icons.self_improvement, color: ObsTheme.safeOf(context)),
            label: 'Recovery',
          ),
        ],
      ),
    );
  }
}

/// Recovery screen — bridges to existing wellness features
class _RecoveryScreen extends StatelessWidget {
  const _RecoveryScreen();

  @override
  Widget build(BuildContext context) {
    final delta = MockWellnessService.computeResilienceDelta();

    return Scaffold(
      backgroundColor: ObsTheme.bgOf(context),
      appBar: AppBar(title: const Text('Recovery Mode')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: ObsTheme.safeOf(context).withValues(alpha: 0.06),
                border: Border.all(color: ObsTheme.safeOf(context).withValues(alpha: 0.2)),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'ACTIVE RECOVERY',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Courier',
                      letterSpacing: 1,
                      color: ObsTheme.safeOf(context),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Your composite score is ${delta.compositeScore}. '
                    'These exercises help your nervous system recover from high-stress on-call shifts.',
                    style: TextStyle(
                      fontSize: 13,
                      color: ObsTheme.textSecondaryOf(context),
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            _RecoveryTile(
              icon: Icons.air_rounded,
              title: '4-7-8 Breathing',
              subtitle: 'Activates parasympathetic response. Targets RMSSD recovery.',
              metric: 'Current HRV: 28ms (target: >40ms)',
              metricBad: true,
              onTap: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const BreatheScreen())),
            ),
            const SizedBox(height: 12),

            _RecoveryTile(
              icon: Icons.edit_note_rounded,
              title: 'Incident Debrief Journal',
              subtitle: 'CBT-based thought record. Process incident stress before it compounds.',
              metric: 'Last journal: 3 days ago',
              metricBad: false,
              onTap: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const JournalScreen())),
            ),
            const SizedBox(height: 12),

            _RecoveryTile(
              icon: Icons.nightlight_round,
              title: 'Sleep Optimization',
              subtitle: 'Based on your next shift and current sleep debt.',
              metric: 'Recommended bedtime: 10:00 PM',
              metricBad: false,
              onTap: () {
                showDialog(
                  context: context,
                  builder: (_) => AlertDialog(
                    backgroundColor: ObsTheme.surfaceOf(context),
                    title: Text('Sleep Coach', style: TextStyle(color: ObsTheme.textPrimaryOf(context))),
                    content: Text(
                      'Based on DREAMT sleep patterns:\n\n'
                      '• Your sleep efficiency has been below 85% for 4 days\n'
                      '• Deep sleep ratio is at 13% (target: >20%)\n'
                      '• Sleep latency 28min suggests residual hyperarousal\n\n'
                      'Recommendation:\n'
                      '→ No screens after 9:30 PM\n'
                      '→ 4-7-8 breathing at 10:00 PM\n'
                      '→ Room temp to 65-67°F\n'
                      '→ If paged tonight, request backup after resolution',
                      style: TextStyle(
                        color: ObsTheme.textSecondaryOf(context),
                        fontFamily: 'Courier',
                        fontSize: 12,
                        height: 1.5,
                      ),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text('Got it', style: TextStyle(color: ObsTheme.safeOf(context))),
                      ),
                    ],
                  ),
                );
              },
            ),

            const SizedBox(height: 24),

            // Recovery target
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: ObsTheme.surfaceOf(context),
                border: Border.all(color: ObsTheme.borderOf(context)),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  Text(
                    'RECOVERY TARGET',
                    style: TextStyle(
                      fontSize: 10,
                      fontFamily: 'Courier',
                      letterSpacing: 1,
                      color: ObsTheme.textMutedOf(context),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '${delta.compositeScore}',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Courier',
                          color: ObsTheme.critical,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Icon(Icons.arrow_forward, color: ObsTheme.textMutedOf(context), size: 20),
                      ),
                      Text(
                        '< 25',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Courier',
                          color: ObsTheme.safeOf(context),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Est. ${((delta.compositeScore - 25) / 8).ceil()} days to full recovery with active intervention',
                    style: TextStyle(
                      fontSize: 11,
                      color: ObsTheme.textSecondaryOf(context),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

class _RecoveryTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String metric;
  final bool metricBad;
  final VoidCallback onTap;

  const _RecoveryTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.metric,
    required this.metricBad,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: ObsTheme.surfaceOf(context),
          border: Border.all(color: ObsTheme.borderOf(context)),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: ObsTheme.safeOf(context).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: ObsTheme.safeOf(context), size: 24),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: ObsTheme.textPrimaryOf(context),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 11,
                      color: ObsTheme.textSecondaryOf(context),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    metric,
                    style: TextStyle(
                      fontSize: 10,
                      fontFamily: 'Courier',
                      color: metricBad ? ObsTheme.critical : ObsTheme.textMutedOf(context),
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: ObsTheme.textMutedOf(context), size: 20),
          ],
        ),
      ),
    );
  }
}
