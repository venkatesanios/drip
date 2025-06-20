import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:oro_drip_irrigation/modules/IrrigationProgram/view/selection_screen.dart';
import 'package:provider/provider.dart';
import '../../models/admin_dealer/new_stock_model.dart';
import '../../models/admin_dealer/simple_category.dart';
import '../../repository/repository.dart';
import '../../services/http_service.dart';
import '../../utils/snack_bar.dart';
import '../../view_models/admin_dealer/new_stock_view_model.dart';

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
          return Padding(
            padding: const EdgeInsets.only(left: 20, top: 10),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Stock Entry Form", style: TextStyle(fontSize: 16)),
                const Divider(),
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Category Name', style: TextStyle(fontSize: 14, color: Colors.black45)),
                    const SizedBox(height: 5),
                    SizedBox(
                      width: 415,
                      height: 50,
                      child: DropdownButtonFormField<SimpleCategory>(
                        value: viewModel.selectedCategory,
                        hint: const Text("Select a category",),
                        decoration: const InputDecoration(
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.black26, width: 1.5),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.black38, width: 1.5),
                          ),
                          filled: true,
                          fillColor: Colors.white,
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
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    DropdownMenu<ProductModel>(
                      controller: viewModel.modelTextController,
                      width: 205,
                      label: const Text('Model'),
                      dropdownMenuEntries: viewModel.modelEntries,
                      inputDecorationTheme: const InputDecorationTheme(
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
                        border: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.black26, width: 1)
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.black26, width: 1.5),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.black38, width: 1.5),
                        ),
                      ),
                      onSelected: (ProductModel? mdl) {
                        viewModel.selectedModelId = mdl!.modelId;
                        viewModel.modelTextController.clear();
                        viewModel.modelTextController.text = mdl.modelName;
                      },
                    ),
                    const SizedBox(width: 10),
                    SizedBox(
                      width: 200,
                      child: TextFormField(
                        maxLength: 12,
                        controller: viewModel.imeiController,
                        decoration: const InputDecoration(
                          counterText: '',
                          labelText: 'Device ID',
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
                          border: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.black26, width: 1)
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.black26, width: 1.5),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.black38, width: 1.5),
                          ),
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
                const SizedBox(height: 16),
                Row(
                  children: [
                    SizedBox(
                      width: 205,
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
                        decoration: const InputDecoration(
                          counterText: '',
                          filled: true,
                          fillColor: Colors.white,
                          labelText: 'warranty months',
                          contentPadding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
                          border: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.black26, width: 1)
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.black26, width: 1.5),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.black38, width: 1.5),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    SizedBox(
                      width: 200,
                      child: TextFormField(
                        validator: (value){
                          if(value==null || value.isEmpty){
                            return 'Please fill out this field';
                          }
                          return null;
                        },
                        controller: viewModel.manufacturingDateController,
                        decoration: const InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          labelText: 'Date',
                          contentPadding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
                          border: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.black26, width: 1)
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.black26, width: 1.5),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.black38, width: 1.5),
                          ),
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
                  ],
                ),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.only(left: 25),
                  child: SizedBox(
                    width: 350,
                    child: TextButton(
                      onPressed: ()  => viewModel.saveStockListToLocal(),
                      style: TextButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Icon(Icons.add),
                          SizedBox(width: 8),
                          Text('ADD STOCK'),
                        ],
                      ),
                    ),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.only(left: 8.0, right: 8.0, top: 5.0),
                  child: Row(
                    children: [
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
                const SizedBox(height: 10),
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
            ),
          );
        },
      ),
    );
  }
}
