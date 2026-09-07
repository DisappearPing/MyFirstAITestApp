import 'dart:async';

import 'package:flutter/material.dart';
import 'package:my_first_app/features/auth/data/repositories/auth_repository.dart';
import 'package:my_first_app/features/auth/presentation/pages/account_page.dart';
import 'package:my_first_app/features/auth/presentation/pages/auth_page.dart';
import 'package:my_first_app/features/auth/presentation/view_models/auth_view_model.dart';
import 'package:my_first_app/features/todos/data/repositories/firestore_todo_repository.dart';
import 'package:my_first_app/features/todos/data/repositories/firebase_storage_todo_image_repository.dart';
import 'package:my_first_app/features/todos/presentation/pages/todo_list_page.dart';
import 'package:my_first_app/features/todos/presentation/view_models/todo_list_view_model.dart';

class AuthGate extends StatefulWidget {
  const AuthGate({super.key, required this.authRepository});

  final AuthRepository authRepository;

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  late final AuthViewModel _authViewModel;
  TodoListViewModel? _todoViewModel;
  String? _todoUserId;
  bool _showAccountPage = false;

  @override
  void initState() {
    super.initState();
    _authViewModel = AuthViewModel(widget.authRepository)..addListener(_onAuthChanged);
    _authViewModel.initialize();
  }

  void _onAuthChanged() {
    final user = _authViewModel.user;
    if (user != null && !user.isAnonymous) _showAccountPage = false;
    if (user?.id != _todoUserId) {
      _todoViewModel?.dispose();
      _todoUserId = user?.id;
      _todoViewModel = user == null
          ? null
          : TodoListViewModel(
              FirestoreTodoRepository(userId: user.id),
              imageRepository: FirebaseStorageTodoImageRepository(
                userId: user.id,
              ),
            );
    }
    if (mounted) setState(() {});
  }

  void _signOut() {
    setState(() => _showAccountPage = false);
    unawaited(_authViewModel.signOut());
  }

  @override
  void dispose() {
    _authViewModel
      ..removeListener(_onAuthChanged)
      ..dispose();
    _todoViewModel?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_authViewModel.isInitializing) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    final user = _authViewModel.user;
    final Widget page;
    if (user == null) {
      page = AuthPage(
        key: const ValueKey('sign-in'),
        viewModel: _authViewModel,
        onContinueAsGuest: () => unawaited(_authViewModel.continueAsGuest()),
      );
    } else if (_showAccountPage && user.isAnonymous) {
      page = AuthPage(
        key: const ValueKey('register'),
        viewModel: _authViewModel,
        onCancel: () => setState(() => _showAccountPage = false),
      );
    } else if (_showAccountPage) {
      page = AccountPage(
        key: const ValueKey('account'),
        user: user,
        onBack: () => setState(() => _showAccountPage = false),
        onSignOut: _signOut,
      );
    } else {
      page = TodoListPage(
        key: ValueKey('todos-${user.id}'),
        viewModel: _todoViewModel!,
        userEmail: user.email,
        isGuest: user.isAnonymous,
        onSignOut: _signOut,
        onOpenAccount: () => setState(() => _showAccountPage = true),
      );
    }
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 280),
      switchInCurve: Curves.easeOut,
      switchOutCurve: Curves.easeIn,
      transitionBuilder: (child, animation) => FadeTransition(
        opacity: animation,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0.02, 0),
            end: Offset.zero,
          ).animate(animation),
          child: child,
        ),
      ),
      child: page,
    );
  }
}
