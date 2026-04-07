import 'package:equatable/equatable.dart';

enum SubscriptionPlan { free, pro, enterprise }

class UserEntity extends Equatable {
  final String uid;
  final String name;
  final String shopName;
  final String phoneNumber;
  final String email;
  final bool isEmailVerified;
  final SubscriptionPlan subscriptionPlan;
  final DateTime? createdAt;

  const UserEntity({
    required this.uid,
    required this.name,
    required this.shopName,
    required this.phoneNumber,
    required this.email,
    this.isEmailVerified = false,
    this.subscriptionPlan = SubscriptionPlan.free,
    this.createdAt,
  });

  UserEntity copyWith({
    String? uid,
    String? name,
    String? shopName,
    String? phoneNumber,
    String? email,
    bool? isEmailVerified,
    SubscriptionPlan? subscriptionPlan,
    DateTime? createdAt,
  }) {
    return UserEntity(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      shopName: shopName ?? this.shopName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      email: email ?? this.email,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
      subscriptionPlan: subscriptionPlan ?? this.subscriptionPlan,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [uid, name, shopName, phoneNumber, email, isEmailVerified, subscriptionPlan, createdAt];
}
