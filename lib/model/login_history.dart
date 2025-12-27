//  LoginHistory Model


class LoginHistory {
  // Properties
  int? id;
  int? cid; //  Customer ID
  final String loginTime;
  final String lStatus;
  final String lAddress;
  final String lPaymentMethod;

  // Constructor
  LoginHistory({
    this.id,
    this.cid,
    required this.loginTime,
    required this.lStatus,
    required this.lAddress,
    required this.lPaymentMethod,
  });

  LoginHistory.fromMap(Map<String, Object?> map)
    : id = map['id'] as int?,
      cid = map['cid'] as int?,
      loginTime = map['loginTime'] as String,
      lStatus = map['lStatus'] as String,
      lAddress = map['lAddress'] as String,
      lPaymentMethod = map['lPaymentMethod'] as String;

  Map<String, Object?> toMap({bool includeId = false}) {
    final map = <String, Object?>{
      'cid': cid,
      'loginTime': loginTime,
      'lStatus': lStatus,
      'lAddress': lAddress,
      'lPaymentMethod': lPaymentMethod,
    };

    if (includeId) {
      map['id'] = id;
    }

    return map;
  }

  static const List<String> keys = [
    'id',
    'cid',
    'loginTime',
    'lStatus',
    'lAddress',
    'lPaymentMethod',
  ];
}
