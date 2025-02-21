import 'package:http/http.dart' as http;
import '../services/http_service.dart';

class Repository{

  final HttpService apiService;
  Repository(this.apiService);

  Future<dynamic> checkLoginAuth(body) async {
    return apiService.postRequest('/auth/signIn', body);
  }

  Future<http.Response> fetchAllMySalesReports(body) async {
    return await apiService.postRequest('/product/getSalesReport', body);
  }

  Future<http.Response> fetchMyStocks(body) async {
    return await apiService.postRequest('/product/getStock', body);
  }

  Future<http.Response> fetchMyCustomerList(body) async {
    return await apiService.postRequest('/user/getUserList', body);
  }

  Future<http.Response> fetchAllMyInventory(body) async {
    return await apiService.postRequest('/product/getInventory', body);
  }

  Future<http.Response> fetchAllCategoriesAndModels(body) async {
    return await apiService.postRequest('/product/getCategoryModelAndDeviceId', body);
  }

  Future<http.Response> fetchDeviceList(body) async {
    return await apiService.postRequest('/product/getList', body);
  }

  Future<http.Response> fetchCountryList() async {
    return await apiService.getRequest('/country/get');
  }

  Future<http.Response> fetchStateList(countryId) async {
    return await apiService.getRequest('/state/get/$countryId');
  }

  Future<http.Response> fetchSentAndReceivedData(body) async {
    return await apiService.postRequest('/user/getSentAndReceivedMessage/getStatus', body);
  }

  Future<http.Response> fetchLanguageByActive(body) async {
    return await apiService.postRequest('/language/getByActive', body);
  }

  Future<http.Response> createCustomerAccount(body) async {
    return await apiService.postRequest('/user/create', body);
  }

  Future<http.Response> createSubUserAccount(body) async {
    return await apiService.postRequest('/user/createWithMainUser', body);
  }

  Future<http.Response> fetchActiveCategory(body) async {
    return await apiService.postRequest('/category/getByActive', body);
  }

  Future<http.Response> fetchCategory() async {
    return await apiService.getRequest('/category/get');
  }

  Future<http.Response> createCategory(body) async {
  return await apiService.postRequest('/category/create', body);
  }

  Future<http.Response> updateCategory(body) async {
  return await apiService.putRequest('/category/update', body);
  }

  Future<http.Response> inActiveCategoryById(body) async {
    return await apiService.putRequest('/category/inactive', body);
  }

  Future<http.Response> activeCategoryById(body) async {
    return await apiService.putRequest('/category/active', body);
  }

  Future<http.Response> fetchModelByCategoryId(body) async {
    return await apiService.postRequest('/model/getByCategoryId', body);
  }

  Future<http.Response> checkProduct(body) async {
    return await apiService.postRequest('/product/checkStatus', body);
  }

  Future<http.Response> createProduct(body) async {
    return await apiService.postRequest('/product/create', body);
  }

  Future<http.Response> updateProduct(body) async {
    return await apiService.putRequest('/product/update', body);
  }

  Future<http.Response> updateUserDetails(body) async {
    return await apiService.putRequest('/user/updateDetails', body);
  }

  Future<http.Response> addProductToDealer(body) async {
    return await apiService.postRequest('/product/addToDealer', body);
  }

  Future<http.Response> addProductToCustomer(body) async {
    return await apiService.postRequest('/product/addToCustomer', body);
  }

  Future<http.Response> fetchUserGroupWithMasterList(body) async {
    return await apiService.postRequest('/user/deviceList/getGroupWithMaster', body);
  }

  Future<http.Response> fetchMasterProductStock(body) async {
    return await apiService.postRequest('/product/getMasterStock', body);
  }

  Future<http.Response> createUserGroupAndDeviceList(body) async {
    return await apiService.postRequest('/user/deviceList/createAndGroup', body);
  }

  Future<http.Response> fetchAllMySite(body) async {
    return await apiService.postRequest('/user/dashboard', body);
  }

  Future<Map<String, dynamic>> fetchAllMySiteOld(body) async {
    return {
      "code": 200,
      "message": "",
      "data": [
        {
          "groupId": 1,
          "groupName": "New Config Site",
          "groupAddress": "Testing address",
          "master": [
            {
              "controllerId": 1,
              "deviceId": "2CCF676089F2",
              "deviceName": "ORO GEM",
              "categoryId": 2,
              "categoryName": "ORO GEM",
              "modelId": 16,
              "modelName": "5G",
              "conditionLibraryCount": 10,
              "units": [
                {
                  "dealerDefinitionId": 114,
                  "parameter": "Water Meter",
                  "value": "l/s"
                },
                {
                  "dealerDefinitionId": 115,
                  "parameter": "Pressure Sensor",
                  "value": "bar"
                },
                {
                  "dealerDefinitionId": 116,
                  "parameter": "Moisture Sensor",
                  "value": "cb"
                },
                {
                  "dealerDefinitionId": 117,
                  "parameter": "Level Sensor",
                  "value": "feet"
                },
                {
                  "dealerDefinitionId": 118,
                  "parameter": "Temperature Sensor",
                  "value": "°C"
                },
                {
                  "dealerDefinitionId": 119,
                  "parameter": "Soil Temperature Sensor",
                  "value": "°C"
                },
                {
                  "dealerDefinitionId": 120,
                  "parameter": "Humdity Sensor",
                  "value": "%"
                },
                {
                  "dealerDefinitionId": 121,
                  "parameter": "CO2 Sensor",
                  "value": "ppm"
                },
                {
                  "dealerDefinitionId": 122,
                  "parameter": "LUX Sensor",
                  "value": "lux"
                },
                {
                  "dealerDefinitionId": 123,
                  "parameter": "Leaf Wetness Sensor",
                  "value": "%"
                },
                {
                  "dealerDefinitionId": 124,
                  "parameter": "Rain Fall",
                  "value": "mm"
                },
                {
                  "dealerDefinitionId": 125,
                  "parameter": "Wind Speed",
                  "value": "km/h"
                },
                {
                  "dealerDefinitionId": 126,
                  "parameter": "Wind Direction",
                  "value": "°"
                },
                {
                  "dealerDefinitionId": 128,
                  "parameter": "Atmospheric Pressure Sensor",
                  "value": "kPa"
                },
                {
                  "dealerDefinitionId": 129,
                  "parameter": "LDX Sensor",
                  "value": "lux"
                }
              ],
              "nodeList": [],
              "config":  {
                "filterSite": [],
                "fertilizerSite": [],
                "waterSource": [
                  {
                    "objectId": 1,
                    "sNo": 1.001,
                    "name": "Source 1",
                    "connectionNo": null,
                    "objectName": "Source",
                    "type": "-",
                    "controllerId": null,
                    "count": null,
                    "sourceType": {},
                    "level": {
                      "objectId": 5,
                      "sNo": 5.001,
                      "name": "Pump 1",
                      "connectionNo": null,
                      "objectName": "Pump",
                      "type": "1,2",
                      "percentage": "35",
                      "controllerId": null,
                      "count": null
                    },
                    "topFloat": {},
                    "bottomFloat": {},
                    "inletPump": [],
                    "outletPump": [
                      {
                        "objectId": 5,
                        "sNo": 5.001,
                        "name": "Pump 1",
                        "connectionNo": null,
                        "objectName": "Pump",
                        "type": "1,2",
                        "controllerId": null,
                        "count": null
                      },
                      {
                        "objectId": 5,
                        "sNo": 5.002,
                        "name": "Pump 2",
                        "connectionNo": null,
                        "objectName": "Pump",
                        "type": "1,2",
                        "controllerId": null,
                        "count": null
                      },
                    ],
                    "valves": []
                  },
                ],
                "pump": [
                  {
                    "objectId": 5,
                    "sNo": 5.001,
                    "name": "Pump 1",
                    "connectionNo": null,
                    "objectName": "Pump",
                    "type": "1,2",
                    "controllerId": null,
                    "count": null,
                    "level": {},
                    "pressure": {},
                    "waterMeter": {},
                    "pumpType": {}
                  },
                  {
                    "objectId": 5,
                    "sNo": 5.002,
                    "name": "Pump 2",
                    "connectionNo": null,
                    "objectName": "Pump",
                    "type": "1,2",
                    "controllerId": null,
                    "count": null,
                    "level": {},
                    "pressure": {},
                    "waterMeter": {},
                    "pumpType": {}
                  },
                ],
                "moistureSensor": [],
                "irrigationLine": [
                  {
                    "objectId": 2,
                    "sNo": 2.001,
                    "name": "Irrigation Line 1",
                    "connectionNo": null,
                    "objectName": "Irrigation Line",
                    "type": "-",
                    "controllerId": null,
                    "count": null,
                    "source": [],
                    "sourcePump": [
                      {
                        "objectId": 5,
                        "sNo": 5.001,
                        "name": "Pump 1",
                        "connectionNo": null,
                        "objectName": "Pump",
                        "type": "1,2",
                        "controllerId": null,
                        "count": null
                      },
                      {
                        "objectId": 5,
                        "sNo": 5.002,
                        "name": "Pump 2",
                        "connectionNo": null,
                        "objectName": "Pump",
                        "type": "1,2",
                        "controllerId": null,
                        "count": null
                      }
                    ],
                    "irrigationPump": [
                      {
                        "objectId": 5,
                        "sNo": 5.003,
                        "name": "Pump 3",
                        "connectionNo": null,
                        "objectName": "Pump",
                        "type": "1,2",
                        "controllerId": null,
                        "count": null
                      }
                    ],
                    "centralFiltration": [],
                    "localFiltration": [],
                    "centralFertilization": [],
                    "localFertilization": [],
                    "valve": [
                      {
                        "objectId": 13,
                        "sNo": 13.001,
                        "name": "Valve 1",
                        "connectionNo": null,
                        "objectName": "Valve",
                        "type": "1,2",
                        "controllerId": null,
                        "count": null
                      },
                      {
                        "objectId": 13,
                        "sNo": 13.002,
                        "name": "Valve 2",
                        "connectionNo": null,
                        "objectName": "Valve",
                        "type": "1,2",
                        "controllerId": null,
                        "count": null
                      },
                      {
                        "objectId": 13,
                        "sNo": 13.003,
                        "name": "Valve 3",
                        "connectionNo": null,
                        "objectName": "Valve",
                        "type": "1,2",
                        "controllerId": null,
                        "count": null
                      },
                      {
                        "objectId": 13,
                        "sNo": 13.004,
                        "name": "Valve 4",
                        "connectionNo": null,
                        "objectName": "Valve",
                        "type": "1,2",
                        "controllerId": null,
                        "count": null
                      },
                      {
                        "objectId": 13,
                        "sNo": 13.005,
                        "name": "Valve 5",
                        "connectionNo": null,
                        "objectName": "Valve",
                        "type": "1,2",
                        "controllerId": null,
                        "count": null
                      },
                      {
                        "objectId": 13,
                        "sNo": 13.006,
                        "name": "Valve 6",
                        "connectionNo": null,
                        "objectName": "Valve",
                        "type": "1,2",
                        "controllerId": null,
                        "count": null
                      },
                      {
                        "objectId": 13,
                        "sNo": 13.007,
                        "name": "Valve 7",
                        "connectionNo": null,
                        "objectName": "Valve",
                        "type": "1,2",
                        "controllerId": null,
                        "count": null
                      },
                      {
                        "objectId": 13,
                        "sNo": 13.008,
                        "name": "Valve 8",
                        "connectionNo": null,
                        "objectName": "Valve",
                        "type": "1,2",
                        "controllerId": null,
                        "count": null
                      },
                      {
                        "objectId": 13,
                        "sNo": 13.009,
                        "name": "Valve 9",
                        "connectionNo": null,
                        "objectName": "Valve",
                        "type": "1,2",
                        "controllerId": null,
                        "count": null
                      },
                      {
                        "objectId": 13,
                        "sNo": 13.01,
                        "name": "Valve 10",
                        "connectionNo": null,
                        "objectName": "Valve",
                        "type": "1,2",
                        "controllerId": null,
                        "count": null
                      },
                      {
                        "objectId": 13,
                        "sNo": 13.001,
                        "name": "Valve 1",
                        "connectionNo": null,
                        "objectName": "Valve",
                        "type": "1,2",
                        "controllerId": null,
                        "count": null
                      },
                      {
                        "objectId": 13,
                        "sNo": 13.002,
                        "name": "Valve 2",
                        "connectionNo": null,
                        "objectName": "Valve",
                        "type": "1,2",
                        "controllerId": null,
                        "count": null
                      },
                      {
                        "objectId": 13,
                        "sNo": 13.003,
                        "name": "Valve 3",
                        "connectionNo": null,
                        "objectName": "Valve",
                        "type": "1,2",
                        "controllerId": null,
                        "count": null
                      },
                      {
                        "objectId": 13,
                        "sNo": 13.004,
                        "name": "Valve 4",
                        "connectionNo": null,
                        "objectName": "Valve",
                        "type": "1,2",
                        "controllerId": null,
                        "count": null
                      },
                      {
                        "objectId": 13,
                        "sNo": 13.005,
                        "name": "Valve 5",
                        "connectionNo": null,
                        "objectName": "Valve",
                        "type": "1,2",
                        "controllerId": null,
                        "count": null
                      },
                      {
                        "objectId": 13,
                        "sNo": 13.006,
                        "name": "Valve 6",
                        "connectionNo": null,
                        "objectName": "Valve",
                        "type": "1,2",
                        "controllerId": null,
                        "count": null
                      },
                      {
                        "objectId": 13,
                        "sNo": 13.007,
                        "name": "Valve 7",
                        "connectionNo": null,
                        "objectName": "Valve",
                        "type": "1,2",
                        "controllerId": null,
                        "count": null
                      },
                      {
                        "objectId": 13,
                        "sNo": 13.008,
                        "name": "Valve 8",
                        "connectionNo": null,
                        "objectName": "Valve",
                        "type": "1,2",
                        "controllerId": null,
                        "count": null
                      },
                      {
                        "objectId": 13,
                        "sNo": 13.009,
                        "name": "Valve 9",
                        "connectionNo": null,
                        "objectName": "Valve",
                        "type": "1,2",
                        "controllerId": null,
                        "count": null
                      },
                      {
                        "objectId": 13,
                        "sNo": 13.01,
                        "name": "Valve 10",
                        "connectionNo": null,
                        "objectName": "Valve",
                        "type": "1,2",
                        "controllerId": null,
                        "count": null
                      },
                      {
                        "objectId": 13,
                        "sNo": 13.001,
                        "name": "Valve 1",
                        "connectionNo": null,
                        "objectName": "Valve",
                        "type": "1,2",
                        "controllerId": null,
                        "count": null
                      },
                      {
                        "objectId": 13,
                        "sNo": 13.002,
                        "name": "Valve 2",
                        "connectionNo": null,
                        "objectName": "Valve",
                        "type": "1,2",
                        "controllerId": null,
                        "count": null
                      },
                      {
                        "objectId": 13,
                        "sNo": 13.001,
                        "name": "Valve 1",
                        "connectionNo": null,
                        "objectName": "Valve",
                        "type": "1,2",
                        "controllerId": null,
                        "count": null
                      },
                      {
                        "objectId": 13,
                        "sNo": 13.002,
                        "name": "Valve 2",
                        "connectionNo": null,
                        "objectName": "Valve",
                        "type": "1,2",
                        "controllerId": null,
                        "count": null
                      },
                      {
                        "objectId": 13,
                        "sNo": 13.005,
                        "name": "Valve 5",
                        "connectionNo": null,
                        "objectName": "Valve",
                        "type": "1,2",
                        "controllerId": null,
                        "count": null
                      },
                      {
                        "objectId": 13,
                        "sNo": 13.006,
                        "name": "Valve 6",
                        "connectionNo": null,
                        "objectName": "Valve",
                        "type": "1,2",
                        "controllerId": null,
                        "count": null
                      },
                      {
                        "objectId": 13,
                        "sNo": 13.007,
                        "name": "Valve 7",
                        "connectionNo": null,
                        "objectName": "Valve",
                        "type": "1,2",
                        "controllerId": null,
                        "count": null
                      },
                      {
                        "objectId": 13,
                        "sNo": 13.008,
                        "name": "Valve 8",
                        "connectionNo": null,
                        "objectName": "Valve",
                        "type": "1,2",
                        "controllerId": null,
                        "count": null
                      },
                      {
                        "objectId": 13,
                        "sNo": 13.009,
                        "name": "Valve 9",
                        "connectionNo": null,
                        "objectName": "Valve",
                        "type": "1,2",
                        "controllerId": null,
                        "count": null
                      },
                      {
                        "objectId": 13,
                        "sNo": 13.01,
                        "name": "Valve 10",
                        "connectionNo": null,
                        "objectName": "Valve",
                        "type": "1,2",
                        "controllerId": null,
                        "count": null
                      },
                      {
                        "objectId": 13,
                        "sNo": 13.001,
                        "name": "Valve 1",
                        "connectionNo": null,
                        "objectName": "Valve",
                        "type": "1,2",
                        "controllerId": null,
                        "count": null
                      },
                      {
                        "objectId": 13,
                        "sNo": 13.002,
                        "name": "Valve 2",
                        "connectionNo": null,
                        "objectName": "Valve",
                        "type": "1,2",
                        "controllerId": null,
                        "count": null
                      },
                      {
                        "objectId": 13,
                        "sNo": 13.001,
                        "name": "Valve 1",
                        "connectionNo": null,
                        "objectName": "Valve",
                        "type": "1,2",
                        "controllerId": null,
                        "count": null
                      },

                    ],
                    "mainValve": [],
                    "fan": [],
                    "fogger": [],
                    "pesticides": [],
                    "heater": [],
                    "screen": [],
                    "vent": [],
                    "powerSupply": {},
                    "pressureSwitch": {},
                    "waterMeter": {},
                    "pressureIn": {},
                    "pressureOut": {},
                    "moisture": [],
                    "temperature": [],
                    "soilTemperature": [],
                    "humidity": [],
                    "co2": []
                  }
                ]
              },
              "live": {
                "cC": "1234567890AB",
                "cD": "2024-11-14",
                "cT": "12:15:00",
              },
            }
          ]
        }
      ]
    };
  }

  Future<http.Response> getUserProgramSequence(body) async {
    return await apiService.postRequest('/user/program/sequence/get', body);
  }

  Future<http.Response> getUserProgramSchedule(body) async {
    return await apiService.postRequest('/user/program/schedule/get', body);
  }

  Future<http.Response> getUserProgramCondition(body) async {
    return await apiService.postRequest('/user/program/condition/get', body);
  }

  Future<http.Response> getUserProgramSelection(body) async {
    return await apiService.postRequest('/user/program/selection/get', body);
  }

  Future<http.Response> getUserProgramAlarm(body) async {
    return await apiService.postRequest('/user/program/alarm/get', body);
  }

  Future<http.Response> getUserProgramDetails(body) async {
    return await apiService.postRequest('/user/program/details/get', body);
  }

  Future<http.Response> getUserConfigMaker(body) async {
    return await apiService.postRequest('/user/configMaker/getAsDefault', body);
  }

  Future<http.Response> getProgramLibraryData(body) async {
    return await apiService.postRequest('/user/program/getLibrary', body);
  }
}

/*
{"filterSite":[],"fertilizerSite":[],"waterSource":[{"objectId":1,"sNo":1.001,"name":"Source 1","connectionNo":null,"objectName":"Source","type":"-","controllerId":null,"count":null,"sourceType":{},"level":{},"topFloat":{},"bottomFloat":{},"inletPump":[],"outletPump":[{"objectId":5,"sNo":5.001,"name":"Pump 1","connectionNo":null,"objectName":"Pump","type":"1,2","controllerId":null,"count":null},{"objectId":5,"sNo":5.002,"name":"Pump 2","connectionNo":null,"objectName":"Pump","type":"1,2","controllerId":null,"count":null}],"valves":[]},{"objectId":1,"sNo":1.002,"name":"Source 2","connectionNo":null,"objectName":"Source","type":"-","controllerId":null,"count":null,"sourceType":{},"level":{},"topFloat":{},"bottomFloat":{},"inletPump":[{"objectId":5,"sNo":5.001,"name":"Pump 1","connectionNo":null,"objectName":"Pump","type":"1,2","controllerId":null,"count":null},{"objectId":5,"sNo":5.002,"name":"Pump 2","connectionNo":null,"objectName":"Pump","type":"1,2","controllerId":null,"count":null}],"outletPump":[{"objectId":5,"sNo":5.003,"name":"Pump 3","connectionNo":null,"objectName":"Pump","type":"1,2","controllerId":null,"count":null}],"valves":[]}],"pump":[{"objectId":5,"sNo":5.001,"name":"Pump 1","connectionNo":null,"objectName":"Pump","type":"1,2","controllerId":null,"count":null,"level":{},"pressure":{},"waterMeter":{},"pumpType":{}},{"objectId":5,"sNo":5.002,"name":"Pump 2","connectionNo":null,"objectName":"Pump","type":"1,2","controllerId":null,"count":null,"level":{},"pressure":{},"waterMeter":{},"pumpType":{}},{"objectId":5,"sNo":5.003,"name":"Pump 3","connectionNo":null,"objectName":"Pump","type":"1,2","controllerId":null,"count":null,"level":{},"pressure":{},"waterMeter":{},"pumpType":{}}],"moistureSensor":[],"irrigationLine":[{"objectId":2,"sNo":2.001,"name":"Irrigation Line 1","connectionNo":null,"objectName":"Irrigation Line","type":"-","controllerId":null,"count":null,"source":[],"sourcePump":[{"objectId":5,"sNo":5.001,"name":"Pump 1","connectionNo":null,"objectName":"Pump","type":"1,2","controllerId":null,"count":null},{"objectId":5,"sNo":5.002,"name":"Pump 2","connectionNo":null,"objectName":"Pump","type":"1,2","controllerId":null,"count":null}],"irrigationPump":[{"objectId":5,"sNo":5.003,"name":"Pump 3","connectionNo":null,"objectName":"Pump","type":"1,2","controllerId":null,"count":null}],"centralFiltration":{},"localFiltration":{},"centralFertilization":{},"localFertilization":{},"valve":[{"objectId":13,"sNo":13.001,"name":"Valve 1","connectionNo":null,"objectName":"Valve","type":"1,2","controllerId":null,"count":null},{"objectId":13,"sNo":13.002,"name":"Valve 2","connectionNo":null,"objectName":"Valve","type":"1,2","controllerId":null,"count":null},{"objectId":13,"sNo":13.003,"name":"Valve 3","connectionNo":null,"objectName":"Valve","type":"1,2","controllerId":null,"count":null},{"objectId":13,"sNo":13.004,"name":"Valve 4","connectionNo":null,"objectName":"Valve","type":"1,2","controllerId":null,"count":null},{"objectId":13,"sNo":13.005,"name":"Valve 5","connectionNo":null,"objectName":"Valve","type":"1,2","controllerId":null,"count":null},{"objectId":13,"sNo":13.006,"name":"Valve 6","connectionNo":null,"objectName":"Valve","type":"1,2","controllerId":null,"count":null},{"objectId":13,"sNo":13.007,"name":"Valve 7","connectionNo":null,"objectName":"Valve","type":"1,2","controllerId":null,"count":null},{"objectId":13,"sNo":13.008,"name":"Valve 8","connectionNo":null,"objectName":"Valve","type":"1,2","controllerId":null,"count":null},{"objectId":13,"sNo":13.009,"name":"Valve 9","connectionNo":null,"objectName":"Valve","type":"1,2","controllerId":null,"count":null},{"objectId":13,"sNo":13.01,"name":"Valve 10","connectionNo":null,"objectName":"Valve","type":"1,2","controllerId":null,"count":null}],"mainValve":[],"fan":[],"fogger":[],"pesticides":[],"heater":[],"screen":[],"vent":[],"powerSupply":{},"pressureSwitch":{},"waterMeter":{},"pressureIn":{},"pressureOut":{},"moisture":[],"temperature":[],"soilTemperature":[],"humidity":[],"co2":[]}]}*/
/*
{"filterSite":[{"objectId":4,"sNo":4.001,"name":"Filtration Site 1","connectionNo":null,"objectName":"Filtration Site","type":"-","controllerId":null,"count":null,"siteMode":2,"filters":[{"objectId":11,"sNo":11.001,"name":"Filter 1","connectionNo":null,"objectName":"Filter","type":"1,2","controllerId":null,"count":null},{"objectId":11,"sNo":11.002,"name":"Filter 2","connectionNo":null,"objectName":"Filter","type":"1,2","controllerId":null,"count":null}],"pressureIn":{"objectId":24,"sNo":24.001,"name":"Pressure Sensor 1","connectionNo":null,"objectName":"Pressure Sensor","type":"3","controllerId":null,"count":null},"pressureOut":{"objectId":24,"sNo":24.002,"name":"Pressure Sensor 2","connectionNo":null,"objectName":"Pressure Sensor","type":"3","controllerId":null,"count":null},"backWashValve":{}}],"fertilizerSite":[],"waterSource":[{"objectId":1,"sNo":1.001,"name":"Source 1","connectionNo":null,"objectName":"Source","type":"-","controllerId":null,"count":null,"sourceType":{},"level":{},"topFloat":{},"bottomFloat":{},"inletPump":[],"outletPump":[{"objectId":5,"sNo":5.001,"name":"Pump 1","connectionNo":null,"objectName":"Pump","type":"1,2","controllerId":null,"count":null}],"valves":[]},{"objectId":1,"sNo":1.002,"name":"Source 2","connectionNo":null,"objectName":"Source","type":"-","controllerId":null,"count":null,"sourceType":{},"level":{},"topFloat":{},"bottomFloat":{},"inletPump":[{"objectId":5,"sNo":5.001,"name":"Pump 1","connectionNo":null,"objectName":"Pump","type":"1,2","controllerId":null,"count":null}],"outletPump":[{"objectId":5,"sNo":5.002,"name":"Pump 2","connectionNo":null,"objectName":"Pump","type":"1,2","controllerId":null,"count":null},{"objectId":5,"sNo":5.003,"name":"Pump 3","connectionNo":null,"objectName":"Pump","type":"1,2","controllerId":null,"count":null},{"objectId":5,"sNo":5.004,"name":"Pump 4","connectionNo":null,"objectName":"Pump","type":"1,2","controllerId":null,"count":null}],"valves":[]}],"pump":[{"objectId":5,"sNo":5.001,"name":"Pump 1","connectionNo":null,"objectName":"Pump","type":"1,2","controllerId":null,"count":null,"level":{},"pressure":{},"waterMeter":{},"pumpType":{}},{"objectId":5,"sNo":5.002,"name":"Pump 2","connectionNo":null,"objectName":"Pump","type":"1,2","controllerId":null,"count":null,"level":{},"pressure":{},"waterMeter":{},"pumpType":{}},{"objectId":5,"sNo":5.003,"name":"Pump 3","connectionNo":null,"objectName":"Pump","type":"1,2","controllerId":null,"count":null,"level":{},"pressure":{},"waterMeter":{},"pumpType":{}},{"objectId":5,"sNo":5.004,"name":"Pump 4","connectionNo":null,"objectName":"Pump","type":"1,2","controllerId":null,"count":null,"level":{},"pressure":{},"waterMeter":{},"pumpType":{}}],"moistureSensor":[],"irrigationLine":[{"objectId":2,"sNo":2.001,"name":"Irrigation Line 1","connectionNo":null,"objectName":"Irrigation Line","type":"-","controllerId":null,"count":null,"source":[],"sourcePump":[{"objectId":5,"sNo":5.001,"name":"Pump 1","connectionNo":null,"objectName":"Pump","type":"1,2","controllerId":null,"count":null}],"irrigationPump":[{"objectId":5,"sNo":5.002,"name":"Pump 2","connectionNo":null,"objectName":"Pump","type":"1,2","controllerId":null,"count":null},{"objectId":5,"sNo":5.003,"name":"Pump 3","connectionNo":null,"objectName":"Pump","type":"1,2","controllerId":null,"count":null},{"objectId":5,"sNo":5.004,"name":"Pump 4","connectionNo":null,"objectName":"Pump","type":"1,2","controllerId":null,"count":null}],"centralFiltration":{"objectId":4,"sNo":4.001,"name":"Filtration Site 1","connectionNo":null,"objectName":"Filtration Site","type":"-","controllerId":null,"count":null},"localFiltration":{},"centralFertilization":{},"localFertilization":{},"valve":[{"objectId":13,"sNo":13.001,"name":"Valve 1","connectionNo":null,"objectName":"Valve","type":"1,2","controllerId":null,"count":null},{"objectId":13,"sNo":13.002,"name":"Valve 2","connectionNo":null,"objectName":"Valve","type":"1,2","controllerId":null,"count":null},{"objectId":13,"sNo":13.003,"name":"Valve 3","connectionNo":null,"objectName":"Valve","type":"1,2","controllerId":null,"count":null},{"objectId":13,"sNo":13.004,"name":"Valve 4","connectionNo":null,"objectName":"Valve","type":"1,2","controllerId":null,"count":null}],"mainValve":[],"fan":[],"fogger":[],"pesticides":[],"heater":[],"screen":[],"vent":[],"powerSupply":{},"pressureSwitch":{},"waterMeter":{"objectId":22,"sNo":22.001,"name":"Water Meter 1","connectionNo":null,"objectName":"Water Meter","type":"6","controllerId":null,"count":null},"pressureIn":{},"pressureOut":{},"moisture":[],"temperature":[],"soilTemperature":[],"humidity":[],"co2":[]},{"objectId":2,"sNo":2.002,"name":"Irrigation Line 2","connectionNo":null,"objectName":"Irrigation Line","type":"-","controllerId":null,"count":null,"source":[],"sourcePump":[{"objectId":5,"sNo":5.001,"name":"Pump 1","connectionNo":null,"objectName":"Pump","type":"1,2","controllerId":null,"count":null}],"irrigationPump":[{"objectId":5,"sNo":5.002,"name":"Pump 2","connectionNo":null,"objectName":"Pump","type":"1,2","controllerId":null,"count":null},{"objectId":5,"sNo":5.003,"name":"Pump 3","connectionNo":null,"objectName":"Pump","type":"1,2","controllerId":null,"count":null},{"objectId":5,"sNo":5.004,"name":"Pump 4","connectionNo":null,"objectName":"Pump","type":"1,2","controllerId":null,"count":null}],"centralFiltration":{"objectId":4,"sNo":4.001,"name":"Filtration Site 1","connectionNo":null,"objectName":"Filtration Site","type":"-","controllerId":null,"count":null},"localFiltration":{},"centralFertilization":{},"localFertilization":{},"valve":[{"objectId":13,"sNo":13.005,"name":"Valve 5","connectionNo":null,"objectName":"Valve","type":"1,2","controllerId":null,"count":null},{"objectId":13,"sNo":13.006,"name":"Valve 6","connectionNo":null,"objectName":"Valve","type":"1,2","controllerId":null,"count":null},{"objectId":13,"sNo":13.007,"name":"Valve 7","connectionNo":null,"objectName":"Valve","type":"1,2","controllerId":null,"count":null},{"objectId":13,"sNo":13.008,"name":"Valve 8","connectionNo":null,"objectName":"Valve","type":"1,2","controllerId":null,"count":null}],"mainValve":[],"fan":[],"fogger":[],"pesticides":[],"heater":[],"screen":[],"vent":[],"powerSupply":{},"pressureSwitch":{},"waterMeter":{},"pressureIn":{},"pressureOut":{},"moisture":[],"temperature":[],"soilTemperature":[],"humidity":[],"co2":[]}]}*/
/*
{"filterSite":[{"objectId":4,"sNo":4.001,"name":"Filtration Site 1","connectionNo":null,"objectName":"Filtration Site","type":"-","controllerId":null,"count":null,"siteMode":2,"filters":[{"objectId":11,"sNo":11.001,"name":"Filter 1","connectionNo":null,"objectName":"Filter","type":"1,2","controllerId":null,"count":null},{"objectId":11,"sNo":11.002,"name":"Filter 2","connectionNo":null,"objectName":"Filter","type":"1,2","controllerId":null,"count":null},{"objectId":11,"sNo":11.003,"name":"Filter 3","connectionNo":null,"objectName":"Filter","type":"1,2","controllerId":null,"count":null},{"objectId":11,"sNo":11.004,"name":"Filter 4","connectionNo":null,"objectName":"Filter","type":"1,2","controllerId":null,"count":null}],"pressureIn":{},"pressureOut":{},"backWashValve":{}}],"fertilizerSite":[{"objectId":3,"sNo":3.001,"name":"Dosing Site 1","connectionNo":null,"objectName":"Dosing Site","type":"-","controllerId":null,"count":null,"siteMode":1,"channel":[{"objectId":10,"sNo":10.001,"name":"Injector 1","connectionNo":null,"objectName":"Injector","type":"1,2","controllerId":null,"count":null},{"objectId":10,"sNo":10.002,"name":"Injector 2","connectionNo":null,"objectName":"Injector","type":"1,2","controllerId":null,"count":null},{"objectId":10,"sNo":10.003,"name":"Injector 3","connectionNo":null,"objectName":"Injector","type":"1,2","controllerId":null,"count":null},{"objectId":10,"sNo":10.004,"name":"Injector 4","connectionNo":null,"objectName":"Injector","type":"1,2","controllerId":null,"count":null}],"boosterPump":[{"objectId":7,"sNo":7.001,"name":"Booster Pump 1","connectionNo":null,"objectName":"Booster Pump","type":"1,2","controllerId":null,"count":null}],"agitator":[{"objectId":9,"sNo":9.001,"name":"Agitator 1","connectionNo":null,"objectName":"Agitator","type":"1,2","controllerId":null,"count":null}],"selector":[],"ec":[],"ph":[]}],"waterSource":[{"objectId":1,"sNo":1.001,"name":"Source 1","connectionNo":null,"objectName":"Source","type":"-","controllerId":null,"count":null,"sourceType":{},"level":{},"topFloat":{},"bottomFloat":{},"inletPump":[],"outletPump":[{"objectId":5,"sNo":5.001,"name":"Pump 1","connectionNo":null,"objectName":"Pump","type":"1,2","controllerId":null,"count":null}],"valves":[]},{"objectId":1,"sNo":1.002,"name":"Source 2","connectionNo":null,"objectName":"Source","type":"-","controllerId":null,"count":null,"sourceType":{},"level":{},"topFloat":{},"bottomFloat":{},"inletPump":[{"objectId":5,"sNo":5.001,"name":"Pump 1","connectionNo":null,"objectName":"Pump","type":"1,2","controllerId":null,"count":null},{"objectId":5,"sNo":5.002,"name":"Pump 2","connectionNo":null,"objectName":"Pump","type":"1,2","controllerId":null,"count":null}],"outletPump":[{"objectId":5,"sNo":5.003,"name":"Pump 3","connectionNo":null,"objectName":"Pump","type":"1,2","controllerId":null,"count":null}],"valves":[]},{"objectId":1,"sNo":1.003,"name":"Source 3","connectionNo":null,"objectName":"Source","type":"-","controllerId":null,"count":null,"sourceType":{},"level":{},"topFloat":{},"bottomFloat":{},"inletPump":[],"outletPump":[{"objectId":5,"sNo":5.002,"name":"Pump 2","connectionNo":null,"objectName":"Pump","type":"1,2","controllerId":null,"count":null}],"valves":[]}],"pump":[{"objectId":5,"sNo":5.001,"name":"Pump 1","connectionNo":null,"objectName":"Pump","type":"1,2","controllerId":null,"count":null,"level":{},"pressure":{},"waterMeter":{},"pumpType":{}},{"objectId":5,"sNo":5.002,"name":"Pump 2","connectionNo":null,"objectName":"Pump","type":"1,2","controllerId":null,"count":null,"level":{},"pressure":{},"waterMeter":{},"pumpType":{}},{"objectId":5,"sNo":5.003,"name":"Pump 3","connectionNo":null,"objectName":"Pump","type":"1,2","controllerId":null,"count":null,"level":{},"pressure":{},"waterMeter":{},"pumpType":{}}],"moistureSensor":[],"irrigationLine":[{"objectId":2,"sNo":2.001,"name":"Irrigation Line 1","connectionNo":null,"objectName":"Irrigation Line","type":"-","controllerId":null,"count":null,"source":[],"sourcePump":[{"objectId":5,"sNo":5.001,"name":"Pump 1","connectionNo":null,"objectName":"Pump","type":"1,2","controllerId":null,"count":null},{"objectId":5,"sNo":5.002,"name":"Pump 2","connectionNo":null,"objectName":"Pump","type":"1,2","controllerId":null,"count":null}],"irrigationPump":[{"objectId":5,"sNo":5.003,"name":"Pump 3","connectionNo":null,"objectName":"Pump","type":"1,2","controllerId":null,"count":null}],"centralFiltration":{"objectId":4,"sNo":4.001,"name":"Filtration Site 1","connectionNo":null,"objectName":"Filtration Site","type":"-","controllerId":null,"count":null},"localFiltration":{},"centralFertilization":{"objectId":3,"sNo":3.001,"name":"Dosing Site 1","connectionNo":null,"objectName":"Dosing Site","type":"-","controllerId":null,"count":null},"localFertilization":{},"valve":[{"objectId":13,"sNo":13.001,"name":"Valve 1","connectionNo":null,"objectName":"Valve","type":"1,2","controllerId":null,"count":null},{"objectId":13,"sNo":13.002,"name":"Valve 2","connectionNo":null,"objectName":"Valve","type":"1,2","controllerId":null,"count":null},{"objectId":13,"sNo":13.003,"name":"Valve 3","connectionNo":null,"objectName":"Valve","type":"1,2","controllerId":null,"count":null},{"objectId":13,"sNo":13.004,"name":"Valve 4","connectionNo":null,"objectName":"Valve","type":"1,2","controllerId":null,"count":null},{"objectId":13,"sNo":13.005,"name":"Valve 5","connectionNo":null,"objectName":"Valve","type":"1,2","controllerId":null,"count":null},{"objectId":13,"sNo":13.006,"name":"Valve 6","connectionNo":null,"objectName":"Valve","type":"1,2","controllerId":null,"count":null},{"objectId":13,"sNo":13.007,"name":"Valve 7","connectionNo":null,"objectName":"Valve","type":"1,2","controllerId":null,"count":null},{"objectId":13,"sNo":13.008,"name":"Valve 8","connectionNo":null,"objectName":"Valve","type":"1,2","controllerId":null,"count":null},{"objectId":13,"sNo":13.009,"name":"Valve 9","connectionNo":null,"objectName":"Valve","type":"1,2","controllerId":null,"count":null},{"objectId":13,"sNo":13.01,"name":"Valve 10","connectionNo":null,"objectName":"Valve","type":"1,2","controllerId":null,"count":null}],"mainValve":[{"objectId":14,"sNo":14.001,"name":"Main Valve 1","connectionNo":null,"objectName":"Main Valve","type":"1,2","controllerId":null,"count":null},{"objectId":14,"sNo":14.002,"name":"Main Valve 2","connectionNo":null,"objectName":"Main Valve","type":"1,2","controllerId":null,"count":null}],"fan":[],"fogger":[],"pesticides":[],"heater":[],"screen":[],"vent":[],"powerSupply":{},"pressureSwitch":{},"waterMeter":{},"pressureIn":{},"pressureOut":{},"moisture":[],"temperature":[],"soilTemperature":[],"humidity":[],"co2":[]}]}*/
