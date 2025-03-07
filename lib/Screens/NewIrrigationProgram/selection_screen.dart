import 'package:flutter/material.dart';
import 'package:oro_drip_irrigation/Models/Configuration/device_object_model.dart';
import 'package:oro_drip_irrigation/Screens/NewIrrigationProgram/schedule_screen.dart';
import 'package:oro_drip_irrigation/Screens/NewIrrigationProgram/sequence_screen.dart';
import 'package:provider/provider.dart';
import '../../StateManagement/irrigation_program_provider.dart';
import '../../Widgets/SCustomWidgets/custom_animated_switcher.dart';
import 'conditions_screen.dart';

final purpleLight = const Color(0xff8833FF).withOpacity(0.05);
final purpleDark = const Color(0xff8833FF).withOpacity(0.35);
final redLight = const Color(0xffFFF7E5).withOpacity(0.5);
final redDark = const Color(0xffFF857D).withOpacity(0.35);
final greenLight = const Color(0xffECF5EF).withOpacity(0.5);
final greenDark = const Color(0xff10E196).withOpacity(0.35);
const yellowLight = Color(0xffFFF7E5);
const yellowDark = Color(0xfffdce7f);
final primaryColorLight = const Color(0xffE3FFF5).withOpacity(0.5);

class SelectionScreen extends StatefulWidget{
  const SelectionScreen({super.key});

  @override
  State<SelectionScreen> createState() => _SelectionScreenState();
}

class _SelectionScreenState extends State<SelectionScreen> with SingleTickerProviderStateMixin{
  late IrrigationProgramMainProvider irrigationProgramProvider;
  late AnimationController ctrlValue;

  @override
  void initState() {
    super.initState();
    ctrlValue = AnimationController(vsync: this,duration: const Duration(seconds: 1));
    ctrlValue.addListener(() {setState(() {});});
    ctrlValue.repeat();
    irrigationProgramProvider = Provider.of<IrrigationProgramMainProvider>(context, listen: false);
    if(irrigationProgramProvider.selectedObjects != null) {
      if(irrigationProgramProvider.sampleIrrigationLine?.map((e) => e.irrigationLine).toList().length == 1 && !(irrigationProgramProvider.selectedObjects!.any((element) => element.objectId == 2))) {
        irrigationProgramProvider.selectedObjects!.add(
            irrigationProgramProvider.sampleIrrigationLine!.map((e) => e.irrigationLine).toList()[0]
        );
      }
      if(!irrigationProgramProvider.isPumpStationMode) {
        if(irrigationProgramProvider.selectedObjects!.where((element) => element.objectId == 2).length > 1) {
          for(var i = 0; i < irrigationProgramProvider.sampleIrrigationLine!.map((e) => e.irrigationLine).toList().length; i++) {
            if(i != 0) {
              irrigationProgramProvider.selectedObjects!.removeWhere((element) => element.objectId == 2);
            } else {
              irrigationProgramProvider.selectedObjects!.add(
                  irrigationProgramProvider.sampleIrrigationLine!.where((headUnit) {
                    return irrigationProgramProvider.irrigationLine!.sequence.any((sequenceItem) {
                      return sequenceItem['valve'].any((valve) {
                        return headUnit.valve!.any((valveItem) {
                          return valveItem.sNo == valve['sNo'];
                        });
                      });
                    });
                  }).map((e) => e.irrigationLine).toList()[0]
              );
            }
          }
        }
      }
    }
    irrigationProgramProvider.calculateTotalFlowRate();
    // print(irrigationProgramProvider.fertilizerSite!.map((e) => e.toJson()));
  }

  @override
  void dispose() {
    // TODO: implement dispose
    ctrlValue.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    irrigationProgramProvider = Provider.of<IrrigationProgramMainProvider>(context);
    final irrigationLine = irrigationProgramProvider.sampleIrrigationLine;
    final primaryColorDark = Theme.of(context).primaryColor.withOpacity(0.35);
    final centralFertilizerSite = irrigationProgramProvider.fertilizerSite!.where((site) {
      for (var i = 0; i < irrigationProgramProvider.selectedObjects!.length; i++) {
        if (site.siteMode == 1 && irrigationProgramProvider.selectedObjects![i].objectId == 3 && irrigationProgramProvider.selectedObjects![i].sNo == site.fertilizerSite?.sNo) {
          return true;
        }
      }
      return false;
    });
    final localFertilizerSite = irrigationProgramProvider.fertilizerSite!.where((site) {
      for (var i = 0; i < irrigationProgramProvider.selectedObjects!.length; i++) {
        if (site.siteMode == 2 && irrigationProgramProvider.selectedObjects![i].objectId == 3 && irrigationProgramProvider.selectedObjects![i].sNo == site.fertilizerSite?.sNo) {
          return true;
        }
      }
      return false;
    });
    final centralFilterSite = irrigationProgramProvider.filterSite!.where((site) {
      // print("Central filter site ==> ${site.filterSite?.sNo}");
      for (var i = 0; i < irrigationProgramProvider.selectedObjects!.length; i++) {
        if (site.siteMode == 1 && irrigationProgramProvider.selectedObjects![i].objectId == 4 && irrigationProgramProvider.selectedObjects![i].sNo == site.filterSite?.sNo) {
          return true;
        }
      }
      return false;
    });
    final localFilterSite = irrigationProgramProvider.filterSite!.where((site) {
      for (var i = 0; i < irrigationProgramProvider.selectedObjects!.length; i++) {
        if (site.siteMode == 2 && irrigationProgramProvider.selectedObjects![i].objectId == 4 && irrigationProgramProvider.selectedObjects![i].sNo == site.filterSite?.sNo) {
          return true;
        }
      }
      return false;
    });

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        return SingleChildScrollView(
          child: Container(
            margin: EdgeInsets.symmetric(
              horizontal: MediaQuery.of(context).size.width * 0.05,
              vertical: MediaQuery.of(context).size.width * 0.025,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                buildSectionTitle(title: "General"),
                buildSection(
                  title: "Main Valves",
                  dataList: irrigationLine!.map((e) => e.mainValve ?? []).expand((list) => list).toList(),
                  lightColor: yellowLight,
                  darkColor: yellowDark,
                  image: Image.asset(
                    'assets/Images/m_valve.png',
                  ),
                ),
               if(irrigationLine.map((e) => e.irrigationPump ?? []).expand((list) => list).toList().length > 1)
                  buildListTile(
                      padding: EdgeInsets.symmetric(vertical: MediaQuery.of(context).size.width > 1200 ? 8 : 0),
                      context: context,
                      title: "Enable pump station mode",
                      subTitle: "Automated pump selection based on valve flow rate",
                      icon: Icons.heat_pump,
                      textColor: Colors.black,
                      trailing: Switch(
                          value: irrigationProgramProvider.isPumpStationMode,
                          onChanged: (newValue) => irrigationProgramProvider.updatePumpStationMode(newValue, 0)
                      )
                  ),
                if(irrigationProgramProvider.isPumpStationMode)
                  const SizedBox(height: 30,),
                CustomAnimatedSwitcher(
                  condition: irrigationLine.map((e) => e.irrigationPump ?? []).expand((list) => list).toList().length > 1 && irrigationProgramProvider.isPumpStationMode,
                  child: buildListTile(
                      padding: EdgeInsets.symmetric(vertical: MediaQuery.of(context).size.width > 1200 ? 8 : 0),
                      context: context,
                      title: "Change over",
                      subTitle: "Automated pump changeover during trip conditions",
                      icon: Icons.change_circle,
                      textColor: Colors.black,
                      trailing: Switch(
                          value: irrigationProgramProvider.isChangeOverMode,
                          onChanged: (newValue) => irrigationProgramProvider.updatePumpStationMode(newValue, 1)
                      )
                  ),
                ),
                if(irrigationLine.map((e) => e.irrigationPump ?? []).expand((list) => list).toList().length > 1)
                  const SizedBox(height: 30,),
                CustomAnimatedSwitcher(
                    condition: !irrigationProgramProvider.isPumpStationMode,
                    child: buildSection(
                        title: "Irrigation Pumps",
                        dataList: irrigationLine.map((e) => e.irrigationPump ?? []).expand((list) => list).toList(),
                        lightColor: redLight,
                        darkColor: redDark
                    )
                ),
                buildSection(
                  title: "Head Units",
                  dataList: !irrigationProgramProvider.isPumpStationMode
                      ? irrigationProgramProvider.selectedObjects!.any((element) => element.objectId == 5)
                      ? irrigationLine.where((line) => irrigationProgramProvider.selectedObjects!
                      .any((element) => line.irrigationPump != null && line.irrigationPump!.any((pump) => element.sNo == pump.sNo)))
                      .map((line) => line.irrigationLine)
                      .toList()
                      : irrigationLine.where((headUnit) {
                    return irrigationProgramProvider.irrigationLine!.sequence.any((sequenceItem) {
                      return sequenceItem['valve'].any((valve) {
                        return headUnit.valve!.any((valveItem) {
                          return valveItem.sNo == valve['sNo'];
                        });
                      });
                    });
                  }).map((e) => e.irrigationLine).toList()
                      : irrigationLine.map((e) => e.irrigationLine).toList(),
                  lightColor: greenLight,
                  darkColor: greenDark,
                ),
                if(irrigationLine.map((e) => e.centralFertilization != null ? [e.centralFertilization!] : []).expand((list) => list).whereType<DeviceObjectModel>().toList().isNotEmpty
                    || irrigationLine.map((e) => e.localFertilization != null ? [e.localFertilization!] : []).expand((list) => list).whereType<DeviceObjectModel>().toList().isNotEmpty)
                  buildSectionTitle(title: "Fertilizer"),
                buildSection(
                    title: "Central fertilizer site",
                    dataList: irrigationLine.map((e) => e.centralFertilization != null ? [e.centralFertilization!] : []).expand((list) => list).whereType<DeviceObjectModel>().toList(),
                    lightColor: purpleLight,
                    darkColor: purpleDark,
                    image: Image.asset(
                      'assets/Images/central_fertilizer_site2.png',
                    ),
                  siteMode: 1,
                  connectedObject: 3
                ),
                buildRow(
                    context: context,
                    title: "Central fert Selector",
                    dataList: centralFertilizerSite.map((e) => e.selector != null ? List<DeviceObjectModel>.from(e.selector!) : [])
                        .expand((list) => list)
                        .whereType<DeviceObjectModel>()
                        .toList(),
                    lightColor: primaryColorLight,
                    darkColor: primaryColorDark,
                    height: -70.00,
                    condition: centralFertilizerSite.map((e) => e.selector != null ? List<DeviceObjectModel>.from(e.selector!) : [])
                        .expand((list) => list)
                        .whereType<DeviceObjectModel>()
                        .toList().isNotEmpty,
                    siteMode: 1,
                    connectedObject: 3
                ),
                // buildSection("Central fertilizer set", selectionData.centralFertilizerSet, lightColor: yellowLight, darkColor: yellowDark),
                buildRow(
                    context: context,
                    title: "EC sensors in central site",
                   dataList: centralFertilizerSite
                       .map((e) => e.ec != null ? List<DeviceObjectModel>.from(e.ec!) : [])
                       .expand((list) => list)
                       .whereType<DeviceObjectModel>()
                       .toList(),
                    lightColor: greenLight,
                    darkColor: greenDark,
                    height: centralFertilizerSite.map((e) => e.selector).toList().isNotEmpty ? -140.00 : -70.00,
                    condition: centralFertilizerSite
                        .map((e) => e.ec != null ? List<DeviceObjectModel>.from(e.ec!) : [])
                        .expand((list) => list)
                        .whereType<DeviceObjectModel>()
                        .toList().isNotEmpty,
                    siteMode: 1,
                    connectedObject: 3
                ),
                buildRow(
                    context: context,
                    title: "pH sensors in central site",
                    dataList: centralFertilizerSite
                        .map((e) => e.ph != null ? List<DeviceObjectModel>.from(e.ph!) : [])
                        .expand((list) => list)
                        .whereType<DeviceObjectModel>()
                        .toList(),
                    lightColor: redLight,
                    darkColor: redDark,
                    height: centralFertilizerSite.isNotEmpty ? -210.0 : -140.0,
                    condition: centralFertilizerSite
                        .map((e) => e.ph != null ? List<DeviceObjectModel>.from(e.ph!) : [])
                        .expand((list) => list)
                        .whereType<DeviceObjectModel>()
                        .toList().isNotEmpty,
                    siteMode: 1,
                    connectedObject: 3
                ),
                buildSection(
                    title: "Local fertilizer site",
                    dataList: irrigationLine.map((e) => e.localFertilization != null ? [e.localFertilization!] : []).expand((list) => list).whereType<DeviceObjectModel>().toList(),
                    lightColor: purpleLight,
                    darkColor: purpleDark,
                    siteMode: 2,
                    connectedObject: 3
                ),
                buildRow(
                    context: context,
                    title: "Local fert Selector",
                    dataList: localFertilizerSite
                        .map((e) => e.selector != null ? List<DeviceObjectModel>.from(e.selector!) : [])
                        .expand((list) => list)
                        .whereType<DeviceObjectModel>()
                        .toList(),
                    lightColor: yellowLight,
                    darkColor: yellowDark,
                    height: -70.0,
                    condition: localFertilizerSite
                        .map((e) => e.selector != null ? List<DeviceObjectModel>.from(e.selector!) : [])
                        .expand((list) => list)
                        .whereType<DeviceObjectModel>()
                        .toList().isNotEmpty,
                    siteMode: 2,
                    connectedObject: 3
                ),
                // // buildSection("Local fertilizer set", selectionData.localFertilizerSet, lightColor: greenLight, darkColor: greenDark),
                buildRow(
                    context: context,
                    title: "EC sensors in local site",
                    dataList: localFertilizerSite
                        .map((e) => e.ec != null ? List<DeviceObjectModel>.from(e.ec!) : [])
                        .expand((list) => list)
                        .whereType<DeviceObjectModel>()
                        .toList(),
                    lightColor: greenLight,
                    darkColor: greenDark,
                    height: localFertilizerSite.map((e) => e.selector).toList().isNotEmpty ? -140.0: -70.0,
                    condition: localFertilizerSite
                        .map((e) => e.ec != null ? List<DeviceObjectModel>.from(e.ec!) : [])
                        .expand((list) => list)
                        .whereType<DeviceObjectModel>()
                        .toList().isNotEmpty,
                    siteMode: 2,
                    connectedObject: 3
                ),
                buildRow(
                    context: context,
                    title: "pH sensors in local site",
                    dataList: localFertilizerSite
                        .map((e) => e.ph != null ? List<DeviceObjectModel>.from(e.ph!) : [])
                        .expand((list) => list)
                        .whereType<DeviceObjectModel>()
                        .toList(),
                    lightColor: redLight,
                    darkColor: redDark,
                    height: localFertilizerSite.map((e) => e.selector).toList().isNotEmpty ? -210.0: -70.0,
                   condition: localFertilizerSite
                       .map((e) => e.ph != null ? List<DeviceObjectModel>.from(e.ph!) : [])
                       .expand((list) => list)
                       .whereType<DeviceObjectModel>()
                       .toList().isNotEmpty,
                    siteMode: 2,
                    connectedObject: 3
                ),
                if(irrigationLine.map((e) => e.centralFiltration != null ? [e.centralFiltration!] : []).expand((list) => list).whereType<DeviceObjectModel>().isNotEmpty
                    || irrigationLine.map((e) => e.localFiltration != null ? [e.localFiltration!] : []).expand((list) => list).whereType<DeviceObjectModel>().isNotEmpty)
                  buildSectionTitle(title: "Filters"),
                buildSection(
                    title: "Central filter site",
                    dataList: irrigationLine.map((e) => e.centralFiltration != null ? [e.centralFiltration!] : []).expand((list) => list).whereType<DeviceObjectModel>().toList(),
                    lightColor: yellowLight,
                    darkColor: yellowDark,
                    siteMode: 1,
                    connectedObject: 4
                ),
                buildRow(
                    context: context,
                    title: "Central filters",
                  dataList: centralFilterSite
                      .map((e) => e.filters != null ? List<DeviceObjectModel>.from(e.filters!) : [])
                      .expand((list) => list)
                      .whereType<DeviceObjectModel>()
                      .toList(),
                    lightColor: greenLight,
                    darkColor: greenDark,
                    height: -70.0,
                    condition: centralFilterSite.isNotEmpty,
                    siteMode: 1,
                    connectedObject: 4
                ),
                if(MediaQuery.of(context).size.width > 1200)
                  buildRow(
                    context: context,
                    title: "",
                    dataList: [],
                    darkColor: Colors.black,
                    lightColor: Colors.black,
                    height: -140.0,
                    condition: centralFilterSite.isNotEmpty,
                    child: Row(
                      children: [
                        Expanded(
                          child: buildListTile(
                            context: context,
                            title: 'Central Filter Operation Mode'.toUpperCase(),
                            subTitle: "Select central Filter operation mode",
                            textColor: Colors.black,
                            icon: Icons.filter_alt,
                            trailing:  buildPopUpMenuButton(
                                context: context,
                                dataList: irrigationProgramProvider.filtrationModes,
                                onSelected: (newValue) => irrigationProgramProvider.updateFiltrationMode(newValue, true),
                                selected: irrigationProgramProvider.selectedCentralFiltrationMode,
                                child: Text(irrigationProgramProvider.selectedCentralFiltrationMode, style: TextStyle(color: Theme.of(context).primaryColor, fontWeight: FontWeight.bold),)
                            ),
                          ),
                        ),
                        const SizedBox(width: 20,),
                        Expanded(
                          child: buildListTile(
                              context: context,
                              title: 'Central Filtration Beginning Only'.toUpperCase(),
                              subTitle: "Filtration preference",
                              textColor: Colors.black,
                              icon: Icons.filter_list_outlined,
                              trailing:  Switch(
                                  value: irrigationProgramProvider.centralFiltBegin,
                                  onChanged: (newValue) => irrigationProgramProvider.updateFiltBegin(newValue, true)
                              )
                          ),
                        ),
                      ],
                    ),
                  ),
                if(MediaQuery.of(context).size.width < 1200)
                  buildRow(
                    context: context,
                    title: "",
                    dataList: [],
                    darkColor: Colors.black,
                    lightColor: Colors.black,
                    height: -140.0,
                    condition: centralFilterSite.isNotEmpty,
                    child: buildListTile(
                      context: context,
                      title: 'Central Filter Operation Mode'.toUpperCase(),
                      subTitle: "Select central Filter operation mode",
                      textColor: Colors.black,
                      icon: Icons.filter_alt_outlined,
                      trailing: buildPopUpMenuButton(
                          context: context,
                          dataList: irrigationProgramProvider.filtrationModes,
                          onSelected: (newValue) => irrigationProgramProvider.updateFiltrationMode(newValue, true),
                          selected: irrigationProgramProvider.selectedCentralFiltrationMode,
                          child: Text(irrigationProgramProvider.selectedCentralFiltrationMode, style: TextStyle(color: Theme.of(context).primaryColor, fontWeight: FontWeight.bold),)
                      ),
                    ),
                  ),
                if(MediaQuery.of(context).size.width < 1200 && centralFilterSite.isNotEmpty)
                  const SizedBox(height: 30,),
                if(MediaQuery.of(context).size.width < 1200)
                  buildRow(
                    context: context,
                    title: "",
                    dataList: [],
                    darkColor: Colors.black,
                    lightColor: Colors.black,
                    height: -210.0,
                    condition: centralFilterSite.isNotEmpty,
                    child: buildListTile(
                        context: context,
                        title: 'Central Filtration Beginning Only'.toUpperCase(),
                        subTitle: "Filtration preference",
                        textColor: Colors.black,
                        icon: Icons.filter_list_outlined,
                        trailing: Switch(
                            value: irrigationProgramProvider.centralFiltBegin,
                            onChanged: (newValue) => irrigationProgramProvider.updateFiltBegin(newValue, true)
                        )
                    ),
                  ),
                if(centralFilterSite.isNotEmpty)
                  const SizedBox(height: 30,),
                buildSection(
                    title: "Local filter site",
                    dataList: irrigationLine.map((e) => e.localFiltration != null ? [e.localFiltration!] : []).expand((list) => list).whereType<DeviceObjectModel>().toList(),
                    lightColor: redLight,
                    darkColor: redDark,
                    siteMode: 2,
                    connectedObject: 4
                ),
               buildRow(
                    context: context,
                    title: "Local filters",
                    dataList: localFilterSite
                        .map((e) => e.filters != null ? List<DeviceObjectModel>.from(e.filters!) : [])
                        .expand((list) => list)
                        .whereType<DeviceObjectModel>()
                        .toList(),
                    lightColor: purpleLight,
                    darkColor: purpleDark,
                    height: -70.0,
                    condition: localFilterSite.isNotEmpty,
                   siteMode: 1,
                   connectedObject: 4
                ),
                if(MediaQuery.of(context).size.width > 1200)
                  buildRow(
                    context: context,
                    title: "",
                    dataList: [],
                    darkColor: Colors.black,
                    lightColor: Colors.black,
                    height: -140.0,
                    condition: localFilterSite.isNotEmpty,
                    child: Row(
                      children: [
                        Expanded(
                          child: buildListTile(
                            context: context,
                            title: 'Local Filter Operation Mode'.toUpperCase(),
                            subTitle: "Select central Filter operation mode",
                            textColor: Colors.black,
                            icon: Icons.filter_alt,
                            trailing:  buildPopUpMenuButton(
                                context: context,
                                dataList: irrigationProgramProvider.filtrationModes,
                                onSelected: (newValue) => irrigationProgramProvider.updateFiltrationMode(newValue, false),
                                selected: irrigationProgramProvider.selectedLocalFiltrationMode,
                                child: Text(irrigationProgramProvider.selectedLocalFiltrationMode, style: TextStyle(color: Theme.of(context).primaryColor, fontWeight: FontWeight.bold),)
                            ),
                          ),
                        ),
                        const SizedBox(width: 20,),
                        Expanded(
                          child: buildListTile(
                              context: context,
                              title: 'Local Filtration Beginning Only'.toUpperCase(),
                              subTitle: "Filtration preference",
                              textColor: Colors.black,
                              icon: Icons.filter_list_outlined,
                              trailing: Switch(
                                  value: irrigationProgramProvider.localFiltBegin,
                                  onChanged: (newValue) => irrigationProgramProvider.updateFiltBegin(newValue, false)
                              )
                          ),
                        ),
                      ],
                    ),
                  ),
                if(MediaQuery.of(context).size.width < 1200)
                  buildRow(
                    context: context,
                    title: "",
                    dataList: [],
                    darkColor: Colors.black,
                    lightColor: Colors.black,
                    height: -140.0,
                    condition: localFilterSite.isNotEmpty,
                    child: buildListTile(
                      context: context,
                      title: 'Local Filter Operation Mode'.toUpperCase(),
                      subTitle: "Select central Filter operation mode",
                      textColor: Colors.black,
                      icon: Icons.filter_alt_outlined,
                      trailing:  buildPopUpMenuButton(
                          context: context,
                          dataList: irrigationProgramProvider.filtrationModes,
                          onSelected: (newValue) => irrigationProgramProvider.updateFiltrationMode(newValue, false),
                          selected: irrigationProgramProvider.selectedLocalFiltrationMode,
                          child: Text(irrigationProgramProvider.selectedLocalFiltrationMode, style: TextStyle(color: Theme.of(context).primaryColor, fontWeight: FontWeight.bold),)
                      ),
                    ),
                  ),
                if(MediaQuery.of(context).size.width < 1200)
                  const SizedBox(height: 30,),
                if(MediaQuery.of(context).size.width < 1200)
                  buildRow(
                    context: context,
                    title: "",
                    dataList: [],
                    darkColor: Colors.black,
                    lightColor: Colors.black,
                    height: -210.0,
                    condition: localFilterSite.isNotEmpty,
                    child: buildListTile(
                        context: context,
                        title: 'Local Filtration Beginning Only'.toUpperCase(),
                        subTitle: "Filtration preference",
                        textColor: Colors.black,
                        icon: Icons.filter_list_outlined,
                        trailing: Switch(
                            value: irrigationProgramProvider.localFiltBegin,
                            onChanged: (newValue) => irrigationProgramProvider.updateFiltBegin(newValue, false)
                        )
                    ),
                  ),
                const SizedBox(height: 80,)
              ],
            ),
          ),
        );
      },
    );
  }

  void toggleSelection(int objectId, int siteMode, int index, dataList) {
    bool isAlreadySelected = irrigationProgramProvider.selectedObjects!.any((element) => element.sNo == dataList[index].sNo);

    if (isAlreadySelected) {
      irrigationProgramProvider.selectedObjects!.removeWhere((element) => element.sNo == dataList[index].sNo);
    } else {
      if (objectId == 4 && siteMode == 1) {
        irrigationProgramProvider.selectedObjects!.removeWhere((element) => element.objectId == objectId && irrigationProgramProvider.filterSite!.any((site) => site.siteMode == 1 && site.filterSite!.sNo == element.sNo));
      }
      if (objectId == 5 && siteMode == 1) {
        irrigationProgramProvider.selectedObjects!.removeWhere((element) => element.objectId == objectId && irrigationProgramProvider.fertilizerSite!.any((site) => site.siteMode == 1 && site.fertilizerSite!.sNo == element.sNo));
      }
      if (objectId == 4 && siteMode == 2) {
        irrigationProgramProvider.selectedObjects!.removeWhere((element) => element.objectId == objectId && irrigationProgramProvider.filterSite!.any((site) => site.siteMode == 2 && site.filterSite!.sNo == element.sNo));
      }
      if (objectId == 5 && siteMode == 2) {
        irrigationProgramProvider.selectedObjects!.removeWhere((element) => element.objectId == objectId && irrigationProgramProvider.fertilizerSite!.any((site) => site.siteMode == 2 && site.fertilizerSite!.sNo == element.sNo));
      }
      irrigationProgramProvider.selectedObjects!.add(dataList[index]);
    }
  }

  Widget buildSection({required String title, required List<DeviceObjectModel> dataList,
    required Color lightColor, required Color darkColor, bool showSubList = false, Widget? image, int? siteMode, int? connectedObject}) {
    if (dataList.isNotEmpty) {
      final data = dataList.fold<List<DeviceObjectModel>>([], (list, pump) {
        if (!list.any((p) => p.sNo == pump.sNo)) {
          list.add(pump);
        }
        return list;
      });

      return Column(
        children: [buildLineAndValveContainerUpdated(
            context: context,
            title: title,
            // showSubList: showSubList,
            // dataList: dataList,
            leading: image != null
                ? Container(
              padding: const EdgeInsets.all(5),
              decoration: BoxDecoration(
                  color: cardColor,
                  shape: BoxShape.circle
              ),
              child: image,
            )
                : null,
            children: [
              for (var index = 0; index < data.length; index++)
                buildListOfContainer(
                  context: context,
                  onTap: () {
                    data[index].siteMode = siteMode;
                    data[index].connectedObject = connectedObject;
                    if ((data[index].objectId == 4 && siteMode == 1) || (data[index].objectId == 4 && siteMode == 2) || (data[index].objectId == 5 && siteMode == 1) || (data[index].objectId == 5 && siteMode == 2)) {
                      toggleSelection(data[index].objectId, siteMode!, index, data);
                    } else {
                      if (irrigationProgramProvider.selectedObjects!.any((element) => element.sNo == data[index].sNo)) {
                        irrigationProgramProvider.selectedObjects!.removeWhere((element) => element.sNo == data[index].sNo);
                      } else {
                        irrigationProgramProvider.selectedObjects!.add(data[index]);
                      }
                    }
                  },
                  itemName: data[index].name ?? "No name",
                  // containerColor: lightColor,
                  containerColor: irrigationProgramProvider.selectedObjects!.any((element) => element.sNo == data[index].sNo) ? darkColor : lightColor,
                )
            ],
          ),
          const SizedBox(height: 30),
        ],
      );
    } else {
      return Container();
    }
  }

  Widget buildRow({required BuildContext context, required String title, required dataList,
    required darkColor, required lightColor, required height, required bool condition, child, int? siteMode, int? connectedObject}) {

    return CustomAnimatedSwitcher(
      condition: condition,
      child: Row(
        children: [
          AnimatedLShape(height: height),
          Expanded(
            flex: 15,
            child: child ?? buildSection(
              showSubList: true,
              title: title,
              dataList: dataList,
              lightColor: lightColor,
              darkColor: darkColor,
              siteMode: siteMode,
              connectedObject: connectedObject
            ),
          )
        ],
      ),
    );
  }

  Widget buildSectionTitle({required String title}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 10),
      child: Text(title, style: TextStyle(color: Theme.of(context).primaryColor, fontWeight: FontWeight.bold),),
    );
  }
}

class LShapeDivider extends CustomPainter{
  BuildContext context;
  double height;
  double? ctrValue;
  LShapeDivider({required this.context,required this.height, this.ctrValue});
  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint();
    paint.strokeWidth = 1;
    paint.color = Theme.of(context).primaryColorDark  ;
    canvas.drawLine(const Offset(20, 0), Offset(20+((size.width-20)*ctrValue!), 0), paint);
    canvas.drawLine(const Offset(20, 0), Offset(20, height*ctrValue!), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    // TODO: implement shouldRepaint
    return true;
  }
}

class AnimatedLShape extends StatefulWidget {
  final double height;
  const AnimatedLShape({super.key, required this.height});

  @override
  State<AnimatedLShape> createState() => _AnimatedLShapeState();
}

class _AnimatedLShapeState extends State<AnimatedLShape> with SingleTickerProviderStateMixin{
  late AnimationController ctrlValue;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    ctrlValue = AnimationController(vsync: this,duration: const Duration(seconds: 1));
    ctrlValue.forward();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    ctrlValue.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 50,
      height: 10,
      child: CustomPaint(
        painter: LShapeDivider(context: context, height: widget.height, ctrValue: ctrlValue.value),
        size: const Size(1,1),
      ),
    );
  }
}

