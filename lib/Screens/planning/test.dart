import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gif/gif.dart';

class MyGifPage extends StatefulWidget {
  @override
  _MyGifPageState createState() => _MyGifPageState();
}

class _MyGifPageState extends State<MyGifPage> with TickerProviderStateMixin {
  late GifController controller;

  @override
  void initState() {
    super.initState();
    controller = GifController(vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('GIF Animation Control'),
      ),
      body: Container(color: Colors.grey, child: Center(child: Gif(image: AssetImage('assets/gif/dp_irr_pump_g.gif'), fps: 30,  autostart: Autostart.loop,controller: controller,),))
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}
