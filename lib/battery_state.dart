import 'package:practise_platform_channel_flutter/battery_info.dart';

sealed class BatteryState {}

class BatteryLoading extends BatteryState {}

class BatterySuccess extends BatteryState {
  final BatteryInfo info;
  BatterySuccess(this.info);
}

class BatteryError extends BatteryState {
  final String message;
  BatteryError(this.message);
}
