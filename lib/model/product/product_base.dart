//  ProductBase Model


class ProductBase {
  // Properties
  int? id;
  final String pName;
  final String pDescription;
  final String pColor;
  final String pGender;
  final String pStatus; //  active, coming soon, inactive etc
  final String pCategory; //  sneakers, sandals, boots
  final String pModelNumber;

  // Constructor
  ProductBase({
    this.id,
    required this.pName,
    required this.pDescription,
    required this.pColor,
    required this.pGender,
    required this.pStatus,
    required this.pCategory,
    required this.pModelNumber,
  });

  ProductBase.fromMap(Map<String, Object?> map)
    : id = map['id'] as int?,
      pName = map['pName'] as String,
      pDescription = map['pDescription'] as String,
      pColor = map['pColor'] as String,
      pGender = map['pGender'] as String,
      pStatus = map['pStatus'] as String,
      pCategory = map['pCategory'] as String,
      pModelNumber = map['pModelNumber'] as String;

  Map<String, Object?> toMap({bool includeId = false}) {
    final map = <String, Object?>{
      'pName': pName,
      'pDescription': pDescription,
      'pColor': pColor,
      'pGender': pGender,
      'pStatus': pStatus,
      'pCategory': pCategory,
      'pModelNumber': pModelNumber,
    };

    if (includeId) {
      map['id'] = id;
    }

    return map;
  }

  static const List<String> keys = [
    'id',
    'pName',
    'pDescription',
    'pColor',
    'pGender',
    'pStatus',
    'pCategory',
    'pModelNumber',
  ];
}
