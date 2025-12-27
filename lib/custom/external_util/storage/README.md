# CustomStorageUtil

로컬 스토리지 유틸리티 클래스입니다. SharedPreferences를 래핑하여 간편하게 사용할 수 있습니다.

## 주요 기능

- 타입 안전한 저장/불러오기 (String, int, bool, double)
- 객체 저장/불러오기 (JSON 직렬화/역직렬화)
- 리스트 저장/불러오기
- 키 삭제 및 전체 삭제
- 키 존재 여부 확인

## 의존성

```yaml
dependencies:
  shared_preferences: ^2.2.2
```

## 초기화

앱 시작 시 한 번만 호출해야 합니다.

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await CustomStorageUtil.init();
  runApp(MyApp());
}
```

## 기본 사용법

### 기본 타입 저장/불러오기

```dart
// 저장
await CustomStorageUtil.setString('username', '홍길동');
await CustomStorageUtil.setInt('age', 25);
await CustomStorageUtil.setBool('isDarkMode', true);
await CustomStorageUtil.setDouble('price', 99.99);
await CustomStorageUtil.setStringList('tags', ['flutter', 'dart']);

// 불러오기
final username = await CustomStorageUtil.getString('username');
final age = await CustomStorageUtil.getInt('age');
final isDarkMode = await CustomStorageUtil.getBool('isDarkMode');
final price = await CustomStorageUtil.getDouble('price');
final tags = await CustomStorageUtil.getStringList('tags');
```

### 객체 저장/불러오기

```dart
// User 클래스 정의
class User {
  final String name;
  final int age;
  final String email;

  User({required this.name, required this.age, required this.email});

  Map<String, dynamic> toJson() => {
    'name': name,
    'age': age,
    'email': email,
  };

  factory User.fromJson(Map<String, dynamic> json) => User(
    name: json['name'] as String,
    age: json['age'] as int,
    email: json['email'] as String,
  );
}

// 저장
final user = User(name: '홍길동', age: 25, email: 'hong@example.com');
await CustomStorageUtil.setObject('user', user);

// 불러오기
final savedUser = await CustomStorageUtil.getObject<User>(
  'user',
  (json) => User.fromJson(json),
);
```

### 리스트 저장/불러오기

```dart
// Item 클래스 정의
class Item {
  final String name;
  final int price;

  Item({required this.name, required this.price});

  Map<String, dynamic> toJson() => {
    'name': name,
    'price': price,
  };

  factory Item.fromJson(Map<String, dynamic> json) => Item(
    name: json['name'] as String,
    price: json['price'] as int,
  );
}

// 저장
final items = [
  Item(name: '사과', price: 1000),
  Item(name: '바나나', price: 2000),
];
await CustomStorageUtil.setList('items', items);

// 불러오기
final savedItems = await CustomStorageUtil.getList<Item>(
  'items',
  (json) => Item.fromJson(json),
);
```

## 유틸리티 메서드

### 키 삭제

```dart
await CustomStorageUtil.remove('username');
```

### 모든 데이터 삭제

```dart
await CustomStorageUtil.clear();
```

### 키 존재 여부 확인

```dart
final exists = await CustomStorageUtil.containsKey('username');
```

### 모든 키 가져오기

```dart
final keys = await CustomStorageUtil.getAllKeys();
```

## 주요 사용 사례

- 사용자 설정 저장 (다크모드, 언어 설정 등)
- 로그인 정보 저장 (토큰, 사용자 정보)
- 캐시 데이터 저장
- 앱 상태 저장

## 예제

자세한 사용 예제는 `example.dart` 파일을 참고하세요.
