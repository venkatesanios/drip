import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:provider/provider.dart';
import '../../repository/repository.dart';
import '../../services/http_service.dart';
import '../../view_models/customer/general_setting_view_model.dart';


class GeneralSetting extends StatefulWidget {
  const GeneralSetting({super.key, required this.customerId, required this.controllerId, required this.userId});
  final int customerId, controllerId, userId;

  @override
  State<GeneralSetting> createState() => _GeneralSettingState();
}

class _GeneralSettingState extends State<GeneralSetting> {
  @override
  Widget build(BuildContext context) {

    return ChangeNotifierProvider(
      create: (_) => GeneralSettingViewModel(Repository(HttpService()))
        ..getControllerInfo(widget.customerId, widget.controllerId)
        ..getSubUserList(widget.customerId)
        ..getNotificationList(widget.customerId, widget.controllerId)
        ..getLanguage(),
      child: Consumer<GeneralSettingViewModel>(
        builder: (context, viewModel, _) {
          return Scaffold(
            appBar: !kIsWeb ? AppBar(title: const Text('General')): null,
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            body: viewModel.isLoading?
            buildLoadingIndicator(true, MediaQuery.sizeOf(context).width):
            kIsWeb ? generalSetting(context, viewModel):
            ListView(
              padding: const EdgeInsets.only(left: 12, right: 10),
              children: [
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8.0),
                  child: Text(
                    'General Settings',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(5),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 6,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.only(top: 5, bottom: 5),
                    child: Column(
                      children: List.generate(5, (index) => getSettingTile(context, index)),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8.0),
                  child: Text(
                    'Controller Settings',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(5),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 6,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.only(top: 5, bottom: 5),
                    child: Column(
                      children: List.generate(6, (index) => getSettingTile(context, index + 5)),
                    ),
                  ),
                ),
              ],
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

  Widget getSettingTile(BuildContext context, int index) {
    final viewModel = Provider.of<GeneralSettingViewModel>(context);

    switch (index) {
      case 0:
        return ListTile(
          visualDensity: const VisualDensity(vertical: -4),
          isThreeLine: true,
          title: const Text('Farm Name', style: TextStyle(fontWeight: FontWeight.bold)),
          subtitle: Text(viewModel.farmName),
          leading: const Icon(Icons.label_outline),
          trailing: IconButton(
            onPressed: () {
              showEditControllerDialog(context, 'Farm Name', viewModel.farmName, (newName) {
                print('Updated name: $newName');
              });
            },
            icon: const Icon(Icons.edit),
          ),
        );
      case 1:
        return ListTile(
          visualDensity: const VisualDensity(vertical: -4),
          isThreeLine: true,
          title: const Text('Controller Name'),
          subtitle: Text(viewModel.controllerCategory, style: const TextStyle(fontWeight: FontWeight.bold)),
          leading: const Icon(Icons.developer_board),
          trailing: IconButton(
            onPressed: () {
              showEditControllerDialog(context, 'Controller Name', viewModel.farmName, (newName) {
                print('Updated name: $newName');
              });
            },
            icon: const Icon(Icons.edit),
          ),
        );
      case 2:
        return ListTile(
          visualDensity: const VisualDensity(vertical: -4),
          isThreeLine: true,
          title: const Text('Device Category'),
          subtitle: Text(viewModel.categoryName, style: TextStyle(fontWeight: FontWeight.bold)),
          leading: const Icon(Icons.category),
        );
      case 3:
        return ListTile(
          visualDensity: const VisualDensity(vertical: -4),
          isThreeLine: true,
          title: const Text('Device Model'),
          subtitle: Text(viewModel.modelName, style: TextStyle(fontWeight: FontWeight.bold)),
          leading: const Icon(Icons.model_training),
        );
      case 4:
        return ListTile(
          visualDensity: const VisualDensity(vertical: -4),
          isThreeLine: true,
          title: const Text('Device ID'),
          subtitle: SelectableText(
            viewModel.deviceId,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          leading: const Icon(Icons.numbers_outlined),
        );
      case 5:
        return ListTile(
          visualDensity: const VisualDensity(vertical: -4),
          isThreeLine: true,
          title: const Text('Controller Version'),
          subtitle: Text(viewModel.controllerVersion, style: const TextStyle(fontWeight: FontWeight.bold)),
          leading: const Icon(Icons.developer_board),
          trailing: IconButton(onPressed: () {}, icon: const Icon(Icons.update)),
        );
      case 6:
        return ListTile(
          visualDensity: const VisualDensity(vertical: -4),
          isThreeLine: true,
          leading: const Icon(Icons.timer_outlined),
          title: const Text('UTC'),
          subtitle: const Text('Time zone setting'),
          trailing: SizedBox(
            width: 175,
            child: DropdownButton<String>(
              hint: const Text('Select Time Zone'),
              value: viewModel.selectedTimeZone,
              onChanged: (String? newValue) {
                if (newValue != null) {
                  viewModel.updateCurrentDateTime(newValue);
                }
              },
              items: viewModel.timeZones
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
          ),
        );
      case 7:
        return ListTile(
          visualDensity: const VisualDensity(vertical: -4),
          isThreeLine: true,
          leading: const Icon(Icons.date_range),
          title: const Text('Current Date'),
          subtitle: const Text('Date from controller'),
          trailing: Text(
            viewModel.currentDate,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
        );
      case 8:
        return ListTile(
          visualDensity: const VisualDensity(vertical: -4),
          isThreeLine: true,
          leading: const Icon(Icons.access_time),
          title: const Text('Current UTC Time'),
          subtitle: const Text('Time from controller'),
          trailing: Text(
            viewModel.currentTime,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
        );
      case 9:
        return const ListTile(
          title: Text('Time Format'),
          leading: Icon(Icons.av_timer),
          trailing: Text(
            '24 Hrs',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
        );
      case 10:
        return const ListTile(
          title: Text('Unit'),
          leading: Icon(Icons.ac_unit_rounded),
          trailing: Text(
            'm3',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
        );
      default:
        return const SizedBox();
    }
  }

  Widget generalSetting(BuildContext context, GeneralSettingViewModel viewModel){

    return Padding(
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
                          /*ListTile(
                            title: const Text('Communication mode'),
                            leading: const Icon(Icons.network_ping),
                            trailing: viewModel.selectedMode=='Http & Mqtt'?
                            DropdownButton<String>(
                              value: viewModel.selectedMode,
                              hint: const Text('select a communication mode'),
                              items: viewModel.communicationMode.map((String value) {
                                return DropdownMenuItem(
                                  value: value,
                                  child: Text(value),
                                );
                              }).toList(),
                              onChanged: (value) => viewModel.onChangeCommunicationMode(value!),
                            ):
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                DropdownButton<String>(
                                  value: viewModel.selectedMode,
                                  hint: const Text('select a communication mode'),
                                  items: viewModel.communicationMode.map((String value) {
                                    return DropdownMenuItem(
                                      value: value,
                                      child: Text(value),
                                    );
                                  }).toList(),
                                  onChanged: (value) => viewModel.onChangeCommunicationMode(value!),
                                ),
                                IconButton(onPressed:(){
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        title: ListTile(title: const Text('Search bluetooth devices'),
                                            trailing: IconButton(
                                          icon: const Icon(Icons.search, color: Colors.white),
                                          onPressed: null,
                                        )),
                                        content: SizedBox(
                                          width: 400,
                                          child: Column(
                                            children: [
                                              *//*...devices.map((d) => ListTile(
                                                title: Text(d.device.name ?? '----'),
                                                subtitle: Text(d.device.address),
                                                trailing: TextButton(
                                                  onPressed: () {},
                                                  child: Text(d.isConnected ? 'Connected' : 'Connect'),
                                                ),
                                              )),*//*
                                            ],
                                          ),
                                        ),
                                        actions: [
                                          TextButton(
                                            child: const Text('Close'),
                                            onPressed: () => Navigator.of(context).pop(),
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                }, icon: Icon(Icons.list))
                              ],
                            ),
                          ),*/
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
                            leading: const Icon(Icons.date_range),
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
                trailing: widget.userId != 0
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
                ) : const Center(
                    child: Text(
                        'No Sub user available for this controller')),
              ),
            ],
          ),
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

  void showEditControllerDialog(BuildContext context, String currentTitle, String currentName, Function(String) onSave) {
    final TextEditingController nameController = TextEditingController(text: currentName);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Edit $currentTitle'),
          content: TextField(
            controller: nameController,
            decoration: InputDecoration(
              labelText: currentTitle,
              border: const OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel', style: TextStyle(color: Colors.red)),
            ),
            TextButton(
              onPressed: () {
                onSave(nameController.text.trim());
                Navigator.of(context).pop();
              },
              child: const Text('Save', style: TextStyle(color: Colors.green)),
            ),
          ],
        );
      },
    );
  }
}
