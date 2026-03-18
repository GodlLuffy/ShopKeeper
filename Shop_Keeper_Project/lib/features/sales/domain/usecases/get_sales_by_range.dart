import 'package:dartz/dartz.dart';
import 'package:shop_keeper_project/core/error/failures.dart';
import 'package:shop_keeper_project/core/usecases/usecase.dart';
import 'package:shop_keeper_project/features/sales/domain/entities/sale_entity.dart';
import 'package:shop_keeper_project/features/sales/domain/repositories/sales_repository.dart';
import 'package:equatable/equatable.dart';

class GetSalesByRange implements UseCase<List<SaleEntity>, SalesRangeParams> {
  final SalesRepository repository;

  GetSalesByRange(this.repository);

  @override
  Future<Either<Failure, List<SaleEntity>>> call(SalesRangeParams params) async {
    return await repository.getSalesByRange(params.start, params.end);
  }
}

class SalesRangeParams extends Equatable {
  final DateTime start;
  final DateTime end;

  const SalesRangeParams({required this.start, required this.end});

  @override
  List<Object> get props => [start, end];
}
