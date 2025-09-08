import 'package:flutter/material.dart';
import 'package:oro_drip_irrigation/services/mqtt_service.dart';
import 'package:provider/provider.dart';
import '../../models/customer/site_model.dart';
import '../../modules/config_Maker/view/config_base_page.dart';
import '../../repository/repository.dart';
import '../../services/http_service.dart';
import '../../utils/environment.dart';
import '../../view_models/customer/site_config_view_model.dart';

class SiteConfig extends StatelessWidget {
  final int userId, customerId, groupId;
  final String customerName, groupName;
  final List<MasterControllerModel> masterData;

  const SiteConfig({super.key,
    required this.userId,
    required this.customerId,
    required this.customerName,
    required this.masterData,
    required this.groupId,
    required this.groupName});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => SiteConfigViewModel(Repository(HttpService()))
        ..getMasterProduct(customerId),
      child: Consumer<SiteConfigViewModel>(
        builder: (context, viewModel, _) {
          return Column(
            children: [
              ListTile(
                leading: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    PopupMenuButton(
                      color: Colors.white,
                      tooltip: 'Add new site to $customerName',
                      child: const MaterialButton(
                        onPressed: null,
                        textColor: Colors.white,
                        color: Colors.green,
                        child: Row(
                          children: [
                            Icon(Icons.add_circle, color: Colors.black),
                            SizedBox(width: 5),
                            Text('ADD NEW FARM', style: TextStyle(color: Colors.black),),
                          ],
                        ),
                      ),
                      itemBuilder: (context) {
                        return List.generate(viewModel.myMasterControllerList.length+1 ,(index) {
                          if(viewModel.myMasterControllerList.isEmpty){
                            return const PopupMenuItem(
                              child: Text('No master available to create site'),
                            );
                          }
                          else if(viewModel.myMasterControllerList.length == index){
                            return PopupMenuItem(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                children: [
                                  MaterialButton(
                                    color: Colors.red,
                                    textColor: Colors.white,
                                    child: const Text('CANCEL'),
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                  ),
                                  MaterialButton(
                                    color: Colors.green,
                                    textColor: Colors.white,
                                    child: const Text('CREATE'),
                                    onPressed: () async {
                                      Navigator.pop(context);
                                      await showDialog<void>(
                                          context: context,
                                          builder: (context) => AlertDialog(actions: [
                                            TextButton(
                                              onPressed: () {
                                                Navigator.of(context).pop(); // Close the dialog
                                              },
                                              child: const Text('Cancel'),
                                            ),
                                            ElevatedButton(
                                              onPressed: () => viewModel.createNewSite(context, customerId),
                                              child: const Text('Create Site'),
                                            ),
                                          ],
                                            content: showForm(viewModel,
                                                viewModel.myMasterControllerList[viewModel.selectedRadioTile].categoryName,
                                                viewModel.myMasterControllerList[viewModel.selectedRadioTile].model,
                                                viewModel.myMasterControllerList[viewModel.selectedRadioTile].imeiNo.toString()),
                                            title: Text('Create new site to $customerName'),
                                          ));
                                    },
                                  ),
                                ],
                              ),
                            );
                          }

                          return PopupMenuItem(
                            value: index,
                            child: AnimatedBuilder(
                                animation: viewModel.selectedItem,
                                builder: (context, child) {
                                  return RadioListTile(
                                    value: MasterController.values[index],
                                    groupValue: viewModel.selectedItem.value,
                                    title: child,  onChanged: (value) {
                                    viewModel.selectedItem.value = value!;
                                    viewModel.selectedRadioTile = value.index;
                                  },
                                    subtitle: Text(viewModel.myMasterControllerList[index].imeiNo),
                                  );
                                },
                                child: Text(viewModel.myMasterControllerList[index].categoryName)

                            ),
                          );
                        },);
                      },
                    ),
                  ],
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    PopupMenuButton(
                      elevation: 10,
                      tooltip: 'Add New Master Controller',
                      child: const MaterialButton(
                        onPressed: null,
                        child: Row(
                          children: [
                            Icon(Icons.add_circle, color: Colors.black),
                            SizedBox(width: 3),
                            Text(
                              'Add New Master',
                              style: TextStyle(color: Colors.black),
                            ),
                          ],
                        ),
                      ),
                      onCanceled: () {},
                      itemBuilder: (context) {
                        if (viewModel.myMasterControllerList.isEmpty) {
                          return [
                            const PopupMenuItem(
                              child: Text('No master controller available'),
                            ),
                          ];
                        }

                        return List.generate(viewModel.myMasterControllerList.length, (index) {
                          return PopupMenuItem(
                            value: index,
                            child: Column(
                              children: [
                                RadioListTile<int>(
                                  value: index,
                                  groupValue: viewModel.selectedRadioTile,
                                  title: Text(viewModel.myMasterControllerList[index].categoryName),
                                  subtitle: Text(viewModel.myMasterControllerList[index].imeiNo),
                                  onChanged: (value) {
                                    viewModel.selectedRadioTile = value!;
                                  },
                                ),
                                if (index == viewModel.myMasterControllerList.length - 1) ...[
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                                    children: [
                                      MaterialButton(
                                        color: Colors.red,
                                        textColor: Colors.white,
                                        child: const Text('CANCEL'),
                                        onPressed: () {
                                          Navigator.pop(context);
                                        },
                                      ),
                                      MaterialButton(
                                        color: Colors.teal,
                                        textColor: Colors.white,
                                        child: const Text('ADD'),
                                        onPressed: () async {
                                          Navigator.pop(context);
                                        },
                                      ),
                                    ],
                                  ),
                                ],
                              ],
                            ),
                          );
                        });
                      },
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 16, right: 16),
                child: Column(
                  children: masterData.asMap().entries.map((entry) {

                    final mstIndex = entry.key;
                    final master = entry.value;

                    return Container(
                      width: MediaQuery.sizeOf(context).width,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: Colors.black26,
                          width: 0.5,
                        ),
                      ),
                      child: ListTile(
                        title: Text(master.categoryName),
                        subtitle: Text(master.deviceId),
                        trailing: TextButton.icon(
                          onPressed: () {
                            MqttService().topicToSubscribe('${Environment.mqttSubscribeTopic}/${masterData[mstIndex].controllerId}');
                            print('controllerId ==> ${masterData[mstIndex].controllerId}');
                            Navigator.push(context, MaterialPageRoute(builder: (context) {
                              return ConfigBasePage(

                                masterData: {
                                  "userId": userId,
                                  "customerId": customerId,
                                  "controllerId": masterData[mstIndex].controllerId,
                                  "deviceId": masterData[mstIndex].deviceId,
                                  "deviceName": masterData[mstIndex].deviceName,
                                  "categoryId": masterData[mstIndex].categoryId,
                                  "categoryName": masterData[mstIndex].categoryName,
                                  "modelId": masterData[mstIndex].modelId,
                                  "modelDescription": masterData[mstIndex].modelDescription,
                                  "modelName": masterData[mstIndex].modelName,
                                  "groupId": groupId,
                                  "groupName": groupName,
                                  "connectingObjectId": [
                                    //masterData[mstIndex].outputObjectId.split(','),
                                    //...masterData[mstIndex].outputObjectId.split(','),
                                    //...masterData[mstIndex].inputObjectId.split(','),
                                  ],
                                  //"productStock": productStock.map((e) => e.toJson()).toList(),
                                },
                              );
                            }));
                          },
                          icon: const Icon(Icons.library_books_rounded, color: Colors.white),
                          label: const Text('Configuration', style: TextStyle(color: Colors.white)),
                          style: TextButton.styleFrom(
                            backgroundColor: Colors.blue,
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget showForm(SiteConfigViewModel viewModel, ctrlName, ctrlModel, ctrlIMEI)
  {
    return Form(
      key: viewModel.formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          ListTile(
            title: Text(ctrlName),
            subtitle: Text('$ctrlModel - $ctrlIMEI'),
          ),
          const SizedBox(height: 10,),
          TextFormField(
            controller: viewModel.siteNameController,
            validator: (value){
              if(value==null ||value.isEmpty){
                return 'Please fill out this field';
              }
              return null;
            },
            decoration: const InputDecoration(
              contentPadding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
              border: OutlineInputBorder(),
              labelText: 'Site Name',
            ),
          ),
          const SizedBox(height: 10,),
          TextFormField(
            controller: viewModel.siteAddressController,
            validator: (value){
              if(value==null ||value.isEmpty){
                return 'Please fill out this field';
              }
              return null;
            },
            decoration: const InputDecoration(
              contentPadding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
              border: OutlineInputBorder(),
              labelText: 'Site Address',
            ),
          ),
        ],
      ),
    );
  }

}
