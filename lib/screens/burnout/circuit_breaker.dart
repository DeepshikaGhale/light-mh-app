import 'package:flutter/material.dart';
import '../../theme/obs_theme.dart';
import '../../services/mock_rootly_service.dart';

class CircuitBreaker extends StatefulWidget {
  const CircuitBreaker({super.key});

  @override
  State<CircuitBreaker> createState() => _CircuitBreakerState();
}

class _CircuitBreakerState extends State<CircuitBreaker> {
  bool _generatingHandoff = false;
  String? _handoffSummary;
  bool _overrideRequested = false;
  bool _alertsSilenced = false;
  bool _escalated = false;

  @override
  Widget build(BuildContext context) {
    final delta = MockWellnessService.computeResilienceDelta();

    return Scaffold(
      backgroundColor: ObsTheme.bg,
      appBar: AppBar(
        title: const Text('Circuit Breaker'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Warning banner
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: ObsTheme.critical.withValues(alpha: 0.08),
                border: Border.all(color: ObsTheme.critical.withValues(alpha: 0.3)),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.shield_outlined, color: ObsTheme.critical, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'PROTECTIVE ACTIONS',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Courier',
                          letterSpacing: 1,
                          color: ObsTheme.critical,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Your resilience delta is ${delta.delta}. These actions help you '
                    'step away safely without dropping the ball.',
                    style: TextStyle(
                      fontSize: 13,
                      color: ObsTheme.textSecondary,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Action 1: Generate Handoff
            _ActionCard(
              icon: Icons.description_outlined,
              title: 'Generate Smart Handoff',
              description: 'AI summarizes your open incidents into a Slack-ready handoff message. Makes it safe to step away.',
              buttonLabel: _handoffSummary != null ? 'GENERATED' : 'GENERATE HANDOFF',
              loading: _generatingHandoff,
              completed: _handoffSummary != null,
              apiLabel: 'Rootly MCP: get_oncall_handoff_summary',
              onTap: _handoffSummary != null ? null : () async {
                setState(() => _generatingHandoff = true);
                await Future.delayed(const Duration(seconds: 2));
                if (!mounted) return;
                setState(() {
                  _generatingHandoff = false;
                  _handoffSummary = MockRootlyService.generateHandoffSummary();
                });
              },
            ),

            // Show generated handoff
            if (_handoffSummary != null) ...[
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: ObsTheme.surface,
                  border: Border.all(color: ObsTheme.safe.withValues(alpha: 0.3)),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.check_circle, color: ObsTheme.safe, size: 16),
                        const SizedBox(width: 8),
                        Text(
                          'HANDOFF READY',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Courier',
                            letterSpacing: 1,
                            color: ObsTheme.safe,
                          ),
                        ),
                        const Spacer(),
                        GestureDetector(
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: const Text('Copied to clipboard'),
                                backgroundColor: ObsTheme.surface,
                              ),
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              border: Border.all(color: ObsTheme.border),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              'COPY',
                              style: TextStyle(
                                fontSize: 10,
                                fontFamily: 'Courier',
                                color: ObsTheme.info,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _handoffSummary!,
                      style: TextStyle(
                        fontSize: 12,
                        fontFamily: 'Courier',
                        color: ObsTheme.textSecondary,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 16),

            // Action 2: Request Override
            _ActionCard(
              icon: Icons.swap_horiz_rounded,
              title: 'Request Shift Override',
              description: 'Find available backup and create an override shift. Your biological data supports the request.',
              buttonLabel: _overrideRequested ? 'OVERRIDE REQUESTED' : 'REQUEST OVERRIDE',
              completed: _overrideRequested,
              apiLabel: 'Rootly API: POST /v1/override_shifts',
              onTap: _overrideRequested ? null : () async {
                setState(() => _overrideRequested = true);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Row(
                      children: [
                        Icon(Icons.check, color: ObsTheme.safe, size: 16),
                        const SizedBox(width: 8),
                        const Text('Override requested. Sarah K. notified.'),
                      ],
                    ),
                    backgroundColor: ObsTheme.surface,
                  ),
                );
              },
            ),
            const SizedBox(height: 16),

            // Action 3: Silence Non-Critical
            _ActionCard(
              icon: Icons.notifications_off_outlined,
              title: 'Silence Non-Critical Alerts',
              description: 'Mute sev3 and sev4 alerts for 4 hours. Only critical pages will come through.',
              buttonLabel: _alertsSilenced ? 'ALERTS SILENCED (4h)' : 'SILENCE ALERTS',
              completed: _alertsSilenced,
              apiLabel: 'Rootly MCP: update incident alerts',
              onTap: _alertsSilenced ? null : () {
                setState(() => _alertsSilenced = true);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Row(
                      children: [
                        Icon(Icons.notifications_off, color: ObsTheme.warning, size: 16),
                        const SizedBox(width: 8),
                        const Text('Non-critical alerts silenced for 4 hours.'),
                      ],
                    ),
                    backgroundColor: ObsTheme.surface,
                  ),
                );
              },
            ),
            const SizedBox(height: 16),

            // Action 4: Escalate
            _ActionCard(
              icon: Icons.escalator_warning_rounded,
              title: 'Escalate to Backup',
              description: 'Trigger escalation policy. Backup engineer takes primary. You move to secondary.',
              buttonLabel: _escalated ? 'ESCALATED' : 'ESCALATE NOW',
              completed: _escalated,
              color: ObsTheme.critical,
              apiLabel: 'Rootly API: POST /v1/escalation_policies',
              onTap: _escalated ? null : () {
                showDialog(
                  context: context,
                  builder: (_) => AlertDialog(
                    backgroundColor: ObsTheme.surface,
                    title: Text('Confirm Escalation',
                      style: TextStyle(color: ObsTheme.textPrimary)),
                    content: Text(
                      'This will page Marcus T. as your backup and move you to secondary. Proceed?',
                      style: TextStyle(color: ObsTheme.textSecondary),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text('Cancel', style: TextStyle(color: ObsTheme.textMuted)),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                          setState(() => _escalated = true);
                        },
                        child: Text('Escalate', style: TextStyle(color: ObsTheme.critical)),
                      ),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 32),

            // Privacy note
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: ObsTheme.surface,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.lock_outline, size: 14, color: ObsTheme.textMuted),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Only your availability status is shared. Raw health data stays on-device.',
                      style: TextStyle(
                        fontSize: 11,
                        color: ObsTheme.textMuted,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final String buttonLabel;
  final String apiLabel;
  final bool loading;
  final bool completed;
  final Color? color;
  final VoidCallback? onTap;

  const _ActionCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.buttonLabel,
    required this.apiLabel,
    this.loading = false,
    this.completed = false,
    this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final c = color ?? ObsTheme.info;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ObsTheme.surface,
        border: Border.all(
          color: completed ? ObsTheme.safe.withValues(alpha: 0.3) : ObsTheme.border,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: completed ? ObsTheme.safe : c, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: ObsTheme.textPrimary,
                  ),
                ),
              ),
              if (completed)
                Icon(Icons.check_circle, color: ObsTheme.safe, size: 18),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: TextStyle(
              fontSize: 12,
              color: ObsTheme.textSecondary,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            apiLabel,
            style: TextStyle(
              fontSize: 9,
              fontFamily: 'Courier',
              color: ObsTheme.textMuted,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: GestureDetector(
              onTap: onTap,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: completed
                      ? ObsTheme.safe.withValues(alpha: 0.1)
                      : c.withValues(alpha: 0.1),
                  border: Border.all(
                    color: completed
                        ? ObsTheme.safe.withValues(alpha: 0.3)
                        : c.withValues(alpha: 0.3),
                  ),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Center(
                  child: loading
                      ? SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation(c),
                          ),
                        )
                      : Text(
                          buttonLabel,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Courier',
                            letterSpacing: 1,
                            color: completed ? ObsTheme.safe : c,
                          ),
                        ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
