import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'config/theme.dart';
import 'config/router.dart';
import 'providers/user_provider.dart';
import 'providers/news_provider.dart';
import 'providers/location_provider.dart';
import 'services/database_service.dart';
import 'services/news_service.dart';
import 'services/llm_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize services
  final databaseService = DatabaseService();
  // DatabaseService initializes lazily, no explicit init needed if not defined
  
  final llmService = LLMService();
  final newsService = NewsService();
  
  runApp(FactualApp(
    databaseService: databaseService,
    newsService: newsService,
    llmService: llmService,
  ));
}

class FactualApp extends StatelessWidget {
  final DatabaseService databaseService;
  final NewsService newsService;
  final LLMService llmService;

  const FactualApp({
    super.key,
    required this.databaseService,
    required this.newsService,
    required this.llmService,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Services (as providers for easy access)
        Provider<DatabaseService>.value(value: databaseService),
        Provider<NewsService>.value(value: newsService),
        Provider<LLMService>.value(value: llmService),
        
        // State providers
        ChangeNotifierProvider(
          create: (_) => UserProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => NewsProvider(newsService),
        ),
        ChangeNotifierProvider(
          create: (_) => LocationProvider(),
        ),
      ],
      child: MaterialApp.router(
        title: 'Factual',
        theme: FactualTheme.lightTheme,
        routerConfig: router,
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
