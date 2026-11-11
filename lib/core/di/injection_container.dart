import 'package:get_it/get_it.dart';

import '../../features/cars/data/repositories/cars_repository_impl.dart';
import '../../features/cars/domain/repositories/cars_repository.dart';
import '../../features/cars/domain/usecases/add_car_photos_usecase.dart';
import '../../features/cars/domain/usecases/add_car_usecase.dart';
import '../../features/cars/domain/usecases/check_vin_unique_usecase.dart';
import '../../features/cars/domain/usecases/delete_car_photo_usecase.dart';
import '../../features/cars/domain/usecases/delete_car_usecase.dart';
import '../../features/cars/domain/usecases/get_all_cars_usecase.dart';
import '../../features/cars/domain/usecases/get_car_by_id_usecase.dart';
import '../../features/cars/domain/usecases/get_car_photos_usecase.dart';
import '../../features/cars/domain/usecases/update_car_status_usecase.dart';
import '../../features/cars/domain/usecases/update_car_usecase.dart';
import '../../features/cars/domain/usecases/watch_active_cars_usecase.dart';
import '../../features/cars/domain/usecases/watch_all_cars_usecase.dart';
import '../../features/cars/domain/usecases/watch_car_photos_usecase.dart';
import '../../features/cars/presentation/cubit/cars_cubit.dart';
import '../../features/dashboard/data/repositories/dashboard_repository_impl.dart';
import '../../features/dashboard/domain/repositories/dashboard_repository.dart';
import '../../features/dashboard/domain/usecases/get_dashboard_data_usecase.dart';
import '../../features/dashboard/domain/usecases/watch_dashboard_data_usecase.dart';
import '../../features/dashboard/presentation/cubit/dashboard_cubit.dart';
import '../../features/history/data/repositories/history_repository_impl.dart';
import '../../features/history/domain/repositories/history_repository.dart';
import '../../features/history/domain/usecases/get_delivered_cars_usecase.dart';
import '../../features/history/domain/usecases/watch_delivered_cars_usecase.dart';
import '../../features/history/presentation/cubit/history_cubit.dart';
import '../../features/settings/data/repositories/notification_settings_repository_impl.dart';
import '../../features/settings/domain/repositories/notification_settings_repository.dart';
import '../../features/settings/presentation/cubit/settings_cubit.dart';
import '../database/app_database.dart';
import '../database/daos/car_photos_dao.dart';
import '../database/daos/cars_dao.dart';
import '../services/car_photo_storage_service.dart';
import '../services/notification_service.dart';
import '../services/notification_service_impl.dart';
import '../services/vehicle_reminder_scheduler.dart';

final sl = GetIt.instance;

Future<void> initDependencies() async {
  // Database & DAOs
  sl.registerLazySingleton<AppDatabase>(() => AppDatabase());
  sl.registerLazySingleton<CarsDao>(() => sl<AppDatabase>().carsDao);
  sl.registerLazySingleton<CarPhotosDao>(() => sl<AppDatabase>().carPhotosDao);

  // Core Services
  sl.registerLazySingleton<CarPhotoStorageService>(
    () => CarPhotoStorageService(),
  );

  sl.registerLazySingleton<NotificationService>(
    () => NotificationServiceImpl(),
  );

  sl.registerLazySingleton<NotificationSettingsRepository>(
    () => NotificationSettingsRepositoryImpl(),
  );

  sl.registerLazySingleton<VehicleReminderScheduler>(
    () => VehicleReminderScheduler(
      notificationService: sl<NotificationService>(),
      settingsRepository: sl<NotificationSettingsRepository>(),
    ),
  );

  // Repositories
  sl.registerLazySingleton<CarsRepository>(
    () => CarsRepositoryImpl(
      carsDao: sl<CarsDao>(),
      carPhotosDao: sl<CarPhotosDao>(),
      photoStorageService: sl<CarPhotoStorageService>(),
      reminderScheduler: sl<VehicleReminderScheduler>(),
    ),
  );

  sl.registerLazySingleton<DashboardRepository>(
    () => DashboardRepositoryImpl(sl<CarsDao>()),
  );

  sl.registerLazySingleton<HistoryRepository>(
    () => HistoryRepositoryImpl(sl<CarsDao>()),
  );

  // Use Cases
  sl.registerLazySingleton(() => GetAllCarsUseCase(sl<CarsRepository>()));
  sl.registerLazySingleton(() => WatchAllCarsUseCase(sl<CarsRepository>()));
  sl.registerLazySingleton(() => WatchActiveCarsUseCase(sl<CarsRepository>()));
  sl.registerLazySingleton(() => GetCarByIdUseCase(sl<CarsRepository>()));
  sl.registerLazySingleton(() => CheckVinUniqueUseCase(sl<CarsRepository>()));
  sl.registerLazySingleton(() => AddCarUseCase(sl<CarsRepository>()));
  sl.registerLazySingleton(() => UpdateCarUseCase(sl<CarsRepository>()));
  sl.registerLazySingleton(() => UpdateCarStatusUseCase(sl<CarsRepository>()));
  sl.registerLazySingleton(() => DeleteCarUseCase(sl<CarsRepository>()));
  sl.registerLazySingleton(() => WatchCarPhotosUseCase(sl<CarsRepository>()));
  sl.registerLazySingleton(() => GetCarPhotosUseCase(sl<CarsRepository>()));
  sl.registerLazySingleton(() => AddCarPhotosUseCase(sl<CarsRepository>()));
  sl.registerLazySingleton(() => DeleteCarPhotoUseCase(sl<CarsRepository>()));
  sl.registerLazySingleton(
    () => GetDashboardDataUseCase(sl<DashboardRepository>()),
  );
  sl.registerLazySingleton(
    () => WatchDashboardDataUseCase(sl<DashboardRepository>()),
  );
  sl.registerLazySingleton(
    () => GetDeliveredCarsUseCase(sl<HistoryRepository>()),
  );
  sl.registerLazySingleton(
    () => WatchDeliveredCarsUseCase(sl<HistoryRepository>()),
  );

  // Cubits
  sl.registerFactory(
    () => DashboardCubit(
      watchDashboardDataUseCase: sl<WatchDashboardDataUseCase>(),
      getDashboardDataUseCase: sl<GetDashboardDataUseCase>(),
    ),
  );
  sl.registerFactory(
    () => HistoryCubit(
      watchDeliveredCarsUseCase: sl<WatchDeliveredCarsUseCase>(),
    ),
  );
  sl.registerFactory(
    () => CarsCubit(
      watchAllCarsUseCase: sl<WatchAllCarsUseCase>(),
      watchActiveCarsUseCase: sl<WatchActiveCarsUseCase>(),
      getCarByIdUseCase: sl<GetCarByIdUseCase>(),
      addCarUseCase: sl<AddCarUseCase>(),
      updateCarUseCase: sl<UpdateCarUseCase>(),
      updateCarStatusUseCase: sl<UpdateCarStatusUseCase>(),
      deleteCarUseCase: sl<DeleteCarUseCase>(),
      watchCarPhotosUseCase: sl<WatchCarPhotosUseCase>(),
      getCarPhotosUseCase: sl<GetCarPhotosUseCase>(),
      addCarPhotosUseCase: sl<AddCarPhotosUseCase>(),
      deleteCarPhotoUseCase: sl<DeleteCarPhotoUseCase>(),
      checkVinUniqueUseCase: sl<CheckVinUniqueUseCase>(),
    ),
  );
  sl.registerFactory(
    () => SettingsCubit(
      settingsRepository: sl<NotificationSettingsRepository>(),
      notificationService: sl<NotificationService>(),
      reminderScheduler: sl<VehicleReminderScheduler>(),
      carsRepository: sl<CarsRepository>(),
    ),
  );
}
