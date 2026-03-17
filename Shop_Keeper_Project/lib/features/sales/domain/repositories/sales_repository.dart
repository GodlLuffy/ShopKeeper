import 'package:dartz/dartz.dart';
import 'package:shop_keeper_project/core/error/failures.dart';
import 'package:shop_keeper_project/features/sales/domain/entities/sale_entity.dart';

abstract class SalesRepository {
  Future<Either<Failure, List<SaleEntity>>> getSalesByDate(DateTime date);
  Future<Either<Failure, SaleEntity>> addSale(SaleEntity sale);
  Future<Either<Failure, double>> getTodaySalesSummary();
}
