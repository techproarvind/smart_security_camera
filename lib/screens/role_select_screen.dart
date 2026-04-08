import 'package:flutter/material.dart';

class RoleSelectScreen extends StatelessWidget {
  const RoleSelectScreen({super.key});

  static const String _cameraId = 'cam_001';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1117),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(Icons.videocam, color: Color(0xFF00E5A0), size: 64),
              const SizedBox(height: 16),
              const Text('SmartCam',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Color(0xFFE6EDF3), fontSize: 28, fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              const Text('Select this device\'s role',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Color(0xFF8B949E), fontSize: 14)),
              const SizedBox(height: 60),

              // ── Camera Device ────────────────────────────
              _RoleCard(
                icon: Icons.videocam,
                title: 'Camera Device',
                subtitle: 'This phone acts as the security camera\n(old phone)',
                color: const Color(0xFF00E5A0),
                onTap: () {
                  print('>>> ROLE SELECTED: broadcaster');  // ← debug
                  Navigator.pushReplacementNamed(
                    context,
                    '/broadcast',                           // ← goes to CameraBroadcastScreen
                    arguments: _cameraId,
                  );
                },
              ),
              const SizedBox(height: 16),

              // ── Viewer Device ────────────────────────────
              _RoleCard(
                icon: Icons.personal_video,
                title: 'Viewer / Monitor',
                subtitle: 'Watch the live stream from camera\n(your phone)',
                color: const Color(0xFF58A6FF),
                onTap: () {
                  print('>>> ROLE SELECTED: viewer');       // ← debug
                  Navigator.pushReplacementNamed(
                    context,
                    '/live',                                // ← goes to LiveViewScreen
                    arguments: _cameraId,
                  );
                },
              ),

              const SizedBox(height: 32),
              Container(
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                decoration: BoxDecoration(
                  color: const Color(0xFF161B22),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF21262D)),
                ),
                child: Row(mainAxisAlignment: MainAxisAlignment.center, children: const [
                  Icon(Icons.meeting_room_outlined, color: Color(0xFF8B949E), size: 16),
                  SizedBox(width: 8),
                  Text('Room ID: cam_001',
                      style: TextStyle(color: Color(0xFF8B949E), fontSize: 13)),
                ]),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RoleCard extends StatelessWidget {
  final IconData icon;
  final String title, subtitle;
  final Color color;
  final VoidCallback onTap;

  const _RoleCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFF161B22),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.4), width: 1.5),
        ),
        child: Row(
          children: [
            Container(
              width: 56, height: 56,
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                          color: Color(0xFFE6EDF3),
                          fontSize: 16,
                          fontWeight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  Text(subtitle,
                      style: const TextStyle(
                          color: Color(0xFF8B949E), fontSize: 12, height: 1.4)),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, color: color, size: 16),
          ],
        ),
      ),
    );
  }
}
