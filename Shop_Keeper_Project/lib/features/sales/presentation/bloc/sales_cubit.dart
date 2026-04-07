import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:shop_keeper_project/features/sales/domain/entities/sale_entity.dart';
import 'package:shop_keeper_project/features/sales/domain/usecases/get_sales_by_date.dart';
import 'package:shop_keeper_project/features/sales/domain/usecases/add_sale.dart';
import 'package:shop_keeper_project/features/sales/domain/usecases/get_today_sales_summary.dart';
import 'package:shop_keeper_project/features/sales/domain/usecases/get_sales_by_range.dart';

part 'sales_state.dart';

class SalesCubit extends Cubit<SalesState> {
  final GetSalesByDate getSalesByDate;
  final GetSalesByRange getSalesByRange;
  final AddSale addSaleUseCase;
  final GetTodaySalesSummary getSummary;

  SalesCubit({
    required this.getSalesByDate,
    required this.getSalesByRange,
    required this.addSaleUseCase,
    required this.getSummary,
  }) : super(SalesInitial());

  Future<void> loadTodaySales() async {
    emit(SalesLoading());
    final result = await getSalesByDate(DateTime.now());
    result.fold(
      (failure) => emit(SalesError(failure.message)),
      (sales) => emit(SalesLoaded(sales)),
    );
  }

  Future<void> loadSalesByRange(DateTime start, DateTime end) async {
    emit(SalesLoading());
    final result = await getSalesByRange(SalesRangeParams(start: start, end: end));
    result.fold(
      (failure) => emit(SalesError(failure.message)),
      (sales) => emit(SalesLoaded(sales)),
    );
  }

  Future<void> addSale(SaleEntity sale) async {
    emit(SalesLoading());
    final result = await addSaleUseCase(sale);
    result.fold(
      (failure) => emit(SalesError(failure.message)),
      (_) => loadTodaySales(),
    );
  }
}
