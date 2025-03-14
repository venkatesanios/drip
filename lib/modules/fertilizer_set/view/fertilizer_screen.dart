import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:oro_drip_irrigation/modules/fertilizer_set/model/fertilizer_site_setting_model.dart';
import 'package:oro_drip_irrigation/modules/fertilizer_set/repository/fertilizer_set_repository.dart';

import '../../config_Maker/view/config_web_view.dart';

class FertilizerScreen extends StatefulWidget {
  final Map<String, dynamic> userData;
  const FertilizerScreen({super.key, required this.userData});

  @override
  State<FertilizerScreen> createState() => _FertilizerScreenState();
}

class _FertilizerScreenState extends State<FertilizerScreen> {
  late Future<int> fertilizerSetResponse;
  List<FertilizerSiteSettingModel> listOfFertilizerSite = [];
  List<FertilizerSiteSettingModel> listOfFertilizerSet = [];
  int selectedFertilizerSite = 0;
  late ThemeData themeData;
  late bool themeMode;
  HardwareAcknowledgementSate payloadState = HardwareAcknowledgementSate.notSent;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fertilizerSetResponse = getFertilizerSetData(widget.userData);
  }

  Future<int> getFertilizerSetData(Map<String, dynamic>userData)async{
    try{
      var body = {
        "userId": userData['userId'],
        "controllerId": userData['controllerId'],
      };
      var response = await FertilizerSetRepository().getUserFertilizerSet(body);
      Map<String, dynamic> jsonData = jsonDecode(response.body);
      // setState(() {
      //   listOfIrrigationLine = (jsonData['data']['globalLimit'] as List<dynamic>).map((line){
      //     return LineInGlobalLimitModel.fromJson(line);
      //   }).toList();
      // });
      return jsonData['code'];
    }catch(e, stackTrace){
      if (kDebugMode) {
        print('Error :: $e');
        print('Stack Trace :: $stackTrace');
      }
      rethrow;
    }
  }


  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
    themeData = Theme.of(context);
    themeMode = themeData.brightness == Brightness.light;
  }


  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
