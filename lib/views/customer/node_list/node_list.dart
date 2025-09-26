import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:oro_drip_irrigation/models/customer/site_model.dart';
import 'package:oro_drip_irrigation/modules/bluetooth_low_energy/view/node_connection_page.dart';
import 'package:oro_drip_irrigation/services/http_service.dart';
import 'package:oro_drip_irrigation/utils/helpers/mc_permission_helper.dart';
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
            );
          }
        });

        final hasSetSerial = masterData.getPermissionStatus("Set Serial");

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

              if (isNova) ...[
                _buildRelayGrid(masterData.ioConnection, vm),
              ],
              if(vm.nodeList.isNotEmpty)...[
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
              ],
              Expanded(
                child: ListView.builder(
                  itemCount: vm.nodeList.length,
                  itemBuilder: (context, index) {
                    return _buildNodeTile(context, vm.nodeList[index], vm, hasSetSerial);
                  },
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

    final hasSetSerial = masterData.getPermissionStatus("Set Serial");
    final hasTestComm = masterData.getPermissionStatus("Test Communication");

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
                color: Theme.of(context).primaryColorDark,
              ),
              onPressed: hasSetSerial ? () => showDialog(
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
              ) : null,
            ),
          ),
          SizedBox(
            width: 40,
            child: IconButton(
              tooltip: 'Test Communication',
              icon: Icon(
                Icons.network_check,
                color: Theme.of(context).primaryColorDark,
              ),
              onPressed: hasTestComm ? () {
                vm.testCommunication(masterData.deviceId, customerId, masterData.controllerId, userId);
                GlobalSnackBar.show(context, 'Sent your comment successfully', 200);
              } : null,
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
    );
  }

  Widget _buildLegendRow() {
    return const SizedBox(
      width: double.infinity,
      height: 20,
      child: Row(
        children: [
          SizedBox(width: 10),
          CircleAvatar(radius: 5, backgroundColor: Colors.green),
          SizedBox(width: 5),
          Text('ON', style: TextStyle(fontSize: 12)),
          SizedBox(width: 20),
          CircleAvatar(radius: 5, backgroundColor: Colors.black45),
          SizedBox(width: 5),
          Text('OFF', style: TextStyle(fontSize: 12)),
          SizedBox(width: 20),
          CircleAvatar(radius: 5, backgroundColor: Colors.orange),
          SizedBox(width: 5),
          Text('ON in OFF', style: TextStyle(fontSize: 12)),
          SizedBox(width: 20),
          CircleAvatar(radius: 5, backgroundColor: Colors.redAccent),
          SizedBox(width: 5),
          Text('OFF in ON', style: TextStyle(fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildRelayGrid(List<RelayStatus> rlyStatus, NodeListViewModel vm) {
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 8),
      child: SizedBox(
        width: double.infinity,
        height: vm.calculateGridHeight(rlyStatus.length),
        child: GridView.builder(
          itemCount: rlyStatus.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 5,
            crossAxisSpacing: 5.0,
            mainAxisSpacing: 5.0,
            childAspectRatio: 1.47,
          ),
          itemBuilder: (BuildContext context, int indexGv) {
            final rly = rlyStatus[indexGv];
            return Column(
              children: [
                RelayStatusAvatar(
                  status: rly.status,
                  rlyNo: rly.rlyNo,
                  objType: rly.objType,
                ),
                Text(
                  (rly.swName?.isNotEmpty ?? false ? rly.swName : rly.name).toString(),
                  style: const TextStyle(color: Colors.black, fontSize: 9),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildNodeTile(BuildContext context, NodeListModel node, NodeListViewModel vm, bool hasSetSerial) {
    return ExpansionTile(
      tilePadding: const EdgeInsets.symmetric(horizontal: 0),
      childrenPadding: const EdgeInsets.symmetric(horizontal: 0),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          node.rlyStatus.any((rly) => rly.status == 2 || rly.status == 3)
              ? const Icon(Icons.warning, color: Colors.orangeAccent)
              : InkWell(
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => NodeConnectionPage(
                nodeData: node.toJson(),
                masterData: {
                  "userId": userId,
                  "customerId": customerId,
                  "controllerId": masterData.controllerId,
                },
              )));
            },
            child: const Icon(Icons.bluetooth),
          ),
          IconButton(
            onPressed: () {
              vm.showEditProductDialog(context, node.deviceName, node.controllerId, 0,
                  customerId, userId, masterData.controllerId);
            },
            icon: Icon(Icons.edit_outlined, color: Theme.of(context).primaryColorDark),
          ),
        ],
      ),
      backgroundColor: Colors.teal.shade50,
      title: Padding(
        padding: const EdgeInsets.only(left: 8),
        child: Row(
          children: [
            const SizedBox(width: 5),
            SizedBox(
              width: 45,
              child: Text('${node.serialNumber}-${node.referenceNumber}', style: const TextStyle(fontSize: 13)),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      statusIndicator(node.status),
                      const SizedBox(width: 5),
                      Text(node.deviceName, style: const TextStyle(fontSize: 14)),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 17),
                    child: Text(node.deviceId, style: const TextStyle(fontSize: 11)),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 17),
                    child: Text('${node.modelName} - v:${node.version}', style: const TextStyle(fontSize: 10)),
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
          height: vm.calculateDynamicHeight(node) + 20,
          child: Column(
            children: [
              Container(
                color: Colors.teal.shade100,
                width: MediaQuery.sizeOf(context).width - 35,
                height: 25,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 5),
                  child: Row(
                    children: [
                      const Text('Missed communication', style: TextStyle(color: Colors.black54)),
                      const Spacer(),
                      Text('Total : ${node.communicationCount.split(',').first}', style: const TextStyle(fontSize: 12)),
                      const SizedBox(width: 8),
                      Text('Continuous : ${node.communicationCount.split(',').last}', style: const TextStyle(fontSize: 12)),
                    ],
                  ),
                ),
              ),
              ListTile(
                contentPadding: const EdgeInsets.only(left: 8),
                tileColor: Theme.of(context).primaryColor,
                title: const Text('Last feedback', style: TextStyle(fontSize: 12)),
                subtitle: Text(vm.formatDateTime(node.lastFeedbackReceivedTime), style: const TextStyle(fontSize: 10)),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.solar_power),
                    Text('${node.sVolt} - V'),
                    const SizedBox(width: 5),
                    const Icon(Icons.battery_3_bar_rounded),
                    Text('${node.batVolt} - V'),
                    IconButton(
                      tooltip: 'Serial set',
                      onPressed: hasSetSerial
                          ? () {
                        vm.actionSerialSet(0, masterData.deviceId, customerId, masterData.controllerId, userId);
                        GlobalSnackBar.show(context, 'Your comment sent successfully', 200);
                      }
                          : null,
                      icon: Icon(Icons.fact_check_outlined, color: Theme.of(context).primaryColor),
                    ),
                  ],
                ),
              ),
              if (node.rlyStatus.isNotEmpty) ...[
                _buildLegendRow(),
                const SizedBox(height: 5),
                _buildRelayGrid(node.rlyStatus, vm),
              ]
            ],
          ),
        ),
      ],
    );
  }

  Widget statusIndicator(int status, {double radius = 7}) {
    Color color;
    switch (status) {
      case 1:
        color = Colors.green.shade400;
        break;
      case 2:
        color = Colors.grey;
        break;
      case 3:
        color = Colors.redAccent;
        break;
      case 4:
        color = Colors.yellow;
        break;
      default:
        color = Colors.grey;
    }

    return CircleAvatar(
      radius: radius,
      backgroundColor: color,
    );
  }
}