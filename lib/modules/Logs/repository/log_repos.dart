/*

/api/v1/user/log/pumpHourly/get
/api/v1/user/log/pumpVoltage/get
/api/v1/user/log/nodePumpHourly/get
/api/v1/user/log/nodePumpVoltage/get
/api/v1/user/log/pump/get
/api/v1/user/log/nodePump/get
*/
import 'package:http/http.dart' as http;

import '../../../services/http_service.dart';
class LogRepository {
  final HttpService apiService;
  LogRepository(this.apiService);

  Future<http.Response> getUserPumpHourlyLog(body, bool isNode) async{
    return await apiService.postRequest('/user/log/${isNode ? 'nodePumpHourly': 'pumpHourly'}/get', body);
  }

  Future<http.Response> getUserPumpLog(body, bool isNode) async{
    return await apiService.postRequest('/user/log/${isNode ? 'nodePump': 'pump'}/get', body);
  }

  Future<http.Response> getUserVoltageLog(body, bool isNode) async{
    return await apiService.postRequest('/user/log/${isNode ? 'nodePumpVoltage': 'pumpVoltage'}/get', body);
  }
}