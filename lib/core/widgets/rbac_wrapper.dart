import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/auth/providers/auth_provider.dart';

class RBACWrapper extends ConsumerWidget {
  final String permissionKey;
  final Widget child;

  const RBACWrapper({
    super.key,
    required this.permissionKey,
    required this.child,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);

    if (!authState.isAuthenticated || authState.user == null) {
      return const SizedBox.shrink();
    }

    final hasPermission = authState.user!.permissions[permissionKey] == true;

    if (hasPermission) {
      return child;
    } else {
      return const SizedBox.shrink();
    }
  }
}
