import 'package:http/http.dart' as http;
import 'package:oro_drip_irrigation/services/http_service.dart';

class ConfigMakerRepository{
  HttpService httpService = HttpService();

  Future<http.Response> getUserConfigMaker(body) async {
    return await httpService.postRequest('/user/configMaker/get', body);
  }

  Future<http.Response> createUserConfigMaker(body) async {
    return await httpService.postRequest('/user/configMaker/create', body);
  }

}