import 'package:flutter/material.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:oro_drip_irrigation/utils/constants.dart';
import 'package:provider/provider.dart';

import '../../../../Screens/Dealer/controllerverssionupdate.dart';
import '../../../../providers/user_provider.dart';
import '../../../../repository/repository.dart';
import '../../../../services/http_service.dart';
import '../../../../utils/validators.dart';
import '../../../../view_models/customer/general_setting_view_model.dart';

class GeneralSettingsNarrow extends StatefulWidget {
  const GeneralSettingsNarrow({super.key, required this.controllerId, required this.customerId,
    required this.userId, required this.isSubUser});
  final int customerId, controllerId, userId;
  final bool isSubUser;

  @override
  State<GeneralSettingsNarrow> createState() => _GeneralSettingsNarrowState();
}

class _GeneralSettingsNarrowState extends State<GeneralSettingsNarrow> {
  @override
  Widget build(BuildContext context) {

    final loggedInUser = Provider.of<UserProvider>(context).loggedInUser;


    return ChangeNotifierProvider(
      create: (_) => GeneralSettingViewModel(Repository(HttpService()))
        ..initIds(customerId: widget.customerId, controllerId: widget.controllerId, userId: widget.userId, isSubUser: widget.isSubUser)
        ..getControllerInfo()
        ..getSubUserList()
        ..getLanguage(),
      child: Consumer<GeneralSettingViewModel>(
        builder: (context, viewModel, _) {

          final bool isEcoMdl = [...AppConstants.ecoGemModelList, ...AppConstants.pumpList].contains(viewModel.modelId);

          return Scaffold(
            appBar: AppBar(
              title: const Text('General'),
              actions: [
                IconButton(onPressed: () async {
                  final isAuthenticated = await Validators().verifyPassword(context);
                   if (isAuthenticated) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ResetVerssion(
                          userId: widget.customerId,
                          controllerId: widget.controllerId,
                          deviceID: viewModel.deviceId,
                        ),
                      ),
                    );
                  }
                }, icon: const Icon(Icons.update)),
              ],
            ),
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            body: viewModel.isLoading?
            buildLoadingIndicator(true, MediaQuery.sizeOf(context).width):
            ListView(
              padding: const EdgeInsets.only(left: 12, right: 10),
              children: [
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8.0),
                  child: Text('General Settings',
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
                      children: List.generate(5, (index) => getSettingTile(
                        context, viewModel, index, widget.customerId, widget.controllerId, loggedInUser.id)),
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
                      children: List.generate(isEcoMdl? 7 : 6, (index) => getSettingTile(context,
                          viewModel, isEcoMdl? index + 5 : index + 6, widget.customerId, widget.controllerId, loggedInUser.id)),
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
      child: Center(
        child: Container(
          color: Colors.transparent,
          padding: EdgeInsets.symmetric(horizontal: width / 2 - 25),
          child: const LoadingIndicator(
            indicatorType: Indicator.ballPulse,
          ),
        ),
      ),
    );
  }

  Widget getSettingTile(BuildContext context,
      GeneralSettingViewModel viewModel, int index, int customerId, int controllerId, int userId) {

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
                viewModel.updateMasterDetails(context);
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
                viewModel.updateMasterDetails(context);
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
          subtitle: Text(viewModel.categoryName, style: const TextStyle(fontWeight: FontWeight.bold)),
          leading: const Icon(Icons.category),
        );
      case 3:
        return ListTile(
          visualDensity: const VisualDensity(vertical: -4),
          isThreeLine: true,
          title: const Text('Device Model'),
          subtitle: Text(viewModel.modelName, style: const TextStyle(fontWeight: FontWeight.bold)),
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
          title: const Text('Sim card number'),
          leading: const Icon(Icons.sim_card_outlined),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('${viewModel.countryCode} - ${viewModel.simNumber}',
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(width: 16),
              IconButton(
                onPressed: () {
                  showSimEditControllerDialog(context, 'SIM card Number',
                      viewModel.countryCode ?? '91',viewModel.simNumber ?? '0', (cCode, sNumber) {
                        viewModel.countryCode = cCode;
                        viewModel.simNumber = sNumber;
                        viewModel.updateMasterDetails(context);
                      });
                },
                icon: const Icon(Icons.edit),
              ),
            ],
          ),
        );
      case 6:
        return ListTile(
          visualDensity: const VisualDensity(vertical: -4),
          isThreeLine: true,
          title: const Text('Controller Version'),
          subtitle: Text(viewModel.controllerVersion, style: const TextStyle(fontWeight: FontWeight.bold)),
          leading: const Icon(Icons.developer_board),
          trailing: IconButton(onPressed: () {}, icon: const Icon(Icons.update)),
        );
      case 7:
        return ListTile(
          visualDensity: const VisualDensity(vertical: -4),
          isThreeLine: true,
          leading: const Icon(Icons.timer_outlined),
          title: const Text('UTC'),
          subtitle: const Text('Time zone'),
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
      case 8:
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
      case 9:
        return ListTile(
          title: const Text('Location'),
          subtitle: const Text('Controller location'),
          leading: const Icon(Icons.location_on_outlined),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(viewModel.controllerLocation, style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(width: 16),
              IconButton(
                onPressed: () {
                  showEditControllerDialog(context, 'Location', viewModel.controllerLocation, (newName) {
                    viewModel.updateMasterDetails(context);
                  });
                },
                icon: const Icon(Icons.edit),
              ),
            ],
          ),
        );
      case 10:
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
      case 11:
        return const ListTile(
          title: Text('Time Format'),
          leading: Icon(Icons.av_timer),
          trailing: Text(
            '24 Hrs',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
        );
      case 12:
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

  void showSimEditControllerDialog(BuildContext context, String currentTitle,
      String cCode, String simNo, Function(String, String) onSave) {

    final TextEditingController cCodeController = TextEditingController(text: cCode);
    final TextEditingController mobileNoController = TextEditingController(text: simNo);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: Text('Edit $currentTitle'),
          content: IntlPhoneField(
            decoration: InputDecoration(
              hintText: 'Enter SIM number',
              border: const OutlineInputBorder(),
              suffixIcon: IconButton(
                icon: const Icon(Icons.clear, color: Colors.red),
                onPressed: () => mobileNoController.clear(),
              ),
              icon: const Icon(Icons.phone_outlined, color: Colors.black),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 12),
              counterText: '',
            ),
            languageCode: "en",
            initialCountryCode: 'IN',
            controller: mobileNoController,
            onChanged: (phone) {},
            onCountryChanged: (country) {
              cCodeController.text = country.dialCode;
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel', style: TextStyle(color: Colors.red)),
            ),
            TextButton(
              onPressed: () {
                onSave(cCodeController.text, mobileNoController.text.trim());
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