import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class KeuanganHelper {
  // Database name and version
  static final _databaseName = "Keuangan.db";
  static final _databaseVersion = 1;

  // Table name and column names
  static final table = 'keuangan';

  static final columnId = 'id';
  static final columnTanggal = 'tanggal';
  static final columnCatatan = 'catatan';
  static final columnUangMasuk = 'uangmasuk';
  static final columnUangKeluar = 'uangkeluar';
  static final columnSaldo = 'saldo';

  // Singleton class
  KeuanganHelper._privateConstructor();
  static final KeuanganHelper instance = KeuanganHelper._privateConstructor();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  // Initialize database
  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), _databaseName);
    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
    );
  }

  // Create the table
  Future _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $table (
        $columnId INTEGER PRIMARY KEY AUTOINCREMENT,
        $columnTanggal TEXT NOT NULL,
        $columnCatatan TEXT NOT NULL,
        $columnUangMasuk REAL NOT NULL,
        $columnUangKeluar REAL NOT NULL,
        $columnSaldo REAL NOT NULL
      )
    ''');
  }

  // Insert new record
  Future<int> insert(Map<String, dynamic> row) async {
    Database db = await instance.database;
    return await db.insert(table, row);
  }

  // Retrieve all records
  Future<List<Map<String, dynamic>>> queryAllRows() async {
    Database db = await instance.database;
    return await db.query(table);
  }

  // Update a record
  Future<int> update(Map<String, dynamic> row) async {
    Database db = await instance.database;
    int id = row[columnId];
    return await db.update(table, row, where: '$columnId = ?', whereArgs: [id]);
  }

  // Delete a record
  Future<int> delete(int id) async {
    Database db = await instance.database;
    return await db.delete(table, where: '$columnId = ?', whereArgs: [id]);
  }

  // Calculate total money in
  Future<double> totalUangMasuk() async {
    Database db = await instance.database;
    final result =
        await db.rawQuery('SELECT SUM($columnUangMasuk) as total FROM $table');
    return result.isNotEmpty && result.first['total'] != null
        ? result.first['total'] as double
        : 0.0;
  }

  // Calculate total money out
  Future<double> totalUangKeluar() async {
    Database db = await instance.database;
    final result =
        await db.rawQuery('SELECT SUM($columnUangKeluar) as total FROM $table');
    return result.isNotEmpty && result.first['total'] != null
        ? result.first['total'] as double
        : 0.0;
  }

  // Calculate balance
  Future<double> calculateSaldo() async {
    double totalMasuk = await totalUangMasuk();
    double totalKeluar = await totalUangKeluar();
    return totalMasuk - totalKeluar; // Saldo = total masuk - total keluar
  }
}
