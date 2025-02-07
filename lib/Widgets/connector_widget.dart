import 'package:flutter/material.dart';
import 'package:oro_drip_irrigation/Widgets/sized_image.dart';
import '../Constants/properties.dart';
import '../Models/Configuration/device_model.dart';
import '../Models/Configuration/device_object_model.dart';
import '../Screens/ConfigMaker/connection.dart';
import '../StateManagement/config_maker_provider.dart';


class ConnectorWidget extends StatelessWidget {
  final ConfigMakerProvider configPvd;
  final String type;
  final int connectionNo;
  final String keyWord;
  final DeviceModel selectedDevice;
  const ConnectorWidget({
    super.key,
    required this.connectionNo,
    required this.selectedDevice,
    required this.configPvd,
    required this.type,
    required this.keyWord,
  });

  @override
  Widget build(BuildContext context) {
    DeviceObjectModel? object = configPvd.listOfGeneratedObject.cast<DeviceObjectModel?>().firstWhere(
          (object) => object?.controllerId == selectedDevice.controllerId && object?.connectionNo == connectionNo && object?.type == type,
      orElse: () => null as DeviceObjectModel?,
    );
    String? name = object?.name;
    bool selectedConnector = (configPvd.selectedModelControllerId == selectedDevice.controllerId && configPvd.selectedType == type && configPvd.selectedConnectionNo == connectionNo);

    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        InkWell(
          onDoubleTap: configPvd.selectedSelectionMode == SelectionMode.auto ? null :  (){
            if(object != null){
              configPvd.removeSingleObjectFromConfigureToConfigure(object);
            }
          },
          onTap: configPvd.selectedSelectionMode == SelectionMode.auto ? null : (){
            configPvd.updateSelectedConnectionNoAndItsType(connectionNo, type);
            print('connectionNo : $connectionNo   type : $type');
          },
          child: Row(
            children: [
              Container(
                width: 20,
                height: 20,
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(2),
                    color:  selectedConnector ? Colors.red : Colors.black
                ),
                child: Center(
                  child: Container(
                    width: double.infinity,
                    height: double.infinity,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(2),
                        color: object != null ? const Color(0xff72E6A7) : Colors.white
                    ),
                  ),
                ),
              ),
              Container(
                width: 20,
                height: 5,
                decoration: BoxDecoration(
                  color: selectedConnector ? Colors.red : Colors.black,
                ),
              ),
              const SizedBox(width: 5,),
              Text('${getSuitableKeyWord()} - ',style: AppProperties.tableHeaderStyle,)
            ],
          ),
        ),
        const SizedBox(width: 5,),
        Expanded(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              if(object != null)
                Expanded(child: Text(name.toString(),style: const TextStyle(fontSize: 12),overflow: TextOverflow.ellipsis,)),
              const SizedBox(width: 5,),
              if(object != null)
                SizedImageSmall(imagePath: 'assets/Images/Png/objectId_${object.objectId}.png')
            ],
          ),
        )


      ],
    );
  }

  String getSuitableKeyWord(){
    String specificSensor = '';
    if(connectionNo == 5 && selectedDevice.categoryId == 6 && selectedDevice.modelId == 3 && type == '3'){
      specificSensor = '(Ph)';
    }else if(connectionNo == 6 && selectedDevice.categoryId == 6 && selectedDevice.modelId == 3 && type == '3'){
      specificSensor = '(Ph)';
    }else if(connectionNo == 7 && selectedDevice.categoryId == 6 && selectedDevice.modelId == 3 && type == '3'){
      specificSensor = '(Ec)';
    }else if(connectionNo == 8 && selectedDevice.categoryId == 6 && selectedDevice.modelId == 3 && type == '3'){
      specificSensor = '(Ec)';
    }
    // else if(connectionNo == 1 && selectedDevice.categoryId == 5 && type == '3'){
    //   specificSensor = '(Ph)';
    // }else if(connectionNo == 2 && selectedDevice.categoryId == 5 && type == '3'){
    //   specificSensor = '(Ph)';
    // }
    return '$keyWord$connectionNo$specificSensor';
  }

}
