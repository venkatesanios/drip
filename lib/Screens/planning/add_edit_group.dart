import 'dart:convert'; // For JSON encoding
import 'package:flutter/material.dart';
import '../../Models/valve_group_model.dart';
import '../../modules/IrrigationProgram/view/program_library.dart';
import '../../repository/repository.dart';
import '../../services/http_service.dart';
import '../../services/mqtt_service.dart';
import '../../utils/snack_bar.dart';
class AddEditValveGroup extends StatefulWidget {
  final String? selectedline;
  final int? selectedgroupindex;
  final bool editcheck;
  final List<ValveGroup>? valveGroupdata;
  valveGroupData groupdata;


  AddEditValveGroup({this.selectedline,this.selectedgroupindex,required this.editcheck, this.valveGroupdata, required this.groupdata});

  @override
  _AddEditValveGroupState createState() => _AddEditValveGroupState();
}

class _AddEditValveGroupState extends State<AddEditValveGroup> {
  final TextEditingController _controller = TextEditingController();
  IrrigationLine? selectedIrrigationLine;  // Keep track of selected irrigation line
  List<Valve> selectedValves = [];
   int selctlineindex = 0;
  @override
  void initState() {
    super.initState();

    selctlineindex = getIrrigationLineIndexByName(widget.selectedline ?? '');

  selectedValves =  widget.valveGroupdata?[widget.selectedgroupindex!].valve ?? [];
     // Set a default irrigation line if available
    _controller.text = widget.valveGroupdata?[widget.selectedgroupindex!].groupName ?? '';
    selectedIrrigationLine = widget.groupdata?.defaultData.irrigationLine[0];
   }

  @override
  Widget build(BuildContext context) {
    print('selectedValves${selectedValves.toString()}');
    print('widget.selectedgroupindex!${widget.selectedgroupindex!}');
    print('_controller.text${_controller.text}');
    print('selectedIrrigationLine${selectedIrrigationLine?.toJson()}');

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
                  print(" drop down selctlineindex  $selctlineindex");
                  print("drop down  selectedIrrigationLine  ${selectedIrrigationLine?.toJson()}");
                });
              },
              items: widget.groupdata!.defaultData.irrigationLine.map((IrrigationLine line) {
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
                  return ChoiceChip(
                    label: Text(valve.name),
                    selected: selectedValves.contains(valve),
                    onSelected: (bool selected) {
                      setState(() {
                        if (selected) {
                          selectedValves.add(valve); // Add valve to selection
                        } else {
                          selectedValves.remove(valve); // Remove valve from selection
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
              child:  Text('Create Valve Group',style: TextStyle(color: selectedValves.isEmpty ? Theme.of(context).primaryColorDark  : Colors.white),),
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
        print('getIrrigationLineIndexByName  select index $i');
        return i;
      }
    }
    return 0;
  }

  // Function to generate the valveGroup JSON
  generateValveGroup() {
    print("widget.selectedgroupindex! ${widget.selectedgroupindex!}");
    print("widget.ValveGrouplist! ${widget.valveGroupdata?.toString()}");
    ValveGroup vdate = ValveGroup(objectId: widget.groupdata!.defaultData.irrigationLine[selctlineindex].objectId, groupName: _controller.text, irrigationLineName: widget.groupdata!.defaultData.irrigationLine[selctlineindex].name,  sNo: widget.groupdata!.defaultData.irrigationLine[selctlineindex].sNo, name: widget.groupdata!.defaultData.irrigationLine[selctlineindex].name, objectName: widget.groupdata!.defaultData.irrigationLine[selctlineindex].objectName, valve: selectedValves);
    widget.editcheck ? widget.groupdata!.valveGroup![widget.selectedgroupindex!] = vdate : widget.groupdata!.valveGroup?.add(vdate);
   widget.editcheck ? widget.valveGroupdata!.removeAt(widget.selectedgroupindex!) : null;
    widget.valveGroupdata?.add(vdate);
     createvalvegroup(vdate);
  }

  createvalvegroup(ValveGroup data) async {

    final Repository repository = Repository(HttpService());
    Map<String, dynamic> body = {
      "userId": 4,
      "controllerId": 1,
      "valveGroup":  widget.valveGroupdata?.map((x) => x.toJson()).toList() ?? [],
       "createUser": 4
    };

    var getUserDetails = await repository.createUserValveGroup(body);
    var jsonDataResponse = jsonDecode(getUserDetails.body);
    print(jsonDataResponse);
    GlobalSnackBar.show(context, jsonDataResponse['message'], jsonDataResponse.statusCode);

  }
}







