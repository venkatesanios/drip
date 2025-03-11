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

  Future<http.Response> fetchMasterControllerDetails(body) async {
    return await apiService.postRequest('/user/deviceList/getMasterDetails', body);
  }

  Future<http.Response> fetchSubUserList(body) async {
    return await apiService.postRequest('/user/sharedUser/get', body);
  }

  Future<http.Response> fetchUserPushNotificationType(body) async {
    return await apiService.postRequest('/user/deviceList/pushNotificationType/get', body);
  }

  Future<http.Response> fetchCountryList() async {
    return await apiService.getRequest('/country/get');
  }

  Future<http.Response> fetchStateList(countryId) async {
    return await apiService.getRequest('/state/get/$countryId');
  }

  Future<http.Response> fetchSentAndReceivedData(body) async {
    return await apiService.postRequest('/user/sentAndReceivedMessage/getStatus', body);
  }

  Future<http.Response> fetchSentAndReceivedHardwarePayload(body) async {
    return await apiService.postRequest('/user/sentAndReceivedMessage/getHardwarePayload', body);
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

  Future<http.Response> createNewMaster(body) async {
    return await apiService.postRequest('/user/deviceList/createWithGroup', body);
  }

  Future<http.Response> fetchAllMySite(body) async {
     return await apiService.postRequest('/user/dashboard', body);
  }
  Future<http.Response> getUserFilterBackwasing(body) async {
    return await apiService.postRequest('/user/planning/filterBackwashing/get', body);
  }

  Future<http.Response> UpdateFilterBackwasing(body) async {
    return await apiService.postRequest('/user/planning/filterBackwashing/create', body);
  }
  Future<http.Response> getUserwaterSource(body) async {
    return await apiService.postRequest('/user/planning/waterSource/get', body);
  }
  Future<http.Response> UpdatewaterSource(body) async {
    return await apiService.postRequest('/user/planning/waterSource/create', body);
  }
  Future<http.Response> getUservirtualwatermeter(body) async {
    return await apiService.postRequest('/user/planning/virtualwatermeter/get', body);
  }
  Future<http.Response> Updatevirtualwatermeter(body) async {
    return await apiService.postRequest('/user/planning/virtualwatermeter/create', body);
  }
  Future<http.Response> getUserfrostProtection(body) async {
    return await apiService.postRequest('/user/planning/frostProtectionAndRainDelay/get', body);
  }
  Future<http.Response> UpdatefrostProtection(body) async {
    return await apiService.postRequest('/user/planning/frostProtectionAndRainDelay/create', body);
  }


  ///Todo: Program urls
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

  Future<http.Response> getUserProgramWaterAndFert(body) async {
    return await apiService.postRequest('/user/program/waterAndFert/get', body);
  }

  Future<http.Response> getProgramLibraryData(body) async {
    return await apiService.postRequest('/user/program/getLibrary', body);
  }

  Future<http.Response> createUserProgram(body) async {
    return await apiService.postRequest('/user/program/create', body);
  }

  Future<http.Response> inactiveUserProgram(body) async {
    return await apiService.putRequest('/user/program/inactive', body);
  }

  Future<http.Response> activeUserProgram(body) async {
    return await apiService.putRequest('/user/program/active', body);
  }

  Future<http.Response> deleteUserProgram(body) async {
    return await apiService.putRequest('/user/program/delete', body);
  }

  Future<http.Response> createProgramFromCopy(body) async {
    return await apiService.postRequest('/user/program/createFromCopy', body);
  }

  Future<http.Response> updateProgramDetails(body) async {
    return await apiService.putRequest('/user/program/updateDetails', body);
  }


  ///Todo: Preference urls
  Future<http.Response> getUserPreferenceSetting(body) async {
    return await apiService.postRequest('/user/preference/setting/get', body);
  }

  Future<http.Response> getUserPreferenceGeneral(body) async {
    return await apiService.postRequest('/user/preference/general/get', body);
  }

  Future<http.Response> getUserPreferenceCalibration(body) async {
    return await apiService.postRequest('/user/preference/calibration/get', body);
  }

  Future<http.Response> getUserPreferenceNotification(body) async {
    return await apiService.postRequest('/user/preference/notification/get', body);
  }

  Future<http.Response> createUserPreference(body) async {
    return await apiService.postRequest('/user/preference/create', body);
  }

  Future<http.Response> checkPassword(body) async {
    return await apiService.postRequest('/user/check', body);
  }


  ///Todo: System definition urls
  Future<http.Response> getUserPlanningSystemDefinition(body) async {
    return await apiService.postRequest('/user/planning/systemDefinition/get', body);
  }

  Future<http.Response> createUserPlanningSystemDefinition(body) async {
    return await apiService.postRequest('/user/planning/systemDefinition/create', body);
  }


  ///Todo: Other planning urls
  Future<http.Response> getUserPlanningValveGroup(body) async {
    return await apiService.postRequest('/user/planning/valveGroup/get', body);
  }


  Future<http.Response> fetchCustomerProgramList(body) async {
    return await apiService.postRequest('/user/program/getNameList', body);
  }

  Future<http.Response> fetchUserManualOperation(body) async {
    return await apiService.postRequest('/user/manualOperation/recent/get', body);
  }
  Future<http.Response> getUserValveGroup(body) async {
    return await apiService.postRequest('/user/planning/valveGroup/get', body);
  }
  Future<http.Response> createUserValveGroup(body) async {
    return await apiService.postRequest('/user/planning/valveGroup/create', body);
  }
  Future<http.Response> fetchStandAloneData(body) async {
    return await apiService.postRequest('/user/getUserDashboardByManual', body);
  }

  Future<http.Response> fetchManualOperation(body) async {
    return await apiService.postRequest('/user/manualOperation/get', body);
  }

  Future<http.Response> updateStandAloneData(body) async {
    return await apiService.postRequest('/user/manualOperation/create', body);
  }

  ///Todo: Other urls
  Future<http.Response> getPlanningHiddenMenu(body) async {
    return await apiService.postRequest('/user/dealerDefinition/mainMenu/get', body);
  }

}

