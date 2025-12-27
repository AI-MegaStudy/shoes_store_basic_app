//  Customer Model


class Customer {
  // Properties
  int? id;
  final String cEmail;
  final String cPhoneNumber;
  final String cName;
  final String cPassword;

  // Constructor
  Customer({
    this.id,
    required this.cEmail,
    required this.cPhoneNumber,
    required this.cName,
    required this.cPassword,
  });

  Customer.fromMap(Map<String, Object?> map)
    : id = map['id'] as int?,
      cEmail = map['cEmail'] as String,
      cPhoneNumber = map['cPhoneNumber'] as String,
      cName = map['cName'] as String,
      cPassword = map['cPassword'] as String;

  Map<String, Object?> toMap({bool includeId = false}) {
    final map = <String, Object?>{
      'cEmail': cEmail,
      'cPhoneNumber': cPhoneNumber,
      'cName': cName,
      'cPassword': cPassword,
    };

    if (includeId) {
      map['id'] = id;
    }

    return map;
  }

  static const List<String> keys = [
    'id',
    'cEmail',
    'cPhoneNumber',
    'cName',
    'cPassword',
  ];
}
