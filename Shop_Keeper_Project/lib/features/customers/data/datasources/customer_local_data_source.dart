import 'package:hive_flutter/hive_flutter.dart';
import 'package:shop_keeper_project/database/tables/customer_table.dart';
import 'package:shop_keeper_project/database/tables/credit_transaction_table.dart';

abstract class CustomerLocalDataSource {
  Future<List<CustomerTable>> getCustomers();
  Future<CustomerTable?> getCustomerById(String id);
  Future<void> saveCustomer(CustomerTable customer);
  Future<void> deleteCustomer(String id);
  Future<List<CreditTransactionTable>> getTransactions(String customerId);
  Future<void> saveTransaction(CreditTransactionTable transaction);
}

class CustomerLocalDataSourceImpl implements CustomerLocalDataSource {
  final Box<CustomerTable> customerBox;
  final Box<CreditTransactionTable> transactionBox;

  CustomerLocalDataSourceImpl({
    required this.customerBox,
    required this.transactionBox,
  });

  @override
  Future<List<CustomerTable>> getCustomers() async {
    return customerBox.values.toList();
  }

  @override
  Future<CustomerTable?> getCustomerById(String id) async {
    return customerBox.get(id);
  }

  @override
  Future<void> saveCustomer(CustomerTable customer) async {
    await customerBox.put(customer.id, customer);
  }

  @override
  Future<void> deleteCustomer(String id) async {
    await customerBox.delete(id);
    // Also delete all transactions for this customer
    final transactionsToDelete = transactionBox.values
        .where((t) => t.customerId == id)
        .map((t) => t.id)
        .toList();
    for (final txId in transactionsToDelete) {
      await transactionBox.delete(txId);
    }
  }

  @override
  Future<List<CreditTransactionTable>> getTransactions(String customerId) async {
    return transactionBox.values
        .where((t) => t.customerId == customerId)
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date)); // Newest first
  }

  @override
  Future<void> saveTransaction(CreditTransactionTable transaction) async {
    await transactionBox.put(transaction.id, transaction);
  }
}
