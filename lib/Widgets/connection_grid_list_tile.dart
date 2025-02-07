import 'package:flutter/material.dart';
import 'package:oro_drip_irrigation/Widgets/sized_image.dart';
import 'package:oro_drip_irrigation/Widgets/toggle_text_form_field_connection.dart';
import 'package:responsive_grid_list/responsive_grid_list.dart';
import '../Constants/communication_codes.dart';
import '../Constants/properties.dart';
import '../Models/Configuration/device_model.dart';
import '../Models/Configuration/device_object_model.dart';
import '../StateManagement/config_maker_provider.dart';

class ConnectionGridListTile extends StatefulWidget {
  final List<DeviceObjectModel> listOfObjectModel;
  final ConfigMakerProvider configPvd;
  final String title;
  Color? leadingColor;
  final DeviceModel selectedDevice;
  ConnectionGridListTile({
    super.key,
    required this.listOfObjectModel,
    required this.title,
    required this.configPvd,
    required this.selectedDevice,
    this.leadingColor,
  });

  @override
  State<ConnectionGridListTile> createState() => _ConnectionGridListTileState();
}

class _ConnectionGridListTileState extends State<ConnectionGridListTile> with SingleTickerProviderStateMixin{
  late AnimationController _controller;
  late Animation<Color?> _colorAnimation;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800), // Total duration of 2 blinks
    );

    // Define the color animation
    _colorAnimation = ColorTween(
      begin: Colors.white,
      end: Colors.red,
    ).animate(_controller);
    _startBlinking();
  }
  void _startBlinking() async {
    for (int i = 0; i < 2; i++) {
      await _controller.forward(); // Blink to red
      await _controller.reverse(); // Blink back to white
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 5,),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(widget.title,style: AppProperties.tableHeaderStyle,),
        ),
        ResponsiveGridList(
          horizontalGridMargin: 20,
          verticalGridMargin: 10,
          minItemWidth: 250,
          shrinkWrap: true,
          listViewBuilderOptions: ListViewBuilderOptions(
            physics: const NeverScrollableScrollPhysics(),
          ),
          children: [
            for(var object in widget.listOfObjectModel)
              objectTile(object)
          ],
        ),
      ],
    );
  }

  Widget objectTile(DeviceObjectModel object){
    Widget myWidget = ListTile(
      contentPadding: const EdgeInsets.symmetric(vertical: 5, horizontal: 5),
      title: Text(object.objectName, style: AppProperties.listTileBlackBoldStyle,),
      subtitle: Text('Not Configured : ${getNotConfiguredObjectByObjectId(object.objectId, widget.configPvd)}', style: TextStyle(fontSize: 11),),
      leading: Container(
        padding: const EdgeInsets.all(5),
        decoration: BoxDecoration(
          color: widget.leadingColor ?? getObjectTypeCodeToColor(int.parse(object.type)),
          borderRadius: BorderRadius.circular(5),
        ),
        child: SizedImage(
          imagePath: 'assets/Images/Png/objectId_${object.objectId}.png',
        ),
      ),
      trailing: (widget.selectedDevice.categoryId == 4 && object.objectId != 25)
          ? Checkbox(
          value: isConnectedToWeather(object),
          onChanged: (value){
            widget.configPvd.updateObjectConnection(object, value! ? 1 : 0);
          }
      ) : SizedBox(
        width: 80,
        child: ToggleTextFormFieldForConnection(
          configPvd: widget.configPvd,
          initialValue: object.count.toString(),
          object: object,
          selectedDevice: widget.selectedDevice,
        ),
      ),
    );
    return Container(
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5),
          color: Colors.white,
          boxShadow: AppProperties.customBoxShadow
      ),
      width: 300,
      child: myWidget,
    );
  }

  bool isConnectedToWeather(DeviceObjectModel object){
    return widget.configPvd.listOfGeneratedObject.any((generatedObject) => (generatedObject.objectId == object.objectId && generatedObject.controllerId == widget.selectedDevice.controllerId));
  }

}



int getNotConfiguredObjectByObjectId(int objectId, ConfigMakerProvider configPvd){
  List<DeviceObjectModel> notConfigured = configPvd.listOfGeneratedObject.where((object) => (object.objectId == objectId && object.controllerId == null)).toList();
  return notConfigured.length;
}

List<int> objectIdDependsOnDosing = [7, 8, 10, 27, 28];
List<int> objectIdDependsOnFiltration = [11, 12];
List<int> objectIdDependsOnTank = [5, 26, 39];
