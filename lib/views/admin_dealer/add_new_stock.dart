import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:oro_drip_irrigation/modules/IrrigationProgram/view/selection_screen.dart';
import 'package:oro_drip_irrigation/utils/Theme/smart_comm_theme.dart';
import 'package:provider/provider.dart';

import '../../models/admin&dealer/new_stock_model.dart';
import '../../models/admin&dealer/simple_category.dart';
import '../../repository/repository.dart';
import '../../services/http_service.dart';
import '../../utils/snack_bar.dart';
import '../../view_models/admin&dealer/new_stock_view_model.dart';

class AddNewStock extends StatelessWidget {
  const AddNewStock({super.key, required this.userId, required this.onStockCreated});
  final int userId;
  final Function(Map<String, dynamic>) onStockCreated;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => NewStockViewModel(Repository(HttpService()), onStockCreatedCallbackFunction:(result) {
        onStockCreated(result);
        Navigator.pop(context);
        GlobalSnackBar.show(context, 'Stock Added successfully', 200);
      })..fetchCategoryList(),
      child: Consumer<NewStockViewModel>(
        builder: (context, viewModel, _) {
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 8.0, right: 8.0, bottom: 5.0),
                child: Row(
                  children: [
                    SizedBox(
                      width:200,
                      height: 50,
                      child: DropdownButtonFormField<SimpleCategory>(
                        value: viewModel.selectedCategory,
                        hint: const Text("Select a category",),
                        decoration: InputDecoration(
                          contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5.0),
                            borderSide: const BorderSide(color: Colors.grey, width: 1.0),
                          ),
                          filled: true,
                          fillColor: primaryColorLight,
                        ),
                        items: viewModel.categoryList.map((category) {
                          return DropdownMenuItem<SimpleCategory>(
                            value: category,
                            child: Text(
                              category.name,
                            ),
                          );
                        }).toList(),
                        onChanged: (SimpleCategory? newValue) {
                          viewModel.selectedCategoryId = newValue!.id;
                          viewModel.modelTextController.clear();
                          viewModel.selectedModelId = 0;
                          viewModel.getModelsByCategoryId();
                          viewModel.selectedCategory = newValue;
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    DropdownMenu<ProductModel>(
                      controller: viewModel.modelTextController,
                      width: 205,
                      label: const Text('Model'),
                      dropdownMenuEntries: viewModel.modelEntries,
                      inputDecorationTheme: InputDecorationTheme(
                        filled: true,
                        contentPadding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
                        border: const OutlineInputBorder(),
                        fillColor: primaryColorLight,
                      ),
                      onSelected: (ProductModel? mdl) {
                        viewModel.selectedModelId = mdl!.modelId;
                        viewModel.modelTextController.clear();
                        viewModel.modelTextController.text = mdl.modelName;
                      },
                    ),
                    const SizedBox(width: 8),
                    SizedBox(
                      width: 200,
                      child: TextFormField(
                        maxLength: 12,
                        controller: viewModel.imeiController,
                        decoration: InputDecoration(
                          counterText: '',
                          labelText: 'Device ID',
                          border: const OutlineInputBorder(),
                          filled: true,
                          fillColor: primaryColorLight,
                          contentPadding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please fill out this field';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 8.0, right: 8.0, top: 5.0),
                child: Row(
                  children: [
                    SizedBox(
                      width: 175,
                      child: TextFormField(
                        controller: viewModel.warrantyMonthsController,
                        validator: (value){
                          if(value==null || value.isEmpty){
                            return 'Please fill out this field';
                          }
                          return null;
                        },
                        maxLength: 2,
                        inputFormatters: <TextInputFormatter>[
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        decoration: InputDecoration(
                          counterText: '',
                          filled: true,
                          fillColor: primaryColorLight,
                          labelText: 'warranty months',
                          border: const OutlineInputBorder(),
                          contentPadding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    SizedBox(
                      width: 125,
                      child: TextFormField(
                        validator: (value){
                          if(value==null || value.isEmpty){
                            return 'Please fill out this field';
                          }
                          return null;
                        },
                        controller: viewModel.manufacturingDateController,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: primaryColorLight,
                          labelText: 'Date',
                          border: const OutlineInputBorder(),
                          contentPadding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
                        ),
                        onTap: ()
                        async {
                          DateTime? date = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime(1900),
                            lastDate: DateTime(2100),
                          );

                          if (date != null) {
                            viewModel.manufacturingDateController.text = DateFormat('dd-MM-yyyy').format(date);
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 20),
                    SizedBox(
                      width: 100,
                      child: MaterialButton(
                        color: Theme.of(context).primaryColor,
                        textColor: Colors.white,
                        height: 55,
                        child: const Row(
                          children: [
                            Icon(Icons.add),
                            SizedBox(width: 8,),
                            Text('ADD'),
                          ],
                        ),
                        onPressed: () => viewModel.saveStockListToLocal(),
                      ),
                    ),
                    const SizedBox(width: 25),
                    SizedBox(
                      width: 170,
                      child: MaterialButton(
                        color: Colors.green,
                        textColor: Colors.white,
                        height: 55,
                        child: const Row(
                          children: [
                            Icon(Icons.save_as_outlined),
                            SizedBox(width: 8,),
                            Text('SAVE TO STOCK'),
                          ],
                        ),
                        onPressed: () async {
                          if(viewModel.addedProductList.isNotEmpty)
                          {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: const Text('Confirmation'),
                                  content: const Text('Are you sure! You want to save the product to Stock list?'),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                      child: const Text('Cancel'),
                                    ),
                                    TextButton(
                                      onPressed: () => viewModel.addProductStock(userId, context),
                                      child: const Text('Save'),
                                    ),
                                  ],
                                );
                              },
                            );
                          }else{
                            //_showAlertDialog('Alert Message', 'Product Empty!');
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 6,),
              viewModel.errorMsg!=''? SizedBox(
                width: 620,
                  child: Text(viewModel.errorMsg, style: const TextStyle(color: Colors.red),)
              ): const SizedBox(),
              const SizedBox(height: 10,),
              Expanded(
                child: DataTable2(
                  columnSpacing: 12,
                  horizontalMargin: 12,
                  minWidth: 600,
                  dataRowHeight: 35.0,
                  headingRowHeight: 25.0,
                  headingRowColor: WidgetStateProperty.all<Color>(Theme.of(context).primaryColorLight.withValues(alpha: 0.3)),
                  columns: const [
                    DataColumn2(
                        label: Center(child: Text('S.No')),
                        fixedWidth: 32
                    ),
                    DataColumn2(
                        label: Text('Category'),
                        size: ColumnSize.M
                    ),
                    DataColumn2(
                        label: Text('Model Name'),
                        size: ColumnSize.M
                    ),
                    DataColumn2(
                      label: Text('Device Id'),
                      fixedWidth: 150,
                    ),
                    DataColumn2(
                      label: Center(child: Text('M.Date')),
                      fixedWidth: 75,
                    ),
                    DataColumn2(
                      label: Center(child: Text('Warranty')),
                      fixedWidth: 70,
                    ),
                    DataColumn2(
                      label: Center(child: Text('Action')),
                      fixedWidth: 45,
                    ),
                  ],
                  rows: List<DataRow>.generate(viewModel.addedProductList.length, (index) => DataRow(cells: [
                    DataCell(Center(child: Text('${index + 1}',style: const TextStyle(fontSize: 10)))),
                    DataCell(Text(viewModel.addedProductList[index]['categoryName'],style: const TextStyle(fontSize: 10))),
                    DataCell(Text(viewModel.addedProductList[index]['modelName'],style: const TextStyle(fontSize: 10))),
                    DataCell(Text('${viewModel.addedProductList[index]['deviceId']}',style: const TextStyle(fontSize: 10))),
                    DataCell(Center(child: Text(viewModel.addedProductList[index]['dateOfManufacturing'],style: const TextStyle(fontSize: 10)))),
                    DataCell(Center(child: Text('${viewModel.addedProductList[index]['warrantyMonths']}',style: const TextStyle(fontSize: 10)))),
                    DataCell(Center(child: IconButton(
                      tooltip: 'Remove',
                      icon: const Icon(Icons.remove_circle, color: Colors.red,), // Specify the icon
                      onPressed: () => viewModel.removeNewStock(index),
                    ),)),
                  ])),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
