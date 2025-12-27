import 'package:shoes_store_basic_app/config.dart' as config;
import 'package:shoes_store_basic_app/database/handlers/manufacturer_handler.dart';
import 'package:shoes_store_basic_app/database/handlers/product_base_handler.dart';
import 'package:shoes_store_basic_app/database/handlers/product_handler.dart';
import 'package:shoes_store_basic_app/model/product/manufacturer.dart';
import 'package:shoes_store_basic_app/model/product/product.dart';
import 'package:shoes_store_basic_app/model/product/product_base.dart';
import 'package:shoes_store_basic_app/model/product/product_image.dart';
import 'package:shoes_store_basic_app/view/cheng/storage/cart_storage.dart';
import 'package:shoes_store_basic_app/custom/custom_snack_bar.dart';
import 'package:shoes_store_basic_app/custom/util/navigation/custom_navigation_util.dart';
import 'package:shoes_store_basic_app/custom/custom_common_util.dart';
import 'package:shoes_store_basic_app/theme/app_colors.dart';
import 'package:flutter/material.dart';

/// 제품 상세 화면
/// 
/// 제품의 상세 정보를 표시하고, 색상과 사이즈를 선택하여 장바구니에 담을 수 있는 화면입니다.
class DetailView extends StatefulWidget {
  const DetailView({super.key});

  @override
  State<DetailView> createState() => _DetailViewState();
}

class _DetailViewState extends State<DetailView> {
  // 데이터베이스 핸들러
  final _productHandler = ProductHandler();
  final _productBaseHandler = ProductBaseHandler();
  final _manufacturerHandler = ManufacturerHandler();

  // 제품 데이터
  Product? product;
  List<Product>? productSizes;
  ProductBase? productBase;
  List<ProductBase>? productColors; // 같은 모델번호의 ProductBase들(=색상 옵션)
  List<String>? pbColors;
  ProductImage? productImage;
  Manufacturer? manufacturer;

  // UI 상태
  int selectedColorIndex = 0;
  int selectedSizeIndex = 0; // 선택된 사이즈 인덱스
  int quantity = 1;
  bool switching = false; // 색상 전환 중 플래그

  /// 장바구니에서 현재 제품의 수량을 가져옵니다.
  /// 
  /// 현재 선택된 product의 productId로 장바구니에서 해당 제품의 수량을 찾습니다.
  /// 장바구니에 없으면 0을 반환합니다.
  int _getCartQuantity() {
    if (product?.id == null) return 0;
    
    final cart = CartStorage.getCart();
    
    final idx = cart.indexWhere(
      (e) => e['productId'] == product!.id,
    );
    
    if (idx >= 0) {
      return _asInt(cart[idx]['quantity'], 0);
    }
    return 0;
  }

  /// 동적 값을 int로 변환하는 헬퍼 메서드
  int _asInt(dynamic v, [int def = 0]) {
    if (v == null) return def;
    if (v is int) return v;
    if (v is num) return v.toInt();
    if (v is String) return int.tryParse(v) ?? def;
    return def;
  }

  /// 현재 선택된 제품의 실제 구매 가능한 최대 수량
  /// 
  /// 제품 재고에서 장바구니에 담긴 수량을 뺀 값을 반환합니다.
  /// 주의: 이 메서드는 캐시된 product.pQuantity를 사용하므로,
  /// 최신 재고를 확인하려면 _getMaxQuantityFromDb()를 사용하세요.
  /// product가 null이면 0을 반환합니다.
  int get maxQuantity {
    final stock = product?.pQuantity ?? 0;
    final cartQty = _getCartQuantity();
    return (stock - cartQty).clamp(0, stock);
  }

  /// DB에서 최신 재고를 조회하여 구매 가능한 최대 수량을 계산합니다.
  /// 
  /// 장바구니에 담을 때마다 호출하여 실시간 재고를 반영합니다.
  /// [productId] 조회할 제품 ID
  /// 반환값: 구매 가능한 최대 수량
  Future<int> _getMaxQuantityFromDb(int productId) async {
    try {
      // DB에서 최신 재고 조회
      final latestProduct = await _productHandler.queryById(productId);
      if (latestProduct == null) return 0;

      // 장바구니에 담긴 수량 확인
      final cartQty = _getCartQuantity();
      
      // 최신 재고에서 장바구니 수량을 뺀 값
      final availableQty = (latestProduct.pQuantity - cartQty).clamp(0, latestProduct.pQuantity);
      
      // 캐시된 product도 업데이트 (선택사항)
      if (product?.id == productId) {
        product = latestProduct;
      }
      
      return availableQty;
    } catch (e) {
      print('재고 조회 실패 (productId: $productId): $e');
      // 실패 시 캐시된 값 사용
      return maxQuantity;
    }
  }

  /// 구매 가능 여부 확인
  /// 
  /// 재고가 있고, 장바구니에 담긴 수량이 재고보다 적으면 true를 반환합니다.
  bool get canPurchase {
    return maxQuantity > 0;
  }

  bool _initialized = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      _initData();
      _initialized = true;
    } else {
      // 페이지가 다시 포커스될 때 장바구니 변경사항 확인
      _updateQuantityFromCart();
    }
  }

  /// 장바구니 변경 감지 및 수량 업데이트
  /// 
  /// 페이지가 다시 포커스될 때마다 호출되어 장바구니 변경사항을 반영합니다.
  void _updateQuantityFromCart() {
    if (!mounted || product == null) return;
    
    // DB에서 최신 재고 조회하여 정확한 최대 수량 계산
    final productId = product!.id;
    if (productId == null) return;
    
    // 비동기로 최신 재고 조회
    _productHandler.queryById(productId).then((latestProduct) {
      if (!mounted || latestProduct == null) return;
      
      // 장바구니에 담긴 수량 확인
      final cartQty = _getCartQuantity();
      
      // 최신 재고에서 장바구니 수량을 뺀 값
      final availableQty = (latestProduct.pQuantity - cartQty).clamp(0, latestProduct.pQuantity);
      
      // 캐시된 product 업데이트
      if (product?.id == productId) {
        setState(() {
          product = latestProduct;
          
          // 수량이 최대 수량을 초과하면 제한
          if (quantity > availableQty && availableQty > 0) {
            quantity = availableQty;
          } else if (availableQty == 0 && quantity > 0) {
            quantity = 1;
          }
        });
      }
    }).catchError((e) {
      // 에러 발생 시 기존 로직 사용
      if (mounted) {
        setState(() {
          // 수량이 최대 수량을 초과하면 제한
          if (quantity > maxQuantity && maxQuantity > 0) {
            quantity = maxQuantity;
          } else if (maxQuantity == 0 && quantity > 0) {
            quantity = 1;
          }
        });
      }
    });
  }

  /// 초기 데이터 로드
  /// 
  /// 전달받은 ProductBase ID를 기반으로 제품 정보를 로드합니다.
  Future<void> _initData() async {
    final int? pbidArg = ModalRoute.of(context)?.settings.arguments as int?;
    if (pbidArg == null) {
      // arguments가 없으면 이전 화면으로 돌아감
      WidgetsBinding.instance.addPostFrameCallback((_) {
        CustomNavigationUtil.back(context);
      });
      return;
    }

    // 현재 ProductBase 조회
    productBase = await _productBaseHandler.queryById(pbidArg);
    if (productBase == null) return;

    // 같은 모델번호의 모든 색상 옵션 조회
    final allProductBases = await _productBaseHandler.queryAll();
    productColors = allProductBases
        .where((pb) => pb.pModelNumber == productBase!.pModelNumber)
        .toList();
    pbColors = productColors!.map((e) => e.pColor).toList();

    // 현재 ProductBase의 색상 인덱스 찾기
    selectedColorIndex = pbColors!.indexOf(productBase!.pColor);
    if (selectedColorIndex < 0) selectedColorIndex = 0;

    // 초기 색상 적용
    await _applyColor(productColors![selectedColorIndex], setChipIndex: false);

    setState(() {});
  }

  /// 색상 선택 시 처리
  /// 
  /// 선택한 색상의 ProductBase로 교체하고, 연관된 제품 정보(Product, 이미지, 제조사, 사이즈)를 다시 로드합니다.
  /// [newPB] 선택한 색상의 ProductBase
  /// [setChipIndex] Chip 인덱스를 업데이트할지 여부
  Future<void> _applyColor(
    ProductBase newPB, {
    bool setChipIndex = true,
  }) async {
    if (switching) return;

    setState(() => switching = true);

    productBase = newPB;
    final pbid = newPB.id;
    if (pbid == null) {
      setState(() => switching = false);
      return;
    }

    // ProductBase별 제품 목록 + ProductBase 정보 조인 조회 (최적화)
    final productsWithBase = await _productHandler.queryListWithBase(pbid);
    if (productsWithBase.isNotEmpty) {
      // Product 객체로 변환
      productSizes = productsWithBase.map((map) => Product.fromMap(map)).toList();
      
      // 선택된 사이즈 인덱스가 유효한지 확인
      if (selectedSizeIndex >= productSizes!.length) {
        selectedSizeIndex = 0;
      }
      product = productSizes![selectedSizeIndex]; // 선택된 사이즈의 제품 사용
      
      // 수량이 최대 수량(재고 - 장바구니 수량)을 초과하면 최대 수량으로 제한
      // setState 전에 product가 설정되어야 하므로 여기서는 직접 계산
      final stock = product?.pQuantity ?? 0;
      final cartQty = _getCartQuantity();
      final availableQty = (stock - cartQty).clamp(0, stock);
      if (quantity > availableQty) {
        quantity = availableQty > 0 ? availableQty : 1;
      }

      // 제품 이미지 조회 (ProductBase + 이미지 목록 조인 조회 최적화)
      final productWithImages = await _productBaseHandler.queryWithImages(pbid);
      if (productWithImages != null) {
        final images = productWithImages['images'] as List<dynamic>?;
        if (images != null && images.isNotEmpty) {
          final firstImagePath = images.first as String;
          productImage = ProductImage(
            id: null,
            pbid: pbid,
            imagePath: firstImagePath,
          );
        }
      }

      // 제조사 정보 조회 (Product에 mfid가 있으면)
      if (product != null && product!.mfid != null) {
        manufacturer = await _manufacturerHandler.queryById(product!.mfid!);
      }
    }

    // Chip 인덱스 업데이트
    if (setChipIndex && pbColors != null) {
      final idx = pbColors!.indexOf(newPB.pColor);
      if (idx >= 0) selectedColorIndex = idx;
    }

    // 수량 리셋 (최대 수량을 초과하지 않도록)
    // product가 이미 업데이트된 후이므로 maxQuantity를 사용할 수 있음
    quantity = 1;
    final stock = product?.pQuantity ?? 0;
    final cartQty = _getCartQuantity();
    final availableQty = (stock - cartQty).clamp(0, stock);
    if (quantity > availableQty && availableQty > 0) {
      quantity = availableQty;
    }

    setState(() => switching = false);
  }

  @override
  Widget build(BuildContext context) {
    if (productBase == null || productImage == null || product == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Loading...')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final p = context.palette;
    
    return Scaffold(
      appBar: AppBar(
        backgroundColor: p.cardBackground,
        title: Text(
          productBase!.pName,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: p.textPrimary),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // 이미지 + 로딩 오버레이
            Stack(
              children: [
                Center(
                  child: Image.asset(
                    productImage!.imagePath,
                    width: MediaQuery.sizeOf(context).width * 0.9,
                    height: config.productDetailImageHeight,
                    fit: BoxFit.cover,
                  ),
                ),
                if (switching)
                  Positioned.fill(
                    child: ColoredBox(
                      color: p.textPrimary.withOpacity(0.33),
                      child: Center(child: CircularProgressIndicator()),
                    ),
                  ),
              ],
            ),

            const SizedBox(height: 40),
            Align(
              alignment: Alignment.topLeft,
              child: Text(
                '     상품명: ${productBase!.pName}',
                style: config.boldLabelStyle.copyWith(color: p.textPrimary),
              ),
            ),

            const SizedBox(height: 40),
            Align(
              alignment: Alignment.topLeft,
              child: Text(
                '     가격: ${CustomCommonUtil.formatNumber(product!.basePrice)}',
                style: config.boldLabelStyle.copyWith(color: p.textPrimary),
              ),
            ),

            const SizedBox(height: 40),
            Align(
              alignment: Alignment.topLeft,
              child: Text('     사이즈', style: config.boldLabelStyle.copyWith(color: p.textPrimary)),
            ),

            const SizedBox(height: 25),
            SizedBox(
              height: 50,
              width: MediaQuery.sizeOf(context).width,
              child: Padding(
                padding: const EdgeInsets.only(left: 20),
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: productSizes?.length ?? 0,
                  separatorBuilder: (_, __) => const SizedBox(width: 12),
                  itemBuilder: (context, index) {
                    final sizeProduct = productSizes![index];
                    final size = sizeProduct.size;
                    final isSelected = selectedSizeIndex == index;
                    
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedSizeIndex = index;
                          product = sizeProduct; // 선택된 사이즈의 제품으로 업데이트
                          // 수량이 최대 수량(재고 - 장바구니 수량)을 초과하면 최대 수량으로 제한
                          final stock = product?.pQuantity ?? 0;
                          final cartQty = _getCartQuantity();
                          final availableQty = (stock - cartQty).clamp(0, stock);
                          if (quantity > availableQty) {
                            quantity = availableQty > 0 ? availableQty : 1;
                          }
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected ? p.primary : p.chipUnselectedBg,
                          borderRadius: BorderRadius.circular(12),
                          border: isSelected 
                              ? Border.all(color: p.primary, width: 2)
                              : Border.all(color: p.divider),
                        ),
                        child: Align(
                          alignment: Alignment.center,
                          child: Text(
                            size.toString(), 
                            style: config.boldLabelStyle.copyWith(
                              color: isSelected ? p.textOnPrimary : p.textPrimary,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),

            const SizedBox(height: 25),
            Align(
              alignment: Alignment.topLeft,
              child: Text('     색상', style: config.boldLabelStyle.copyWith(color: p.textPrimary)),
            ),

            const SizedBox(height: 25),
            Wrap(
              spacing: config.mediumSpacing,
              children: List.generate(productColors?.length ?? 0, (index) {
                return ChoiceChip(
                  label: Text(pbColors![index]),
                  selected: selectedColorIndex == index,
                  onSelected: (bool selected) async {
                    if (!selected) return;
                    if (switching) return;

                    // 먼저 선택 UI 반영
                    setState(() => selectedColorIndex = index);

                    // 실제 데이터 갈아끼우기
                    await _applyColor(
                      productColors![index],
                      setChipIndex: false,
                    );
                  },
                  selectedColor: p.chipSelectedBg,
                  backgroundColor: p.chipUnselectedBg,
                  labelStyle: TextStyle(
                    color: selectedColorIndex == index
                        ? p.chipSelectedText
                        : p.chipUnselectedText,
                  ),
                );
              }),
            ),

            const SizedBox(height: 25),
            Align(
              alignment: Alignment.topLeft,
              child: Text(
                '     수량${maxQuantity > 0 ? ' (최대 $maxQuantity)' : ''}',
                style: config.boldLabelStyle.copyWith(color: p.textPrimary),
              ),
            ),

            const SizedBox(height: 12), // mediumSpacing과 동일하지만 SizedBox는 위젯이므로 유지
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: p.chipUnselectedBg,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          onPressed: () {
                            if (quantity > 1) {
                              setState(() => quantity--);
                            }
                          },
                          icon: const Icon(Icons.remove),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: p.cardBackground,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: p.divider),
                          ),
                          child: Text('$quantity', style: config.boldLabelStyle.copyWith(color: p.textPrimary)),
                        ),
                        IconButton(
                          onPressed: quantity >= maxQuantity
                              ? null
                              : () => setState(() {
                                    if (quantity < maxQuantity) {
                                      quantity++;
                                    }
                                  }),
                          icon: const Icon(Icons.add),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 24),

                  Expanded(
                    child: SizedBox(
                      height: 48,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: canPurchase ? p.chipUnselectedBg : p.divider,
                          foregroundColor: canPurchase ? p.textPrimary : p.textSecondary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 0,
                        ),
                        onPressed: canPurchase
                            ? () async {
                                if (product == null || productBase == null) return;
                                
                                // DB에서 최신 재고 조회하여 구매 가능한 수량 확인
                                final productId = product!.id;
                                if (productId == null) return;
                                
                                final latestMaxQty = await _getMaxQuantityFromDb(productId);
                                
                                // 구매 가능한 수량 체크 (최신 재고 기준)
                                if (quantity > latestMaxQty) {
                                  CustomSnackBar.showError(
                                    context,
                                    message: '구매 가능한 최대 수량은 $latestMaxQty개입니다.\n'
                                        '(다른 사용자가 구매하여 재고가 변경되었을 수 있습니다.)',
                                    duration: const Duration(seconds: 3),
                                  );
                                  
                                  // 수량을 최대 수량으로 자동 조정
                                  if (latestMaxQty > 0) {
                                    setState(() {
                                      quantity = latestMaxQty;
                                    });
                                  }
                                  return;
                                }

                                // 장바구니에 담을 아이템 정보 구성
                                final item = <String, dynamic>{
                                  'productId': productId,
                                  'pbid': product!.pbid,
                                  'mfid': product!.mfid,
                                  'name': productBase!.pName,
                                  'color': productBase!.pColor,
                                  'size': product!.size,
                                  'unitPrice': product!.basePrice,
                                  'quantity': quantity,
                                  'imagePath': productImage?.imagePath,
                                };

                                // CartStorage를 사용하여 장바구니에 추가
                                CartStorage.addToCart(item);

                                CustomSnackBar.showSuccess(
                                  context,
                                  message: '장바구니에 담겼습니다!',
                                );
                                
                                // 장바구니 상태 변경 후 UI 업데이트
                                setState(() {});
                              }
                            : null,
                        child: Text('Add Cart', style: config.boldLabelStyle.copyWith(color: p.textPrimary)),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        child: SizedBox(
          height: 55,
          child: Row(
            children: [
              // 장바구니 가기 버튼
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    CustomNavigationUtil.toNamed(context, config.routeCart);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: p.primary,
                    foregroundColor: p.textOnPrimary,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.shopping_cart, size: 20),
                      const SizedBox(width: 8),
                      Text('장바구니', style: config.boldLabelStyle.copyWith(color: p.textOnPrimary)),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // 바로 구매 버튼
              Expanded(
                child: ElevatedButton(
                  onPressed: canPurchase
                      ? () {
                          // 현재 선택된 제품 정보를 바로 구매 화면으로 전달
                          // 장바구니는 거치지 않고 바로 결제 화면으로 이동
                          if (product == null || productBase == null || productImage == null) {
                            CustomSnackBar.showError(
                              context,
                              message: '제품 정보를 불러올 수 없습니다.',
                            );
                            return;
                          }

                          // 구매 가능한 수량 체크
                          if (quantity > maxQuantity) {
                            CustomSnackBar.showError(
                              context,
                              message: '구매 가능한 최대 수량은 $maxQuantity개입니다.',
                            );
                            return;
                          }

                          // purchase_view가 기대하는 형식으로 현재 선택된 제품 정보 구성
                          final purchaseItem = <String, dynamic>{
                            'productId': product!.id,
                            'quantity': quantity,
                            'unitPrice': product!.basePrice,
                            'imagePath': productImage!.imagePath,
                            'name': productBase!.pName,
                            'color': productBase!.pColor,
                            'size': product!.size,
                          };

                          // 리스트로 감싸서 전달 (purchase_view는 리스트를 기대함)
                          CustomNavigationUtil.toNamed(
                            context,
                            config.routePurchaseView,
                            arguments: [purchaseItem],
                          );
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: canPurchase ? p.primary : p.divider,
                    foregroundColor: p.textOnPrimary,
                  ),
                  child: Text("바로 구매", style: config.boldLabelStyle.copyWith(color: p.textOnPrimary)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
