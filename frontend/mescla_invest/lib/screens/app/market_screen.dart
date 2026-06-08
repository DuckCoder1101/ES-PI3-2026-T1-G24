// Autor: Vinicius Santuci Virgolino
// RA: 25000294

import 'package:flutter/material.dart';
import 'package:mescla_invest/constants/colors.dart';
import 'package:mescla_invest/models/order_model.dart';
import 'package:mescla_invest/models/startup/startup_model.dart';
import 'package:mescla_invest/screens/app/create_order_screen.dart';
import 'package:mescla_invest/widgets/market/order_card/order_card.dart';
import 'package:mescla_invest/services/order_service.dart';
import 'package:mescla_invest/utils/handle_exception.dart';

class MarketScreen extends StatefulWidget {
  const MarketScreen({super.key});

  @override
  State<MarketScreen> createState() => _MarketScreenState();
}

class _MarketScreenState extends State<MarketScreen> {
  OrderTypeFilter _activeTab = OrderTypeFilter.buy;
  StartupStageFilter _selectedStage = StartupStageFilter.all;

  // Listas de ordens carregadas do backend
  List<OrderModel> _buyOrders = [];
  List<OrderModel> _sellOrders = [];
  List<OrderModel> _myOrders = [];

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchOrders();
  }

  // Carrega todas as ordens do backend conforme a aba ativa
  Future<void> _fetchOrders() async {
    setState(() => _isLoading = true);

    try {
      final results = await Future.wait([
        OrderService.getOrders(
          orderType: OrderType.buy,
          offset: 0,
          limit: 10,
          stageFilter: _selectedStage,
        ),
        OrderService.getOrders(
          orderType: OrderType.sell,
          offset: 0,
          limit: 10,
          stageFilter: _selectedStage,
        ),
        OrderService.getUserOrders(stageFilter: _selectedStage),
      ]);

      if (mounted) {
        setState(() {
          _buyOrders = results[0];
          _sellOrders = results[1];
          _myOrders = results[2];
        });
      }
    } catch (err, stack) {
      if (mounted) {
        handleException(err: err, stack: stack, context: context);
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _goToNewOffer() async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => CreateOrderScreen()),
    );

    // Recarrega após criar uma nova ordem
    if (result == true && mounted) {
      await _fetchOrders();
    }
  }

  Widget _buildFilterTags() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: StartupStageFilter.values.map((stage) {
          final isSelected = _selectedStage == stage;
          return GestureDetector(
            onTap: () {
              if (_selectedStage != stage) {
                setState(() => _selectedStage = stage);
                _fetchOrders();
              }
            },
            child: Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.verdeMescla
                    : AppColors.campoEscuro,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                stage.label,
                style: TextStyle(
                  color: isSelected ? Colors.black : Colors.white70,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildOrderList() {
    final orders = switch (_activeTab) {
      OrderTypeFilter.buy => _buyOrders,
      OrderTypeFilter.sell => _sellOrders,
      OrderTypeFilter.myOrders => _myOrders,
    };

    if (orders.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: const [
          Padding(
            padding: EdgeInsets.only(top: 100),
            child: Center(
              child: Text(
                'Nenhuma ordem encontrada.',
                style: TextStyle(color: Colors.white38),
              ),
            ),
          ),
        ],
      );
    }

    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: orders.length,
      itemBuilder: (context, index) {
        final order = orders[index];
        return OrderCard(
          tab: _activeTab,
          order: order,
          onUpdate: _fetchOrders,
          onRemove: () =>
              setState(() => _myOrders.removeWhere((o) => o.id == order.id)),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Stack(
        children: [
          Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Mercado',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              // Toggle abas
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: AppColors.campoEscuro,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: OrderTypeFilter.values.map((tab) {
                      final isSelected = _activeTab == tab;

                      return Expanded(
                        child: GestureDetector(
                          onTap: () {
                            setState(() => _activeTab = tab);
                            _fetchOrders();
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? const Color(0xFF2A2A2A)
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              tab.label,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: isSelected
                                    ? AppColors.verdeMescla
                                    : Colors.white54,
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // Filtros de estágio
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _buildFilterTags(),
              ),

              const SizedBox(height: 12),

              // Label da aba
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    _activeTab.label,
                    style: const TextStyle(
                      color: AppColors.verdeMescla,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              Expanded(
                child: _isLoading
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.verdeMescla,
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _fetchOrders,
                        color: AppColors.verdeMescla,
                        child: _buildOrderList(),
                      ),
              ),
            ],
          ),

          if (_activeTab == OrderTypeFilter.myOrders) ...[
            Positioned(
              right: 20,
              bottom: MediaQuery.of(context).padding.bottom + 50,
              child: GestureDetector(
                onTap: _goToNewOffer,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: AppColors.verdeMescla,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.add_rounded,
                    color: Colors.black,
                    size: 34,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
