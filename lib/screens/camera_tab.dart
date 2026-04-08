import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_security_camera/provider/alert_provider.dart';
import 'package:smart_security_camera/provider/camera_provider.dart';
import 'package:smart_security_camera/screens/app_theme.dart';
import 'package:smart_security_camera/screens/camera_card.dart';
import 'package:smart_security_camera/sharedWidget/shared_widged.dart';

class CamerasTab extends StatelessWidget {
  const CamerasTab();
  @override
  Widget build(BuildContext context) {
    final camP = context.watch<CameraProvider>();
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Stats row
          Row(
            children: [
              _StatCard(label: 'Online',   value: '${camP.onlineCount}',  icon: Icons.wifi,          color: AppTheme.primary),
              const SizedBox(width: 12),
              _StatCard(label: 'Offline',  value: '${camP.offlineCount}', icon: Icons.wifi_off,      color: AppTheme.textSec),
              const SizedBox(width: 12),
              _StatCard(label: 'People',   value: '${camP.totalPeople}',  icon: Icons.people_outline, color: AppTheme.info),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Your Cameras', style: TextStyle(color: AppTheme.textPri, fontSize: 16, fontWeight: FontWeight.w600)),
              TextButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.add, size: 16, color: AppTheme.primary),
                label: const Text('Add Camera', style: TextStyle(color: AppTheme.primary, fontSize: 13)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.72,
            ),
            itemCount: camP.cameras.length,
            itemBuilder: (_, i) => CameraCard(camera: camP.cameras[i]),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label, value;
  final IconData icon;
  final Color color;
  const _StatCard({required this.label, required this.value, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) => Expanded(
    child: GlassCard(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 8),
          Text(value, style: TextStyle(color: color, fontSize: 22, fontWeight: FontWeight.w700)),
          Text(label, style: const TextStyle(color: AppTheme.textSec, fontSize: 12)),
        ],
      ),
    ),
  );
}

class AlertsTab extends StatelessWidget {
  const AlertsTab();
  @override
  Widget build(BuildContext context) {
    final alertP = context.watch<AlertProvider>();
    return Column(
      children: [
        if (alertP.unreadCount > 0)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: GlassCard(
              borderColor: AppTheme.danger.withOpacity(0.4),
              child: Row(
                children: [
                  const Icon(Icons.warning_amber_rounded, color: AppTheme.danger, size: 20),
                  const SizedBox(width: 12),
                  Expanded(child: Text('${alertP.unreadCount} unread alerts', style: const TextStyle(color: AppTheme.textPri, fontWeight: FontWeight.w500))),
                  TextButton(onPressed: alertP.markAllRead, child: const Text('Mark all read', style: TextStyle(color: AppTheme.primary, fontSize: 12))),
                ],
              ),
            ),
          ),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: alertP.alerts.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (_, i) {
              final a = alertP.alerts[i];
              return GestureDetector(
                onTap: () => alertP.markRead(a.id),
                child: GlassCard(
                  borderColor: !a.isRead ? a.color.withOpacity(0.4) : null,
                  child: Row(
                    children: [
                      Container(
                        width: 40, height: 40,
                        decoration: BoxDecoration(color: a.color.withOpacity(0.15), borderRadius: BorderRadius.circular(10)),
                        child: Icon(a.icon, color: a.color, size: 20),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(a.typeLabel, style: const TextStyle(color: AppTheme.textPri, fontSize: 14, fontWeight: FontWeight.w600)),
                            Text(a.cameraName, style: const TextStyle(color: AppTheme.textSec, fontSize: 12)),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(_timeAgo(a.timestamp), style: const TextStyle(color: AppTheme.textSec, fontSize: 11)),
                          if (!a.isRead)
                            Container(
                              width: 8, height: 8,
                              margin: const EdgeInsets.only(top: 4),
                              decoration: BoxDecoration(color: a.color, shape: BoxShape.circle),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  String _timeAgo(DateTime dt) {
    final d = DateTime.now().difference(dt);
    if (d.inMinutes < 1) return 'Just now';
    if (d.inMinutes < 60) return '${d.inMinutes}m ago';
    if (d.inHours < 24) return '${d.inHours}h ago';
    return '${d.inDays}d ago';
  }
}

class AnalyticsTab extends StatelessWidget {
  const AnalyticsTab();
  @override
  Widget build(BuildContext context) {
    final camP = context.watch<CameraProvider>();
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('People Occupancy', style: TextStyle(color: AppTheme.textPri, fontSize: 16, fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          ...camP.cameras.where((c) => c.peopleCount > 0).map((cam) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: GlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          cam.name,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                          style: const TextStyle(color: AppTheme.textPri, fontSize: 14, fontWeight: FontWeight.w600),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text('${cam.peopleCount} people', style: const TextStyle(color: AppTheme.info, fontSize: 13, fontWeight: FontWeight.w600)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: (cam.peopleCount / 20).clamp(0, 1),
                      backgroundColor: AppTheme.surface2,
                      color: cam.peopleCount > 15 ? AppTheme.danger : AppTheme.info,
                      minHeight: 8,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text('Max capacity: 20', style: const TextStyle(color: AppTheme.textSec, fontSize: 11)),
                ],
              ),
            ),
          )),
          const SizedBox(height: 8),
          const Text('Quick Actions', style: TextStyle(color: AppTheme.textPri, fontSize: 16, fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          Row(
            children: [
              _QuickAction(icon: Icons.people_alt_outlined, label: 'People\nCounter', color: AppTheme.info,    route: '/people_counter'),
              const SizedBox(width: 12),
              _QuickAction(icon: Icons.videocam,             label: 'Live\nView',       color: AppTheme.primary, route: '/live',           args: 'cam_001'),
              const SizedBox(width: 12),
              _QuickAction(icon: Icons.history,              label: 'Alert\nHistory',   color: AppTheme.warning, route: '/alerts'),
            ],
          ),
        ],
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  final IconData icon; final String label, route; final Color color; final Object? args;
  const _QuickAction({required this.icon, required this.label, required this.color, required this.route, this.args});
  @override
  Widget build(BuildContext context) => Expanded(
    child: GestureDetector(
      onTap: () => Navigator.pushNamed(context, route, arguments: args),
      child: GlassCard(
        child: Column(
          children: [
            Container(
              width: 44, height: 44,
              decoration: BoxDecoration(color: color.withOpacity(0.15), borderRadius: BorderRadius.circular(12)),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(height: 8),
            Text(label, textAlign: TextAlign.center, style: const TextStyle(color: AppTheme.textPri, fontSize: 12, fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    ),
  );
}