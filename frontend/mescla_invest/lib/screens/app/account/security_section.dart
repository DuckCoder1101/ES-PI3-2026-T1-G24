/*
 * Autor: Cristian Eduardo Fava
 * RA: 25000636
 */

import 'package:flutter/material.dart';
import 'package:mescla_invest/constants/colors.dart';
import 'package:mescla_invest/services/user_service.dart';
import 'package:mescla_invest/utils/handle_exception.dart';
import 'package:mescla_invest/utils/show_snackbar.dart';
import 'package:mescla_invest/widgets/layout/account_section.dart';

class SecuritySection extends StatefulWidget {
  const SecuritySection({super.key});

  @override
  State<SecuritySection> createState() => _SecuritySectionState();
}

class _SecuritySectionState extends State<SecuritySection> {
  bool? _has2Fa;
  bool _isTogglingTotp = false;

  @override
  void initState() {
    super.initState();
    _loadTotpStatus();
  }

  Future<void> _loadTotpStatus() async {
    try {
      final has2Fa = await UserService.checkHas2Fa();
      if (mounted) setState(() => _has2Fa = has2Fa);
    } catch (_) {
      if (mounted) setState(() => _has2Fa = false);
    }
  }

  Future<void> _toggleTotp() async {
    if (_has2Fa == null || _isTogglingTotp) return;

    if (_has2Fa!) {
      final confirm = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor: AppColors.campoEscuro,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            'Desabilitar 2FA',
            style: TextStyle(color: Colors.white),
          ),
          content: const Text(
            'Deseja remover a autenticação em duas etapas? Sua conta ficará menos protegida.',
            style: TextStyle(color: Colors.white60, height: 1.5),
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
                'Desabilitar',
                style: TextStyle(color: Colors.redAccent),
              ),
            ),
          ],
        ),
      );

      if (confirm != true || !mounted) return;

      setState(() => _isTogglingTotp = true);
      try {
        await UserService.disableTotp();
        if (mounted) {
          setState(() => _has2Fa = false);
          showSnackbar(msg: '2FA desabilitado.', context: context);
        }
      } catch (err) {
        if (mounted) handleException(err: err, context: context);
      } finally {
        if (mounted) setState(() => _isTogglingTotp = false);
      }
    } else {
      final enrolled = await Navigator.pushNamed(context, '/auth/activate-2fa');
      if (enrolled == true && mounted) setState(() => _has2Fa = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isActive = _has2Fa == true;
    final isLoading = _has2Fa == null || _isTogglingTotp;

    return AccountCard(
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: isActive
                  ? AppColors.verdeMescla.withValues(alpha: 0.12)
                  : Colors.white10,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              isActive ? Icons.verified_user_rounded : Icons.security_outlined,
              color: isActive ? AppColors.verdeMescla : Colors.white38,
              size: 22,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Verificação em 2 etapas',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  isLoading
                      ? 'Verificando...'
                      : isActive
                      ? 'Ativa — autenticador configurado'
                      : 'Inativa — ative para maior segurança',
                  style: TextStyle(
                    color: isActive ? AppColors.verdeMescla : Colors.white38,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          isLoading
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.verdeMescla,
                  ),
                )
              : GestureDetector(
                  onTap: _toggleTotp,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    width: 48,
                    height: 28,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      color: isActive ? AppColors.verdeMescla : Colors.white12,
                    ),
                    padding: const EdgeInsets.all(3),
                    child: AnimatedAlign(
                      duration: const Duration(milliseconds: 250),
                      curve: Curves.easeOutCubic,
                      alignment: isActive
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      child: Container(
                        width: 22,
                        height: 22,
                        decoration: BoxDecoration(
                          color: isActive ? Colors.black : Colors.white38,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ),
                ),
        ],
      ),
    );
  }
}
