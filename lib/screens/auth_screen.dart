import 'package:flutter/material.dart';
import '../services/services.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final AuthService _authService = AuthService();
  final TextEditingController _usernameController = TextEditingController();
  bool _isLoading = false;
  bool _showUsernameInput = false;
  String? _userEmail;

  @override
  void dispose() {
    _usernameController.dispose();
    super.dispose();
  }

  Future<void> _signInWithGoogle() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final mockUser = await _authService.signInWithGoogle();
      
      if (mockUser != null) {
        // Check if user already has a username
        final userData = await _authService.getUserData();
        
        if (userData != null && userData['username'] == null) {
          // Show username input
          setState(() {
            _showUsernameInput = true;
            _userEmail = mockUser.email;
            _isLoading = false;
          });
        } else {
          // User already has username, navigate to home
          if (mounted) {
            Navigator.of(context).pushReplacementNamed('/');
          }
        }
      } else {
        setState(() {
          _isLoading = false;
        });
        _showErrorSnackBar('Sign in was cancelled or failed');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showErrorSnackBar('Error signing in: $e');
    }
  }

  Future<void> _setUsername() async {
    final username = _usernameController.text.trim();
    
    if (username.isEmpty) {
      _showErrorSnackBar('Please enter a username');
      return;
    }

    if (username.length < 3) {
      _showErrorSnackBar('Username must be at least 3 characters');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final success = await _authService.updateUsername(username);
      
      if (success) {
        if (mounted) {
          Navigator.of(context).pushReplacementNamed('/');
        }
      } else {
        _showErrorSnackBar('Failed to set username');
      }
    } catch (e) {
      _showErrorSnackBar('Error setting username: $e');
    }

    setState(() {
      _isLoading = false;
    });
  }

  void _showErrorSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // App Logo/Title
              const Icon(
                Icons.shopping_cart,
                size: 80,
                color: Color(0xFF232F3E),
              ),
              const SizedBox(height: 24),
              const Text(
                'Mini Shopping App',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF232F3E),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Sign in to start shopping',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 48),

              if (!_showUsernameInput) ...[
                // Google Sign In Button
                ElevatedButton.icon(
                  onPressed: _isLoading ? null : _signInWithGoogle,
                  icon: _isLoading 
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Icon(Icons.login),
                  label: Text(_isLoading ? 'Signing in...' : 'Sign in with Google'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    textStyle: const TextStyle(fontSize: 16),
                  ),
                ),
              ] else ...[
                // Username Input Section
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Welcome!',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Signed in as: $_userEmail',
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          'Choose your username:',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _usernameController,
                          decoration: const InputDecoration(
                            hintText: 'Enter username',
                            prefixIcon: Icon(Icons.person),
                          ),
                          textInputAction: TextInputAction.done,
                          onSubmitted: (_) => _setUsername(),
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _setUsername,
                            child: _isLoading
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                    ),
                                  )
                                : const Text('Continue'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],

              const SizedBox(height: 24),
              const Text(
                'By signing in, you agree to our terms of service',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}