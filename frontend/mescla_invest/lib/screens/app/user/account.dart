/*
 * Autor: Cristian Eduardo Fava
 * RA: 25000636
 */

import 'dart:io';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mescla_invest/constants/colors.dart';
import 'package:mescla_invest/models/user.dart';
import 'package:mescla_invest/screens/app_root.dart';

class UserAccountScreen extends StatefulWidget {
  const UserAccountScreen({super.key});

  @override
  State<UserAccountScreen> createState() => _UserAccountScreenState();
}

class _UserAccountScreenState extends State<UserAccountScreen> {
  // Foto de perfil
  String? _resolvedAvatarUrl;
  bool _isUploadingPhoto = false;

  // Dados pessoais
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  bool _isSavingData = false;
  bool _dataChanged = false;

  // 2FA
  bool? _has2Fa;
  bool _isTogglingTotp = false;

  bool _isLoggingOut = false;

  @override
  void initState() {
    super.initState();
    final user = authUserDataProvider.value;

    if (user != null) {
      _nameController.text = user.name;
      _phoneController.text = user.phone;
      _loadProfilePicture(user);
    }

    _loadTotpStatus();

    _nameController.addListener(_onDataChanged);
    _phoneController.addListener(_onDataChanged);
  }

  @override
  void dispose() {
    _nameController.removeListener(_onDataChanged);
    _phoneController.removeListener(_onDataChanged);

    _nameController.dispose();
    _phoneController.dispose();

    super.dispose();
  }

  void _onDataChanged() {
    final user = authUserDataProvider.value;
    final changed =
        user != null &&
        (_nameController.text != user.name ||
            _phoneController.text != user.phone);
    if (changed != _dataChanged) setState(() => _dataChanged = changed);
  }

  // Download da foto de perfil
  Future<void> _loadProfilePicture(UserModel user) async {
    try {
      final url = await user.getAvatarUrl();

      if (mounted) {
        setState(() => _resolvedAvatarUrl = url);
      }
    } catch (_) {
      if (!mounted) return;
      _showSnack("Erro ao baixar foto de perfil!");
    }
  }

  // Upload da foto de perfil
  Future<void> _pickAndUploadPhoto(UserModel user) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
      maxWidth: 512,
    );

    if (picked == null || !mounted) return;
    setState(() => _isUploadingPhoto = true);

    try {
      await user.uploadAvatarPicture(File(picked.path));
      await _loadProfilePicture(user);

      _showSnack('Foto atualizada com sucesso!', isError: false);
    } catch (err) {
      debugPrint("Erro desconhecido interno ao enviar foto: $err");
      _showSnack(
        'Erro desconhecido interno ao enviar foto. Tente novamente mais tarde.',
      );
    } finally {
      if (mounted) setState(() => _isUploadingPhoto = false);
    }
  }

  // Dados pessoais
  Future<void> _savePersonalData() async {
    final name = _nameController.text.trim();
    final phone = _phoneController.text.trim();

    if (name.isEmpty || phone.isEmpty) {
      _showSnack('Preencha todos os campos!');
      return;
    }

    setState(() => _isSavingData = true);

    try {
      await UserModel.updateProfile(name: name, phone: phone);

      final updated = await UserModel.getFullUserData();
      authUserDataProvider.value = updated;

      if (mounted) setState(() => _dataChanged = false);
      _showSnack('Dados salvos com sucesso!', isError: false);
    } on FirebaseFunctionsException catch (err) {
      if (mounted) {
        if (err.code == "invalid-argument") {
          _showSnack("Número de telefone inválido!");
        } else {
          _showSnack(
            "Erro desconhecido interno ao salvar dados! Tente novamente mais tarde!",
          );
        }
      }
    } catch (err) {
      debugPrint("Erro desconhecido ao salvar dados de usuário: $err");
      _showSnack('Erro desconhecido ao salvar dados.');
    } finally {
      if (mounted) setState(() => _isSavingData = false);
    }
  }

  // 2FA
  Future<void> _loadTotpStatus() async {
    try {
      final has2Fa = await UserModel.checkHas2Fa();
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
        await UserModel.disableTotp();

        if (mounted) {
          setState(() => _has2Fa = false);
          _showSnack('2FA desabilitado.', isError: false);
        }
      } catch (_) {
        if (mounted) {
          _showSnack('Erro ao desabilitar 2FA.');
        }
      } finally {
        if (mounted) {
          setState(() => _isTogglingTotp = false);
        }
      }
    } else {
      final enrolled = await Navigator.pushNamed(context, '/auth/activate-2fa');
      if (enrolled == true && mounted) setState(() => _has2Fa = true);
    }
  }

  // Logout
  Future<void> _logout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.campoEscuro,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Sair da conta',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          'Tem certeza que deseja sair?',
          style: TextStyle(color: Colors.white60),
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
              'Sair',
              style: TextStyle(color: Colors.redAccent),
            ),
          ),
        ],
      ),
    );

    if (confirm != true) return;
    setState(() => _isLoggingOut = true);

    try {
      await UserModel.signout();
    } catch (err) {
      debugPrint("Erro no logout: $err");

      if (mounted) {
        _showSnack("Não foi possível fazer logout!");
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoggingOut = false;
        });
      }
    }
  }

  void _showSnack(String msg, {bool isError = true}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, style: const TextStyle(fontWeight: FontWeight.w600)),
        backgroundColor: isError ? Colors.redAccent : AppColors.verdeMescla,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  InputDecoration _inputDecoration(String label) => InputDecoration(
    labelText: label,
    labelStyle: const TextStyle(color: Colors.white38, fontSize: 13),
    filled: true,
    fillColor: const Color(0xFF1A1A1A),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide.none,
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: AppColors.verdeMescla, width: 1.5),
    ),
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
  );

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<UserModel?>(
      valueListenable: authUserDataProvider,
      builder: (context, user, _) {
        return CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: 200,
              pinned: true,
              backgroundColor: AppColors.fundoEscuro,
              automaticallyImplyLeading: false,
              flexibleSpace: FlexibleSpaceBar(background: _buildAvatar(user)),
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(0.5),
                child: Container(height: 0.5, color: Colors.white10),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 28, 20, 40),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  _SectionHeader(label: 'Dados Pessoais'),
                  const SizedBox(height: 14),
                  _buildInfoCard(user),
                  const SizedBox(height: 32),
                  _SectionHeader(label: 'Segurança'),
                  const SizedBox(height: 14),
                  _build2FACard(),
                  const SizedBox(height: 32),
                  _SectionHeader(label: 'Conta'),
                  const SizedBox(height: 14),
                  _buildLogoutCard(),
                  const SizedBox(height: 20),
                ]),
              ),
            ),
          ],
        );
      },
    );
  }

  // Avatar
  Widget _buildAvatar(UserModel? user) {
    final displayName = (user != null && user.name.isNotEmpty)
        ? user.name
        : 'Investidor';
    final email = user?.email ?? '';

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
              Stack(
                alignment: Alignment.bottomRight,
                children: [
                  GestureDetector(
                    onTap: () async {
                      if (!_isUploadingPhoto) {
                        await _pickAndUploadPhoto(user!);
                      }
                    },
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
                      child: ClipOval(
                        child: _isUploadingPhoto
                            ? Container(
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
                              )
                            : _resolvedAvatarUrl != null
                            ? Image.network(
                                _resolvedAvatarUrl!,
                                fit: BoxFit.cover,
                              )
                            : Container(
                                color: AppColors.campoEscuro,
                                child: const Icon(
                                  Icons.person_rounded,
                                  color: Colors.white24,
                                  size: 36,
                                ),
                              ),
                      ),
                    ),
                  ),
                  if (!_isUploadingPhoto)
                    GestureDetector(
                      onTap: () async {
                        await _pickAndUploadPhoto(user!);
                      },
                      child: Container(
                        width: 26,
                        height: 26,
                        decoration: BoxDecoration(
                          color: AppColors.verdeMescla,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.fundoEscuro,
                            width: 2,
                          ),
                        ),
                        child: const Icon(
                          Icons.camera_alt_rounded,
                          size: 13,
                          color: Colors.black,
                        ),
                      ),
                    ),
                ],
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

  // Card dados pessoais
  Widget _buildInfoCard(UserModel? user) {
    return _Card(
      child: Column(
        children: [
          TextField(
            controller: _nameController,
            style: const TextStyle(color: Colors.white),
            decoration: _inputDecoration('Nome completo'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            style: const TextStyle(color: Colors.white),
            decoration: _inputDecoration('Telefone'),
          ),
          const SizedBox(height: 12),
          _ReadOnlyField(label: 'CPF', value: user?.cpf ?? ''),
          const SizedBox(height: 12),
          _ReadOnlyField(label: 'E-mail', value: user?.email ?? ''),
          const SizedBox(height: 20),
          AnimatedOpacity(
            opacity: _dataChanged ? 1.0 : 0.4,
            duration: const Duration(milliseconds: 200),
            child: SizedBox(
              width: double.infinity,
              child: FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.verdeMescla,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: _dataChanged && !_isSavingData
                    ? _savePersonalData
                    : null,
                child: _isSavingData
                    ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.black,
                        ),
                      )
                    : const Text(
                        'Salvar alterações',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Card 2FA
  Widget _build2FACard() {
    final isActive = _has2Fa == true;
    final isLoading = _has2Fa == null || _isTogglingTotp;

    return _Card(
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

  // Card logout
  Widget _buildLogoutCard() {
    return _Card(
      child: GestureDetector(
        onTap: _isLoggingOut ? null : _logout,
        behavior: HitTestBehavior.opaque,
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: Colors.redAccent.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.logout_rounded,
                color: Colors.redAccent,
                size: 20,
              ),
            ),
            const SizedBox(width: 16),
            const Expanded(
              child: Text(
                'Sair da conta',
                style: TextStyle(
                  color: Colors.redAccent,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ),
            _isLoggingOut
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.redAccent,
                    ),
                  )
                : const Icon(
                    Icons.chevron_right_rounded,
                    color: Colors.redAccent,
                    size: 20,
                  ),
          ],
        ),
      ),
    );
  }
}

class _Card extends StatelessWidget {
  final Widget child;
  const _Card({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: child,
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String label;
  const _SectionHeader({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(
      label.toUpperCase(),
      style: const TextStyle(
        color: Colors.white38,
        fontSize: 11,
        fontWeight: FontWeight.bold,
        letterSpacing: 1.4,
      ),
    );
  }
}

class _ReadOnlyField extends StatelessWidget {
  final String label;
  final String value;
  const _ReadOnlyField({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(color: Colors.white24, fontSize: 11),
          ),
          const SizedBox(height: 3),
          Text(
            value.isNotEmpty ? value : '—',
            style: const TextStyle(color: Colors.white54, fontSize: 14),
          ),
        ],
      ),
    );
  }
}
