import 'package:flutter/material.dart';

class WaitlistScreen extends StatelessWidget {
  const WaitlistScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Waitlist')),
      body: const Center(child: Text('Waitlist — Coming Soon')),
    );
  }
}
