/// auth_screen.dart
/// Authentication screen with three sign-in methods:
/// - Email (sign up / sign in)
/// - Web3 Wallet (Sign In With Solana)
/// - Guest (anonymous auth)
///
/// Shown on first launch or when no valid session exists.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/supabase_service.dart';
import '../solana/wallet_service.dart';

enum AuthMode { landing, emailSignIn, emailSignUp }

class AuthScreen extends StatefulWidget {
  final VoidCallback onAuthenticated;

  const AuthScreen({super.key, required this.onAuthenticated});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> with SingleTickerProviderStateMixin {
  AuthMode _mode = AuthMode.landing;
  bool _loading = false;
  String? _error;
  String? _successMessage;

  // Email form
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;

  late AnimationController _fadeController;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnim = CurvedAnimation(parent: _fadeController, curve: Curves.easeOut);
    _fadeController.forward();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  void _setError(String msg) {
    if (mounted) setState(() { _error = msg; _loading = false; });
  }

  void _clearMessages() {
    setState(() { _error = null; _successMessage = null; });
  }

  // ── Email Sign In ────────────────────────────────────────────

  Future<void> _emailSignIn() async {
    _clearMessages();
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      _setError('Please enter your email and password');
      return;
    }

    setState(() => _loading = true);

    try {
      await SupabaseService.instance.signInWithEmail(email, password);
      widget.onAuthenticated();
    } catch (e) {
      _setError(_friendlyAuthError(e));
    }
  }

  // ── Email Sign Up ────────────────────────────────────────────

  Future<void> _emailSignUp() async {
    _clearMessages();
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;

    if (email.isEmpty || password.isEmpty) {
      _setError('Please enter your email and password');
      return;
    }
    if (password.length < 6) {
      _setError('Password must be at least 6 characters');
      return;
    }
    if (password != confirmPassword) {
      _setError('Passwords do not match');
      return;
    }

    setState(() => _loading = true);

    try {
      final needsConfirmation = await SupabaseService.instance.signUpWithEmail(email, password);
      if (needsConfirmation) {
        setState(() {
          _successMessage = 'Check your email to confirm your account!';
          _loading = false;
          _mode = AuthMode.emailSignIn;
        });
      } else {
        widget.onAuthenticated();
      }
    } catch (e) {
      _setError(_friendlyAuthError(e));
    }
  }

  // ── Wallet Sign In ───────────────────────────────────────────

  Future<void> _walletSignIn() async {
    _clearMessages();
    setState(() => _loading = true);

    try {
      final wallet = context.read<WalletService>();

      // Step 1: Connect wallet if not connected
      if (!wallet.isConnected) {
        final connected = await wallet.connect();
        if (!connected) {
          _setError('Wallet connection cancelled');
          return;
        }
      }

      final pubkey = wallet.publicKey;
      if (pubkey == null) {
        _setError('Could not get wallet address');
        return;
      }

      // Step 2: Get sign-in message from server
      final message = await SupabaseService.instance.getWalletSignInMessage(pubkey);

      // Step 3: Sign message via MWA
      final signedBytes = await wallet.signMessage(message);
      if (signedBytes == null) {
        _setError('Message signing was cancelled');
        return;
      }

      // Step 4: Verify signature and get session
      await SupabaseService.instance.verifyWalletSignature(
        walletAddress: pubkey,
        signature: signedBytes,
        message: message,
      );

      widget.onAuthenticated();
    } catch (e) {
      _setError(_friendlyAuthError(e));
    }
  }

  // ── Guest Sign In ────────────────────────────────────────────

  Future<void> _guestSignIn() async {
    _clearMessages();
    setState(() => _loading = true);

    try {
      await SupabaseService.instance.signInAsGuest();
      widget.onAuthenticated();
    } catch (e) {
      _setError(_friendlyAuthError(e));
    }
  }

  String _friendlyAuthError(dynamic e) {
    final msg = e.toString().toLowerCase();
    if (msg.contains('invalid login')) return 'Invalid email or password';
    if (msg.contains('user already registered')) return 'An account with this email already exists';
    if (msg.contains('email not confirmed')) return 'Please confirm your email first';
    if (msg.contains('network') || msg.contains('socket')) return 'Network error — check your connection';
    if (msg.contains('rate limit')) return 'Too many attempts — try again later';
    if (msg.contains('cancelled') || msg.contains('canceled')) return 'Cancelled';
    final str = e.toString();
    return str.length > 80 ? '${str.substring(0, 80)}...' : str;
  }

  // ── Build ────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0d0d1a),
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnim,
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: _mode == AuthMode.landing
                  ? _buildLanding()
                  : _buildEmailForm(),
            ),
          ),
        ),
      ),
    );
  }

  // ── Landing (method selection) ───────────────────────────────

  Widget _buildLanding() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Logo / Title
        const Text(
          '⛏',
          style: TextStyle(fontSize: 56),
        ),
        const SizedBox(height: 12),
        const Text(
          'DIGGLE',
          style: TextStyle(
            color: Colors.white,
            fontSize: 36,
            fontWeight: FontWeight.w900,
            letterSpacing: 6,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Mine deep. Earn rewards.',
          style: TextStyle(
            color: Colors.white.withOpacity(0.4),
            fontSize: 14,
            letterSpacing: 1,
          ),
        ),

        const SizedBox(height: 48),

        // Email sign in
        _buildAuthButton(
          label: 'SIGN IN WITH EMAIL',
          icon: Icons.email_outlined,
          color: const Color(0xFF2563eb),
          onTap: () => setState(() => _mode = AuthMode.emailSignIn),
        ),

        const SizedBox(height: 12),

        // Wallet sign in
        _buildAuthButton(
          label: 'SIGN IN WITH WALLET',
          icon: Icons.account_balance_wallet_outlined,
          color: const Color(0xFF9333ea),
          onTap: _loading ? null : _walletSignIn,
          loading: _loading,
        ),

        const SizedBox(height: 24),

        // Divider
        Row(
          children: [
            Expanded(child: Divider(color: Colors.white.withOpacity(0.1))),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'OR',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.3),
                  fontSize: 12,
                  letterSpacing: 2,
                ),
              ),
            ),
            Expanded(child: Divider(color: Colors.white.withOpacity(0.1))),
          ],
        ),

        const SizedBox(height: 24),

        // Guest
        TextButton(
          onPressed: _loading ? null : _guestSignIn,
          child: Text(
            'Play as Guest',
            style: TextStyle(
              color: Colors.white.withOpacity(0.5),
              fontSize: 14,
              decoration: TextDecoration.underline,
              decorationColor: Colors.white.withOpacity(0.3),
            ),
          ),
        ),

        if (_error != null) ...[
          const SizedBox(height: 16),
          _buildErrorBanner(),
        ],

        if (_successMessage != null) ...[
          const SizedBox(height: 16),
          _buildSuccessBanner(),
        ],
      ],
    );
  }

  // ── Email Form ───────────────────────────────────────────────

  Widget _buildEmailForm() {
    final isSignUp = _mode == AuthMode.emailSignUp;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Back button
        Align(
          alignment: Alignment.centerLeft,
          child: IconButton(
            onPressed: () {
              _clearMessages();
              setState(() => _mode = AuthMode.landing);
            },
            icon: Icon(Icons.arrow_back, color: Colors.white.withOpacity(0.6)),
          ),
        ),

        const SizedBox(height: 8),

        Text(
          isSignUp ? 'CREATE ACCOUNT' : 'SIGN IN',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.w900,
            letterSpacing: 3,
          ),
          textAlign: TextAlign.center,
        ),

        const SizedBox(height: 32),

        // Email field
        _buildTextField(
          controller: _emailController,
          hint: 'Email address',
          icon: Icons.email_outlined,
          keyboardType: TextInputType.emailAddress,
        ),

        const SizedBox(height: 12),

        // Password field
        _buildTextField(
          controller: _passwordController,
          hint: 'Password',
          icon: Icons.lock_outlined,
          obscure: _obscurePassword,
          suffix: IconButton(
            icon: Icon(
              _obscurePassword ? Icons.visibility_off : Icons.visibility,
              color: Colors.white.withOpacity(0.3),
              size: 20,
            ),
            onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
          ),
        ),

        if (isSignUp) ...[
          const SizedBox(height: 12),
          _buildTextField(
            controller: _confirmPasswordController,
            hint: 'Confirm password',
            icon: Icons.lock_outlined,
            obscure: true,
          ),
        ],

        const SizedBox(height: 24),

        // Submit button
        SizedBox(
          height: 50,
          child: ElevatedButton(
            onPressed: _loading ? null : (isSignUp ? _emailSignUp : _emailSignIn),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2563eb),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              disabledBackgroundColor: const Color(0xFF2563eb).withOpacity(0.5),
            ),
            child: _loading
                ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            )
                : Text(
              isSignUp ? 'CREATE ACCOUNT' : 'SIGN IN',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5,
              ),
            ),
          ),
        ),

        const SizedBox(height: 16),

        // Toggle sign in / sign up
        TextButton(
          onPressed: () {
            _clearMessages();
            setState(() {
              _mode = isSignUp ? AuthMode.emailSignIn : AuthMode.emailSignUp;
            });
          },
          child: Text(
            isSignUp
                ? 'Already have an account? Sign in'
                : "Don't have an account? Sign up",
            style: TextStyle(
              color: Colors.white.withOpacity(0.5),
              fontSize: 13,
            ),
          ),
        ),

        if (_error != null) ...[
          const SizedBox(height: 12),
          _buildErrorBanner(),
        ],

        if (_successMessage != null) ...[
          const SizedBox(height: 12),
          _buildSuccessBanner(),
        ],
      ],
    );
  }

  // ── Shared Widgets ───────────────────────────────────────────

  Widget _buildAuthButton({
    required String label,
    required IconData icon,
    required Color color,
    VoidCallback? onTap,
    bool loading = false,
  }) {
    return SizedBox(
      height: 52,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: color.withOpacity(0.15),
          foregroundColor: Colors.white,
          side: BorderSide(color: color.withOpacity(0.4)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
        child: loading
            ? SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: color.withOpacity(0.8),
          ),
        )
            : Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 20, color: color),
            const SizedBox(width: 10),
            Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                letterSpacing: 1,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool obscure = false,
    TextInputType keyboardType = TextInputType.text,
    Widget? suffix,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      keyboardType: keyboardType,
      style: const TextStyle(color: Colors.white, fontSize: 15),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.white.withOpacity(0.3)),
        prefixIcon: Icon(icon, color: Colors.white.withOpacity(0.3), size: 20),
        suffixIcon: suffix,
        filled: true,
        fillColor: Colors.white.withOpacity(0.05),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF2563eb)),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }

  Widget _buildErrorBanner() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.red.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: Colors.red.shade300, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              _error!,
              style: TextStyle(color: Colors.red.shade300, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessBanner() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.green.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.green.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.check_circle_outline, color: Colors.green.shade300, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              _successMessage!,
              style: TextStyle(color: Colors.green.shade300, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}