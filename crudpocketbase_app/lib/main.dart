import 'package:flutter/material.dart';
import 'pages/news_page.dart'; 
import 'scripts/create_initial_news.dart';

void main() {
  runApp(const App());
  addInitialNews();
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'News (PocketBase)',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      home: const NewsPage(), // <- หน้าแรก = ข่าว
    );
  }
}
