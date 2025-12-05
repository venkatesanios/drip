class CustomerListModel
{
  CustomerListModel({
    this.id = 0,
    this.name = '',
    this.countryCode = '',
    this.mobileNumber = '',
    this.emailId = '',
    this.serviceRequestCount = 0,
    this.criticalAlarmCount = 0,
  });

  int id,serviceRequestCount,criticalAlarmCount;
  String name, countryCode, mobileNumber, emailId;

  factory CustomerListModel.fromJson(Map<String, dynamic> json) => CustomerListModel(
    id: json['userId'],
    name: json['userName'],
    countryCode: json['countryCode'],
    mobileNumber: json['mobileNumber'],
    emailId: json['emailId'],
    serviceRequestCount: json['serviceRequestCount'],
    criticalAlarmCount: json['criticalAlarmCount'],
  );

  factory CustomerListModel.fake() {
    return CustomerListModel(
      id: 0,
      name: 'Loading...',
      emailId: 'loading@example.com',
      mobileNumber: '0000000000',
      countryCode: '00',
    );
  }

  Map<String, dynamic> toJson() => {
    'userId': id,
    'userName': name,
    'countryCode': countryCode,
    'mobileNumber': mobileNumber,
    'emailId': emailId,
    'serviceRequestCount': serviceRequestCount,
    'criticalAlarmCount': criticalAlarmCount,
  };
}