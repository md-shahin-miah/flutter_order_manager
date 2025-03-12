import 'package:flutter_order_manager/domain/entities/order.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';

class OrderLocalDataSource {
  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final documentsDirectory = await getApplicationDocumentsDirectory();
    final path = join(documentsDirectory.path, 'orders.db');
    return await openDatabase(
      path,
      version: 1, // Increased version number for schema change
      onCreate: _createDb,
    );
  }

  Future<void> _createDb(Database db, int version) async {
    await db.execute('''
      CREATE TABLE orders(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        items TEXT,
        createdTime TEXT,
        deliveryTime TEXT,
        customerNote TEXT,
        pickupTime TEXT,
        status TEXT,
        readyStatus TEXT,
        customerMobile TEXT,
        customerName TEXT
      )
    ''');
  }

  Future<void> _upgradeDb(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Add columns for version 2
      await db.execute('ALTER TABLE orders ADD COLUMN readyStatus TEXT DEFAULT "Pickup in"');
      await db.execute('ALTER TABLE orders ADD COLUMN customerMobile TEXT DEFAULT ""');
    }
    
    if (oldVersion < 3) {
      // Add createdTime column and remove name column for version 3
      await db.execute('ALTER TABLE orders ADD COLUMN createdTime TEXT DEFAULT "${DateTime.now().toIso8601String()}"');
      
      // We can't drop columns in SQLite easily, so we'll just ignore the name column if it exists
    }
  }

  Future<List<Order>> getOrders() async {
    final db = await database;
    final maps = await db.query('orders');
    return List.generate(maps.length, (i) => Order.fromMap(maps[i]));
  }

  Future<List<Order>> getOrdersByStatus(String status) async {
    final db = await database;
    final maps = await db.query(
      'orders',
      where: 'status = ?',
      whereArgs: [status],
    );
    return List.generate(maps.length, (i) => Order.fromMap(maps[i]));
  }

  Future<Order?> getOrderById(int id) async {
    final db = await database;
    final maps = await db.query(
      'orders',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return Order.fromMap(maps.first);
    }
    return null;
  }

  Future<int> addOrder(Order order) async {
    final db = await database;
    return await db.insert('orders', order.toMap());
  }

  Future<int> updateOrder(Order order) async {
    final db = await database;
    return await db.update(
      'orders',
      order.toMap(),
      where: 'id = ?',
      whereArgs: [order.id],
    );
  }

  Future<int> deleteOrder(int id) async {
    final db = await database;
    return await db.delete(
      'orders',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> updateReadyStatus(int id, String readyStatus) async {
    final db = await database;
    return await db.update(
      'orders',
      {'readyStatus': readyStatus},
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}

