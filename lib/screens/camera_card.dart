import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_security_camera/model/camera_model.dart';
import 'package:smart_security_camera/provider/camera_provider.dart';
import 'package:smart_security_camera/screens/app_theme.dart';
import 'package:smart_security_camera/screens/status_dots.dart';
import 'package:smart_security_camera/sharedWidget/shared_widged.dart';

class CameraCard extends StatelessWidget {
  final CameraModel camera;
  const CameraCard({super.key, required this.camera});

  @override
  Widget build(BuildContext context) {
    final provider = context.read<CameraProvider>();
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, '/camera_detail', arguments: camera.id),
      child: GlassCard(
        borderColor: camera.status == CameraStatus.recording
            ? AppTheme.danger.withOpacity(0.5)
            : null,
        padding: EdgeInsets.zero,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Thumbnail placeholder
            Stack(
              children: [
                Container(
                  height: 120,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: AppTheme.surface2,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                  ),
                  child: camera.status == CameraStatus.offline
                      ? const Center(child: Icon(Icons.videocam_off, color: AppTheme.textSec, size: 40))
                      : Center(
                          child: Icon(Icons.videocam, color: AppTheme.primary.withOpacity(0.4), size: 44),
                        ),
                ),
                if (camera.status == CameraStatus.recording)
                  Positioned(
                    top: 8, right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppTheme.danger,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text('● REC', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700)),
                    ),
                  ),
                if (camera.peopleCount > 0)
                  Positioned(
                    top: 8, left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppTheme.info.withOpacity(0.85),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        '${camera.peopleCount} 👤',
                        style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          camera.name,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                          style: const TextStyle(color: AppTheme.textPri, fontSize: 14, fontWeight: FontWeight.w600),
                        ),
                      ),
                      const SizedBox(width: 8),
                      StatusDot(camera.status),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(camera.location, style: const TextStyle(color: AppTheme.textSec, fontSize: 12)),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      _ActionChip(
                        icon: Icons.motion_photos_on,
                        label: camera.motionEnabled ? 'Motion ON' : 'Motion OFF',
                        active: camera.motionEnabled,
                        onTap: () => provider.toggleMotion(camera.id),
                      ),
                      const SizedBox(width: 8),
                      _ActionChip(
                        icon: camera.status == CameraStatus.offline ? Icons.power_off : Icons.power,
                        label: camera.status == CameraStatus.offline ? 'Off' : 'On',
                        active: camera.status != CameraStatus.offline,
                        onTap: () => provider.toggleCamera(camera.id),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback onTap;
  const _ActionChip({required this.icon, required this.label, required this.active, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: active ? AppTheme.primary.withOpacity(0.15) : AppTheme.surface2,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: active ? AppTheme.primary.withOpacity(0.4) : AppTheme.surface2),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: active ? AppTheme.primary : AppTheme.textSec),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              label,
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
              style: TextStyle(fontSize: 11, color: active ? AppTheme.primary : AppTheme.textSec, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    ),
  );
}