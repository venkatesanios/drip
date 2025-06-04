import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class ControlNode extends StatefulWidget {
  const ControlNode({super.key});

  @override
  State<ControlNode> createState() => _ControlNodeState();
}

class _ControlNodeState extends State<ControlNode> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Control'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: output(),
          )

        ],
      ),
    );
  }

  Widget output(){
    return Column(
      spacing: 10,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Output',
          style: TextStyle(
              fontSize: 14
          ),
        ),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: Theme.of(context).primaryColorLight.withValues(alpha: 0.05)
          ),
          child: Column(
            children: [
              for(var relay = 0;relay < 8;relay++)
                ListTile(
                  shape: relay == 7 ? null : const Border(bottom: BorderSide(width: 1, color: Colors.black12)),
                  leading: SvgPicture.asset(
                    'assets/Images/Svg/SmartComm/latch.svg',
                    height: 50,
                  ),
                  title:  Text(
                    "Relay ${relay+1}",
                    style: const TextStyle(fontSize: 16),
                  ),
                  trailing: Switch(
                    value: true,
                    activeColor: Colors.blueAccent,
                    onChanged: (value) {
                      print('value ==> $value');
                      setState(() {
                      });
                    },
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
