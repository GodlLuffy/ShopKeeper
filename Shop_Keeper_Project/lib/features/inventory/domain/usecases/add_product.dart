import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/product_entity.dart';
import '../repositories/inventory_repository.dart';

class AddProduct implements UseCase<ProductEntity, AddProductParams> {
  final InventoryRepository repository;

  AddProduct(this.repository);

  @override
  Future<Either<Failure, ProductEntity>> call(AddProductParams params) async {
    final validation = params.product.validate();
    return await validation.fold(
      (failure) async => Left(failure),
      (_) async => await repository.addProduct(params.product, imageFile: params.imageFile, barcode: params.barcode),
    );
  }
}

class AddProductParams extends Equatable {
  final ProductEntity product;
  final File? imageFile;
  final String? barcode;

  const AddProductParams({required this.product, this.imageFile, this.barcode});

  @override
  List<Object?> get props => [product, imageFile, barcode];
}
