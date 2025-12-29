import 'package:flutter/material.dart';

import '../../../view_models/customer/customer_screen_controller_view_model.dart';

class BluetoothScanTile extends StatefulWidget {
  final CustomerScreenControllerViewModel vm;

  const BluetoothScanTile({super.key, required this.vm});

  @override
  State<BluetoothScanTile> createState() => _BluetoothScanTileState();
}

class _BluetoothScanTileState extends State<BluetoothScanTile>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _rotationAnimation;
  bool isScanning = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );
    _rotationAnimation = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.linear,
      ),
    );

    widget.vm.blueService.onDeviceFound = stopScan;
  }

  Future<void> startScan() async {
    if (isScanning) return;
    setState(() {
      isScanning = true;
    });
    _controller.repeat();
    await widget.vm.blueService.getDevices(widget.vm.mySiteList.data[widget.vm.sIndex].master[widget.vm.mIndex].deviceId);
    setState(() {
      isScanning = false;
    });
    _controller.stop();
  }

  void stopScan() {
    if (!mounted) return;

    setState(() {
      isScanning = false;
    });

    _controller.stop();
  }

  @override
  void dispose() {
    widget.vm.blueService.onDeviceFound = null;
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      dense: true,
      visualDensity: VisualDensity.compact,
      contentPadding: EdgeInsets.zero,
      title: const Text(
        "Scan for Bluetooth Devices and Connect",
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
      ),
      trailing: RotationTransition(
        turns: _rotationAnimation,
        child: IconButton(
          icon: Icon(
            Icons.refresh_outlined,
            color: isScanning ? Colors.blue : Colors.black,
          ),
          onPressed: startScan,
        ),
      ),
    );
  }
}