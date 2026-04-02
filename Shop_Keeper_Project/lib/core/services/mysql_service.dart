import 'package:mysql_client/mysql_client.dart';
import 'dart:async';

class MySQLService {
  MySQLConnection? _connection;
  final String host;
  final int port;
  final String userName;
  final String password;
  final String databaseName;

  MySQLService({
    required this.host,
    required this.port,
    required this.userName,
    required this.password,
    required this.databaseName,
  });

  bool get isConnected => _connection != null && _connection!.connected;

  Future<bool> connect() async {
    try {
      _connection = await MySQLConnection.createConnection(
        host: host,
        port: port,
        userName: userName,
        password: password,
        databaseName: databaseName,
      );

      await _connection!.connect();
      return true;
    } catch (e) {
      print('MySQL Connection Error: $e');
      return false;
    }
  }

  Future<void> execute(String query, [Map<String, dynamic>? params]) async {
    if (!isConnected) {
      final success = await connect();
      if (!success) throw Exception('Could not connect to MySQL');
    }

    try {
      await _connection!.execute(query, params);
    } catch (e) {
      print('MySQL Execution Error: $e');
      rethrow;
    }
  }

  Future<void> disconnect() async {
    if (_connection != null) {
      await _connection!.close();
      _connection = null;
    }
  }

  Future<void> initializeSchema() async {
    final tables = [
      """
      CREATE TABLE IF NOT EXISTS products (
          id VARCHAR(255) PRIMARY KEY,
          name VARCHAR(255) NOT NULL,
          category VARCHAR(100),
          buy_price DECIMAL(10,2),
          sell_price DECIMAL(10,2),
          stock_quantity INT,
          min_stock_alert INT,
          user_id VARCHAR(255),
          created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
          updated_at TIMESTAMP NULL ON UPDATE CURRENT_TIMESTAMP,
          barcode VARCHAR(100),
          image_url TEXT
      )
      """,
      """
      CREATE TABLE IF NOT EXISTS sales (
          id VARCHAR(255) PRIMARY KEY,
          product_id VARCHAR(255),
          product_name VARCHAR(255),
          quantity_sold INT,
          sale_price DECIMAL(10,2),
          total_amount DECIMAL(10,2),
          total_profit DECIMAL(10,2),
          date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
          user_id VARCHAR(255)
      )
      """,
      """
      CREATE TABLE IF NOT EXISTS expenses (
          id VARCHAR(255) PRIMARY KEY,
          title VARCHAR(255) NOT NULL,
          amount DECIMAL(10,2) NOT NULL,
          category VARCHAR(100),
          date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
          user_id VARCHAR(255)
      )
      """,
      """
      CREATE TABLE IF NOT EXISTS customers (
          id VARCHAR(255) PRIMARY KEY,
          name VARCHAR(255) NOT NULL,
          phone VARCHAR(20),
          total_credit DECIMAL(10,2) DEFAULT 0.0,
          last_tx_date TIMESTAMP NULL,
          notes TEXT,
          created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
          user_id VARCHAR(255)
      )
      """,
      """
      CREATE TABLE IF NOT EXISTS suppliers (
          id VARCHAR(255) PRIMARY KEY,
          name VARCHAR(255) NOT NULL,
          contact_person VARCHAR(255),
          phone VARCHAR(20),
          address TEXT,
          balance DECIMAL(10,2) DEFAULT 0.0,
          email VARCHAR(255),
          user_id VARCHAR(255),
          created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      )
      """
    ];

    try {
      for (var sql in tables) {
        await execute(sql);
      }
    } catch (e) {
      print('MySQL SCHEMA INITIALIZATION FAILED: $e');
    }
  }

  // --- Sync Handlers ---

  Future<void> upsertProduct(Map<String, dynamic> data) async {
    const query = """
      INSERT INTO products (id, name, category, buy_price, sell_price, stock_quantity, min_stock_alert, user_id, barcode, image_url)
      VALUES (:id, :name, :category, :buyPrice, :sellPrice, :stockQuantity, :minStockAlert, :userId, :barcode, :imageUrl)
      ON DUPLICATE KEY UPDATE
      name = VALUES(name),
      category = VALUES(category),
      buy_price = VALUES(buy_price),
      sell_price = VALUES(sell_price),
      stock_quantity = VALUES(stock_quantity),
      min_stock_alert = VALUES(min_stock_alert),
      barcode = VALUES(barcode),
      image_url = VALUES(image_url)
    """;
    try {
      final sanitizedData = {
        'id': data['id'] ?? '',
        'name': data['name'] ?? 'Unknown Product',
        'category': data['category'] ?? '',
        'buyPrice': (data['buyPrice'] ?? 0.0).toDouble(),
        'sellPrice': (data['sellPrice'] ?? 0.0).toDouble(),
        'stockQuantity': data['stockQuantity'] ?? 0,
        'minStockAlert': data['minStockAlert'] ?? 0,
        'userId': data['userId'] ?? '',
        'barcode': data['barcode'] ?? '',
        'imageUrl': data['imageUrl'] ?? '',
      };
      await execute(query, sanitizedData);
    } catch (e) {
      print('MySQL UPSERT PRODUCT FAILED: $e');
    }
  }

  Future<void> insertSale(Map<String, dynamic> data) async {
    const query = """
      INSERT INTO sales (id, product_id, product_name, quantity_sold, sale_price, total_amount, total_profit, date, user_id)
      VALUES (:id, :productId, :productName, :quantitySold, :salePrice, :totalAmount, :totalProfit, :date, :userId)
    """;
    try {
      final sanitizedData = {
        'id': data['id'] ?? '',
        'productId': data['productId'] ?? '',
        'productName': data['productName'] ?? '',
        'quantitySold': data['quantitySold'] ?? 0,
        'salePrice': (data['salePrice'] ?? 0.0).toDouble(),
        'totalAmount': (data['totalAmount'] ?? 0.0).toDouble(),
        'totalProfit': (data['totalProfit'] ?? 0.0).toDouble(),
        'date': data['date'] ?? DateTime.now().toIso8601String(),
        'userId': data['userId'] ?? '',
      };
      await execute(query, sanitizedData);
    } catch (e) {
      print('MySQL INSERT SALE FAILED: $e');
    }
  }

  Future<void> insertExpense(Map<String, dynamic> data) async {
    const query = """
      INSERT INTO expenses (id, title, amount, category, date, user_id)
      VALUES (:id, :title, :amount, :category, :date, :userId)
    """;
    try {
      final sanitizedData = {
        'id': data['id'] ?? '',
        'title': data['title'] ?? '',
        'amount': (data['amount'] ?? 0.0).toDouble(),
        'category': data['category'] ?? '',
        'date': data['date'] ?? DateTime.now().toIso8601String(),
        'userId': data['userId'] ?? '',
      };
      await execute(query, sanitizedData);
    } catch (e) {
      print('MySQL INSERT EXPENSE FAILED: $e');
    }
  }

  Future<void> upsertCustomer(Map<String, dynamic> data) async {
    const query = """
      INSERT INTO customers (id, name, phone, total_credit, last_tx_date, notes, user_id)
      VALUES (:id, :name, :phone, :totalCredit, :lastTransactionDate, :notes, :userId)
      ON DUPLICATE KEY UPDATE
      name = VALUES(name),
      phone = VALUES(phone),
      total_credit = VALUES(total_credit),
      last_tx_date = VALUES(last_tx_date),
      notes = VALUES(notes)
    """;
    try {
      final sanitizedData = {
        'id': data['id'] ?? '',
        'name': data['name'] ?? '',
        'phone': data['phone'] ?? '',
        'totalCredit': (data['totalCredit'] ?? 0.0).toDouble(),
        'lastTransactionDate': data['lastTransactionDate'] ?? '',
        'notes': data['notes'] ?? '',
        'userId': data['userId'] ?? '',
      };
      await execute(query, sanitizedData);
    } catch (e) {
      print('MySQL UPSERT CUSTOMER FAILED: $e');
    }
  }

  Future<void> upsertSupplier(Map<String, dynamic> data) async {
    const query = """
      INSERT INTO suppliers (id, name, contact_person, phone, address, balance, email, user_id)
      VALUES (:id, :name, :contactPerson, :phone, :address, :balance, :email, :userId)
      ON DUPLICATE KEY UPDATE
      name = VALUES(name),
      contact_person = VALUES(contact_person),
      phone = VALUES(phone),
      address = VALUES(address),
      balance = VALUES(balance),
      email = VALUES(email)
    """;
    try {
      final sanitizedData = {
        'id': data['id'] ?? '',
        'name': data['name'] ?? '',
        'contactPerson': data['contactPerson'] ?? '',
        'phone': data['phone'] ?? '',
        'address': data['address'] ?? '',
        'balance': (data['balance'] ?? 0.0).toDouble(),
        'email': data['email'] ?? '',
        'userId': data['userId'] ?? '',
      };
      await execute(query, sanitizedData);
    } catch (e) {
      print('MySQL UPSERT SUPPLIER FAILED: $e');
    }
  }
}
