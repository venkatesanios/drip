import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:oro_drip_irrigation/Constants/properties.dart';
import 'package:oro_drip_irrigation/Widgets/legend.dart';
import 'package:oro_drip_irrigation/Widgets/product_limit_grid_list_tile.dart';
import 'package:oro_drip_irrigation/Widgets/toggle_text_form_field_product_limit.dart';
import 'package:responsive_grid_list/responsive_grid_list.dart';

import '../../Constants/communication_codes.dart';
import '../../Models/Configuration/device_model.dart';
import '../../Models/Configuration/device_object_model.dart';
import '../../StateManagement/config_maker_provider.dart';
import '../../Widgets/sized_image.dart';

class ProductLimit extends StatefulWidget {
  final ConfigMakerProvider configPvd;
  List<DeviceModel> listOfDevices;
  ProductLimit({
    super.key,
    required this.listOfDevices,
    required this.configPvd,
  });

  @override
  State<ProductLimit> createState() => _ProductLimitState();
}

class _ProductLimitState extends State<ProductLimit> {
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: LayoutBuilder(builder: (context, productLimitSize){
        return SizedBox(
          width: productLimitSize.maxWidth,
          height: productLimitSize.maxHeight,
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                ...colorLegendBox(screenWidth,screenHeight),
                commonObject(),
                outputObject(),
                analogObject(),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget commonObject(){
    List<DeviceObjectModel> filteredList = widget.configPvd.listOfSampleObjectModel.where((object) => object.type == '-').toList();
    return ProductLimitGridListTile(
      listOfObjectModel: filteredList,
      title: 'Common Object',
      leadingColor: const Color(0xffDBDEFF),
      configPvd: widget.configPvd,
    );
  }

  Widget outputObject(){
    List<DeviceObjectModel> filteredList = widget.configPvd.listOfSampleObjectModel.where((object) => object.type == '1,2').toList();
    return ProductLimitGridListTile(
      listOfObjectModel: filteredList,
      title: 'Output Object',
      leadingColor: const Color(0xffD2EAFF),
      configPvd: widget.configPvd,
    );
  }

  Widget analogObject(){
    List<DeviceObjectModel> filteredList = widget.configPvd.listOfSampleObjectModel.where((object) => !['-', '1,2'].contains(object.type)).toList();
    filteredList.sort((a, b) => a.type.compareTo(b.type));
    return ProductLimitGridListTile(
      listOfObjectModel: filteredList,
      title: 'Input Object',
      configPvd: widget.configPvd,
    );
  }

  List<Widget> colorLegendBox(double screenWidth,double screenHeight){
    return [
      const Text('Enter The Count Of The Object',style: AppProperties.normalBlackBoldTextStyle),
      const SizedBox(height: 10,),
      Container(
        width: screenWidth > 500 ? null : double.infinity,
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(width: 1),
        ),
        child: Wrap(
          runSpacing: 10,
          spacing: screenWidth > 500 ? 30 : 10,
          children: [
            ColorLegend(
                color: const Color(0xffDBDEFF),
                message: 'Common Object',
              screenWidth: screenWidth,
            ),
            ColorLegend(
                color: const Color(0xffD2EAFF),
                message: 'Output : ${getRelayLatchCount(widget.listOfDevices) - balanceCountForRelayLatch(widget.configPvd)}/${getRelayLatchCount(widget.listOfDevices)}',
              screenWidth: screenWidth,
            ),
            for(var code in [3, 4, 5, 6, 7])
              if(getInputCount(code, widget.listOfDevices) != 0)
                ColorLegend(
                    color: getObjectTypeCodeToColor(code),
                    message: '${getObjectTypeCodeToString(code)} : ${getInputCount(code, widget.listOfDevices) - balanceCountForInputType(code, widget.configPvd)}/${getInputCount(code, widget.listOfDevices)}',
                  screenWidth: screenWidth,
                ),
          ],
        ),
      )
    ];
  }

}


int getRelayLatchCount(List<DeviceModel> listOfDevices){
  int count = 0;
  for(var node in listOfDevices){
    if(node.masterId != null){
      count += node.noOfRelay;
      count += node.noOfLatch;
    }
  }
  return count;
}

int balanceCountForRelayLatch(ConfigMakerProvider configPvd){
  int totalCount = getRelayLatchCount(configPvd.listOfDeviceModel);
  for(var object in configPvd.listOfSampleObjectModel){
    if(object.type == '1,2'){
      int objectCount = [null, ''].contains(object.count) ? 0 : int.parse(object.count!);
      totalCount -= objectCount;
    }
  }
  return totalCount;
}

int getInputCount(int code, List<DeviceModel> listOfDevices){
  int count = 0;
  for(var node in listOfDevices){
    if(node.masterId != null){
      if(code == 3){
        count += node.noOfAnalogInput;
      }else if(code == 4){
        count += node.noOfDigitalInput;
      }else if(code == 5){
        count += node.noOfMoistureInput;
      }else if(code == 6){
        count += node.noOfPulseInput;
      }else{
        count += node.noOfI2CInput;
      }
    }
  }
  return count;
}

int balanceCountForInputType(int code, ConfigMakerProvider configPvd){
  int totalCount = getInputCount(code, configPvd.listOfDeviceModel);
  for(var object in configPvd.listOfSampleObjectModel){
    if(object.type == '$code'){
      int objectCount = [null, ''].contains(object.count) ? 0 : int.parse(object.count!);
      totalCount -= objectCount;
    }
  }
  return totalCount;
}