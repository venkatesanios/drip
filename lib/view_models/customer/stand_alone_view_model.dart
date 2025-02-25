import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../Models/customer/program_model.dart';
import '../../Models/customer/stand_alone_model.dart';
import '../../repository/repository.dart';

enum SegmentWithFlow {manual, duration, flow}

class StandAloneViewModel extends ChangeNotifier {

  final Repository repository;
  bool isLoading = false;
  String errorMessage = "";

  SegmentWithFlow _segmentWithFlow = SegmentWithFlow.manual;
  String durationValue = '00:00:00';
  String selectedIrLine = '0';
  final TextEditingController _hoursController = TextEditingController();
  final TextEditingController _minutesController = TextEditingController();
  final TextEditingController _secondsController = TextEditingController();
  final TextEditingController _flowLiter = TextEditingController();

  late List<StandAloneModel> dashBoardData = [];
  List<ProgramModel> programList = [];
  bool visibleLoading = false;
  int ddCurrentPosition = 0;
  int serialNumber = 0;
  int standAloneMethod = 0;
  int startFlag = 0;
  String strFlow = '0';
  String strDuration = '00:00:00';
  String strSelectedLineOfProgram = '0';

  late List<Map<String, dynamic>> standaloneSelection  = [];

  StandAloneViewModel(this.repository);

  Future<void> getProgramList(customerId, controllerId) async {
    setLoading(true);
    programList.clear();
    try {
      Map<String, Object> body = {"userId": customerId, "controllerId": controllerId};
      final response = await repository.fetchCustomerProgramList(body);
      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        if (jsonData["code"] == 200) {
          List<dynamic> programsJson = jsonData['data'];
          programList = [...programsJson.map((programJson) => ProgramModel.fromJson(programJson))];

          ProgramModel defaultProgram = ProgramModel(
            programId: 0,
            serialNumber: 0,
            programName: 'Manual',
            defaultProgramName: '',
            programType: '',
            priority: '',
            startDate: '',
            startTime: '',
            sequenceCount: 0,
            scheduleType: '',
            firstSequence: '',
            duration: '',
            programCategory: '',
          );

          bool programWithNameExists = false;
          for (ProgramModel program in programList) {
            if (program.programName == 'Manual') {
              programWithNameExists = true;
              break;
            }
          }

          if (!programWithNameExists) {
            programList.insert(0, defaultProgram);
          } else {
            print('Program with name \'Default\' already exists in widget.programList.');
          }
          getExitManualOperation(customerId, controllerId);
        }
      }
    } catch (error) {
      debugPrint('Error fetching country list: $error');
    } finally {
      setLoading(false);
    }
  }

  Future<void> getExitManualOperation(customerId, controllerId) async
  {
    try {
      Map<String, Object> body = {"userId": customerId, "controllerId": controllerId};
      final response = await repository.fetchUserManualOperation(body);
      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        if (jsonResponse['data'] != null){
          try{
            dynamic data = jsonResponse['data'];
            startFlag = data['startFlag'];
            serialNumber = data['serialNumber'];
            try {
              standAloneMethod = data['method'];
              if (standAloneMethod == 0){
                standAloneMethod = 3;
              }
            } catch (e) {
              print('Error: $e');
            }
            strFlow = data['flow'];
            strDuration = data['duration'];

            int position = findPositionByName(serialNumber, programList);
            if (position != -1) {
              ddCurrentPosition = position;
            }else {
              print("'$serialNumber' not found in the list.");
            }

            if(standAloneMethod == 3){
              _segmentWithFlow = SegmentWithFlow.manual;
            }else if(standAloneMethod == 1){
              _segmentWithFlow = SegmentWithFlow.duration;
            }else{
              _segmentWithFlow = SegmentWithFlow.flow;
            }

            int count = strDuration.split(':').length - 1;
            if(count>1){
              durationValue = strDuration;
            }else{
              durationValue = '$strDuration:00';
            }
            _flowLiter.text = strFlow;

            await Future.delayed(const Duration(milliseconds: 500));
            scheduleSectionCallbackMethod(serialNumber, ddCurrentPosition);

          }catch(e){
            print(e);
          }
        } else {
          throw Exception('Invalid response format: "data" is null');
        }
      }
    } catch (error) {
      debugPrint('Error fetching country list: $error');
    } finally {
      setLoading(false);
    }

  }


  Future<List<StandAloneModel>> fetchControllerData(String customerId, String controllerId, String sNo) async {
    Map<String, Object> body = {
      "userId": customerId,
      "controllerId": controllerId,
      "serialNumber": sNo
    };

    try {
      var response = await repository.fetchStandAloneData(body);
      print(response.body);
      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        if (jsonResponse['data'] != null) {
          dynamic data = jsonResponse['data'];
          if (data is Map<String, dynamic>) {
            return [StandAloneModel.fromJson(data)];
          } else {
            debugPrint('Invalid response format: "data" is not a Map');
          }
        } else {
          debugPrint('Invalid response format: "data" is null');
        }
      }
    } catch (error, stackTrace) {
      debugPrint('Error fetching Product stock: $error');
      debugPrint(stackTrace.toString());
    } finally {
      notifyListeners();
    }

    return [];
  }

  int findPositionByName(int sNo, List<ProgramModel> programList) {
    for (int i = 0; i < programList.length; i++) {
      if (programList[i].serialNumber == sNo) {
        return i;
      }
    }
    return -1;
  }

  Future<void> scheduleSectionCallbackMethod(serialNumber, selection) async
  {
    ddCurrentPosition = selection;
    try {
      //dashBoardData = await fetchControllerData(serialNumber);
      //indicatorViewHide();
    } catch (e) {
      print('Error: $e');
    }
  }


  void setLoading(bool value) {
    isLoading = value;
    notifyListeners();
  }

}