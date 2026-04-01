import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../providers/emergency_provider.dart';
import '../../domain/entities/alert.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // Check for active alert on app start
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkActiveAlert();
    });
  }

  void _checkActiveAlert() {
    final provider = context.read<EmergencyProvider>();
    if (provider.activeAlert != null) {
      _showAlertDetails(provider.activeAlert!);
    }
  }

  void _showSosConfirmation() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Trigger Emergency Alert?'),
        content: const Text(
          'This will send emergency alerts to your contacts and start location tracking.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _triggerSos();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('YES, EMERGENCY'),
          ),
        ],
      ),
    );
  }

  void _triggerSos() async {
    await context.read<EmergencyProvider>().triggerSOS();
    if (mounted && context.read<EmergencyProvider>().activeAlert != null) {
      _showAlertDetails(context.read<EmergencyProvider>().activeAlert!);
    }
  }

  void _showAlertDetails(Alert alert) {
    showModalBottomSheet(
      context: context,
      isDismissible: false,
      enableDrag: false,
      builder: (context) => AlertDetailsSheet(alert: alert),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Emergency Alert'),
        actions: [
          IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () {
              showMenu(
                context: context,
                position: const RelativeRect.fromLTRB(100, 50, 0, 0),
                items: [
                  PopupMenuItem(
                    child: const Text('Contacts'),
                    onTap: () => context.push('/contacts'),
                  ),
                  PopupMenuItem(
                    child: const Text('Settings'),
                    onTap: () => context.push('/settings'),
                  ),
                  PopupMenuItem(
                    child: const Text('History'),
                    onTap: () => context.push('/alerts-history'),
                  ),
                  const PopupMenuDivider(),
                  PopupMenuItem(
                    child: const Text('Sign Out'),
                    onTap: () {
                      // Sign out logic
                      context.go('/login');
                    },
                  ),
                ],
              );
            },
          ),
        ],
      ),
      body: Consumer<EmergencyProvider>(
        builder: (context, provider, _) {
          return Stack(
            children: [
              // Main content
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (provider.activeAlert == null) ...[
                        Icon(
                          Icons.sos,
                          size: 80,
                          color: Colors.grey[300],
                        ),
                        const SizedBox(height: 24),
                        Text(
                          'Ready for Emergency',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Tap the button below to trigger emergency alert',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey[600],
                          ),
                        ),
                      ] else ...[
                        const CircularProgressIndicator(),
                        const SizedBox(height: 24),
                        Text(
                          'Alert Active',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Sending alerts to contacts...',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 32),
                        if (provider.isTrackingLocation) ...[
                          Icon(
                            Icons.location_on,
                            color: Colors.green[600],
                            size: 24,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Location tracking active',
                            style: TextStyle(color: Colors.green[600]),
                          ),
                        ],
                        const SizedBox(height: 16),
                        if (provider.isRecordingAudio) ...[
                          Icon(
                            Icons.mic,
                            color: Colors.red[600],
                            size: 24,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Audio recording active',
                            style: TextStyle(color: Colors.red[600]),
                          ),
                        ],
                      ],
                    ],
                  ),
                ),
              ),

              // SOS Button (fixed at bottom)
              if (provider.activeAlert == null)
                Positioned(
                  bottom: 48,
                  left: 24,
                  right: 24,
                  child: GestureDetector(
                    onLongPress: provider.isLoading ? null : _showSosConfirmation,
                    child: Container(
                      height: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.red,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.red.withOpacity(0.5),
                            blurRadius: 20,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: Center(
                        child: provider.isLoading
                            ? const CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        )
                            : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.sos,
                              color: Colors.white,
                              size: 48,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Hold for SOS',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

              // Error message
              if (provider.error != null)
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: Material(
                    color: Colors.red,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        provider.error!,
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

/// Alert details modal sheet
class AlertDetailsSheet extends StatelessWidget {
  final Alert alert;

  const AlertDetailsSheet({
    Key? key,
    required this.alert,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<EmergencyProvider>(
      builder: (context, provider, _) {
        return Container(
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 24,
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Emergency Alert Active',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'ACTIVE',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                'Alert ID: ${alert.id.substring(0, 8)}...',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 8),
              Text(
                'Time: ${alert.createdAt.toString().split('.').first}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 24),
              Text(
                'Status:',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(
                    provider.isTrackingLocation
                        ? Icons.check_circle
                        : Icons.radio_button_unchecked,
                    color: provider.isTrackingLocation
                        ? Colors.green
                        : Colors.grey,
                  ),
                  const SizedBox(width: 8),
                  Text('Location Tracking'),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    provider.isRecordingAudio
                        ? Icons.check_circle
                        : Icons.radio_button_unchecked,
                    color:
                    provider.isRecordingAudio ? Colors.green : Colors.grey,
                  ),
                  const SizedBox(width: 8),
                  Text('Audio Recording'),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    alert.contactsNotified.isNotEmpty
                        ? Icons.check_circle
                        : Icons.radio_button_unchecked,
                    color: alert.contactsNotified.isNotEmpty
                        ? Colors.green
                        : Colors.grey,
                  ),
                  const SizedBox(width: 8),
                  Text('${alert.contactsNotified.length} Contacts Notified'),
                ],
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: provider.isLoading
                      ? null
                      : () {
                    provider.resolveAlert();
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: provider.isLoading
                      ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                      : const Text('Resolve Alert'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
