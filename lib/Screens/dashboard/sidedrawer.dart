import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:oro_drip_irrigation/utils/Theme/oro_theme.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';

import '../../StateManagement/mqtt_payload_provider.dart';
import '../../StateManagement/overall_use.dart';
import '../../services/http_service.dart';



class DrawerWidget extends StatefulWidget {
   List<dynamic> listOfSite;
  DrawerWidget({super.key,required this.listOfSite,});
  @override
  State<DrawerWidget> createState() => _DrawerWidgetState();
}
class _DrawerWidgetState extends State<DrawerWidget> {
  String uName = '';
  String uMobileNo = '';
  String uEmail = '';
  late OverAllUse overAllPvd;
  late MqttPayloadProvider payloadProvider;
  final String _correctPassword = 'Oro@321';
  int selectedIndex = -1;
  String currentVersion = '';

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    payloadProvider = Provider.of<MqttPayloadProvider>(context,listen: false);

    overAllPvd = Provider.of<OverAllUse>(context, listen: false);
    getUserData();
  }

  Future<void> getUserData() async {
    currentVersion =  '';
    final prefs = await SharedPreferences.getInstance();
    Future.delayed(Duration.zero, () {
      setState(() {
        // final userIdFromPref = prefs.getString('userId') ?? '';
        uName = prefs.getString('userName') ?? '';
        uMobileNo = prefs.getString('mobileNumber') ?? '';
        uEmail = prefs.getString('email') ?? '';
      });
    });
    // print("uName:$uName,uMobileNo:$uMobileNo,uEmail:$uEmail,");
  }

  @override
  Widget build(BuildContext context) {
    overAllPvd = Provider.of<OverAllUse>(context, listen: true);
    payloadProvider = Provider.of<MqttPayloadProvider>(context,listen: true);
    return Drawer(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.zero,
      ),
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColorDark,

            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                InkWell(
                  onTap: () {
                    setState(() {
                      // Navigator.pop(context);
                      // Navigator.push(
                      //   context,
                      //   MaterialPageRoute(
                      //     builder: (context) => AccountManagement(
                      //       userID: overAllPvd.userId,
                      //       callback: callbackFunction,
                      //     ),
                      //   ),
                      // );
                    });
                  },
                  child: Card(
                    shape: CircleBorder(),
                    elevation: 20,
                    child: Container(
                      width: 65,
                      height: 65,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                      ),
                      child: Text(
                        uName.isNotEmpty ? uName.substring(0, 1).toUpperCase() : uEmail.substring(0, 2).toUpperCase(),
                        style: TextStyle(
                            fontSize: 28,
                            color: Theme.of(context).primaryColor,
                            fontWeight: FontWeight.bold
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: ListTile(
                    title: Text(
                      uName,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        shadows: [
                          Shadow(
                            blurRadius: 5.0,
                            color: Colors.black12,
                            offset: Offset(2.0, 4),
                          ),
                        ],
                      ),
                    ),
                    subtitle: Text(
                      '$uMobileNo\n$uEmail',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 16,
                        shadows: [
                          Shadow(
                            blurRadius: 5.0,
                            color: Colors.black45,
                            offset: Offset(2.0, 2.0),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              children: [
                buildMenuItem(
                  icon: Icons.person_add_alt_outlined,
                  title: "Sub User",
                  function: () async {
                    // for (var site = 0; site < widget.listOfSite.length; site++) {
                    //   setState(() {
                    //     widget.listOfSite[site]['overAll'] = false;
                    //   });
                    //   for (var master = 0; master < widget.listOfSite[site]['master'].length; master++) {
                    //     setState(() {
                    //       widget.listOfSite[site]['master'][master]['selectedMaster'] = false;
                    //     });
                    //   }
                    // }
                    // await Future.delayed(Duration(milliseconds: 500));
                    Navigator.pop(context);
                    // Navigator.push(
                    //   context,
                    //   MaterialPageRoute(
                    //     builder: (context) => SubUser(listOfSite: widget.listOfSite),
                    //   ),
                    // );
                  }, index: 0,
                ),
                buildMenuItem(
                    icon: Icons.build_outlined,
                    title: "Service Request",
                    function: () {
                      Navigator.pop(context);
                      // Navigator.push(
                      //   context,
                      //   MaterialPageRoute(
                      //     builder: (context) => TicketHomePage(
                      //       userId: overAllPvd.userId,
                      //       controllerId: overAllPvd.controllerId,
                      //     ),
                      //   ),
                      // );
                    },
                    index: 1
                ),
                buildMenuItem(
                    icon: Icons.send_outlined,
                    title: "Sent and Received",
                    function: () {
                      Navigator.pop(context);
                      // Navigator.push(context, MaterialPageRoute(builder: (context) => SentAndReceived()));
                    },
                    index: 2
                ),
                buildMenuItem(
                    icon: Icons.help_outline,
                    title: "Help and Support",
                    function: () {
                      Navigator.pop(context);
                      // Navigator.push(
                      //   context,
                      //   MaterialPageRoute(
                      //     builder: (context) => UserChatScreen(
                      //       userId: overAllPvd.userId,
                      //       dealerId: 0,
                      //       userName: uName,
                      //       phoneNumber: '',
                      //     ),
                      //   ),
                      // );
                    },
                    index: 3
                ),
                buildMenuItem(
                    icon: Icons.info_outline,
                    title: "Controller Info",
                    function: () {
                      Navigator.pop(context);
                      // showPasswordDialog(context, _correctPassword);
                    },
                    index: 4
                ),
                // buildMenuItem(
                //     icon: Icons.settings_outlined,
                //     title: "Settings",
                //     function: () {
                //       Navigator.pop(context);
                //       Navigator.push(context, MaterialPageRoute(builder: (context) => SettingsMenu()));
                //     },
                //     index: 5
                // ),
                buildMenuItem(
                    icon: Icons.logout_outlined,
                    title: "Log Out",
                    function: () async {
                      setState(() {
                        logoutData();
                        payloadProvider.selectedSiteString = '';
                      });
                      // if(widget.manager.currentSubscribedTopic?.isNotEmpty ?? false) {
                      //   // widget.manager.unSubscribe(
                      //   //   unSubscribeTopic: 'FirmwareToApp/${overAllPvd.imeiNo}',
                      //   //   subscribeTopic: '',
                      //   //   publishTopic: '',
                      //   //   publishMessage: jsonEncode({"3000": [{"3001": ""}]}),
                      //   // );
                      // }
                      final prefs = await SharedPreferences.getInstance();
                      await prefs.clear();
                      if (mounted) {
                        Navigator.pushReplacementNamed(context, '/loginOTP');
                      }
                    },
                    index: 6
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.only(bottom: 15, left: 15),
            child:  Text(
              'App Version: $currentVersion',
              style: TextStyle(color: Colors.grey, fontSize: 14),
              textAlign: TextAlign.left,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildMenuItem({
    required IconData icon,
    required String title,
    required void Function() function,
    required int index,
  }) {
    final isSelected = selectedIndex == index;

    return ListTile(
      leading: Icon(
        icon,
        color: index == 6 ? Colors.red : isSelected ? Theme.of(context).primaryColor : Colors.black,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: index == 6 ? Colors.red : isSelected ? Theme.of(context).primaryColor : Colors.black,
          fontWeight: FontWeight.w500,
        ),
      ),
      tileColor: isSelected ? Theme.of(context).primaryColor.withOpacity(0.1) : Colors.transparent,
      onTap: () {
        setState(() {
          selectedIndex = index;
        });
        function();
      },
    );
  }

  Future<void> logoutData() async {
    final response = await HttpService().postRequest("userSignOut", {"userId": overAllPvd.userId, "isMobile": true});
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        print('data--->${data}');
      });
    } else {
      _showSnackBar(response.body);
    }
  }

  void callbackFunction(message) {
    Navigator.pop(context);
    Future.delayed(const Duration(milliseconds: 500), () {
      _showSnackBar(message);
    });
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 3),
      ),
    );
  }
}

void showPasswordDialog(BuildContext context, correctPassword) {
  final TextEditingController _passwordController = TextEditingController();

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Enter Password'),
        content: TextField(
          controller: _passwordController,
          obscureText: true,
          decoration: InputDecoration(
            labelText: 'Password',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final enteredPassword = _passwordController.text;

              if (enteredPassword == correctPassword) {
                Navigator.of(context).pop(); // Close the dialog
                // Navigator.push(
                //   context,
                //   MaterialPageRoute(builder: (context) => ResetVerssion()),
                // );
              } else {
                Navigator.of(context).pop(); // Close the dialog
                showErrorDialog(context);
              }
            },
            child: Text('Submit'),
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
        title: Text('Error'),
        content: Text('Incorrect password. Please try again.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text('OK'),
          ),
        ],
      );
    },
  );
}