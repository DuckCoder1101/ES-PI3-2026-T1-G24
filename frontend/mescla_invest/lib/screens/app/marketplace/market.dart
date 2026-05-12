// Autor: Vinicius Santuci Virgolino
// RA: 25000294

import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import 'package:mescla_invest/constants/colors.dart';
import 'package:mescla_invest/models/order/order.dart';
import 'package:mescla_invest/screens/app/marketplace/create_order_screen.dart';

class MarketScreen extends StatefulWidget {
  const MarketScreen({super.key});

  @override
  State<MarketScreen> createState() => _MarketScreenState();
}

class _MarketScreenState extends State<MarketScreen> {
  String _activeTab = 'Compra';

  // Listas de ordens carregadas do backend
  List<OrderModel> _buyOrders = [];
  List<OrderModel> _sellOrders = [];
  List<OrderModel> _myOrders = [];

  bool _isLoading = false;
  bool _isExecuting = false;

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
        OrderModel.getOrders(orderType: OrderType.buy, offset: 0, limit: 10),
        OrderModel.getOrders(orderType: OrderType.sell, offset: 0, limit: 10),
        OrderModel.getUserOrders(),
      ]);

      if (mounted) {
        setState(() {
          _buyOrders = results[0];
          _sellOrders = results[1];
          _myOrders = results[2];
        });
      }
    } on FirebaseFunctionsException catch (err) {
      _showSnack('Erro ao carregar ordens: ${err.message}', isError: true);
    } catch (err) {
      debugPrint("Erro: $err");
      _showSnack(
        'Erro ao carregar ordens. Verifique sua conexão.',
        isError: true,
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // Executa a compra de tokens de uma ordem de venda existente
  Future<void> _executeBuy(OrderModel order) async {
    final confirm = await _showConfirmDialog(
      title: 'Confirmar compra',
      message:
          'Comprar ${order.tokenAmount} tokens de ${order.startup.name} por R\$ ${order.totalValue.toStringAsFixed(2).replaceAll('.', ',')}?',
    );
    if (!confirm || !mounted) return;

    setState(() => _isExecuting = true);
    try {
      await OrderModel.buyOrder(order.id);
      _showSnack('Compra realizada com sucesso!', isError: false);
      await _fetchOrders();
    } on FirebaseFunctionsException catch (e) {
      _showSnack(e.message ?? 'Erro ao comprar tokens.', isError: true);
    } catch (_) {
      _showSnack('Erro ao realizar compra.', isError: true);
    } finally {
      if (mounted) setState(() => _isExecuting = false);
    }
  }

  // Executa a venda de tokens para uma ordem de compra existente
  Future<void> _executeSell(OrderModel order) async {
    final confirm = await _showConfirmDialog(
      title: 'Confirmar venda',
      message:
          'Vender ${order.tokenAmount} tokens de ${order.startup.name} por R\$ ${order.totalValue.toStringAsFixed(2).replaceAll('.', ',')}?',
    );
    if (!confirm || !mounted) return;

    setState(() => _isExecuting = true);
    try {
      await OrderModel.sellOrder(order.id);
      _showSnack('Venda realizada com sucesso!', isError: false);
      await _fetchOrders();
    } on FirebaseFunctionsException catch (e) {
      _showSnack(e.message ?? 'Erro ao vender tokens.', isError: true);
    } catch (_) {
      _showSnack('Erro ao realizar venda.', isError: true);
    } finally {
      if (mounted) setState(() => _isExecuting = false);
    }
  }

  // Cancela uma ordem própria e devolve os fundos/tokens bloqueados
  Future<void> _cancelOrder(OrderModel order) async {
    final confirm = await _showConfirmDialog(
      title: 'Cancelar ordem',
      message:
          'Deseja cancelar esta ordem? Os fundos/tokens bloqueados serão devolvidos.',
    );
    if (!confirm || !mounted) return;

    setState(() => _isExecuting = true);
    try {
      await OrderModel.deleteOrder(order.id);
      _showSnack('Ordem cancelada.', isError: false);
      await _fetchOrders();
    } on FirebaseFunctionsException catch (e) {
      _showSnack(e.message ?? 'Erro ao cancelar ordem.', isError: true);
    } catch (_) {
      _showSnack('Erro ao cancelar ordem.', isError: true);
    } finally {
      if (mounted) setState(() => _isExecuting = false);
    }
  }

  Future<bool> _showConfirmDialog({
    required String title,
    required String message,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.campoEscuro,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(title, style: const TextStyle(color: Colors.white)),
        content: Text(
          message,
          style: const TextStyle(color: Colors.white70, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text(
              'Cancelar',
              style: TextStyle(color: Colors.white38),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text(
              'Confirmar',
              style: TextStyle(color: AppColors.verdeMescla),
            ),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  void _showSnack(String msg, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: isError ? Colors.redAccent : AppColors.verdeMescla,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _goToNewOffer(OrderType orderType) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => CreateOrderScreen(orderType: orderType),
      ),
    );

    // Recarrega após criar uma nova ordem
    if (result == true && mounted) {
      await _fetchOrders();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.fundoEscuro,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
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
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () => _goToNewOffer(OrderType.buy),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.verdeMescla,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            '+ Oferta',
                            style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      GestureDetector(
                        onTap: _isLoading ? null : _fetchOrders,
                        child: const Icon(
                          Icons.refresh_rounded,
                          color: Colors.white54,
                        ),
                      ),
                    ],
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
                  children: ['Compra', 'Venda', 'Minhas Ordens'].map((tab) {
                    final isSelected = _activeTab == tab;
                    return Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _activeTab = tab),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? const Color(0xFF2A2A2A)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            tab,
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

            const SizedBox(height: 16),

            // Label da aba
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  _activeTab == 'Compra'
                      ? 'OFERTAS DE COMPRA ABERTAS'
                      : _activeTab == 'Venda'
                      ? 'OFERTAS DE VENDA ABERTAS'
                      : 'MINHAS ORDENS',
                  style: const TextStyle(
                    color: AppColors.verdeMescla,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Lista de ordens
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
      ),
    );
  }

  Widget _buildOrderList() {
    final orders = _activeTab == 'Compra'
        ? _buyOrders
        : _activeTab == 'Venda'
        ? _sellOrders
        : _myOrders;

    if (orders.isEmpty) {
      return const Center(
        child: Text(
          'Nenhuma ordem encontrada.',
          style: TextStyle(color: Colors.white38),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: orders.length,
      itemBuilder: (context, index) {
        final order = orders[index];
        return _buildOrderCard(order);
      },
    );
  }

  Widget _buildOrderCard(OrderModel order) {
    final isBuyTab = _activeTab == 'Compra';
    final isMyOrders = _activeTab == 'Minhas Ordens';

    // Rótulo do botão de ação
    final actionLabel = isMyOrders
        ? 'Cancelar'
        : isBuyTab
        ? 'Vender'
        : 'Comprar';

    // Cor do botão
    final actionColor = isMyOrders ? Colors.redAccent : AppColors.verdeMescla;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.campoEscuro,
        borderRadius: BorderRadius.circular(12),
        border: order.isAuthor
            ? Border.all(color: AppColors.verdeMescla.withValues(alpha: 0.3))
            : null,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  order.startup.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  'Qtd: ${order.tokenAmount} tokens',
                  style: const TextStyle(color: Colors.white54, fontSize: 13),
                ),
                if (isMyOrders)
                  Text(
                    order.type == OrderType.buy
                        ? 'Ordem de compra'
                        : 'Ordem de venda',
                    style: TextStyle(
                      color: order.type == OrderType.buy
                          ? Colors.greenAccent.withValues(alpha: 0.8)
                          : Colors.orangeAccent.withValues(alpha: 0.8),
                      fontSize: 12,
                    ),
                  ),
              ],
            ),
          ),
          Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'R\$ ${order.pricePerToken.toStringAsFixed(2).replaceAll('.', ',')}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const Text(
                    '/token',
                    style: TextStyle(color: Colors.white54, fontSize: 12),
                  ),
                ],
              ),
              const SizedBox(width: 12),
              // Não mostra o botão de ação para as próprias ordens nas abas Compra/Venda
              if (isMyOrders || !order.isAuthor)
                GestureDetector(
                  onTap: _isExecuting
                      ? null
                      : () {
                          if (isMyOrders) {
                            _cancelOrder(order);
                          } else if (isBuyTab) {
                            _executeSell(order);
                          } else {
                            _executeBuy(order);
                          }
                        },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: actionColor,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: _isExecuting
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.black,
                            ),
                          )
                        : Text(
                            actionLabel,
                            style: const TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                  ),
                )
              else
                // Badge "Sua ordem" para ordens próprias nas abas Compra/Venda
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.verdeMescla.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: AppColors.verdeMescla.withValues(alpha: 0.4),
                    ),
                  ),
                  child: const Text(
                    'Sua ordem',
                    style: TextStyle(
                      color: AppColors.verdeMescla,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
