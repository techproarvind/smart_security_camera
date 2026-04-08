import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_security_camera/model/camera_model.dart';
import 'package:smart_security_camera/provider/camera_provider.dart';
import 'package:smart_security_camera/screens/app_theme.dart';
import 'package:smart_security_camera/sharedWidget/shared_widged.dart';

class CameraDetailScreen extends StatelessWidget {
  const CameraDetailScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final id     = ModalRoute.of(context)!.settings.arguments as String;
    final camP   = context.watch<CameraProvider>();
    final camera = camP.getById(id);
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
            // Live feed placeholder
            GlassCard(
              padding: EdgeInsets.zero,
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      decoration: const BoxDecoration(
                        color: AppTheme.surface2,
                        borderRadius: BorderRadius.all(Radius.circular(16)),
                      ),
                    ),
                    if (camera.status != CameraStatus.offline) ...[
                      const Icon(Icons.videocam, color: AppTheme.primary, size: 52),
                      Positioned(
                        bottom: 12, right: 12,
                        child: ElevatedButton.icon(
                          onPressed: () => Navigator.pushNamed(context, '/live'),
                          icon: const Icon(Icons.play_arrow, size: 16),
                          label: const Text('Watch Live'),
                          style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8)),
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
            GlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Controls', style: TextStyle(color: AppTheme.textPri, fontSize: 15, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 16),
                  _ControlRow(
                    icon: Icons.power_settings_new,
                    label: 'Camera Power',
                    value: camera.status != CameraStatus.offline,
                    onChanged: (_) => camP.toggleCamera(camera.id),
                  ),
                  const Divider(color: AppTheme.surface2, height: 20),
                  _ControlRow(
                    icon: Icons.motion_photos_on_outlined,
                    label: 'Motion Detection',
                    value: camera.motionEnabled,
                    onChanged: (_) => camP.toggleMotion(camera.id),
                  ),
                  const Divider(color: AppTheme.surface2, height: 20),
                  _ControlRow(
                    icon: Icons.fiber_manual_record,
                    label: 'Recording',
                    value: camera.isRecording,
                    onChanged: (_) {},
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            GlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('People Counter', style: TextStyle(color: AppTheme.textPri, fontSize: 15, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        onPressed: () => camP.updatePeopleCount(camera.id, -1),
                        icon: const Icon(Icons.remove_circle_outline, color: AppTheme.danger, size: 32),
                      ),
                      const SizedBox(width: 20),
                      Column(
                        children: [
                          Text('${camera.peopleCount}',
                              style: const TextStyle(color: AppTheme.textPri, fontSize: 48, fontWeight: FontWeight.w700)),
                          const Text('people inside', style: TextStyle(color: AppTheme.textSec, fontSize: 12)),
                        ],
                      ),
                      const SizedBox(width: 20),
                      IconButton(
                        onPressed: () => camP.updatePeopleCount(camera.id, 1),
                        icon: const Icon(Icons.add_circle_outline, color: AppTheme.primary, size: 32),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: () => Navigator.pushNamed(context, '/people_counter'),
              icon: const Icon(Icons.people_alt_outlined, size: 18),
              label: const Text('Full People Counter View'),
            ),
          ],
        ),
      ),
    );
  }
}

class _ControlRow extends StatelessWidget {
  final IconData icon; final String label; final bool value; final ValueChanged<bool> onChanged;
  const _ControlRow({required this.icon, required this.label, required this.value, required this.onChanged});
  @override
  Widget build(BuildContext context) => Row(
    children: [
      Icon(icon, color: value ? AppTheme.primary : AppTheme.textSec, size: 20),
      const SizedBox(width: 12),
      Expanded(child: Text(label, style: const TextStyle(color: AppTheme.textPri))),
      Switch(
        value: value,
        onChanged: onChanged,
        activeColor: AppTheme.primary,
        inactiveThumbColor: AppTheme.textSec,
        inactiveTrackColor: AppTheme.surface2,
      ),
    ],
  );
}
