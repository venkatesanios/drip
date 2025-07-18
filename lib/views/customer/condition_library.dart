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
  const ConditionLibrary({
    super.key,
    required this.customerId,
    required this.controllerId,
    required this.userId,
    required this.deviceId,
  });

  final int customerId;
  final int controllerId;
  final int userId;
  final String deviceId;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ConditionLibraryViewModel(Repository(HttpService()))
        ..getConditionLibraryData(customerId, controllerId),
      child: Consumer<ConditionLibraryViewModel>(
        builder: (context, vm, _) {
          if (vm.isLoading) {
            return Scaffold(
              appBar: !kIsWeb ? AppBar(title: const Text('Condition Library')) : null,
              body: _buildLoadingIndicator(context),
            );
          }

          final hasConditions = vm.clData.cnLibrary.condition.isNotEmpty;
          return Scaffold(
            appBar: !kIsWeb ? AppBar(title: const Text('Condition Library')) : null,
            body: Padding(
              padding: const EdgeInsets.all(8.0),
              child: hasConditions ? Consumer<ConditionLibraryViewModel>(
                builder: (context, vm, child) {
                  return _buildGridView(context, vm);
                },
              ) : const Center(child: Text('No condition available')),
            ),
            floatingActionButton: _buildFloatingActionButtons(context, vm),
          );
        },
      ),
    );
  }

  Widget _buildLoadingIndicator(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: kIsWeb?MediaQuery.of(context).size.width / 2 - 50:
        MediaQuery.of(context).size.width / 2 - 25,
      ),
      child: const LoadingIndicator(
        indicatorType: Indicator.ballPulse,
        strokeWidth: 100,
      ),
    );
  }



  Widget _buildGridView(BuildContext context, ConditionLibraryViewModel vm) {
    return GridView.builder(
      itemCount: vm.clData.cnLibrary.condition.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: _getCrossAxisCount(context),
        crossAxisSpacing: 3.0,
        mainAxisSpacing: 3.0,
        childAspectRatio: _getChildAspectRatio(context),
      ),
      itemBuilder: (BuildContext context, int index) {
        return _buildConditionCard(context, vm, index);
      },
    );
  }

  int _getCrossAxisCount(BuildContext context) {
    if (kIsWeb) {
      return MediaQuery.of(context).size.width > 1350 ? 3 : 2;
    } else {
      return 1;
    }
  }

  double _getChildAspectRatio(BuildContext context) {
    if (kIsWeb) {
      if (MediaQuery.of(context).size.width > 1350) {
        return MediaQuery.of(context).size.width / 1200;
      } else {
        return MediaQuery.of(context).size.width / 750;
      }
    } else {
      return 1.15;
    }
  }

  Widget _buildConditionCard(BuildContext context, ConditionLibraryViewModel vm, int index) {
    return Card(
      color: Colors.white,
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ConditionTile(
              name: vm.clData.cnLibrary.condition[index].name,
              rule: vm.clData.cnLibrary.condition[index].rule,
              status: vm.clData.cnLibrary.condition[index].status,
              onStatusChanged: (value) => vm.switchStateOnChange(value, index),
              onRemove: () => vm.removeCondition(index),
            ),
            const Divider(height: 0),
            ConditionTypeSelector(
              selectedType: vm.clData.cnLibrary.condition[index].type,
              onTypeChanged: (value) => vm.conTypeOnChange(value, index),
            ),
            const Divider(height: 0),
            _buildSelectionMenus(context, vm, index),
            const SizedBox(height: 10),
            _buildAlertMessageField(context, vm, index),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectionMenus(BuildContext context, ConditionLibraryViewModel vm, int index) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, top: 8),
      child: Row(
        children: [
          const ConditionLabelsColumn(),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ComponentSelectionMenu(index: index, vm: vm),
                const SizedBox(height: 5),
                ParameterSelectionMenu(index: index, vm: vm),
                const SizedBox(height: 5),
                Row(
                  children: [
                    ThresholdSelectorWidget(index: index, vm: vm),
                    const SizedBox(width: 5),
                    ValueSelectorWidget(index: index, vm: vm),
                  ],
                ),
                const SizedBox(height: 5),
                ReasonSelectionMenu(index: index, vm: vm),
                const SizedBox(height: 5),
                DelayTimeSelectionMenu(index: index, vm: vm),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAlertMessageField(BuildContext context, ConditionLibraryViewModel vm, int index) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: TextFormField(
        maxLength: 100,
        controller: vm.amTEVControllers[index],
        decoration: const InputDecoration(
          counterText: '',
          labelText: 'Alert message',
          contentPadding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
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
    );
  }

  Widget _buildFloatingActionButtons(BuildContext context, ConditionLibraryViewModel vm) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('Total: ${vm.clData.cnLibrary.condition.length} of ${vm.clData.defaultData.conditionLimit}'),
        const SizedBox(width: 10),
        MaterialButton(
          color: Theme.of(context).primaryColor,
          textColor: Colors.white,
          onPressed: vm.clData.cnLibrary.condition.length != vm.clData.defaultData.conditionLimit
              ? () => vm.createNewCondition()
              : null,
          child: const Text('Create condition'),
        ),
        const SizedBox(width: 10),
        MaterialButton(
          color: Colors.green,
          textColor: Colors.white,
          onPressed: () => vm.saveConditionLibrary(context, customerId, controllerId, userId, deviceId),
          child: const Text('Save'),
        ),
      ],
    );
  }
}

class ConditionTile extends StatelessWidget {
  final String name;
  final String rule;
  final bool status;
  final VoidCallback onRemove;
  final ValueChanged<bool> onStatusChanged;

  const ConditionTile({
    super.key,
    required this.name,
    required this.rule,
    required this.status,
    required this.onRemove,
    required this.onStatusChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(name, style: const TextStyle(fontSize: 15)),
            Text(rule, style: const TextStyle(fontSize: 12, color: Colors.black54)),
            const SizedBox(height: 5),
          ],
        ),
        const Spacer(),
        Transform.scale(
          scale: 0.7,
          child: Tooltip(
            message: status ? 'deactivate' : 'activate',
            child: Switch(
              hoverColor: Theme.of(context).primaryColor,
              activeColor: Theme.of(context).primaryColorLight,
              value: status,
              onChanged: onStatusChanged,
            ),
          ),
        ),
        IconButton(
          tooltip: 'Remove condition',
          onPressed: onRemove,
          icon: const Icon(Icons.remove_circle_outline, color: Colors.red),
        ),
      ],
    );
  }
}

class ConditionTypeSelector extends StatelessWidget {
  final String selectedType;
  final ValueChanged<String> onTypeChanged;

  const ConditionTypeSelector({
    super.key,
    required this.selectedType,
    required this.onTypeChanged,
  });

  @override
  Widget build(BuildContext context) {
    Widget verticalDivider() => Container(
      width: 0.5,
      height: 40,
      color: Colors.grey,
    );

    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        verticalDivider(),
        Expanded(
          child: RadioListTile<String>(
            title: const Text("Sensor"),
            value: 'Sensor',
            groupValue: selectedType,
            onChanged: (value) => onTypeChanged(value!),
            contentPadding: EdgeInsets.zero,
            visualDensity: const VisualDensity(horizontal: -4.0, vertical: -4.0),
            activeColor: Theme.of(context).primaryColorLight,
          ),
        ),
        verticalDivider(),
        Expanded(
          child: RadioListTile<String>(
            title: const Text("Program"),
            value: 'Program',
            groupValue: selectedType,
            onChanged: (value) => onTypeChanged(value!),
            contentPadding: EdgeInsets.zero,
            visualDensity: const VisualDensity(horizontal: -4.0, vertical: -4.0),
            activeColor: Theme.of(context).primaryColorLight,
          ),
        ),
        verticalDivider(),
      ],
    );
  }
}

class ComponentSelection {
  final String name;
  final String sNo;
  ComponentSelection({required this.name, required this.sNo});
}

class ConditionLabelsColumn extends StatelessWidget {
  const ConditionLabelsColumn({super.key});
  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      width: 125,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Component', style: TextStyle(color: Colors.black54)),
          SizedBox(height: 8),
          Text('Parameter', style: TextStyle(color: Colors.black54)),
          SizedBox(height: 10),
          Text('Value/Threshold', style: TextStyle(color: Colors.black54)),
          SizedBox(height: 12),
          Text('Reason', style: TextStyle(color: Colors.black54)),
          SizedBox(height: 15),
          Text('Delay Time', style: TextStyle(color: Colors.black54)),
        ],
      ),
    );
  }
}

class ComponentSelectionMenu extends StatelessWidget {
  final int index;
  final ConditionLibraryViewModel vm;
  const ComponentSelectionMenu({super.key, required this.index, required this.vm});

  @override
  Widget build(BuildContext context) {
    final condition = vm.clData.cnLibrary.condition[index];

    return Container(
      width: double.infinity,
      height: 27,
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withAlpha(12),
        borderRadius: BorderRadius.circular(3),
        border: Border.all(width: 0.5, color: Colors.grey.shade400),
      ),
      child: Padding(
        padding: const EdgeInsets.only(left: 5, top: 3),
        child: condition.type == 'Combined'? PopupMenuButton<String>(
          onSelected: (String cName) => vm.combinedTO(index, cName),
          itemBuilder: (BuildContext context) {
            return vm.getAvailableCondition(index).map((String source) {
              return CheckedPopupMenuItem<String>(
                value: source,
                height: 30,
                checked: vm.connectedTo[index].contains(source),
                child: Text(source),
              );
            }).toList();
          },
          child: Text(condition.component),
        )
            : PopupMenuButton<ComponentSelection>(
          tooltip: condition.type == 'Sensor'? 'Select your sensor':
          condition.type == 'Program'? 'Select your program': 'Select more than one conditions',
          onSelected: (ComponentSelection selected) {
            vm.componentOnChange(selected.name, index, selected.sNo);
          },
          itemBuilder: (BuildContext context) {
            if (condition.type == 'Sensor') {
              return vm.clData.defaultData.sensors.map<PopupMenuEntry<ComponentSelection>>((sensor) {
                return PopupMenuItem<ComponentSelection>(
                  value: ComponentSelection(
                    name: sensor.name,
                    sNo: sensor.sNo.toString(),
                  ),
                  height: 35,
                  child: Text(sensor.name),
                );
              }).toList();
            } else {
              return vm.clData.defaultData.program
                  .map<PopupMenuEntry<ComponentSelection>>((program) {
                return PopupMenuItem<ComponentSelection>(
                  value: ComponentSelection(
                    name: program.name,
                    sNo: program.sNo.toString(),
                  ),
                  height: 35,
                  child: Text(program.name),
                );
              }).toList();
            }
          },
          child: Text(condition.component),
        ),
      ),
    );
  }
}

class ParameterSelectionMenu extends StatelessWidget {
  final int index;
  final ConditionLibraryViewModel vm;

  const ParameterSelectionMenu({ super.key,
    required this.index,
    required this.vm,
  });

  @override
  Widget build(BuildContext context) {
    final condition = vm.clData.cnLibrary.condition[index];

    return Container(
      width: double.infinity,
      height: 27,
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withAlpha(12),
        borderRadius: BorderRadius.circular(3),
        border: Border.all(
          width: 0.5,
          color: Colors.grey.shade400,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.only(left: 5, top: 3),
        child: PopupMenuButton<String>(
          onSelected: (String selectedValue) {
            vm.parameterOnChange(selectedValue, index);
          },
          itemBuilder: (BuildContext context) {
            if (condition.type == 'Sensor') {
              final selectedSensor = vm.clData.defaultData.sensors.firstWhereOrNull((sensor) =>
              sensor.name == condition.component);

              final filteredParameters = vm
                  .clData.defaultData.sensorParameter
                  .where((param) => param.objectId == selectedSensor?.objectId)
                  .toList();

              return filteredParameters.map<PopupMenuEntry<String>>((param) {
                return PopupMenuItem<String>(
                  value: param.parameter,
                  height: 35,
                  child: Text(param.parameter),
                );
              }).toList();
            } else {
              return ['Status'].map((String value) {
                return PopupMenuItem<String>(
                  value: value,
                  height: 30,
                  child: Text(value),
                );
              }).toList();
            }
          },
          child: Text(condition.parameter),
        ),
      ),
    );
  }
}

class ThresholdSelectorWidget extends StatelessWidget {
  final int index;
  final ConditionLibraryViewModel vm;

  const ThresholdSelectorWidget({super.key, required this.index, required this.vm});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        height: 27,
        decoration: BoxDecoration(
          color: Theme.of(context).primaryColor.withOpacity(0.05),
          borderRadius: BorderRadius.circular(3),
          border: Border.all(width: 0.5, color: Colors.grey.shade400),
        ),
        child: Padding(
          padding: const EdgeInsets.only(left: 5, top: 3),
          child: PopupMenuButton<String>(
            onSelected: (String selectedValue) {
              vm.thresholdOnChange(selectedValue, index);
            },
            itemBuilder: (BuildContext context) {
              final type = vm.clData.cnLibrary.condition[index].type;
              final options = type == 'Sensor'
                  ? ['Lower than', 'Higher than', 'Equal to']
                  : type == 'Program'
                  ? ['is Running', 'is Starting', 'is Ending']
                  : ['Anyone is', 'Both are'];

              return options.map((String value) {
                return PopupMenuItem<String>(
                  value: value,
                  height: 30,
                  child: Text(value),
                );
              }).toList();
            },
            child: Text(vm.clData.cnLibrary.condition[index].threshold),
          ),
        ),
      ),
    );
  }
}

class ValueSelectorWidget extends StatelessWidget {
  final int index;
  final ConditionLibraryViewModel vm;

  const ValueSelectorWidget({super.key, required this.index, required this.vm});

  @override
  Widget build(BuildContext context) {
    final isSensor = vm.clData.cnLibrary.condition[index].type == 'Sensor';

    return isSensor?
    SensorValueButton(index: index, vm: vm, controller: vm.vtTEVControllers[index], onValueChanged: (newValue) {

      final sensor = vm.clData.defaultData.sensors.firstWhere((sensor) =>
      sensor.name == vm.clData.cnLibrary.condition[index].component,
        orElse: () => Sensor(objectId: 0, sNo: 0.0, name: '', objectName: ''),
      );

      if (sensor.objectName.isNotEmpty) {
        if(sensor.objectName=='Level Sensor'){
          bool hasPercentage = newValue.contains('%');
          if (hasPercentage) {
            vm.valueOnChange(newValue, index);
          }else{
            vm.valueOnChange('$newValue%', index);
          }
        }else{
          String unit = MyFunction().getUnitValue(context, sensor.objectName, newValue) ?? '';
          vm.valueOnChange('$newValue $unit', index);
        }
      }

    }): ProgramBooleanSelector(index: index, vm: vm);
  }
}

class SensorValueButton extends StatelessWidget {
  final ConditionLibraryViewModel vm;
  final int index;
  final Function(String) onValueChanged;
  final TextEditingController controller;


  const SensorValueButton({super.key, required this.index, required this.vm, required this.controller, required this.onValueChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100,
      height: 27,
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(3),
        border: Border.all(width: 0.5, color: Colors.grey.shade400),
      ),
      child: TextButton(
        onPressed: () => _showInputDialog(context),
        style: ButtonStyle(
          padding: WidgetStateProperty.all(EdgeInsets.zero),
          minimumSize: WidgetStateProperty.all(Size.zero),
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          backgroundColor: WidgetStateProperty.all(Colors.transparent),
        ),
        child: Text(
          vm.clData.cnLibrary.condition[index].value,
          style: const TextStyle(color: Colors.black, fontSize: 13),
          textAlign: TextAlign.left,
        ),
      ),
    );
  }

  void _showInputDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Select values and Operator'),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
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
                    controller: controller,
                    maxLength: 100,
                    readOnly: true,
                    decoration: const InputDecoration(
                      counterText: '',
                      labelText: 'Value/Threshold',
                      contentPadding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
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
                const SizedBox(height: 8),
                _buildGridView(context),
                SizedBox(
                  width: 250,
                  height: 50,
                  child: Row(
                    children: [
                      MaterialButton(
                        color: Theme.of(context).primaryColor,
                        textColor: Colors.white,
                        height: 40,
                        minWidth: 170,
                        onPressed: () {
                          controller.text += ' ';
                        },
                        child: Text('Space'),
                      ),
                      const SizedBox(width: 5),
                      MaterialButton(
                        height: 40,
                        color: Theme.of(context).primaryColorLight,
                        textColor: Colors.white,
                        onPressed: () {
                          if (controller.text.trim().isEmpty) {
                            showDialog(
                              context: context,
                              builder: (context) {
                                return AlertDialog(
                                  title: const Text("Error"),
                                  content: const Text("Field cannot be empty or contain only spaces."),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: const Text("OK"),
                                    ),
                                  ],
                                );
                              },
                            );
                          } else {
                            onValueChanged(controller.text);
                            Navigator.pop(context);
                          }
                        },
                        child: const Text('Enter'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildGridView(BuildContext context) {
    List<String> operators = ['%', '°C', '.', 'cl', 'C', '9', '8', '7', '6', '5', '4', '3', '2', '1', '0'];
    return SizedBox(
      width: 250,
      height: 150,
      child: GridView.count(
        crossAxisCount: 5,
        crossAxisSpacing: 5,
        mainAxisSpacing: 5,
        children: operators.map((operator) {
          return ElevatedButton(
            onPressed: () {
              if (operator == 'C') {
                controller.clear();
              } else if (operator == 'cl') {
                if (controller.text.isNotEmpty) {
                  controller.text = controller.text.substring(0, controller.text.length - 1);
                }
              } else {
                controller.text += operator;
              }
            },
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all(
                operator == 'C' ? Colors.redAccent : Theme.of(context).primaryColor,
              ),
            ),
            child: operator == 'cl'
                ? const Icon(Icons.backspace_outlined, color: Colors.white)
                : Text(operator, style: TextStyle(fontSize: 15, color: Colors.white)),
          );
        }).toList(),
      ),
    );
  }

}

class ProgramBooleanSelector extends StatelessWidget {
  final int index;
  final ConditionLibraryViewModel vm;

  const ProgramBooleanSelector({super.key, required this.index, required this.vm});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100,
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(3),
        border: Border.all(width: 0.5, color: Colors.grey.shade400),
      ),
      child: Padding(
        padding: const EdgeInsets.only(left: 5, top: 3),
        child: PopupMenuButton<String>(
          onSelected: (String selectedValue) {
            vm.valueOnChange(selectedValue, index);
          },
          itemBuilder: (BuildContext context) {
            return ['true', 'False'].map((String value) {
              return PopupMenuItem<String>(
                value: value,
                height: 30,
                child: Text(value),
              );
            }).toList();
          },
          child: Text(vm.clData.cnLibrary.condition[index].value),
        ),
      ),
    );
  }
}

class ReasonSelectionMenu extends StatelessWidget {
  final int index;
  final ConditionLibraryViewModel vm;
  const ReasonSelectionMenu({super.key, required this.index, required this.vm,});

  static const List<String> reasons = [
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
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 27,
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withAlpha(12),
        borderRadius: BorderRadius.circular(3),
        border: Border.all(
          width: 0.5,
          color: Colors.grey.shade400,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.only(left: 5, top: 3),
        child: PopupMenuButton<String>(
          onSelected: (String selectedValue) =>
              vm.reasonOnChange(selectedValue, index),
          itemBuilder: (BuildContext context) {
            return reasons.map((String value) {
              return PopupMenuItem<String>(
                value: value,
                height: 30,
                child: Text(value),
              );
            }).toList();
          },
          child: Text(
            vm.clData.cnLibrary.condition[index].reason,
          ),
        ),
      ),
    );
  }
}

class DelayTimeSelectionMenu extends StatelessWidget {
  final int index;
  final ConditionLibraryViewModel vm;
  const DelayTimeSelectionMenu({super.key, required this.index, required this.vm,});

  static const List<String> delayTimes = [
    '--',
    '3 Sec',
    '5 Sec',
    '10 Sec',
    '20 Sec',
    '30 Sec'
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 27,
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withAlpha(12),
        borderRadius: BorderRadius.circular(3),
        border: Border.all(
          width: 0.5,
          color: Colors.grey.shade400,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.only(left: 5, top: 3),
        child: PopupMenuButton<String>(
          onSelected: (String selectedValue) {
            vm.delayTimeOnChange(selectedValue, index);
          },
          itemBuilder: (BuildContext context) {
            return delayTimes.map((String value) {
              return PopupMenuItem<String>(
                value: value,
                height: 30,
                child: Text(value),
              );
            }).toList();
          },
          child: Text(
            vm.clData.cnLibrary.condition[index].delayTime,
          ),
        ),
      ),
    );
  }
}