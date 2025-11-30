import 'package:flutter_riverpod/flutter_riverpod.dart';

// Simple User Model
class User {
  final String username;
  final Map<String, dynamic> permissions;

  User({required this.username, required this.permissions});
}

// Auth State
class AuthState {
  final bool isAuthenticated;
  final User? user;
  final bool isLoading;
  final String? error;

  AuthState({
    this.isAuthenticated = false,
    this.user,
    this.isLoading = false,
    this.error,
  });

  AuthState copyWith({
    bool? isAuthenticated,
    User? user,
    bool? isLoading,
    String? error,
  }) {
    return AuthState(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

// Auth Notifier
class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier() : super(AuthState());

  Future<void> loginWithPin(String pin) async {
    state = state.copyWith(isLoading: true, error: null);

    // Simulate API Call delay
    await Future.delayed(const Duration(seconds: 1));

    // Mock Logic: In production, call ApiService to verify PIN
    if (pin == "1234") {
      // Admin
      state = state.copyWith(
        isAuthenticated: true,
        isLoading: false,
        user: User(
          username: "Admin",
          permissions: {"can_see_cost": true, "can_approve": true},
        ),
      );
    } else if (pin == "0000") {
      // Operator
      state = state.copyWith(
        isAuthenticated: true,
        isLoading: false,
        user: User(
          username: "Operator",
          permissions: {"can_see_cost": false, "can_approve": false},
        ),
      );
    } else {
      state = state.copyWith(isLoading: false, error: "Invalid PIN");
    }
  }

  void logout() {
    state = AuthState();
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});
