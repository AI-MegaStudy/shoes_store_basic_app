//  Purchase Model


class Purchase {
  //  Properties
  int? id;

  int? cid; //  Customer id
  final String pickupDate;  //  Pickupdate default is Purchasedate +1 dummy for now
  final String orderCode; //  Client's request
  final String timeStamp; //  Purchased time

  // Constructor
  Purchase({
    this.id,
    required this.cid,
    required this.pickupDate,
    required this.orderCode,
    required this.timeStamp
  });

  Purchase.fromMap(Map<String, Object?> map)
    : id = map['id'] as int?,
      cid = map['cid'] as int?,
      pickupDate = map['pickupDate'] as String,
      orderCode = map['orderCode'] as String,
      timeStamp = map['timeStamp'] as String;

      Map<String, Object?> toMap({bool includeId = false}) {
    final map = <String, Object?>{
      'cid': cid,
      'pickupDate': pickupDate,
      'orderCode': orderCode,
      'timeStamp': timeStamp
    };

    if (includeId) {
      map['id'] = id;
    }

    return map;
  }
  static const List<String> keys = ['id', 'cid', 'pickupDate', 'orderCode', 'timeStamp'];
}
