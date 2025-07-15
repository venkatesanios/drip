import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../utils/constants.dart';
import '../utils/shared_preferences_helper.dart';

class HttpService
{
  Future<http.Response> getRequest(String endpoint, {String? type,Map<String, String>? queryParams}) async {
    final token = await PreferenceHelper.getToken();

    debugPrint('${AppConstants.apiUrl}$endpoint');

    final uri = Uri.parse('${AppConstants.apiUrl}$endpoint').replace(queryParameters: queryParams);

    var headers = {
      'Content-Type': 'application/json',
      'auth_token': token?.isNotEmpty == true ? token! : 'default_token',
    };
    print('MQTTCONFIG ${http.get(Uri.parse(endpoint), headers: headers).toString()}');
    return await type == 'MQTTCONFIG' ? http.get(Uri.parse(endpoint), headers: headers) : http.get(uri, headers: headers);
  }

  Future<http.Response> postRequest(String endpoint, Map<String, dynamic> bodyData) async {
     final token = await PreferenceHelper.getToken();
     debugPrint('body: ${jsonEncode(bodyData)},endpoint $endpoint');
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

    // debugPrint('body: $bodyData');
    debugPrint('endpoint:');
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

  Future<String> sendTextToAI(String text, String selectedLanguage) async {
    final uri = Uri.parse('https://api.openai.com/v1/chat/completions');
    final headers = {
      //'Authorization': 'Bearer sk-proj-xxx',
      'Authorization': 'Bearer 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', // Keep this safe in production!
      'Content-Type': 'application/json',
    };

    final body = jsonEncode({
      'model': 'gpt-3.5-turbo',
      'messages': [
        {
          "role": "system",
          "content": "You are an expert crop advisor. Always respond only in $selectedLanguage. "
              "Analyze the uploaded crop image and provide a detailed diagnosis of any visible crop issues. "
              "Give actionable recommendations to improve yield or treat the problem, "
              "even if image is the only data available. Identify crop type and predict the days of the crop. "
              "Based on that, suggest the crop advisory, fertilizer, and watering recommendations."
        },
        {'role': 'user', 'content': text}
      ],
    });

    final response = await http.post(uri, headers: headers, body: body);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final message = data['choices'][0]['message']['content'];
      return message;
    } else {
      throw Exception('AI request failed: ${response.statusCode}');
    }
  }
}