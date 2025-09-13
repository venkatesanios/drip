import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../Screens/Dealer/controllerverssionupdate.dart';
import '../../../Screens/planning/FactoryReset.dart';
import '../../../models/customer/site_model.dart';
import '../../../modules/PumpController/view/node_settings.dart';
import '../../../modules/UserChat/view/user_chat.dart';
import '../../../modules/bluetooth_low_energy/view/node_connection_page.dart';
import '../../../modules/open_ai/view/open_ai_screen.dart';
import '../../../providers/user_provider.dart';
import '../../../repository/repository.dart';
import '../../../services/http_service.dart';
import '../../../utils/constants.dart';
import '../../../utils/enums.dart';
import '../../../utils/routes.dart';
import '../../../utils/shared_preferences_helper.dart';
import '../../../view_models/customer/customer_screen_controller_view_model.dart';
import '../../common/user_profile/user_profile.dart';
import '../sent_and_received.dart';
import 'alarm_button.dart';

List<Widget> appBarActions(BuildContext context, CustomerScreenControllerViewModel vm,
    MasterControllerModel master, isNarrow) {

  final loggedInUser = Provider.of<UserProvider>(context, listen: false).loggedInUser;
  final viewedCustomer = Provider.of<UserProvider>(context, listen: false).viewedCustomer;

  final isGem = [...AppConstants.gemModelList, ...AppConstants.ecoGemModelList,].contains(master.modelId);

  if (isGem) {

    if(isNarrow){
      return [
        Consumer<CustomerScreenControllerViewModel>(
          builder: (context, vm, child) {
            return Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (vm.programRunning)
                  CircleAvatar(
                    radius: 15,
                    backgroundImage:
                    const AssetImage('assets/gif/water_drop_ani.gif'),
                    backgroundColor: Colors.blue.shade100,
                  ),
              ],
            );
          },
        ),
        const SizedBox(width: 8),
        AlarmButton(
          alarmPayload: vm.alarmDL,
          deviceID: master.deviceId,
          customerId: viewedCustomer!.id,
          controllerId: master.controllerId,
          irrigationLine: master.irrigationLine,
        ),
        IconButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const AIChatScreen()),
            );
          },
          icon: const Icon(Icons.assistant),
        ),
      ];
    }else{
      return [
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [

            Consumer<CustomerScreenControllerViewModel>(
              builder: (context, vm, child) {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    vm.programRunning ? CircleAvatar(
                      radius: 15,
                      backgroundImage: const AssetImage('assets/gif/water_drop_ani.gif'),
                      backgroundColor: Colors.blue.shade100,
                    )
                        : const SizedBox(),
                  ],
                );
              },
            ),

            const SizedBox(width: 10,),

            (vm.lineLiveMessage.isNotEmpty && master.irrigationLine.length > 1)?
            Builder(
              builder: (context) {
                bool allPaused = vm.lineLiveMessage.every((line) {
                  final parts = line.split(',');
                  return parts.length > 1 && parts[1] == '1';
                });

                return TextButton(
                  onPressed: () => vm.linePauseOrResume(vm.lineLiveMessage),
                  style: ButtonStyle(
                    backgroundColor: WidgetStateProperty.all<Color>(
                      allPaused ? Colors.green : Colors.amber,
                    ),
                    shape: WidgetStateProperty.all<OutlinedBorder>(
                      RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        allPaused ? Icons.play_arrow_outlined : Icons.pause,
                        color: Colors.black,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        allPaused ? 'RESUME ALL LINE' : 'PAUSE ALL LINE',
                        style: const TextStyle(color: Colors.black54),
                      ),
                    ],
                  ),
                );
              },
            ):
            const SizedBox(),

            const SizedBox(width: 10),
            const IconButton(color: Colors.transparent, onPressed: null, icon: CircleAvatar(
              radius: 17,
              backgroundColor: Colors.black12,
              child: Icon(Icons.mic, color: Colors.black26,),
            )),
            IconButton(tooltip : 'Help & Support', onPressed: (){
              showMenu(
                context: context,
                color: Colors.white,
                position: const RelativeRect.fromLTRB(100, 0, 50, 0),
                items: <PopupMenuEntry>[
                  PopupMenuItem(
                    child: Column(
                      children: [
                        ListTile(
                          leading: const Icon(Icons.info_outline),
                          title: const Text('App info'),
                          onTap: () {
                            Navigator.pop(context);
                          },
                        ),
                        ListTile(
                          leading: const Icon(Icons.help_outline),
                          title: const Text('Help'),
                          onTap: () {
                            Navigator.pop(context);
                            Navigator.push(
                                context,
                                MaterialPageRoute(builder: (BuildContext context) => UserChatScreen(
                                    userId: vm.mySiteList.data[vm.sIndex].customerId,
                                    userName: vm.mySiteList.data[vm.sIndex].customerName,
                                    phoneNumber: viewedCustomer!.mobileNo))
                            );
                          },
                        ),
                        ListTile(
                          leading: const Icon(Icons.info_outline),
                          title: const Text('Controller info'),
                          onTap: () {
                            Navigator.pop(context);
                            if(loggedInUser.role == UserRole.admin){
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) =>
                                    ResetVerssion(userId: vm.mySiteList.data[vm.sIndex].customerId,
                                      controllerId: master.controllerId,
                                      deviceID: master.deviceId,)),
                              );
                            }
                            else
                            {
                              showPasswordDialog(context,'Oro@321',vm.mySiteList.data[vm.sIndex].customerId,
                                  master.controllerId, master.deviceId,1);
                            }

                          },
                        ),
                        ListTile(
                          leading: const Icon(Icons.restore),
                          title: const Text('Factory Reset'),
                          onTap: () {
                            Navigator.pop(context);
                            if(loggedInUser.role == UserRole.admin){
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) =>
                                    ResetAccumalationScreen(userId: vm.mySiteList.data[vm.sIndex].customerId,
                                      controllerId: master.controllerId,
                                      deviceID: master.deviceId,)),
                              );
                            }
                            else
                            {
                              showPasswordDialog(context,'Oro@321',vm.mySiteList.data[vm.sIndex].customerId,
                                  master.controllerId, master.deviceId,2);
                            }
                          },
                        ),
                        const Divider(height: 0),
                        ListTile(
                          leading: const Icon(Icons.feedback_outlined),
                          title: const Text('Send feedback'),
                          onTap: () {
                            Navigator.pop(context);
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              );
            }, icon: const CircleAvatar(
              radius: 17,
              backgroundColor: Colors.white,
              child: Icon(Icons.live_help_outlined),
            )),
            IconButton(tooltip : 'Your Account\n${viewedCustomer!.name}\n ${viewedCustomer.mobileNo}', onPressed: (){
              showMenu(
                context: context,
                position: const RelativeRect.fromLTRB(100, 0, 10, 0),
                color: Colors.white,
                items: <PopupMenuEntry>[
                  PopupMenuItem(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Center(
                          child: CircleAvatar(radius: 30, backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
                            child: Text(viewedCustomer.name.substring(0, 1).toUpperCase(),
                                style: const TextStyle(fontSize: 25)),),
                        ),
                        Text('Hi, ${viewedCustomer.name}!',style: const TextStyle(fontSize: 20)),
                        Text(viewedCustomer.mobileNo, style: const TextStyle(fontSize: 13)),
                        const SizedBox(height: 8),
                        MaterialButton(
                          color: Theme.of(context).primaryColor,
                          textColor: Colors.white,
                          child: const Text('Manage Your Account'),
                          onPressed: () async {
                            Navigator.pop(context);
                            showModalBottomSheet(
                              context: context,
                              isScrollControlled: true,
                              builder: (context) => FractionallySizedBox(
                                heightFactor: 0.84,
                                widthFactor: 0.75,
                                child: Container(
                                  decoration: const BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
                                  ),
                                  child: const UserProfile(),
                                ),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 8),
                        TextButton(onPressed: () async {
                          await PreferenceHelper.clearAll();
                          Navigator.pushNamedAndRemoveUntil(context, Routes.login, (route) => false,);
                        },
                          child: const SizedBox(
                            width:100,
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.exit_to_app, color: Colors.red),
                                SizedBox(width: 7),
                                Text('Logout', style: TextStyle(color: Colors.red),),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
                icon: CircleAvatar(
                  radius: 17,
                  backgroundColor: Colors.white,
                  child: Text(viewedCustomer.name.substring(0, 1).toUpperCase()),
                )
            ),

            if(master.nodeList.isNotEmpty && master.categoryId == 2 && [48, 49].contains(master.modelId))
              IconButton(
                  onPressed: (){
                    showModalBottomSheet(
                        context: context,
                        builder: (context) {
                          return NodeSettings(
                            userId: viewedCustomer.id,
                            controllerId: master.controllerId,
                            customerId: vm.mySiteList.data[vm.sIndex].customerId,
                            nodeList: master.nodeList,
                            deviceId: master.deviceId,
                          );
                        }
                    );
                  },
                  icon: const Icon(Icons.settings_remote)
              ),

            const SizedBox(width: 8),

          ]),
      ];
    }

  } else {
    return [
      _buildNonGemActions(context, master, loggedInUser, viewedCustomer),
    ];
  }
}

void showPasswordDialog(BuildContext context, correctPassword,userId,controllerID,imeiNumber,type) {
  final TextEditingController passwordController = TextEditingController();
  print('userId:$userId,controllerID:$controllerID,imeiNumber:$imeiNumber');
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Enter Password'),
        content: TextField(
          controller: passwordController,
          obscureText: true,
          decoration: const InputDecoration(
            labelText: 'Password',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async{
              final userPsw = passwordController.text;

              try{
                final Repository repository = Repository(HttpService());
                var getUserDetails = await repository.checkpassword({
                  "passkey": userPsw
                });

                if (getUserDetails.statusCode == 200) {
                  var jsonData = jsonDecode(getUserDetails.body);
                  print("jsonData$jsonData");
                  if (jsonData['code'] == 200) {
                    print("getUserDetails.body: ${getUserDetails.body}");
                    if (type == 1) {
                      Navigator.of(context).pop();
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) =>
                            ResetVerssion(userId: userId,
                              controllerId: controllerID,
                              deviceID: imeiNumber,)),
                      );
                    }
                    else if (type == 2) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              ResetAccumalationScreen(userId: userId,
                                  controllerId: controllerID,
                                  deviceID: imeiNumber),
                        ),
                      );
                    }
                  } else {
                    Navigator.of(context).pop(); // Close the dialog
                    showErrorDialog(context);
                  }
                }
              }
              catch (e, stackTrace) {
                print(' Error overAll getData => ${e.toString()}');
                print(' trace overAll getData  => ${stackTrace}');
              }
            },
            child: const Text('Submit'),
          ),
        ],
      );
    },
  );
}

void showErrorDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Error'),
        content: const Text('Incorrect password. Please try again.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('OK'),
          ),
        ],
      );
    },
  );
}

Widget _buildNonGemActions(BuildContext context, dynamic master,
    dynamic loggedInUser, dynamic viewedCustomer) {
  return Container(
    height: 35,
    decoration: BoxDecoration(
      color: MediaQuery.of(context).size.width >= 600 ?
      Colors.transparent : Theme.of(context).primaryColorLight,
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(25),
        bottomLeft: Radius.circular(25),
      ),
    ),
    child: Row(
      children: [
        if (master.nodeList.isNotEmpty && [48, 49].contains(master.modelId))...[
          InkWell(
            onTap: () {
              showModalBottomSheet(
                context: context,
                builder: (context) => NodeSettings(
                  userId: viewedCustomer!.id,
                  controllerId: master.controllerId,
                  customerId: viewedCustomer.id,
                  nodeList: master.nodeList,
                  deviceId: master.deviceId,
                ),
              );
            },
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 8),
              child: Icon(Icons.settings_remote),
            ),
          ),
        ],
        InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => SentAndReceived(
                  customerId: loggedInUser.id,
                  controllerId: master.controllerId,
                ),
              ),
            );
          },
          child: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 8),
            child: Icon(Icons.question_answer_outlined),
          ),
        ),
        if (!kIsWeb)...[
          InkWell(
            onTap: () {
              final Map<String, dynamic> data = {
                'controllerId': master.controllerId,
                'deviceId': master.deviceId,
                'deviceName': master.deviceName,
                'categoryId': master.categoryId,
                'categoryName': master.categoryName,
                'modelId': master.modelId,
                'modelName': master.modelName,
                'InterfaceType': 1,
                'interface': 'GSM',
                'relayOutput': 3,
                'latchOutput': 0,
                'analogInput': 8,
                'digitalInput': 4,
              };
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => NodeConnectionPage(
                    nodeData: data,
                    masterData: {
                      "userId": loggedInUser.id,
                      "customerId": viewedCustomer!.id,
                      "controllerId": master.controllerId,
                    },
                  ),
                ),
              );
            },
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 8),
              child: Icon(Icons.bluetooth),
            ),
          ),
        ],
        InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const AIChatScreen()),
            );
          },
          child: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 8),
            child: Icon(Icons.assistant),
          ),
        ),
      ],
    ),
  );
}