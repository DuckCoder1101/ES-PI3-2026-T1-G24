import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:mescla_invest/constants/colors.dart';
import 'package:mescla_invest/models/user.dart';

class AppHeader extends StatefulWidget {
  final UserModel? user;
  const AppHeader({super.key, this.user});

  @override
  State<AppHeader> createState() => _AppHeaderState();
}

class _AppHeaderState extends State<AppHeader> {
  String? _resolvedUrl;

  @override
  void initState() {
    super.initState();
    _loadProfilePicture();
  }

  Future<void> _loadProfilePicture() async {
    if (widget.user != null && widget.user!.avatarUrl.isNotEmpty) {
      try {
        final url = await FirebaseStorage.instance
            .ref(widget.user!.avatarUrl)
            .getDownloadURL();
        if (mounted) setState(() => _resolvedUrl = url);
      } catch (e) {
        debugPrint("Erro ao baixar foto: $e");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Olá, ${widget.user?.name.split(' ')[0] ?? "Investidor"}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),

          PopupMenuButton<String>(
            offset: const Offset(0, 50),
            color: AppColors.campoEscuro,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            onSelected: _handleMenuSelection,
            // O botão principal agora é apenas a foto limpa
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
              // A opção de trocar foto aparece apenas aqui dentro
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
                'Segurança 2FA',
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
        // Lógica para disparar o seletor de galeria/câmera
        debugPrint("Trocar foto acionado");
        break;
      case 'info':
        debugPrint("Editar perfil");
        break;
      case '2fa':
        Navigator.pushNamed(
          context,
          "/auth/enable-2fa",
        ); // Navega para sua tela de 2FA
        break;
      case 'logout':
        await UserModel.signout(); // Garanta que o método seja async

        if (mounted) {
          Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
        }
        break;
    }
  }
}
