import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_security_camera/provider/auth_provider.dart';
import 'package:smart_security_camera/screens/app_theme.dart';
import 'package:smart_security_camera/sharedWidget/shared_widged.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          GlassCard(
            child: Row(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: AppTheme.primary.withOpacity(0.15),
                  child: Text(
                    auth.userName.isNotEmpty ? auth.userName[0].toUpperCase() : 'U',
                    style: const TextStyle(color: AppTheme.primary, fontSize: 22, fontWeight: FontWeight.w700),
                  ),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(auth.userName, style: const TextStyle(color: AppTheme.textPri, fontSize: 16, fontWeight: FontWeight.w600)),
                    const Text('Premium Plan', style: TextStyle(color: AppTheme.primary, fontSize: 12)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _SettingsSection(title: 'Notifications', tiles: [
            _SettingsTile(icon: Icons.notifications_active_outlined, label: 'Push Notifications', trailing: Switch(value: true, onChanged: (_){}, activeColor: AppTheme.primary)),
            _SettingsTile(icon: Icons.motion_photos_on_outlined, label: 'Motion Alerts',        trailing: Switch(value: true, onChanged: (_){}, activeColor: AppTheme.primary)),
            _SettingsTile(icon: Icons.people_outline,             label: 'Occupancy Alerts',    trailing: Switch(value: false, onChanged: (_){}, activeColor: AppTheme.primary)),
          ]),
          const SizedBox(height: 12),
          _SettingsSection(title: 'Security', tiles: [
            _SettingsTile(icon: Icons.lock_outline,    label: 'Two-Factor Auth'),
            _SettingsTile(icon: Icons.key_outlined,    label: 'Change Password'),
            _SettingsTile(icon: Icons.devices_outlined, label: 'Connected Devices'),
          ]),
          const SizedBox(height: 12),
          _SettingsSection(title: 'Storage', tiles: [
            _SettingsTile(icon: Icons.cloud_outlined,          label: 'Cloud Storage',    trailing: const Text('4.2 GB / 15 GB', style: TextStyle(color: AppTheme.textSec, fontSize: 12))),
            _SettingsTile(icon: Icons.video_settings_outlined, label: 'Video Quality',    trailing: const Text('1080p', style: TextStyle(color: AppTheme.primary, fontSize: 12))),
            _SettingsTile(icon: Icons.history_outlined,        label: 'Retention Period', trailing: const Text('30 days', style: TextStyle(color: AppTheme.primary, fontSize: 12))),
          ]),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              context.read<AuthProvider>().logout();
              Navigator.pushNamedAndRemoveUntil(context, '/login', (_) => false);
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.danger.withOpacity(0.15), foregroundColor: AppTheme.danger),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
  }
}

class _SettingsSection extends StatelessWidget {
  final String title; final List<Widget> tiles;
  const _SettingsSection({required this.title, required this.tiles});
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Padding(
        padding: const EdgeInsets.only(left: 4, bottom: 8),
        child: Text(title, style: const TextStyle(color: AppTheme.textSec, fontSize: 12, fontWeight: FontWeight.w600, letterSpacing: 0.8)),
      ),
      GlassCard(
        padding: EdgeInsets.zero,
        child: Column(
          children: tiles.asMap().entries.map((e) => Column(
            children: [
              e.value,
              if (e.key < tiles.length - 1) const Divider(color: AppTheme.surface2, height: 1, indent: 52),
            ],
          )).toList(),
        ),
      ),
    ],
  );
}

class _SettingsTile extends StatelessWidget {
  final IconData icon; final String label; final Widget? trailing;
  const _SettingsTile({required this.icon, required this.label, this.trailing});
  @override
  Widget build(BuildContext context) => ListTile(
    leading: Icon(icon, color: AppTheme.textSec, size: 20),
    title: Text(label, style: const TextStyle(color: AppTheme.textPri, fontSize: 14)),
    trailing: trailing ?? const Icon(Icons.chevron_right, color: AppTheme.textSec, size: 18),
    dense: true,
  );
}