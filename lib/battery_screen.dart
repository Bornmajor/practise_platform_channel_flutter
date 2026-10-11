import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:practise_platform_channel_flutter/battery_info.dart';
import 'package:practise_platform_channel_flutter/battery_state.dart';

class BatteryScreen extends StatefulWidget {
  const BatteryScreen({super.key});

  @override
  State<BatteryScreen> createState() => _BatteryScreenState();
}

class _BatteryScreenState extends State<BatteryScreen> {
  static const platform = MethodChannel('com.example.practise_platform_channel_flutter/battery');
  // int? _batteryLevel;
  // bool _isLoading = true;
  // String? _errorMessage;

  //Create single state variable default Loading
  BatteryState _state = BatteryLoading();

  @override
  void initState() {
    super.initState();
    // Fetch battery as soon as screen mounts
    _fetchBatteryLevel();
  }

  Future<void> _fetchBatteryLevel() async {
    try {
      final int result = await platform.invokeMethod('getBatteryLevel');
      // setState(() {
      //   _batteryLevel = result;
      //   _isLoading = false;
      // });
      setState(() {
        _state = BatterySuccess(BatteryInfo(level: result));
      });
    } on PlatformException catch (e) {
      // setState(() {
      //   _isLoading = false;
      //   _errorMessage = e.message;
      // });
      setState(() {
        _state = BatteryError(
          e.message ?? "Error while fetching battery level",
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Device Status')),
      body: Center(
        child: switch (_state) {
          BatteryLoading() => const CircularProgressIndicator(),
          BatteryError(message: final message) => Text(
            message,
            style: Theme.of(context).textTheme.bodyLarge
                ?.copyWith(color: Theme.of(context).colorScheme.error),
          ),
          BatterySuccess(info: final info) => Text(
            'Battery level: ${info.level}%',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        },
      ),
    );
  }
}
