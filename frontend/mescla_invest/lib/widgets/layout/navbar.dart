// Autor: Cristian Fava
// RA: 25000636

import 'package:flutter/material.dart';
import 'package:mescla_invest/screens/app/startups/catalog.dart';
import 'package:mescla_invest/constants/colors.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 1; // Começa em Startups conforme o protótipo

  final List<Widget> _screens = [
    const Center(child: Text('Home')),
    const CatalogScreen(),
    const Center(child: Text('Balcão')),
    const Center(child: Text('Carteira')),
    const Center(child: Text('Perfil')),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: AppColors.fundoEscuro,
        selectedItemColor: AppColors.verdeMescla,
        unselectedItemColor: Colors.white38,
        type: BottomNavigationBarType.fixed,
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.show_chart),
            label: 'Startups',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.swap_horiz),
            label: 'Balcão',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.money), label: 'Carteira'),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }
}
