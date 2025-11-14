import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key, this.useScaffold = true});

  final bool useScaffold;

  @override
  Widget build(BuildContext context) {
    final content = Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.home, size: 80, color: Colors.grey),
          const SizedBox(height: 16),
          const Text('Home Screen'),
          const SizedBox(height: 8),
          Text(
            'Welcome to the Home Screen!',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );

    if (useScaffold) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Home'),
        ),
        body: content,
      );
    } else {
      return content;
    }
  }
}
