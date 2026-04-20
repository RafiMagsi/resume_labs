import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:fpdart/fpdart.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

import '../../core/constants/app_strings.dart';
import '../../core/errors/app_exception.dart';
import '../../core/errors/failure.dart';
import '../../domain/repositories/purchase_repository.dart';
import '../datasources/remote/firestore_user_datasource.dart';

class PurchaseRepositoryImpl implements PurchaseRepository {
  final FirestoreUserDatasource _userDatasource;
  final InAppPurchase _inAppPurchase = InAppPurchase.instance;

  PurchaseRepositoryImpl({
    required FirestoreUserDatasource userDatasource,
  }) : _userDatasource = userDatasource;

  @override
  Stream<bool> get premiumStatusStream {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return Stream.value(false);
    }

    return _userDatasource.streamPremiumStatus(user.uid);
  }

  @override
  Future<Either<Failure, void>> purchasePremium() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        return Left(AuthFailure('User not authenticated'));
      }

      final productDetails = await _getProductDetails();
      if (productDetails == null) {
        return Left(ServerFailure('Product not found'));
      }

      final result = await _inAppPurchase.buyNonConsumable(
        purchaseParam: PurchaseParam(productDetails: productDetails),
      );

      if (!result) {
        return Left(ServerFailure('Purchase failed'));
      }

      await _userDatasource.setPremiumStatus(user.uid, true);
      return Right(null);
    } on AppException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Purchase error: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> restorePurchases() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        return Left(AuthFailure('User not authenticated'));
      }

      await _inAppPurchase.restorePurchases();

      // Listen to purchase stream to detect restored purchases
      var hasPremium = false;
      await _inAppPurchase.purchaseStream.first.then((purchases) {
        hasPremium = purchases.any(
          (p) => p.productID == AppStrings.premiumProductId,
        );
      });

      await _userDatasource.setPremiumStatus(user.uid, hasPremium);
      return Right(null);
    } on AppException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Restore error: $e'));
    }
  }

  Future<ProductDetails?> _getProductDetails() async {
    try {
      final available = await _inAppPurchase.isAvailable();
      if (!available) {
        return null;
      }

      final response = await _inAppPurchase.queryProductDetails(
        {AppStrings.premiumProductId},
      );

      if (response.productDetails.isEmpty) {
        return null;
      }

      return response.productDetails.first;
    } catch (e) {
      return null;
    }
  }
}
