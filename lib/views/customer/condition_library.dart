import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:provider/provider.dart';
import '../../repository/repository.dart';
import '../../services/http_service.dart';
import '../../view_models/customer/condition_library_view_model.dart';

class ConditionLibrary extends StatelessWidget {
  const ConditionLibrary(this.customerId, this.controllerId, {super.key});
  final int customerId, controllerId;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ConditionLibraryViewModel(Repository(HttpService()))
        ..getConditionLibraryData(customerId, controllerId),
      child: Consumer<ConditionLibraryViewModel>(
        builder: (context, viewModel, _) {
          return viewModel.isLoading?
          buildLoadingIndicator(true, MediaQuery.sizeOf(context).width)
              : Scaffold(
            backgroundColor: Colors.white,
            body: Padding(
              padding: const EdgeInsets.only(left: 8, right: 8),
              child: Column(
                children: [
                  ListTile(
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text("Used: 0 of 10"),
                        const SizedBox(width: 8),
                        IconButton(tooltip:'add new condition', onPressed: (){

                        }, icon: const Icon(Icons.add_circle))
                      ],
                    ),
                  ),
                  /*Container(
                    width: MediaQuery.sizeOf(context).width,
                    height: 100,
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(5),
                        border: Border.all(
                          color: Colors.grey.shade300,
                          width: 1,
                        )
                    ),
                    child: Column(
                      children: [
                        Container(
                          width: MediaQuery.sizeOf(context).width,
                          height: 30,
                          color: Theme.of(context).primaryColorDark.withOpacity(0.1),
                          child: Row(
                            children: [
                              const SizedBox(width: 8,),
                              const Center(child: Text('Default Condition', style: TextStyle(fontWeight: FontWeight.bold),)),
                              const Spacer(),
                              IconButton(onPressed: (){}, icon: const Icon(Icons.check)),
                              const SizedBox(width: 8,),
                            ],
                          ),
                        ),
                        SizedBox(
                          width: MediaQuery.sizeOf(context).width,
                          height: 50,
                          child: DataTable2(
                            columnSpacing: 12,
                            horizontalMargin: 12,
                            headingRowHeight: 30,
                            headingRowColor: WidgetStateProperty.all<
                                Color>(Theme.of(context).primaryColor.withValues(alpha: 0.1)),
                            dataRowHeight: 35,
                            minWidth: 600,
                            columns: const [
                              DataColumn2(
                                label: Center(child: Text('id',)),
                                fixedWidth: 40,
                              ),
                              DataColumn2(
                                label: Center(child: Text('Pump Name')),
                                size: ColumnSize.M,
                              ),
                              DataColumn2(
                                label: Center(child: Text('Parameter')),
                                size: ColumnSize.S,
                              ),
                              DataColumn2(
                                label: Center(child: Text('Value/Threshold')),
                                size: ColumnSize.M,
                              ),
                              DataColumn2(
                                label: Center(child: Text('Reason')),
                                size: ColumnSize.M,
                              ),
                              DataColumn2(
                                label: Center(child: Text('Delay Time')),
                                size: ColumnSize.S,
                              ),
                              DataColumn2(
                                label: Center(child: Text('Action')),
                                size: ColumnSize.S,
                              ),
                              DataColumn2(
                                label: Text('Alert Message'),
                                size: ColumnSize.L,
                              ),
                            ],
                            rows: List<DataRow>.generate(1,(index) => DataRow(
                              cells: [
                                DataCell(Center(
                                  child: Text(
                                    '${index + 1}',
                                  ),
                                )),
                                DataCell(Center(
                                  child: PopupMenuButton<String>(
                                    onSelected: (String selectedValue) {
                                      viewModel.pumpOnChange(selectedValue, index);
                                    },
                                    itemBuilder: (BuildContext context) {
                                      return ['--', 'pump 1', 'pump 2', 'pump 3', 'pump 4', 'pump 5']
                                          .map((String value) => PopupMenuItem<String>(
                                        value: value,
                                        height: 30,
                                        child: Text(value),
                                      )).toList();
                                    },
                                    child: Text(
                                      viewModel.selectedPump[index],
                                    ),
                                  ),
                                )),
                                DataCell(
                                  Center(
                                    child: PopupMenuButton<String>(
                                      onSelected: (String selectedValue) {
                                        viewModel.lvlSensorCountOnChange(selectedValue, index);
                                      },
                                      itemBuilder: (BuildContext context) {
                                        return ['--', 'Flow rate', 'Pressure', 'Temperature', 'Level', 'Power']
                                            .map((String value) => PopupMenuItem<String>(
                                          value: value,
                                          height: 30,
                                          child: Text(value),
                                        )).toList();
                                      },
                                      child: Text(
                                        viewModel.selectedLevelParameter[index],
                                      ),
                                    ),
                                  ),
                                ),
                                DataCell(Center(
                                  child: PopupMenuButton<String>(
                                    onSelected: (String selectedValue) {
                                      viewModel.valueOnChange(selectedValue, index);
                                    },
                                    itemBuilder: (BuildContext context) {
                                      return ['--', '< 10 L/min', '> 150 L/min', '> 120 psi', '> 80°C', '> 90%', '< 10%', '0 L/min']
                                          .map((String value) => PopupMenuItem<String>(
                                        value: value,
                                        height: 30,
                                        child: Text(value),
                                      )).toList();
                                    },
                                    child: Text(
                                      viewModel.selectedValue[index],
                                    ),
                                  ),
                                )),
                                DataCell(Center(
                                  child: PopupMenuButton<String>(
                                    onSelected: (String selectedValue) {
                                      viewModel.reasonOnChange(selectedValue, index);
                                    },
                                    itemBuilder: (BuildContext context) {
                                      return ['--', 'Low flow', 'High flow', 'No flow',
                                        'High pressure', 'Low pressure', 'Over heating',
                                        'Low level', 'High level', 'Time limit', 'Dry run']
                                          .map((String value) => PopupMenuItem<String>(
                                        value: value,
                                        height: 30,
                                        child: Text(value),
                                      )).toList();
                                    },
                                    child: Text(
                                      viewModel.selectedReason[index],
                                    ),
                                  ),
                                )),
                                DataCell(Center(
                                  child: PopupMenuButton<String>(
                                    onSelected: (String selectedValue) {
                                      viewModel.delayTimeOnChange(selectedValue, index);
                                    },
                                    itemBuilder: (BuildContext context) {
                                      return ['--', '3 Sec', '5 Sec', '10 Sec']
                                          .map((String value) => PopupMenuItem<String>(
                                        value: value,
                                        height: 30,
                                        child: Text(value),
                                      )).toList();
                                    },
                                    child: Text(
                                      viewModel.selectedDelayTime[index],
                                    ),
                                  ),
                                )),
                                DataCell(Center(
                                  child: PopupMenuButton<String>(
                                    onSelected: (String selectedValue) {
                                      viewModel.actionOnChange(selectedValue, index);
                                    },
                                    itemBuilder: (BuildContext context) {
                                      return ['--', 'Stop Pump', 'Start Pump', 'Notify & Stop Pump', 'Notify & Start Pump']
                                          .map((String value) => PopupMenuItem<String>(
                                        value: value,
                                        height: 30,
                                        child: Text(value),
                                      )).toList();
                                    },
                                    child: Text(
                                      viewModel.selectedAction[index],
                                    ),
                                  ),
                                )),
                                DataCell(PopupMenuButton<String>(
                                  onSelected: (String selectedValue) {
                                    viewModel.messageOnChange(selectedValue, index);
                                  },
                                  itemBuilder: (BuildContext context) {
                                    return ['--', 'Low flow detected in pump 1', 'High flow detected in pump 1', 'Low tank level detected', 'High tank level detected']
                                        .map((String value) => PopupMenuItem<String>(
                                      value: value,
                                      height: 30,
                                      child: Text(value),
                                    )).toList();
                                  },
                                  child: Text(
                                    viewModel.selectedMessage[index],
                                  ),
                                )),
                              ],
                            ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8,),*/
                  /*Container(
                    width: MediaQuery.sizeOf(context).width,
                    height: 250,
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(5),
                        border: Border.all(
                          color: Colors.grey.shade300,
                          width: 1,
                        )
                    ),
                    child: Column(
                      children: [
                        Container(
                          width: MediaQuery.sizeOf(context).width,
                          height: 40,
                          color: Theme.of(context).primaryColorDark.withOpacity(0.1),
                          child: Row(
                            children: [
                              const SizedBox(width: 8,),
                              const Center(child: Text('Sensor based Condition', style: TextStyle(fontWeight: FontWeight.bold),)),
                              const Spacer(),
                              IconButton(onPressed: (){}, icon: const Icon(Icons.check)),
                              const SizedBox(width: 8,),
                            ],
                          ),
                        ),
                        SizedBox(
                          width: MediaQuery.sizeOf(context).width,
                          height: 200,
                          child: DataTable2(
                            columnSpacing: 12,
                            horizontalMargin: 12,
                            headingRowHeight: 30,
                            headingRowColor: WidgetStateProperty.all<
                                Color>(Theme.of(context).primaryColor.withValues(alpha: 0.1)),
                            dataRowHeight: 35,
                            minWidth: 600,
                            columns: const [
                              DataColumn2(
                                label: Center(child: Text('id',)),
                                fixedWidth: 40,
                              ),

                              *//*DataColumn2(
                                label: Center(child: Text('Sensor Type')),
                                size: ColumnSize.M,
                              ),*//*

                              DataColumn2(
                                label: Center(child: Text('Sensor Name')),
                                size: ColumnSize.M,
                              ),

                              DataColumn2(
                                label: Center(child: Text('Parameter')),
                                size: ColumnSize.S,
                              ),
                              DataColumn2(
                                label: Center(child: Text('Value/Threshold')),
                                size: ColumnSize.M,
                              ),
                              DataColumn2(
                                label: Center(child: Text('Reason')),
                                size: ColumnSize.M,
                              ),
                              DataColumn2(
                                label: Center(child: Text('Delay Time')),
                                size: ColumnSize.S,
                              ),
                              DataColumn2(
                                label: Center(child: Text('Action')),
                                size: ColumnSize.S,
                              ),
                            ],
                            rows: List<DataRow>.generate(4,(index) => DataRow(
                              cells: [
                                DataCell(Center(
                                  child: Text(
                                    '${index + 1}',
                                  ),
                                )),
                                *//*DataCell(Center(
                                  child: PopupMenuButton<String>(
                                    onSelected: (String selectedValue) {
                                      viewModel.componentOnChange(selectedValue, index);
                                    },
                                    itemBuilder: (BuildContext context) {
                                      return ['--',  'Flow meter', 'Pressure sensor', 'Level sensor', 'Moisture sensor']
                                          .map((String value) => PopupMenuItem<String>(
                                        value: value,
                                        height: 30,
                                        child: Text(value),
                                      )).toList();
                                    },
                                    child: Text(
                                      viewModel.selectedComponent[index],
                                    ),
                                  ),
                                )),*//*
                                DataCell(Center(
                                  child: PopupMenuButton<String>(
                                    onSelected: (String selectedValue) {
                                      viewModel.sensorOnChange(selectedValue, index);
                                    },
                                    itemBuilder: (BuildContext context) {
                                      return ['--',  'flow meter 1', 'Pressure Sensor 1', 'Pressure Sensor 2', 'flow meter 2', 'pressure switch', 'moisture sensor 1', 'level sensor 1']
                                          .map((String value) => PopupMenuItem<String>(
                                        value: value,
                                        height: 30,
                                        child: Text(value),
                                      )).toList();
                                    },
                                    child: Text(
                                      viewModel.selectedSensor[index],
                                    ),
                                  ),
                                )),
                                DataCell(
                                  Center(
                                    child: PopupMenuButton<String>(
                                      onSelected: (String selectedValue) {
                                        viewModel.lvlSensorCountOnChange(selectedValue, index);
                                      },
                                      itemBuilder: (BuildContext context) {
                                        return ['--', 'Flow rate', 'Pressure', 'Temperature', 'Level', 'Power']
                                            .map((String value) => PopupMenuItem<String>(
                                          value: value,
                                          height: 30,
                                          child: Text(value),
                                        )).toList();
                                      },
                                      child: Text(
                                        viewModel.selectedLevelParameter[index],
                                      ),
                                    ),
                                  ),
                                ),
                                DataCell(Center(
                                  child: PopupMenuButton<String>(
                                    onSelected: (String selectedValue) {
                                      viewModel.valueOnChange(selectedValue, index);
                                    },
                                    itemBuilder: (BuildContext context) {
                                      return ['--', '< 10 L/min', '> 150 L/min', '> 120 psi', '> 80°C', '> 90%', '< 10%', '0 L/min']
                                          .map((String value) => PopupMenuItem<String>(
                                        value: value,
                                        height: 30,
                                        child: Text(value),
                                      )).toList();
                                    },
                                    child: Text(
                                      viewModel.selectedValue[index],
                                    ),
                                  ),
                                )),
                                DataCell(Center(
                                  child: PopupMenuButton<String>(
                                    onSelected: (String selectedValue) {
                                      viewModel.reasonOnChange(selectedValue, index);
                                    },
                                    itemBuilder: (BuildContext context) {
                                      return ['--', 'Low flow', 'High flow', 'No flow',
                                        'High pressure', 'Low pressure', 'Over heating',
                                        'Low level', 'High level', 'Time limit', 'Dry run']
                                          .map((String value) => PopupMenuItem<String>(
                                        value: value,
                                        height: 30,
                                        child: Text(value),
                                      )).toList();
                                    },
                                    child: Text(
                                      viewModel.selectedReason[index],
                                    ),
                                  ),
                                )),
                                DataCell(Center(
                                  child: PopupMenuButton<String>(
                                    onSelected: (String selectedValue) {
                                      viewModel.delayTimeOnChange(selectedValue, index);
                                    },
                                    itemBuilder: (BuildContext context) {
                                      return ['--', '3 Sec', '5 Sec', '10 Sec']
                                          .map((String value) => PopupMenuItem<String>(
                                        value: value,
                                        height: 30,
                                        child: Text(value),
                                      )).toList();
                                    },
                                    child: Text(
                                      viewModel.selectedDelayTime[index],
                                    ),
                                  ),
                                )),
                                DataCell(Center(
                                  child: PopupMenuButton<String>(
                                    onSelected: (String selectedValue) {
                                      viewModel.actionOnChange(selectedValue, index);
                                    },
                                    itemBuilder: (BuildContext context) {
                                      return ['--', 'turn_on', 'turn_off', 'turn_on & Notify', 'turn_off & Notify',]
                                          .map((String value) => PopupMenuItem<String>(
                                        value: value,
                                        height: 30,
                                        child: Text(value),
                                      )).toList();
                                    },
                                    child: Text(
                                      viewModel.selectedAction[index],
                                    ),
                                  ),
                                )),
                              ],
                            ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),*/

                  Expanded(
                    child: GridView.builder(
                      itemCount: 3, // Number of items in the grid
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 5.0,
                        mainAxisSpacing: 5.0,
                        childAspectRatio: 1.45,
                      ),
                      itemBuilder: (BuildContext context, int index) {
                        return Card(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              children: [
                                const SizedBox(
                                  width: 125,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('Name', style: TextStyle(color: Colors.black54)),
                                      SizedBox(height: 10),
                                      Text('Sensor Name', style: TextStyle(color: Colors.black54)),
                                      SizedBox(height: 10),
                                      Text('Parameter', style: TextStyle(color: Colors.black54)),
                                      SizedBox(height: 10),
                                      Text('Value/Threshold', style: TextStyle(color: Colors.black54)),
                                      SizedBox(height: 10),
                                      Text('Reason', style: TextStyle(color: Colors.black54)),
                                      SizedBox(height: 10),
                                      Text('Delay Time', style: TextStyle(color: Colors.black54)),
                                      SizedBox(height: 10),
                                      Text('Action', style: TextStyle(color: Colors.black54)),
                                      SizedBox(height: 20),
                                      Text('Alert Message', style: TextStyle(color: Colors.black54)),
                                    ],
                                  ),
                                ),
                                const SizedBox(
                                  width: 20,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      Text(':'),
                                      SizedBox(height: 10),
                                      Text(':'),
                                      SizedBox(height: 10),
                                      Text(':'),
                                      SizedBox(height: 10),
                                      Text(':'),
                                      SizedBox(height: 10),
                                      Text(':'),
                                      SizedBox(height: 10),
                                      Text(':'),
                                      SizedBox(height: 10),
                                      Text(':'),
                                      SizedBox(height: 20),
                                      Text(':'),
                                    ],
                                  ),
                                ),
                                Expanded(
                                  flex: 1,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('Condition ${index + 1}'),
                                      const SizedBox(height: 10),
                                      PopupMenuButton<String>(
                                        onSelected: (String selectedValue) {
                                          viewModel.sensorOnChange(selectedValue, index);
                                        },
                                        itemBuilder: (BuildContext context) {
                                          return ['--',  'flow meter 1', 'Pressure Sensor 1', 'Pressure Sensor 2', 'flow meter 2', 'pressure switch', 'moisture sensor 1', 'level sensor 1']
                                              .map((String value) => PopupMenuItem<String>(
                                            value: value,
                                            height: 30,
                                            child: Text(value),
                                          )).toList();
                                        },
                                        child: Text(
                                          viewModel.selectedSensor[index],
                                        ),
                                      ),
                                      const SizedBox(height: 10),
                                      PopupMenuButton<String>(
                                        onSelected: (String selectedValue) {
                                          viewModel.lvlSensorCountOnChange(selectedValue, index);
                                        },
                                        itemBuilder: (BuildContext context) {
                                          return ['--', 'Flow rate', 'Pressure', 'Temperature', 'Level', 'Power']
                                              .map((String value) => PopupMenuItem<String>(
                                            value: value,
                                            height: 30,
                                            child: Text(value),
                                          )).toList();
                                        },
                                        child: Text(
                                          viewModel.selectedLevelParameter[index],
                                        ),
                                      ),
                                      const SizedBox(height: 10),
                                      PopupMenuButton<String>(
                                        onSelected: (String selectedValue) {
                                          viewModel.valueOnChange(selectedValue, index);
                                        },
                                        itemBuilder: (BuildContext context) {
                                          return ['--', '< 10 L/min', '> 150 L/min', '> 120 psi', '> 80°C', '> 90%', '< 10%', '0 L/min']
                                              .map((String value) => PopupMenuItem<String>(
                                            value: value,
                                            height: 30,
                                            child: Text(value),
                                          )).toList();
                                        },
                                        child: Text(
                                          viewModel.selectedValue[index],
                                        ),
                                      ),
                                      const SizedBox(height: 10),
                                      PopupMenuButton<String>(
                                        onSelected: (String selectedValue) {
                                          viewModel.reasonOnChange(selectedValue, index);
                                        },
                                        itemBuilder: (BuildContext context) {
                                          return ['--', 'Low flow', 'High flow', 'No flow',
                                            'High pressure', 'Low pressure', 'Over heating',
                                            'Low level', 'High level', 'Time limit', 'Dry run']
                                              .map((String value) => PopupMenuItem<String>(
                                            value: value,
                                            height: 30,
                                            child: Text(value),
                                          )).toList();
                                        },
                                        child: Text(
                                          viewModel.selectedReason[index],
                                        ),
                                      ),
                                      const SizedBox(height: 10),
                                      PopupMenuButton<String>(
                                        onSelected: (String selectedValue) {
                                          viewModel.delayTimeOnChange(selectedValue, index);
                                        },
                                        itemBuilder: (BuildContext context) {
                                          return ['--', '3 Sec', '5 Sec', '10 Sec']
                                              .map((String value) => PopupMenuItem<String>(
                                            value: value,
                                            height: 30,
                                            child: Text(value),
                                          )).toList();
                                        },
                                        child: Text(
                                          viewModel.selectedDelayTime[index],
                                        ),
                                      ),
                                      const SizedBox(height: 10),
                                      PopupMenuButton<String>(
                                        onSelected: (String selectedValue) {
                                          viewModel.actionOnChange(selectedValue, index);
                                        },
                                        itemBuilder: (BuildContext context) {
                                          return ['--', 'turn_on', 'turn_off', 'turn_on & Notify', 'turn_off & Notify',]
                                              .map((String value) => PopupMenuItem<String>(
                                            value: value,
                                            height: 30,
                                            child: Text(value),
                                          )).toList();
                                        },
                                        child: Text(
                                          viewModel.selectedAction[index],
                                        ),
                                      ),
                                      const SizedBox(height: 10),
                                      TextField(),
                                    ],
                                  ),
                                ),

                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  )
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget buildLoadingIndicator(bool isVisible, double width) {
    return Visibility(
      visible: isVisible,
      child: Container(
        color: Colors.white,
        padding: EdgeInsets.symmetric(horizontal: width / 2 - 25),
        child: const LoadingIndicator(
          indicatorType: Indicator.ballPulse,
        ),
      ),
    );
  }
}
