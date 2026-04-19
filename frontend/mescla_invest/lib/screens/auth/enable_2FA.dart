/// Autor: Cristian Eduardo Fava
/// RA: 25000636

import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';

import 'package:mescla_invest/constants/colors.dart';
import 'package:mescla_invest/components/primary_button.dart';

class Enable2FAScreen extends StatefulWidget {
  const Enable2FAScreen({super.key});

  @override
  State<Enable2FAScreen> createState() => _Enable2FAScreenState();
}

class _Enable2FAScreenState extends State<Enable2FAScreen> {
  String? _qrCodeUri;
  String? _manualKey;
  bool _isFetching = true;

  @override
  void initState() {
    super.initState();
    _fetch2FADetails();
  }

  Future<void> _fetch2FADetails() async {
    try {
      final result = await FirebaseFunctions.instance
          .httpsCallable('enable2FA')
          .call();

      debugPrint(result.data.toString());

      setState(() {
        _qrCodeUri = result.data['qrCode'];
        _manualKey = result.data['manualCode'];
        _isFetching = false;
      });
    } catch (e) {
      debugPrint("DEU MERDA");
      debugPrint(e.toString());
      _showError('Erro ao carregar dados do MFA.');
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: Colors.redAccent),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.fundoEscuro,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Segurança'),
      ),
      body: _isFetching
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.verdeMescla),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Ativar MFA / 2FA',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 32),
                  _buildStep(1, 'Instale um autenticador'),
                  _buildStep(2, 'Escaneie o QR code abaixo'),
                  const SizedBox(height: 24),

                  // QR Code Real vindo da Function
                  if (_qrCodeUri != null)
                    Center(
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: QrImageView(data: _qrCodeUri!, size: 200),
                      ),
                    ),
                  const SizedBox(height: 16),

                  const Text(
                    'Ou insira a chave manualmente:',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white70),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SelectableText(
                        _manualKey ?? '',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.copy,
                          color: AppColors.verdeMescla,
                          size: 20,
                        ),
                        onPressed: () {
                          Clipboard.setData(
                            ClipboardData(text: _manualKey ?? ''),
                          );
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Copiado!')),
                          );
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 40),
                  PrimaryButton(
                    text: 'Próximo Passo',
                    onPressed: () =>
                        Navigator.pushNamed(context, 'confirm-2fa'),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildStep(int n, String texto) {
    return RichText(
      text: TextSpan(
        style: const TextStyle(color: Colors.white, fontSize: 14),
        children: [
          TextSpan(
            text: 'Passo $n: ',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          TextSpan(text: texto),
        ],
      ),
    );
  }
}
