import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:oro_drip_irrigation/Models/customer/site_model.dart';
import 'package:provider/provider.dart';
import '../../StateManagement/mqtt_payload_provider.dart';
import '../../utils/snack_bar.dart';
import '../../view_models/customer/node_list_view_model.dart';

class NodeList extends StatelessWidget {
  const NodeList({super.key, required this.customerId, required this.userId, required this.controllerId, required this.deviceId, required this.deviceName, required this.nodes});
  final int userId, controllerId, customerId;
  final String deviceId, deviceName;
  final List<NodeListModel> nodes;

  @override
  Widget build(BuildContext context) {

    return ChangeNotifierProvider(
      create: (_) => NodeListViewModel(context, nodes),
      child: Consumer<NodeListViewModel>(
        builder: (context, vm, _) {

          return Consumer<MqttPayloadProvider>(
            builder: (context, mqttProvider, child) {
              var nodeLiveMessage = mqttProvider.nodeLiveMessage;
              var relayOnOffStatus = mqttProvider.outputStatusPayload;

              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (vm.shouldUpdate(nodeLiveMessage, relayOnOffStatus)) {
                  vm.onLivePayloadReceived(
                    List.from(nodeLiveMessage),
                    List.from(relayOnOffStatus),
                  );
                }
              });

              return Container(
                padding: kIsWeb ? const EdgeInsets.all(10) : const EdgeInsets.all(0),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.zero,
                ),
                height: MediaQuery.sizeOf(context).height ,
                width: 400,
                child: Column(
                  children: [
                    Row(
                      children: [
                        IconButton(
                          tooltip: 'Close',
                          icon: const Icon(Icons.close, color: Colors.redAccent),
                          onPressed: () async {
                            Navigator.of(context).pop();
                          },
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 5, right: 5),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          const Expanded(child: Text('NODE STATUS', style: TextStyle(color: Colors.black, fontSize: 15))),
                          IconButton(tooltip:'Hourly Power Logs for the Node',onPressed: (){
                            /*Navigator.push(context,
                    MaterialPageRoute(
                      builder: (context) => NodeHrsLog(userId: widget.customerId, controllerId: widget.controllerId,),
                    ),
                  );*/
                          }, icon: Icon(Icons.power_outlined, color: Theme.of(context).primaryColorDark,)),
                          IconButton(tooltip:'Hourly Sensor Logs',onPressed: (){
                            /*Navigator.push(context,
                    MaterialPageRoute(
                      builder: (context) => SensorHourlyLogs(userId: widget.customerId, controllerId: widget.controllerId,),
                    ),
                  );*/
                          }, icon: Icon(Icons.settings_input_antenna, color: Theme.of(context).primaryColorDark,)),
                        ],
                      ),
                    ),
                    const Divider(),
                    SizedBox(
                      height: 50,
                      child: Row(
                        children: [
                          Row(
                            children: [
                              const SizedBox(width: 5),
                              const Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      SizedBox(width: 5),
                                      CircleAvatar(radius: 5, backgroundColor: Colors.green,),
                                      SizedBox(width: 5),
                                      Text('Connected', style: TextStyle(fontWeight: FontWeight.normal, fontSize: 12, color: Colors.black))
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      SizedBox(width: 5),
                                      CircleAvatar(radius: 5, backgroundColor: Colors.grey),
                                      SizedBox(width: 5),
                                      Text('No Communication', style: TextStyle(fontWeight: FontWeight.normal, fontSize: 12, color: Colors.black))
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(width: 10),
                              const Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      SizedBox(width: 10),
                                      CircleAvatar(radius: 5, backgroundColor: Colors.redAccent,),
                                      SizedBox(width: 5),
                                      Text('Set Serial Error', style: TextStyle(fontWeight: FontWeight.normal, fontSize: 12, color: Colors.black))
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      SizedBox(width: 10),
                                      CircleAvatar(radius: 5, backgroundColor: Colors.yellow),
                                      SizedBox(width: 5),
                                      Text('Low Battery', style: TextStyle(fontWeight: FontWeight.normal, fontSize: 12, color: Colors.black))
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(width: 20),
                              SizedBox(
                                width: 40,
                                child: IconButton(
                                  tooltip: 'Set serial for all Nodes',
                                  icon: Icon(Icons.format_list_numbered, color: vm.getPermissionStatusBySNo(context, 7)? Theme.of(context).primaryColorDark : Colors.black26),
                                  onPressed: vm.getPermissionStatusBySNo(context, 7)?() async {
                                    showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          title: const Text('Confirmation'),
                                          content: const Text('Are you sure! you want to proceed to reset all node ids?'),
                                          actions: <Widget>[
                                            MaterialButton(
                                              color: Colors.redAccent,
                                              textColor: Colors.white,
                                              onPressed: () {
                                                Navigator.of(context).pop();
                                              },
                                              child: const Text('Cancel'),
                                            ),
                                            MaterialButton(
                                              color: Theme.of(context).primaryColor,
                                              textColor: Colors.white,
                                              onPressed: () {
                                                vm.setSerialToAllNodes(deviceId, customerId, controllerId, userId);
                                                GlobalSnackBar.show(context, 'Sent your comment successfully', 200);
                                                Navigator.of(context).pop();
                                              },
                                              child: const Text('Yes'),
                                            ),
                                          ],
                                        );
                                      },
                                    );
                                  }:null,
                                ),
                              ),
                              SizedBox(
                                width: 40,
                                child: IconButton(
                                  tooltip: 'Test Communication',
                                  icon: Icon(Icons.network_check, color: vm.getPermissionStatusBySNo(context, 8)? Theme.of(context).primaryColorDark:Colors.black26),
                                  onPressed: vm.getPermissionStatusBySNo(context, 8)? () async {
                                    vm.testCommunication(deviceId, customerId, controllerId, userId);
                                    GlobalSnackBar.show(context, 'Sent your comment successfully', 200);
                                  }:null,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      width: 400,
                      height: MediaQuery.sizeOf(context).height-170,
                      child: Column(
                        children: [
                          SizedBox(
                            width:400,
                            height: 35,
                            child: DataTable2(
                              columnSpacing: 12,
                              horizontalMargin: 12,
                              minWidth: 400,
                              headingRowHeight: 35.0,
                              headingRowColor: WidgetStateProperty.all<Color>(Theme.of(context).primaryColorDark.withOpacity(0.3)),
                              columns: const [
                                DataColumn2(
                                    label: Center(child: Text('S.No', style: TextStyle(fontWeight: FontWeight.normal, fontSize: 13, color: Colors.black),)),
                                    fixedWidth: 35
                                ),
                                DataColumn2(
                                  label: Center(child: Text('Status', style: TextStyle(fontWeight: FontWeight.normal, fontSize: 13, color: Colors.black),)),
                                  fixedWidth: 55,
                                ),
                                DataColumn2(
                                  label: Center(child: Text('Rf.No', style: TextStyle(fontWeight: FontWeight.normal, fontSize: 13, color: Colors.black),)),
                                  fixedWidth: 45,
                                ),
                                DataColumn2(
                                  label: Text('Category', style: TextStyle(fontWeight: FontWeight.normal, fontSize: 13, color: Colors.black),),
                                  size: ColumnSize.M,
                                  numeric: true,
                                ),
                                DataColumn2(
                                  label: Text('Info', style: TextStyle(fontWeight: FontWeight.normal, fontSize: 13, color: Colors.black),),
                                  fixedWidth: 100,
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
                                  //initiallyExpanded: true,
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      vm.nodeList[index].rlyStatus.any((rly) => rly.status == 2 || rly.status == 3)? const Icon(Icons.warning, color: Colors.orangeAccent):
                                      const Icon(Icons.info_outline,),
                                      IconButton(
                                        onPressed: () {
                                          vm.showEditProductDialog(context, vm.nodeList[index].deviceName, vm.nodeList[index].controllerId, index);
                                        },
                                        icon: Icon(Icons.edit_outlined, color: Theme.of(context).primaryColorDark,),
                                      ),
                                    ],
                                  ),
                                  backgroundColor: Colors.teal.shade50,
                                  title: Row(
                                    children: [
                                      SizedBox(width: 30, child: Text('${vm.nodeList[index].serialNumber}', style: const TextStyle(fontSize: 13),)),
                                      SizedBox(
                                        width:50,
                                        child: Center(child: CircleAvatar(radius: 7, backgroundColor:
                                        vm.nodeList[index].status == 1? Colors.green.shade400:
                                        vm.nodeList[index].status == 2? Colors.grey:
                                        vm.nodeList[index].status == 3? Colors.redAccent:
                                        vm.nodeList[index].status == 4? Colors.yellow:
                                        Colors.grey,
                                        )),
                                      ),
                                      SizedBox(width: 40, child: Center(child: Text('${vm.nodeList[index].referenceNumber}', style: const TextStyle(fontSize: 13),))),
                                      SizedBox(
                                        width: 142,
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.end,
                                          mainAxisAlignment: MainAxisAlignment.end,
                                          children: [
                                            Text(vm.nodeList[index].deviceName, style: const TextStyle(fontWeight: FontWeight.normal, color: Colors.black, fontSize: 13)),
                                            Text(vm.nodeList[index].deviceId, style: const TextStyle(fontWeight: FontWeight.normal,fontSize: 11, color: Colors.black)),
                                            RichText(
                                              text: TextSpan(
                                                children: <TextSpan>[
                                                  TextSpan(text: '${vm.nodeList[index].categoryName} - ', style: const TextStyle(fontWeight: FontWeight.normal,fontSize: 10, color: Colors.black)),
                                                  TextSpan(text: vm.mapInterfaceType(vm.nodeList[index].interface), style: const TextStyle(fontWeight: FontWeight.bold,fontSize: 10, color: Colors.black),),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
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
                                            width : 370,
                                            height: 25,
                                            child: Padding(
                                              padding: const EdgeInsets.only(left: 5, right: 5),
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  const Text('Missed communication :', style: TextStyle(fontWeight: FontWeight.normal),),
                                                  const Spacer(),
                                                  Text(
                                                    'Total : ${vm.nodeList[index].communicationCount.split(',').first}',
                                                    style: const TextStyle(fontSize: 12),
                                                  ),
                                                  const SizedBox(width: 8,),
                                                  Text(
                                                    'Continuous : ${vm.nodeList[index].communicationCount.split(',').last}',
                                                    style: const TextStyle(fontSize: 12),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                          ListTile(
                                            tileColor: Theme.of(context).primaryColor,
                                            textColor: Colors.black,
                                            title: const Text('Last feedback', style: TextStyle(fontSize: 10)),
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
                                                    vm.actionSerialSet(index, deviceId, customerId, controllerId, userId);
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
                                                    childAspectRatio: 1.45,
                                                  ),
                                                  itemBuilder: (BuildContext context, int indexGv) {
                                                    return Column(
                                                      children: [
                                                        CircleAvatar(
                                                          radius: 13,
                                                          backgroundColor: vm.nodeList[index].rlyStatus[indexGv]
                                                              .status ==
                                                              0
                                                              ? Colors.grey
                                                              : vm.nodeList[index].rlyStatus[indexGv].status ==
                                                              1
                                                              ? Colors.green
                                                              : vm.nodeList[index].rlyStatus[indexGv]
                                                              .status ==
                                                              2
                                                              ? Colors.orange
                                                              : vm.nodeList[index].rlyStatus[indexGv]
                                                              .status ==
                                                              3
                                                              ? Colors.redAccent
                                                              : Colors.black12, // Avatar background color
                                                          child: Text(
                                                            (vm.nodeList[index].rlyStatus[indexGv].rlyNo)
                                                                .toString(),
                                                            style: const TextStyle(color: Colors.white, fontSize: 12),
                                                          ),
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

                                              /*if (nodeList[index].rlyStatus.isNotEmpty ||
                                       nodeList[index].sensor.isNotEmpty)
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
                                     height: calculateGridHeight(nodeList[index].rlyStatus.length),
                                     child: GridView.builder(
                                       itemCount: nodeList[index].rlyStatus.length, // Number of items in the grid
                                       gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                         crossAxisCount: 5,
                                         crossAxisSpacing: 5.0,
                                         mainAxisSpacing: 5.0,
                                         childAspectRatio: 1.45,
                                       ),
                                       itemBuilder: (BuildContext context, int indexGv) {
                                         return Column(
                                           children: [
                                             CircleAvatar(
                                               radius: 13,
                                               backgroundColor: nodeList[index].rlyStatus[indexGv]
                                                   .Status ==
                                                   0
                                                   ? Colors.grey
                                                   : nodeList[index].rlyStatus[indexGv].Status ==
                                                   1
                                                   ? Colors.green
                                                   : nodeList[index].rlyStatus[indexGv]
                                                   .Status ==
                                                   2
                                                   ? Colors.orange
                                                   : nodeList[index].rlyStatus[indexGv]
                                                   .Status ==
                                                   3
                                                   ? Colors.redAccent
                                                   : Colors.black12, // Avatar background color
                                               child: Text(
                                                 (nodeList[index].rlyStatus[indexGv].rlyNo)
                                                     .toString(),
                                                 style: const TextStyle(color: Colors.white, fontSize: 12),
                                               ),
                                             ),
                                             Text(
                                               (nodeList[index].rlyStatus[indexGv].swName!.isNotEmpty
                                                   ? nodeList[index].rlyStatus[indexGv].swName
                                                   : nodeList[index].rlyStatus[indexGv].name)
                                                   .toString(),
                                               style:
                                               const TextStyle(color: Colors.black, fontSize: 9),
                                             ),
                                           ],
                                         );
                                       },
                                     ),
                                   ),
                                   nodeList[index].sensor.isNotEmpty? const Padding(
                                     padding: EdgeInsets.only(left: 8, right: 8),
                                     child: Divider(
                                       thickness: 0.5,
                                     ),
                                   ):
                                   const SizedBox(),
                                   nodeList[index].sensor.isNotEmpty? SizedBox(
                                     width: double.infinity,
                                     height: calculateGridHeight(nodeList[index].sensor.length),
                                     child: GridView.builder(
                                       itemCount: nodeList[index].sensor.length, // Number of items in the grid
                                       gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                         crossAxisCount: 5,
                                         crossAxisSpacing: 5.0,
                                         mainAxisSpacing: 5.0,
                                         childAspectRatio: 1.45,
                                       ),
                                       itemBuilder: (BuildContext context, int indexSnr) {
                                         return Column(
                                           crossAxisAlignment: CrossAxisAlignment.center,
                                           mainAxisAlignment: MainAxisAlignment.center,
                                           children: [
                                             CircleAvatar(
                                               radius: 13,
                                               backgroundColor: Colors.black38,
                                               child: Text(
                                                 textAlign: TextAlign.center,
                                                 (nodeList[index].sensor[indexSnr].angIpNo !=
                                                     null
                                                     ? 'A-${nodeList[index].sensor[indexSnr].angIpNo}'
                                                     : 'P-${nodeList[index].sensor[indexSnr].pulseIpNo}')
                                                     .toString(),
                                                 style: const TextStyle(color: Colors.white, fontSize: 10),
                                               ),
                                             ),
                                             Text(
                                               (nodeList[index].sensor[indexSnr].swName!.isNotEmpty
                                                   ? nodeList[index].sensor[indexSnr].swName
                                                   : nodeList[index].sensor[indexSnr].name)
                                                   .toString(),
                                               style: const TextStyle(color: Colors.black, fontSize: 8),
                                             ),
                                           ],
                                         );
                                       },
                                     ),
                                   ):
                                   const SizedBox(),*/
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
                    )
                  ],
                ),
              ); // or your widget
            },
          );

        },
      ),
    );
  }

}