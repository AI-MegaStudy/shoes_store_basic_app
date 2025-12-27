//  Customer Model

class Employee {
  // Properties
  int? id;
  final String eEmail;
  final String ePhoneNumber;
  final String eName;
  final String ePassword;
  final String eRole;

  // Constructor
  Employee({
    this.id,
    required this.eEmail,
    required this.ePhoneNumber,
    required this.eName,
    required this.ePassword,
    //  Point 1
    required this.eRole
  });

  Employee.fromMap(Map<String, Object?> map)
    : id = map['id'] as int?,
      eEmail = map['eEmail'] as String,
      ePhoneNumber = map['ePhoneNumber'] as String,
      eName = map['eName'] as String,
      ePassword = map['ePassword'] as String,
      eRole = map['eRole'] as String;

  Map<String, Object?> toMap({bool includeId = false}) {
    final map = <String, Object?>{
      'eEmail': eEmail,
      'ePhoneNumber': ePhoneNumber,
      'eName': eName,
      'ePassword': ePassword,
      'eRole': eRole,
    };

    if (includeId) {
      map['id'] = id;
    }

    return map;
  }

  static const List<String> keys = [
    'id',
    'eEmail',
    'ePhoneNumber',
    'eName',
    'ePassword',
    'eRole'
  ];
}
