import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smart_security_camera/controllers/camera_controller.dart';
import 'package:smart_security_camera/model/camera_model.dart';
import 'package:smart_security_camera/screens/app_theme.dart';
import 'package:smart_security_camera/screens/status_dots.dart';
import 'package:smart_security_camera/sharedWidget/shared_widged.dart';

class CameraCard extends StatelessWidget {
  final CameraModel camera;
  const CameraCard({super.key, required this.camera});

  @override
  Widget build(BuildContext context) {
    final ctrl = CameraController.to;
    return GestureDetector(
      onTap: () => Get.toNamed('/camera_detail', arguments: camera.id),
      child: GlassCard(
        borderColor: camera.status == CameraStatus.recording ? AppTheme.danger.withOpacity(0.5) : null,
        padding: EdgeInsets.zero,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(children: [
              Container(
                height: 110, width: double.infinity,
                decoration: const BoxDecoration(
                  color: AppTheme.surface2,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                ),
                child: camera.status == CameraStatus.offline
                    ? const Center(child: Icon(Icons.videocam_off, color: AppTheme.textSec, size: 36))
                    : Center(child: Icon(Icons.videocam, color: AppTheme.primary.withOpacity(0.4), size: 40)),
              ),
              if (camera.status == CameraStatus.recording)
                Positioned(top: 8, right: 36,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(color: AppTheme.danger, borderRadius: BorderRadius.circular(6)),
                    child: const Text('● REC', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w700)),
                  )),
              if (camera.peopleCount > 0)
                Positioned(top: 8, left: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(color: AppTheme.info.withOpacity(0.85), borderRadius: BorderRadius.circular(6)),
                    child: Text('${camera.peopleCount} 👤', style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w700)),
                  )),
              // 3-dot menu
              Positioned(top: 2, right: 2,
                child: PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert, color: AppTheme.textSec, size: 18),
                  color: AppTheme.surface,
                  itemBuilder: (_) => [
                    const PopupMenuItem(value: 'detail', child: Row(children: [Icon(Icons.info_outline, size: 16, color: AppTheme.textSec), SizedBox(width: 8), Text('Details', style: TextStyle(color: AppTheme.textPri, fontSize: 13))])),
                    const PopupMenuItem(value: 'delete', child: Row(children: [Icon(Icons.delete_outline, size: 16, color: AppTheme.danger),  SizedBox(width: 8), Text('Remove',  style: TextStyle(color: AppTheme.danger,  fontSize: 13))])),
                  ],
                  onSelected: (val) {
                    if (val == 'detail') Get.toNamed('/camera_detail', arguments: camera.id);
                    if (val == 'delete') _confirmDelete(ctrl);
                  },
                )),
            ]),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  Expanded(child: Text(camera.name, overflow: TextOverflow.ellipsis, maxLines: 1,
                      style: const TextStyle(color: AppTheme.textPri, fontSize: 13, fontWeight: FontWeight.w600))),
                  const SizedBox(width: 6),
                  StatusDot(camera.status),
                ]),
                const SizedBox(height: 3),
                Text(camera.location, overflow: TextOverflow.ellipsis, maxLines: 1,
                    style: const TextStyle(color: AppTheme.textSec, fontSize: 11)),
                const SizedBox(height: 8),
                Row(children: [
                  _ActionChip(icon: Icons.motion_photos_on, label: camera.motionEnabled ? 'Motion' : 'Off',
                      active: camera.motionEnabled, onTap: () => ctrl.toggleMotion(camera.id)),
                  const SizedBox(width: 6),
                  _ActionChip(
                      icon: camera.status == CameraStatus.offline ? Icons.power_off : Icons.power,
                      label: camera.status == CameraStatus.offline ? 'Off' : 'On',
                      active: camera.status != CameraStatus.offline,
                      onTap: () => ctrl.toggleCamera(camera.id)),
                ]),
              ]),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(CameraController ctrl) {
    Get.defaultDialog(
      backgroundColor: AppTheme.surface,
      title: 'Remove Camera',
      titleStyle: const TextStyle(color: AppTheme.textPri, fontSize: 16),
      content: Text('Remove "${camera.name}"?\nThis cannot be undone.',
          textAlign: TextAlign.center, style: const TextStyle(color: AppTheme.textSec, fontSize: 14)),
      textCancel: 'Cancel',
      textConfirm: 'Remove',
      cancelTextColor: AppTheme.textSec,
      confirmTextColor: AppTheme.danger,
      buttonColor: AppTheme.surface,
      onConfirm: () { Get.back(); ctrl.removeCamera(camera.id); },
    );
  }
}

class _ActionChip extends StatelessWidget {
  final IconData icon; final String label; final bool active; final VoidCallback onTap;
  const _ActionChip({required this.icon, required this.label, required this.active, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: active ? AppTheme.primary.withOpacity(0.15) : AppTheme.surface2,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: active ? AppTheme.primary.withOpacity(0.4) : AppTheme.surface2),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 11, color: active ? AppTheme.primary : AppTheme.textSec),
        const SizedBox(width: 3),
        Flexible(child: Text(label, overflow: TextOverflow.ellipsis, maxLines: 1,
            style: TextStyle(fontSize: 10, color: active ? AppTheme.primary : AppTheme.textSec, fontWeight: FontWeight.w500))),
      ]),
    ),
  );
}
