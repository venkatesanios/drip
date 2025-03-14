import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:oro_drip_irrigation/Widgets/sized_image.dart';
import 'package:oro_drip_irrigation/modules/calibration/repository/calibration_repository.dart';
import 'package:responsive_grid_list/responsive_grid_list.dart';
import '../../../Constants/properties.dart';
import '../../../Widgets/custom_buttons.dart';
import '../../../Widgets/status_box.dart';
import '../../config_Maker/view/config_web_view.dart';
import '../../../utils/constants.dart';
import '../../../utils/environment.dart';
import '../model/sensor_category_model.dart';
import 'package:oro_drip_irrigation/services/mqtt_manager_mobile.dart' if (dart.library.html) 'package:oro_drip_irrigation/services/mqtt_manager_web.dart';


class CalibrationScreen extends StatefulWidget {
  final Map<String, dynamic> userData;
  const CalibrationScreen({super.key, required this.userData,});

  @override
  State<CalibrationScreen> createState() => _CalibrationScreenState();
}

class _CalibrationScreenState extends State<CalibrationScreen> {
  late Future<List<SensorCategoryModel>> listOfSensorCategoryModel;
  late Map<String, dynamic> defaultData;
  Set<int> selectedTab = {0};
  HardwareAcknowledgementSate payloadState = HardwareAcknowledgementSate.notSent;
  MqttManager mqttManager = MqttManager();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    listOfSensorCategoryModel = getCalibration(widget.userData);
  }

  Future<List<SensorCategoryModel>> getCalibration(userData) async {
    List<SensorCategoryModel> calibrationData = [];
    try {
      var body = {
        "userId": userData['userId'],
        "controllerId": userData['controllerId'],
      };
      var response = await CalibrationRepository().getUserCalibration(body);
      Map<String, dynamic> jsonData = jsonDecode(response.body);
      calibrationData = (jsonData['data']['calibration'] as List<dynamic>).map((element){
        return SensorCategoryModel.fromJson(element);
      }).toList();
      setState(() {
        defaultData = jsonData['data']['default'];
      });

    } catch (e, stackTrace) {
      print('error :: $e');
      print('stackTrace :: $stackTrace');
      rethrow;
    }
    return calibrationData;
  }


  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<SensorCategoryModel>>(
        future: listOfSensorCategoryModel,
        builder: (context, snapshot){
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator()); // Loading state
          } else if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}'); // Error state
          } else if (snapshot.hasData) {
            return Scaffold(
              backgroundColor: Colors.white,
              floatingActionButton: getFloatingActionButton(snapshot.data!),
              body: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        getCalibrationCategory(),
                        const SizedBox(height: 20,),
                        ...getFilterByMaximumAndFactor(snapshot.data!),
                      ],
                    ),
                  ),
                ),
              ),
            );
          } else {
            return const Text('No data'); // Shouldn't reach here normally
          }

        }
    );
  }

  List<Widget> getFilterByMaximumAndFactor(List<SensorCategoryModel> data){
    return [
      for(var sensorCategory in data)
        if(defaultData[selectedTab.first == 0 ? 'maximum' : 'factor'].contains(sensorCategory.objectTypeId.toString()))
          Column(
          spacing: 10,
          children: [
            sensorCategoryWidget(sensorCategory),
            ResponsiveGridList(
              horizontalGridMargin: 20,
              verticalGridMargin: 10,
              minItemWidth: 250,
              shrinkWrap: true,
              listViewBuilderOptions: ListViewBuilderOptions(
                physics: const NeverScrollableScrollPhysics(),
              ),
              children: sensorCategory.calibrationObject.map((object){
                return PhysicalModel(
                  color: Theme.of(context).cardColor,
                  elevation: 8,
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5),
                        // color: Theme.of(context).cardColor,
                        // boxShadow: [
                        //   BoxShadow(
                        //       offset: const Offset(0,5),
                        //       blurRadius: 10,
                        //       color: Colors.black.withOpacity(0.06)
                        //   ),
                        //   BoxShadow(
                        //       offset: const Offset(5,5),
                        //       blurRadius: 5,
                        //       color: Colors.black.withOpacity(0.06)
                        //   ),
                        // ]
                    ),
                    width: 250,
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(vertical: 5, horizontal: 5),
                      title: Text('    ${object.objectName}', style: Theme.of(context).textTheme.labelLarge, overflow: TextOverflow.ellipsis,),
                      trailing: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5),
                          border: Border.all(width: 1, color: const Color(0xffd7d7d7)),
                          color: Theme.of(context).primaryColorDark.withOpacity(0.04),
                        ),
                        width: 80,
                        child: TextFormField(
                          key: Key('${selectedTab.first}'),
                          inputFormatters: AppProperties.regexForDecimal,
                          initialValue: selectedTab.first == 0 ? object.maximumValue : object.calibrationFactor,
                          onChanged: (value){
                            setState(() {
                              if(selectedTab.first == 0){
                                object.maximumValue = value;
                              }else{
                                object.calibrationFactor = value;
                              }
                            });
                  
                          },
                          textAlign: TextAlign.center,
                          keyboardType: TextInputType.number,
                          cursorHeight: 20,
                          decoration: const InputDecoration(
                            contentPadding: EdgeInsets.only(bottom: 10),
                            constraints: BoxConstraints(maxHeight: 35),
                              counterText: '',
                              border: OutlineInputBorder(
                                borderSide: BorderSide.none
                              )
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }).toList()
            ),
            const SizedBox(height: 20,)
          ],
        )
    ];
  }

  Widget sensorCategoryWidget(SensorCategoryModel sensorCategory){
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 5,horizontal: 10),
      width: double.infinity,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Theme.of(context).primaryColorDark.withOpacity(0.04),
          border: Border.all(width: 1, color: Theme.of(context).primaryColorDark.withOpacity(0.2))
      ),
      alignment: Alignment.centerLeft,
      child: Row(
        spacing: 10,
        children: [
          CircleAvatar(
              radius: 20,
              backgroundColor: Theme.of(context).primaryColor,
              child: SizedImage(imagePath: '${AppConstants.svgObjectPath}objectId_${sensorCategory.objectTypeId}.svg')
          ),
          Text(sensorCategory.object, style: Theme.of(context).textTheme.labelLarge,),
        ],
      ),
    );
  }

  Widget getCalibrationCategory(){
    return SegmentedButton<int>(
      style: ButtonStyle(
        shape: WidgetStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)))
      ),
      segments: [
        getButtonSegment(0, "Calibration"),
        getButtonSegment(1, "Factor"),
      ],
      selected: selectedTab,
      onSelectionChanged: (Set<int> newSelection) {
        setState(() {
          selectedTab = newSelection;
        });
      },
    );
  }

  ButtonSegment<int> getButtonSegment(int value, String title){
    return ButtonSegment(
        value: value,
        label: Container(
          width: 100,
          padding: const EdgeInsets.all(15.0),
          child: Text(title, style: const TextStyle(fontSize: 14),),
        )
    );
  }

  Widget getFloatingActionButton(List<SensorCategoryModel> sensorCategoryModel){
    return FloatingActionButton(
      onPressed: (){
        setState(() {
          payloadState = HardwareAcknowledgementSate.notSent;
          mqttManager.payload = null;
        });
        showDialog(
          barrierDismissible: false,
            context: context,
            builder: (context){
              return StatefulBuilder(
                  builder: (context, stateSetter){
                    return AlertDialog(
                      title: Text('Send Payload', style: Theme.of(context).textTheme.labelLarge,),
                      content: getHardwareAcknowledgementWidget(payloadState),
                      actions: [
                        if(payloadState != HardwareAcknowledgementSate.sending && payloadState != HardwareAcknowledgementSate.notSent)
                          CustomMaterialButton(),
                        if(payloadState == HardwareAcknowledgementSate.notSent)
                          CustomMaterialButton(title: 'Cancel',outlined: true,),
                        if(payloadState == HardwareAcknowledgementSate.notSent)
                          CustomMaterialButton(
                            onPressed: ()async{
                              sendToHttp(sensorCategoryModel);
                              if(mqttManager.connectionState == MqttConnectionState.connected){
                                mqttManager.topicToSubscribe('${Environment.mqttSubscribeTopic}/${widget.userData['deviceId']}');
                                print('subscribe successfully...........');
                              }
                              var payload = jsonEncode(getCalibrationPayload(sensorCategoryModel));
                              int delayDuration = 5;
                              for(var delay = 0; delay < delayDuration; delay++){
                                if(delay == 0){
                                  stateSetter((){
                                    setState((){
                                      mqttManager.topicToPublishAndItsMessage('${Environment.mqttPublishTopic}/${widget.userData['deviceId']}', payload);
                                      payloadState = HardwareAcknowledgementSate.sending;
                                    });
                                  });
                                }
                                stateSetter((){
                                  setState((){
                                    if(mqttManager.payload != null){
                                      if(validatePayloadFromHardware(mqttManager.payload!, ['cC'], widget.userData['deviceId']) && validatePayloadFromHardware(mqttManager.payload!, ['cM', '4201', 'PayloadCode'], '4600')){
                                        if(mqttManager.payload!['cM']['4201']['Code'] == '200'){
                                          payloadState = HardwareAcknowledgementSate.success;
                                        }else if(mqttManager.payload!['cM']['4201']['Code'] == '90'){
                                          payloadState = HardwareAcknowledgementSate.programRunning;
                                        }else if(mqttManager.payload!['cM']['4201']['Code'] == '1'){
                                          payloadState = HardwareAcknowledgementSate.hardwareUnknownError;
                                        }else{
                                          payloadState = HardwareAcknowledgementSate.errorOnPayload;
                                        }
                                        mqttManager.payload == null;
                                      }
                                    }
                                  });
                                });
                                await Future.delayed(const Duration(seconds: 1));
                                if(delay == delayDuration-1){
                                  stateSetter((){
                                    setState((){
                                      payloadState = HardwareAcknowledgementSate.failed;
                                    });
                                  });
                                }
                                if(payloadState != HardwareAcknowledgementSate.sending){
                                  break;
                                }
                              }
                            },
                            title: 'Send',
                          ),

                      ],
                    );
                  }
              );
            }
        );
      },
      child: const Icon(Icons.send),
    );
  }

  void sendToHttp(List<SensorCategoryModel> sensorCategoryModel)async{
    var body = {
      "userId" : widget.userData['userId'],
      "controllerId" : widget.userData['controllerId'],
      'calibration' : sensorCategoryModel.map((sensorCategory) => sensorCategory.toJson()).toList(),
      "createUser" : widget.userData['userId']
    };
    var response = await CalibrationRepository().createUserCalibration(body);
    print('response calibration : ${response.body}');
  }

  Map<String, dynamic> getCalibrationPayload(List<SensorCategoryModel> sensorCategory){
    var payloadWithOutWeather = sensorCategory.map((category) {
      return category.calibrationObject.map((object) {
        return {
          'S_No' : object.sNo,
          'CalibrationValue' : object.calibrationFactor.isEmpty ? 1.0 : object.calibrationFactor,
          'MaximumValue' : object.maximumValue.isEmpty ? 1.0 : object.maximumValue,
        }.entries.map((obj) => obj.value).join(',');
      }).toList();
    }).expand((list) => list).toList().join(';');
    var calibrationPayload = {
      "4600" :{
        "4601" :payloadWithOutWeather
      }
    };
    return calibrationPayload;
  }
  
  Widget getHardwareAcknowledgementWidget(HardwareAcknowledgementSate state){
    print('state : $state');
    if(state == HardwareAcknowledgementSate.notSent){
      return const StatusBox(color:  Colors.black87,child: Text('Do you want to send payload..',),);
    }else if(state == HardwareAcknowledgementSate.success){
      return const StatusBox(color:  Colors.green,child: Text('Success..',),);
    }else if(state == HardwareAcknowledgementSate.failed){
      return const StatusBox(color:  Colors.red,child: Text('Failed..',),);
    }else if(state == HardwareAcknowledgementSate.errorOnPayload){
      return const StatusBox(color:  Colors.red,child: Text('Payload error..',),);
    }else{
      return const SizedBox(
          width: double.infinity,
          height: 5,
          child: LinearProgressIndicator()
      );
    }
  }
}



