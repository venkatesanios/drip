import 'dart:convert';
import 'package:data_table_2/data_table_2.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../Models/servicerequestdealermodel.dart';
import '../../StateManagement/overall_use.dart';
import '../../repository/repository.dart';
import '../../services/http_service.dart';
import '../../utils/snack_bar.dart';

class ServiceRequestsTable extends StatefulWidget {
  const ServiceRequestsTable({
    super.key,
    required this.userId,
  });

  final int userId;

  @override
  State<ServiceRequestsTable> createState() => _ServiceRequestsTableState();
}

class _ServiceRequestsTableState extends State<ServiceRequestsTable> {
  ServiceDealerModel _serviceDealerModel = ServiceDealerModel();
  DateFormat dateFormat = DateFormat("yyyy-MM-dd");

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    try {
      final repository = Repository(HttpService());
      var response = await repository.getUserServiceRequestForDealer({
        "userId": widget.userId,
      });

      if (response.statusCode == 200) {
        setState(() {
          var jsonData = jsonDecode(response.body);
          _serviceDealerModel = ServiceDealerModel.fromJson(jsonData);
        });
      } else {
        GlobalSnackBar.show(context, "Failed to load data", response.statusCode);
      }
    } catch (e, stackTrace) {
      debugPrint('Error fetching data: $e');
      debugPrint('StackTrace: $stackTrace');
    }
  }

  Future<void> updateData(
      int userId,
      int controllerId,
      int requestTypeId,
      int responsibleUser,
      String estimatedDate,
      String status,
      int requestId,
      ) async {
    final body = {
      "userId": userId,
      "controllerId": controllerId,
      "requestTypeId": requestTypeId,
      "requestId": requestId,
      "responsibleUser": responsibleUser,
      "estimatedDate": estimatedDate,
      "status": status,
      "closedDate": status == 'Closed'
          ? dateFormat.format(DateTime.now())
          : null,
      "modifyUser": userId,
    };

    final repository = Repository(HttpService());
    var response = await repository.updateUserServiceRequest(body);
    final jsonData = json.decode(response.body);

    if (response.statusCode == 200) {
      GlobalSnackBar.show(context, jsonData['message'], response.statusCode);
      fetchData();
    } else {
      GlobalSnackBar.show(context, jsonData['message'], response.statusCode);
    }
  }

  @override
  Widget build(BuildContext context) {
    final data = _serviceDealerModel.data ?? [];

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(title: const Text('Service Request List')),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: data.isEmpty ? const Center(
          child: Text(
            'Currently No Request available',
            style: TextStyle(color: Colors.black),
          ),
        ):
        DataTable2(
          minWidth: 1200,
          showBottomBorder: true,
          headingRowColor: WidgetStateProperty.all(
            Theme.of(context).primaryColorDark,
          ),
          headingRowHeight: 29,
          dataRowHeight: 45,
          columns: const [
            DataColumn2(
              fixedWidth: 50,
              label: Text('SNo',
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold)),
            ),
            DataColumn2(
              fixedWidth: 150,
              label: Text('Site Name',
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold)),
            ),
            DataColumn2(
              size: ColumnSize.L,
              label: Text('Issue',
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold)),
            ),
            DataColumn2(
              size: ColumnSize.L,
              label: Text('Description',
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold)),
            ),
            DataColumn2(
              fixedWidth: 140,
              label: Text('Request Date',
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold)),
            ),
            DataColumn2(
              fixedWidth: 160,
              label: Text('Estimated Date',
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold)),
            ),
            DataColumn2(
              fixedWidth: 165,
              label: Text('Status',
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold)),
            ),
            DataColumn2(
              fixedWidth: 150,
              label: Text('Update',
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
          rows: List<DataRow>.generate(
            data.length,
                (index) {
              final item = data[index];
              return DataRow(
                color: WidgetStateProperty.all(
                  item.status == 'Closed'
                      ? Colors.green.shade100
                      : item.priority == 'High'
                      ? Colors.red.shade100
                      : item.priority == 'Medium'
                      ? Colors.yellow.shade100
                      : Colors.white,
                ),
                cells: [
                  DataCell(Text(item.requestId.toString())),
                  DataCell(Text(item.groupName ?? '')),
                  DataCell(Text(item.requestType ?? '')),
                  DataCell(Text(item.requestDescription ?? '')),
                  DataCell(Text(item.requestDate != null
                      ? dateFormat.format(item.requestDate!)
                      : '-')),
                  DataCell(
                    InkWell(
                      child: Row(
                        children: [
                          Text(item.estimatedDate != null
                              ? dateFormat.format(item.estimatedDate!)
                              : '-'),
                          const Icon(Icons.date_range),
                        ],
                      ),
                      onTap: () async {
                        DateTime? pickedDate = await showDatePicker(
                          context: context,
                          initialDate: item.estimatedDate ?? DateTime.now(),
                          firstDate: DateTime(DateTime.now().year),
                          lastDate: DateTime(2026),
                        );
                        if (pickedDate != null) {
                          setState(() => item.estimatedDate = pickedDate);
                        }
                      },
                    ),
                  ),
                  DataCell(
                    DropdownButton<String>(
                      value: item.status,
                      items: ['Waiting', 'In-Progress', 'Closed']
                          .map((value) => DropdownMenuItem(
                        value: value,
                        child: Text(value),
                      ))
                          .toList(),
                      onChanged: (newValue) =>
                          setState(() => item.status = newValue),
                    ),
                  ),
                  DataCell(
                    ElevatedButton(
                      onPressed: () {
                        updateData(
                          widget.userId,
                          item.controllerId!,
                          item.requestTypeId!,
                          item.responsibleUser!,
                          dateFormat.format(item.estimatedDate!),
                          item.status!,
                          item.requestId!,
                        );
                      },
                      child: const Text(
                        'Update',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

