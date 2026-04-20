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
  Stream<int> get creditsStream {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return Stream.value(0);
    }

    return _userDatasource.streamCredits(user.uid);
  }

  @override
  Future<Either<Failure, void>> purchaseCredits() async {
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

      // Add 10 credits to user after successful purchase
      await _userDatasource.addCredits(user.uid, 10);
      return Right(null);
    } on AppException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Purchase error: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> deductCredit() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        return Left(AuthFailure('User not authenticated'));
      }

      await _userDatasource.deductCredit(user.uid);
      return Right(null);
    } on AppException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Failed to deduct credit: $e'));
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
      int restoredCount = 0;
      await _inAppPurchase.purchaseStream.first.then((purchases) {
        restoredCount = purchases
            .where((p) => p.productID == AppStrings.creditsProductId)
            .length;
      });

      // Add 10 credits for each restored purchase
      if (restoredCount > 0) {
        await _userDatasource.addCredits(user.uid, 10 * restoredCount);
      }

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
        {AppStrings.creditsProductId},
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
