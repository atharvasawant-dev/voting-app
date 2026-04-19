import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'firebase_options.dart';
import 'models/election_model.dart';
import 'providers/election_provider.dart';
import 'screens/admin_screen.dart';
import 'screens/already_voted_screen.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/results_screen.dart';
import 'screens/success_screen.dart';
import 'screens/voting_screen.dart';
import 'services/auth_service.dart';
import 'services/firestore_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const CivicVoteRoot());
}

class CivicVoteRoot extends StatelessWidget {
  const CivicVoteRoot({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<AuthService>(
          create: (_) => AuthService(),
        ),
        Provider<FirestoreService>(
          create: (_) => FirestoreService(),
        ),
        ChangeNotifierProvider<ElectionProvider>(
          create: (context) => ElectionProvider(
            firestoreService: context.read<FirestoreService>(),
            authService: context.read<AuthService>(),
          ),
        ),
      ],
      child: const CivicVoteApp(),
    );
  }
}

class CivicVoteApp extends StatelessWidget {
  const CivicVoteApp({super.key});

  @override
  Widget build(BuildContext context) {
    const primaryBlue = Color(0xFF0C3D73);
    const accentBlue = Color(0xFF1E5B9B);
    const surfaceBlue = Color(0xFFF4F8FC);

    final colorScheme = ColorScheme.fromSeed(
      seedColor: primaryBlue,
      brightness: Brightness.light,
    ).copyWith(
      primary: primaryBlue,
      secondary: accentBlue,
      surface: Colors.white,
      surfaceContainerHighest: surfaceBlue,
    );

    return MaterialApp(
      title: 'CivicVote',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: colorScheme,
        scaffoldBackgroundColor: surfaceBlue,
        cardTheme: CardThemeData(
          color: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
            side: BorderSide(
              color: primaryBlue.withOpacity(0.06),
            ),
          ),
          margin: EdgeInsets.zero,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          scrolledUnderElevation: 0,
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          selectedItemColor: primaryBlue,
          unselectedItemColor: Color(0xFF7F8DA3),
          showUnselectedLabels: true,
          type: BottomNavigationBarType.fixed,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: BorderSide(
              color: primaryBlue.withOpacity(0.08),
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: const BorderSide(
              color: accentBlue,
              width: 1.4,
            ),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 18,
            vertical: 16,
          ),
        ),
        snackBarTheme: SnackBarThemeData(
          behavior: SnackBarBehavior.floating,
          backgroundColor: primaryBlue,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          contentTextStyle: const TextStyle(color: Colors.white),
        ),
      ),
      initialRoute: AppRoutes.home,
      routes: {
        AppRoutes.home: (_) => const AuthGate(),
        AppRoutes.results: (_) => const AppShell(initialIndex: 1),
        AppRoutes.admin: (_) => const AppShell(initialIndex: 2),
        AppRoutes.login: (_) => const LoginScreen(),
        AppRoutes.register: (_) => const RegisterScreen(),
      },
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case AppRoutes.vote:
            final election = settings.arguments as ElectionModel;
            return MaterialPageRoute(
              builder: (_) => VotingScreen(election: election),
            );
          case AppRoutes.success:
            final electionTitle = settings.arguments as String?;
            return MaterialPageRoute(
              builder: (_) => SuccessScreen(electionTitle: electionTitle),
            );
          case AppRoutes.alreadyVoted:
            final electionTitle = settings.arguments as String?;
            return MaterialPageRoute(
              builder: (_) => AlreadyVotedScreen(electionTitle: electionTitle),
            );
          default:
            return null;
        }
      },
    );
  }
}

class AppRoutes {
  static const home = '/';
  static const results = '/results';
  static const admin = '/admin';
  static const login = '/login';
  static const register = '/register';
  static const vote = '/vote';
  static const success = '/success';
  static const alreadyVoted = '/already-voted';
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = context.read<AuthService>();

    return StreamBuilder(
      stream: authService.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.data == null) {
          return const LoginScreen();
        }

        return const AppShell(initialIndex: 0);
      },
    );
  }
}

class AppShell extends StatefulWidget {
  const AppShell({super.key, required this.initialIndex});

  final int initialIndex;

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      HomeScreen(
        onElectionTap: (election) {
          Navigator.pushNamed(
            context,
            AppRoutes.vote,
            arguments: election,
          );
        },
      ),
      const ResultsScreen(),
      const AdminScreen(),
    ];

    return Scaffold(
      body: SafeArea(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 260),
          child: KeyedSubtree(
            key: ValueKey(_currentIndex),
            child: IndexedStack(
              index: _currentIndex,
              children: pages,
            ),
          ),
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() => _currentIndex = index);
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.how_to_vote_outlined),
            selectedIcon: Icon(Icons.how_to_vote),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.bar_chart_outlined),
            selectedIcon: Icon(Icons.bar_chart),
            label: 'Results',
          ),
          NavigationDestination(
            icon: Icon(Icons.admin_panel_settings_outlined),
            selectedIcon: Icon(Icons.admin_panel_settings),
            label: 'Admin',
          ),
        ],
      ),
    );
  }
}
