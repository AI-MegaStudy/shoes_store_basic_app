//  PurchaseItem Model


class PurchaseItem {
  //  Properties

  int? id;
  int pid; //  Product id
  int pcid; //  Purchase id

  int pcQuantity; //  Purchase Item Quantity
  String pcStatus;  //  config.pickupStatus의 value(한글 문자열)만 사용: '제품 준비 중', '제품 준비 완료', '제품 수령 완료', '반품 신청', '반품 처리 중', '반품 완료'



  // Constructor
  PurchaseItem({
    this.id,
    required this.pid,
    required this.pcid,
    required this.pcQuantity,
    required this.pcStatus  //  
  });

  PurchaseItem.fromMap(Map<String, Object?> map)
    : id = map['id'] as int?,
      pid = map['pid'] as int,
      pcid = map['pcid'] as int,
      pcQuantity = map['pcQuantity'] as int,
      pcStatus = map['pcStatus'] as String;

  //  Point 2
  Map<String, Object?> toMap({bool includeId = false}) {
    final map = <String, Object?>{
      'pid': pid,
      'pcid': pcid,
      'pcQuantity': pcQuantity,
      'pcStatus': pcStatus
    };

    if (includeId) {
      map['id'] = id;
    }

    return map;
  }

  static const List<String> keys = ['id', 'pid', 'pcid', 'pcQuantity', 'pcStatus'];
}