import 'device_object_model.dart';

class FertilizationModel{
  DeviceObjectModel commonDetails;
  int? siteMode;
  List<int>? channel;
  List<int>? boosterPump;
  List<int>? agitator;
  List<int>? selector;
  List<int>? ec;
  List<int>? ph;

  FertilizationModel({
    required this.commonDetails,
    required this.siteMode,
    required this.channel,
    required this.boosterPump,
    required this.agitator,
    required this.selector,
    required this.ec,
    required this.ph,
  });

  factory FertilizationModel.fromJson(data){
    return FertilizationModel(
        commonDetails: data,
        siteMode: data['siteMode'],
        channel: data['channel'],
        boosterPump: data['boosterPump'],
        agitator: data['agitator'],
        selector: data['selector'],
        ec: data['ec'],
        ph: data['ph']
    );
  }

  Map<String, dynamic> toJson(){
    var commonInfo = commonDetails.toJson();
    commonInfo.addAll({
      'siteMode' : siteMode,
      'channel' : channel,
      'boosterPump' : boosterPump,
      'agitator' : agitator,
      'selector' : selector,
      'ec' : ec,
      'ph' : ph,
    });
    return commonInfo;
  }
}