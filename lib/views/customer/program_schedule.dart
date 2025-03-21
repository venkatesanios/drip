import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:oro_drip_irrigation/modules/IrrigationProgram/view/program_library.dart';
import 'package:oro_drip_irrigation/Screens/planning/fiterbackwash.dart';
import 'package:oro_drip_irrigation/modules/calibration/view/calibration_screen.dart';
import 'package:oro_drip_irrigation/modules/fertilizer_set/view/fertilizer_Set_screen.dart';
import 'package:oro_drip_irrigation/modules/global_limit/view/global_limit_screen.dart';

import '../../Constants/properties.dart';
import '../../Screens/Constant/api_in_constant.dart';
import '../../modules/Preferences/view/preference_main_screen.dart';
import '../../modules/SystemDefinitions/view/system_definition_screen.dart';
import '../../Screens/planning/frost_productionScreen.dart';
import '../../Screens/planning/names_form.dart';
import '../../Screens/planning/planningwatersource.dart';
import '../../Screens/planning/valve_group_screen.dart';
import '../../Screens/planning/virtual_screen.dart';
import '../../repository/repository.dart';
import '../../services/http_service.dart';


class ProgramSchedule extends StatefulWidget {
  const ProgramSchedule({
    super.key,
    required this.customerID,
    required this.controllerID,
    required this.siteName,
    required this.imeiNumber,
    required this.userId, required this.groupId, required this.categoryId,
  });

  final int userId, customerID, controllerID, groupId, categoryId;
  final String siteName, imeiNumber;

  @override
  State<ProgramSchedule> createState() => _ProgramScheduleState();
}

class _ProgramScheduleState extends State<ProgramSchedule> with SingleTickerProviderStateMixin {
  List<Map<String, dynamic>> sideMenuList = [];
  final Repository repository = Repository(HttpService());
  int selectedIndex = 0;
  int hoverTab = -1;

  @override
  void initState() {
    super.initState();
    getPlanningSideMenu();
  }

  Future<void> getPlanningSideMenu() async {
    try {
      Map<String, Object> body = {"userId": widget.customerID, "controllerId": widget.controllerID};
      final response = await repository.getPlanningHiddenMenu(body);
      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        List<dynamic> itemList = jsonResponse['data'];
        List<Map<String, dynamic>> newSideMenuList = [{'id': 1, 'label': 'Irrigation Program', 'value': ''}];
        newSideMenuList.addAll(itemList.map((item) => {'id': item['dealerDefinitionId'], 'label': item['parameter'] ?? '', 'value': item['value'] ?? ''}).toList());
        setState(() {
          sideMenuList = newSideMenuList;
        });
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  Icon getIconForParameter(int id) {
    switch (id) {
      case 66:
        return const Icon(Icons.water, color: Colors.white,);
      case 67:
        return const Icon(Icons.gas_meter_outlined, color: Colors.white,);
      case 68:
        return const Icon(Icons.waves, color: Colors.white,);
      case 69:
        return const Icon(Icons.group_work_outlined, color: Colors.white,);
      case 70:
        return const Icon(Icons.format_list_numbered, color: Colors.white,);
      case 71:
        return const Icon(Icons.deblur_outlined, color: Colors.white,);
      case 72:
        return const Icon(Icons.filter_alt_outlined, color: Colors.white,);
      case 73:
        return const Icon(Icons.settings_outlined, color: Colors.white,);
      case 74:
        return const Icon(Icons.settings_outlined, color: Colors.white,);
      case 75:
        return const Icon(Icons.power_outlined, color: Colors.white,);
      case 76:
        return const Icon(Icons.question_answer_outlined, color: Colors.white,);
      case 78:
        return const Icon(Icons.settings, color: Colors.white,);
      case 79:
        return const Icon(Icons.code, color: Colors.white,);
      case 80:
        return const Icon(Icons.text_fields, color: Colors.white,);
      default:
        return const Icon(Icons.help_outline, color: Colors.white,);
    }
  }

  Widget getViewForParameter(int id) {
    switch (id) {
      case 1:
        return ProgramLibraryScreenNew(customerId: widget.customerID, controllerId: widget.controllerID, deviceId: widget.imeiNumber, userId: widget.userId, fromDealer: false, groupId: widget.groupId, categoryId: widget.categoryId,);
      // case 66:
      //   return watersourceUI(userId: widget.customerID, controllerId: widget.controllerID, deviceID: widget.imeiNumber,);
      // case 67:
      //   return VirtualMeterScreen(userId: widget.customerID, controllerId: widget.controllerID, deviceId: widget.imeiNumber);
      case 66:
        return watersourceUI(userId: widget.userId, controllerId: widget.controllerID, deviceID: widget.imeiNumber, menuId: 66,);
      case 67:
        return VirtualMeterScreen(userId: widget.userId, controllerId: widget.controllerID, menuId: 67, deviceId: widget.imeiNumber);
      // case 68:
      //   return RadiationSetUI(userId: widget.customerID, controllerId: widget.controllerID, );
      case 69:
        return GroupListScreen();
      case 70:
      //   return ConditionScreen(customerId: widget.customerID, controllerId: widget.controllerID, imeiNo: widget.imeiNumber, isProgram: false, serialNumber: 0,);
      case 71:
        return FrostMobUI(userId: widget.customerID, controllerId: widget.controllerID,deviceID: widget.imeiNumber, menuId: 71,);
      case 72:
        return FilterBackwashUI(userId: widget.userId, controllerId: widget.controllerID, deviceId: widget.imeiNumber, customerId: widget.customerID, fromDealer: false,);
      case 73:
        return FertilizerSetScreen(userData: {'userId' : widget.customerID, 'controllerId' : widget.controllerID, 'deviceId' : widget.imeiNumber});
      case 74:
        return GlobalLimitScreen(userData: {'userId' : widget.customerID, 'controllerId' : widget.controllerID, 'deviceId' : widget.imeiNumber});
      case 75:
        return SystemDefinition(userId: widget.userId, controllerId: widget.controllerID, deviceId: widget.imeiNumber, customerId: widget.customerID,);
      // case 76:
      //   return ProgramQueueScreen(userId: widget.customerID, controllerId: widget.controllerID, cutomerId: widget.customerID, customerId: widget.customerID, deviceId: widget.imeiNumber,);
      // case 77:
      //   return WeatherScreen(userId: widget.customerID, controllerId: widget.controllerID,deviceID: widget.imeiNumber,initialIndex: 0,);
      case 78:
        return PreferenceMainScreen(userId: widget.userId, controllerId: widget.controllerID, customerId: widget.customerID, deviceId: widget.imeiNumber, menuId: 0,);
      case 79:
        return ConstantInConfig(userId: widget.customerID, deviceId: widget.imeiNumber, customerId: widget.customerID, controllerId: widget.controllerID);
      case 80:
        return Names(userID: widget.customerID, customerID: widget.customerID, controllerId: widget.controllerID, menuId: 0, imeiNo: widget.imeiNumber, );
      // case 81:
      //   return CustomMarkerPage(userId: widget.customerID,deviceID: widget.imeiNumber,controllerId: widget.controllerID,);
      case 127:
        return CalibrationScreen(userData: {'userId' : widget.customerID, 'controllerId' : widget.controllerID, 'deviceId' : widget.imeiNumber});
      default:
        return const Center(child: Text('id'));
    }

  }


  @override
  Widget build(BuildContext context) {
    //var fertSetPvd = Provider.of<FertilizerSetProvider>(context, listen: true);
    return Scaffold(
      backgroundColor: const Color(0xFF03464F),
      body:
      sideMenuList.isEmpty? const Center(child: CircularProgressIndicator()):
      SafeArea(
        child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            return SizedBox(
              width: double.infinity,
              height: double.infinity,
              child: Row(

                children: [
                  Container(
                    width: constraints.maxWidth * 0.15,
                    color: Theme.of(context).primaryColorDark,
                    child: ListView(
                      padding: const EdgeInsets.all(10),
                      children: [
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 20),
                            child:  Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                const BackButton(color: Colors.white,),
                                const SizedBox(width: 10,),
                                Expanded(
                                  child: Text(
                                    "Planning",
                                    style: TextStyle(
                                        fontSize: Theme.of(context).textTheme.titleLarge!.fontSize,
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        for (var i = 0; i < sideMenuList.length; i++)
                          Material(
                            type: MaterialType.transparency,
                            child: ListTile(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)
                              ),
                              title: !(constraints
                                  .maxWidth > 500 && constraints
                                  .maxWidth <= 600)
                                  ? Text(sideMenuList[i]['label'], style: const TextStyle(color: Colors.white),) : null,
                              leading: getIconForParameter(sideMenuList[i]['id']),
                              selected: selectedIndex == i,
                              onTap: () {
                                setState(() {
                                  selectedIndex = i;
                                });
                              },
                              /*  selectedTileColor: _tabController.index == i ? const Color(0xff2999A9) : null,
                                  hoverColor: _tabController.index == i ? const Color(0xff2999A9) : null*/
                              selectedTileColor: selectedIndex == i ? Theme.of(context).primaryColorLight : null,
                              hoverColor: selectedIndex == i ? Theme.of(context).primaryColorLight : null,
                            ),
                          ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        width: double.infinity,
                        height: double.infinity,
                        decoration: BoxDecoration(
                            color: const Color(0xffE6EDF5),
                            borderRadius: BorderRadius.circular(20)),
                        child: Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: getViewForParameter(sideMenuList[selectedIndex]['id']),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }
        ),
      ),
    );
  }
}
