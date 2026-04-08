import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smart_security_camera/controllers/camera_controller.dart';
import 'package:smart_security_camera/model/camera_model.dart';
import 'package:smart_security_camera/screens/app_theme.dart';
import 'package:smart_security_camera/sharedWidget/shared_widged.dart';

class PeopleCounterScreen extends StatelessWidget {
  const PeopleCounterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Occupancy & Safety'),
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.people_alt_outlined, size: 18), text: 'In / Out'),
              Tab(icon: Icon(Icons.shield_outlined, size: 18),     text: 'Safety Kit'),
            ],
            labelColor: AppTheme.primary,
            unselectedLabelColor: AppTheme.textSec,
            indicatorColor: AppTheme.primary,
          ),
        ),
        body: const TabBarView(children: [
          _OccupancyTab(),
          _SafetyTab(),
        ]),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// OCCUPANCY TAB
// ─────────────────────────────────────────────────────────────
class _OccupancyTab extends StatelessWidget {
  const _OccupancyTab();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final ctrl  = CameraController.to;
      final total = ctrl.totalPeople;
      final totalIn  = ctrl.cameras.fold(0, (s, c) => s + c.peopleIn);
      final totalOut = ctrl.cameras.fold(0, (s, c) => s + c.peopleOut);
      final members  = ctrl.cameras.fold(0, (s, c) => s + c.memberCount);
      final visitors = ctrl.cameras.fold(0, (s, c) => s + c.visitorCount);

      return SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(children: [
          // ── Summary card ─────────────────────────────────
          GlassCard(
            borderColor: total > 20
                ? AppTheme.danger.withOpacity(0.5)
                : AppTheme.primary.withOpacity(0.3),
            child: Column(children: [
              const Text('Current Occupancy', style: TextStyle(color: AppTheme.textSec, fontSize: 13)),
              const SizedBox(height: 6),
              Text(
                '$total',
                style: TextStyle(
                  color: total > 20 ? AppTheme.danger : AppTheme.primary,
                  fontSize: 72, fontWeight: FontWeight.w800,
                ),
              ),
              const Text('people inside right now', style: TextStyle(color: AppTheme.textSec, fontSize: 13)),
              if (total > 20) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppTheme.danger.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text('⚠️  Capacity exceeded', style: TextStyle(color: AppTheme.danger, fontSize: 13, fontWeight: FontWeight.w600)),
                ),
              ],
              const SizedBox(height: 16),
              // In / Out row
              Row(children: [
                Expanded(child: _SummaryBox(label: 'Entered', value: totalIn,
                    icon: Icons.login_rounded, color: AppTheme.primary)),
                const SizedBox(width: 10),
                Expanded(child: _SummaryBox(label: 'Exited', value: totalOut,
                    icon: Icons.logout_rounded, color: AppTheme.textSec)),
              ]),
              const SizedBox(height: 10),
              Row(children: [
                Expanded(child: _SummaryBox(label: 'Members', value: members,
                    icon: Icons.badge_outlined, color: AppTheme.info)),
                const SizedBox(width: 10),
                Expanded(child: _SummaryBox(label: 'Visitors', value: visitors,
                    icon: Icons.person_outline, color: const Color(0xFFFFB300))),
              ]),
            ]),
          ),
          const SizedBox(height: 20),

          // ── Per camera ───────────────────────────────────
          const Align(
            alignment: Alignment.centerLeft,
            child: Text('Per Camera', style: TextStyle(color: AppTheme.textPri, fontSize: 15, fontWeight: FontWeight.w600)),
          ),
          const SizedBox(height: 12),
          if (ctrl.cameras.isEmpty)
            GlassCard(child: Row(children: const [
              Icon(Icons.videocam_off, color: AppTheme.textSec, size: 22),
              SizedBox(width: 12),
              Text('No cameras added yet', style: TextStyle(color: AppTheme.textSec, fontSize: 14)),
            ]))
          else
            ...ctrl.cameras.map((cam) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _CameraOccupancyCard(cam: cam),
            )),
        ]),
      );
    });
  }
}

class _CameraOccupancyCard extends StatelessWidget {
  final CameraModel cam;
  const _CameraOccupancyCard({required this.cam});

  @override
  Widget build(BuildContext context) {
    final ctrl = CameraController.to;
    return GlassCard(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Header
        Row(children: [
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(cam.name, overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: AppTheme.textPri, fontWeight: FontWeight.w600)),
            Text(cam.location, overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: AppTheme.textSec, fontSize: 12)),
          ])),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppTheme.primary.withOpacity(0.12),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text('${cam.peopleCount} inside',
                style: const TextStyle(color: AppTheme.primary, fontSize: 12, fontWeight: FontWeight.w600)),
          ),
        ]),
        const SizedBox(height: 14),

        // In / Out stat row
        Row(children: [
          _MiniStat(label: 'IN',      value: '${cam.peopleIn}',  color: AppTheme.primary),
          const SizedBox(width: 8),
          _MiniStat(label: 'OUT',     value: '${cam.peopleOut}', color: AppTheme.textSec),
          const SizedBox(width: 8),
          _MiniStat(label: 'MEMBERS', value: '${cam.memberCount}',  color: AppTheme.info),
          const SizedBox(width: 8),
          _MiniStat(label: 'VISITORS',value: '${cam.visitorCount}', color: const Color(0xFFFFB300)),
        ]),
        const SizedBox(height: 14),

        // Action buttons
        Row(children: [
          Expanded(child: _CountBtn(
            label: 'Member IN',
            icon: Icons.login_rounded,
            color: AppTheme.primary,
            onTap: () => ctrl.logEntry(cam.id, isMember: true),
          )),
          const SizedBox(width: 8),
          Expanded(child: _CountBtn(
            label: 'Visitor IN',
            icon: Icons.person_add_outlined,
            color: const Color(0xFFFFB300),
            onTap: () => ctrl.logEntry(cam.id, isMember: false),
          )),
          const SizedBox(width: 8),
          Expanded(child: _CountBtn(
            label: 'OUT',
            icon: Icons.logout_rounded,
            color: AppTheme.danger,
            onTap: () => ctrl.logExit(cam.id),
          )),
        ]),
        const SizedBox(height: 8),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton.icon(
            onPressed: () => ctrl.resetOccupancy(cam.id),
            icon: const Icon(Icons.refresh, size: 14, color: AppTheme.textSec),
            label: const Text('Reset', style: TextStyle(color: AppTheme.textSec, fontSize: 12)),
            style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4)),
          ),
        ),
      ]),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// SAFETY TAB
// ─────────────────────────────────────────────────────────────
class _SafetyTab extends StatelessWidget {
  const _SafetyTab();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final ctrl       = CameraController.to;
      final violations = ctrl.totalViolations;
      final safetyZoneCameras = ctrl.cameras.where((c) => c.safetyZoneEnabled).toList();

      return SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(children: [
          // ── Overall compliance ─────────────────────────
          GlassCard(
            borderColor: violations > 0
                ? AppTheme.danger.withOpacity(0.5)
                : AppTheme.primary.withOpacity(0.3),
            child: Column(children: [
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                Icon(Icons.shield_outlined,
                    color: violations > 0 ? AppTheme.danger : AppTheme.primary, size: 20),
                const SizedBox(width: 8),
                Text('Safety Compliance',
                    style: TextStyle(
                      color: violations > 0 ? AppTheme.danger : AppTheme.primary,
                      fontSize: 15, fontWeight: FontWeight.w600,
                    )),
              ]),
              const SizedBox(height: 12),
              if (violations > 0)
                Column(children: [
                  Text('$violations', style: const TextStyle(
                      color: AppTheme.danger, fontSize: 56, fontWeight: FontWeight.w800)),
                  const Text('safety violations', style: TextStyle(color: AppTheme.danger, fontSize: 13)),
                ])
              else
                Column(children: [
                  const Icon(Icons.verified_outlined, color: AppTheme.primary, size: 52),
                  const SizedBox(height: 4),
                  const Text('All compliant', style: TextStyle(color: AppTheme.primary, fontSize: 15, fontWeight: FontWeight.w600)),
                ]),
              if (safetyZoneCameras.isEmpty) ...[
                const SizedBox(height: 12),
                const Text('Enable Safety Zone on a camera below to start monitoring.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppTheme.textSec, fontSize: 12)),
              ],
            ]),
          ),
          const SizedBox(height: 20),

          const Align(
            alignment: Alignment.centerLeft,
            child: Text('Camera Safety Zones', style: TextStyle(color: AppTheme.textPri, fontSize: 15, fontWeight: FontWeight.w600)),
          ),
          const SizedBox(height: 12),

          if (ctrl.cameras.isEmpty)
            GlassCard(child: Row(children: const [
              Icon(Icons.videocam_off, color: AppTheme.textSec, size: 22),
              SizedBox(width: 12),
              Text('No cameras added yet', style: TextStyle(color: AppTheme.textSec, fontSize: 14)),
            ]))
          else
            ...ctrl.cameras.map((cam) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _CameraSafetyCard(cam: cam),
            )),
        ]),
      );
    });
  }
}

class _CameraSafetyCard extends StatelessWidget {
  final CameraModel cam;
  const _CameraSafetyCard({required this.cam});

  @override
  Widget build(BuildContext context) {
    final ctrl = CameraController.to;
    return GlassCard(
      borderColor: cam.safetyZoneEnabled && cam.safetyViolations > 0
          ? AppTheme.danger.withOpacity(0.4)
          : null,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Header + zone toggle
        Row(children: [
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(cam.name, overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: AppTheme.textPri, fontWeight: FontWeight.w600)),
            Text(cam.location, overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: AppTheme.textSec, fontSize: 12)),
          ])),
          Row(children: [
            const Text('Safety Zone', style: TextStyle(color: AppTheme.textSec, fontSize: 12)),
            const SizedBox(width: 6),
            Switch(
              value: cam.safetyZoneEnabled,
              onChanged: (_) => ctrl.toggleSafetyZone(cam.id),
              activeColor: AppTheme.primary,
              inactiveThumbColor: AppTheme.textSec,
              inactiveTrackColor: AppTheme.surface2,
            ),
          ]),
        ]),

        if (cam.safetyZoneEnabled) ...[
          const Divider(color: AppTheme.surface2, height: 20),

          // Required kit checkboxes
          const Text('Required Equipment', style: TextStyle(color: AppTheme.textSec, fontSize: 12)),
          const SizedBox(height: 8),
          Wrap(spacing: 8, runSpacing: 6, children: [
            _KitChip(
              label: 'Helmet',
              icon: Icons.construction,
              enabled: cam.requireHelmet,
              onTap: () => ctrl.updateSafetyRequirements(cam.id, helmet: !cam.requireHelmet),
            ),
            _KitChip(
              label: 'Safety Vest',
              icon: Icons.checkroom,
              enabled: cam.requireVest,
              onTap: () => ctrl.updateSafetyRequirements(cam.id, vest: !cam.requireVest),
            ),
            _KitChip(
              label: 'Goggles',
              icon: Icons.visibility,
              enabled: cam.requireGoggles,
              onTap: () => ctrl.updateSafetyRequirements(cam.id, goggles: !cam.requireGoggles),
            ),
          ]),
          const SizedBox(height: 14),

          // Compliance stats
          Row(children: [
            Expanded(child: _MiniStat(
              label: 'COMPLIANT',
              value: '${cam.safetyCompliant}',
              color: AppTheme.primary,
            )),
            const SizedBox(width: 8),
            Expanded(child: _MiniStat(
              label: 'VIOLATIONS',
              value: '${cam.safetyViolations}',
              color: cam.safetyViolations > 0 ? AppTheme.danger : AppTheme.textSec,
            )),
            const SizedBox(width: 8),
            Expanded(child: _MiniStat(
              label: 'RATE',
              value: '${cam.safetyComplianceRate}%',
              color: cam.safetyComplianceRate < 80 ? AppTheme.danger : AppTheme.primary,
            )),
          ]),
          const SizedBox(height: 12),

          // Compliance bar
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: cam.safetyComplianceRate / 100,
              minHeight: 6,
              backgroundColor: AppTheme.surface2,
              valueColor: AlwaysStoppedAnimation(
                cam.safetyComplianceRate < 80 ? AppTheme.danger : AppTheme.primary,
              ),
            ),
          ),
          const SizedBox(height: 14),

          // Log buttons
          Row(children: [
            Expanded(child: _CountBtn(
              label: 'Kit Worn ✓',
              icon: Icons.check_circle_outline,
              color: AppTheme.primary,
              onTap: () => ctrl.logSafetyCompliant(cam.id),
            )),
            const SizedBox(width: 8),
            Expanded(child: _CountBtn(
              label: 'Kit Missing ✗',
              icon: Icons.cancel_outlined,
              color: AppTheme.danger,
              onTap: () => ctrl.logSafetyViolation(cam.id),
            )),
          ]),
          const SizedBox(height: 6),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: () => ctrl.resetSafetyStats(cam.id),
              icon: const Icon(Icons.refresh, size: 14, color: AppTheme.textSec),
              label: const Text('Reset stats', style: TextStyle(color: AppTheme.textSec, fontSize: 12)),
              style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4)),
            ),
          ),
        ],
      ]),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Shared small widgets
// ─────────────────────────────────────────────────────────────
class _SummaryBox extends StatelessWidget {
  final String label; final int value; final IconData icon; final Color color;
  const _SummaryBox({required this.label, required this.value, required this.icon, required this.color});

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
        Text('$value', style: TextStyle(color: color, fontSize: 20, fontWeight: FontWeight.w800)),
        Text(label, style: const TextStyle(color: AppTheme.textSec, fontSize: 10)),
      ])),
    ]),
  );
}

class _MiniStat extends StatelessWidget {
  final String label; final String value; final Color color;
  const _MiniStat({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
    decoration: BoxDecoration(
      color: color.withOpacity(0.08),
      borderRadius: BorderRadius.circular(8),
    ),
    child: Column(children: [
      Text(value, style: TextStyle(color: color, fontSize: 16, fontWeight: FontWeight.w700)),
      const SizedBox(height: 2),
      Text(label, style: const TextStyle(color: AppTheme.textSec, fontSize: 9, fontWeight: FontWeight.w600)),
    ]),
  );
}

class _CountBtn extends StatelessWidget {
  final String label; final IconData icon; final Color color; final VoidCallback onTap;
  const _CountBtn({required this.label, required this.icon, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 9),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.35)),
      ),
      child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(icon, color: color, size: 15),
        const SizedBox(width: 5),
        Flexible(child: Text(label, overflow: TextOverflow.ellipsis, maxLines: 1,
            style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w600))),
      ]),
    ),
  );
}

class _KitChip extends StatelessWidget {
  final String label; final IconData icon; final bool enabled; final VoidCallback onTap;
  const _KitChip({required this.label, required this.icon, required this.enabled, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: enabled ? AppTheme.primary.withOpacity(0.12) : AppTheme.surface2,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: enabled ? AppTheme.primary.withOpacity(0.5) : Colors.transparent),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 14, color: enabled ? AppTheme.primary : AppTheme.textSec),
        const SizedBox(width: 5),
        Text(label, style: TextStyle(
            color: enabled ? AppTheme.primary : AppTheme.textSec,
            fontSize: 12, fontWeight: enabled ? FontWeight.w600 : FontWeight.normal)),
      ]),
    ),
  );
}
