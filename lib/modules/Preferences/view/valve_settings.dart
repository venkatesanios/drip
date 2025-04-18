import 'package:flutter/material.dart';
import 'package:oro_drip_irrigation/modules/IrrigationProgram/widgets/custom_native_time_picker.dart';
import 'package:oro_drip_irrigation/modules/Preferences/model/preference_data_model.dart';
import 'package:oro_drip_irrigation/modules/Preferences/state_management/preference_provider.dart';
import 'package:provider/provider.dart';

import '../../../view_models/customer/customer_screen_controller_view_model.dart';
import '../../IrrigationProgram/view/schedule_screen.dart';

class ValveSettings extends StatelessWidget {
  const ValveSettings({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.read<CustomerScreenControllerViewModel>();
    final valves = provider.mySiteList.data[provider.sIndex].master[provider.mIndex].configObjects.where((e) => e.objectId == 13).toList();
    return Consumer<PreferenceProvider>(
      builder: (context, provider, _) {
        final settings = provider.valveSettings!.setting;
        final firstHalf = settings.sublist(0, 5);
        final secondHalf = settings.sublist(5, 5+valves.length);

        return ListView(
          padding: const EdgeInsets.all(8),
          children: [
            ...firstHalf.map((item) => _buildSettingTile(context, item)),
            const Divider(),

           /* const Text("Select Mode:", style: TextStyle(fontWeight: FontWeight.bold)),
            Row(
              children: [
                Expanded(
                  child: RadioListTile<String>(
                    title: const Text("Duration"),
                    value: "Duration",
                    groupValue: provider.mode,
                    onChanged: (value) {
                      if (value != null) provider.updateMode(value);
                    },
                  ),
                ),
                Expanded(
                  child: RadioListTile<String>(
                    title: const Text("Manual"),
                    value: "Manual",
                    groupValue: provider.mode,
                    onChanged: (value) {
                      if (value != null) provider.updateMode(value);
                    },
                  ),
                ),
              ],
            ),

            const Divider(),*/
            ...secondHalf.map((item) => _buildSecondHalfTile(context, item, provider.mode)),
            const SizedBox(height: 60),
          ],
        );
      },
    );
  }

  Widget _buildSettingTile(BuildContext context, WidgetSetting settingItem) {
    final provider = Provider.of<PreferenceProvider>(context, listen: false);

    return ListTile(
      title: Text(settingItem.title),
      trailing: IntrinsicWidth(
        child: settingItem.widgetTypeId == 3
            ? CustomNativeTimePicker(
          initialValue: settingItem.value!,
          is24HourMode: true,
          onChanged: (newValue) {
            provider.updateSettingValue(settingItem.title, newValue);
          },
        )
            : settingItem.widgetTypeId == 2
            ? Switch(
          value: settingItem.value,
          onChanged: (newValue) {
            provider.updateSwitchValue(settingItem.title, newValue);
          },
        )
            : SizedBox(
          width: 80,
          child: TextFormField(
            key: Key(settingItem.title),
            initialValue: settingItem.value,
            textAlign: TextAlign.center,
            keyboardType: TextInputType.number,
            onChanged: (newValue) {
              provider.updateSettingValue(settingItem.title, newValue);
            },
            decoration: const InputDecoration(
              hintText: "000",
              contentPadding: EdgeInsets.symmetric(vertical: 5),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(8)),
                borderSide: BorderSide.none,
              ),
              fillColor: cardColor,
              filled: true,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSecondHalfTile(BuildContext context, WidgetSetting settingItem, String mode) {
    final provider = Provider.of<PreferenceProvider>(context, listen: false);

    return ListTile(
      title: Text(settingItem.title),
      trailing: IntrinsicWidth(
        child: mode == "Manual"
            ? Switch(
          value: provider.getSwitchState(settingItem.value),
          onChanged: (newValue) {
            provider.updateSwitchValue(settingItem.title, newValue);
          },
        )
            : CustomNativeTimePicker(
          initialValue: provider.getDuration(settingItem.value),
          is24HourMode: true,
          onChanged: (newValue) {
            provider.updateSettingValue(settingItem.title, newValue);
          },
        ),
      ),
    );
  }
}

