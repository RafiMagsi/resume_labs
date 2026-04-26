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

      final productDetailsResult = await _getCreditsProductDetails();
      final productDetails = productDetailsResult.fold(
        (failure) => null,
        (product) => product,
      );
      if (productDetails == null) return productDetailsResult;

      final purchaseStarted = await _inAppPurchase.buyConsumable(
        purchaseParam: PurchaseParam(productDetails: productDetails),
        autoConsume: true,
      );

      if (!purchaseStarted) {
        return Left(ServerFailure('Purchase did not start.'));
      }

      final completer = Completer<Either<Failure, void>>();
      late final StreamSubscription<List<PurchaseDetails>> sub;

      sub = _inAppPurchase.purchaseStream.listen(
        (purchases) async {
          for (final purchase in purchases) {
            if (purchase.productID != AppStrings.creditsProductId) continue;

            switch (purchase.status) {
              case PurchaseStatus.pending:
                // waiting
                break;
              case PurchaseStatus.canceled:
                if (!completer.isCompleted) {
                  completer.complete(
                    Left(ServerFailure('Purchase cancelled.')),
                  );
                }
                break;
              case PurchaseStatus.error:
                if (!completer.isCompleted) {
                  completer.complete(
                    Left(
                      ServerFailure(
                        purchase.error?.message ?? 'Purchase failed.',
                      ),
                    ),
                  );
                }
                break;
              case PurchaseStatus.purchased:
              case PurchaseStatus.restored:
                try {
                  if (purchase.pendingCompletePurchase) {
                    await _inAppPurchase.completePurchase(purchase);
                  }

                  // Grant credits only after a successful purchase signal.
                  await _userDatasource.addCredits(user.uid, 10);

                  if (!completer.isCompleted) {
                    completer.complete(const Right(null));
                  }
                } catch (e) {
                  if (!completer.isCompleted) {
                    completer.complete(
                      Left(ServerFailure('Failed to finalize purchase: $e')),
                    );
                  }
                }
                break;
            }
          }
        },
        onError: (e) {
          if (!completer.isCompleted) {
            completer
                .complete(Left(ServerFailure('Purchase stream error: $e')));
          }
        },
      );

      final result = await completer.future.timeout(
        const Duration(seconds: 60),
        onTimeout: () => Left(
          NetworkFailure('Purchase timed out. Please try again.'),
        ),
      );

      await sub.cancel();
      return result;
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
      // `resume_labs_credits_10` should be configured as a Consumable.
      // Consumables are not restored by Apple/Google (they are meant to be
      // purchased repeatedly). Credits are stored in Firestore per-user, so a
      // reinstall will keep them without restore.
      return Left(
        ServerFailure(
          'Credits purchases cannot be restored. Your credits are tied to your account.',
        ),
      );
    } on AppException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Restore error: $e'));
    }
  }

  Future<Either<Failure, ProductDetails>> _getCreditsProductDetails() async {
    try {
      final available = await _inAppPurchase.isAvailable();
      if (!available) {
        return const Left(
          ServerFailure(
            'In-app purchases are not available on this device. '
            'Test on a real device using TestFlight (iOS) or an internal testing track (Android).',
          ),
        );
      }

      final response = await _inAppPurchase.queryProductDetails(
        {AppStrings.creditsProductId},
      );

      if (response.error != null) {
        return Left(
          ServerFailure(
            'Store error: ${response.error!.message} (${response.error!.code})',
          ),
        );
      }

      if (response.productDetails.isEmpty) {
        return const Left(
          ServerFailure(
            'Product not found in the store. Make sure `resume_labs_credits_10` '
            'exists in App Store Connect / Play Console and you are running from TestFlight / an internal testing track.',
          ),
        );
      }

      return Right(response.productDetails.first);
    } catch (e) {
      return Left(ServerFailure('Failed to load product details: $e'));
    }
  }
}
