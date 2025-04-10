import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:loading_indicator/loading_indicator.dart';

import 'package:oro_drip_irrigation/utils/my_function.dart';
import 'package:oro_drip_irrigation/view_models/create_account_view_model.dart';
import 'package:provider/provider.dart';
import '../../Models/customer/condition_library_model.dart';
import '../../repository/repository.dart';
import '../../services/http_service.dart';
import '../../view_models/customer/condition_library_view_model.dart';

class ConditionLibrary extends StatelessWidget {
   const ConditionLibrary( {super.key, required this.customerId, required this.controllerId, required this.userId,required this.deviceId});

  final int customerId;
   final int controllerId;
   final int userId;
   final String deviceId;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) =>
      ConditionLibraryViewModel(Repository(HttpService()))
        ..getConditionLibraryData(customerId, controllerId),
      child: Consumer<ConditionLibraryViewModel>(
        builder: (context, vm, _) {
          return vm.isLoading ?
          Container(
            color: Colors.white,
            child: Padding(
              padding: EdgeInsets.only(left: MediaQuery.of(context).size.width/2-95,
                  right: MediaQuery.of(context).size.width/2-95),
              child: const LoadingIndicator(
                indicatorType: Indicator.ballPulse,
                strokeWidth: 100,
              ),
            ),
          ) :
          Scaffold(
            appBar: !kIsWeb? AppBar(title: const Text('Condition Library')) : null,
            body: Padding(
              padding: const EdgeInsets.only(left: 8, right: 8, top: 8),
              child: vm.conditionLibraryData.conditionLibrary.condition
                  .isNotEmpty ?
              GridView.builder(
                itemCount: vm.conditionLibraryData.conditionLibrary.condition
                    .length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: kIsWeb? MediaQuery
                      .sizeOf(context)
                      .width > 1350 ? 3 : 2:1,
                  crossAxisSpacing: 3.0,
                  mainAxisSpacing: 3.0,
                  childAspectRatio: kIsWeb? MediaQuery
                      .sizeOf(context)
                      .width > 1350 ? MediaQuery
                      .sizeOf(context)
                      .width / 1200 :
                  MediaQuery
                      .sizeOf(context)
                      .width / 750: 1.15,
                ),
                itemBuilder: (BuildContext context, int index) {
                  return Card(
                    color: Colors.white,
                    elevation: 1,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Condition ${index + 1}',
                                      style: const TextStyle(fontSize: 15)),
                                  Text(vm.conditionLibraryData.conditionLibrary
                                      .condition[index].rule,
                                      style: const TextStyle(
                                          fontSize: 12, color: Colors.black54)),
                                  const SizedBox(height: 5),
                                ],
                              ),
                              const Spacer(),
                              Transform.scale(
                                scale: 0.7,
                                child: Tooltip(
                                  message: vm.conditionLibraryData
                                      .conditionLibrary.condition[index].status
                                      ?
                                  'deactivate':
                                  'activate',
                                  child: Switch(
                                    hoverColor: Theme
                                        .of(context)
                                        .primaryColor,
                                    activeColor: Theme
                                        .of(context)
                                        .primaryColorLight,
                                    value: vm.conditionLibraryData
                                        .conditionLibrary.condition[index]
                                        .status,
                                    onChanged: (bool value) {
                                      vm.switchStateOnChange(value, index);
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const Divider(height: 0),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Container(
                                  width: 0.5, height: 40, color: Colors.grey),
                              Expanded(
                                child: RadioListTile<String>(
                                  title: const Text("Sensor"),
                                  value: 'Sensor',
                                  groupValue: vm.conditionLibraryData
                                      .conditionLibrary.condition[index].type,
                                  onChanged: (value) =>
                                      vm.conTypeOnChange(value!, index),
                                  contentPadding: EdgeInsets.zero,
                                  visualDensity: const VisualDensity(
                                      horizontal: -4.0, vertical: -4.0),
                                  activeColor: Theme
                                      .of(context)
                                      .primaryColorLight,
                                ),
                              ),
                              Container(
                                  width: 0.5, height: 40, color: Colors.grey),
                              Expanded(
                                child: RadioListTile<String>(
                                  title: const Text("Program"),
                                  value: 'Program',
                                  groupValue: vm.conditionLibraryData
                                      .conditionLibrary.condition[index].type,
                                  onChanged: (value) =>
                                      vm.conTypeOnChange(value!, index),
                                  contentPadding: EdgeInsets.zero,
                                  visualDensity: const VisualDensity(
                                      horizontal: -4.0, vertical: -4.0),
                                  activeColor: Theme
                                      .of(context)
                                      .primaryColorLight,
                                ),
                              ),
                              Container(
                                  width: 0.5, height: 40, color: Colors.grey),
                              Expanded(
                                child: RadioListTile<String>(
                                  title: const Text("Combined"),
                                  value: 'Combined',
                                  groupValue: vm.conditionLibraryData
                                      .conditionLibrary.condition[index].type,
                                  onChanged: (value) =>
                                      vm.conTypeOnChange(value!, index),
                                  contentPadding: EdgeInsets.zero,
                                  visualDensity: const VisualDensity(
                                      horizontal: -4.0, vertical: -4.0),
                                  activeColor: Theme
                                      .of(context)
                                      .primaryColorLight,
                                ),
                              ),
                              Container(
                                  width: 0.5, height: 40, color: Colors.grey),
                            ],
                          ),
                          const Divider(height: 0),
                          Padding(
                            padding: const EdgeInsets.only(left: 8, top: 8),
                            child: Row(
                              children: [
                                const SizedBox(
                                  width: 125,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment
                                        .start,
                                    children: [
                                      Text('Component', style: TextStyle(
                                          color: Colors.black54)),
                                      SizedBox(height: 8),
                                      Text('Parameter', style: TextStyle(
                                          color: Colors.black54)),
                                      SizedBox(height: 10),
                                      Text('Value/Threshold', style: TextStyle(
                                          color: Colors.black54)),
                                      SizedBox(height: 12),
                                      Text('Reason', style: TextStyle(
                                          color: Colors.black54)),
                                      SizedBox(height: 15),
                                      Text('Delay Time', style: TextStyle(
                                          color: Colors.black54)),
                                    ],
                                  ),
                                ),
                                Expanded(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment
                                        .start,
                                    children: [
                                      Container(
                                        width: double.infinity,
                                        height: 27,
                                        decoration: BoxDecoration(
                                            color: Theme
                                                .of(context)
                                                .primaryColor
                                                .withValues(alpha: 0.05),
                                            borderRadius: BorderRadius.circular(
                                                3),
                                            border: Border.all(
                                                width: 0.5,
                                                color: Colors.grey.shade400
                                            )
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.only(
                                              left: 5, top: 3),
                                          child: vm.conditionLibraryData
                                              .conditionLibrary.condition[index]
                                              .type == 'Combined' ?
                                          PopupMenuButton<String>(
                                            onSelected: (String cName) =>
                                                vm.combinedTO(index, cName),
                                            itemBuilder: (
                                                BuildContext context) {
                                              return vm.getAvailableCondition(
                                                  index).map((String source) {
                                                return CheckedPopupMenuItem<
                                                    String>(
                                                  value: source,
                                                  height: 30,
                                                  checked: vm.connectedTo[index]
                                                      .contains(source),
                                                  child: Text(source),
                                                );
                                              }).toList();
                                            },
                                            child: Text(
                                              vm.conditionLibraryData
                                                  .conditionLibrary
                                                  .condition[index].component,
                                            ),
                                          ) :
                                          PopupMenuButton<String>(
                                            tooltip: vm.conditionLibraryData
                                                .conditionLibrary
                                                .condition[index].type ==
                                                'Sensor'
                                                ? 'Select your sensor'
                                                :
                                            vm.conditionLibraryData
                                                .conditionLibrary
                                                .condition[index].type ==
                                                'Program'
                                                ? 'Select your program'
                                                :
                                            'Select more than one conditions',
                                            onSelected: (String selectedValue) {
                                              vm.componentOnChange(selectedValue, index);
                                            },
                                            itemBuilder: (BuildContext context) {
                                              return vm.conditionLibraryData
                                                  .conditionLibrary
                                                  .condition[index].type == 'Sensor' ?
                                              vm.conditionLibraryData.defaultData.sensors.map<PopupMenuEntry<String>>((sensor) {
                                                return PopupMenuItem<String>(
                                                  value: sensor.name,
                                                  height: 35,
                                                  child: Text(sensor.name),
                                                );
                                              }).toList() :
                                              vm.conditionLibraryData.defaultData.program.map<PopupMenuEntry<String>>((
                                                  program) {
                                                return PopupMenuItem<String>(
                                                  value: program.name,
                                                  height: 35,
                                                  child: Text(program.name),
                                                );
                                              }).toList();
                                            },
                                            child: Text(
                                              vm.conditionLibraryData
                                                  .conditionLibrary
                                                  .condition[index].component,
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 5),
                                      Container(
                                        width: double.infinity,
                                        height: 27,
                                        decoration: BoxDecoration(
                                            color: Theme
                                                .of(context)
                                                .primaryColor
                                                .withValues(alpha: 0.05),
                                            borderRadius: BorderRadius.circular(
                                                3),
                                            border: Border.all(
                                                width: 0.5,
                                                color: Colors.grey.shade400
                                            )
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.only(
                                              left: 5, top: 3),
                                          child: PopupMenuButton<String>(
                                            onSelected: (String selectedValue) {
                                              vm.parameterOnChange(
                                                  selectedValue, index);
                                            },
                                            itemBuilder: (
                                                BuildContext context) {
                                              if (vm.conditionLibraryData
                                                  .conditionLibrary
                                                  .condition[index].type ==
                                                  'Sensor') {
                                                final selectedSensor = vm
                                                    .conditionLibraryData
                                                    .defaultData.sensors
                                                    .firstWhereOrNull((
                                                    sensor) =>
                                                sensor.name == vm
                                                    .conditionLibraryData
                                                    .conditionLibrary
                                                    .condition[index]
                                                    .component);

                                                final filteredParameters = vm
                                                    .conditionLibraryData
                                                    .defaultData.sensorParameter
                                                    .where((param) =>
                                                param.objectId ==
                                                    selectedSensor?.objectId)
                                                    .toList();

                                                return filteredParameters.map<
                                                    PopupMenuEntry<String>>((
                                                    program) {
                                                  return PopupMenuItem<String>(
                                                    value: program.parameter,
                                                    height: 35,
                                                    child: Text(
                                                        program.parameter),
                                                  );
                                                }).toList();
                                              } else {
                                                return ['Status'].map((
                                                    String value) =>
                                                    PopupMenuItem<String>(
                                                      value: value,
                                                      height: 30,
                                                      child: Text(value),
                                                    )).toList();
                                              }
                                            },
                                            child: Text(
                                              vm.conditionLibraryData
                                                  .conditionLibrary
                                                  .condition[index].parameter,
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 5),
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Container(
                                              height: 27,
                                              decoration: BoxDecoration(
                                                  color: Theme
                                                      .of(context)
                                                      .primaryColor
                                                      .withValues(alpha: 0.05),
                                                  borderRadius: BorderRadius
                                                      .circular(3),
                                                  border: Border.all(
                                                      width: 0.5,
                                                      color: Colors.grey
                                                          .shade400
                                                  )
                                              ),
                                              child: Padding(
                                                padding: const EdgeInsets.only(
                                                    left: 5, top: 3),
                                                child: PopupMenuButton<String>(
                                                  onSelected: (
                                                      String selectedValue) {
                                                    vm.thresholdOnChange(
                                                        selectedValue, index);
                                                  },
                                                  itemBuilder: (
                                                      BuildContext context) {

                                                    /* final selectedSensor = vm.conditionLibraryData.defaultData.sensors
                                                        .firstWhereOrNull((sensor) => sensor.name == vm.selectedComponent[index]);

                                                    final List<String> options = (selectedSensor?.objectId == 40)
                                                        ? ['--', 'Low', 'High']
                                                        : ['--', 'Lower than', 'Higher than', 'Equal to'];*/

                                                    final List<
                                                        String> options = (vm
                                                        .conditionLibraryData
                                                        .conditionLibrary
                                                        .condition[index]
                                                        .type == 'Sensor')
                                                        ? [
                                                      'Lower than',
                                                      'Higher than',
                                                      'Equal to'
                                                    ] :
                                                    (vm.conditionLibraryData
                                                        .conditionLibrary
                                                        .condition[index]
                                                        .type == 'Program') ?
                                                    [
                                                      'is Running',
                                                      "is Starting",
                                                      "is Ending"
                                                    ] : [
                                                      'Anyone is',
                                                      "Both are"
                                                    ];


                                                    return options.map((
                                                        String value) =>
                                                        PopupMenuItem<String>(
                                                          value: value,
                                                          height: 30,
                                                          child: Text(value),
                                                        )).toList();
                                                  },
                                                  child: Text(
                                                    vm.conditionLibraryData
                                                        .conditionLibrary
                                                        .condition[index]
                                                        .threshold,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 5,),
                                          vm.conditionLibraryData
                                              .conditionLibrary.condition[index]
                                              .type == 'Sensor' ?
                                          Container(
                                            width: 100,
                                            height: 27,
                                            decoration: BoxDecoration(
                                                color: Theme
                                                    .of(context)
                                                    .primaryColor
                                                    .withValues(alpha: 0.05),
                                                borderRadius: BorderRadius
                                                    .circular(3),
                                                border: Border.all(
                                                    width: 0.5,
                                                    color: Colors.grey.shade400
                                                )
                                            ),
                                            child: TextButton(
                                              onPressed: () {
                                                showDialog(
                                                  context: context,
                                                  builder: (
                                                      BuildContext context) {
                                                    return AlertDialog(
                                                      title: const Text(
                                                          'Select values and Operator'),
                                                      shape: RoundedRectangleBorder(
                                                        borderRadius: BorderRadius
                                                            .circular(10),
                                                      ),
                                                      content: SizedBox(
                                                        width: 250,
                                                        height: 260,
                                                        child: Column(
                                                          children: [
                                                            SizedBox(
                                                                width: 250,
                                                                height: 50,
                                                                child: TextFormField(
                                                                  controller: vm
                                                                      .vtTEVControllers[index],
                                                                  maxLength: 100,
                                                                  readOnly: true,
                                                                  decoration: const InputDecoration(
                                                                    counterText: '',
                                                                    labelText: 'Value/Threshold',
                                                                    contentPadding: EdgeInsets
                                                                        .symmetric(
                                                                        vertical: 10.0,
                                                                        horizontal: 10.0),
                                                                    enabledBorder: UnderlineInputBorder(
                                                                      borderSide: BorderSide(
                                                                          color: Colors
                                                                              .black12),
                                                                    ),
                                                                  ),
                                                                  validator: (
                                                                      value) {
                                                                    if (value ==
                                                                        null ||
                                                                        value
                                                                            .isEmpty) {
                                                                      return 'Please fill out this field';
                                                                    }
                                                                    return null;
                                                                  },
                                                                )
                                                            ),
                                                            const SizedBox(
                                                                height: 8),
                                                            SizedBox(
                                                              width: 250,
                                                              height: 150,
                                                              child: GridView
                                                                  .count(
                                                                crossAxisCount: 5,
                                                                crossAxisSpacing: 5,
                                                                mainAxisSpacing: 5,
                                                                children: [
                                                                  '%',
                                                                  '°C',
                                                                  '.',
                                                                  'cl',
                                                                  'C',
                                                                  '9',
                                                                  '8',
                                                                  '7',
                                                                  '6',
                                                                  '5',
                                                                  '4',
                                                                  '3',
                                                                  '2',
                                                                  '1',
                                                                  '0'
                                                                ].map((
                                                                    operator) =>
                                                                    ElevatedButton(
                                                                      onPressed: () {
                                                                        if (operator ==
                                                                            'C') {
                                                                          vm
                                                                              .vtTEVControllers[index]
                                                                              .text =
                                                                          '';
                                                                        } else
                                                                        if (operator ==
                                                                            'cl') {
                                                                          vm
                                                                              .vtTEVControllers[index]
                                                                              .text =
                                                                              vm
                                                                                  .vtTEVControllers[index]
                                                                                  .text
                                                                                  .substring(
                                                                                  0,
                                                                                  vm
                                                                                      .vtTEVControllers[index]
                                                                                      .text
                                                                                      .length -
                                                                                      1);
                                                                        }
                                                                        else
                                                                        if (operator ==
                                                                            'Ok') {
                                                                          Navigator
                                                                              .pop(
                                                                              context);
                                                                        } else {
                                                                          vm
                                                                              .vtTEVControllers[index]
                                                                              .text +=
                                                                              operator;
                                                                        }
                                                                        ChangeNotifier();
                                                                        //result = operator;
                                                                        //Navigator.pop(context);
                                                                      },
                                                                      style: ButtonStyle(
                                                                        backgroundColor: operator ==
                                                                            'C'
                                                                            ? WidgetStateProperty
                                                                            .all<
                                                                            Color>(
                                                                            Colors
                                                                                .redAccent)
                                                                            :
                                                                        WidgetStateProperty
                                                                            .all<
                                                                            Color>(
                                                                            Theme
                                                                                .of(
                                                                                context)
                                                                                .primaryColor),
                                                                      ),
                                                                      child: operator ==
                                                                          'cl'
                                                                          ? const Icon(
                                                                          Icons
                                                                              .backspace_outlined,
                                                                          color: Colors
                                                                              .white)
                                                                          :
                                                                      Text(
                                                                          operator,
                                                                          style: const TextStyle(
                                                                              fontSize: 15,
                                                                              color: Colors
                                                                                  .white)),
                                                                    ),
                                                                ).toList(),
                                                              ),
                                                            ),
                                                            SizedBox(
                                                                width: 250,
                                                                height: 50,
                                                                child: Row(
                                                                  children: [
                                                                    MaterialButton(
                                                                      color: Theme
                                                                          .of(
                                                                          context)
                                                                          .primaryColor,
                                                                      textColor: Colors
                                                                          .white,
                                                                      height: 40,
                                                                      minWidth: 170,
                                                                      onPressed: () {
                                                                        vm
                                                                            .vtTEVControllers[index]
                                                                            .text +=
                                                                        ' ';
                                                                      },
                                                                      child: const Text(
                                                                          'Space'),
                                                                    ),
                                                                    const SizedBox(
                                                                        width: 5),
                                                                    MaterialButton(
                                                                      height: 40,
                                                                      color: Theme
                                                                          .of(
                                                                          context)
                                                                          .primaryColorLight,
                                                                      textColor: Colors
                                                                          .white,
                                                                      onPressed: () {
                                                                        if (vm
                                                                            .vtTEVControllers[index]
                                                                            .text
                                                                            .trim()
                                                                            .isEmpty) {
                                                                          showDialog(
                                                                            context: context,
                                                                            builder: (
                                                                                context) {
                                                                              return AlertDialog(
                                                                                title: const Text(
                                                                                    "Error"),
                                                                                content: const Text(
                                                                                    "Field cannot be empty or contain only spaces."),
                                                                                actions: [
                                                                                  TextButton(
                                                                                    onPressed: () =>
                                                                                        Navigator
                                                                                            .pop(
                                                                                            context),
                                                                                    child: const Text(
                                                                                        "OK"),
                                                                                  ),
                                                                                ],
                                                                              );
                                                                            },
                                                                          );
                                                                        } else {
                                                                          final sensor = vm
                                                                              .conditionLibraryData
                                                                              .defaultData
                                                                              .sensors
                                                                              .firstWhere(
                                                                                (
                                                                                sensor) =>
                                                                            sensor
                                                                                .name ==
                                                                                vm
                                                                                    .conditionLibraryData
                                                                                    .conditionLibrary
                                                                                    .condition[index]
                                                                                    .component,
                                                                            orElse: () =>
                                                                                Sensor(
                                                                                    objectId: 0,
                                                                                    sNo: 0.0,
                                                                                    name: '',
                                                                                    objectName: ''),
                                                                          );
                                                                          if (sensor
                                                                              .objectName
                                                                              .isNotEmpty) {
                                                                            String unit = MyFunction()
                                                                                .getUnitValue(
                                                                                context,
                                                                                sensor
                                                                                    .objectName,
                                                                                vm
                                                                                    .vtTEVControllers[index]
                                                                                    .text) ??
                                                                                '';
                                                                            vm
                                                                                .valueOnChange(
                                                                                '${vm
                                                                                    .vtTEVControllers[index]
                                                                                    .text} $unit',
                                                                                index);
                                                                            Navigator
                                                                                .pop(
                                                                                context);
                                                                          }
                                                                        }
                                                                      },
                                                                      child: const Text(
                                                                          'Enter'),
                                                                    ),
                                                                  ],
                                                                )
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    );
                                                  },
                                                );
                                              },
                                              style: ButtonStyle(
                                                padding: WidgetStateProperty
                                                    .all(EdgeInsets.zero),
                                                minimumSize: WidgetStateProperty
                                                    .all(Size.zero),
                                                tapTargetSize: MaterialTapTargetSize
                                                    .shrinkWrap,
                                                backgroundColor: WidgetStateProperty
                                                    .all(Colors.transparent),
                                              ),
                                              child: Text(
                                                vm.conditionLibraryData
                                                    .conditionLibrary
                                                    .condition[index].value,
                                                style: const TextStyle(
                                                    color: Colors.black,
                                                    fontSize: 13),
                                                textAlign: TextAlign.left,),
                                            ),
                                          ) :
                                          Container(
                                            width: 100,
                                            decoration: BoxDecoration(
                                                color: Theme
                                                    .of(context)
                                                    .primaryColor
                                                    .withValues(alpha: 0.05),
                                                borderRadius: BorderRadius
                                                    .circular(3),
                                                border: Border.all(
                                                    width: 0.5,
                                                    color: Colors.grey.shade400
                                                )
                                            ),
                                            child: Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 5, top: 3),
                                              child: PopupMenuButton<String>(
                                                onSelected: (
                                                    String selectedValue) {
                                                  vm.valueOnChange(
                                                      selectedValue, index);
                                                },
                                                itemBuilder: (
                                                    BuildContext context) {
                                                  return ['true', 'False'].map((
                                                      String value) =>
                                                      PopupMenuItem<String>(
                                                        value: value,
                                                        height: 30,
                                                        child: Text(value),
                                                      )).toList();
                                                },
                                                child: Text(
                                                  vm.conditionLibraryData
                                                      .conditionLibrary
                                                      .condition[index].value,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 5),
                                      Container(
                                        width: double.infinity,
                                        height: 27,
                                        decoration: BoxDecoration(
                                            color: Theme
                                                .of(context)
                                                .primaryColor
                                                .withValues(alpha: 0.05),
                                            borderRadius: BorderRadius.circular(
                                                3),
                                            border: Border.all(
                                                width: 0.5,
                                                color: Colors.grey.shade400
                                            )
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.only(
                                              left: 5, top: 3),
                                          child: PopupMenuButton<String>(
                                            onSelected: (
                                                String selectedValue) =>
                                                vm.reasonOnChange(
                                                    selectedValue, index),
                                            itemBuilder: (
                                                BuildContext context) {
                                              return [
                                                '--',
                                                'Low flow',
                                                'High flow',
                                                'No flow',
                                                'High pressure',
                                                'Low pressure',
                                                'Over heating',
                                                'Low level',
                                                'High level',
                                                'Time limit',
                                                'Dry run'
                                              ]
                                                  .map((String value) =>
                                                  PopupMenuItem<String>(
                                                    value: value,
                                                    height: 30,
                                                    child: Text(value),
                                                  )).toList();
                                            },
                                            child: Text(
                                              vm.conditionLibraryData
                                                  .conditionLibrary
                                                  .condition[index].reason,
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 5),
                                      Container(
                                        width: double.infinity,
                                        height: 27,
                                        decoration: BoxDecoration(
                                            color: Theme
                                                .of(context)
                                                .primaryColor
                                                .withValues(alpha: 0.05),
                                            borderRadius: BorderRadius.circular(
                                                3),
                                            border: Border.all(
                                                width: 0.5,
                                                color: Colors.grey.shade400
                                            )
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.only(
                                              left: 5, top: 3),
                                          child: PopupMenuButton<String>(
                                            onSelected: (String selectedValue) {
                                              vm.delayTimeOnChange(
                                                  selectedValue, index);
                                            },
                                            itemBuilder: (
                                                BuildContext context) {
                                              return [
                                                '--',
                                                '3 Sec',
                                                '5 Sec',
                                                '10 Sec',
                                                '20 Sec',
                                                '30 Sec'
                                              ]
                                                  .map((String value) =>
                                                  PopupMenuItem<String>(
                                                    value: value,
                                                    height: 30,
                                                    child: Text(value),
                                                  )).toList();
                                            },
                                            child: Text(
                                              vm.conditionLibraryData
                                                  .conditionLibrary
                                                  .condition[index].delayTime,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 10),
                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: TextFormField(
                              maxLength: 100,
                              controller: vm.amTEVControllers[index],
                              decoration: const InputDecoration(
                                counterText: '',
                                labelText: 'Alert message',
                                contentPadding: EdgeInsets.symmetric(
                                    vertical: 10.0, horizontal: 10.0),
                                enabledBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(color: Colors.black12),
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please fill out this field';
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ) :
              const Center(child: Text('No condition available')),
            ),
            floatingActionButton: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Total : ${vm.conditionLibraryData.conditionLibrary
                    .condition.length} of '
                    '${vm.conditionLibraryData.defaultData.conditionLimit}'),
                const SizedBox(width: 10),
                MaterialButton(
                  color: Theme
                      .of(context)
                      .primaryColor,
                  textColor: Colors.white,
                  onPressed: vm.conditionLibraryData.conditionLibrary.condition
                      .length !=
                      vm.conditionLibraryData.defaultData.conditionLimit ?
                      () => vm.createNewCondition() :
                  null,
                  child: const Text('Create condition'),
                ),
                const SizedBox(width: 10), // Spacing between buttons
                MaterialButton(
                  color: Colors.green,
                  textColor: Colors.white,
                  onPressed: () => vm.saveConditionLibrary(
                      context, customerId, controllerId, userId, deviceId),
                  child: const Text('Save'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}