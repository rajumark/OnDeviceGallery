import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'viewmodels/gallery_viewmodel.dart';
import 'models/image_model.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const OnDeviceGalleryApp());
}

class OnDeviceGalleryApp extends StatelessWidget {
  const OnDeviceGalleryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'OnDeviceGallery',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.light,
        ),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.dark,
        ),
      ),
      themeMode: ThemeMode.system,
      home: const HomeScreen(),
    );
  }
}
