import 'package:festeasy_app/features/auth/view/register_page.dart';
import 'package:festeasy_app/features/dashboard/view/client_dashboard.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final SupabaseClient supabase = Supabase.instance.client;
  bool _isLoading = false;

  Future<void> _signIn() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final res = await supabase.auth.signInWithPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      final user = res.user;

      if (user != null) {
        if (mounted) {
          await Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute<dynamic>(builder: (context) => const ClientDashboard()),
            (route) => false,
          );
        }
      }
    } on AuthException catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error.message), backgroundColor: Colors.red,));
      }
    } on Exception catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Ocurrió un error inesperado'), backgroundColor: Colors.red,));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () {},
        ),
        title: const Text(
          'Iniciar sesión',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Image.asset(
                  'assets/logoFestEasy.png',
                  height: 150, // Adjust height as needed
                ),
              ),
              const SizedBox(height: 40),
              const Text('Correo electrónico o nombre de usuario', 
                  style: TextStyle(fontWeight: FontWeight.w500)),
              const SizedBox(height: 8),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  hintText: 'Ingresa tu correo o usuario',
                ),
                keyboardType: TextInputType.emailAddress,
              ),

              const SizedBox(height: 24),

              const Text('Contraseña', 
                  style: TextStyle(fontWeight: FontWeight.w500)),
              const SizedBox(height: 8),
              TextFormField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  hintText: 'Ingresa tu contraseña',
                ),
              ),

              const SizedBox(height: 24), // Added spacing here

              ElevatedButton(
                onPressed: _isLoading ? null : _signIn,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                ),
                child: _isLoading 
                    ? const SizedBox(
                        height: 20, width: 20, 
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                      )
                    : const Text('Iniciar sesión'),
              ),

              const SizedBox(height: 40),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('¿No tienes una cuenta? ', style: TextStyle(color: Colors.grey)),
                  GestureDetector(
                    onTap: () {
                       Navigator.push(
                        context,
                        MaterialPageRoute<void>(builder: (context) => const RegisterPage()),
                      );
                    },
                    child: const Text(
                      'Regístrate',
                      style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
