/*
 * Autor: Cristian Eduardo Fava
 * RA: 25000636
 */

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mescla_invest/constants/colors.dart';
import 'package:mescla_invest/models/user/user_model.dart';
import 'package:mescla_invest/services/user_service.dart';
import 'package:mescla_invest/utils/handle_exception.dart';
import 'package:mescla_invest/utils/show_snackbar.dart';

class AvatarSection extends StatefulWidget {
  final UserModel? user;

  const AvatarSection({super.key, required this.user});

  @override
  State<AvatarSection> createState() => _AvatarSectionState();
}

class _AvatarSectionState extends State<AvatarSection> {
  String? _resolvedAvatarUrl;
  bool _isUploadingPhoto = false;

  @override
  void initState() {
    super.initState();
    _loadProfilePicture();
  }

  Future<void> _loadProfilePicture() async {
    try {
      final url = await UserService.getAvatarUrl();
      if (mounted) {
        setState(() => _resolvedAvatarUrl = url);
      }
    } catch (_) {
      // Sem foto de perfil: silencia o erro e exibe o ícone padrão
      if (mounted) {
        setState(() => _resolvedAvatarUrl = null);
      }
    }
  }

  Future<void> _showAvatarOptions() async {
    if (_isUploadingPhoto || widget.user == null) return;

    await showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E1E1E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 8),
            ListTile(
              leading: const Icon(
                Icons.photo_library_rounded,
                color: Colors.white,
              ),
              title: const Text(
                'Alterar foto de perfil',
                style: TextStyle(color: Colors.white),
              ),
              onTap: () {
                Navigator.pop(ctx);
                _pickAndUploadPhoto();
              },
            ),
            if (_resolvedAvatarUrl != null)
              ListTile(
                leading: const Icon(
                  Icons.delete_rounded,
                  color: Colors.redAccent,
                ),
                title: const Text(
                  'Remover foto',
                  style: TextStyle(color: Colors.redAccent),
                ),
                onTap: () {
                  Navigator.pop(ctx);
                  _removePhoto();
                },
              ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Future<void> _pickAndUploadPhoto() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
      maxWidth: 512,
    );

    if (picked == null || !mounted) return;
    setState(() => _isUploadingPhoto = true);

    try {
      await UserService.uploadAvatarPicture(File(picked.path));
      await _loadProfilePicture();

      if (mounted) {
        showSnackbar(msg: 'Foto atualizada com sucesso!', context: context);
      }
    } catch (err, stack) {
      if (mounted) {
        handleException(err: err, stack: stack, context: context);
      }
    } finally {
      if (mounted) setState(() => _isUploadingPhoto = false);
    }
  }

  Future<void> _removePhoto() async {
    setState(() => _isUploadingPhoto = true);

    try {
      await UserService.removeAvatar();
      if (mounted) {
        setState(() => _resolvedAvatarUrl = null);
        showSnackbar(msg: 'Foto removida com sucesso!', context: context);
      }
    } catch (err, stack) {
      if (mounted) {
        handleException(err: err, stack: stack, context: context);
      }
    } finally {
      if (mounted) setState(() => _isUploadingPhoto = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final displayName = (widget.user != null && widget.user!.name.isNotEmpty)
        ? widget.user!.name
        : 'Investidor';
    final email = widget.user?.email ?? '';

    return Stack(
      fit: StackFit.expand,
      children: [
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF0E1F0E), AppColors.fundoEscuro],
            ),
          ),
        ),
        Positioned(
          bottom: 20,
          left: 0,
          right: 0,
          child: Column(
            children: [
              _AvatarCircle(
                avatarUrl: _resolvedAvatarUrl,
                isUploading: _isUploadingPhoto,
                onTap: _showAvatarOptions,
              ),
              const SizedBox(height: 12),
              Text(
                displayName,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                email,
                style: const TextStyle(color: Colors.white38, fontSize: 13),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _AvatarCircle extends StatelessWidget {
  final String? avatarUrl;
  final bool isUploading;
  final VoidCallback onTap;

  const _AvatarCircle({
    required this.avatarUrl,
    required this.isUploading,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.bottomRight,
      children: [
        GestureDetector(
          onTap: onTap,
          child: Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.verdeMescla.withValues(alpha: 0.5),
                width: 2,
              ),
            ),
            child: ClipOval(child: _buildAvatarContent()),
          ),
        ),
        if (!isUploading)
          GestureDetector(
            onTap: onTap,
            child: Container(
              width: 26,
              height: 26,
              decoration: BoxDecoration(
                color: AppColors.verdeMescla,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.fundoEscuro, width: 2),
              ),
              child: const Icon(
                Icons.camera_alt_rounded,
                size: 13,
                color: Colors.black,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildAvatarContent() {
    if (isUploading) {
      return Container(
        color: AppColors.campoEscuro,
        child: const Center(
          child: SizedBox(
            width: 28,
            height: 28,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              color: AppColors.verdeMescla,
            ),
          ),
        ),
      );
    }

    if (avatarUrl != null) {
      return Image.network(
        avatarUrl!,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => _buildDefaultIcon(),
      );
    }

    return _buildDefaultIcon();
  }

  Widget _buildDefaultIcon() {
    return Container(
      color: AppColors.campoEscuro,
      child: const Icon(Icons.person_rounded, color: Colors.white24, size: 36),
    );
  }
}
