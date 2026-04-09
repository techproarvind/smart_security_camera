import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:get/get.dart';
import 'package:smart_security_camera/model/recording_model.dart';
import 'package:smart_security_camera/services/recording_service.dart';

class RecordingController extends GetxController {
  static RecordingController get to => Get.find();

  final _recordings  = <RecordingModel>[].obs;
  final _isRecording = false.obs;
  final _isUploading = false.obs;

  List<RecordingModel> get recordings  => _recordings;
  bool get isRecording                 => _isRecording.value;
  bool get isUploading                 => _isUploading.value;

  Future<void> startRecording(MediaStream stream) async {
    await RecordingService.instance.startRecording(stream);
    _isRecording.value = true;
  }

  Future<void> stopRecording({
    required String cameraId,
    required String cameraName,
  }) async {
    _isRecording.value = false;
    _isUploading.value = true;

    final rec = await RecordingService.instance.stopAndSave(
      cameraId:   cameraId,
      cameraName: cameraName,
    );

    _isUploading.value = false;

    if (rec != null) {
      _recordings.insert(0, rec);
      Get.snackbar(
        'Recording Saved',
        '${rec.durationLabel} • ${rec.sizeLabel}',
        snackPosition: SnackPosition.BOTTOM,
      );
    } else {
      Get.snackbar(
        'Upload Failed',
        'Could not save recording. Check your connection.',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> loadRecordings({String? cameraId}) async {
    final list = await RecordingService.instance.fetchRecordings(cameraId: cameraId);
    _recordings.assignAll(list);
  }

  Future<void> deleteRecording(RecordingModel rec) async {
    await RecordingService.instance.deleteRecording(rec);
    _recordings.remove(rec);
  }
}
