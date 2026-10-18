import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import '../../core/constants/app_constants.dart';

class TipTier {
  final String id;
  final String title;
  final String description;
  final String priceString;
  final String emoji;

  const TipTier({
    required this.id,
    required this.title,
    required this.description,
    required this.priceString,
    required this.emoji,
  });
}

class TipJarService extends ChangeNotifier {
  final InAppPurchase _iap;
  StreamSubscription<List<PurchaseDetails>>? _subscription;

  List<ProductDetails> _products = [];
  bool _isAvailable = false;
  bool _isLoading = true;
  String? _lastError;
  bool _purchaseSuccess = false;

  TipJarService({InAppPurchase? iap}) : _iap = iap ?? InAppPurchase.instance;

  List<ProductDetails> get products => _products;
  bool get isAvailable => _isAvailable;
  bool get isLoading => _isLoading;
  String? get lastError => _lastError;
  bool get purchaseSuccess => _purchaseSuccess;

  // Fallback metadata for clean visual display and offline/simulator testing
  static const List<TipTier> fallbackTiers = [
    TipTier(
      id: AppConstants.tipSmallId,
      title: 'Espresso Tip',
      description: 'Fuel a quick coding run',
      priceString: '\$1.99',
      emoji: '☕',
    ),
    TipTier(
      id: AppConstants.tipMediumId,
      title: 'Running Socks Tip',
      description: 'Keep the app blister-free & ad-free',
      priceString: '\$4.99',
      emoji: '🧦',
    ),
    TipTier(
      id: AppConstants.tipLargeId,
      title: 'Energy Gel Pack Tip',
      description: 'Power major performance features',
      priceString: '\$9.99',
      emoji: '⚡',
    ),
  ];

  Future<void> initialize() async {
    _subscription = _iap.purchaseStream.listen(
      _handlePurchaseUpdates,
      onDone: () => _subscription?.cancel(),
      onError: (error) {
        _lastError = error.toString();
        notifyListeners();
      },
    );

    await loadProducts();
  }

  Future<void> loadProducts() async {
    _isLoading = true;
    notifyListeners();

    try {
      _isAvailable = await _iap.isAvailable();
      if (_isAvailable) {
        final response = await _iap.queryProductDetails(AppConstants.tipProductIds);
        _products = response.productDetails;
        if (response.error != null) {
          _lastError = response.error!.message;
        }
      }
    } catch (e) {
      _lastError = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> buyTip(String productId) async {
    _purchaseSuccess = false;
    _lastError = null;

    if (!_isAvailable) {
      _lastError = 'StoreKit is currently unavailable on this device.';
      notifyListeners();
      return false;
    }

    final product = _products.cast<ProductDetails?>().firstWhere(
          (p) => p?.id == productId,
          orElse: () => null,
        );

    if (product == null) {
      _lastError = 'Tip tier is being configured in App Store Connect.';
      notifyListeners();
      return false;
    }

    final purchaseParam = PurchaseParam(productDetails: product);
    return await _iap.buyConsumable(purchaseParam: purchaseParam);
  }

  void _handlePurchaseUpdates(List<PurchaseDetails> purchaseDetailsList) {
    for (final purchaseDetails in purchaseDetailsList) {
      if (purchaseDetails.status == PurchaseStatus.pending) {
        // In progress
      } else {
        if (purchaseDetails.status == PurchaseStatus.error) {
          _lastError = purchaseDetails.error?.message ?? 'Purchase failed';
        } else if (purchaseDetails.status == PurchaseStatus.purchased) {
          _purchaseSuccess = true;
        }
        if (purchaseDetails.pendingCompletePurchase) {
          _iap.completePurchase(purchaseDetails);
        }
      }
    }
    notifyListeners();
  }

  void resetStatus() {
    _purchaseSuccess = false;
    _lastError = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
