import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_security_camera/model/camera_model.dart';
import 'package:smart_security_camera/provider/camera_provider.dart';
import 'package:smart_security_camera/screens/app_theme.dart';
import 'package:smart_security_camera/sharedWidget/shared_widged.dart';

class PeopleCounterScreen extends StatelessWidget {
  const PeopleCounterScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final camP = context.watch<CameraProvider>();
    final total = camP.totalPeople;

    return Scaffold(
      appBar: AppBar(title: const Text('People Counter')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            GlassCard(
              borderColor: total > 20 ? AppTheme.danger.withOpacity(0.5) : AppTheme.primary.withOpacity(0.3),
              child: Column(
                children: [
                  const Text('Total occupancy', style: TextStyle(color: AppTheme.textSec, fontSize: 13)),
                  const SizedBox(height: 8),
                  Text('$total',
                      style: TextStyle(
                        color: total > 20 ? AppTheme.danger : AppTheme.primary,
                        fontSize: 64, fontWeight: FontWeight.w800,
                      )),
                  const Text('people currently inside', style: TextStyle(color: AppTheme.textSec, fontSize: 13)),
                  if (total > 20) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(color: AppTheme.danger.withOpacity(0.15), borderRadius: BorderRadius.circular(8)),
                      child: const Text('⚠️  Capacity exceeded', style: TextStyle(color: AppTheme.danger, fontSize: 13, fontWeight: FontWeight.w600)),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text('By Location', style: TextStyle(color: AppTheme.textPri, fontSize: 15, fontWeight: FontWeight.w600)),
            ),
            const SizedBox(height: 12),
            ...camP.cameras.map((cam) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: GlassCard(
                child: Row(
                  children: [
                    Container(
                      width: 44, height: 44,
                      decoration: BoxDecoration(
                        color: cam.status == CameraStatus.offline ? AppTheme.surface2 : AppTheme.info.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(Icons.people_outline, color: cam.status == CameraStatus.offline ? AppTheme.textSec : AppTheme.info, size: 22),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(cam.name, style: const TextStyle(color: AppTheme.textPri, fontWeight: FontWeight.w600)),
                          Text(cam.location, style: const TextStyle(color: AppTheme.textSec, fontSize: 12)),
                        ],
                      ),
                    ),
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () => context.read<CameraProvider>().updatePeopleCount(cam.id, -1),
                          child: Container(
                            width: 28, height: 28,
                            decoration: BoxDecoration(color: AppTheme.danger.withOpacity(0.15), borderRadius: BorderRadius.circular(8)),
                            child: const Icon(Icons.remove, color: AppTheme.danger, size: 16),
                          ),
                        ),
                        SizedBox(
                          width: 44,
                          child: Text('${cam.peopleCount}',
                              textAlign: TextAlign.center,
                              style: const TextStyle(color: AppTheme.textPri, fontSize: 18, fontWeight: FontWeight.w700)),
                        ),
                        GestureDetector(
                          onTap: () => context.read<CameraProvider>().updatePeopleCount(cam.id, 1),
                          child: Container(
                            width: 28, height: 28,
                            decoration: BoxDecoration(color: AppTheme.primary.withOpacity(0.15), borderRadius: BorderRadius.circular(8)),
                            child: const Icon(Icons.add, color: AppTheme.primary, size: 16),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            )),
          ],
        ),
      ),
    );
  }
}