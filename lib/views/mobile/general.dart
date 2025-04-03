import 'package:flutter/material.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:provider/provider.dart';

import '../../repository/repository.dart';
import '../../services/http_service.dart';
import '../../view_models/customer/controller_settings_view_model.dart';

class General extends StatelessWidget {
  const General({super.key, required this.customerId, required this.controllerId, required this.adDrId, required this.userId});
  final int customerId, controllerId, adDrId, userId;

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
          return Scaffold(
            appBar: AppBar(title: const Text('General')),
            backgroundColor: Colors.white,
            body: viewModel.isLoading? buildLoadingIndicator(true, MediaQuery.sizeOf(context).width):
            ListView.builder(
              itemCount: 12,
              itemBuilder: (context, index) {
                return Column(
                  children: [
                    if(index==0)
                      ListTile(
                        title: const Text('Farm Name'),
                        subtitle: SizedBox(
                          width: 300,
                          child: TextField(
                            controller: viewModel.txtEcSiteName,
                            decoration: const InputDecoration(
                              filled: false,
                              suffixIcon: Icon(Icons.edit),
                            ),
                          ),
                        ),
                        leading: const Icon(Icons.area_chart_outlined),
                      ),
                    if(index==1)
                      ListTile(
                        title: const Text('Controller Name'),
                        subtitle: TextField(
                          controller: viewModel.txtEcGroupName,
                          decoration: const InputDecoration(
                            filled: false,
                            suffixIcon: Icon(Icons.edit),
                          ),
                        ),
                        leading: const Icon(Icons.developer_board),
                      ),
                    if(index==2)
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
                    if(index==3)
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
                    if(index==4)
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
                    if(index==5)
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
                    if(index==6)
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
                    if(index==7)
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
                    if(index==8)
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
                    if(index==9)
                      ListTile(
                        title: const Text('Current UTC Time'),
                        leading: const Icon(Icons.access_time),
                        trailing: Text(
                          viewModel.currentTime,
                          style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    if(index==10)
                      const ListTile(
                        title: Text('Time Format'),
                        leading: Icon(Icons.av_timer),
                        trailing: Text(
                          '24 Hrs',
                          style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    if(index==11)
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
                  ],
                );
              },
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

}
