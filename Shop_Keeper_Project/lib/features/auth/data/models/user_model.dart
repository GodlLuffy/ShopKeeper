import 'package:shop_keeper_project/features/auth/domain/entities/user_entity.dart';

class UserModel extends UserEntity {
  const UserModel({
    required super.uid,
    required super.name,
    required super.shopName,
    required super.phoneNumber,
    required super.email,
    super.isEmailVerified,
    super.subscriptionPlan,
    super.createdAt,
  });

  factory UserModel.fromEntity(UserEntity entity) {
    return UserModel(
      uid: entity.uid,
      name: entity.name,
      shopName: entity.shopName,
      phoneNumber: entity.phoneNumber,
      email: entity.email,
      isEmailVerified: entity.isEmailVerified,
      subscriptionPlan: entity.subscriptionPlan,
      createdAt: entity.createdAt,
    );
  }

  factory UserModel.fromMap(Map<String, dynamic> map, String uid) {
    return UserModel(
      uid: uid,
      name: map['name'] ?? '',
      shopName: map['shopName'] ?? '',
      phoneNumber: map['phoneNumber'] ?? '',
      email: map['email'] ?? '',
      isEmailVerified: map['isEmailVerified'] ?? false,
      subscriptionPlan: _parseSubscriptionPlan(map['subscriptionPlan']),
      createdAt: map['createdAt'] != null 
          ? (map['createdAt'] is DateTime 
              ? map['createdAt'] 
              : DateTime.fromMillisecondsSinceEpoch(map['createdAt'].millisecondsSinceEpoch ?? DateTime.now().millisecondsSinceEpoch))
          : null,
    );
  }

  static SubscriptionPlan _parseSubscriptionPlan(dynamic value) {
    if (value == null) return SubscriptionPlan.free;
    if (value is String) {
      switch (value.toLowerCase()) {
        case 'pro':
          return SubscriptionPlan.pro;
        case 'enterprise':
          return SubscriptionPlan.enterprise;
        default:
          return SubscriptionPlan.free;
      }
    }
    if (value is int) {
      switch (value) {
        case 1:
          return SubscriptionPlan.pro;
        case 2:
          return SubscriptionPlan.enterprise;
        default:
          return SubscriptionPlan.free;
      }
    }
    return SubscriptionPlan.free;
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'shopName': shopName,
      'phoneNumber': phoneNumber,
      'email': email,
      'isEmailVerified': isEmailVerified,
      'subscriptionPlan': subscriptionPlan.name,
      'createdAt': createdAt?.toUtc().millisecondsSinceEpoch ?? DateTime.now().toUtc().millisecondsSinceEpoch,
    };
  }
}
