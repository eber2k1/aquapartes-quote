import 'package:flutter/material.dart';

import '../../../../core/services/app_notifications.dart';
import '../../auth_module.dart';
import '../../domain/entities/auth_session.dart';
import '../../domain/repositories/auth_repository.dart';

class AuthLoginPage extends StatefulWidget {
  const AuthLoginPage({
    super.key,
    required this.onSignedIn,
    required this.onContinueAsGuest,
  });

  final ValueChanged<AuthSession> onSignedIn;
  final Future<void> Function() onContinueAsGuest;

  @override
  State<AuthLoginPage> createState() => _AuthLoginPageState();
}

class _AuthLoginPageState extends State<AuthLoginPage> {
  final AuthRepository _repository = getAuthRepository();
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _codeController = TextEditingController();
  bool _isRequestingCode = false;
  bool _isVerifyingCode = false;
  bool _codeRequested = false;

  @override
  void dispose() {
    _emailController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _requestCode() async {
    if (!_formKey.currentState!.validate()) return;
    final messenger = ScaffoldMessenger.of(context);

    setState(() {
      _isRequestingCode = true;
    });

    try {
      final result = await _repository.requestCode(
        _emailController.text.trim(),
      );
      if (!mounted) return;

      setState(() {
        _codeRequested = true;
      });

      _showMessage(
        messenger,
        result.message.isEmpty
            ? 'Se envio el codigo de verificacion.'
            : result.message,
      );
    } catch (error) {
      if (mounted) {
        _showMessage(messenger, _readErrorMessage(error));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isRequestingCode = false;
        });
      }
    }
  }

  Future<void> _verifyCode() async {
    if (!_formKey.currentState!.validate()) return;
    final messenger = ScaffoldMessenger.of(context);
    if (_codeController.text.trim().isEmpty) {
      _showMessage(messenger, 'Ingresa el codigo de verificacion.');
      return;
    }

    setState(() {
      _isVerifyingCode = true;
    });

    try {
      final session = await _repository.verifyCode(
        email: _emailController.text.trim(),
        code: _codeController.text.trim(),
      );
      if (!mounted) return;

      AppNotifications.showSuccess(
        'Bienvenido ${session.user.fullName.isEmpty ? session.user.email : session.user.fullName}.',
      );
      widget.onSignedIn(session);
    } catch (error) {
      if (mounted) {
        _showMessage(messenger, _readErrorMessage(error));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isVerifyingCode = false;
        });
      }
    }
  }

  String _readErrorMessage(Object error) {
    final rawMessage = error.toString().trim();
    if (rawMessage.startsWith('Exception: ')) {
      return rawMessage.substring('Exception: '.length).trim();
    }
    return rawMessage.isEmpty ? 'No se pudo iniciar sesion.' : rawMessage;
  }

  void _showMessage(ScaffoldMessengerState messenger, String message) {
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Center(
                      child: Hero(
                        tag: 'app_logo',
                        child: Image.asset(
                          'assets/aquapartes_logo.png',
                          height: 220,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    Text(
                      'Bienvenido',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.5,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        'Ingresa tu correo para recibir un codigo de acceso seguro.',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                          height: 1.4,
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    if (!_codeRequested) ...[
                      TextFormField(
                        controller: _emailController,
                        enabled: !_isRequestingCode,
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(labelText: 'Correo'),
                        validator: (value) {
                          final email = value?.trim() ?? '';
                          if (email.isEmpty) {
                            return 'Ingresa tu correo';
                          }
                          final emailRegex = RegExp(
                            r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                          );
                          if (!emailRegex.hasMatch(email)) {
                            return 'Ingresa un correo electrónico exacto y válido';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                    ],
                    if (_codeRequested) ...[
                      TextFormField(
                        controller: _codeController,
                        enabled: !_isVerifyingCode,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Codigo de verificacion',
                        ),
                        validator: (value) {
                          if (!_codeRequested) return null;
                          if ((value?.trim() ?? '').isEmpty) {
                            return 'Ingresa el codigo';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                    ],
                    FilledButton(
                      onPressed: _isRequestingCode || _isVerifyingCode
                          ? null
                          : (_codeRequested ? _verifyCode : _requestCode),
                      child: _isRequestingCode || _isVerifyingCode
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Text(
                              _codeRequested
                                  ? 'Verificar codigo'
                                  : 'Enviar codigo',
                            ),
                    ),
                    const SizedBox(height: 12),
                    OutlinedButton.icon(
                      onPressed: _isRequestingCode || _isVerifyingCode
                          ? null
                          : () async {
                              await widget.onContinueAsGuest();
                            },
                      icon: const Icon(Icons.wifi_off_outlined),
                      label: const Text('Continuar como invitado'),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Modo invitado: acceso solo con datos guardados localmente.',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    if (_codeRequested) ...[
                      const SizedBox(height: 12),
                      TextButton(
                        onPressed: _isRequestingCode || _isVerifyingCode
                            ? null
                            : () {
                                setState(() {
                                  _codeRequested = false;
                                  _codeController.clear();
                                });
                              },
                        child: const Text('Cambiar correo'),
                      ),
                      TextButton(
                        onPressed: _isRequestingCode || _isVerifyingCode
                            ? null
                            : _requestCode,
                        child: const Text('Reenviar codigo'),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
