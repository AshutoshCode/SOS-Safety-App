import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';
import 'package:geolocator/geolocator.dart';
import '../../domain/entities/alert.dart';
import '../../domain/repositories/alert_repository.dart';
import '../../services/location_service.dart';
import '../../services/audio_recorder_service.dart';
import '../../../../core/services/service_locator.dart';

class EmergencyProvider extends ChangeNotifier {
  final AlertRepository _alertRepository = getIt<AlertRepository>();
  final LocationService _locationService = getIt<LocationService>();
  final AudioRecorderService _audioRecorderService = getIt<AudioRecorderService>();
  final Logger _logger = getIt<Logger>();

  Alert? _activeAlert;
  List<Alert> _alertHistory = [];
  bool _isTrackingLocation = false;
  bool _isRecordingAudio = false;
  Position? _currentLocation;
  String? _error;
  bool _isLoading = false;

  // Getters
  Alert? get activeAlert => _activeAlert;
  List<Alert> get alertHistory => _alertHistory;
  bool get isTrackingLocation => _isTrackingLocation;
  bool get isRecordingAudio => _isRecordingAudio;
  Position? get currentLocation => _currentLocation;
  String? get error => _error;
  bool get isLoading => _isLoading;

  EmergencyProvider() {
    _loadAlertHistory();
  }

  /// Load alert history
  Future<void> _loadAlertHistory() async {
    try {
      _alertHistory = await _alertRepository.getAlertHistory();
      notifyListeners();
    } catch (e) {
      _logger.e('Failed to load alert history: $e');
    }
  }

  /// Trigger emergency SOS
  Future<void> triggerSOS() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      // Trigger alert
      _activeAlert = await _alertRepository.triggerEmergencyAlert(
        triggerType: TriggerType.sos,
      );

      // Start tracking location
      await startLocationTracking();

      // Start audio recording
      await startAudioRecording();

      _isLoading = false;
      notifyListeners();

      _logger.i('SOS triggered: ${_activeAlert!.id}');
    } catch (e) {
      _error = 'Failed to trigger SOS: $e';
      _logger.e(_error);
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Start continuous location tracking
  Future<void> startLocationTracking() async {
    if (_activeAlert == null) return;

    try {
      final hasPermission = await _locationService.hasLocationPermission();
      if (!hasPermission) {
        await _locationService.requestLocationPermission();
      }

      _isTrackingLocation = true;
      notifyListeners();

      _locationService.startLocationUpdates(
        onLocationUpdate: (position) {
          _currentLocation = position;
          _alertRepository.updateAlertLocation(
            _activeAlert!.id,
            position.latitude,
            position.longitude,
          );
          notifyListeners();
        },
        onError: (e) {
          _logger.e('Location tracking error: $e');
        },
      );

      _logger.i('Location tracking started');
    } catch (e) {
      _logger.e('Failed to start location tracking: $e');
    }
  }

  /// Stop location tracking
  Future<void> stopLocationTracking() async {
    try {
      await _locationService.stopLocationUpdates();
      _isTrackingLocation = false;
      notifyListeners();
      _logger.i('Location tracking stopped');
    } catch (e) {
      _logger.e('Failed to stop location tracking: $e');
    }
  }

  /// Start audio recording
  Future<void> startAudioRecording() async {
    try {
      final success = await _audioRecorderService.startRecording();
      if (success) {
        _isRecordingAudio = true;
        notifyListeners();
        _logger.i('Audio recording started');
      }
    } catch (e) {
      _logger.e('Failed to start audio recording: $e');
    }
  }

  /// Stop audio recording and upload
  Future<void> stopAudioRecording() async {
    try {
      final path = await _audioRecorderService.stopRecording();
      _isRecordingAudio = false;

      if (path != null && _activeAlert != null) {
        // TODO: Upload to Firebase Storage and get URL
        // For now, just update with local path
        await _alertRepository.updateAlertAudioUrl(_activeAlert!.id, path);
        _logger.i('Audio recording uploaded: $path');
      }

      notifyListeners();
    } catch (e) {
      _logger.e('Failed to stop audio recording: $e');
    }
  }

  /// Resolve active alert
  Future<void> resolveAlert() async {
    if (_activeAlert == null) return;

    try {
      _isLoading = true;
      notifyListeners();

      await stopLocationTracking();
      await stopAudioRecording();

      await _alertRepository.resolveAlert(_activeAlert!.id);
      _activeAlert = null;

      await _loadAlertHistory();

      _isLoading = false;
      notifyListeners();

      _logger.i('Alert resolved');
    } catch (e) {
      _error = 'Failed to resolve alert: $e';
      _logger.e(_error);
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _locationService.stopLocationUpdates();
    _audioRecorderService.dispose();
    super.dispose();
  }
}
