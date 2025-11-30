import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../providers/auth_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  String _pin = "";

  void _onKeyPress(String value) {
    if (_pin.length < 4) {
      setState(() {
        _pin += value;
      });
      if (_pin.length == 4) {
        _attemptLogin();
      }
    }
  }

  void _onDelete() {
    if (_pin.isNotEmpty) {
      setState(() {
        _pin = _pin.substring(0, _pin.length - 1);
      });
    }
  }

  Future<void> _attemptLogin() async {
    await ref.read(authProvider.notifier).loginWithPin(_pin);

    if (ref.read(authProvider).isAuthenticated) {
      if (mounted) context.go('/lab');
    } else {
      setState(() {
        _pin = ""; // Reset on failure
      });
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Access Denied")));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(authProvider).isLoading;

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Abstract Logo / Animation
            const Icon(Icons.science, size: 80, color: Colors.cyan)
                .animate(onPlay: (controller) => controller.repeat())
                .shimmer(duration: 2.seconds, color: Colors.white),
            const SizedBox(height: 40),

            // PIN Display (Abstract Dots)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(4, (index) {
                return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 10),
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: index < _pin.length
                            ? Colors.cyan
                            : Colors.grey.withOpacity(0.3),
                        boxShadow: index < _pin.length
                            ? [
                                BoxShadow(
                                  color: Colors.cyan.withOpacity(0.5),
                                  blurRadius: 10,
                                ),
                              ]
                            : [],
                      ),
                    )
                    .animate(target: index < _pin.length ? 1 : 0)
                    .scale(duration: 200.ms);
              }),
            ),
            const SizedBox(height: 60),

            if (isLoading)
              const CircularProgressIndicator()
            else
              // Keypad
              SizedBox(
                width: 300,
                child: GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    childAspectRatio: 1.5,
                    mainAxisSpacing: 20,
                    crossAxisSpacing: 20,
                  ),
                  itemCount: 12,
                  itemBuilder: (context, index) {
                    if (index == 9)
                      return const SizedBox(); // Empty bottom left
                    if (index == 11) {
                      return _buildKey(
                        icon: Icons.backspace_outlined,
                        onTap: _onDelete,
                      );
                    }

                    final number = index == 10 ? "0" : "${index + 1}";
                    return _buildKey(
                      text: number,
                      onTap: () => _onKeyPress(number),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildKey({
    String? text,
    IconData? icon,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(40),
        child: Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white.withOpacity(0.1)),
            color: Colors.white.withOpacity(0.05),
          ),
          child: Center(
            child: text != null
                ? Text(
                    text,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  )
                : Icon(icon, size: 24),
          ),
        ),
      ),
    );
  }
}
