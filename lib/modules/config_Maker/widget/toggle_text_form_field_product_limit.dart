import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:oro_drip_irrigation/utils/constants.dart';
import '../../../Constants/communication_codes.dart';
import '../../../Constants/dialog_boxes.dart';
import '../model/device_object_model.dart';
import '../view/product_limit.dart';
import '../state_management/config_maker_provider.dart';

class ToggleTextFormFieldForProductLimit extends StatefulWidget {
  final ConfigMakerProvider configPvd;
  String initialValue;
  DeviceObjectModel object;
  Color leadingColor;
  ToggleTextFormFieldForProductLimit({super.key,required this.initialValue, required this.object, required this.configPvd,required this.leadingColor});

  @override
  State<ToggleTextFormFieldForProductLimit> createState() => _ToggleTextFormFieldForProductLimitState();
}

class _ToggleTextFormFieldForProductLimitState extends State<ToggleTextFormFieldForProductLimit> {
  FocusNode myFocus = FocusNode();
  late TextEditingController myController;
  bool focus = false;
  bool isEditing = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    myController = TextEditingController();
    myController.text = widget.initialValue;
    if(mounted) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        myFocus.addListener(() {
          if(!myFocus.hasFocus){
            toggleEditing();
            var integerValue = myController.text == '' ? 0 : int.parse(myController.text);


            if(widget.object.type == '-'){
              /* there is no validation for places eg: source, line, site. */
              widget.configPvd.updateObjectCount(widget.object.objectId, integerValue.toString());
            }else{
              /* do validate expect source, line, site. */
              int availableCount = widget.object.type == '1,2'
                  ? balanceCountForRelayLatch(widget.configPvd)
                  : balanceCountForInputType(int.parse(widget.object.type ), widget.configPvd);

              /* filter output object for pump with valve model*/
              if(AppConstants.pumpWithValveModelList.contains(widget.configPvd.masterData['modelId'])){
                if(widget.object.objectId == AppConstants.pumpObjectId){
                  /*only one pump allowed to config*/
                  int maxAllowablePumpCount = 1;
                  if(integerValue > maxAllowablePumpCount){
                    simpleDialogBox(context: context, title: 'Alert', message: 'Only one ${widget.object.objectName} should be connect with ${widget.configPvd.masterData['deviceName']}.');
                    integerValue = maxAllowablePumpCount;
                  }
                  widget.configPvd.updateObjectCount(widget.object.objectId, integerValue.toString());
                }
              }

              /*gem and pump validation*/
              if(widget.object.type != '-'){
                availableCount += widget.initialValue == '' ? 0 : int.parse(widget.initialValue);
                if(integerValue > availableCount){
                  simpleDialogBox(context: context, title: 'Alert', message: 'The maximum allowable value is $availableCount. Please enter a value less than or equal to $availableCount.');
                  widget.configPvd.updateObjectCount(widget.object.objectId, availableCount.toString());
                }else{
                  if(AppConstants.pumpModelList.contains(widget.configPvd.masterData['modelId'])){
                    if([AppConstants.levelObjectId, AppConstants.waterMeterObjectId, AppConstants.pressureSensorObjectId].contains(widget.object.objectId)){
                      if(integerValue > 1){ // level, pressure, water meter -- oro pump
                        simpleDialogBox(context: context, title: 'Alert', message: 'Only one ${widget.object.objectName} should be connect with ${widget.configPvd.masterData['deviceName']}.');
                        widget.configPvd.updateObjectCount(widget.object.objectId, '1');
                      }else{
                        widget.configPvd.updateObjectCount(widget.object.objectId, integerValue.toString());
                      }
                    }else{ // float -- oro pump
                      if(integerValue > availableCount){
                        simpleDialogBox(context: context, title: 'Alert', message: 'The maximum allowable value is $availableCount. Please enter a value less than or equal to $availableCount.');
                        widget.configPvd.updateObjectCount(widget.object.objectId, availableCount.toString());
                      }else{
                        widget.configPvd.updateObjectCount(widget.object.objectId, integerValue.toString());
                      }
                    }
                  }else{
                    widget.configPvd.updateObjectCount(widget.object.objectId, integerValue.toString());
                  }
                }
              }
              else{
                widget.configPvd.updateObjectCount(widget.object.objectId, integerValue.toString());
              }
            }

            setState(() {
              focus = false;
            });
          }
          if(myFocus.hasFocus == true){
            setState(() {
              focus = true;
            });
          }
        });
      });
    }
  }

  void validateAndUpdateObjectCount(DeviceObjectModel object,int newCount){
    List<DeviceObjectModel> availableObject = widget.configPvd.listOfGeneratedObject.where((available) => (available.objectId == object.objectId)).toList();
    if(availableObject.length >= newCount){
      widget.configPvd.updateObjectCount(object.objectId, newCount.toString());
    }
  }

  @override
  void dispose() {
    myController.dispose();
    myFocus.dispose();
    super.dispose();
  }

  void toggleEditing() {
    setState(() {
      isEditing = !isEditing;
      if (isEditing) {
        myFocus.requestFocus();
      }
    });
  }


  @override
  Widget build(BuildContext context) {
    if(focus == false){
      myController.text = widget.initialValue;
    }
    if(!editable()){
      return const Text('Limit reached');
    }
    bool themeMode = Theme.of(context).brightness == Brightness.light;
    return GestureDetector(
      onTap: toggleEditing,
      child: isEditing
          ? SizedBox(
        width: 80,
        child: TextFormField(
          focusNode: myFocus,
          controller: myController,
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
          ],
          onFieldSubmitted: (value){

          },
          maxLength: 2,
          onChanged: (value){

          },
          textAlign: TextAlign.center,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
              counterText: '',
              border: OutlineInputBorder(
                  borderSide: BorderSide.none
              )
          ),
        ),
      )
          : Container(
          margin: const EdgeInsets.all(2),
          width: 90,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5),
          ),
          height: double.infinity,
          child: Center(child: Text(widget.initialValue, style: const TextStyle(fontSize: 14,fontWeight: FontWeight.w600),))
      ),
    );
  }

  bool editable(){
    bool visible = true;
    if(widget.object.type == '1,2'){
      if(balanceCountForRelayLatch(widget.configPvd) == 0 && ['', '0'].contains(widget.object.count)){
        visible = false;
      }
    }else if(widget.object.type != '-'){
      if(balanceCountForInputType(int.parse(widget.object.type), widget.configPvd) == 0 && ['', '0'].contains(widget.object.count)){
        visible = false;
      }
    }
    return visible;
  }

}
