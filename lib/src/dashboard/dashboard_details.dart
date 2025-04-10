import 'package:flutter/material.dart';

class DashboardDetails extends StatelessWidget {
  const DashboardDetails({super.key});

  static const routeName = '/dashboardDetails';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Details'),
      ),
      body: const Center(
        child: Text('More Information Here'),
      ),
    );
  }
}
