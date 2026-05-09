// Autor: Cristian Eduardo Fava
// RA: 25000636

import 'package:flutter/material.dart';
import 'package:mescla_invest/constants/colors.dart';

// Enum dos destinos da navbar
enum NavDestination {
  catalog,
  market,
  wallet,
  account;

  String get label => switch (this) {
    NavDestination.catalog => 'Catálogo',
    NavDestination.market => 'Mercado',
    NavDestination.wallet => 'Carteira',
    NavDestination.account => 'Minha conta',
  };

  String get route => switch (this) {
    NavDestination.catalog => "/startups/catalog",
    NavDestination.market => "/startups/market",
    NavDestination.wallet => "/user/waller",
    NavDestination.account => "/user/account",
  };

  IconData get icon => switch (this) {
    NavDestination.catalog => Icons.grid_view_rounded,
    NavDestination.market => Icons.show_chart_rounded,
    NavDestination.wallet => Icons.account_balance_wallet_outlined,
    NavDestination.account => Icons.person_outline_rounded,
  };

  IconData get iconSelected => switch (this) {
    NavDestination.catalog => Icons.grid_view_rounded,
    NavDestination.market => Icons.show_chart_rounded,
    NavDestination.wallet => Icons.account_balance_wallet_rounded,
    NavDestination.account => Icons.person_rounded,
  };
}

class NavBar extends StatelessWidget {
  final NavDestination current;

  const NavBar({super.key, required this.current});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF111111),
        border: Border(top: BorderSide(color: Colors.white10, width: 0.8)),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 64,
          child: Row(
            children: NavDestination.values.map((dest) {
              return Expanded(
                child: _NavItem(
                  destination: dest,
                  isSelected: dest == current,
                  onTap: () {
                    Navigator.pushReplacementNamed(context, dest.route);
                  },
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}

// Item individual com animação
class _NavItem extends StatefulWidget {
  final NavDestination destination;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavItem({
    required this.destination,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<_NavItem> createState() => _NavItemState();
}

class _NavItemState extends State<_NavItem>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
      lowerBound: 0.0,
      upperBound: 1.0,
    );
    _scaleAnim = Tween<double>(
      begin: 1.0,
      end: 0.88,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _handleTap() async {
    await _controller.forward();
    await _controller.reverse();
    widget.onTap();
  }

  @override
  Widget build(BuildContext context) {
    final isSelected = widget.isSelected;

    return GestureDetector(
      onTap: _handleTap,
      behavior: HitTestBehavior.opaque,
      child: ScaleTransition(
        scale: _scaleAnim,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Ícone com indicador de seleção
            AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOutCubic,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.verdeMescla.withValues(alpha: 0.14)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(20),
              ),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 180),
                child: Icon(
                  isSelected
                      ? widget.destination.iconSelected
                      : widget.destination.icon,
                  key: ValueKey(isSelected),
                  color: isSelected ? AppColors.verdeMescla : Colors.white30,
                  size: 22,
                ),
              ),
            ),

            const SizedBox(height: 4),

            // Label
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style: TextStyle(
                color: isSelected ? AppColors.verdeMescla : Colors.white30,
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                letterSpacing: isSelected ? 0.2 : 0,
              ),
              child: Text(widget.destination.label),
            ),
          ],
        ),
      ),
    );
  }
}
