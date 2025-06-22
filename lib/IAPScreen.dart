import 'dart:async';
import 'dart:ffi';
import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:restart_app/restart_app.dart';
import 'package:sakoon_shar/Utils.dart';

import 'main.dart';

class IAPBottomSheet extends StatefulWidget {
  @override
  _IAPBottomSheetState createState() => _IAPBottomSheetState();
}

class _IAPBottomSheetState extends State<IAPBottomSheet> {
  final InAppPurchase _iap = InAppPurchase.instance;
  late StreamSubscription<List<PurchaseDetails>> _subscription;
  bool _available = false;
  List<ProductDetails> _products = [];
  List<PurchaseDetails> _purchases = [];

  final String _androidProductId = 'full_book';
  final String _iosProductId = 'FullBook';

  String get _productId =>
      Theme.of(context).platform == TargetPlatform.iOS ? _iosProductId : _androidProductId;

  @override
  void initState() {
    super.initState();
    final purchaseUpdated = _iap.purchaseStream;
    _subscription = purchaseUpdated.listen(_listenToPurchaseUpdated, onDone: () {
      _subscription.cancel();
    }, onError: (error) {
      debugPrint("Purchase stream error: $error");
    });


    _initialize();
  }

  Future<void> _initialize() async {
    _available = await _iap.isAvailable();
    if (_available) {
      await _getProducts();
    }
    setState(() {});
  }

  Future<void> _getProducts() async {
    final response = await _iap.queryProductDetails({_productId});
    if (response.notFoundIDs.isNotEmpty) {
      debugPrint("Product ID not found: $_productId");
    }
    _products = response.productDetails;
    setState(() {});
  }

  void _buyProduct(ProductDetails product) {
    final purchaseParam = PurchaseParam(productDetails: product);
    _iap.buyNonConsumable(purchaseParam: purchaseParam);
  }

  void _listenToPurchaseUpdated(List<PurchaseDetails> purchases) {
    for (var purchase in purchases) {
      if (purchase.status == PurchaseStatus.purchased) {
        debugPrint("Purchase successful: ${purchase.productID}");
        _iap.completePurchase(purchase);
        setState(() {
          _purchases.add(purchase);
          Utils.saveBool(Utils.ip, true);
        });
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Purchase Success.')),
        );
        Restart.restartApp();
      }

      else if (purchase.status == PurchaseStatus.restored){
        Utils.saveBool(Utils.ip, true);
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Purchase Restored.')),
        );
        Restart.restartApp();
        print("IAP_RESTORED!!");
      }
      else if (purchase.status == PurchaseStatus.error) {
        if (purchase.error?.message == 'BillingResponse.itemAlreadyOwned') {
          print("IAP_RESTORED");
          Utils.saveBool(Utils.ip, true);
          ScaffoldMessenger.of(context)
                .showSnackBar(SnackBar(content: Text('Purchase Restored.')),
            );

          Restart.restartApp();

          // Navigator.pushReplacement(
          //   context,
          //   MaterialPageRoute(builder: (context) => MyHomePage(index: 0,size1:Utils.updateFontSize)),
          // );
        }else{
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text('Purchase Failed.')),
          );
          // Navigator.pushReplacement(
          //   context,
          //   MaterialPageRoute(builder: (context) => MyHomePage(index: 0,size1:Utils.updateFontSize)),
          // );
          print("IAP_ "+purchase.error!.message.toString()+"  __ ");
        }
        print("IAP_Purchase error: ${purchase.error}");
        //Utils.saveBool(Utils.ip, false);
      }
    }
  }

  bool _isPurchased(String productId) {
    return _purchases.any(
            (p) => p.productID == productId && p.status == PurchaseStatus.purchased);
  }

  void _restorePurchases() async {
    if (Theme.of(context).platform == TargetPlatform.iOS) {
      await _iap.restorePurchases();
    }
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_available) {
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(height: 40,width: double.infinity),
                Text("Store not available",style: TextStyle(fontSize: 18, fontWeight: FontWeight.normal)),
                SizedBox(height: 40,width: double.infinity)
              ]
          )
        
        
          //Center(child: Text("Store not available")),
        ),
      );
    }

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _products.isEmpty
            ?
        // Center(child: CircularProgressIndicator())
        Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(height: 40,width: double.infinity),
              CircularProgressIndicator(),
              SizedBox(height: 40,width: double.infinity),
      
            ]
        )
      
            : Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Text("Unlock Full Book", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                Spacer(),
                if (Theme.of(context).platform == TargetPlatform.iOS)
                  TextButton.icon(
                    icon: Icon(Icons.restore),
                    label: Text("Restore"),
                    onPressed: _restorePurchases,
                  ),
              ],
            ),
            ..._products.map((product) {
              final purchased = _isPurchased(product.id);
              return ListTile(
                title: Text(product.title),
                subtitle: Column(verticalDirection: VerticalDirection.down,
                    children: [
                  Text(product.description),
                  purchased
                      ? Icon(Icons.check_circle, color: Colors.green)
                      : SizedBox(
                        width: 220,
                        child: ElevatedButton(
                          child: Text(product.price, style: TextStyle(color: Colors.white) ,),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xff1b5a4b), // ← Set background color here
                          ),
                          onPressed: () => _buyProduct(product),
                                        ),
                      ),
                ]),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }
}
//
// import 'dart:async';
// import 'package:flutter/material.dart';
// import 'package:in_app_purchase/in_app_purchase.dart';
// import 'package:sakoon_shar/Utils.dart';
//
// class IAPBottomSheet extends StatefulWidget {
//   @override
//   _IAPBottomSheetState createState() => _IAPBottomSheetState();
// }
//
// class _IAPBottomSheetState extends State<IAPBottomSheet> {
//   final InAppPurchase _iap = InAppPurchase.instance;
//   late StreamSubscription<List<PurchaseDetails>> _subscription;
//   bool _available = false;
//   bool _isLoading = true;
//   List<ProductDetails> _products = [];
//   List<PurchaseDetails> _purchases = [];
//   String? _errorMessage;
//
//   final String _androidProductId = 'full_book';
//   final String _iosProductId = 'FullBook';
//
//   String get _productId =>
//       Theme.of(context).platform == TargetPlatform.iOS ? _iosProductId : _androidProductId;
//
//   @override
//   void initState() {
//     super.initState();
//     _initialize();
//     _subscription = _iap.purchaseStream.listen(
//       _listenToPurchaseUpdated,
//       onError: (error) => _handleError('Purchase stream error: $error'),
//     );
//   }
//
//   Future<void> _initialize() async {
//     try {
//       _available = await _iap.isAvailable();
//       if (_available) {
//         await _getProducts();
//       } else {
//         _handleError('In-app purchases not available');
//       }
//     } catch (e) {
//       _handleError('Initialization failed: $e');
//     } finally {
//       if (mounted) {
//         setState(() => _isLoading = false);
//       }
//     }
//   }
//
//   Future<void> _getProducts() async {
//     try {
//       final response = await _iap.queryProductDetails({_productId});
//       if (response.notFoundIDs.isNotEmpty) {
//         _handleError('Product ID not found: ${response.notFoundIDs.join(', ')}');
//       }
//       if (mounted) {
//         setState(() => _products = response.productDetails);
//       }
//     } catch (e) {
//       _handleError('Failed to fetch products: $e');
//     }
//   }
//
//   Future<void> _buyProduct(ProductDetails product) async {
//     try {
//       final purchaseParam = PurchaseParam(productDetails: product);
//       await _iap.buyNonConsumable(purchaseParam: purchaseParam);
//     } catch (e) {
//       _handleError('Purchase failed: $e');
//     }
//   }
//
//   void _listenToPurchaseUpdated(List<PurchaseDetails> purchases) async {
//     for (var purchase in purchases) {
//       try {
//         switch (purchase.status) {
//           case PurchaseStatus.purchased:
//           case PurchaseStatus.restored:
//             await _handleSuccessfulPurchase(purchase);
//             break;
//
//           case PurchaseStatus.error:
//             await _handlePurchaseError(purchase);
//             break;
//
//           case PurchaseStatus.pending:
//             debugPrint("Purchase pending: ${purchase.productID}");
//             break;
//
//           case PurchaseStatus.canceled:
//             debugPrint("Purchase canceled: ${purchase.productID}");
//             break;
//         }
//       } catch (e) {
//         _handleError('Error processing purchase: $e');
//       }
//     }
//   }
//
//   Future<void> _handleSuccessfulPurchase(PurchaseDetails purchase) async {
//    print("IAP_Handling Success: --");
//     // Verify purchase (in production, implement proper server-side verification)
//     final isValid = true;//await _verifyPurchase(purchase);
//     if (!isValid) {
//       await _iap.completePurchase(purchase);
//       _handleError('Purchase verification failed');
//       return;
//     }
//
//     await _iap.completePurchase(purchase);
//     Utils.saveBool(Utils.ip, true);
//
//     if (mounted) {
//       setState(() => _purchases.add(purchase));
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text(
//             purchase.status == PurchaseStatus.purchased
//                 ? 'Purchase Successful!'
//                 : 'Purchase Restored!'
//         )),
//       );
//     }
//    print("IAP_Handling Success: --end--");
//   }
//
//   Future<void> _handlePurchaseError(PurchaseDetails purchase) async {
//     final error = purchase.error;
//     debugPrint("Purchase error: ${error?.message}");
//
//     // Handle "already owned" case
//     if (error?.message?.toLowerCase().contains('already owned') ?? false) {
//       await _handleSuccessfulPurchase(purchase);
//       return;
//     }
//
//     if (mounted) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text(error?.message ?? 'Purchase failed')),
//       );
//     }
//   }
//
//   Future<bool> _verifyPurchase(PurchaseDetails purchase) async {
//     // In production, implement proper verification with your server
//     return true; // For testing purposes only
//   }
//
//   Future<void> _restorePurchases() async {
//     try {
//       setState(() => _isLoading = true);
//       await _iap.restorePurchases();
//     } catch (e) {
//       _handleError('Failed to restore purchases: $e');
//     } finally {
//       if (mounted) {
//         setState(() => _isLoading = false);
//       }
//     }
//   }
//
//   void _handleError(String message) {
//     debugPrint(message);
//     if (mounted) {
//       setState(() => _errorMessage = message);
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text(message)),
//       );
//     }
//   }
//
//   bool _isPurchased(String productId) {
//     return _purchases.any((p) =>
//     p.productID == productId &&
//         (p.status == PurchaseStatus.purchased || p.status == PurchaseStatus.restored)
//     );
//   }
//
//   @override
//   void dispose() {
//     _subscription.cancel();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.all(16.0),
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Row(
//             children: [
//               Text(
//                 "Unlock Full Book",
//                 style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//               ),
//               Spacer(),
//               if (Theme.of(context).platform == TargetPlatform.iOS && !_isLoading)
//                 TextButton.icon(
//                   icon: Icon(Icons.restore),
//                   label: Text("Restore"),
//                   onPressed: _restorePurchases,
//                 ),
//             ],
//           ),
//           SizedBox(height: 16),
//           if (_isLoading)
//             Center(child: CircularProgressIndicator())
//           else if (_errorMessage != null)
//             Text(_errorMessage!, style: TextStyle(color: Colors.red))
//           else if (!_available)
//               Text("Store not available", style: TextStyle(color: Colors.red))
//             else if (_products.isEmpty)
//                 Text("No products available", style: TextStyle(color: Colors.red))
//               else
//                 ..._products.map((product) {
//                   final purchased = _isPurchased(product.id);
//                   return ListTile(
//                     title: Text(product.title),
//                     subtitle: Text(product.description),
//                     trailing: purchased
//                         ? Icon(Icons.check_circle, color: Colors.green)
//                         : ElevatedButton(
//                       child: Text(product.price),
//                       onPressed: () => _buyProduct(product),
//                     ),
//                   );
//                 }).toList(),
//         ],
//       ),
//     );
//   }
// }