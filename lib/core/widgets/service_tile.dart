import 'package:flutter/material.dart';

class ServiceTile extends StatelessWidget {
  const ServiceTile({super.key});

  @override
  Widget build(BuildContext context) {
    return const ListTile(
      leading: Icon(Icons.room_service),
      title: Text('Service Name'),
      subtitle: Text('Service details...'),
    );
  }
}
