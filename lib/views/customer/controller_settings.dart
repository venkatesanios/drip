import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:oro_drip_irrigation/Models/admin&dealer/dealer_definition_model.dart';
import 'package:oro_drip_irrigation/Screens/Dealer/dealer_definition.dart';
import 'package:oro_drip_irrigation/view_models/customer/controller_settings_view_model.dart';
import 'package:oro_drip_irrigation/views/customer/condition_library.dart';
import 'package:provider/provider.dart';

import '../../Models/customer/site_model.dart';
import '../../repository/repository.dart';
import '../../services/http_service.dart';
import 'constant.dart';

class ControllerSettings extends StatelessWidget {
  const ControllerSettings({super.key, required this.customerId, required this.controllerId, required this.adDrId});
  final int customerId, controllerId, adDrId;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ControllerSettingsViewModel(Repository(HttpService()))
        ..getControllerInfo(customerId, controllerId)
        ..getSubUserList(customerId)
        ..getNotificationList(customerId, controllerId)
        ..getLanguage(),
      child: Consumer<ControllerSettingsViewModel>(
        builder: (context, viewModel, _) {
          return viewModel.isLoading?
          buildLoadingIndicator(true, MediaQuery.sizeOf(context).width)
              : Scaffold(
            backgroundColor: Colors.white,
            body: DefaultTabController(
              length: 8,
              child: Column(
                children: [
                  TabBar(
                    indicatorColor: Theme.of(context).primaryColorLight,
                    labelColor: Colors.black,
                    unselectedLabelColor: Colors.grey,
                    tabs: const [
                      Tab(text: 'General'),
                      Tab(text: 'Preference'),
                      Tab(text: 'Constant'),
                      Tab(text: 'Condition Library'),
                      Tab(text: 'Notification'),
                      Tab(text: 'Names'),
                      Tab(text: 'View Settings'),
                      Tab(text: 'Dealer Definition'),
                    ],
                  ),
                  Expanded(
                    child: TabBarView(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Container(
                            color: Colors.white,
                            child: SingleChildScrollView(
                              child: Column(
                                children: [
                                  SizedBox(
                                    height: 385,
                                    child: Row(
                                      children: [
                                        Flexible(
                                          flex: 1,
                                          child: Column(
                                            children: [
                                              ListTile(
                                                title: const Text('Farm Name'),
                                                leading: const Icon(Icons.area_chart_outlined),
                                                trailing: SizedBox(
                                                  width: 300,
                                                  child: TextField(
                                                    controller: viewModel.txtEcSiteName,
                                                    decoration: const InputDecoration(
                                                      filled: false,
                                                      suffixIcon: Icon(Icons.edit),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              Divider(color: Colors.grey.shade200,),
                                              ListTile(
                                                title: const Text('Controller Name'),
                                                leading: const Icon(Icons.developer_board),
                                                trailing: SizedBox(
                                                  width: 300,
                                                  child: TextField(
                                                    controller: viewModel.txtEcGroupName,
                                                    decoration: const InputDecoration(
                                                      filled: false,
                                                      suffixIcon: Icon(Icons.edit),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              Divider(color: Colors.grey.shade200,),
                                              ListTile(
                                                title: const Text('Device Category'),
                                                leading: const Icon(Icons.category_outlined),
                                                trailing: Text(
                                                  viewModel.categoryName,
                                                  style: const TextStyle(
                                                      fontSize: 14,
                                                      fontWeight: FontWeight.bold),
                                                ),
                                              ),
                                              Divider(color: Colors.grey.shade200,),
                                              ListTile(
                                                title: const Text('Model'),
                                                leading: const Icon(Icons.model_training),
                                                trailing: Text(
                                                  viewModel.modelName,
                                                  style: const TextStyle(
                                                      fontSize: 14,
                                                      fontWeight: FontWeight.bold),
                                                ),
                                              ),
                                              Divider(color: Colors.grey.shade200,),
                                              ListTile(
                                                title: const Text('Device ID'),
                                                leading: const Icon(Icons.numbers_outlined),
                                                trailing: SelectableText(
                                                  viewModel.deviceId,
                                                  style: const TextStyle(
                                                      fontSize: 14,
                                                      fontWeight: FontWeight.bold),
                                                ),
                                              ),
                                              Divider(color: Colors.grey.shade200,),
                                              ListTile(
                                                title: const Text('Version'),
                                                leading: const Icon(Icons.perm_device_info),
                                                trailing: Row(
                                                  mainAxisSize: MainAxisSize.min,
                                                  children: [
                                                    Text(
                                                      viewModel.controllerVersion,
                                                      style: const TextStyle(
                                                          fontSize: 14,
                                                          fontWeight: FontWeight.bold),
                                                    ),
                                                    viewModel.controllerVersion != viewModel.newVersion? const SizedBox(width: 16,):
                                                    const SizedBox(),
                                                    viewModel.controllerVersion != viewModel.newVersion? TextButton(
                                                      onPressed: () {
                                                      },
                                                      child: AnimatedOpacity(
                                                        opacity: viewModel.opacity,
                                                        duration: const Duration(seconds: 2),
                                                        child: Text('New Version available - ${viewModel.newVersion}', style: const TextStyle(color: Colors.black54),),
                                                      ),
                                                    ):
                                                    const SizedBox(),
                                                  ],
                                                ),
                                              ),
                                              Divider(color: Colors.grey.shade300,),
                                            ],
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.only(bottom: 15),
                                          child: VerticalDivider(width: 0, color: Colors.grey.shade200),
                                        ),
                                        Flexible(
                                          flex: 1,
                                          child: Column(
                                            children: [
                                              ListTile(
                                                title: const Text('App Theme Color'),
                                                leading: const Icon(Icons.color_lens_outlined),
                                                trailing: DropdownButton<String>(
                                                  underline: Container(),
                                                  value: viewModel.selectedTheme,
                                                  hint: const Text('Select your theme color'),
                                                  onChanged: (String? newValue) {
                                                    if (newValue != null) {
                                                      /*setState(() {
                                                        selectedTheme = newValue;
                                                      });*/
                                                    }
                                                  },
                                                  items: viewModel.themeColors.entries
                                                      .map<DropdownMenuItem<String>>((entry) {
                                                    return DropdownMenuItem<String>(
                                                      value: entry.key,
                                                      child: Row(
                                                        children: [
                                                          Container(
                                                            width: 20,
                                                            height: 20,
                                                            color: entry.value,
                                                            margin:
                                                            const EdgeInsets.only(right: 8),
                                                          ),
                                                          Text(entry.key),
                                                        ],
                                                      ),
                                                    );
                                                  }).toList(),
                                                ),
                                              ),
                                              Divider(color: Colors.grey.shade200,),
                                              ListTile(
                                                title: const Text('UTC'),
                                                leading: const Icon(Icons.timer_outlined),
                                                trailing: DropdownButton<String>(
                                                  hint: const Text('Select Time Zone'),
                                                  value: viewModel.selectedTimeZone,
                                                  onChanged: (String? newValue) {
                                                    if (newValue != null) {
                                                      viewModel.updateCurrentDateTime(newValue);
                                                    }
                                                  },
                                                  items: viewModel.timeZones
                                                      .map<DropdownMenuItem<String>>(
                                                          (String value) {
                                                        return DropdownMenuItem<String>(
                                                          value: value,
                                                          child: Text(value),
                                                        );
                                                      }).toList(),
                                                ),
                                              ),
                                              Divider(color: Colors.grey.shade200,),
                                              ListTile(
                                                title: const Text('Current Date'),
                                                leading: Icon(Icons.date_range),
                                                trailing: Text(
                                                  viewModel.currentDate,
                                                  style: const TextStyle(
                                                      fontSize: 14,
                                                      fontWeight: FontWeight.bold),
                                                ),
                                              ),
                                              Divider(color: Colors.grey.shade200,),
                                              ListTile(
                                                title: const Text('Current UTC Time'),
                                                leading: const Icon(Icons.date_range),
                                                trailing: Text(
                                                  viewModel.currentTime,
                                                  style: const TextStyle(
                                                      fontSize: 14,
                                                      fontWeight: FontWeight.bold),
                                                ),
                                              ),
                                              Divider(color: Colors.grey.shade200,),
                                              const ListTile(
                                                title: Text('Time Format'),
                                                leading: Icon(Icons.date_range),
                                                trailing: Text(
                                                  '24 Hrs',
                                                  style: TextStyle(
                                                      fontSize: 14,
                                                      fontWeight: FontWeight.bold),
                                                ),
                                              ),
                                              Divider(color: Colors.grey.shade200,),
                                              const ListTile(
                                                title: Text('Unit'),
                                                leading: Icon(Icons.ac_unit_rounded),
                                                trailing: Text(
                                                  'm3',
                                                  style: TextStyle(
                                                      fontSize: 14,
                                                      fontWeight: FontWeight.bold),
                                                ),
                                              ),
                                              Divider(color: Colors.grey.shade300,),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(
                                    height: 50,
                                    width: MediaQuery.sizeOf(context).width,
                                    child: ListTile(
                                      trailing: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          MaterialButton(
                                            color: Colors.teal,
                                            textColor: Colors.white,
                                            onPressed: () async {
                                            },
                                            child: const Text('Restart the controller'),
                                          ),
                                          const SizedBox(width: 16,),
                                          MaterialButton(
                                            color: Colors.green,
                                            textColor: Colors.white,
                                            onPressed: () async {
                                              /*Map<String, Object> body = {
                                                'userId': widget.customerID,
                                                'controllerId':
                                                widget.siteData.master[0].controllerId,
                                                'deviceName': txtEcGroupName.text,
                                                'groupId': groupId,
                                                'groupName': txtEcSiteName.text,
                                                'modifyUser': widget.customerID,
                                                'timeZone': _selectedTimeZone ?? '',
                                              };
                                              final Response response = await HttpService()
                                                  .putRequest("updateUserMasterDetails", body);
                                              if (response.statusCode == 200) {
                                                var data = jsonDecode(response.body);
                                                if (data["code"] == 200) {
                                                  if (context.mounted) {
                                                    GlobalSnackBar.show(context, data["message"],
                                                        response.statusCode);
                                                  }
                                                }
                                              }*/
                                            },
                                            child: const Text('Save Changes'),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  ListTile(
                                    leading: const Icon(Icons.supervised_user_circle_outlined),
                                    title: const Text(
                                      'My Sub users',
                                      style:
                                      TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                                    ),
                                    trailing: adDrId != 0
                                        ? IconButton(
                                        tooltip: 'Add new sub user',
                                        onPressed: () async {

                                          /*showModalBottomSheet(
                                            context: context,
                                            isScrollControlled: true,
                                            builder: (context) {
                                              return FractionallySizedBox(
                                                heightFactor: 0.84,
                                                widthFactor: 0.75,
                                                child: Container(
                                                  decoration: const BoxDecoration(
                                                    color: Colors.white,
                                                    borderRadius: BorderRadius.vertical(top: Radius.circular(8.0)),
                                                  ),
                                                  child: CreateAccount(callback: callbackFunction, subUsrAccount: true, customerId: widget.customerID, from: 'Sub User',),
                                                ),
                                              );
                                            },
                                          );*/
                                        },
                                        icon: const Icon(Icons.add))
                                        : null,
                                  ),
                                  Divider(height:0, color: Colors.grey.shade300,),
                                  SizedBox(
                                    height: 70,
                                    child: viewModel.subUsers.isNotEmpty
                                        ? ListView.builder(
                                      scrollDirection: Axis.horizontal,
                                      itemCount: viewModel.subUsers.length,
                                      itemBuilder: (context, index) {
                                        final user = viewModel.subUsers[index];
                                        return SizedBox(
                                          width: 250,
                                          child: Card(
                                            surfaceTintColor: Colors.teal,
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(
                                                  5.0), // Adjust the radius as needed
                                            ),
                                            child: ListTile(
                                              title: Text(user['userName']),
                                              subtitle: Text(
                                                  '+${user['countryCode']} ${user['mobileNumber']}'),
                                              trailing: IconButton(
                                                tooltip: 'User Permission',
                                                onPressed: () => _showAlertDialog(
                                                    context, user['userName'], user['userId']),
                                                icon: const Icon(Icons.menu),
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                    )
                                        : const Center(
                                        child: Text(
                                            'No Sub user available for this controller')),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const Center(child: Text('Tab 2 Content')),
                        Constant(customerId: customerId, controllerId: controllerId, userId: adDrId,),
                        ConditionLibrary(customerId, controllerId, adDrId),
                        const Center(child: Text('Tab 4 Content')),
                        const Center(child: Text('Tab 5 Content')),
                        const Center(child: Text('Tab 6 Content')),
                         DealerDefinitionInConfig(userId: adDrId, customerId: customerId, controllerId: controllerId, imeiNo: viewModel.deviceId),
                        ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget buildLoadingIndicator(bool isVisible, double width) {
    return Visibility(
      visible: isVisible,
      child: Container(
        color: Colors.white,
        padding: EdgeInsets.symmetric(horizontal: width / 2 - 25),
        child: const LoadingIndicator(
          indicatorType: Indicator.ballPulse,
        ),
      ),
    );
  }

  Future<void> _showAlertDialog(BuildContext context, String cName, int suId) async {

    /*List<UserGroup> userGroups = [];

    final response = await HttpService().postRequest("getUserSharedDeviceList",
        {"userId": widget.customerID, "sharedUserId": suId,});
    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      //print(response.body);
      if (data["code"] == 200) {
        var list = data['data'] as List;
        setState(() {
          userGroups = list.map((i) => UserGroup.fromJson(i)).toList();
        });
      }
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('$cName - Permissions'),
          content: SizedBox(
            width: 400,
            height: 400,
            child: Scaffold(
              body: ListView.builder(
                itemCount: userGroups.length,
                itemBuilder: (context, index) {
                  return UserGroupWidget(group: userGroups[index]);
                },
              ),
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Submit'),
              onPressed: () {
                List<MasterItem> masterList = [];
                for(int gix=0; gix<userGroups.length; gix++){
                  for(int mix=0; mix<userGroups[gix].master.length; mix++){
                    masterList.add(MasterItem(id: userGroups[gix].master[mix].controllerId, action: userGroups[gix].master[mix].isSharedDevice, userPermission: userGroups[gix].master[mix].userPermission));
                  }
                }
                sendUpdatedPermission(masterList.map((item) => item.toMap()).toList(), suId);
              },
            ),
          ],
        );
      },
    );*/
  }
}
