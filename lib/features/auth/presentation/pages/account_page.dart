import 'package:flutter/material.dart';
import 'package:my_first_app/features/auth/domain/models/app_user.dart';

class AccountPage extends StatelessWidget {
  const AccountPage({
    super.key,
    required this.user,
    required this.onBack,
    required this.onSignOut,
  });

  final AppUser user;
  final VoidCallback onBack;
  final VoidCallback onSignOut;

  @override
  Widget build(BuildContext context) {
    final name = _firstNonEmpty(user.displayName, user.email) ?? '會員';
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) onBack();
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            tooltip: '返回待辦',
            onPressed: onBack,
          ),
          title: const Text('會員中心'),
        ),
        body: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 560),
              child: ListView(
                padding: const EdgeInsets.all(24),
                children: [
                  CircleAvatar(
                    radius: 46,
                    child: Text(
                      name.substring(0, 1).toUpperCase(),
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: Text(
                      name,
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                  ),
                  if (user.email != null) ...[
                    const SizedBox(height: 4),
                    Center(child: Text(user.email!)),
                  ],
                  const SizedBox(height: 32),
                  const ListTile(
                    leading: Icon(Icons.cloud_done_outlined),
                    title: Text('待辦已同步到你的帳號'),
                    subtitle: Text('登入相同帳號即可在其他裝置繼續使用。'),
                  ),
                  const SizedBox(height: 16),
                  OutlinedButton.icon(
                    onPressed: onSignOut,
                    icon: const Icon(Icons.logout),
                    label: const Text('登出'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  String? _firstNonEmpty(String? primary, String? fallback) {
    final primaryValue = primary?.trim();
    if (primaryValue?.isNotEmpty ?? false) return primaryValue;
    final fallbackValue = fallback?.trim();
    if (fallbackValue?.isNotEmpty ?? false) return fallbackValue;
    return null;
  }
}
