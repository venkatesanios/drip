import 'package:oro_drip_irrigation/modules/fertilizer_set/model/channel_setting_model.dart';
import 'package:oro_drip_irrigation/modules/fertilizer_set/model/ec_ph_setting_model.dart';

class FertilizerSiteSettingModel{
  final int objectId;
  final double sNo;
  final String name;
  List<ChannelSettingModel> channel;
  List<EcPhSettingModel> ec;
  List<EcPhSettingModel> ph;

  FertilizerSiteSettingModel({
    required this.objectId,
    required this.sNo,
    required this.name,
    required this.channel,
    required this.ec,
    required this.ph,
  });

  factory FertilizerSiteSettingModel.fromJson(data){
    return FertilizerSiteSettingModel(
        objectId: data['objectId'],
        sNo: data['sNo'],
        name: data['name'],
        channel: data['channel'],
        ec: data['ec'],
        ph: data['ph'],
    );
  }

  Map<String, dynamic> toJson(){
    return {
      'objectId' : objectId,
      'sNo' : sNo,
      'name' : name,
      'channel' : channel.map((channel) => channel.toJson()).toList(),
      'ec' : ec.map((ec) => ec.toJson()).toList(),
      'ph' : ph.map((ph) => ph.toJson()).toList(),
    };
  }
}