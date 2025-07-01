import 'dart:async';
import 'dart:ffi';
import 'package:flutter/material.dart';
// import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:restart_app/restart_app.dart';
import 'package:sakoon_shar/Utils.dart';

import 'main.dart';

class IAPBottomSheet  {
  // @override
  // _IAPBottomSheetState createState() => _IAPBottomSheetState();
}

// class _IAPBottomSheetState extends State<IAPBottomSheet> {
//   final InAppPurchase _iap = InAppPurchase.instance;
//   late StreamSubscription<List<PurchaseDetails>> _subscription;
//   bool _available = false;
//   List<ProductDetails> _products = [];
//   List<PurchaseDetails> _purchases = [];
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
//     final purchaseUpdated = _iap.purchaseStream;
//     _subscription = purchaseUpdated.listen(_listenToPurchaseUpdated, onDone: () {
//       _subscription.cancel();
//     }, onError: (error) {
//       debugPrint("Purchase stream error: $error");
//     });
//
//
//     _initialize();
//   }
//
//   Future<void> _initialize() async {
//     _available = await _iap.isAvailable();
//     if (_available) {
//       await _getProducts();
//     }
//     setState(() {});
//   }
//
//   Future<void> _getProducts() async {
//     final response = await _iap.queryProductDetails({_productId});
//     if (response.notFoundIDs.isNotEmpty) {
//       debugPrint("Product ID not found: $_productId");
//     }
//     _products = response.productDetails;
//     setState(() {});
//   }
//
//   void _buyProduct(ProductDetails product) {
//     final purchaseParam = PurchaseParam(productDetails: product);
//     _iap.buyNonConsumable(purchaseParam: purchaseParam);
//   }
//
//   void _listenToPurchaseUpdated(List<PurchaseDetails> purchases) {
//     for (var purchase in purchases) {
//       if (purchase.status == PurchaseStatus.purchased) {
//         debugPrint("Purchase successful: ${purchase.productID}");
//         _iap.completePurchase(purchase);
//         setState(() {
//           _purchases.add(purchase);
//           Utils.saveBool(Utils.ip, true);
//         });
//         ScaffoldMessenger.of(context)
//             .showSnackBar(SnackBar(content: Text('Purchase Success.')),
//         );
//         Restart.restartApp();
//       }
//
//       else if (purchase.status == PurchaseStatus.restored){
//         Utils.saveBool(Utils.ip, true);
//         ScaffoldMessenger.of(context)
//             .showSnackBar(SnackBar(content: Text('Purchase Restored.')),
//         );
//         Restart.restartApp();
//         print("IAP_RESTORED!!");
//       }
//       else if (purchase.status == PurchaseStatus.error) {
//         if (purchase.error?.message == 'BillingResponse.itemAlreadyOwned') {
//           print("IAP_RESTORED");
//           Utils.saveBool(Utils.ip, true);
//           ScaffoldMessenger.of(context)
//                 .showSnackBar(SnackBar(content: Text('Purchase Restored.')),
//             );
//
//           Restart.restartApp();
//
//           // Navigator.pushReplacement(
//           //   context,
//           //   MaterialPageRoute(builder: (context) => MyHomePage(index: 0,size1:Utils.updateFontSize)),
//           // );
//         }else{
//           ScaffoldMessenger.of(context)
//               .showSnackBar(SnackBar(content: Text('Purchase Failed.')),
//           );
//           // Navigator.pushReplacement(
//           //   context,
//           //   MaterialPageRoute(builder: (context) => MyHomePage(index: 0,size1:Utils.updateFontSize)),
//           // );
//           print("IAP_ "+purchase.error!.message.toString()+"  __ ");
//         }
//         print("IAP_Purchase error: ${purchase.error}");
//         //Utils.saveBool(Utils.ip, false);
//       }
//     }
//   }
//
//   bool _isPurchased(String productId) {
//     return _purchases.any(
//             (p) => p.productID == productId && p.status == PurchaseStatus.purchased);
//   }
//
//   void _restorePurchases() async {
//     if (Theme.of(context).platform == TargetPlatform.iOS) {
//       await _iap.restorePurchases();
//     }
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
//     if (!_available) {
//       return SafeArea(
//         child: Padding(
//           padding: const EdgeInsets.all(16.0),
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//               children: [
//                 SizedBox(height: 40,width: double.infinity),
//                 Text("Store not available",style: TextStyle(fontSize: 18, fontWeight: FontWeight.normal)),
//                 SizedBox(height: 40,width: double.infinity)
//               ]
//           )
//
//
//           //Center(child: Text("Store not available")),
//         ),
//       );
//     }
//
//     return SafeArea(
//       child: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: _products.isEmpty
//             ?
//         // Center(child: CircularProgressIndicator())
//         Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               SizedBox(height: 40,width: double.infinity),
//               CircularProgressIndicator(),
//               SizedBox(height: 40,width: double.infinity),
//
//             ]
//         )
//
//             : Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Row(
//               children: [
//                 Text("Unlock Full Book", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
//                 Spacer(),
//                 if (Theme.of(context).platform == TargetPlatform.iOS)
//                   TextButton.icon(
//                     icon: Icon(Icons.restore),
//                     label: Text("Restore"),
//                     onPressed: _restorePurchases,
//                   ),
//               ],
//             ),
//             ..._products.map((product) {
//               final purchased = _isPurchased(product.id);
//               return ListTile(
//                 title: Text(product.title),
//                 subtitle: Column(verticalDirection: VerticalDirection.down,
//                     children: [
//                   Text(product.description),
//                   purchased
//                       ? Icon(Icons.check_circle, color: Colors.green)
//                       : SizedBox(
//                         width: 220,
//                         child: ElevatedButton(
//                           child: Text(product.price, style: TextStyle(color: Colors.white) ,),
//                           style: ElevatedButton.styleFrom(
//                             backgroundColor: Color(0xff1b5a4b), // ← Set background color here
//                           ),
//                           onPressed: () => _buyProduct(product),
//                                         ),
//                       ),
//                 ]),
//               );
//             }).toList(),
//           ],
//         ),
//       ),
//     );
//   }
// }