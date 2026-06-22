import 'package:go_router/go_router.dart';
import '../screens/home_screen.dart';
import '../screens/search_screen.dart';
import '../screens/search_results_screen.dart';
import '../screens/article_detail_screen.dart';
import '../screens/news_detail_screen.dart';
import '../screens/map_screen.dart';
import '../screens/profile_screen.dart';
import '../screens/chat_hub_screen.dart';
import '../screens/settings_screen.dart';
import '../models/news_article.dart';

import '../screens/loading_screen.dart';
import '../screens/auth_screen.dart';
import '../screens/sign_in_screen.dart';
import '../screens/sign_up_screen.dart';
import '../screens/forgot_password_screen.dart';
import '../screens/regional_news_detail_screen.dart';
import '../screens/worldwide_deep_analysis_screen.dart';
import '../screens/debug_analytics_screen.dart';
import '../screens/notifications_screen.dart';
import '../screens/notification_settings_screen.dart';
import '../screens/blocked_users_screen.dart';
import '../screens/language_screen.dart';
import '../screens/clear_data_screen.dart';

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
      builder: (context, state) => const ChatHubScreen(),
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
      path: '/news-detail',
      builder: (context, state) {
        final article = state.extra as NewsArticle;
        return NewsDetailScreen(articleId: article.id);
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
        return ChatHubScreen(initialQuery: query);
      },
    ),
    GoRoute(
      path: '/debug-analytics',
      builder: (context, state) => const DebugAnalyticsScreen(),
    ),
    GoRoute(
      path: '/notifications',
      builder: (context, state) => const NotificationsScreen(),
    ),
    GoRoute(
      path: '/notification-settings',
      builder: (context, state) => const NotificationSettingsScreen(),
    ),
    GoRoute(
      path: '/blocked-users',
      builder: (context, state) => const BlockedUsersScreen(),
    ),
    GoRoute(
      path: '/language',
      builder: (context, state) => const LanguageScreen(),
    ),
    GoRoute(
      path: '/clear-data',
      builder: (context, state) => const ClearDataScreen(),
    ),
  ],
);
