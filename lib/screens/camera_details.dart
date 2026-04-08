import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smart_security_camera/controllers/camera_controller.dart';
import 'package:smart_security_camera/model/camera_model.dart';
import 'package:smart_security_camera/screens/app_theme.dart';
import 'package:smart_security_camera/sharedWidget/shared_widged.dart';

class CameraDetailScreen extends StatelessWidget {
  const CameraDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final id   = Get.arguments as String;
    final ctrl = CameraController.to;

    return Obx(() {
      final camera = ctrl.getById(id);
      if (camera == null) {
        return Scaffold(
          appBar: AppBar(title: const Text('Camera')),
          body: const Center(child: Text('Camera not found', style: TextStyle(color: AppTheme.textSec))),
        );
      }

      return Scaffold(
        appBar: AppBar(title: Text(camera.name)),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Live feed ───────────────────────────────
              GlassCard(
                padding: EdgeInsets.zero,
                child: AspectRatio(
                  aspectRatio: 16 / 9,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(decoration: const BoxDecoration(
                        color: AppTheme.surface2,
                        borderRadius: BorderRadius.all(Radius.circular(16)),
                      )),
                      if (camera.status != CameraStatus.offline) ...[
                        Icon(
                          camera.status == CameraStatus.motion
                              ? Icons.motion_photos_on
                              : Icons.videocam,
                          color: camera.status == CameraStatus.motion
                              ? const Color(0xFFFFB300)
                              : AppTheme.primary,
                          size: 52,
                        ),
                        Positioned(
                          bottom: 12, right: 12,
                          child: ElevatedButton.icon(
                            onPressed: () => Get.toNamed('/live', arguments: id),
                            icon: const Icon(Icons.play_arrow, size: 16),
                            label: const Text('Watch Live'),
                            style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8)),
                          ),
                        ),
                        if (camera.status == CameraStatus.motion)
                          Positioned(
                            top: 10, left: 12,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFB300),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Text('⚡ MOTION DETECTED',
                                  style: TextStyle(color: Colors.black, fontSize: 11, fontWeight: FontWeight.w700)),
                            ),
                          ),
                      ] else
                        Column(mainAxisSize: MainAxisSize.min, children: const [
                          Icon(Icons.videocam_off, color: AppTheme.textSec, size: 44),
                          SizedBox(height: 8),
                          Text('Camera offline', style: TextStyle(color: AppTheme.textSec)),
                        ]),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // ── Controls ─────────────────────────────────
              GlassCard(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Text('Controls', style: TextStyle(color: AppTheme.textPri, fontSize: 15, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 16),
                  _ControlRow(
                    icon: Icons.power_settings_new, label: 'Camera Power',
                    value: camera.status != CameraStatus.offline,
                    onChanged: (_) => ctrl.toggleCamera(id),
                  ),
                  const Divider(color: AppTheme.surface2, height: 20),
                  _ControlRow(
                    icon: Icons.motion_photos_on_outlined, label: 'Motion Detection',
                    value: camera.motionEnabled,
                    onChanged: (_) => ctrl.toggleMotion(id),
                  ),
                  const Divider(color: AppTheme.surface2, height: 20),
                  _ControlRow(
                    icon: Icons.fiber_manual_record, label: 'Recording',
                    value: camera.isRecording,
                    onChanged: (_) {},
                  ),
                ]),
              ),
              const SizedBox(height: 12),

              // ── Motion Sensing Settings ───────────────────
              GlassCard(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [
                    const Icon(Icons.sensors, color: AppTheme.primary, size: 18),
                    const SizedBox(width: 8),
                    const Text('Motion Sensing', style: TextStyle(color: AppTheme.textPri, fontSize: 15, fontWeight: FontWeight.w600)),
                    const Spacer(),
                    if (camera.status == CameraStatus.motion)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFB300).withOpacity(0.15),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: const Color(0xFFFFB300).withOpacity(0.5)),
                        ),
                        child: const Text('Active', style: TextStyle(color: Color(0xFFFFB300), fontSize: 11, fontWeight: FontWeight.w600)),
                      ),
                  ]),
                  const SizedBox(height: 16),

                  // Sensitivity selector
                  const Text('Sensitivity', style: TextStyle(color: AppTheme.textSec, fontSize: 12)),
                  const SizedBox(height: 8),
                  Row(children: MotionSensitivity.values.map((s) {
                    final selected = camera.motionSensitivity == s;
                    return Expanded(child: Padding(
                      padding: const EdgeInsets.only(right: 6),
                      child: GestureDetector(
                        onTap: () => ctrl.setMotionSensitivity(id, s),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          decoration: BoxDecoration(
                            color: selected ? AppTheme.primary.withOpacity(0.15) : AppTheme.surface2,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: selected ? AppTheme.primary.withOpacity(0.5) : Colors.transparent,
                            ),
                          ),
                          child: Text(
                            s.name[0].toUpperCase() + s.name.substring(1),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: selected ? AppTheme.primary : AppTheme.textSec,
                              fontSize: 12,
                              fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
                            ),
                          ),
                        ),
                      ),
                    ));
                  }).toList()),
                  const SizedBox(height: 6),
                  Text(
                    _sensitivityHint(camera.motionSensitivity),
                    style: const TextStyle(color: AppTheme.textSec, fontSize: 11),
                  ),
                  const SizedBox(height: 16),
                  const Divider(color: AppTheme.surface2, height: 1),
                  const SizedBox(height: 14),

                  // Stats
                  Row(children: [
                    Expanded(child: _StatBox(
                      label: 'Events Today',
                      value: '${camera.motionEventsToday}',
                      icon: Icons.bolt,
                      color: const Color(0xFFFFB300),
                    )),
                    const SizedBox(width: 10),
                    Expanded(child: _StatBox(
                      label: 'Last Motion',
                      value: camera.lastMotionAt != null
                          ? _formatTime(camera.lastMotionAt!)
                          : 'Never',
                      icon: Icons.access_time,
                      color: AppTheme.primary,
                    )),
                  ]),
                  const SizedBox(height: 16),

                  // Test button
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: camera.motionEnabled && camera.status != CameraStatus.offline
                          ? () => ctrl.triggerMotion(id)
                          : null,
                      icon: const Icon(Icons.sensors, size: 16),
                      label: const Text('Test Motion Detection'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFFFFB300),
                        side: const BorderSide(color: Color(0xFFFFB300), width: 1),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                      ),
                    ),
                  ),
                ]),
              ),
              const SizedBox(height: 12),

              // ── People Counter ────────────────────────────
              GlassCard(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Text('People Counter', style: TextStyle(color: AppTheme.textPri, fontSize: 15, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 16),
                  Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    IconButton(
                      onPressed: () => ctrl.updatePeopleCount(id, -1),
                      icon: const Icon(Icons.remove_circle_outline, color: AppTheme.danger, size: 32),
                    ),
                    const SizedBox(width: 20),
                    Column(children: [
                      Text('${camera.peopleCount}',
                          style: const TextStyle(color: AppTheme.textPri, fontSize: 48, fontWeight: FontWeight.w700)),
                      const Text('people inside', style: TextStyle(color: AppTheme.textSec, fontSize: 12)),
                    ]),
                    const SizedBox(width: 20),
                    IconButton(
                      onPressed: () => ctrl.updatePeopleCount(id, 1),
                      icon: const Icon(Icons.add_circle_outline, color: AppTheme.primary, size: 32),
                    ),
                  ]),
                ]),
              ),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                onPressed: () => Get.toNamed('/people_counter'),
                icon: const Icon(Icons.people_alt_outlined, size: 18),
                label: const Text('Full People Counter View'),
              ),
            ],
          ),
        ),
      );
    });
  }

  String _sensitivityHint(MotionSensitivity s) {
    switch (s) {
      case MotionSensitivity.low:    return 'Clears after 5 s — fewer false alerts';
      case MotionSensitivity.medium: return 'Clears after 10 s — balanced detection';
      case MotionSensitivity.high:   return 'Clears after 20 s — catches subtle movements';
    }
  }

  String _formatTime(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inSeconds < 60)  return '${diff.inSeconds}s ago';
    if (diff.inMinutes < 60)  return '${diff.inMinutes}m ago';
    if (diff.inHours < 24)    return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }
}

class _ControlRow extends StatelessWidget {
  final IconData icon; final String label; final bool value; final ValueChanged<bool> onChanged;
  const _ControlRow({required this.icon, required this.label, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) => Row(children: [
    Icon(icon, color: value ? AppTheme.primary : AppTheme.textSec, size: 20),
    const SizedBox(width: 12),
    Expanded(child: Text(label, style: const TextStyle(color: AppTheme.textPri))),
    Switch(value: value, onChanged: onChanged, activeColor: AppTheme.primary,
        inactiveThumbColor: AppTheme.textSec, inactiveTrackColor: AppTheme.surface2),
  ]);
}

class _StatBox extends StatelessWidget {
  final String label; final String value; final IconData icon; final Color color;
  const _StatBox({required this.label, required this.value, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
    decoration: BoxDecoration(
      color: color.withOpacity(0.08),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: color.withOpacity(0.25)),
    ),
    child: Row(children: [
      Icon(icon, color: color, size: 18),
      const SizedBox(width: 8),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(value, overflow: TextOverflow.ellipsis,
            style: TextStyle(color: color, fontSize: 15, fontWeight: FontWeight.w700)),
        Text(label, style: const TextStyle(color: AppTheme.textSec, fontSize: 10)),
      ])),
    ]),
  );
}
