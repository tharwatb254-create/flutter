import 'package:flutter/material.dart';
import 'client_home.dart';
import 'client_requests.dart';
import '../profile_screen.dart';

class ClientMainLayout extends StatefulWidget {
  const ClientMainLayout({super.key});

  @override
  State<ClientMainLayout> createState() => _ClientMainLayoutState();
}

class _ClientMainLayoutState extends State<ClientMainLayout> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    ClientHomeScreen(),
    ClientRequestsScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() => _currentIndex = index);
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'الرئيسية',
          ),
          NavigationDestination(
            icon: Icon(Icons.receipt_long_outlined),
            selectedIcon: Icon(Icons.receipt_long),
            label: 'طلباتي',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'حسابي',
          ),
        ],
      ),
    );
  }
}
