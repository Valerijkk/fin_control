import 'dart:io';
import 'package:flutter/material.dart';
import '../widgets/app_bar_title.dart';

class PhotoViewerScreen extends StatelessWidget {
  final String path;
  const PhotoViewerScreen({super.key, required this.path});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppBarTitle(title: 'Фото', canPop: true),
      body: Center(child: Image.file(File(path))),
    );
  }
}
