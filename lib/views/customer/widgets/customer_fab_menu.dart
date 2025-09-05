import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../Models/customer/site_model.dart';
import '../../../Screens/Dealer/ble_mobile_screen.dart';
import '../../../StateManagement/customer_provider.dart';
import '../../../StateManagement/mqtt_payload_provider.dart';
import '../../../modules/IrrigationProgram/view/program_library.dart';
import '../../../modules/ScheduleView/view/schedule_view_screen.dart';
import '../../../modules/bluetooth_low_energy/view/node_connection_page.dart';
import '../../../services/communication_service.dart';
import '../../../utils/constants.dart';
import '../../../view_models/customer/customer_screen_controller_view_model.dart';
import '../../mobile/mobile_screen_controller.dart';
import '../input_output_connection_details.dart';
import '../node_list/node_list_narrow.dart';
import '../send_and_received/sent_and_received_narrow.dart';
import '../stand_alone.dart';
import '../stand_alone/stand_alone_narrow.dart';

class CustomerFabMenu extends StatelessWidget {
  final dynamic currentMaster;
  final dynamic viewedCustomer;
  final dynamic loggedInUser;
  final dynamic vm;
  final void Function(String msg) callbackFunction;

  const CustomerFabMenu({
    super.key,
    required this.currentMaster,
    required this.viewedCustomer,
    required this.loggedInUser,
    required this.vm,
    required this.callbackFunction,
  });

  @override
  Widget build(BuildContext context) {

    final isGem = [
      ...AppConstants.gemModelList,
      ...AppConstants.ecoGemModelList
    ].contains(currentMaster.modelId);

    if (!isGem) return const SizedBox.shrink();

    final commMode = Provider.of<CustomerProvider>(context).controllerCommMode;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        FloatingActionButton(
          heroTag: null,
          backgroundColor: Theme.of(context).primaryColorLight,
          onPressed: null,
          child: PopupMenuButton<String>(
            offset: const Offset(0, -180),
            color: Colors.white,
            onSelected: (value) => _handleMenuSelection(value, context),
            icon: const Icon(Icons.menu, color: Colors.white),
            itemBuilder: (context) => [
              _buildPopupItem(
                  context, 'Node Status', Icons.format_list_numbered, 'Node Status'),
              _buildPopupItem(
                  context, 'I/O Connection', Icons.settings_input_component_outlined, 'I/O Connection details'),
              _buildPopupItem(
                  context, 'Program', Icons.list_alt, 'Program'),
              _buildPopupItem(
                  context, 'ScheduleView', Icons.view_list_outlined, 'Scheduled program details'),
              _buildPopupItem(
                  context, 'Manual', Icons.touch_app_outlined, 'Manual'),
              _buildPopupItem(
                  context, 'Sent & Received', Icons.question_answer_outlined, 'Sent & Received'),
            ],
          ),
        ),

        const SizedBox(height: 10),

        // Connectivity FAB
        FloatingActionButton(
          heroTag: null,
          backgroundColor: commMode == 1 ? Theme.of(context).primaryColorLight :
          (commMode == 2 && vm.blueService.isConnected) ? Theme.of(context).primaryColorLight :
          Colors.redAccent,
          onPressed: () => _showBottomSheet(context,currentMaster, vm, viewedCustomer.id, loggedInUser.id),
          tooltip: 'Connectivity',
          child: commMode == 1
              ? Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                vm.wifiStrength == 0
                    ? Icons.wifi_off
                    : vm.wifiStrength <= 20
                    ? Icons.network_wifi_1_bar_outlined
                    : vm.wifiStrength <= 40
                    ? Icons.network_wifi_2_bar_outlined
                    : vm.wifiStrength <= 80
                    ? Icons.network_wifi_3_bar_outlined
                    : Icons.wifi,
                color: Colors.white,
              ),
              Text(
                '${vm.wifiStrength} %',
                style: const TextStyle(
                    fontSize: 11.0, color: Colors.white70),
              ),
            ],
          )
              : Icon(
            (commMode == 2 && vm.blueService.isConnected)
                ? Icons.bluetooth
                : Icons.bluetooth_disabled,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  void _handleMenuSelection(String value, BuildContext context) {
    switch (value) {
      case 'Node Status':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => NodeListNarrow(
              customerId: viewedCustomer.id,
              nodes: currentMaster.nodeList,
              userId: loggedInUser.id,
              configObjects: currentMaster.configObjects,
              masterData: currentMaster,
            ),
          ),
        );
        break;

      case 'I/O Connection':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => InputOutputConnectionDetails(
              masterInx: vm.mIndex,
              nodes: currentMaster.nodeList,
            ),
          ),
        );
        break;

      case 'Sent & Received':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SentAndReceivedNarrow(
              customerId: viewedCustomer.id,
              controllerId: currentMaster.controllerId,
            ),
          ),
        );
        break;

      case 'Program':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProgramLibraryScreenNew(
              customerId: viewedCustomer.id,
              controllerId: currentMaster.controllerId,
              deviceId: currentMaster.deviceId,
              userId: loggedInUser.id,
              groupId: vm.mySiteList.data[vm.sIndex].groupId,
              categoryId: currentMaster.categoryId,
              modelId: currentMaster.modelId,
              deviceName: currentMaster.deviceName,
              categoryName: currentMaster.categoryName,
            ),
          ),
        );
        break;

      case 'ScheduleView':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ScheduleViewScreen(
              deviceId: currentMaster.deviceId,
              userId: loggedInUser.id,
              controllerId: currentMaster.controllerId,
              customerId: viewedCustomer.id,
              groupId: vm.mySiteList.data[vm.sIndex].groupId,
            ),
          ),
        );
        break;

      case 'Manual':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => StandAloneNarrow(
              siteId: vm.mySiteList.data[vm.sIndex].groupId,
              controllerId: currentMaster.controllerId,
              customerId: viewedCustomer.id,
              deviceId: currentMaster.deviceId,
              callbackFunction: callbackFunction,
              userId: loggedInUser.id,
              masterData: currentMaster,
            ),
          ),
        );
        break;
    }
  }

  PopupMenuItem<String> _buildPopupItem(
      BuildContext context, String value, IconData icon, String text) {
    return PopupMenuItem<String>(
      value: value,
      child: Row(
        children: [
          Icon(icon, color: Theme.of(context).primaryColor, size: 20),
          const SizedBox(width: 10),
          Text(text),
        ],
      ),
    );
  }

  void _showBottomSheet(BuildContext context, MasterControllerModel currentMaster,
      CustomerScreenControllerViewModel vm, int customerId, int userId) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      backgroundColor: Colors.white,
      builder: (_) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final commMode = Provider.of<CustomerProvider>(context).controllerCommMode;
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Wrap(
                children: [
                  const Text(
                    "Controller Communication Mode",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  ListTile(
                    leading: const Icon(Icons.wifi),
                    title: const Text("Wi-Fi / MQTT"),
                    trailing: commMode == 1 ?
                    Icon(Icons.check, color: Theme.of(context).primaryColorLight) : null,
                    onTap: () {
                      vm.updateCommunicationMode(1, customerId);
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.bluetooth),
                    title: const Text("Bluetooth"),
                    trailing: commMode == 2
                        ? Icon(Icons.check, color: Theme.of(context).primaryColorLight)
                        : null,
                    onTap: () {
                      vm.updateCommunicationMode(2, customerId);
                    },
                  ),
                  if (commMode == 2) ...[
                    const Divider(),
                    if(currentMaster.modelId==3)...[
                      ListTile(
                        title: const Text('Scan & Connect the controller via Bluetooth',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: const Text('Stay close to the controller near by 10 meters',
                            style: TextStyle(color: Colors.black45)),
                        trailing: Icon(CupertinoIcons.arrow_right_circle),
                        onTap: (){
                          final Map<String, dynamic> data = {
                            'controllerId': currentMaster.controllerId,
                            'deviceId': currentMaster.deviceId,
                            'deviceName': currentMaster.deviceName,
                            'categoryId': currentMaster.categoryId,
                            'categoryName': currentMaster.categoryName,
                            'modelId': currentMaster.modelId,
                            'modelName': currentMaster.modelName,
                            'InterfaceType': currentMaster.interfaceTypeId,
                            'interface': currentMaster.interface,
                            'relayOutput': currentMaster.relayOutput,
                            'latchOutput': currentMaster.latchOutput,
                            'analogInput': currentMaster.analogInput,
                            'digitalInput': currentMaster.digitalInput,
                          };
                          Navigator.push(context, MaterialPageRoute(builder: (context) => NodeConnectionPage(
                            nodeData: data,
                            masterData: {
                              "userId" : userId,
                              "customerId" : customerId,
                              "controllerId" : currentMaster.controllerId
                            },
                          )));
                        },
                      ),
                    ]
                    else...[
                      BluetoothScanTile(vm: vm),
                      const SizedBox(height: 10),
                      Consumer<MqttPayloadProvider>(
                        builder: (context, provider, _) {
                          final devices = provider.pairedDevices;
                          if (devices.isNotEmpty) {
                            return Column(
                              children: devices.map((d) {
                                return ListTile(
                                  title: Text(d.device.name ?? ''),
                                  subtitle: Text(d.device.address),
                                  trailing: d.isConnected ? Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(Icons.check_circle, color: Colors.green),
                                      const SizedBox(width: 8),
                                      IconButton(
                                        onPressed: () {
                                          requestAndShowWifiList(context, false);
                                        },
                                        icon: const Icon(CupertinoIcons.text_badge_checkmark),
                                      ),
                                      IconButton(
                                        onPressed: () {
                                          Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) => BLEMobileScreen(deviceID: currentMaster.deviceId,
                                                    communicationType: 'Bluetooth',userId: customerId,controllerId: currentMaster.controllerId),
                                              ));
                                        },
                                        icon: const Icon(CupertinoIcons.exclamationmark_octagon),
                                      ),
                                    ],
                                  ):
                                  d.isConnecting ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  ):
                                  TextButton(
                                    onPressed: d.isDisConnected ? () => vm.blueService.connectToDevice(d) : null,
                                    child: const Text('Connect'),
                                  ),
                                );
                              }).toList(),
                            );
                          } else {
                            return const Center(
                              child: Text(
                                'Stay close to the controller and tap refresh to try scanning again.',
                                style: TextStyle(fontSize: 12, color: Colors.black38),
                              ),
                            );
                          }
                        },
                      ),
                    ]
                  ],
                ],
              ),
            );
          },
        );
      },
    );
  }

  void requestAndShowWifiList(BuildContext context, bool visibleDg) {
    final commService = Provider.of<CommunicationService>(context, listen: false);
    String payLoadFinal = jsonEncode({"7200": {"7201": ''}});
    commService.sendCommand(serverMsg: '', payload: payLoadFinal);
    if(!visibleDg){
      showWifiListDialog(context);
    }
  }

  void showWifiListDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        final connectingNetwork = ValueNotifier<String?>(null);
        final provider = context.watch<MqttPayloadProvider>();
        final networks = provider.wifiList;
        final message = provider.wifiMessage;
        final wifiStatus = provider.wifiStatus;
        final interfaceType = provider.interfaceType;
        final ipAddress = provider.ipAddress;

        if (message != null && message.isNotEmpty) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (message == 'WWi-Fi is now ON' || message == 'Wi-Fi is now OFF') {
              context.read<MqttPayloadProvider>().clearWifiMessage();
              Future.delayed(const Duration(milliseconds: 1500), () {
                requestAndShowWifiList(context, true);
              });
            } else {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text("Changing controller network..."),
                    content: Text(message),
                    actions: [
                      TextButton(
                        onPressed: () {
                          context.read<MqttPayloadProvider>().clearWifiMessage();
                          Navigator.of(context).pop();
                          Navigator.of(context).pop();
                          showWifiListDialog(context);
                        },
                        child: const Text("OK"),
                      ),
                    ],
                  );
                },
              );
            }
          });
        }

        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: Colors.white,
              title: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.wifi),
                    title: const Text("Wi-Fi"),
                    subtitle: wifiStatus == '2'
                        ? const Text(
                      'Wi-Fi is enabled on the controller \n But No Internet connection',
                      style: TextStyle(fontSize: 12, color: Colors.red),
                    )
                        : Text(
                      wifiStatus == '1'
                          ? 'Wi-Fi is enabled on the controller'
                          : 'Wi-Fi is disabled on the controller',
                      style: const TextStyle(fontSize: 12, color: Colors.black45),
                    ),
                    trailing: Transform.scale(
                      scale: 0.8,
                      child: provider.wifiStateChanging? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(strokeWidth: 3),
                      ) : Switch(
                        value: wifiStatus == '1' || wifiStatus == '2',
                        activeColor: Colors.blue,
                        onChanged: (bool value) async {
                          provider.updateWifiStatus('0', true);
                          final communicationService = context.read<CommunicationService>();
                          final livePayload = jsonEncode({
                            "6000": {
                              "6001": value ? '1,0,0' : '0,0,0',
                            }
                          });

                          await communicationService.sendCommand(serverMsg: '', payload: livePayload,);

                        },
                      ),
                    ),
                  ),
                  const Divider(height: 0),
                  (wifiStatus=='1'||wifiStatus=='2')? ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text("Available Networks"),
                    subtitle: const Text(
                      "Select a Wi-Fi network to change the controller's connection.",
                      style: TextStyle(fontSize: 11, color: Colors.grey),
                    ),
                    trailing: IconButton(
                      onPressed: () {
                        requestAndShowWifiList(context, true);
                      },
                      icon: const Icon(Icons.refresh),
                    ),
                  ) :
                  const SizedBox(),
                ],
              ),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              content: SizedBox(
                width: double.maxFinite,
                child: interfaceType=='ethernet'? ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Controller connected with ethernet'),
                  subtitle: Text('IpAddress : $ipAddress'),
                  trailing: const Icon(Icons.cast_connected),
                ):
                networks.isEmpty
                    ? const SizedBox(height: 20, child: Center(child: Text("No networks found.")))
                    : ValueListenableBuilder<String?>(
                  valueListenable: connectingNetwork,
                  builder: (dialogContext, connectingSsid, _) {
                    return ListView.builder(
                      shrinkWrap: true,
                      itemCount: networks.length,
                      itemBuilder: (context, index) {
                        final net = networks[index];
                        final ssid = net["SSID"] ?? "Unknown";
                        final bool isSecured = (net["SECURITY"] != null);

                        return ListTile(
                          leading: Icon(
                            Icons.wifi,
                            color: net["SIGNAL"] >= 75
                                ? Colors.green
                                : (net["SIGNAL"] >= 50 ? Colors.orange : Colors.red),
                          ),
                          title: Text(ssid),
                          subtitle: Text("Signal: ${net["SIGNAL"]}%"),
                          trailing: connectingSsid == ssid
                              ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                              : (net["IN-USE"] == "1"
                              ? const Icon(Icons.check_circle, color: Colors.blue)
                              : null),
                          onTap: () async {
                            connectingNetwork.value = ssid;

                            final communicationService = context.read<CommunicationService>();

                            if (isSecured) {
                              final password = await showPasswordDialog(context, ssid);
                              if (password == null || password.isEmpty) return;

                              final payload = '2,$ssid,$password';
                              final livePayload = jsonEncode({"6000": {"6001": payload}});
                              await communicationService.sendCommand(serverMsg: '', payload: livePayload);
                            } else {
                              final payload = '2,$ssid,';
                              final livePayload = jsonEncode({"6000": {"6001": payload}});
                              await communicationService.sendCommand(serverMsg: '', payload: livePayload);
                            }
                          },
                        );
                      },
                    );
                  },
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Cancel"),
                )
              ],
            );
          },
        );
      },
    );
  }

  Future<String?> showPasswordDialog(BuildContext context, String ssid) async {
    final TextEditingController passwordController = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Enter password for "$ssid"'),
        content: PasswordField(controller: passwordController),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, null),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, passwordController.text),
            child: const Text("Connect"),
          ),
        ],
      ),
    );
  }

}



