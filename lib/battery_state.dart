sealed class BatteryState {}

class BatteryLoading extends BatteryState {}

class BatterySuccess extends BatteryState {
  final int level;
  BatterySuccess(this.level);
}

class BatteryError extends BatteryState {
  final String message;
  BatteryError(this.message);
}
