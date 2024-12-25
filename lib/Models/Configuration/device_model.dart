class DeviceModel {
  final int controllerId;
  final String deviceId;
  final String deviceName;
  final int categoryId;
  final String categoryName;
  final int modelId;
  final String modelName;
  int interfaceId;
  int interval;
  final int serialNo;
  int isUsedInConfig;
  String? masterDeviceId;
  final int noOfRelay;
  final int noOfLatch;
  final int noOfAnalogInput;
  final int noOfDigitalInput;
  final int noOfPulseInput;
  final int noOfMoistureInput;
  final int noOfI2CInput;
  bool select;
  final List<int> connectingObjectId;

  DeviceModel({
    required this.controllerId,
    required this.deviceId,
    required this.deviceName,
    required this.categoryId,
    required this.categoryName,
    required this.modelId,
    required this.modelName,
    required this.interfaceId,
    required this.interval,
    required this.serialNo,
    required this.isUsedInConfig,
    required this.masterDeviceId,
    required this.noOfRelay,
    required this.noOfLatch,
    required this.noOfAnalogInput,
    required this.noOfDigitalInput,
    required this.noOfPulseInput,
    required this.noOfMoistureInput,
    required this.noOfI2CInput,
    required this.select,
    required this.connectingObjectId,
});

  factory DeviceModel.fromJson(data){
    return DeviceModel(
        controllerId : data['controllerId'],
        deviceId : data['deviceId'],
        deviceName : data['deviceName'],
        categoryId : data['categoryId'],
        categoryName : data['categoryName'],
        modelId : data['modelId'],
        modelName : data['modelName'],
        interfaceId : data['interfaceId'],
        interval : data['interval'],
        serialNo : data['serialNo'],
        isUsedInConfig : data['isUsedInConfig'],
        masterDeviceId : data['masterDeviceId'],
        noOfRelay : data['noOfRelay'],
        noOfLatch : data['noOfLatch'],
        noOfAnalogInput : data['noOfAnalogInput'],
        noOfDigitalInput : data['noOfDigitalInput'],
        noOfPulseInput : data['noOfPulseInput'],
        noOfMoistureInput : data['noOfMoistureInput'],
        noOfI2CInput : data['noOfI2CInput'],
        select : data['select'],
        connectingObjectId : data['connectingObjectId'],
    );
  }

  Map<String, dynamic> toJson(){
    return {
      'controllerId' : controllerId,
      'deviceId' : deviceId,
      'deviceName' : deviceName,
      'categoryId' : categoryId,
      'categoryName' : categoryName,
      'modelId' : modelId,
      'modelName' : modelName,
      'interfaceId' : interfaceId,
      'interval' : interval,
      'serialNo' : serialNo,
      'isUsedInConfig' : isUsedInConfig,
      'masterDeviceId' : masterDeviceId,
      'noOfRelay' : noOfRelay,
      'noOfLatch' : noOfLatch,
      'noOfAnalogInput' : noOfAnalogInput,
      'noOfDigitalInput' : noOfDigitalInput,
      'noOfPulseInput' : noOfPulseInput,
      'noOfMoistureInput' : noOfMoistureInput,
      'noOfI2CInput' : noOfI2CInput,
      'connectingObjectId' : connectingObjectId,
    };
  }
}