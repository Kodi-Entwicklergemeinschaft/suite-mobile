import 'package:common_components/common_components.dart';
import 'package:flutter/material.dart';
import 'package:upgrader/upgrader.dart';

// Flip to true to enable the in-app update gate.
const bool _kUpgraderEnabled = false;

/// Full-screen update gate. When a newer version is available on the store
/// the entire app is covered by [AppUpdateOverlay] — the user can only tap
/// "Update Now". Uses a Stack so GoRouter route replacements cannot dismiss it.
class AppUpdateGate extends StatefulWidget {
  const AppUpdateGate({super.key, required this.child});

  final Widget child;

  @override
  State<AppUpdateGate> createState() => _AppUpdateGateState();
}

class _AppUpdateGateState extends State<AppUpdateGate> {
  late final Upgrader _upgrader;

  @override
  void initState() {
    super.initState();
    if (_kUpgraderEnabled) {
      _upgrader = Upgrader(
        durationUntilAlertAgain: Duration.zero,
        debugLogging: true,
      );
      _upgrader.initialize();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_kUpgraderEnabled) return widget.child;

    return StreamBuilder<UpgraderState>(
      initialData: _upgrader.state,
      stream: _upgrader.stateStream,
      builder: (context, snapshot) {
        final needsUpdate = snapshot.data?.versionInfo != null &&
            _upgrader.shouldDisplayUpgrade();

        return Stack(
          children: [
            widget.child,
            if (needsUpdate)
              Positioned.fill(
                child: AppUpdateOverlay(
                  onUpdate: _upgrader.sendUserToAppStore,
                ),
              ),
          ],
        );
      },
    );
  }
}
