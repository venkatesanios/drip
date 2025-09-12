import 'dart:async';
import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:provider/provider.dart';
import '../../models/customer/site_model.dart';
import '../../StateManagement/customer_provider.dart';
import '../../StateManagement/mqtt_payload_provider.dart';
import '../../repository/repository.dart';
import '../../services/bluetooth_service.dart';
import '../../services/communication_service.dart';
import '../../services/mqtt_service.dart';
import '../../utils/constants.dart';
import '../../utils/network_utils.dart';

class CustomerScreenControllerViewModel extends ChangeNotifier {
  final Repository repository;
  final BuildContext context;
  final MqttService mqttService = MqttService();
  final BluService blueService = BluService();

  late MqttPayloadProvider mqttProvider;
  bool _disposed = false;

  bool isLoading = false;
  String errorMsg = '';
  bool programRunning = false;
  bool isChanged = true;

  int selectedIndex = 0;
  int unreadAlarmCount = 2;
  int sIndex = 0, mIndex = 0, lIndex = 0;
  int wifiStrength = 0;
  int powerSupply = 0;
  bool isNotCommunicate = false;
  List<String> alarmDL = [];
  List<String> lineLiveMessage = [];

  late String myCurrentSite;
  String fromWhere = '';
  String myCurrentIrrLine = 'No Line Available';

  late SiteModel mySiteList = SiteModel(data: []);
  StreamSubscription<MqttConnectionState>? mqttSubscription;


  List<String> pairedDevices = ['Device A', 'Device B', 'Device C'];

  bool _isConnecting = false;
  int reconnectAttempts = 0;


  CustomerScreenControllerViewModel(this.context, this.repository, this.mqttProvider) {
    fromWhere = 'init';
    _initializeMqttConnection();
    mqttProvider.addListener(_onPayloadReceived);

    NetworkUtils.connectionStream.listen((connected) {
      if (_disposed) return;
      if (connected) {
        _initializeMqttConnection();
        mqttProvider.addListener(_onPayloadReceived);
      }
    });
  }

  void _onPayloadReceived() {
    if (_disposed) return;
    final activeDeviceId = mqttProvider.activeDeviceId;
    final liveDateAndTime = mqttProvider.liveDateAndTime;
    final wifiStrength = mqttProvider.wifiStrength;
    final currentSchedule = mqttProvider.currentSchedule;
    lineLiveMessage = mqttProvider.lineLiveMessage;
    powerSupply = mqttProvider.powerSupply;
    alarmDL = mqttProvider.alarmDL;
    isNotCommunicate = isDeviceNotCommunicating(mqttProvider.liveDateAndTime);
    if(activeDeviceId == mySiteList.data[sIndex].master[mIndex].deviceId){
      updateLivePayload(wifiStrength, liveDateAndTime, currentSchedule, lineLiveMessage);
    }
  }

  bool isDeviceNotCommunicating(String lastSyncTimeString) {
    DateTime lastSyncTime = DateTime.parse(lastSyncTimeString);
    DateTime currentTime = DateTime.now();
    Duration difference = currentTime.difference(lastSyncTime);
    return difference.inMinutes > 10;
  }

  void _initializeMqttConnection() {
    mqttService.initializeMQTTClient(state: mqttProvider);
    mqttService.connect();

    if (!kIsWeb) {
      blueService.initializeBluService(state: mqttProvider);
    }

    mqttSubscription = mqttService.mqttConnectionStream.listen((state) {
      switch (state) {
        case MqttConnectionState.connected:
          debugPrint("MQTT Connected! Callback");
          Future.delayed(const Duration(milliseconds: 1000), () {
            _subscribeToDeviceTopic();
          });
          break;

        case MqttConnectionState.connecting:
          debugPrint("MQTT Connecting... Callback");
          break;

        case MqttConnectionState.disconnected:
        default:
          debugPrint("MQTT Disconnected Callback");
          _handleMqttReconnection();
      }
    });
  }

  void _handleMqttReconnection() {
    if (_isConnecting || mqttService.isConnected) return;

    if (NetworkUtils.isOnline) {
      _isConnecting = true;
      final delay = Duration(seconds: 2 * (1 << reconnectAttempts).clamp(1, 32));
      Future.delayed(delay, () async {
        try {
          await mqttService.connect();
          reconnectAttempts = 0;
        } catch (_) {
          reconnectAttempts++;
        } finally {
          _isConnecting = false;
        }
      });
    }
  }


  void _subscribeToDeviceTopic() async {

    if (mqttService.mqttConnectionState != MqttConnectionState.connected) {
      debugPrint("MQTT client not yet connected properly.");
      return;
    }

    if (mySiteList.data.isEmpty) {
      print('Site data fetching from server...');
      return;
    }

    final deviceId = mySiteList.data[sIndex].master[mIndex].deviceId;
    if (deviceId.isEmpty) {
      debugPrint("No device ID found");
      return;
    }

    final topic = '${AppConstants.subscribeTopic}/$deviceId';

    try {
      await mqttService.topicToSubscribe(topic);
      Future.delayed(const Duration(seconds: 2), onRefreshClicked);
    } catch (e) {
      debugPrint("MQTT Subscribe failed: $e");
    }
  }

  void updateLivePayload(int ws, String liveDataAndTime, List<String> cProgram, List<String> linePauseResume) {

    final parts = liveDataAndTime.split(' ');
    if (parts.length == 2) {
      mySiteList.data[sIndex].master[mIndex].live?.cD = parts[0];
      mySiteList.data[sIndex].master[mIndex].live?.cT = parts[1];
    }

    wifiStrength = ws;
    programRunning = cProgram.isNotEmpty && cProgram[0].isNotEmpty;
    if (programRunning) {
      mqttProvider.currentSchedule = cProgram;
    }

    for (final entry in linePauseResume) {
      final parts = entry.split(',');
      if (parts.length == 2) {
        final serialNo = double.tryParse(parts[0]);
        final flag = int.tryParse(parts[1]);
        if (serialNo != null && flag != null) {
          for (var line in mySiteList.data[sIndex].master[mIndex].irrigationLine) {
            if (line.sNo == serialNo) {
              line.linePauseFlag = flag;
              break;
            }
          }
        }
      }
    }

    notifyListeners();
  }

  Future<void> getAllMySites(BuildContext context, int customerId, {bool preserveSelection = false}) async {
    setLoading(true);
    try {
      final response = await repository.fetchAllMySite({"userId": customerId});
      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        if (jsonData["code"] == 200) {
          final newSiteList = SiteModel.fromJson(jsonData, 'customer');

          if (preserveSelection && mySiteList.data.isNotEmpty) {
            // update the whole master (so programList gets replaced too)
            mySiteList.data[sIndex].master[mIndex] =
            newSiteList.data[sIndex].master[mIndex];

            // 👇 force programList replacement explicitly
            mySiteList.data[sIndex].master[mIndex].programList =
                newSiteList.data[sIndex].master[mIndex].programList;

            notifyListeners();
          } else {
            mySiteList = newSiteList;
            updateSite(sIndex, mIndex, lIndex);
          }

          mqttProvider.saveUnits(Unit.toJsonList(mySiteList.data[sIndex].master[mIndex].units));

          final customerProvider = Provider.of<CustomerProvider>(context, listen: false);
          customerProvider.updateControllerCommunicationMode(
            cmmMode: mySiteList.data[sIndex].master[mIndex].communicationMode!,
          );

          final live = mySiteList.data[sIndex].master[mIndex].live;
          mqttProvider.updateReceivedPayload(
            live != null ? jsonEncode(live) : _defaultPayload(),
            true,
          );

          wifiStrength = live?.cM['WifiStrength'] ?? 0;
        }
        else {
          // handle sharedUserSite same way
          final sharedResponse = await repository.fetchSharedUserSite({"userId": customerId});
          if (sharedResponse.statusCode == 200) {
            final jsonData = jsonDecode(sharedResponse.body);
            if (jsonData["code"] == 200) {
              final newSiteList = SiteModel.fromJson(jsonData, 'subUser');

              if (preserveSelection && mySiteList.data.isNotEmpty) {
                mySiteList.data[sIndex].master[mIndex] =
                newSiteList.data[sIndex].master[mIndex];
              } else {
                mySiteList = newSiteList;
                updateSite(sIndex, mIndex, lIndex);
              }

              mqttProvider.saveUnits(Unit.toJsonList(mySiteList.data[sIndex].master[mIndex].units));

              final live = mySiteList.data[sIndex].master[mIndex].live;
              mqttProvider.updateReceivedPayload(
                live != null ? jsonEncode(live) : _defaultPayload(),
                true,
              );

              wifiStrength = live?.cM['WifiStrength'] ?? 0;
            }
          }
        }
      }
    } catch (error) {
      errorMsg = 'Error fetching site list: $error';
      debugPrint(errorMsg);
    } finally {
      setLoading(false);
      notifyListeners(); // 🔥 always notify UI
    }
  }

  /*Future<void> getAllMySites(BuildContext context, int customerId, {bool preserveSelection = false}) async {
    setLoading(true);
    try {
      final response = await repository.fetchAllMySite({"userId": customerId});
      print("response.body :: ${response.body}");

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        if (jsonData["code"] == 200) {
          final newSiteList = SiteModel.fromJson(jsonData, 'customer');

          if (preserveSelection && mySiteList.data.isNotEmpty) {
            //only update the selected controller data
            mySiteList.data[sIndex].master[mIndex] =
            newSiteList.data[sIndex].master[mIndex];
          } else {
            // normal flow (full reload)
            mySiteList = newSiteList;
            updateSite(sIndex, mIndex, lIndex);
          }

          mqttProvider.saveUnits(Unit.toJsonList(mySiteList.data[sIndex].master[mIndex].units));

          final customerProvider = Provider.of<CustomerProvider>(context, listen: false);
          customerProvider.updateControllerCommunicationMode(
            cmmMode: mySiteList.data[sIndex].master[mIndex].communicationMode!,
          );

          final live = mySiteList.data[sIndex].master[mIndex].live;
          mqttProvider.updateReceivedPayload(
            live != null ? jsonEncode(live) : _defaultPayload(),
            true,
          );

          wifiStrength = live?.cM['WifiStrength'] ?? 0;
        } else {
          // handle sharedUserSite same way
          final sharedResponse = await repository.fetchSharedUserSite({"userId": customerId});
          if (sharedResponse.statusCode == 200) {
            final jsonData = jsonDecode(sharedResponse.body);
            if (jsonData["code"] == 200) {
              final newSiteList = SiteModel.fromJson(jsonData, 'subUser');

              if (preserveSelection && mySiteList.data.isNotEmpty) {
                mySiteList.data[sIndex].master[mIndex] =
                newSiteList.data[sIndex].master[mIndex];
              } else {
                mySiteList = newSiteList;
                updateSite(sIndex, mIndex, lIndex);
              }

              mqttProvider.saveUnits(Unit.toJsonList(mySiteList.data[sIndex].master[mIndex].units));

              final live = mySiteList.data[sIndex].master[mIndex].live;
              mqttProvider.updateReceivedPayload(
                live != null ? jsonEncode(live) : _defaultPayload(),
                true,
              );

              wifiStrength = live?.cM['WifiStrength'] ?? 0;
            }
          }
        }
      }
    } catch (error) {
      errorMsg = 'Error fetching site list: $error';
      debugPrint(errorMsg);
    } finally {
      setLoading(false);
    }
  }*/

  /*Future<void> getAllMySites(BuildContext context, int customerId) async {
    setLoading(true);
    final response = await repository.fetchAllMySite({"userId": customerId});
    print("response.body :: ${response.body}");
    try {
      final response = await repository.fetchAllMySite({"userId": customerId});
      if (response.statusCode == 200) {
        print(response.body);
        final jsonData = jsonDecode(response.body);
        if (jsonData["code"] == 200) {
          mySiteList = SiteModel.fromJson(jsonData, 'customer');
          updateSite(sIndex, mIndex, lIndex);

          mqttProvider.saveUnits(Unit.toJsonList(mySiteList.data[sIndex].master[mIndex].units));

          final customerProvider = Provider.of<CustomerProvider>(context, listen: false);
          customerProvider.updateControllerCommunicationMode(
            cmmMode: mySiteList.data[sIndex].master[mIndex].communicationMode!,
          );

          final live = mySiteList.data[sIndex].master[mIndex].live;
          mqttProvider.updateReceivedPayload(
            live != null ? jsonEncode(live) : _defaultPayload(),
            true,
          );

          wifiStrength = live?.cM['WifiStrength'] ?? 0;
        }
        else{
          final response = await repository.fetchSharedUserSite({"userId": customerId});
          if (response.statusCode == 200) {
            print(response.body);
            final jsonData = jsonDecode(response.body);
            if (jsonData["code"] == 200) {
              mySiteList = SiteModel.fromJson(jsonData, 'subUser');
              updateSite(sIndex, mIndex, lIndex);

              mqttProvider.saveUnits(Unit.toJsonList(mySiteList.data[sIndex].master[mIndex].units));

              final live = mySiteList.data[sIndex].master[mIndex].live;
              mqttProvider.updateReceivedPayload(
                live != null ? jsonEncode(live) : _defaultPayload(),
                true,
              );

              wifiStrength = live?.cM['WifiStrength'] ?? 0;
            }
          }
        }
      }

    } catch (error) {
      errorMsg = 'Error fetching site list: $error';
      debugPrint(errorMsg);
    } finally {
      setLoading(false);
    }
  }*/

  String _defaultPayload() => '''
  {
    "cC": "00000000",
    "cM": {
      "2401": "", "2402": "", "2403": "", "2404": "", "2405": "", "2406": "", "2407": "", "2408": "",
      "2409": "", "2410": "", "2411": "", "2412": "", "WifiStrength": 0, "Version": "", "PowerSupply": 0
    },
    "cD": "0000-00-00", "cT": "00:00:00", "mC": "2400"
  }''';

  void setLoading(bool value) {
    isLoading = value;
    notifyListeners();
  }

  Future<void> siteOnChanged(String siteName) async{
    int index = mySiteList.data.indexWhere((site) => site.groupName == siteName);
    if (index != -1) {
      sIndex = index;
      fromWhere = 'site';
      updateSite(index, 0, 0);
    }
    isChanged = false;
    await Future.delayed(const Duration(seconds: 1));
    isChanged = true;
    notifyListeners();
  }

  Future<void> masterOnChanged(int index) async {
    mIndex = index;
    lIndex = 0;
    fromWhere = 'master';
    updateMaster(sIndex, index, lIndex);

    isChanged = false;
    await Future.delayed(const Duration(seconds: 1));
    isChanged = true;
    notifyListeners();
  }

  void lineOnChanged(int lInx) {
    if (mySiteList.data[sIndex].master[mIndex].irrigationLine.length > 1) {
      lIndex = lInx;
      fromWhere = 'line';
      updateMasterLine(sIndex, mIndex, lInx);
    }
  }

  void updateSite(int sIdx, int mIdx, int lIdx) {
    myCurrentSite = mySiteList.data[sIdx].groupName;
    updateMaster(sIdx, mIdx, lIdx);
  }

  void updateMaster(int sIdx, int mIdx, int lIdx) {
    final customerProvider = Provider.of<CustomerProvider>(context, listen: false);
    customerProvider.updateControllerInfo(
      controllerId: mySiteList.data[sIdx].master[mIdx].controllerId,
      device: mySiteList.data[sIdx].master[mIdx].deviceId,
      customerId: mySiteList.data[sIdx].customerId,
    );

    final live = mySiteList.data[sIndex].master[mIndex].live;

    if ([1, 2, 3, 4, 56, 57, 58, 59].contains(mySiteList.data[sIdx].master[mIdx].modelId)) {
      updateMasterLine(sIdx, mIdx, lIdx);
      mqttProvider.updateReceivedPayload(
        live != null ? jsonEncode(live) : _defaultPayload(),
        true,
      );
    }else{
      final Map<String, dynamic> mapData = {
        "cD": live!.cD,
        "cT": live.cT,
        "cC": live.cC,
      };
      final String payload = jsonEncode(mapData);
      mqttProvider.updateLastSyncDateFromPumpControllerPayload(payload);
    }

    _subscribeToDeviceTopic();
    notifyListeners();
  }

  void updateMasterLine(int sIdx, int mIdx, int lIdx) {
    if (mySiteList.data[sIdx].master[mIdx].irrigationLine.isNotEmpty) {
      myCurrentIrrLine = mySiteList.data[sIdx].master[mIdx].irrigationLine[lIdx].name;
      notifyListeners();
    }
  }

  Future<void> onRefreshClicked() async {
    if (!mqttService.isConnected) {
      debugPrint("MQTT not connected. Attempting to reconnect...");
      _initializeMqttConnection();
    }

    if (mySiteList.data.isEmpty ||
        sIndex >= mySiteList.data.length ||
        mIndex >= mySiteList.data[sIndex].master.length) {
      debugPrint("Invalid site/master index.");
      return;
    }

    final isCategory1 = [...AppConstants.gemModelList, ...AppConstants.ecoGemModelList].contains(mySiteList.data[sIndex].master[mIndex].modelId);
    final payload = isCategory1
        ? jsonEncode({"3000": {"3001": ""}})
        : jsonEncode({"sentSms": "#live"});

    mqttProvider.liveSyncCall(true);

    try {
      final result = await context.read<CommunicationService>().sendCommand(
        serverMsg: '',
        payload: payload,
      );

      if (result['http'] == true) debugPrint("Payload sent to Server");
      if (result['mqtt'] == true) debugPrint("Payload sent to MQTT Box");
      if (result['bluetooth'] == true) debugPrint("Payload sent via Bluetooth");
    } catch (e) {
      debugPrint("Error sending command: $e");
    }

    await Future.delayed(const Duration(seconds: 1));
    mqttProvider.liveSyncCall(false);
  }

  Future<void> linePauseOrResume(List<String> lineLiveMsg) async {
    final allPaused = lineLiveMsg.every((line) => line.split(',')[1] == '1');
    final strPRPayload = '${lineLiveMsg.map((msg) {
      final parts = msg.split(',');
      return '${parts[0]},${allPaused ? '0' : '1'}';
    }).join(';')};';

    final payload = jsonEncode({"4900": {"4901": strPRPayload}});
    final result = await context.read<CommunicationService>().sendCommand(
      serverMsg: allPaused ? 'Resumed all line' : 'Paused all line',
      payload: payload,
    );

    if (result['http'] == true) debugPrint("Payload sent to Server");
    if (result['mqtt'] == true) debugPrint("Payload sent to MQTT Box");
    if (result['bluetooth'] == true) debugPrint("Payload sent via Bluetooth");
  }

  bool getPermissionStatusBySNo(BuildContext context, int sNo) {
    return true;
  }

  void onItemTapped(int index) {
    selectedIndex = index;
    notifyListeners();
  }

  Future<void> updateCommunicationMode(int communicationMode, int customerId) async {
    try {
      Map<String, dynamic> body = {
        "userId": customerId,
        "controllerId": mySiteList.data[sIndex].master[mIndex].controllerId,
        "communicationMode": communicationMode,
        "modifyUser": customerId
      };
      final response = await repository.updateControllerCommunicationMode(body);
      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        if (jsonData["code"] == 200) {
          final customerProvider = Provider.of<CustomerProvider>(context, listen: false);
          customerProvider.updateControllerCommunicationMode(cmmMode: communicationMode);
        }
      }
    } catch (error) {
      //errorMsg = 'Error fetching site list: $error';
    }
  }


  @override
  void dispose() {
    super.dispose();
    _disposed = true;
    mqttProvider.removeListener(_onPayloadReceived);
    mqttSubscription?.cancel();
    mqttService.disConnect();
  }
}