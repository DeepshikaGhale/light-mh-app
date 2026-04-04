import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/app_state.dart';
import 'theme/app_theme.dart';
import 'theme/obs_theme.dart';
import 'screens/onboarding/welcome_screen.dart';
import 'screens/home/home_screen.dart';
import 'screens/burnout/burnout_home.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => AppState(),
      child: const LightApp(),
    ),
  );
}

class LightApp extends StatelessWidget {
  const LightApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Light',
      // Use dark observability theme for the burnout/Rootly mode
      theme: ObsTheme.darkTheme,
      debugShowCheckedModeBanner: false,
      home: const _ModeSelector(),
    );
  }
}

/// Mode selector: Engineer Burnout Shield or Wellness Companion
class _ModeSelector extends StatelessWidget {
  const _ModeSelector();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ObsTheme.bg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            children: [
              const Spacer(flex: 2),
              // Logo
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: ObsTheme.safe.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                  border: Border.all(color: ObsTheme.safe.withValues(alpha: 0.3)),
                ),
                child: const Icon(
                  Icons.wb_sunny_rounded,
                  size: 40,
                  color: ObsTheme.safe,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Light',
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: ObsTheme.textPrimary,
                  fontFamily: 'Poppins',
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Human Telemetry for Engineers',
                style: TextStyle(
                  fontSize: 14,
                  color: ObsTheme.textSecondary,
                  letterSpacing: 0.5,
                ),
              ),
              const Spacer(flex: 2),

              // Burnout shield mode (primary)
              _ModeCard(
                icon: Icons.shield_outlined,
                title: 'Burnout Shield',
                subtitle: 'Rootly × DREAMT fusion. Track incidents, sleep, and resilience.',
                accentColor: ObsTheme.safe,
                tags: const ['Rootly API', 'On-Call Health', 'DREAMT'],
                onTap: () => Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (_) => const BurnoutHome()),
                ),
              ),
              const SizedBox(height: 16),

              // Wellness mode (secondary)
              _ModeCard(
                icon: Icons.self_improvement_rounded,
                title: 'Wellness Companion',
                subtitle: 'CBT journal, mood tracking, breathing exercises.',
                accentColor: ObsTheme.info,
                tags: const ['Offline', 'CBT', 'Mood'],
                onTap: () {
                  final state = context.read<AppState>();
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (_) => MaterialApp(
                        theme: AppTheme.lightTheme,
                        debugShowCheckedModeBanner: false,
                        home: state.onboardingComplete
                            ? const HomeScreen()
                            : const WelcomeScreen(),
                      ),
                    ),
                  );
                },
              ),

              const Spacer(),
              Text(
                'All health data stays on-device',
                style: TextStyle(
                  fontSize: 11,
                  color: ObsTheme.textMuted,
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

class _ModeCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color accentColor;
  final List<String> tags;
  final VoidCallback onTap;

  const _ModeCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.accentColor,
    required this.tags,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: ObsTheme.surface,
          border: Border.all(color: accentColor.withValues(alpha: 0.3)),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: accentColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: accentColor, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: ObsTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: ObsTheme.textSecondary,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    children: tags.map((t) => Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: accentColor.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        t,
                        style: TextStyle(
                          fontSize: 9,
                          fontFamily: 'Courier',
                          color: accentColor,
                        ),
                      ),
                    )).toList(),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: ObsTheme.textMuted),
          ],
        ),
      ),
    );
  }
}
