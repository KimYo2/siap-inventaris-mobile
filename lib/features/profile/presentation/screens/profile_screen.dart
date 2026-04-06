import 'package:flutter/material.dart';
import '../../../../core/widgets/user_scaffold.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const UserScaffold(
      title: 'Profil',
      body: Center(child: Text('Profil — Coming Soon')),
    );
  }
}
