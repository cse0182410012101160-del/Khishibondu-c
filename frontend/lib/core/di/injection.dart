import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:agro_bridge/core/storage/cache_service.dart';
import 'package:agro_bridge/core/network/api_client.dart';
import 'package:agro_bridge/core/network/offline_request_queue.dart';
import 'package:agro_bridge/core/localization/app_localizations.dart';
import 'package:agro_bridge/core/plugins/plugin_registry.dart';
import 'package:agro_bridge/core/geo/location_service.dart';

// Feature Plugins
import 'package:agro_bridge/features/plugins/ai_disease_plugin.dart';
import 'package:agro_bridge/features/plugins/yield_prediction_plugin.dart';

// Auth
import 'package:agro_bridge/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:agro_bridge/features/auth/domain/repositories/auth_repository.dart';
import 'package:agro_bridge/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:agro_bridge/features/auth/presentation/bloc/auth_bloc.dart';

// Marketplace
import 'package:agro_bridge/features/marketplace/data/datasources/marketplace_remote_data_source.dart';
import 'package:agro_bridge/features/marketplace/domain/repositories/marketplace_repository.dart';
import 'package:agro_bridge/features/marketplace/data/repositories/marketplace_repository_impl.dart';
import 'package:agro_bridge/features/marketplace/presentation/bloc/marketplace_bloc.dart';

// Orders
import 'package:agro_bridge/features/orders/data/datasources/orders_remote_data_source.dart';
import 'package:agro_bridge/features/orders/domain/repositories/orders_repository.dart';
import 'package:agro_bridge/features/orders/data/repositories/orders_repository_impl.dart';
import 'package:agro_bridge/features/orders/presentation/bloc/orders_bloc.dart';

// Escrow
import 'package:agro_bridge/features/escrow/data/datasources/escrow_remote_data_source.dart';
import 'package:agro_bridge/features/escrow/domain/repositories/escrow_repository.dart';
import 'package:agro_bridge/features/escrow/data/repositories/escrow_repository_impl.dart';
import 'package:agro_bridge/features/escrow/presentation/bloc/escrow_bloc.dart';

// Microfinance
import 'package:agro_bridge/features/microfinance/data/datasources/microfinance_remote_data_source.dart';
import 'package:agro_bridge/features/microfinance/domain/repositories/microfinance_repository.dart';
import 'package:agro_bridge/features/microfinance/data/repositories/microfinance_repository_impl.dart';
import 'package:agro_bridge/features/microfinance/presentation/bloc/microfinance_bloc.dart';

// Weather
import 'package:agro_bridge/features/weather/data/datasources/weather_remote_data_source.dart';
import 'package:agro_bridge/features/weather/domain/repositories/weather_repository.dart';
import 'package:agro_bridge/features/weather/data/repositories/weather_repository_impl.dart';
import 'package:agro_bridge/features/weather/presentation/bloc/weather_bloc.dart';

// Traceability
import 'package:agro_bridge/features/traceability/data/datasources/traceability_remote_data_source.dart';
import 'package:agro_bridge/features/traceability/domain/repositories/traceability_repository.dart';
import 'package:agro_bridge/features/traceability/data/repositories/traceability_repository_impl.dart';
import 'package:agro_bridge/features/traceability/presentation/bloc/traceability_bloc.dart';

// Chat
import 'package:agro_bridge/features/chat/data/datasources/chat_remote_data_source.dart';
import 'package:agro_bridge/features/chat/domain/repositories/chat_repository.dart';
import 'package:agro_bridge/features/chat/data/repositories/chat_repository_impl.dart';
import 'package:agro_bridge/features/chat/presentation/bloc/chat_bloc.dart';

// Analytics
import 'package:agro_bridge/features/analytics/data/datasources/analytics_remote_data_source.dart';
import 'package:agro_bridge/features/analytics/domain/repositories/analytics_repository.dart';
import 'package:agro_bridge/features/analytics/data/repositories/analytics_repository_impl.dart';
import 'package:agro_bridge/features/analytics/presentation/bloc/analytics_bloc.dart';
import 'package:agro_bridge/features/catalog/data/repositories/catalog_repository_impl.dart';
import 'package:agro_bridge/features/catalog/domain/repositories/catalog_repository.dart';
import 'package:agro_bridge/features/catalog/presentation/bloc/catalog_bloc.dart';

final sl = GetIt.instance;

Future<void> initDependencies() async {
  // 1. Core Services
  final sharedPrefs = await SharedPreferences.getInstance();
  sl.registerSingleton<SharedPreferences>(sharedPrefs);

  final cacheService = CacheService(sl<SharedPreferences>());
  sl.registerSingleton<CacheService>(cacheService);

  // Location service (GPS market discovery + weather-alert geofencing)
  sl.registerSingleton<LocationService>(LocationService.instance);

  final apiClient = ApiClient(sl<CacheService>());
  sl.registerSingleton<ApiClient>(apiClient);
  final offlineQueue = OfflineRequestQueue();
  await offlineQueue.initialize(sender: (path, payload, type) async {
    await apiClient.post(path, data: payload);
  });
  sl.registerSingleton<OfflineRequestQueue>(offlineQueue);

  final localeCubit = LocaleCubit(sl<SharedPreferences>());
  sl.registerSingleton<LocaleCubit>(localeCubit);

  // 2. Extensible Plugin & Feature-Flag Registry
  final pluginRegistry = PluginRegistry();
  pluginRegistry.register(AiDiseaseDetectionPlugin(), defaultActive: true);
  pluginRegistry.register(YieldPredictionPlugin(), defaultActive: true);
  sl.registerSingleton<PluginRegistry>(pluginRegistry);

  // 3. Auth
  sl.registerLazySingleton<AuthRemoteDataSource>(
      () => AuthRemoteDataSourceImpl(sl<ApiClient>()));
  sl.registerLazySingleton<AuthRepository>(
      () => AuthRepositoryImpl(sl<AuthRemoteDataSource>(), sl<CacheService>()));
  sl.registerFactory<AuthBloc>(
      () => AuthBloc(sl<AuthRepository>(), sl<ApiClient>()));

  // 4. Marketplace
  sl.registerLazySingleton<MarketplaceRemoteDataSource>(() =>
      MarketplaceRemoteDataSourceImpl(
          sl<ApiClient>(), sl<OfflineRequestQueue>()));
  sl.registerLazySingleton<MarketplaceRepository>(() =>
      MarketplaceRepositoryImpl(
          sl<MarketplaceRemoteDataSource>(), sl<CacheService>()));
  sl.registerFactory<MarketplaceBloc>(
      () => MarketplaceBloc(sl<MarketplaceRepository>()));

  // 5. Orders
  sl.registerLazySingleton<OrdersRemoteDataSource>(
      () => OrdersRemoteDataSourceImpl(sl<ApiClient>()));
  sl.registerLazySingleton<OrdersRepository>(
      () => OrdersRepositoryImpl(sl<OrdersRemoteDataSource>()));
  sl.registerFactory<OrdersBloc>(() => OrdersBloc(sl<OrdersRepository>()));

  // 6. Escrow
  sl.registerLazySingleton<EscrowRemoteDataSource>(
      () => EscrowRemoteDataSourceImpl(sl<ApiClient>()));
  sl.registerLazySingleton<EscrowRepository>(
      () => EscrowRepositoryImpl(sl<EscrowRemoteDataSource>()));
  sl.registerFactory<EscrowBloc>(() => EscrowBloc(sl<EscrowRepository>()));

  // 7. Microfinance
  sl.registerLazySingleton<MicrofinanceRemoteDataSource>(
      () => MicrofinanceRemoteDataSourceImpl(sl<ApiClient>()));
  sl.registerLazySingleton<MicrofinanceRepository>(
      () => MicrofinanceRepositoryImpl(sl<MicrofinanceRemoteDataSource>()));
  sl.registerFactory<MicrofinanceBloc>(
      () => MicrofinanceBloc(sl<MicrofinanceRepository>()));

  // 8. Weather
  sl.registerLazySingleton<WeatherRemoteDataSource>(
      () => WeatherRemoteDataSourceImpl(sl<ApiClient>()));
  sl.registerLazySingleton<WeatherRepository>(() =>
      WeatherRepositoryImpl(sl<WeatherRemoteDataSource>(), sl<CacheService>()));
  sl.registerFactory<WeatherBloc>(() => WeatherBloc(sl<WeatherRepository>()));

  // 9. Traceability
  sl.registerLazySingleton<TraceabilityRemoteDataSource>(
      () => TraceabilityRemoteDataSourceImpl(sl<ApiClient>()));
  sl.registerLazySingleton<TraceabilityRepository>(
      () => TraceabilityRepositoryImpl(sl<TraceabilityRemoteDataSource>()));
  sl.registerFactory<TraceabilityBloc>(
      () => TraceabilityBloc(sl<TraceabilityRepository>()));

  // 10. Chat
  sl.registerLazySingleton<ChatRemoteDataSource>(
      () => ChatRemoteDataSourceImpl(sl<ApiClient>()));
  sl.registerLazySingleton<ChatRepository>(
      () => ChatRepositoryImpl(sl<ChatRemoteDataSource>()));
  sl.registerFactory<ChatBloc>(() => ChatBloc(sl<ChatRepository>()));

  // 11. Analytics
  sl.registerLazySingleton<AnalyticsRemoteDataSource>(
      () => AnalyticsRemoteDataSourceImpl(sl<ApiClient>()));
  sl.registerLazySingleton<AnalyticsRepository>(
      () => AnalyticsRepositoryImpl(sl<AnalyticsRemoteDataSource>()));
  sl.registerFactory<AnalyticsBloc>(
      () => AnalyticsBloc(sl<AnalyticsRepository>()));

  // 12. Catalog
  sl.registerLazySingleton<CatalogRepository>(
      () => CatalogRepositoryImpl(sl<ApiClient>()));
  sl.registerFactory<CatalogBloc>(() => CatalogBloc(sl<CatalogRepository>()));
}
