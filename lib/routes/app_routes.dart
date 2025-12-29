import 'package:go_router/go_router.dart';

import '../home/home_shell.dart';
import '../features/result/presentation/scan_result_page.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    /// HOME SHELL (BOTTOM NAV)
    GoRoute(
      path: '/',
      builder: (context, state) => const HomeShell(),
    ),

    /// SCAN RESULT
    GoRoute(
      path: '/result',
      builder: (context, state) {
        final String result = state.extra as String;
        return ScanResultPage(result: result);
      },
    ),
  ],
);
