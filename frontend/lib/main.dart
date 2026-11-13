import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'core/di/injection.dart';
import 'core/theme/app_theme.dart';
import 'core/localization/app_localizations.dart';
import 'core/network/firebase_initializer.dart';
import 'core/widgets/agro_image.dart';

// Blocs
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/marketplace/presentation/bloc/marketplace_bloc.dart';
import 'features/orders/presentation/bloc/orders_bloc.dart';
import 'features/escrow/presentation/bloc/escrow_bloc.dart';
import 'features/microfinance/presentation/bloc/microfinance_bloc.dart';
import 'features/weather/presentation/bloc/weather_bloc.dart';
import 'features/traceability/presentation/bloc/traceability_bloc.dart';
import 'features/chat/presentation/bloc/chat_bloc.dart';
import 'features/analytics/presentation/bloc/analytics_bloc.dart';

// Screens
import 'features/auth/presentation/screens/login_screen.dart';
import 'navigation/main_navigation_shell.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await FirebaseInitializer.init();
  } catch (e) {
    debugPrint('Firebase init bypassed: $e');
  }
  await initDependencies();
  runApp(const AgroBridgeApp());
}

class AgroBridgeApp extends StatelessWidget {
  const AgroBridgeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<LocaleCubit>.value(value: sl<LocaleCubit>()),
        BlocProvider<AuthBloc>(create: (_) => sl<AuthBloc>()..add(AppStartedEvent())),
        BlocProvider<MarketplaceBloc>(create: (_) => sl<MarketplaceBloc>()),
        BlocProvider<OrdersBloc>(create: (_) => sl<OrdersBloc>()),
        BlocProvider<EscrowBloc>(create: (_) => sl<EscrowBloc>()),
        BlocProvider<MicrofinanceBloc>(create: (_) => sl<MicrofinanceBloc>()),
        BlocProvider<WeatherBloc>(create: (_) => sl<WeatherBloc>()),
        BlocProvider<TraceabilityBloc>(create: (_) => sl<TraceabilityBloc>()),
        BlocProvider<ChatBloc>(create: (_) => sl<ChatBloc>()),
        BlocProvider<AnalyticsBloc>(create: (_) => sl<AnalyticsBloc>()),
      ],
      child: BlocBuilder<LocaleCubit, Locale>(
        builder: (context, locale) {
          return MaterialApp(
            title: 'Agro-Bridge',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            builder: (context, child) => AgroAppBackdrop(child: child ?? const SizedBox.shrink()),
            locale: locale,
            supportedLocales: const [
              Locale('bn', ''), // Bangla first
              Locale('en', ''), // English
            ],
            localizationsDelegates: const [
              AppLocalizationsDelegate(),
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            home: BlocBuilder<AuthBloc, AuthState>(
              builder: (context, state) {
                if (state is AuthenticatedState) {
                  return MainNavigationShell(currentUser: state.user);
                }
                return const LoginScreen();
              },
            ),
          );
        },
      ),
    );
  }
}
