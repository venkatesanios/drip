import 'package:flutter/material.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:provider/provider.dart';

import '../../../../repository/repository.dart';
import '../../../../services/http_service.dart';
import '../../../../view_models/customer/condition_library_view_model.dart';
import '../widgets/component_selection_menu.dart';
import '../widgets/condition_labels_column.dart';
import '../widgets/condition_tile.dart';
import '../widgets/condition_type_selector.dart';
import '../widgets/delay_time_selection_menu.dart';
import '../widgets/parameter_selection_menu.dart';
import '../widgets/reason_selection_menu.dart';
import '../widgets/threshold_selector_widget.dart';
import '../widgets/value_selector_widget.dart';

class ConditionLibraryNarrow extends StatelessWidget {
  const ConditionLibraryNarrow({
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
              appBar: AppBar(title: const Text('Condition Library')),
              body: _buildLoadingIndicator(context),
            );
          }

          final hasConditions = vm.clData.cnLibrary.condition.isNotEmpty;
          return Scaffold(
            appBar: AppBar(title: const Text('Condition Library')),
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
        horizontal: MediaQuery.of(context).size.width / 2 - 25,
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
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount:1,
        crossAxisSpacing: 3.0,
        mainAxisSpacing: 3.0,
        childAspectRatio: 1.15,
      ),
      itemBuilder: (BuildContext context, int index) {
        return _buildConditionCard(context, vm, index);
      },
    );
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