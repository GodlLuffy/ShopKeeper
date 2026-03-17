import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:shop_keeper_project/features/sales/domain/entities/sale_entity.dart';
import 'package:shop_keeper_project/features/sales/domain/repositories/sales_repository.dart';

part 'sales_state.dart';

class SalesCubit extends Cubit<SalesState> {
  final SalesRepository repository;

  SalesCubit({required this.repository}) : super(SalesInitial());

  Future<void> loadTodaySales() async {
    emit(SalesLoading());
    final result = await repository.getSalesByDate(DateTime.now());
    result.fold(
      (failure) => emit(SalesError(failure.message)),
      (sales) => emit(SalesLoaded(sales)),
    );
  }

  Future<void> addSale(SaleEntity sale) async {
    emit(SalesLoading());
    final result = await repository.addSale(sale);
    result.fold(
      (failure) => emit(SalesError(failure.message)),
      (_) => loadTodaySales(),
    );
  }
}
