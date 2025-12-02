import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../StateManagement/mqtt_payload_provider.dart';
import '../../../services/communication_service.dart';

class ProgramPreview extends StatefulWidget {
  const ProgramPreview({super.key});
  @override
  State<ProgramPreview> createState() => _ProgramPreviewState();
}

class _ProgramPreviewState extends State<ProgramPreview> {
  @override
  void initState() {
    super.initState();

    Future.microtask(() async {
      final payload = jsonEncode({"sentSms": "program_view"});
      await context.read<CommunicationService>().sendCommand(
        serverMsg: '',
        payload: payload,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text("Program Preview", style: TextStyle(fontSize: 16)),
      ),

      body: Column(
        children: [
          Expanded(
            child: Selector<MqttPayloadProvider, String?>(
              selector: (_, provider) => provider.getProgramPreview(),
              builder: (_, status, __) {
                if (status == null) {
                  return const Center(child: CircularProgressIndicator());
                }

                final List<String> items = status.split(',').map((e) => e.trim()).toList();

                return ListView.builder(
                  itemCount: items.length,
                  itemBuilder: (_, index) {
                    return ListTile(
                      leading: Text("${index + 1}"),
                      title: Text(getLabelByIndex(index)),
                      trailing: Text(items[index]),
                    );
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Selector<MqttPayloadProvider, String?>(
              selector: (_, provider) => provider.getSequencePreview(),
              builder: (_, status, __) {
                if (status == null) {
                  return const Center(child: CircularProgressIndicator());
                }

                final List<String> items = status.split(',').map((e) => e.trim()).toList();

                return ListView.builder(
                  itemCount: items.length,
                  itemBuilder: (_, index) {
                    return ListTile(
                      leading: Text("${index + 1}"),
                      title: Text(items[index]),
                    );
                  },
                );


              },
            ),
          ),
        ],
      ),
    );
  }

  String getLabelByIndex(int index) {
    switch (index) {
      case 0:
        return "Program Name";
      case 1:
        return "Valve Status";
      case 2:
        return "Program Mode";
      case 3:
        return "Fertilizer Mode";
      case 4:
        return "Decide Last";
      case 5:
        return "Decide FB Last";
      case 6:
        return "Valve delay (MM)";
      case 7:
        return "Valve delay (SS)";
      case 8:
        return "fbk del min";
      case 9:
        return "fbk del min";
      case 10:
        return "cyccomrstOnOf";
      case 11:
        return "cyccomReHr";
      case 12:
        return "cyccomReMin";
      case 13:
        return "cyccomReSec";
      case 14:
        return "cycrestartonof";
      case 15:
        return "programselection";
      case 16:
        return "startfrom";
      case 17:
        return "daycounthr";
      default:
        return "Value $index";
    }
  }


}