// IAP Service Template - Add to all games
// Replace GAME_NAME with actual game name

import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';

class IAPService {
  static final IAPService instance = IAPService._();
  IAPService._();

  final InAppPurchase _iap = InAppPurchase.instance;
  bool _isInitialized = false;
  bool _adsRemoved = false;
  bool _isPremium = false;
  StreamSubscription<List<PurchaseDetails>>? _subscription;

  // Product IDs (must match App Store Connect & Play Console)
  static const String removeAdsId = 'com.heldig.bouncedash.removeads';
  static const String premiumId = 'com.heldig.bouncedash.premium';
  static const String hintPackSmallId = 'com.heldig.bouncedash.hints_small';
  static const String hintPackLargeId = 'com.heldig.bouncedash.hints_large';

  // Getters
  bool get adsRemoved => _adsRemoved;
  bool get isPremium => _isPremium;

  Future<void> initialize() async {
    if (_isInitialized) return;

    final available = await _iap.isAvailable();
    if (!available) {
      debugPrint('IAP not available on this device');
      return;
    }

    // Listen to purchase updates
    _subscription = _iap.purchaseStream.listen(
      _onPurchaseUpdate,
      onDone: () => _subscription?.cancel(),
      onError: (error) => debugPrint('Purchase error: $error'),
    );

    // Restore previous purchases
    await _restorePurchases();

    _isInitialized = true;
  }

  void _onPurchaseUpdate(List<PurchaseDetails> purchases) {
    for (final purchase in purchases) {
      if (purchase.status == PurchaseStatus.purchased ||
          purchase.status == PurchaseStatus.restored) {
        _verifyAndDeliverProduct(purchase);
      }

      if (purchase.pendingCompletePurchase) {
        _iap.completePurchase(purchase);
      }
    }
  }

  void _verifyAndDeliverProduct(PurchaseDetails purchase) {
    // In production, verify receipt with backend
    // For now, trust the platform

    switch (purchase.productID) {
      case removeAdsId:
        _adsRemoved = true;
        _savePreference('ads_removed', true);
        break;
      case premiumId:
        _isPremium = true;
        _savePreference('is_premium', true);
        break;
      case hintPackSmallId:
        // Add 10 hints
        _addHints(10);
        break;
      case hintPackLargeId:
        // Add 50 hints
        _addHints(50);
        break;
    }

    debugPrint('Product delivered: ${purchase.productID}');
  }

  Future<void> _restorePurchases() async {
    try {
      await _iap.restorePurchases();

      // Also load from local storage
      _adsRemoved = await _loadPreference('ads_removed');
      _isPremium = await _loadPreference('is_premium');
    } catch (e) {
      debugPrint('Restore error: $e');
    }
  }

  // Purchase Methods
  Future<bool> purchaseRemoveAds() async {
    return await _purchaseProduct(removeAdsId);
  }

  Future<bool> purchasePremium() async {
    return await _purchaseProduct(premiumId);
  }

  Future<bool> purchaseHintPackSmall() async {
    return await _purchaseProduct(hintPackSmallId);
  }

  Future<bool> purchaseHintPackLarge() async {
    return await _purchaseProduct(hintPackLargeId);
  }

  Future<bool> _purchaseProduct(String productId) async {
    if (!_isInitialized) {
      debugPrint('IAP not initialized');
      return false;
    }

    try {
      final ProductDetailsResponse response = await _iap.queryProductDetails({productId});

      if (response.productDetails.isEmpty) {
        debugPrint('Product not found: $productId');
        return false;
      }

      final productDetails = response.productDetails.first;
      final purchaseParam = PurchaseParam(productDetails: productDetails);

      // Determine if consumable or non-consumable
      final isConsumable = productId.contains('hints');

      if (isConsumable) {
        await _iap.buyConsumable(purchaseParam: purchaseParam);
      } else {
        await _iap.buyNonConsumable(purchaseParam: purchaseParam);
      }

      return true;
    } catch (e) {
      debugPrint('Purchase error: $e');
      return false;
    }
  }

  Future<Map<String, ProductDetails>> getProductDetails() async {
    const productIds = {
      removeAdsId,
      premiumId,
      hintPackSmallId,
      hintPackLargeId,
    };

    final response = await _iap.queryProductDetails(productIds);

    return {
      for (var product in response.productDetails)
        product.id: product
    };
  }

  // Helper methods
  void _addHints(int count) {
    // Implement in game-specific code
    // Example: HintService.instance.addHints(count);
  }

  Future<void> _savePreference(String key, bool value) async {
    // Use SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
  }

  Future<bool> _loadPreference(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(key) ?? false;
  }

  void dispose() {
    _subscription?.cancel();
  }
}

// Example usage in main.dart:
/*
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await IAPService.instance.initialize();
  runApp(MyApp());
}

// In Settings Screen:
class SettingsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        if (!IAPService.instance.adsRemoved)
          ListTile(
            title: Text('Remove Ads'),
            subtitle: Text('\$2.99 - One-time purchase'),
            trailing: ElevatedButton(
              onPressed: () async {
                final success = await IAPService.instance.purchaseRemoveAds();
                if (success) {
                  // Show success message
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Ads removed! Thank you!')),
                  );
                }
              },
              child: Text('Buy'),
            ),
          ),
        ListTile(
          title: Text('Restore Purchases'),
          trailing: IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () async {
              await IAPService.instance._restorePurchases();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Purchases restored')),
              );
            },
          ),
        ),
      ],
    );
  }
}

// Disable ads after purchase:
void initializeAds() {
  AdService.instance.setAdsRemoved(IAPService.instance.adsRemoved);
}
*/
