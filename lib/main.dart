import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:google_sign_in/google_sign_in.dart';
import 'firebase_options.dart';
import 'core/themes/app_theme.dart';
import 'data/datasources/local/database_helper.dart';
import 'data/datasources/local/resume_local_datasource.dart';
import 'data/datasources/local/user_local_datasource.dart';
import 'data/datasources/remote/auth_remote_datasource.dart';
import 'data/repositories/auth_repository_impl.dart';
import 'data/repositories/resume_repository_impl.dart';
import 'presentation/bloc/auth/auth_bloc.dart';
import 'presentation/bloc/auth/auth_event.dart';
import 'presentation/bloc/auth/auth_state.dart';
import 'presentation/bloc/resume/resume_bloc.dart';
import 'presentation/cubit/theme_cubit.dart';
import 'presentation/screens/auth/login_screen.dart';
import 'presentation/screens/home/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Initialize dependencies
    final databaseHelper = DatabaseHelper.instance;
    final resumeLocalDataSource = ResumeLocalDataSource(databaseHelper);
    final resumeRepository = ResumeRepositoryImpl(resumeLocalDataSource);

    final firebaseAuth = firebase_auth.FirebaseAuth.instance;
    final googleSignIn = GoogleSignIn();
    final authRemoteDataSource = AuthRemoteDataSource(
      firebaseAuth,
      googleSignIn,
    );
    final userLocalDataSource = UserLocalDataSource(databaseHelper);
    final authRepository = AuthRepositoryImpl(
      authRemoteDataSource,
      userLocalDataSource,
    );

    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider(create: (_) => authRepository),
        RepositoryProvider(create: (_) => resumeRepository),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) =>
                AuthBloc(authRepository)..add(CheckAuthStatus()),
          ),
          BlocProvider(create: (context) => ResumeBloc(resumeRepository)),
          BlocProvider(create: (context) => ThemeCubit()),
        ],
        child: BlocBuilder<ThemeCubit, ThemeMode>(
          builder: (context, themeMode) {
            return MaterialApp(
              title: 'Resume Creator',
              debugShowCheckedModeBanner: false,
              theme: AppTheme.lightTheme,
              darkTheme: AppTheme.darkTheme,
              themeMode: themeMode, // Can now be toggled manually
              home: BlocBuilder<AuthBloc, AuthState>(
                builder: (context, state) {
                  if (state is AuthLoading || state is AuthInitial) {
                    return const Scaffold(
                      body: Center(child: CircularProgressIndicator()),
                    );
                  } else if (state is Authenticated) {
                    return const HomeScreen();
                  } else {
                    return const LoginScreen();
                  }
                },
              ),
            );
          },
        ),
      ),
    );
  }
}
