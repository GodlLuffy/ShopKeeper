import 'package:equatable/equatable.dart';

class UserEntity extends Equatable {
  final String uid;
  final String name;
  final String shopName;
  final String phoneNumber;
  final String email;

  const UserEntity({
    required this.uid,
    required this.name,
    required this.shopName,
    required this.phoneNumber,
    required this.email,
  });

  @override
  List<Object?> get props => [uid, name, shopName, phoneNumber, email];
}
