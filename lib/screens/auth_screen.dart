
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../models/models.dart';
import '../data/database_service.dart';
import 'client/client_main_layout.dart';
import 'technician/setup_screen.dart';
import 'technician/dashboard.dart';

class AuthScreen extends StatefulWidget {
  final UserRole role;
  const AuthScreen({super.key, required this.role});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _loginFormKey = GlobalKey<FormState>();
  final _signupFormKey = GlobalKey<FormState>();

  // Controllers
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'البريد الإلكتروني مطلوب';
    }
    if (!value.endsWith('@gmail.com')) {
      return 'لازم البريد يكون @gmail.com';
    }
    return null;
  }

  void _submitLogin() async {
    if (!_loginFormKey.currentState!.validate()) return;
    
    setState(() => _isLoading = true);
    
    final success = await Provider.of<DatabaseService>(context, listen: false)
        .login(_emailController.text, _passwordController.text);
        
    setState(() => _isLoading = false);

    if (success && mounted) {
      _navigateHome();
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('بريد أو كلمة مرور خطأ')),
      );
    }
  }

  void _submitSignup() async {
    if (!_signupFormKey.currentState!.validate()) return;
    
    setState(() => _isLoading = true);
    
    try {
      await Provider.of<DatabaseService>(context, listen: false).signup(
        _emailController.text, 
        _passwordController.text,
        widget.role,
        _nameController.text
      );
      if (mounted) _navigateHome();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _navigateHome() async {
    if (widget.role == UserRole.client) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const ClientMainLayout()),
        (route) => false,
      );
    } else {
      // For technician: check if profile exists
      final dbService = Provider.of<DatabaseService>(context, listen: false);
      
      // Wait a bit for auth to complete
      await Future.delayed(const Duration(milliseconds: 500));
      
      final String? userId = dbService.getAuthUserId();
      
      debugPrint('🔍 Checking technician profile for user: $userId');
      
      if (userId == null) {
        debugPrint('⚠️ No user ID found, going to setup');
        if (!mounted) return;
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const TechnicianSetupScreen()),
          (route) => false,
        );
        return;
      }

      // Check if technician profile exists in Firestore
      final profileExists = await dbService.checkTechnicianProfileExists(userId);
      
      debugPrint('📋 Profile exists: $profileExists');

      if (mounted) {
        if (profileExists) {
          debugPrint('✅ Going to Dashboard');
          // Profile exists, go to dashboard
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const TechnicianDashboard()),
            (route) => false,
          );
        } else {
          debugPrint('⚙️ Going to Setup');
          // Profile doesn't exist, go to setup
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const TechnicianSetupScreen()),
            (route) => false,
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.role == UserRole.client ? 'دخول عميل' : 'دخول صنايعي'),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelStyle: GoogleFonts.cairo(fontWeight: FontWeight.bold),
          tabs: const [
            Tab(text: 'تسجيل دخول'),
            Tab(text: 'إنشاء حساب'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildLoginForm(),
          _buildSignupForm(),
        ],
      ),
    );
  }

  Widget _buildLoginForm() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Form(
        key: _loginFormKey,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextFormField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'البريد الإلكتروني (Gmail only)'),
              validator: _validateEmail,
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _passwordController,
              decoration: const InputDecoration(labelText: 'كلمة المرور'),
              obscureText: true,
              validator: (v) => v!.length < 6 ? 'كلمة المرور قصيرة' : null,
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _submitLogin,
                child: _isLoading 
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('دخول'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSignupForm() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: SingleChildScrollView(
        child: Form(
          key: _signupFormKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 32),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'الاسم بالكامل'),
                validator: (v) => v!.isEmpty ? 'الاسم مطلوب' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'البريد الإلكتروني (Gmail only)'),
                validator: _validateEmail,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(labelText: 'كلمة المرور'),
                obscureText: true,
                validator: (v) => v!.length < 6 ? 'كلمة المرور قصيرة' : null,
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submitSignup,
                  child: _isLoading 
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('إنشاء حساب'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
