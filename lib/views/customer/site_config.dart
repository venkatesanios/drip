import 'package:flutter/material.dart';
import 'package:oro_drip_irrigation/services/mqtt_service.dart';
import 'package:provider/provider.dart';
import '../../Models/customer/site_model.dart';
import '../../modules/config_Maker/view/config_base_page.dart';
import '../../repository/repository.dart';
import '../../services/http_service.dart';
import '../../utils/environment.dart';
import '../../view_models/customer/site_config_view_model.dart';

class SiteConfig extends StatelessWidget {
  final int userId, customerId, groupId;
  final String customerName, groupName;
  final List<Master> masterData;

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
              Container(
                color: Theme.of(context).primaryColorDark.withAlpha((0.1 * 255).toInt()),
                child: ListTile(
                  trailing: SizedBox(
                    width: 155,
                    child: PopupMenuButton(
                      color: Colors.white,
                      tooltip: 'Create new site to $customerName',
                      child: const MaterialButton(
                        onPressed: null,
                        textColor: Colors.white,
                        child: Row(
                          children: [
                            Icon(Icons.add_circle, color: Colors.black),
                            SizedBox(width: 5),
                            Text('Create New site', style: TextStyle(color: Colors.black),),
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
                  ),
                ),
              ),
              const Divider(height: 0),
              Padding(
                padding: const EdgeInsets.only(left: 16, right: 16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      height: MediaQuery.sizeOf(context).height - 160,
                      child: SingleChildScrollView(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                mainAxisSize: MainAxisSize.min, // Prevents infinite height issue
                                children: [
                                  for (int mstIndex = 0; mstIndex < masterData.length; mstIndex++)
                                    Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const SizedBox(height: 8),
                                        SizedBox( // Used instead of Expanded
                                          width: double.infinity,
                                          child: Row(
                                            children: [
                                              Expanded(
                                                flex: 1,
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    const Text('Master Controller',
                                                        style: TextStyle(fontSize: 13, color: Colors.grey, fontWeight: FontWeight.normal)),
                                                    const SizedBox(height: 2),
                                                    Text(masterData[mstIndex].categoryName),
                                                  ],
                                                ),
                                              ),
                                              Expanded(
                                                flex: 1,
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    const Text('Device Id',
                                                        style: TextStyle(fontSize: 13, color: Colors.grey, fontWeight: FontWeight.normal)),
                                                    const SizedBox(height: 2),
                                                    Text(masterData[mstIndex].deviceId),
                                                  ],
                                                ),
                                              ),
                                              Expanded(
                                                flex: 1,
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    const Text('Model',
                                                        style: TextStyle(fontSize: 13, color: Colors.grey, fontWeight: FontWeight.normal)),
                                                    const SizedBox(height: 2),
                                                    Text(masterData[mstIndex].modelName),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const Divider(),
                                        SizedBox(
                                          width: double.infinity,
                                          child: Row(
                                            children: [
                                              const Spacer(),
                                              MaterialButton(
                                                onPressed: () async {},
                                                textColor: Colors.white,
                                                color: Colors.redAccent,
                                                child: const Text('Reset Serial Connection', style: TextStyle(color: Colors.white)),
                                              ),
                                              const SizedBox(width: 8),
                                              MaterialButton(
                                                onPressed: () async {},
                                                textColor: Colors.white,
                                                color: Colors.redAccent,
                                                child: const Text('Delete', style: TextStyle(color: Colors.white)),
                                              ),
                                              const SizedBox(width: 8),
                                              MaterialButton(
                                                onPressed: () async {
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
                                                        "modelName": masterData[mstIndex].modelName,
                                                        "groupId": groupId,
                                                        "groupName": groupName,
                                                        //"inputObjectId": masterData[mstIndex].inputObjectId,
                                                        //"outputObjectId": masterData[mstIndex].outputObjectId,
                                                      },
                                                    );
                                                  }));
                                                },
                                                textColor: Colors.white,
                                                color: Colors.teal,
                                                child: const Text('Site Config', style: TextStyle(color: Colors.white)),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                ],
                              ),
                            ),
                            SizedBox(
                              width: 170,
                              height: 40,
                              child: PopupMenuButton(
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
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
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
