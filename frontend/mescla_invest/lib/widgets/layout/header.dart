/*
 * Autor: Cristian Eduardo Fava
 * RA: 25000636
 */

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:mescla_invest/constants/colors.dart';
import 'package:mescla_invest/models/user.dart';
import 'package:mescla_invest/screens/app_root.dart'; // Import necessário para o provider

class AppHeader extends StatefulWidget {
  final UserModel? user;
  const AppHeader({super.key, this.user});

  @override
  State<AppHeader> createState() => _AppHeaderState();
}

class _AppHeaderState extends State<AppHeader> {
  String? _resolvedUrl;
  bool? _has2Fa;

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  @override
  void didUpdateWidget(AppHeader oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.user?.avatarUrl != oldWidget.user?.avatarUrl ||
        widget.user?.uid != oldWidget.user?.uid) {
      _loadProfilePicture();
    }
  }

  Future<void> _loadProfileData() async {
    await Future.wait([_loadProfilePicture(), _loadTotpStatus()]);
  }

  Future<void> _loadProfilePicture() async {
    if (widget.user?.avatarUrl != null && widget.user!.avatarUrl!.isNotEmpty) {
      try {
        final url = await FirebaseStorage.instance
            .ref(widget.user!.avatarUrl)
            .getDownloadURL();
        if (mounted) setState(() => _resolvedUrl = url);
      } catch (e) {
        debugPrint("Erro ao baixar foto: $e");
        if (mounted) setState(() => _resolvedUrl = null);
      }
    } else {
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
    // TOTP ativo → confirma e desativa
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.campoEscuro,
        title: const Text(
          'Desabilitar 2FA',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          'Tem certeza que deseja remover a autenticação em duas etapas?',
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

    if (confirm == null || !confirm || !mounted) return;

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
    } catch (e) {
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

    if (enrolled == true && mounted) {
      setState(() => _has2Fa = true);
    }
  }

  Future<void> _logout() async {
    await UserModel.signout();
    if (mounted) {
      Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<UserModel?>(
      valueListenable: authUserDataProvider,
      builder: (context, currentUser, _) {
        // Prioriza o usuário do provider global, fallback para o widget, fallback para string vazia
        final user = currentUser ?? widget.user;
        final String displayName = (user != null && user.name.isNotEmpty)
            ? user.name.split(' ')[0]
            : "Investidor";

        return Padding(
          padding: const EdgeInsets.all(20.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Nome do usuário com animação suave de troca de texto
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
                itemBuilder: (context) => [
                  _buildHoverMenuItem(
                    'photo',
                    Icons.camera_alt_outlined,
                    'Alterar foto de perfil',
                  ),
                  _buildHoverMenuItem(
                    'info',
                    Icons.edit_outlined,
                    'Informações pessoais',
                  ),
                  _buildHoverMenuItem(
                    '2fa',
                    Icons.security_outlined,
                    _has2Fa == null
                        ? 'Verificando 2FA...'
                        : (_has2Fa! ? 'Desabilitar 2FA' : 'Habilitar 2FA'),
                  ),
                  const PopupMenuDivider(height: 1),
                  _buildHoverMenuItem(
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

  PopupMenuItem<String> _buildHoverMenuItem(
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

  Future<void> _handleMenuSelection(String value) async {
    switch (value) {
      case 'photo':
        debugPrint("Trocar foto acionado");
        break;
      case 'info':
        debugPrint("Editar perfil");
        break;
      case '2fa':
        // Aguarda o status estar carregado antes de navegar
        if (_has2Fa == null) return;

        if (_has2Fa!) return await _disableTotp();
        await _enableTotp();

        break;

      case 'logout':
        await _logout();
        break;
    }
  }
}
