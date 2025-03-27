import 'package:flutter/material.dart';
import 'package:oro_drip_irrigation/modules/constant/widget/custom_check_box.dart';
import 'package:oro_drip_irrigation/modules/constant/widget/custom_pop_up_button.dart';

import '../../../Widgets/HoursMinutesSeconds.dart';
import '../model/constant_setting_model.dart';
import '../model/constant_setting_type_Model.dart';
import 'custom_switch.dart';
import 'custom_text_form_field.dart';

class FindSuitableWidget extends StatefulWidget {
  final List<PopUpItemModel> popUpItemModelList;
  ConstantSettingModel constantSettingModel;
  void Function(dynamic) onUpdate;
  void Function() onOk;
  FindSuitableWidget({super.key, required this.constantSettingModel, required this.onUpdate, required this.onOk, required this.popUpItemModelList});
  @override
  State<FindSuitableWidget> createState() => _FindSuitableWidgetState();
}

class _FindSuitableWidgetState extends State<FindSuitableWidget> {
  @override
  Widget build(BuildContext context) {
    print("widget.constantSettingModel.value : ${widget.constantSettingModel.value} - ${widget.constantSettingModel.value.runtimeType}");
    if(widget.constantSettingModel.widgetTypeId == 1){
      return CustomTextFormField(
          value: widget.constantSettingModel.value.value.toString(),
          dataType: widget.constantSettingModel.dataType,
          onChanged: widget.onUpdate
      );
    }
    else if(widget.constantSettingModel.widgetTypeId == 2){
      return CustomSwitch(
          value: widget.constantSettingModel.value.value,
          onChanged: widget.onUpdate
      );
    }
    else if(widget.constantSettingModel.widgetTypeId == 3){
      return Center(
        child: InkWell(
          onTap: (){
            showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    content:
                    HoursMinutesSeconds(
                      initialTime: widget.constantSettingModel.value.value,
                      onPressed: widget.onOk,
                    ),
                  );
                });
          },
          child: Padding(
            padding: const EdgeInsets.all(5),
            child: Text(widget.constantSettingModel.value.value),
          ),
        ),
      );
    }
    else if(widget.constantSettingModel.widgetTypeId == 6){
      return Center(
        child: CustomPopUpButton(
            popUpItemModelList: widget.popUpItemModelList,
            selectedItemSno: widget.constantSettingModel.value.value,
          onSelected: widget.onUpdate,
        ),
      );
    }
    else if(widget.constantSettingModel.widgetTypeId == 7){
      return CustomCheckBox(
          value: widget.constantSettingModel.value.value,
          onChanged: widget.onUpdate
      );
    }
    else{
      return Center(child: const Text('N/A'));
    }
  }
}
