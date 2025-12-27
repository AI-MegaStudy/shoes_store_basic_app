//  ProductImage Model


class ProductImage {
  // Properties
  int? id;
  int? pbid; //  ProductBase id
  final String imagePath;

  // Constructor
  ProductImage({this.id, required this.pbid, required this.imagePath});

  ProductImage.fromMap(Map<String, Object?> map)
    : id = map['id'] as int?,
      pbid = map['pbid'] as int?,
      imagePath = map['imagePath'] as String;

  //  Point 1
  Map<String, Object?> toMap({bool includeId = false}) {
    final map = <String, Object?>{'pbid': pbid, 'imagePath': imagePath};

    if (includeId) {
      map['id'] = id;
    }

    return map;
  }

  static const List<String> keys = ['id', 'pbid', 'imagePath'];
}
