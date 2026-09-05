import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:my_first_app/features/auth/presentation/view_models/auth_view_model.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({
    super.key,
    required this.viewModel,
    this.onCancel,
    this.onContinueAsGuest,
  });

  final AuthViewModel viewModel;
  final VoidCallback? onCancel;
  final VoidCallback? onContinueAsGuest;

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isRegistering = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submitEmail() async {
    if (!_formKey.currentState!.validate()) return;
    if (_isRegistering || (widget.viewModel.user?.isAnonymous ?? false)) {
      await widget.viewModel.registerWithEmail(
        _emailController.text.trim(),
        _passwordController.text,
      );
    } else {
      await widget.viewModel.signInWithEmail(
        _emailController.text.trim(),
        _passwordController.text,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isGuest = widget.viewModel.user?.isAnonymous ?? false;
    final returnsToTodos = (isGuest && widget.onCancel != null) ||
        (!isGuest && widget.onContinueAsGuest != null);
    return WillPopScope(
      onWillPop: () async {
        if (!returnsToTodos) return true;
        if (isGuest) {
          widget.onCancel?.call();
        } else {
          widget.onContinueAsGuest?.call();
        }
        return false;
      },
      child: Scaffold(
        appBar: isGuest && kIsWeb
            ? AppBar(
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back),
                  tooltip: '返回待辦',
                  onPressed: widget.onCancel,
                ),
                title: const Text('建立帳號'),
              )
            : null,
        body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: ListenableBuilder(
                listenable: widget.viewModel,
                builder: (context, _) => Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      isGuest ? '保留訪客待辦' : '今日待辦',
                      style: Theme.of(context).textTheme.displaySmall,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      isGuest
                          ? '你正在使用訪客模式。建立帳號可保留目前待辦。'
                          : '登入後即可在不同裝置保存你的待辦。',
                    ),
                    const SizedBox(height: 24),
                    OutlinedButton.icon(
                      onPressed: widget.viewModel.isSubmitting
                          ? null
                          : () => unawaited(widget.viewModel.signInWithGoogle()),
                      icon: const Icon(Icons.account_circle_outlined),
                      label: Text(
                        isGuest ? '使用 Google 註冊並保留待辦' : '使用 Google 登入',
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 20),
                      child: Row(
                        children: [Expanded(child: Divider()), Padding(padding: EdgeInsets.symmetric(horizontal: 12), child: Text('或')), Expanded(child: Divider())],
                      ),
                    ),
                    Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          TextFormField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            autofillHints: const [AutofillHints.email],
                            decoration: const InputDecoration(labelText: 'Email', border: OutlineInputBorder()),
                            validator: (value) => value != null && value.contains('@') ? null : '請輸入正確的 Email',
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _passwordController,
                            obscureText: true,
                            autofillHints: const [AutofillHints.password],
                            decoration: const InputDecoration(labelText: '密碼', border: OutlineInputBorder()),
                            validator: (value) => value != null && value.length >= 6 ? null : '密碼至少 6 個字元',
                          ),
                        ],
                      ),
                    ),
                    if (widget.viewModel.errorMessage case final message?) ...[
                      const SizedBox(height: 12),
                      Text(message, style: TextStyle(color: Theme.of(context).colorScheme.error)),
                    ],
                    const SizedBox(height: 16),
                    FilledButton(
                      onPressed: widget.viewModel.isSubmitting ? null : () => unawaited(_submitEmail()),
                      child: Text(
                        widget.viewModel.isSubmitting
                            ? '處理中…'
                            : (isGuest || _isRegistering)
                            ? '建立並綁定 Email 帳號'
                            : 'Email 登入',
                      ),
                    ),
                    if (!isGuest)
                      TextButton(
                        onPressed: widget.viewModel.isSubmitting
                            ? null
                            : () => setState(
                                () => _isRegistering = !_isRegistering,
                              ),
                        child: Text(
                          _isRegistering
                              ? '已有帳號？改為登入'
                              : '還沒有帳號？建立帳號',
                        ),
                      ),
                    if (!isGuest && widget.onContinueAsGuest != null)
                      TextButton.icon(
                        onPressed: widget.viewModel.isSubmitting
                            ? null
                            : widget.onContinueAsGuest,
                        icon: const Icon(Icons.person_outline),
                        label: const Text('先以訪客身分繼續'),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
        ),
      ),
    );
  }
}
