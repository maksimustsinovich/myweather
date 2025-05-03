import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_background_service_android/flutter_background_service_android.dart';
import 'package:pedometer/pedometer.dart';
import 'package:myweather/services/db_helper.dart';

/// Точка входа — инициализируем сервис
void initializeBackgroundService() {
  final service = FlutterBackgroundService();
  service.configure(
    androidConfiguration: AndroidConfiguration(
      onStart: onServiceStart,
      autoStart: true,
      isForegroundMode: true,
      notificationChannelId: 'step_service_channel',
      initialNotificationTitle: 'Шагомер (фон)',
      initialNotificationContent: 'Отслеживает шаги в фоне',
    ),
    iosConfiguration: IosConfiguration(
      autoStart: true,
      onForeground: onServiceStart,
      onBackground: onIosBackground,
    ),
  );
  service.startService();
}

/// Запуск «рабочей» части сервиса
void onServiceStart(ServiceInstance service) {
  WidgetsFlutterBinding.ensureInitialized();
  final pedometer = Pedometer();

  // Слушаем события шагомера
  Pedometer.stepCountStream.listen((event) async {
    final ts = event.timeStamp.millisecondsSinceEpoch;
    final steps = event.steps;
    // Сохраняем каждое событие в БД
    await DBHelper.insertStepEvent(ts, steps);
  }, onError: (e) {
    print('Ошибка фонового шагомера: $e');
  });

  // Обработка команды остановки (если потребуется)
  service.on('stopService').listen((_) {
    service.stopSelf();
  });
}

/// iOS Background Fetch
bool onIosBackground(ServiceInstance service) {
  onServiceStart(service);
  return true;
}
