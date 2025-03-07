import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../utils/constants.dart';
import '../utils/shared_preferences_helper.dart';

class HttpService
{
  Future<http.Response> getRequest(String endpoint, {Map<String, String>? queryParams}) async {
    final token = await PreferenceHelper.getToken();

    debugPrint('${AppConstants.apiUrl}$endpoint');

    final uri = Uri.parse('${AppConstants.apiUrl}$endpoint').replace(queryParameters: queryParams);

    var headers = {
      'Content-Type': 'application/json',
      'auth_token': token?.isNotEmpty == true ? token! : 'default_token',
    };

    return await http.get(uri, headers: headers);
  }

  Future<http.Response> postRequest(String endpoint, Map<String, dynamic> bodyData) async {
    final token = await PreferenceHelper.getToken();

    debugPrint('body: $bodyData,endpoint $endpoint');
    debugPrint('${AppConstants.apiUrl}$endpoint');

    var headers = {
      'Content-Type': 'application/json',
      'auth_token': token?.isNotEmpty == true ? token! : 'default_token',
    };

    var body = json.encode(bodyData);

    return await http.post(
      Uri.parse('${AppConstants.apiUrl}$endpoint'),
      headers: headers,
      body: body,
    );
  }

  Future<http.Response> putRequest(String endpoint, Map<String, dynamic> bodyData) async
  {
    final token = await PreferenceHelper.getToken();

    debugPrint('body: $bodyData');
    debugPrint('${AppConstants.apiUrl}$endpoint');

    var headers = {
      'Content-Type':'application/json',
      'auth_token': token?.isNotEmpty == true ? token! : 'default_token',
    };
    var body = json.encode(bodyData);
    return await http.put(Uri.parse('${AppConstants.apiUrl}$endpoint'),
        headers : headers,
        body: body
    );
  }

  Future<http.Response> deleteRequest(String endpoint, Map<String, dynamic> bodyData) async {
    final token = await PreferenceHelper.getToken();

    debugPrint('body: $bodyData');
    debugPrint('${AppConstants.apiUrl}$endpoint');

    var headers = {
      'Content-Type': 'application/json',
      'auth_token': token?.isNotEmpty == true ? token! : 'default_token',
    };
    var body = json.encode(bodyData);
    return await http.delete(Uri.parse('${AppConstants.apiUrl}$endpoint'),
        headers : headers,
        body: body
    );
  }
}