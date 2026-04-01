import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';
import 'package:logger/logger.dart';
import 'dart:io';
import '../../../core/services/service_locator.dart';

class AudioRecorderService {
  final AudioRecorder _recorder = AudioRecorder();
  final Logger _logger = getIt<Logger>();

  String? _currentRecordingPath;
  bool _isRecording = false;

  bool get isRecording => _isRecording;
  String? get currentRecordingPath => _currentRecordingPath;

  /// Request microphone permission
  Future<bool> requestMicrophonePermission() async {
    try {
      final hasPermission = await _recorder.hasPermission();
      _logger.i('Microphone permission: $hasPermission');
      return hasPermission;
    } catch (e) {
      _logger.e('Error requesting microphone permission: $e');
      return false;
    }
  }

  /// Check if microphone permission is granted
  Future<bool> hasMicrophonePermission() async {
    try {
      return await _recorder.hasPermission();
    } catch (e) {
      _logger.e('Error checking microphone permission: $e');
      return false;
    }
  }

  /// Start audio recording
  Future<bool> startRecording() async {
    try {
      final hasPermission = await hasMicrophonePermission();
      if (!hasPermission) {
        _logger.w('Microphone permission not granted');
        return false;
      }

      // Get app documents directory
      final appDir = await getApplicationDocumentsDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      _currentRecordingPath = '${appDir.path}/emergency_audio_$timestamp.wav';

      await _recorder.start(
        RecordConfig(
          encoder: AudioEncoder.wav,
          sampleRate: 16000,
          bitRate: 128000,
          numChannels: 1,
        ),
        path: _currentRecordingPath!,
      );

      _isRecording = true;
      _logger.i('Audio recording started: $_currentRecordingPath');
      return true;
    } catch (e) {
      _logger.e('Error starting recording: $e');
      _isRecording = false;
      return false;
    }
  }

  /// Stop audio recording and return path
  Future<String?> stopRecording() async {
    try {
      final path = await _recorder.stop();
      _isRecording = false;
      _currentRecordingPath = null;
      _logger.i('Audio recording stopped: $path');
      return path;
    } catch (e) {
      _logger.e('Error stopping recording: $e');
      _isRecording = false;
      return null;
    }
  }

  /// Delete recording file
  Future<bool> deleteRecording(String path) async {
    try {
      final file = File(path);
      if (await file.exists()) {
        await file.delete();
        _logger.i('Recording deleted: $path');
        return true;
      }
      return false;
    } catch (e) {
      _logger.e('Error deleting recording: $e');
      return false;
    }
  }

  /// Pause recording
  Future<bool> pauseRecording() async {
    try {
      await _recorder.pause();
      _logger.i('Audio recording paused');
      return true;
    } catch (e) {
      _logger.e('Error pausing recording: $e');
      return false;
    }
  }

  /// Resume recording
  Future<bool> resumeRecording() async {
    try {
      await _recorder.resume();
      _logger.i('Audio recording resumed');
      return true;
    } catch (e) {
      _logger.e('Error resuming recording: $e');
      return false;
    }
  }

  /// Dispose recorder resources
  Future<void> dispose() async {
    try {
      await _recorder.dispose();
      _logger.i('Audio recorder disposed');
    } catch (e) {
      _logger.e('Error disposing recorder: $e');
    }
  }
}
