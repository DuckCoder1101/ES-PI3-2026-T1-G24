// Autor: Cristian Eduardo Fava
// RA: 25000636

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pinput/pinput.dart';
import 'package:qr_flutter/qr_flutter.dart';

import 'package:mescla_invest/constants/colors.dart';
import 'package:mescla_invest/models/user/user.dart';
import 'package:mescla_invest/widgets/ui/primary_button.dart';
import 'package:url_launcher/url_launcher.dart';

/// Tela para ativar o 2FA via TOTP (Google Authenticator, Authy etc).
class Activate2FAScreen extends StatefulWidget {
  const Activate2FAScreen({super.key});

  @override
  State<Activate2FAScreen> createState() => _Activate2FAScreenState();
}

class _Activate2FAScreenState extends State<Activate2FAScreen> {
  final _pinController = TextEditingController();

  bool _loadingQr = true;
  bool _isActivating = false;

  String? _otpauthUrl;
  TotpSecret? _secret;

  String? _qrError;

  @override
  void initState() {
    super.initState();
    _initActivation();
  }

  @override
  void dispose() {
    _pinController.dispose();
    super.dispose();
  }

  Future<void> _initActivation() async {
    setState(() {
      _loadingQr = true;
      _qrError = null;
    });

    final user = FirebaseAuth.instance.currentUser!;
    final accountName = user.email ?? 'usuário';

    try {
      final result = await UserModel.beginTotpActivation(accountName);
      if (!mounted) return;

      setState(() {
        _otpauthUrl = result.otpauthUrl;
        _secret = result.secret;
      });
    } on PlatformException catch (e) {
      final code = e.code.toUpperCase();

      // LOGIN RECENTE
      if (code.contains("REQUIRES_RECENT_LOGIN")) {
        final success = await _showReauthenticationDialog();
        if (success) {
          await _initActivation();
        }
      }
    } on FirebaseAuthException catch (_) {
      // LOGIN RECENTE
      final success = await _showReauthenticationDialog();
      if (success) {
        await _initActivation();
      }
    } catch (_) {
      // OUTRO ERRO
      if (!mounted) return;

      setState(() {
        _qrError = 'Erro ao gerar QR code. Tente novamente.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _loadingQr = false;
        });
      }
    }
  }

  Future<bool> _showReauthenticationDialog() async {
    final passwordController = TextEditingController();

    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        bool loading = false;
        String? error;

        return StatefulBuilder(
          builder: (context, setModalState) {
            return AlertDialog(
              backgroundColor: AppColors.campoEscuro,
              title: const Text(
                'Confirme sua senha',
                style: TextStyle(color: Colors.white),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Por segurança, confirme sua senha para continuar.',
                    style: TextStyle(color: Colors.white70),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: passwordController,
                    obscureText: true,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Senha',
                      hintStyle: const TextStyle(color: Colors.white38),
                      errorText: error,
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: loading
                      ? null
                      : () => Navigator.pop(context, false),
                  child: const Text('Cancelar'),
                ),
                ElevatedButton(
                  onPressed: loading
                      ? null
                      : () async {
                          try {
                            setModalState(() {
                              loading = true;
                              error = null;
                            });

                            final user = FirebaseAuth.instance.currentUser!;

                            final credential = EmailAuthProvider.credential(
                              email: user.email!,
                              password: passwordController.text,
                            );

                            await user.reauthenticateWithCredential(credential);

                            if (context.mounted) {
                              Navigator.pop(context, true);
                            }
                          } on FirebaseAuthException {
                            setModalState(() {
                              error = 'Senha incorreta';
                              loading = false;
                            });
                          }
                        },
                  child: loading
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Confirmar'),
                ),
              ],
            );
          },
        );
      },
    );

    return result ?? false;
  }

  Future<void> _confirmActivation() async {
    final code = _pinController.text.trim();

    if (code.length != 6) {
      _showSnackBar('Digite o código completo de 6 dígitos.');
      return;
    }

    if (_secret == null) {
      _showSnackBar('QR code não gerado.');
      return;
    }

    setState(() => _isActivating = true);

    try {
      await UserModel.finalizeTotpActivation(_secret!, code);

      if (mounted) {
        _showSnackBar('2FA ativado com sucesso!', isError: false);

        Navigator.of(context).pop(true);
      }
    } on FirebaseAuthException catch (e) {
      final message = e.code == 'invalid-verification-code'
          ? 'Código inválido. Verifique no autenticador.'
          : 'Erro ao ativar 2FA: ${e.message}';

      _showSnackBar(message);
    } catch (_) {
      _showSnackBar('Ocorreu um erro inesperado.');
    } finally {
      if (mounted) {
        setState(() => _isActivating = false);
      }
    }
  }

  void _showSnackBar(String message, {bool isError = true}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.redAccent : Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final defaultPinTheme = PinTheme(
      width: 45,
      height: 55,
      textStyle: const TextStyle(
        fontSize: 22,
        color: Colors.white,
        fontWeight: FontWeight.bold,
      ),
      decoration: BoxDecoration(
        color: AppColors.campoEscuro,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white24),
      ),
    );

    return Scaffold(
      backgroundColor: AppColors.fundoEscuro,
      appBar: AppBar(
        backgroundColor: AppColors.fundoEscuro,
        foregroundColor: Colors.white,
        title: const Text('Ativar autenticação em 2 etapas'),
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildStep(
                number: '1',
                title: 'Escaneie o QR code',
                child: _buildQrSection(),
              ),

              const SizedBox(height: 32),

              _buildStep(
                number: '2',
                title: 'Digite o código gerado pelo app',
                child: Column(
                  children: [
                    Center(
                      child: Pinput(
                        controller: _pinController,
                        length: 6,
                        defaultPinTheme: defaultPinTheme,
                        separatorBuilder: (_) => const SizedBox(width: 8),
                        focusedPinTheme: defaultPinTheme.copyWith(
                          decoration: defaultPinTheme.decoration!.copyWith(
                            border: Border.all(color: AppColors.verdeMescla),
                          ),
                        ),
                        onCompleted: (_) => _confirmActivation(),
                      ),
                    ),

                    const SizedBox(height: 24),

                    PrimaryButton(
                      text: 'Ativar 2FA',
                      onPressed: _confirmActivation,
                      isLoading: _isActivating,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStep({
    required String number,
    required String title,
    required Widget child,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: const BoxDecoration(
                color: AppColors.verdeMescla,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Text(
                number,
                style: const TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(width: 12),

            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 16),

        child,
      ],
    );
  }

  Widget _buildQrSection() {
    if (_loadingQr) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: CircularProgressIndicator(color: AppColors.verdeMescla),
        ),
      );
    }

    if (_qrError != null) {
      return Center(
        child: Column(
          children: [
            Text(
              _qrError!,
              style: const TextStyle(color: Colors.redAccent),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        const Text(
          'Abra o Google Authenticator ou outro app compatível '
          'e escaneie o código abaixo.',
          style: TextStyle(color: Colors.white60, fontSize: 13),
        ),

        const SizedBox(height: 20),

        Center(
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: QrImageView(
              data: _otpauthUrl!,
              version: QrVersions.auto,
              size: 200,
            ),
          ),
        ),

        const SizedBox(height: 12),

        GestureDetector(
          onTap: () async {
            final uri = Uri.parse(_otpauthUrl!);

            if (await canLaunchUrl(uri)) {
              await launchUrl(uri);
            } else {
              Clipboard.setData(ClipboardData(text: _otpauthUrl!));

              _showSnackBar('URL copiada!', isError: false);
            }
          },
          child: const Text(
            'Não consegue escanear? Abra o autenticador por aqui!',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.verdeMescla,
              fontSize: 12,
              decoration: TextDecoration.underline,
              decorationColor: AppColors.verdeMescla,
            ),
          ),
        ),
      ],
    );
  }
}
