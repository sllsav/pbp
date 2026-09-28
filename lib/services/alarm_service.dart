import '../models/alarm_model.dart';
import 'database_service.dart';
import 'notification_service.dart';

class AlarmService {
  final _dbService = DatabaseService.instance;

  Future<int> tambahAlarm(AlarmModel alarm) async {
    final db = await _dbService.database;
    final id = await db.insert('alarm', alarm.toMap()..remove('id'));
    await NotificationService.instance.scheduleDaily(
      id: id,
      title: alarm.judul,
      body: alarm.deskripsi,
      time: alarm.jam,
    );
    return id;
  }

  Future<List<AlarmModel>> getAlarmByUser(int userId) async {
    final db = await _dbService.database;
    final result = await db.query(
      'alarm',
      where: 'userId = ?',
      whereArgs: [userId],
      orderBy: 'jam ASC',
    );
    return result.map(AlarmModel.fromMap).toList();
  }

  Future<void> updateAlarm(AlarmModel alarm) async {
    final db = await _dbService.database;
    await db.update(
      'alarm',
      alarm.toMap(),
      where: 'id = ?',
      whereArgs: [alarm.id],
    );
    if (alarm.id != null && alarm.aktif) {
      await NotificationService.instance.scheduleDaily(
        id: alarm.id!,
        title: alarm.judul,
        body: alarm.deskripsi,
        time: alarm.jam,
      );
    }
  }

  Future<void> toggleAktif(int id, bool aktif) async {
    final db = await _dbService.database;
    await db.update(
      'alarm',
      {'aktif': aktif ? 1 : 0},
      where: 'id = ?',
      whereArgs: [id],
    );
    if (aktif) {
      final alarms = await db.query(
        'alarm',
        where: 'id = ?',
        whereArgs: [id],
        limit: 1,
      );
      if (alarms.isNotEmpty) {
        final alarm = AlarmModel.fromMap(alarms.first);
        await NotificationService.instance.scheduleDaily(
          id: id,
          title: alarm.judul,
          body: alarm.deskripsi,
          time: alarm.jam,
        );
      }
    } else {
      await NotificationService.instance.cancel(id);
    }
  }

  Future<void> hapusAlarm(int id) async {
    final db = await _dbService.database;
    await db.delete('alarm', where: 'id = ?', whereArgs: [id]);
    await NotificationService.instance.cancel(id);
  }
}
