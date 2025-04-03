import 'package:flutter/material.dart';
import 'package:gif/gif.dart';

class MyGifPage extends StatefulWidget {
  const MyGifPage({super.key});

  @override
  _MyGifPageState createState() => _MyGifPageState();
}

class _MyGifPageState extends State<MyGifPage> with TickerProviderStateMixin {
  late GifController controller;

  @override
  void initState() {
    super.initState();
    controller = GifController(vsync: this);
    // Set a duration for the animation cycle and start it
    controller.repeat(period: const Duration(seconds: 1)); // Adjust duration as needed
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('GIF Animation Control'),
      ),
      body: Column(
        children: [
          Container(
            color: Colors.grey,
            child: Center(
              child: Gif(
                image: const AssetImage('assets/gif/dp_irr_pump_g.gif'),
                controller: controller,
                autostart: Autostart.loop,
                fps: 30,
              ),
            ),
          ),
          Image.asset('assets/gif/dp_irr_pump_g.gif',repeat: ImageRepeat.repeat,)
        ],
      ),
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}