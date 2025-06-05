import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class ControlNode extends StatefulWidget {
  const ControlNode({super.key});

  @override
  State<ControlNode> createState() => _ControlNodeState();
}

class _ControlNodeState extends State<ControlNode> {
  var data = [
    {'name' : 'Relay 1', 'loading' : false, 'value' : false},
    {'name' : 'Relay 2', 'loading' : false, 'value' : false},
    {'name' : 'Relay 3', 'loading' : false, 'value' : false},
    {'name' : 'Relay 4', 'loading' : false, 'value' : false},
    {'name' : 'Relay 5', 'loading' : false, 'value' : false},
    {'name' : 'Relay 6', 'loading' : false, 'value' : false},
    {'name' : 'Relay 7', 'loading' : false, 'value' : false},
    {'name' : 'Relay 8', 'loading' : false, 'value' : false},
  ];

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
        Column(
          children: [
            for(var item in data)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SizedBox(
                    child: Text(item['name'].toString()),
                  ),
                  Row(
                    children: [
                      SizedBox(
                        width: 40,
                        height: 10,
                          child: LinearProgressIndicator(
                            value: (item['loading'] as bool) ? null : 1,
                            borderRadius: BorderRadius.circular(5),
                            color: (item['value'] as bool) ? Colors.green : Colors.red,
                          )
                      ),
                      InkWell(
                        onTap: ()async{
                          for(var i = 0;i < 3;i ++){
                            setState(() {
                              item['loading'] = true;
                            });
                            await Future.delayed(const Duration(seconds: 1));
                          }
                          setState(() {
                            item['loading'] = false;
                          });
                          if((item['value'] as bool) == true){
                            item['value'] = false;
                          }else{
                            item['value'] = true;
                          }
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: SvgPicture.asset(
                            'assets/Images/Svg/SmartComm/latch.svg',
                            height: 30,
                         ),
                        ),
                      )
                    ],
                  ),

                ],
              )
          ],
        ),
      ],
    );
  }

}
