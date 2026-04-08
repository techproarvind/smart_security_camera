import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smart_security_camera/controllers/auth_controller.dart';
import 'package:smart_security_camera/screens/app_theme.dart';

class RoleSelectScreen extends StatelessWidget {
  const RoleSelectScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                width: 72, height: 72,
                margin: const EdgeInsets.only(bottom: 16),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppTheme.primary.withOpacity(0.12),
                  shape: BoxShape.circle,
                  border: Border.all(color: AppTheme.primary.withOpacity(0.4), width: 2),
                ),
                child: const Icon(Icons.videocam, color: AppTheme.primary, size: 36),
              ),
              const Text('SmartCam', textAlign: TextAlign.center,
                  style: TextStyle(color: AppTheme.textPri, fontSize: 28, fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              const Text("Select this device's role", textAlign: TextAlign.center,
                  style: TextStyle(color: AppTheme.textSec, fontSize: 14)),
              const SizedBox(height: 52),

              _RoleCard(
                icon: Icons.videocam,
                title: 'Camera Device',
                subtitle: 'This phone acts as the security camera',
                color: AppTheme.primary,
                onTap: () async {
                  await AuthController.to.setRole(UserRole.camera);
                  Get.offAllNamed('/dashboard');
                },
              ),
              const SizedBox(height: 16),

              _RoleCard(
                icon: Icons.personal_video,
                title: 'Viewer / Monitor',
                subtitle: 'Watch the live stream from camera',
                color: AppTheme.info,
                onTap: () async {
                  await AuthController.to.setRole(UserRole.viewer);
                  Get.offAllNamed('/dashboard');
                },
              ),

              const SizedBox(height: 32),
              Container(
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                decoration: BoxDecoration(
                  color: AppTheme.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.surface2),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.meeting_room_outlined, color: AppTheme.textSec, size: 16),
                    SizedBox(width: 8),
                    Text('Room ID: cam_001', style: TextStyle(color: AppTheme.textSec, fontSize: 13)),
                  ],
                ),
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

  const _RoleCard({required this.icon, required this.title, required this.subtitle, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.4), width: 1.5),
      ),
      child: Row(
        children: [
          Container(
            width: 56, height: 56,
            decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(14)),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: AppTheme.textPri, fontSize: 16, fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                Text(subtitle, style: const TextStyle(color: AppTheme.textSec, fontSize: 12, height: 1.4)),
              ],
            ),
          ),
          Icon(Icons.arrow_forward_ios, color: color, size: 16),
        ],
      ),
    ),
  );
}
