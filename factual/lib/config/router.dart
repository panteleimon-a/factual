import 'package:go_router/go_router.dart';
import '../screens/home_screen.dart';
import '../screens/search_screen.dart';
import '../screens/search_results_screen.dart';
import '../screens/article_detail_screen.dart';
import '../screens/news_detail_screen.dart';
import '../screens/map_screen.dart';
import '../screens/profile_screen.dart';
import '../screens/search_history_screen.dart';
import '../screens/settings_screen.dart';
import '../models/news_article.dart';

import '../screens/loading_screen.dart';
import '../screens/auth_screen.dart';
import '../screens/sign_in_screen.dart';
import '../screens/sign_up_screen.dart';
import '../screens/forgot_password_screen.dart';
import '../screens/regional_news_detail_screen.dart';
import '../screens/worldwide_deep_analysis_screen.dart';
import '../screens/query_analysis_screen.dart';
import '../screens/debug_analytics_screen.dart';

final router = GoRouter(
  initialLocation: '/loading',
  routes: [
    GoRoute(
      path: '/loading',
      builder: (context, state) => const LoadingScreen(),
    ),
    GoRoute(
      path: '/auth',
      builder: (context, state) => const AuthScreen(),
    ),
    GoRoute(
      path: '/sign-in',
      builder: (context, state) => const SignInScreen(),
    ),
    GoRoute(
      path: '/sign-up',
      builder: (context, state) => const SignUpScreen(),
    ),
    GoRoute(
      path: '/history',
      builder: (context, state) => const SearchHistoryScreen(),
    ),
    GoRoute(
      path: '/regional-news',
      builder: (context, state) => const RegionalNewsDetailScreen(),
    ),
    GoRoute(
      path: '/forgot-password',
      builder: (context, state) => const ForgotPasswordScreen(),
    ),
    GoRoute(
      path: '/',
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: '/search',
      builder: (context, state) {
        final query = state.extra as String?;
        if (query != null) {
          return SearchResultsScreen(query: query);
        }
        return const SearchScreen();
      },
    ),
    GoRoute(
      path: '/article-detail',
      builder: (context, state) {
        final article = state.extra as NewsArticle;
        return ArticleDetailScreen(article: article);
      },
    ),
    GoRoute(
      path: '/map',
      builder: (context, state) => const MapScreen(),
    ),
    GoRoute(
      path: '/settings',
      builder: (context, state) => const SettingsScreen(),
    ),
    GoRoute(
      path: '/profile',
      builder: (context, state) => const ProfileScreen(),
    ),
    GoRoute(
      path: '/worldwide-deep',
      builder: (context, state) => const WorldwideDeepAnalysisScreen(),
    ),
    GoRoute(
      path: '/query-analysis',
      builder: (context, state) {
        final query = state.extra as String;
        return QueryAnalysisScreen(query: query);
      },
    ),
    GoRoute(
      path: '/debug-analytics',
      builder: (context, state) => const DebugAnalyticsScreen(),
    ),
  ],
);
