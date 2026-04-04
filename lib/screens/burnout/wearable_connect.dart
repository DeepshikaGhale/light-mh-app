import 'package:flutter/material.dart';
import '../../theme/obs_theme.dart';

class WearableConnect extends StatefulWidget {
  const WearableConnect({super.key});

  @override
  State<WearableConnect> createState() => _WearableConnectState();
}

class _WearableConnectState extends State<WearableConnect> {
  String? _connectingDevice;
  String? _connectedDevice;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ObsTheme.bgOf(context),
      appBar: AppBar(
        title: Text(
          'Connect Wearable',
          style: TextStyle(fontFamily: ObsTheme.titleFont),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status banner
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _connectedDevice != null
                    ? ObsTheme.highlightPositive.withValues(alpha: 0.08)
                    : ObsTheme.surfaceLightOf(context),
                border: Border.all(
                  color: _connectedDevice != null
                      ? ObsTheme.highlightPositive.withValues(alpha: 0.3)
                      : ObsTheme.borderOf(context),
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(
                    _connectedDevice != null ? Icons.bluetooth_connected : Icons.bluetooth_searching,
                    color: _connectedDevice != null ? ObsTheme.highlightPositive : ObsTheme.textMutedOf(context),
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _connectedDevice != null ? 'CONNECTED' : 'NO DEVICE CONNECTED',
                          style: TextStyle(
                            fontFamily: 'Courier',
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1,
                            color: _connectedDevice != null
                                ? ObsTheme.highlightPositive
                                : ObsTheme.textMutedOf(context),
                          ),
                        ),
                        if (_connectedDevice != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            _connectedDevice!,
                            style: TextStyle(
                              fontSize: 14,
                              fontFamily: ObsTheme.bodyFont,
                              color: ObsTheme.textPrimaryOf(context),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            Text(
              'SUPPORTED DEVICES',
              style: TextStyle(
                fontFamily: 'Courier',
                fontSize: 11,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.5,
                color: ObsTheme.textMutedOf(context),
              ),
            ),
            const SizedBox(height: 12),

            // Apple Watch
            _DeviceCard(
              name: 'Apple Watch',
              subtitle: 'Series 4 or later',
              icon: Icons.watch,
              signals: ['Heart Rate', 'HRV (RMSSD)', 'Sleep Stages', 'Blood Oxygen'],
              connected: _connectedDevice == 'Apple Watch',
              connecting: _connectingDevice == 'Apple Watch',
              onConnect: () => _simulateConnect('Apple Watch'),
            ),
            const SizedBox(height: 12),

            // Fitbit
            _DeviceCard(
              name: 'Fitbit',
              subtitle: 'Sense, Versa 3+, Charge 5+',
              icon: Icons.watch_outlined,
              signals: ['Heart Rate', 'HRV', 'Sleep Score', 'Skin Temperature'],
              connected: _connectedDevice == 'Fitbit',
              connecting: _connectingDevice == 'Fitbit',
              onConnect: () => _simulateConnect('Fitbit'),
            ),
            const SizedBox(height: 12),

            // Garmin
            _DeviceCard(
              name: 'Garmin',
              subtitle: 'Venu, Forerunner, Fenix',
              icon: Icons.watch_later_outlined,
              signals: ['Heart Rate', 'HRV', 'Body Battery', 'Sleep'],
              connected: _connectedDevice == 'Garmin',
              connecting: _connectingDevice == 'Garmin',
              onConnect: () => _simulateConnect('Garmin'),
            ),
            const SizedBox(height: 12),

            // Samsung Galaxy Watch
            _DeviceCard(
              name: 'Samsung Galaxy Watch',
              subtitle: 'Watch 4 or later',
              icon: Icons.watch_rounded,
              signals: ['Heart Rate', 'HRV', 'Sleep Tracking', 'Blood Oxygen'],
              connected: _connectedDevice == 'Samsung Galaxy Watch',
              connecting: _connectingDevice == 'Samsung Galaxy Watch',
              onConnect: () => _simulateConnect('Samsung Galaxy Watch'),
            ),
            const SizedBox(height: 24),

            // Data info
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: ObsTheme.surfaceOf(context),
                border: Border.all(color: ObsTheme.borderOf(context)),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'WHAT WE COLLECT',
                    style: TextStyle(
                      fontFamily: 'Courier',
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                      color: ObsTheme.textMutedOf(context),
                    ),
                  ),
                  const SizedBox(height: 10),
                  _DataRow(icon: Icons.bedtime_outlined, label: 'Sleep duration & efficiency', color: ObsTheme.info),
                  _DataRow(icon: Icons.favorite_outline, label: 'Heart rate variability (RMSSD)', color: ObsTheme.highlightUrgent),
                  _DataRow(icon: Icons.nights_stay_outlined, label: 'Deep sleep & REM ratios', color: ObsTheme.highlightInfo),
                  _DataRow(icon: Icons.alarm_outlined, label: 'Sleep latency & fragmentation', color: ObsTheme.warning),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Privacy note
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: ObsTheme.highlightPositive.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.lock_outline, size: 16, color: ObsTheme.highlightPositive),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'All health data stays on your device. We only compute aggregate recovery scores.',
                      style: TextStyle(
                        fontSize: 12,
                        fontFamily: ObsTheme.bodyFont,
                        color: ObsTheme.textSecondaryOf(context),
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

  Future<void> _simulateConnect(String device) async {
    setState(() {
      _connectingDevice = device;
      _connectedDevice = null;
    });
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;
    setState(() {
      _connectingDevice = null;
      _connectedDevice = device;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Color(0xFF2ECC71), size: 16),
            const SizedBox(width: 8),
            Text('$device connected. Syncing health data...'),
          ],
        ),
        backgroundColor: ObsTheme.surfaceOf(context),
      ),
    );
  }
}

class _DeviceCard extends StatelessWidget {
  final String name;
  final String subtitle;
  final IconData icon;
  final List<String> signals;
  final bool connected;
  final bool connecting;
  final VoidCallback onConnect;

  const _DeviceCard({
    required this.name,
    required this.subtitle,
    required this.icon,
    required this.signals,
    required this.connected,
    required this.connecting,
    required this.onConnect,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ObsTheme.surfaceOf(context),
        border: Border.all(
          color: connected
              ? ObsTheme.highlightPositive.withValues(alpha: 0.4)
              : ObsTheme.borderOf(context),
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: connected
                      ? ObsTheme.highlightPositive.withValues(alpha: 0.1)
                      : ObsTheme.surfaceLightOf(context),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  icon,
                  color: connected ? ObsTheme.highlightPositive : ObsTheme.textSecondaryOf(context),
                  size: 24,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        fontFamily: ObsTheme.bodyFont,
                        color: ObsTheme.textPrimaryOf(context),
                      ),
                    ),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 12,
                        fontFamily: ObsTheme.bodyFont,
                        color: ObsTheme.textMutedOf(context),
                      ),
                    ),
                  ],
                ),
              ),
              if (connected)
                Icon(Icons.check_circle, color: ObsTheme.highlightPositive, size: 22),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: signals.map((s) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: ObsTheme.surfaceLightOf(context),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                s,
                style: TextStyle(
                  fontSize: 10,
                  fontFamily: 'Courier',
                  color: ObsTheme.textSecondaryOf(context),
                ),
              ),
            )).toList(),
          ),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: connected ? null : onConnect,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: connected
                    ? ObsTheme.highlightPositive.withValues(alpha: 0.1)
                    : ObsTheme.safeOf(context).withValues(alpha: 0.1),
                border: Border.all(
                  color: connected
                      ? ObsTheme.highlightPositive.withValues(alpha: 0.3)
                      : ObsTheme.safeOf(context).withValues(alpha: 0.3),
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: connecting
                    ? SizedBox(
                        width: 16, height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation(ObsTheme.safeOf(context)),
                        ),
                      )
                    : Text(
                        connected ? 'CONNECTED' : 'CONNECT',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Courier',
                          letterSpacing: 1,
                          color: connected ? ObsTheme.highlightPositive : ObsTheme.safeOf(context),
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

class _DataRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  const _DataRow({required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 10),
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontFamily: ObsTheme.bodyFont,
              color: ObsTheme.textSecondaryOf(context),
            ),
          ),
        ],
      ),
    );
  }
}
