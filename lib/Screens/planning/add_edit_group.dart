import 'dart:convert'; // For JSON encoding
import 'package:flutter/material.dart';
import '../../Models/valve_group_model.dart';
import '../../repository/repository.dart';
import '../../services/http_service.dart';
import '../../utils/snack_bar.dart';

class AddEditValveGroup extends StatefulWidget {
  final String? selectedline;
  final int? selectedgroupindex;
  final bool editcheck;
  final int userId;
  final int controllerId;
  final List<ValveGroup>? valveGroupdata;
  valveGroupData groupdata;

  AddEditValveGroup(
      {this.selectedline,
      this.selectedgroupindex,
      required this.editcheck,
      this.valveGroupdata,
      required this.groupdata,
      required this.userId,
      required this.controllerId});

  @override
  _AddEditValveGroupState createState() => _AddEditValveGroupState();
}

class _AddEditValveGroupState extends State<AddEditValveGroup> {
  final TextEditingController _controller = TextEditingController();
  IrrigationLine?
      selectedIrrigationLine; // Keep track of selected irrigation line
  List<Valve> selectedValves = [];
  List<double> selectedvalvesno = [];
  int selctlineindex = 0;
  @override
  void initState() {
    super.initState();
    print("valvegroup init ${widget.valveGroupdata}");
    selctlineindex = getIrrigationLineIndexByName(widget.selectedline ?? '');
    if (widget.valveGroupdata != null &&
        widget.valveGroupdata!.isNotEmpty &&
        widget.editcheck) {
       selectedValves =
          widget.valveGroupdata?[widget.selectedgroupindex!].valve ?? [];
      selectedvalvesno = widget.valveGroupdata![widget.selectedgroupindex!].valve.map((e) => e.sNo).toList();
      _controller.text =
          widget.valveGroupdata?[widget.selectedgroupindex!].groupName ?? '';
       double selectedIrrigationLinesrno = widget.valveGroupdata![widget.selectedgroupindex!].sNo;

         selectedIrrigationLine = widget.groupdata?.defaultData.irrigationLine
          .firstWhere(
            (line) => line.sNo == selectedIrrigationLinesrno,
       );
     }
    else
      {
        selectedIrrigationLine = widget.groupdata?.defaultData.irrigationLine[0];
      }
  }

  @override
  Widget build(BuildContext context) {

     return Scaffold(
      appBar: AppBar(
        title: const Text('Add Edit Valve Group'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Select Irrigation Line
            const Text(
              'Group Name:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            TextFormField(
              controller: _controller,
              decoration: const InputDecoration(
                labelText: 'Enter text',
                // border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter some text';
                }
                return null;
              },
            ),
            const SizedBox(height: 8),
            const Text(
              'Select Irrigation Line:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            DropdownButton<IrrigationLine>(
              hint: Text('Choose an irrigation line'),
              value: selectedIrrigationLine,
              onChanged: (IrrigationLine? newValue) {
                setState(() {
                  selctlineindex = getIrrigationLineIndexByName(newValue!.name);
                  selectedIrrigationLine = newValue;
                  selectedValves.clear();

                });
              },
              items: widget.groupdata!.defaultData.irrigationLine
                  .map((IrrigationLine line) {
                return DropdownMenuItem<IrrigationLine>(
                  value: line,
                  child: Text(line.name),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            if (selectedIrrigationLine != null) ...[
              const Text(
                'Select Valves:',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8.0,
                runSpacing: 4.0,
                children: selectedIrrigationLine!.valve.map((Valve valve) {
                  for (var e in selectedValves) {
                    print(e.toJson());
                  }
                   return ChoiceChip(
                    label: Text(valve.name),
                    selected: selectedvalvesno.contains(valve.sNo),
                    onSelected: (bool selected) {
                      setState(() {
                         if (selected) {
                          if (!selectedValves.contains(valve)) {
                            selectedValves.add(valve);
                            selectedvalvesno.add(valve.sNo);
                          } // Add valve to selection
                        } else {
                          selectedValves
                              .remove(valve); // Remove valve from selection
                          selectedvalvesno.remove(valve.sNo);
                        }
                      });
                    },
                  );
                }).toList(),
              ),
            ],
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: selectedValves.isNotEmpty
                  ? () {
                      // Generate valveGroup JSON
                      generateValveGroup();

                      // Display a confirmation message
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Valve group created!')),
                      );
                    }
                  : null,
              child: Text(
                'Create Valve Group',
                style: TextStyle(
                    color: selectedValves.isEmpty
                        ? Theme.of(context).primaryColorDark
                        : Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  int getIrrigationLineIndexByName(String irrigationLineName) {
    var defaultData = widget.groupdata!.defaultData;
    for (int i = 0; i < defaultData.irrigationLine.length; i++) {
      if (defaultData.irrigationLine[i].name == irrigationLineName) {
        return i;
      }
    }
    return 0;
  }

  // Function to generate the valveGroup JSON
  generateValveGroup() {
    String groupid = 'VG.${widget.valveGroupdata!.length + 1}';
    groupid = widget.editcheck
        ? '${widget.groupdata!.valveGroup![widget.selectedgroupindex!].groupID}'
        : groupid;
    ValveGroup vdate = ValveGroup(
        groupID: groupid,
        objectId: widget
            .groupdata!.defaultData.irrigationLine[selctlineindex].objectId,
        groupName: _controller.text,
        irrigationLineName:
            widget.groupdata!.defaultData.irrigationLine[selctlineindex].name,
        sNo: widget.groupdata!.defaultData.irrigationLine[selctlineindex].sNo,
        name: widget.groupdata!.defaultData.irrigationLine[selctlineindex].name,
        objectName: widget
            .groupdata!.defaultData.irrigationLine[selctlineindex].objectName,
        valve: selectedValves);
    widget.editcheck
        ? widget.groupdata!.valveGroup![widget.selectedgroupindex!] = vdate
        : widget.groupdata!.valveGroup?.add(vdate);

     createvalvegroup(vdate);
  }

  createvalvegroup(ValveGroup data) async {
    final Repository repository = Repository(HttpService());
    Map<String, dynamic> body = {
      "userId": widget.userId,
      "controllerId": widget.controllerId,
      "valveGroup":
          widget.valveGroupdata?.map((x) => x.toJson()).toList() ?? [],
      "createUser": widget.userId
    };

    var getUserDetails = await repository.createUserValveGroup(body);
    var jsonDataResponse = jsonDecode(getUserDetails.body);
     GlobalSnackBar.show(
        context, jsonDataResponse['message'], jsonDataResponse['code']);
  }
}
