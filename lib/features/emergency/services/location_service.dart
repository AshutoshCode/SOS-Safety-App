import 'package:geolocator/geolocator.dart';
import 'package:logger/logger.dart';
import 'dart:async';
import '../../../core/services/service_locator.dart';

class LocationService {
  final Logger _logger = getIt<Logger>();
  StreamSubscription<Position>? _positionStream;

  LocationService();

  /// Request location permission
  Future<bool> requestLocationPermission() async {
    try {
      final permission = await Geolocator.requestPermission();
      final hasPermission = permission == LocationPermission.always ||
          permission == LocationPermission.whileInUse;
      _logger.i('Location permission: $hasPermission');
      return hasPermission;
    } catch (e) {
      _logger.e('Error requesting location permission: $e');
      return false;
    }
  }

  /// Check if location permission is granted
  Future<bool> hasLocationPermission() async {
    try {
      final permission = await Geolocator.checkPermission();
      return permission == LocationPermission.always ||
          permission == LocationPermission.whileInUse;
    } catch (e) {
      _logger.e('Error checking location permission: $e');
      return false;
    }
  }

  /// Get current location
  Future<Position?> getCurrentLocation() async {
    try {
      final hasPermission = await hasLocationPermission();
      if (!hasPermission) {
        _logger.w('Location permission not granted');
        return null;
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );

      _logger.i('Current location: ${position.latitude}, ${position.longitude}');
      return position;
    } catch (e) {
      _logger.e('Error getting current location: $e');
      return null;
    }
  }

  /// Stream continuous location updates (optimized for 30s intervals)
  Stream<Position> streamLocationUpdates({
    Duration updateInterval = const Duration(seconds: 30),
    int distanceFilter = 0, // meters - use 0 for frequent updates
  }) async* {
    try {
      final hasPermission = await hasLocationPermission();
      if (!hasPermission) {
        _logger.w('Location permission not granted');
        return;
      }

      _logger.i('Starting location stream with ${updateInterval.inSeconds}s interval');

      await for (final position in Geolocator.getPositionStream(
        locationSettings: LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: distanceFilter,
          timeLimit: const Duration(seconds: 5),
        ),
      )) {
        yield position;
        _logger.d('Location: ${position.latitude}, ${position.longitude}');
      }
    } catch (e) {
      _logger.e('Error streaming location: $e');
    }
  }

  /// Start continuous location updates (for foreground)
  void startLocationUpdates({
    required Function(Position) onLocationUpdate,
    required Function(dynamic) onError,
    Duration updateInterval = const Duration(seconds: 30),
  }) {
    try {
      _positionStream = Geolocator.getPositionStream(
        locationSettings: LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 0,
          timeLimit: const Duration(seconds: 5),
        ),
      ).listen(
        (position) {
          onLocationUpdate(position);
          _logger.d('Location update: ${position.latitude}, ${position.longitude}');
        },
        onError: (e) {
          onError(e);
          _logger.e('Location stream error: $e');
        },
      );

      _logger.i('Location updates started');
    } catch (e) {
      _logger.e('Error starting location updates: $e');
      onError(e);
    }
  }

  /// Stop continuous location updates
  Future<void> stopLocationUpdates() async {
    try {
      await _positionStream?.cancel();
      _positionStream = null;
      _logger.i('Location updates stopped');
    } catch (e) {
      _logger.e('Error stopping location updates: $e');
    }
  }

  /// Check if location services are enabled
  Future<bool> isLocationServiceEnabled() async {
    return await Geolocator.isLocationServiceEnabled();
  }

  /// Open location settings
  Future<bool> openLocationSettings() async {
    return await Geolocator.openLocationSettings();
  }
}
