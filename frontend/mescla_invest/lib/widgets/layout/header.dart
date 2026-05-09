/*
 * Autor: Cristian Eduardo Fava
 * RA: 25000636
 */

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:mescla_invest/constants/colors.dart';
import 'package:mescla_invest/models/user.dart';
import 'package:mescla_invest/screens/app_root.dart';

class AppHeader extends StatefulWidget {
  const AppHeader({super.key});

  @override
  State<AppHeader> createState() => _AppHeaderState();
}

class _AppHeaderState extends State<AppHeader> {
  String? _lastUid;
  String? _resolvedUrl;
  bool? _has2Fa;

  // Chamado sempre que o provider emite um novo valor
  void _onUserChanged(UserModel? user) {
    if (user == null) {
      setState(() {
        _resolvedUrl = null;
        _has2Fa = null;
        _lastUid = null;
      });
      return;
    }

    // Só recarrega foto e 2FA quando o usuário muda de fato
    if (user.uid != _lastUid) {
      _lastUid = user.uid;
      _loadProfilePicture(user);
      _loadTotpStatus();
    }
  }

  Future<void> _loadProfilePicture(UserModel user) async {
    if (user.avatarUrl == null || user.avatarUrl!.isEmpty) {
      if (mounted) setState(() => _resolvedUrl = null);
      return;
    }

    try {
      final url = await FirebaseStorage.instance
          .ref(user.avatarUrl)
          .getDownloadURL();
      if (mounted) setState(() => _resolvedUrl = url);
    } catch (e) {
      debugPrint("Erro ao baixar foto: $e");
      if (mounted) setState(() => _resolvedUrl = null);
    }
  }

  Future<void> _loadTotpStatus() async {
    try {
      final has2Fa = await UserModel.checkHas2Fa();
      if (mounted) setState(() => _has2Fa = has2Fa);
    } catch (e) {
      debugPrint("Erro ao verificar 2FA: $e");
      if (mounted) setState(() => _has2Fa = false);
    }
  }

  Future<void> _disableTotp() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.campoEscuro,
        title: const Text(
          'Desabilitar 2FA',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          'Deseja desabilitar a autenticação em duas etapas?',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text(
              'Cancelar',
              style: TextStyle(color: Colors.white54),
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

    try {
      await UserModel.disableTotp();

      if (mounted) {
        setState(() => _has2Fa = false);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('2FA desabilitado com sucesso.'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Erro ao desabilitar 2FA.'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  Future<void> _enableTotp() async {
    final enrolled = await Navigator.pushNamed(context, '/auth/activate-2fa');
    if (enrolled == true && mounted) setState(() => _has2Fa = true);
  }

  Future<void> _logout() async {
    await UserModel.signout();
  }

  Future<void> _handleMenuSelection(String value) async {
    switch (value) {
      case 'photo':
        debugPrint("Trocar foto acionado");
      case 'info':
        debugPrint("Editar perfil");
      case '2fa':
        if (_has2Fa == null) return;
        if (_has2Fa!) {
          await _disableTotp();
        } else {
          await _enableTotp();
        }
      case 'logout':
        await _logout();
    }
  }

  PopupMenuItem<String> _buildMenuItem(
    String value,
    IconData icon,
    String label, {
    bool isDestructive = false,
  }) {
    return PopupMenuItem(
      value: value,
      child: Row(
        children: [
          Icon(
            icon,
            color: isDestructive ? Colors.redAccent : AppColors.verdeMescla,
            size: 20,
          ),
          const SizedBox(width: 12),
          Text(
            label,
            style: TextStyle(
              color: isDestructive ? Colors.redAccent : Colors.white,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<UserModel?>(
      valueListenable: authUserDataProvider,
      builder: (context, user, _) {
        // Dispara efeitos colaterais (foto, 2FA) de forma segura dentro do build
        WidgetsBinding.instance.addPostFrameCallback(
          (_) => _onUserChanged(user),
        );

        final displayName = (user != null && user.name.isNotEmpty)
            ? user.name.split(' ')[0]
            : 'Investidor';

        return Padding(
          padding: const EdgeInsets.all(20.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: Text(
                  'Olá, $displayName',
                  key: ValueKey(displayName),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              PopupMenuButton<String>(
                offset: const Offset(0, 50),
                color: AppColors.campoEscuro,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                onSelected: _handleMenuSelection,
                child: CircleAvatar(
                  radius: 20,
                  backgroundColor: AppColors.campoEscuro,
                  backgroundImage: _resolvedUrl != null
                      ? NetworkImage(_resolvedUrl!)
                      : null,
                  child: _resolvedUrl == null
                      ? const Icon(Icons.person, color: Colors.white24)
                      : null,
                ),
                itemBuilder: (_) => [
                  _buildMenuItem(
                    'photo',
                    Icons.camera_alt_outlined,
                    'Alterar foto de perfil',
                  ),
                  _buildMenuItem(
                    'info',
                    Icons.edit_outlined,
                    'Informações pessoais',
                  ),
                  _buildMenuItem(
                    '2fa',
                    Icons.security_outlined,
                    _has2Fa == null
                        ? 'Verificando 2FA...'
                        : (_has2Fa! ? 'Desabilitar 2FA' : 'Habilitar 2FA'),
                  ),
                  const PopupMenuDivider(height: 1),
                  _buildMenuItem(
                    'logout',
                    Icons.logout,
                    'Sair do app',
                    isDestructive: true,
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
