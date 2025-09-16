import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:oro_drip_irrigation/models/customer/site_model.dart';
import 'package:oro_drip_irrigation/modules/bluetooth_low_energy/view/node_connection_page.dart';
import 'package:oro_drip_irrigation/services/http_service.dart';
import 'package:oro_drip_irrigation/views/customer/widgets/relay_status_avatar.dart';
import 'package:provider/provider.dart';
import '../../../StateManagement/mqtt_payload_provider.dart';
import '../../../repository/repository.dart';
import '../../../utils/snack_bar.dart';
import '../../../view_models/customer/node_list_view_model.dart';
import '../hourly_log/node_hourly_logs.dart';
import '../hourly_log/sensor_hourly_logs.dart';

class NodeList extends StatelessWidget {
  const NodeList({super.key, required this.customerId, required this.userId,
    required this.nodes, required this.configObjects, required this.masterData,
    required this.isWide});
  final int userId, customerId;
  final MasterControllerModel masterData;
  final List<NodeListModel> nodes;
  final List<ConfigObject> configObjects;
  final bool isWide;


  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => NodeListViewModel(context, Repository(HttpService()), nodes),
      child: isWide ? nodeListBody(context) : buildScaffold(context),
    );
  }

  Widget buildScaffold(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Node Status'),
        actions: actionButtons(context, isWide: false),
      ),
      body: nodeListBody(context),
    );
  }

  Widget nodeListBody(BuildContext context) {

    final isNova = [56, 57, 58, 59].contains(masterData.modelId);

    return Consumer2<NodeListViewModel, MqttPayloadProvider>(
      builder: (context, vm, mqttProvider, _) {
        final nodeLiveMessage = mqttProvider.nodeLiveMessage;
        final outputOnOffPayload = mqttProvider.outputOnOffPayload;

        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (vm.shouldUpdate(nodeLiveMessage, outputOnOffPayload)) {
            vm.onLivePayloadReceived(
              List.from(nodeLiveMessage),
              List.from(outputOnOffPayload),
              isNova? true:false,
            );
          }
        });

        return Container(
          padding: isWide ? const EdgeInsets.all(10) : EdgeInsets.zero,
          color: Colors.white,
          height: MediaQuery.of(context).size.height,
          width: isWide ? 400 : MediaQuery.of(context).size.width,
          child: Column(
            children: [
              buildHeader(context),
              const Divider(height: 0, thickness: 0.4),
              buildStatusHeaderRow(context, vm, isNova ? true:false),
              const Divider(height: 0),
              Container(
                color: isNova ? Colors.teal.shade50 : Colors.white,
                width: 400,
                height: kIsWeb ?MediaQuery.sizeOf(context).height-190:
                MediaQuery.sizeOf(context).height-274,
                child: isNova ? Column(
                  children: [
                    const SizedBox(height: 5),
                    const SizedBox(
                      width: double.infinity,
                      height: 20,
                      child: Row(
                        children: [
                          SizedBox(width: 10),
                          CircleAvatar(
                            radius: 5,
                            backgroundColor: Colors.green,
                          ),
                          SizedBox(width: 5),
                          Text('ON', style: TextStyle(fontSize: 12)),
                          SizedBox(width: 20),
                          CircleAvatar(
                            radius: 5,
                            backgroundColor: Colors.black45,
                          ),
                          SizedBox(width: 5),
                          Text('OFF', style: TextStyle(fontSize: 12)),
                          SizedBox(width: 20),
                          CircleAvatar(
                            radius: 5,
                            backgroundColor: Colors.orange,
                          ),
                          SizedBox(width: 5),
                          Text('ON in OFF', style: TextStyle(fontSize: 12)),
                          SizedBox(width: 20),
                          CircleAvatar(
                            radius: 5,
                            backgroundColor: Colors.redAccent,
                          ),
                          SizedBox(width: 5),
                          Text('OFF in ON', style: TextStyle(fontSize: 12)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      height: vm.calculateGridHeight(masterData.ioConnection.length),
                      child: GridView.builder(
                        itemCount: masterData.ioConnection.length,
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 5,
                          crossAxisSpacing: 5.0,
                          mainAxisSpacing: 5.0,
                          childAspectRatio: 1.47,
                        ),
                        itemBuilder: (BuildContext context, int indexGv) {
                          return Column(
                            children: [
                              RelayStatusAvatar(
                                status: masterData.ioConnection[indexGv].status,
                                rlyNo: masterData.ioConnection[indexGv].rlyNo,
                                objType: masterData.ioConnection[indexGv].objType,
                              ),
                              Text(
                                (masterData.ioConnection[indexGv].swName!.isNotEmpty
                                    ? masterData.ioConnection[indexGv].swName
                                    : masterData.ioConnection[indexGv].name)
                                    .toString(),
                                style:
                                const TextStyle(color: Colors.black, fontSize: 9),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ],
                ) :
                Column(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      height: 35,
                      child: DataTable2(
                        columnSpacing: 0,
                        horizontalMargin: 0,
                        minWidth: 400,
                        headingRowHeight: 35.0,
                        headingRowColor: WidgetStateProperty.all<Color>(Theme.of(context).primaryColorDark.withOpacity(0.3)),
                        columns: const [
                          DataColumn2(
                              label: Center(child: Text('SR.No', style: TextStyle(fontWeight: FontWeight.normal, fontSize: 13, color: Colors.black),)),
                              fixedWidth: 60
                          ),
                          DataColumn2(
                            label: Text('Status & Category', style: TextStyle(fontWeight: FontWeight.normal, fontSize: 13, color: Colors.black),),
                            size: ColumnSize.L,
                          ),
                          DataColumn2(
                            label: Center(child: Text('Info', style: TextStyle(fontWeight: FontWeight.normal, fontSize: 13, color: Colors.black),)),
                            fixedWidth: 90,
                          ),
                        ],
                        rows: List<DataRow>.generate(0,(index) => const DataRow(cells: [],),
                        ),
                      ),
                    ),
                    Expanded(
                      flex:1,
                      child: ListView.builder(
                        itemCount: vm.nodeList.length,
                        itemBuilder: (context, index) {
                          return ExpansionTile(
                            tilePadding: const EdgeInsets.symmetric(horizontal: 0),
                            childrenPadding: const EdgeInsets.symmetric(horizontal: 0),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                vm.nodeList[index].rlyStatus.any((rly) => rly.status == 2 || rly.status == 3)? const Icon(Icons.warning, color: Colors.orangeAccent):
                                InkWell(
                                    onTap: (){
                                      Navigator.push(context, MaterialPageRoute(builder: (context) => NodeConnectionPage(
                                        nodeData: vm.nodeList[index].toJson(),
                                        masterData: {
                                          "userId" : userId,
                                          "customerId" : customerId,
                                          "controllerId" : masterData.controllerId
                                        },
                                      )));
                                    },
                                    child: const Icon(Icons.bluetooth,)
                                ),
                                IconButton(
                                  onPressed: () {
                                    vm.showEditProductDialog(context, vm.nodeList[index].deviceName, vm.nodeList[index].controllerId, index,
                                        customerId, userId, masterData.controllerId);
                                  },
                                  icon: Icon(Icons.edit_outlined, color: Theme.of(context).primaryColorDark,),
                                ),
                              ],
                            ),
                            backgroundColor: Colors.teal.shade50,
                            title: Padding(
                              padding: const EdgeInsets.only(left: 8),
                              child: Row(
                                children: [
                                  const SizedBox(width: 5),
                                  SizedBox(width: 45, child: Text('${vm.nodeList[index].serialNumber}-${vm.nodeList[index].referenceNumber}', style: const TextStyle(fontSize: 13),)),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            CircleAvatar(radius: 7, backgroundColor:
                                            vm.nodeList[index].status == 1? Colors.green.shade400:
                                            vm.nodeList[index].status == 2? Colors.grey:
                                            vm.nodeList[index].status == 3? Colors.redAccent:
                                            vm.nodeList[index].status == 4? Colors.yellow:
                                            Colors.grey,
                                            ),
                                            const SizedBox(width: 5),
                                            Text(vm.nodeList[index].deviceName, style: const TextStyle(fontSize: 14)),
                                          ],
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.only(left: 17),
                                          child: Text(vm.nodeList[index].deviceId, style: const TextStyle(fontWeight: FontWeight.normal,fontSize: 11, color: Colors.black)),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.only(left: 17),
                                          child: Text('${vm.nodeList[index].modelName} - v:${vm.nodeList[index].version}',
                                              style: const TextStyle(fontWeight: FontWeight.bold,fontSize: 10, color: Colors.black)),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            children: [
                              SizedBox(
                                width: double.infinity,
                                height: vm.calculateDynamicHeight(vm.nodeList[index])+20,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: <Widget>[
                                    Container(
                                      color: Colors.teal.shade100,
                                      width : MediaQuery.sizeOf(context).width-35,
                                      height: 25,
                                      child: Padding(
                                        padding: const EdgeInsets.only(left: 5, right: 5),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            const Text('Missed communication', style: TextStyle(color: Colors.black54)),
                                            const Spacer(),
                                            Text(
                                              'Total : ${vm.nodeList[index].communicationCount.split(',').first}',
                                              style: const TextStyle(fontSize: 12),
                                            ),
                                            const SizedBox(width: 8),
                                            Text(
                                              'Continuous : ${vm.nodeList[index].communicationCount.split(',').last}',
                                              style: const TextStyle(fontSize: 12),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    ListTile(
                                      contentPadding: const EdgeInsets.only(left: 8, right: 0, top: 0, bottom: 0),
                                      tileColor: Theme.of(context).primaryColor,
                                      textColor: Colors.black,
                                      title: const Text('Last feedback', style: TextStyle(fontSize: 12)),
                                      subtitle: Text(
                                        vm.formatDateTime(vm.nodeList[index].lastFeedbackReceivedTime),
                                        style: const TextStyle(fontSize: 10),
                                      ),
                                      trailing: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Icon(Icons.solar_power),
                                          const SizedBox(width: 5),
                                          Text(
                                            '${vm.nodeList[index].sVolt} - V',
                                            style: const TextStyle(fontWeight: FontWeight.normal),
                                          ),
                                          const SizedBox(width: 5),
                                          const Icon(Icons.battery_3_bar_rounded),
                                          const SizedBox(width: 5),
                                          Text(
                                            '${vm.nodeList[index].batVolt} - V',
                                            style: const TextStyle(fontWeight: FontWeight.normal),
                                          ),
                                          const SizedBox(width: 5),
                                          IconButton(
                                            tooltip: 'Serial set',
                                            onPressed: vm.getPermissionStatusBySNo(context, 7) ? () {
                                              vm.actionSerialSet(index, masterData.deviceId, customerId, masterData.controllerId, userId);
                                              GlobalSnackBar.show(context, 'Your comment sent successfully', 200);
                                            }:null,
                                            icon: Icon(Icons.fact_check_outlined, color: vm.getPermissionStatusBySNo(context, 7) ?
                                            Theme.of(context).primaryColor:Colors.black26),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Column(
                                      children: [
                                        if (vm.nodeList[index].rlyStatus.isNotEmpty)
                                          const SizedBox(
                                            width: double.infinity,
                                            height: 20,
                                            child: Row(
                                              children: [
                                                SizedBox(width: 10),
                                                CircleAvatar(
                                                  radius: 5,
                                                  backgroundColor: Colors.green,
                                                ),
                                                SizedBox(width: 5),
                                                Text('ON', style: TextStyle(fontSize: 12)),
                                                SizedBox(width: 20),
                                                CircleAvatar(
                                                  radius: 5,
                                                  backgroundColor: Colors.black45,
                                                ),
                                                SizedBox(width: 5),
                                                Text('OFF', style: TextStyle(fontSize: 12)),
                                                SizedBox(width: 20),
                                                CircleAvatar(
                                                  radius: 5,
                                                  backgroundColor: Colors.orange,
                                                ),
                                                SizedBox(width: 5),
                                                Text('ON in OFF', style: TextStyle(fontSize: 12)),
                                                SizedBox(width: 20),
                                                CircleAvatar(
                                                  radius: 5,
                                                  backgroundColor: Colors.redAccent,
                                                ),
                                                SizedBox(width: 5),
                                                Text('OFF in ON', style: TextStyle(fontSize: 12)),
                                              ],
                                            ),
                                          ),
                                        const SizedBox(height: 5),
                                        SizedBox(
                                          width: double.infinity,
                                          height: vm.calculateGridHeight(vm.nodeList[index].rlyStatus.length),
                                          child: GridView.builder(
                                            itemCount: vm.nodeList[index].rlyStatus.length, // Number of items in the grid
                                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                              crossAxisCount: 5,
                                              crossAxisSpacing: 5.0,
                                              mainAxisSpacing: 5.0,
                                              childAspectRatio: 1.47,
                                            ),
                                            itemBuilder: (BuildContext context, int indexGv) {
                                              return Column(
                                                children: [
                                                  RelayStatusAvatar(
                                                    status: vm.nodeList[index].rlyStatus[indexGv].status,
                                                    rlyNo: vm.nodeList[index].rlyStatus[indexGv].rlyNo,
                                                    objType: vm.nodeList[index].rlyStatus[indexGv].objType,
                                                  ),
                                                  Text(
                                                    (vm.nodeList[index].rlyStatus[indexGv].swName!.isNotEmpty
                                                        ? vm.nodeList[index].rlyStatus[indexGv].swName
                                                        : vm.nodeList[index].rlyStatus[indexGv].name)
                                                        .toString(),
                                                    style:
                                                    const TextStyle(color: Colors.black, fontSize: 9),
                                                  ),
                                                ],
                                              );
                                            },
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget buildHeader(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(left: kIsWeb?0:10, right: 8),
          child: ListTile(
            contentPadding: EdgeInsets.zero,
            leading: kIsWeb? IconButton(
              tooltip: 'Close',
              icon: const Icon(Icons.close, color: Colors.redAccent),
              onPressed: () => Navigator.of(context).pop(),
            ): null,
            title: Text(masterData.deviceName, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(masterData.deviceId, style: const TextStyle(fontWeight: FontWeight.normal, color: Colors.black54, fontSize: 12)),
            trailing: Consumer<MqttPayloadProvider>(
              builder: (context, provider, _) {
                List<Widget> children = [
                  Text(
                    'V: ${provider.activeDeviceVersion}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ];
                if (provider.activeLoraData.isNotEmpty) {
                  List<String> parts = provider.activeLoraData.split(',');
                  List<String> versions = [];
                  for (int i = 0; i < parts.length; i += 3) {
                    versions.add(parts[i]);
                  }

                  children.add(
                    Text(
                      'LoRa: $versions',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 10),
                    ),
                  );
                }

                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: children,
                    ),
                    const SizedBox(width: 5),
                    IconButton(onPressed: (){
                      Navigator.push(context, MaterialPageRoute(builder: (context) => NodeConnectionPage(
                        nodeData: {
                          'controllerId': masterData.controllerId,
                          'deviceId': masterData.deviceId,
                          'deviceName': masterData.deviceName,
                          'categoryId': masterData.categoryId,
                          'categoryName': masterData.categoryName,
                          'modelId': masterData.modelId,
                          'modelName': masterData.modelName,
                          'interfaceTypeId': masterData.interfaceTypeId,
                          'interface': masterData.interface,
                          'relayOutput': masterData.relayOutput,
                          'latchOutput': masterData.latchOutput,
                          'analogInput': masterData.analogInput,
                          'digitalInput': masterData.digitalInput,

                        },
                        masterData: {
                          "userId" : userId,
                          "customerId" : customerId,
                          "controllerId" : masterData.controllerId
                        },
                      )));
                    }, icon: const Icon(Icons.bluetooth))
                  ],
                );
              },
            ),
          ),
        ),
        const Divider(height: 0, thickness: 0.4),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 5),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              const Expanded(
                child: Text('NODE STATUS', style: TextStyle(color: Colors.black, fontSize: 15)),
              ),
              ...actionButtons(context),
            ],
          ),
        ),
      ],
    );
  }

  List<Widget> actionButtons(BuildContext context, {bool isWide = true}) {
    final iconColor = isWide ? Theme.of(context).primaryColorDark : Colors.white;
    return [
      IconButton(
        tooltip: 'Hourly Power Logs for the Node',
        onPressed: () {
          Navigator.push(context,
            MaterialPageRoute(
              builder: (context) => NodeHourlyLogs(userId: customerId, controllerId: masterData.controllerId, nodes: nodes),
            ),
          );
        },
        icon: Icon(Icons.power_outlined, color: iconColor),
      ),
      IconButton(
        tooltip: 'Hourly Sensor Logs',
        onPressed: () {
          Navigator.push(context,
            MaterialPageRoute(
              builder: (context) => SensorHourlyLogs(userId: customerId, controllerId: masterData.controllerId,
                configObjects: configObjects,),
            ),
          );
        },
        icon: Icon(Icons.settings_input_antenna, color: iconColor),
      ),
      if (!isWide) const SizedBox(width: 8),
    ];
  }

  Widget buildStatusHeaderRow(BuildContext context, NodeListViewModel vm, bool isNova) {
    return SizedBox(
      height: 50,
      child: Row(
        children: [
          const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  SizedBox(width: 5),
                  CircleAvatar(radius: 5, backgroundColor: Colors.green),
                  SizedBox(width: 5),
                  Text('Connected', style: TextStyle(fontSize: 12, color: Colors.black)),
                ],
              ),
              SizedBox(height: 5),
              Row(
                children: [
                  SizedBox(width: 5),
                  CircleAvatar(radius: 5, backgroundColor: Colors.grey),
                  SizedBox(width: 5),
                  Text('No Communication', style: TextStyle(fontSize: 12, color: Colors.black)),
                ],
              ),
              SizedBox(height: 5),
            ],
          ),
          const Spacer(),
          const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  SizedBox(width: 10),
                  CircleAvatar(radius: 5, backgroundColor: Colors.redAccent),
                  SizedBox(width: 5),
                  Text('Set Serial Error', style: TextStyle(fontSize: 12, color: Colors.black)),
                ],
              ),
              SizedBox(height: 5),
              Row(
                children: [
                  SizedBox(width: 10),
                  CircleAvatar(radius: 5, backgroundColor: Colors.yellow),
                  SizedBox(width: 5),
                  Text('Low Battery', style: TextStyle(fontSize: 12, color: Colors.black)),
                ],
              ),
              SizedBox(height: 5),
            ],
          ),
          const Spacer(),
          SizedBox(
            width: 40,
            child: IconButton(
              tooltip: isNova ? 'Set serial' : 'Set serial for all Nodes',
              icon: Icon(
                Icons.format_list_numbered,
                color: vm.getPermissionStatusBySNo(context, 7)
                    ? Theme.of(context).primaryColorDark
                    : Colors.black26,
              ),
              onPressed: vm.getPermissionStatusBySNo(context, 7)
                  ? () => showDialog(
                context: context,
                builder: (_) => AlertDialog(
                  title: const Text('Confirmation'),
                  content: const Text('Are you sure! you want to proceed to reset all node ids?'),
                  actions: [
                    MaterialButton(
                      color: Colors.redAccent,
                      textColor: Colors.white,
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Cancel'),
                    ),
                    MaterialButton(
                      color: Theme.of(context).primaryColor,
                      textColor: Colors.white,
                      onPressed: () {
                        vm.setSerialToAllNodes(masterData.deviceId, customerId, masterData.controllerId, userId);
                        GlobalSnackBar.show(context, 'Sent your comment successfully', 200);
                        Navigator.of(context).pop();
                      },
                      child: const Text('Yes'),
                    ),
                  ],
                ),
              )
                  : null,
            ),
          ),
          SizedBox(
            width: 40,
            child: IconButton(
              tooltip: 'Test Communication',
              icon: Icon(
                Icons.network_check,
                color: vm.getPermissionStatusBySNo(context, 8)
                    ? Theme.of(context).primaryColorDark
                    : Colors.black26,
              ),
              onPressed: vm.getPermissionStatusBySNo(context, 8)
                  ? () {
                vm.testCommunication(masterData.deviceId, customerId, masterData.controllerId, userId);
                GlobalSnackBar.show(context, 'Sent your comment successfully', 200);
              }
                  : null,
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
    );
  }
}