import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:provider/provider.dart';

import '../../Models/customer/constant_model.dart';
import '../../repository/repository.dart';
import '../../services/http_service.dart';
import '../../view_models/customer/constant_view_model.dart';

class Constant extends StatelessWidget {
  const Constant(
      {super.key,
      required this.customerId,
      required this.controllerId,
      required this.userId});

  final int customerId, controllerId, userId;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ConstantViewModel(Repository(HttpService()))
        ..getConstantData(customerId, controllerId),
      child: Consumer<ConstantViewModel>(
        builder: (context, vm, _) {

          return vm.isLoading
              ? Padding(
                  padding: EdgeInsets.only(
                      left: MediaQuery.of(context).size.width / 2 - 95,
                      right: MediaQuery.of(context).size.width / 2 - 95),
                  child: const LoadingIndicator(
                    indicatorType: Indicator.ballPulse,
                    strokeWidth: 100,
                  ),
                ):
          Scaffold(
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            body: DefaultTabController(
              length: vm.filteredMenu.length,
              child: Column(
                children: [
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 40,
                    child: TabBar(
                      indicatorSize: TabBarIndicatorSize.label,
                      isScrollable: true,
                      indicatorColor: Colors.transparent,
                      dividerColor: Colors.transparent,
                      overlayColor: WidgetStateProperty.all<Color>(Colors.transparent),
                      tabs: vm.filteredMenu.map((filteredItem) {
                        return Tab(
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              ColorFiltered(
                                colorFilter: ColorFilter.mode(
                                  filteredItem.isSelected
                                      ? const Color(0xFF005B8D)
                                      : const Color(0xFFFFFFFF),
                                  BlendMode.srcIn,
                                ),
                                child: SvgPicture.asset(
                                  'assets/svg_images/white_arrow.svg',
                                  width: 250,
                                  height: 35,
                                ),
                              ),
                              Positioned(
                                child: Text(
                                  filteredItem.parameter, // Set tab text dynamically
                                  style: TextStyle(
                                    color: filteredItem.isSelected ? Colors.white : Colors.black,
                                    fontSize: 16,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                      onTap: (index) {
                        vm.menuOnChange(index); // Correct way to call the function
                      },
                    ),
                  ),
                  Expanded(
                    child: TabBarView(
                      children: vm.filteredMenu.map((filteredItem) {
                        switch (filteredItem.parameter) {
                          case "General":
                            return GridView.builder(
                              itemCount: vm.userConstant.constant
                                  .generalMenu.length,
                              gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount:
                                MediaQuery.sizeOf(context).width >
                                    1350
                                    ? 3
                                    : 2,
                                crossAxisSpacing: 16.0,
                                mainAxisSpacing: 16.0,
                                childAspectRatio:
                                MediaQuery.sizeOf(context).width >
                                    1350
                                    ? MediaQuery.sizeOf(context)
                                    .width /
                                    250
                                    : MediaQuery.sizeOf(context)
                                    .width /
                                    750,
                              ),
                              itemBuilder:
                                  (BuildContext context, int index) {
                                return Card(
                                  color: Colors.white,
                                  elevation: 1,
                                  child: Padding(
                                    padding:
                                    const EdgeInsets.only(top: 10),
                                    child: ListTile(
                                      title: Text(vm
                                          .userConstant
                                          .constant
                                          .generalMenu[index]
                                          .title),
                                      trailing: vm
                                          .userConstant
                                          .constant
                                          .generalMenu[index]
                                          .widgetTypeId ==
                                          1
                                          ? SizedBox(
                                        width: 75,
                                        child: TextField(
                                          controller:
                                          vm.txtEdControllers[
                                          index],
                                          inputFormatters: [
                                            FilteringTextInputFormatter
                                                .digitsOnly
                                          ],
                                          keyboardType:
                                          TextInputType
                                              .number,
                                          textAlign:
                                          TextAlign.right,
                                          style: const TextStyle(
                                              fontWeight:
                                              FontWeight
                                                  .bold),
                                          decoration:
                                          const InputDecoration(
                                            border:
                                            InputBorder.none,
                                            hintText: "value",
                                          ),
                                          onChanged: (value) {
                                            vm.updateGeneralValve(
                                                index,
                                                value,
                                                'general');
                                          },
                                        ),
                                      )
                                          : vm
                                          .userConstant
                                          .constant
                                          .generalMenu[
                                      index]
                                          .widgetTypeId ==
                                          2
                                          ? Transform.scale(
                                        scale: 0.8,
                                        child: Tooltip(
                                          message: vm.userConstant.constant.generalMenu[index].value
                                              ? 'Disable': 'Enable',
                                          child: Switch(
                                            hoverColor: Theme.of(context).primaryColor,
                                            activeColor: Theme.of(context).primaryColorLight,
                                            value: vm.userConstant.constant.generalMenu[index].value,
                                            onChanged:
                                                (value) {
                                              vm.updateGeneralSwitch(index,
                                                  !(vm.userConstant.constant.generalMenu[index].value as bool), 'general');
                                            },
                                          ),
                                        ),
                                      )
                                          : TextButton(
                                          onPressed: () {
                                            vm.showDurationInputDialog(
                                                context,
                                                vm.userConstant.constant.generalMenu[index].value, index, 'general');
                                          },
                                          child: Text(vm.userConstant.constant.generalMenu[index].value)),
                                    ),
                                  ),
                                );
                              },
                            );
                          case "Valve":
                            return vm.userConstant.constant.valveList!.isNotEmpty?
                            DataTable2(
                              border: const TableBorder(
                                top: BorderSide(color: Color(0xFFDFE0E1), width: 1),
                                bottom: BorderSide(color: Color(0xFFDFE0E1), width: 1),
                                left: BorderSide(
                                    color: Color(0xFFDFE0E1),
                                    width: 1),
                                right: BorderSide(
                                    color: Color(0xFFDFE0E1),
                                    width: 1),
                              ),
                              columnSpacing: 12,
                              minWidth: 1020,
                              dataRowHeight: 45.0,
                              headingRowHeight: 40,
                              headingRowColor:
                              WidgetStateProperty.all(
                                  const Color(0xFFFDFDFD)),
                              columns: const [
                                DataColumn(
                                    label: Center(child: Text('Valve Name'))),
                                DataColumn(label: Center(child: Text('Nominal Flow (I/hr)'))),
                                DataColumn(label: Center(child: Text('Fill Up Delay'))),
                              ],
                              rows: List.generate(
                                  vm.userConstant.constant.valveList!.length, (index) {
                                return DataRow(
                                  color: WidgetStateProperty
                                      .resolveWith<Color?>(
                                        (Set<WidgetState> states) {
                                      return index.isEven
                                          ? const Color(0xFFF6F6F6) : const Color(0xFFFDFDFD);
                                    },
                                  ),
                                  cells: [
                                    DataCell(Center(
                                      child: Text(
                                        vm.userConstant.constant.valveList![index].name,
                                        style: const TextStyle(
                                            color: Color(0xFF005B8D)),
                                      ),
                                    )),
                                    DataCell(Center(child: SizedBox(
                                      width: 100,
                                      child: TextField(
                                        controller: vm.txtEdControllersNF[index],
                                        inputFormatters: [FilteringTextInputFormatter.digitsOnly
                                        ],
                                        keyboardType: TextInputType.number,
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(fontWeight: FontWeight.bold),
                                        decoration: const InputDecoration(
                                            border: InputBorder.none,
                                            hintText: "Enter value",
                                            hintStyle: TextStyle(color: Colors.grey)),
                                        onChanged: (value) {
                                          vm.updateGeneralValve(index, value, 'value');
                                        },
                                      ),
                                    ))),

                                    DataCell(Center(
                                        child: TextButton(
                                            onPressed: () {
                                              vm.showDurationInputDialog(
                                                  context,
                                                  vm.userConstant.constant.valveList![index].duration, index, 'valve');
                                            },
                                            child: Text(vm.userConstant.constant.valveList![index].duration)))),
                                  ],
                                );
                              }),
                            ):
                            const Center(child: Text("Valve Data not available"));
                        }
                        return Center(child: Text("${filteredItem.parameter} Screen"));
                      }).toList(),
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
}
