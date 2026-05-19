/*
 * Autor: Cristian Eduardo Fava
 * RA: 25000636
 */

import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mescla_invest/constants/colors.dart';
import 'package:mescla_invest/models/investment/investment.dart';
import 'package:mescla_invest/models/startup/startup.dart';

class BuyTokensSheet extends StatefulWidget {
  final StartupModel startup;
  final VoidCallback onSuccess;

  const BuyTokensSheet({
    super.key,
    required this.startup,
    required this.onSuccess,
  });

  @override
  State<BuyTokensSheet> createState() => _BuyTokensSheetState();
}

class _BuyTokensSheetState extends State<BuyTokensSheet> {
  final _qtyController = TextEditingController(text: '1');
  bool _isLoading = false;
  String? _errorMsg;

  @override
  void dispose() {
    _qtyController.dispose();
    super.dispose();
  }

  int get _tokenAmount => int.tryParse(_qtyController.text) ?? 0;
  double get _total => _tokenAmount * widget.startup.tokenPrice;

  Future<void> _submit() async {
    if (_tokenAmount <= 0) {
      setState(() => _errorMsg = 'A quantidade deve ser maior que zero.');
      return;
    }

    if (_tokenAmount > widget.startup.totalTokensAvailable) {
      setState(
        () => _errorMsg =
            'Quantidade maior que os tokens disponíveis! Tokens disponíveis: (${widget.startup.totalTokensAvailable}).',
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMsg = null;
    });

    try {
      await InvestmentModel.buyTokens(
        startupId: widget.startup.id,
        tokenAmount: _tokenAmount,
      );

      if (mounted) {
        Navigator.pop(context);
        widget.onSuccess();
      }
    } on FirebaseFunctionsException catch (e) {
      if (mounted) {
        setState(() => _errorMsg = 'Erro ao comprar tokens: ${e.message}');
      }
    } catch (_) {
      if (mounted) {
        setState(() => _errorMsg = 'Erro inesperado. Tente novamente.');
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 32,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  widget.startup.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(
                'R\$ ${widget.startup.tokenPrice.toStringAsFixed(2).replaceAll('.', ',')} / token',
                style: const TextStyle(
                  color: AppColors.verdeMescla,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),

          const SizedBox(height: 6),

          Text(
            '${widget.startup.totalTokensAvailable} tokens disponíveis',
            style: const TextStyle(color: Colors.white38, fontSize: 13),
          ),

          const SizedBox(height: 24),

          // Seletor de quantidade
          const Text(
            'Quantidade de tokens',
            style: TextStyle(color: Colors.white70),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              GestureDetector(
                onTap: () {
                  final v = int.tryParse(_qtyController.text) ?? 1;
                  if (v > 1) {
                    _qtyController.text = '${v - 1}';
                    setState(() {});
                  }
                },
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A1A1A),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.remove,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
              Expanded(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A1A1A),
                    border: Border.all(color: AppColors.verdeMescla),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: TextField(
                    controller: _qtyController,
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(vertical: 12),
                    ),
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    onChanged: (_) => setState(() {}),
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {
                  final v = int.tryParse(_qtyController.text) ?? 0;
                  _qtyController.text = '${v + 1}';
                  setState(() {});
                },
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.verdeMescla,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.add, color: Colors.black, size: 20),
                ),
              ),
            ],
          ),

          if (_errorMsg != null) ...[
            const SizedBox(height: 12),
            Text(
              _errorMsg!,
              style: const TextStyle(color: Colors.redAccent, fontSize: 13),
            ),
          ],

          const SizedBox(height: 20),

          // Resumo do total
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A1A),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Total a pagar',
                  style: TextStyle(color: Colors.white54),
                ),
                Text(
                  'R\$ ${_total.toStringAsFixed(2).replaceAll('.', ',')}',
                  style: const TextStyle(
                    color: AppColors.verdeMescla,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.verdeMescla,
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: _isLoading ? null : _submit,
            child: _isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.black,
                    ),
                  )
                : const Text(
                    'Confirmar compra',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
          ),
        ],
      ),
    );
  }
}
