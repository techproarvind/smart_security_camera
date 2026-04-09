import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smart_security_camera/controllers/recording_controller.dart';
import 'package:smart_security_camera/model/recording_model.dart';
import 'package:smart_security_camera/screens/app_theme.dart';
import 'package:smart_security_camera/sharedWidget/shared_widged.dart';

class RecordingsScreen extends StatelessWidget {
  const RecordingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = RecordingController.to;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Recordings'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_outlined),
            tooltip: 'Refresh',
            onPressed: ctrl.loadRecordings,
          ),
        ],
      ),
      body: Obx(() {
        if (ctrl.isUploading) {
          return const Center(
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              CircularProgressIndicator(color: AppTheme.primary),
              SizedBox(height: 16),
              Text('Uploading recording…', style: TextStyle(color: AppTheme.textSec)),
            ]),
          );
        }

        if (ctrl.recordings.isEmpty) {
          return Center(
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              const Icon(Icons.videocam_off_outlined, color: AppTheme.textSec, size: 52),
              const SizedBox(height: 12),
              const Text('No recordings yet', style: TextStyle(color: AppTheme.textSec, fontSize: 15)),
              const SizedBox(height: 6),
              const Text('Start broadcasting and hit Record to save a clip.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppTheme.textSec, fontSize: 12)),
              const SizedBox(height: 20),
              TextButton.icon(
                onPressed: ctrl.loadRecordings,
                icon: const Icon(Icons.refresh, color: AppTheme.primary),
                label: const Text('Load from cloud', style: TextStyle(color: AppTheme.primary)),
              ),
            ]),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: ctrl.recordings.length,
          itemBuilder: (_, i) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _RecordingCard(rec: ctrl.recordings[i]),
          ),
        );
      }),
    );
  }
}

class _RecordingCard extends StatelessWidget {
  final RecordingModel rec;
  const _RecordingCard({required this.rec});

  @override
  Widget build(BuildContext context) {
    final dateStr = _formatDate(rec.startedAt);
    final timeStr = _formatTime(rec.startedAt);

    return GlassCard(
      child: Row(children: [
        // Thumbnail / icon
        Container(
          width: 60, height: 60,
          decoration: BoxDecoration(
            color: AppTheme.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppTheme.primary.withOpacity(0.25)),
          ),
          child: const Icon(Icons.play_circle_outline, color: AppTheme.primary, size: 32),
        ),
        const SizedBox(width: 14),

        // Info
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(rec.cameraName, overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: AppTheme.textPri, fontSize: 14, fontWeight: FontWeight.w600)),
          const SizedBox(height: 3),
          Text('$dateStr  $timeStr',
              style: const TextStyle(color: AppTheme.textSec, fontSize: 12)),
          const SizedBox(height: 5),
          Row(children: [
            _Badge(icon: Icons.timer_outlined,  label: rec.durationLabel),
            const SizedBox(width: 8),
            _Badge(icon: Icons.folder_outlined, label: rec.sizeLabel),
          ]),
        ])),
        const SizedBox(width: 8),

        // Actions
        Column(mainAxisSize: MainAxisSize.min, children: [
          IconButton(
            icon: const Icon(Icons.open_in_new, color: AppTheme.primary, size: 20),
            tooltip: 'Open video',
            onPressed: rec.downloadUrl.isNotEmpty
                ? () => Get.snackbar('Download URL', rec.downloadUrl,
                        backgroundColor: AppTheme.surface,
                        colorText: AppTheme.textSec,
                        snackPosition: SnackPosition.BOTTOM)
                : null,
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: AppTheme.danger, size: 20),
            tooltip: 'Delete',
            onPressed: () => _confirmDelete(context),
          ),
        ]),
      ]),
    );
  }

  void _confirmDelete(BuildContext context) {
    Get.defaultDialog(
      backgroundColor: AppTheme.surface,
      title: 'Delete Recording',
      titleStyle: const TextStyle(color: AppTheme.textPri, fontSize: 16),
      content: Text(
        'Delete this ${rec.durationLabel} clip from ${rec.cameraName}?\nThis also removes it from cloud storage.',
        textAlign: TextAlign.center,
        style: const TextStyle(color: AppTheme.textSec, fontSize: 13),
      ),
      textCancel: 'Cancel',
      textConfirm: 'Delete',
      cancelTextColor: AppTheme.textSec,
      confirmTextColor: AppTheme.danger,
      buttonColor: AppTheme.surface,
      onConfirm: () {
        Get.back();
        RecordingController.to.deleteRecording(rec);
      },
    );
  }

  String _formatDate(DateTime dt) {
    return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}';
  }

  String _formatTime(DateTime dt) {
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }
}

class _Badge extends StatelessWidget {
  final IconData icon; final String label;
  const _Badge({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) => Row(mainAxisSize: MainAxisSize.min, children: [
    Icon(icon, size: 11, color: AppTheme.textSec),
    const SizedBox(width: 3),
    Text(label, style: const TextStyle(color: AppTheme.textSec, fontSize: 11)),
  ]);
}
