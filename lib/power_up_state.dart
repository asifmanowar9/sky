import 'dart:async';
import 'power_up_component.dart';

class PowerUpState {
  bool rapidFireActive = false;
  bool shieldActive = false;
  Timer? rapidFireTimer;
  Timer? shieldTimer;

  // Callback for updating bullet fire rate
  void Function(bool isRapidFire)? onRapidFireChanged;

  // Stream controller for power-up state updates
  final StreamController<PowerUpState> _stateController =
      StreamController<PowerUpState>.broadcast();

  Stream<PowerUpState> get stateStream => _stateController.stream;

  // Duration constants
  static const Duration rapidFireDuration = Duration(seconds: 5);
  static const Duration shieldDuration = Duration(seconds: 8);

  void activateRapidFire() {
    // Cancel existing timer if active
    rapidFireTimer?.cancel();

    // Activate rapid fire
    rapidFireActive = true;
    _notifyStateChange();

    // Notify callback to update bullet fire rate
    onRapidFireChanged?.call(true);

    // Set timer for automatic deactivation
    rapidFireTimer = Timer(rapidFireDuration, () {
      rapidFireActive = false;
      rapidFireTimer = null;
      _notifyStateChange();

      // Notify callback to restore normal fire rate
      onRapidFireChanged?.call(false);
    });
  }

  void activateShield() {
    // Cancel existing timer if active
    shieldTimer?.cancel();

    // Activate shield
    shieldActive = true;
    _notifyStateChange();

    // Set timer for automatic deactivation
    shieldTimer = Timer(shieldDuration, () {
      shieldActive = false;
      shieldTimer = null;
      _notifyStateChange();
    });
  }

  void deactivate(PowerUpType type) {
    switch (type) {
      case PowerUpType.rapidFire:
        rapidFireTimer?.cancel();
        rapidFireTimer = null;
        rapidFireActive = false;
        // Notify callback to restore normal fire rate
        onRapidFireChanged?.call(false);
        break;
      case PowerUpType.shield:
        shieldTimer?.cancel();
        shieldTimer = null;
        shieldActive = false;
        break;
    }
    _notifyStateChange();
  }

  // Consume shield (called when it prevents a life loss)
  void consumeShield() {
    if (shieldActive) {
      deactivate(PowerUpType.shield);
    }
  }

  void reset() {
    rapidFireTimer?.cancel();
    shieldTimer?.cancel();
    rapidFireTimer = null;
    shieldTimer = null;

    // Restore normal fire rate if rapid fire was active
    if (rapidFireActive) {
      onRapidFireChanged?.call(false);
    }

    rapidFireActive = false;
    shieldActive = false;
    _notifyStateChange();
  }

  void _notifyStateChange() {
    _stateController.add(this);
  }

  void dispose() {
    rapidFireTimer?.cancel();
    shieldTimer?.cancel();
    _stateController.close();
  }
}
