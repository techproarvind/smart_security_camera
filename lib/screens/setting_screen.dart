import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:smart_security_camera/controllers/alert_controller.dart';
import 'package:smart_security_camera/controllers/auth_controller.dart';
import 'package:smart_security_camera/controllers/camera_controller.dart';
import 'package:smart_security_camera/controllers/notification_controller.dart';
import 'package:smart_security_camera/controllers/settings_controller.dart';
import 'package:smart_security_camera/screens/app_theme.dart';
import 'package:smart_security_camera/sharedWidget/shared_widged.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth     = AuthController.to;
    final settings = SettingsController.to;
    final cameras  = CameraController.to;
    final alerts   = AlertController.to;
    final notif    = NotificationController.to;

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: Obx(() {
        final user       = FirebaseAuth.instance.currentUser;
        final email      = user?.email ?? 'Not signed in';
        final initials   = auth.userName.isNotEmpty ? auth.userName[0].toUpperCase() : '?';
        final roleLabel  = auth.role == UserRole.camera ? 'Camera Device' : 'Viewer';
        final roleColor  = auth.role == UserRole.camera ? AppTheme.danger : AppTheme.primary;
        final roleIcon   = auth.role == UserRole.camera ? Icons.videocam : Icons.visibility_outlined;

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [

            // ── Profile card ──────────────────────────────
            GlassCard(
              child: Row(children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: AppTheme.primary.withOpacity(0.15),
                  child: Text(initials,
                      style: const TextStyle(color: AppTheme.primary, fontSize: 24, fontWeight: FontWeight.w700)),
                ),
                const SizedBox(width: 16),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(auth.userName.isNotEmpty ? auth.userName : 'User',
                      overflow: TextOverflow.ellipsis, maxLines: 1,
                      style: const TextStyle(color: AppTheme.textPri, fontSize: 16, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 2),
                  Text(email, overflow: TextOverflow.ellipsis, maxLines: 1,
                      style: const TextStyle(color: AppTheme.textSec, fontSize: 12)),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: roleColor.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: roleColor.withOpacity(0.4)),
                    ),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      Icon(roleIcon, color: roleColor, size: 12),
                      const SizedBox(width: 4),
                      Text(roleLabel, style: TextStyle(color: roleColor, fontSize: 11, fontWeight: FontWeight.w600)),
                    ]),
                  ),
                ])),
              ]),
            ),
            const SizedBox(height: 16),

            // ── Live stats ────────────────────────────────
            _Section(title: 'Live Stats', tiles: [
              _InfoTile(
                icon: Icons.videocam_outlined,
                label: 'Total Cameras',
                value: '${cameras.cameras.length}',
              ),
              _InfoTile(
                icon: Icons.circle, iconColor: AppTheme.primary,
                label: 'Online',
                value: '${cameras.onlineCount}',
              ),
              _InfoTile(
                icon: Icons.circle, iconColor: AppTheme.textSec,
                label: 'Offline',
                value: '${cameras.offlineCount}',
              ),
              _InfoTile(
                icon: Icons.people_outline,
                label: 'Current Occupancy',
                value: '${cameras.totalPeople}',
              ),
              _InfoTile(
                icon: Icons.notifications_none,
                label: 'Unread Alerts',
                value: '${alerts.unreadCount}',
                valueColor: alerts.unreadCount > 0 ? AppTheme.danger : null,
              ),
            ]),
            const SizedBox(height: 12),

            // ── Notifications ─────────────────────────────
            _Section(title: 'Notifications', tiles: [
              _SwitchTile(
                icon: Icons.notifications_active_outlined,
                label: 'Push Notifications',
                value: settings.pushNotifications.value,
                onChanged: (_) => settings.togglePush(),
              ),
              _SwitchTile(
                icon: Icons.motion_photos_on_outlined,
                label: 'Motion Alerts',
                value: settings.motionAlerts.value,
                onChanged: (_) => settings.toggleMotion(),
              ),
              _SwitchTile(
                icon: Icons.people_outline,
                label: 'Occupancy Alerts',
                value: settings.occupancyAlerts.value,
                onChanged: (_) => settings.toggleOccupancy(),
              ),
              _SwitchTile(
                icon: Icons.shield_outlined,
                label: 'Safety Violation Alerts',
                value: settings.safetyAlerts.value,
                onChanged: (_) => settings.toggleSafety(),
              ),
            ]),
            const SizedBox(height: 12),

            // ── Account ───────────────────────────────────
            _Section(title: 'Account', tiles: [
              _ActionTile(
                icon: Icons.lock_reset_outlined,
                label: 'Reset Password',
                onTap: () => _resetPassword(auth, email),
              ),
              _ActionTile(
                icon: Icons.swap_horiz_outlined,
                label: 'Switch Role',
                subtitle: 'Current: $roleLabel',
                onTap: () => Get.offAllNamed('/role'),
              ),
              _ActionTile(
                icon: Icons.delete_sweep_outlined,
                label: 'Clear All Alerts',
                color: AppTheme.danger,
                onTap: () => _confirmClear(alerts),
              ),
            ]),
            const SizedBox(height: 12),

            // ── Device / Debug ────────────────────────────
            _Section(title: 'Device', tiles: [
              _InfoTile(
                icon: Icons.info_outline,
                label: 'App Version',
                value: 'v1.0.0',
              ),
              _ActionTile(
                icon: Icons.copy_outlined,
                label: 'Copy FCM Token',
                subtitle: notif.fcmToken.value.isNotEmpty ? 'Token available' : 'No token',
                onTap: notif.fcmToken.value.isNotEmpty
                    ? () {
                        Clipboard.setData(ClipboardData(text: notif.fcmToken.value));
                        Get.snackbar('Copied', 'FCM token copied to clipboard',
                            backgroundColor: AppTheme.surface,
                            colorText: AppTheme.primary,
                            snackPosition: SnackPosition.BOTTOM);
                      }
                    : null,
              ),
            ]),
            const SizedBox(height: 20),

            // ── Sign out ──────────────────────────────────
            ElevatedButton.icon(
              onPressed: () => _confirmLogout(auth),
              icon: const Icon(Icons.logout, size: 18),
              label: const Text('Sign Out'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.danger.withOpacity(0.15),
                foregroundColor: AppTheme.danger,
              ),
            ),
            const SizedBox(height: 8),
          ],
        );
      }),
    );
  }

  void _resetPassword(AuthController auth, String email) async {
    final err = await auth.forgotPassword(email);
    if (err == null) {
      Get.snackbar('Email Sent', 'Password reset link sent to $email',
          backgroundColor: AppTheme.surface, colorText: AppTheme.primary,
          snackPosition: SnackPosition.BOTTOM);
    } else {
      Get.snackbar('Error', err,
          backgroundColor: AppTheme.surface, colorText: AppTheme.danger,
          snackPosition: SnackPosition.BOTTOM);
    }
  }

  void _confirmClear(AlertController alerts) {
    Get.defaultDialog(
      backgroundColor: AppTheme.surface,
      title: 'Clear Alerts',
      titleStyle: const TextStyle(color: AppTheme.textPri, fontSize: 16),
      content: const Text('Remove all alerts? This cannot be undone.',
          textAlign: TextAlign.center,
          style: TextStyle(color: AppTheme.textSec, fontSize: 14)),
      textCancel: 'Cancel',
      textConfirm: 'Clear All',
      cancelTextColor: AppTheme.textSec,
      confirmTextColor: AppTheme.danger,
      buttonColor: AppTheme.surface,
      onConfirm: () { Get.back(); alerts.clearAll(); },
    );
  }

  void _confirmLogout(AuthController auth) {
    Get.defaultDialog(
      backgroundColor: AppTheme.surface,
      title: 'Sign Out',
      titleStyle: const TextStyle(color: AppTheme.textPri, fontSize: 16),
      content: const Text('Are you sure you want to sign out?',
          textAlign: TextAlign.center,
          style: TextStyle(color: AppTheme.textSec, fontSize: 14)),
      textCancel: 'Cancel',
      textConfirm: 'Sign Out',
      cancelTextColor: AppTheme.textSec,
      confirmTextColor: AppTheme.danger,
      buttonColor: AppTheme.surface,
      onConfirm: () { Get.back(); auth.logout(); },
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Section wrapper
// ─────────────────────────────────────────────────────────────
class _Section extends StatelessWidget {
  final String title; final List<Widget> tiles;
  const _Section({required this.title, required this.tiles});

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Padding(
        padding: const EdgeInsets.only(left: 4, bottom: 8),
        child: Text(title.toUpperCase(),
            style: const TextStyle(color: AppTheme.textSec, fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 1)),
      ),
      GlassCard(
        padding: EdgeInsets.zero,
        child: Column(children: tiles.asMap().entries.map((e) => Column(children: [
          e.value,
          if (e.key < tiles.length - 1) const Divider(color: AppTheme.surface2, height: 1, indent: 52),
        ])).toList()),
      ),
    ],
  );
}

// ─────────────────────────────────────────────────────────────
// Tile variants
// ─────────────────────────────────────────────────────────────
class _InfoTile extends StatelessWidget {
  final IconData icon; final Color? iconColor; final String label;
  final String value; final Color? valueColor;
  const _InfoTile({required this.icon, required this.label, required this.value,
      this.iconColor, this.valueColor});

  @override
  Widget build(BuildContext context) => ListTile(
    leading: Icon(icon, color: iconColor ?? AppTheme.textSec, size: 20),
    title: Text(label, style: const TextStyle(color: AppTheme.textPri, fontSize: 14)),
    trailing: Text(value,
        style: TextStyle(color: valueColor ?? AppTheme.primary, fontSize: 13, fontWeight: FontWeight.w600)),
    dense: true,
  );
}

class _SwitchTile extends StatelessWidget {
  final IconData icon; final String label; final bool value;
  final ValueChanged<bool> onChanged;
  const _SwitchTile({required this.icon, required this.label, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) => ListTile(
    leading: Icon(icon, color: value ? AppTheme.primary : AppTheme.textSec, size: 20),
    title: Text(label, style: const TextStyle(color: AppTheme.textPri, fontSize: 14)),
    trailing: Switch(
      value: value, onChanged: onChanged,
      activeColor: AppTheme.primary,
      inactiveThumbColor: AppTheme.textSec,
      inactiveTrackColor: AppTheme.surface2,
    ),
    dense: true,
  );
}

class _ActionTile extends StatelessWidget {
  final IconData icon; final String label; final String? subtitle;
  final VoidCallback? onTap; final Color? color;
  const _ActionTile({required this.icon, required this.label,
      this.subtitle, this.onTap, this.color});

  @override
  Widget build(BuildContext context) => ListTile(
    onTap: onTap,
    leading: Icon(icon, color: color ?? AppTheme.textSec, size: 20),
    title: Text(label, style: TextStyle(color: color ?? AppTheme.textPri, fontSize: 14)),
    subtitle: subtitle != null
        ? Text(subtitle!, style: const TextStyle(color: AppTheme.textSec, fontSize: 11))
        : null,
    trailing: onTap != null
        ? Icon(Icons.chevron_right, color: color ?? AppTheme.textSec, size: 18)
        : null,
    dense: true,
  );
}
