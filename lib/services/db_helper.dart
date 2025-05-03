// lib/services/db_helper.dart
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';
import '../models/day_stat.dart';

class DBHelper {
  static final _dbName = 'weather_steps.db';
  static final _table = 'day_stats';
  static Database? _db;

  /// Получаем экземпляр базы, создаём при необходимости
  static Future<Database> get db async {
    if (_db != null) return _db!;
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, _dbName);
    _db = await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        // Таблица для сырых событий шагомера
        await db.execute('''
          CREATE TABLE step_events(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            timestamp INTEGER NOT NULL,
            steps INTEGER NOT NULL
          );
        ''');

        // Существующая таблица для итоговой статистики по дате
        await db.execute('''
          CREATE TABLE $_table(
            date TEXT PRIMARY KEY,
            steps INTEGER,
            weather TEXT,
            temp REAL
          );
        ''');
      },
    );
    return _db!;
  }

  /// Вставка или замена записи статистики за день
  static Future<void> upsertStat(DayStat stat) async {
    final client = await db;
    await client.insert(
      _table,
      stat.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Получаем все записи из day_stats (если нужно)
  static Future<List<DayStat>> fetchAll() async {
    final client = await db;
    final maps = await client.query(_table);
    return maps.map((m) => DayStat.fromMap(m)).toList();
  }

  /// Сохраняем каждое событие шагомера с точной меткой времени
  static Future<void> insertStepEvent(int timestamp, int steps) async {
    final client = await db;
    await client.insert('step_events', {
      'timestamp': timestamp,
      'steps': steps,
    });
  }

  /// Достаём агрегированные данные за каждый день и подцепляем к ним погоду
  static Future<List<DayStat>> fetchDailyStatsWithWeather() async {
    final client = await db;
    // Считаем шаги за день: разница между максимальным и минимальным
    final rows = await client.rawQuery('''
      SELECT
        date(timestamp/1000, 'unixepoch', 'localtime') AS date,
        MAX(steps) - MIN(steps) AS steps
      FROM step_events
      GROUP BY date
    ''');

    List<DayStat> stats = [];
    for (var r in rows) {
      final date = r['date'] as String;
      final steps = (r['steps'] as num).toInt();

      // Подцепляем погодные данные из таблицы day_stats
      String weather = '';
      double temp = 0.0;
      final weatherRows = await client.query(
        _table,
        where: 'date = ?',
        whereArgs: [date],
        limit: 1,
      );
      if (weatherRows.isNotEmpty) {
        final m = weatherRows.first;
        weather = m['weather'] as String;
        temp    = (m['temp'] as num).toDouble();
      }

      stats.add(DayStat(
        date: date,
        steps: steps,
        weather: weather,
        temp: temp,
      ));
    }
    return stats;
  }
}
