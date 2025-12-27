//  Manufacturer Model


class Manufacturer {
  // Properties
  int? id;
  final String mName;

  // Constructor
  Manufacturer({this.id, required this.mName});

  Manufacturer.fromMap(Map<String, Object?> map)
    : id = map['id'] as int?,
      mName = map['mName'] as String;

  Map<String, Object?> toMap({bool includeId = false}) {
    final map = <String, Object?>{'mName': mName};

    if (includeId) {
      map['id'] = id;
    }

    return map;
  }

  static const List<String> keys = ['id', 'mName'];
}
