import 'package:flutter/material.dart';
import 'package:smart_security_camera/model/camera_model.dart';
import 'package:smart_security_camera/screens/app_theme.dart';

class StatusDot extends StatelessWidget {
  final CameraStatus status;
  const StatusDot(this.status, {super.key});

  Color get _color {
    switch (status) {
      case CameraStatus.online:    return AppTheme.primary;
      case CameraStatus.recording: return AppTheme.danger;
      case CameraStatus.offline:   return AppTheme.textSec;
      case CameraStatus.motion:    return const Color(0xFFFFB300);
    }
  }

  String get _label {
    switch (status) {
      case CameraStatus.online:    return 'Live';
      case CameraStatus.recording: return 'REC';
      case CameraStatus.offline:   return 'Offline';
      case CameraStatus.motion:    return 'Motion';
    }
  }

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Container(width: 8, height: 8, decoration: BoxDecoration(color: _color, shape: BoxShape.circle)),
      const SizedBox(width: 5),
      Flexible(
        child: Text(
          _label,
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
          style: TextStyle(color: _color, fontSize: 12, fontWeight: FontWeight.w600),
        ),
      ),
    ],
  );
}