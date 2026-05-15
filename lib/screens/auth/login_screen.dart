import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'signup_screen.dart';
import 'forgot_password_screen.dart';
import '../dashboard_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool rememberMe = true;
  bool obscurePassword = true;

  bool isLoginError = false;
  String errorMessage = "";
  String? emailError;

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool get isFormValid =>
      emailController.text.trim().endsWith("@gmail.com") &&
      passwordController.text.trim().isNotEmpty &&
      emailError == null;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> loginValidation() async {
    String email = emailController.text.trim();
    String password = passwordController.text.trim();

    if (email == "admin@gmail.com" && password == "123456") {
      final prefs = await SharedPreferences.getInstance();

      if (rememberMe) {
        await prefs.setBool('rememberMe', true);
        await prefs.setString('savedEmail', email);
        await prefs.setString('savedPassword', password);
      } else {
        await prefs.setBool('rememberMe', false);
        await prefs.remove('savedEmail');
        await prefs.remove('savedPassword');
      }

      setState(() {
        isLoginError = false;
        errorMessage = "";
      });

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const DashboardScreen()),
      );
    } else {
      setState(() {
        isLoginError = true;
        errorMessage = "Incorrect email or password";
      });
    }
  }

  @override
  void initState() {
    super.initState();
    loadRememberedAccount();
  }

  Future<void> loadRememberedAccount() async {
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      rememberMe = prefs.getBool('rememberMe') ?? false;

      if (rememberMe) {
        emailController.text = prefs.getString('savedEmail') ?? '';
        passwordController.text = prefs.getString('savedPassword') ?? '';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEAF4FF),
      body: SafeArea(
        child: Center(
          child: SizedBox(
            width: 390,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 34),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 38),

                  GestureDetector(
                    onTap: () => Navigator.maybePop(context),
                    child: const Padding(
                      padding: EdgeInsets.only(left: 2),
                      child: Icon(
                        Icons.arrow_back_ios_new_rounded,
                        size: 22,
                        color: Color(0xFF4C8DFF),
                      ),
                    ),
                  ),

                  const SizedBox(height: 2),

                  Center(
                    child: Column(
                      children: [
                        Image.asset(
                          'assets/images/logo2.png',
                          height: 76,
                          fit: BoxFit.contain,
                        ),
                        const Text(
                          'Smart drying. Smarter living',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF9AA5B1),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 30),

                  RichText(
                    text: const TextSpan(
                      children: [
                        TextSpan(
                          text: 'Welcome\n',
                          style: TextStyle(
                            fontSize: 25,
                            height: 1.1,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF073E8E),
                          ),
                        ),
                        TextSpan(
                          text: 'Back!',
                          style: TextStyle(
                            fontSize: 25,
                            height: 1.1,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF3F95FF),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 2),

                  const Text(
                    'Login to continue to your account.',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF9AA5B1),
                    ),
                  ),

                  const SizedBox(height: 17),

                  const Text(
                    'Email',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),

                  const SizedBox(height: 4),

                  _InputField(
                    controller: emailController,
                    hint: 'Enter your email',
                    icon: Icons.email_outlined,
                    onChanged: () {
                      final email = emailController.text.trim();

                      setState(() {
                        isLoginError = false;
                        errorMessage = "";

                        if (email.isEmpty || email.endsWith("@gmail.com")) {
                          emailError = null;
                        } else {
                          emailError = "Please enter a valid email";
                        }
                      });
                    },
                  ),

                  if (emailError != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 0, left: 4),
                      child: Row(
                        children: [
                          const SizedBox(width: 5),
                          Text(
                            emailError!,
                            style: TextStyle(
                              color: Colors.red.shade400,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),

                  const SizedBox(height: 3),

                  const Text(
                    'Password',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),

                  const SizedBox(height: 4),

                  _InputField(
                    controller: passwordController,
                    hint: 'Enter your password',
                    icon: Icons.lock_outline_rounded,
                    obscureText: obscurePassword,
                    onChanged: () {
                      setState(() {
                        isLoginError = false;
                        errorMessage = "";
                      });
                    },
                    suffixIcon: GestureDetector(
                      onTap: () {
                        setState(() {
                          obscurePassword = !obscurePassword;
                        });
                      },
                      child: Icon(
                        obscurePassword
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        color: const Color(0xFF3F8CFF),
                        size: 23,
                      ),
                    ),
                  ),

                  if (isLoginError)
                    Padding(
                      padding: const EdgeInsets.only(top: 0, left: 4),
                      child: Row(
                        children: [
                          const SizedBox(width: 5),
                          Text(
                            errorMessage,
                            style: TextStyle(
                              color: Colors.red.shade400,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),

                  const SizedBox(height: 4),

                  Align(
                    alignment: Alignment.centerRight,
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const ForgotPasswordScreen(),
                          ),
                        );
                      },
                      child: const Text(
                        'Forgot Password?',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF3F8CFF),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  Row(
                    children: [
                      Transform.scale(
                        scale: 0.9,
                        child: Switch(
                          value: rememberMe,
                          activeColor: Colors.white,
                          activeTrackColor: const Color(0xFF5C8CFF),
                          inactiveThumbColor: Colors.white,
                          inactiveTrackColor: const Color(0xFFD6E0EF),
                          onChanged: (value) {
                            setState(() {
                              rememberMe = value;
                            });
                          },
                        ),
                      ),

                      const SizedBox(width: 2),

                      const Text(
                        'Remember Me?',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),

                  const Spacer(),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: isFormValid ? loginValidation : null,
                        style: ElevatedButton.styleFrom(
                          elevation: 0,
                          backgroundColor: isFormValid
                              ? const Color(0xFF449BF5)
                              : Colors.grey.shade400,
                          disabledBackgroundColor: Colors.grey.shade400,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        child: const Text(
                          'Log In',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  Center(
                    child: Wrap(
                      children: [
                        const Text(
                          "Don’t have an account yet? ",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                          ),
                        ),

                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const SignUpScreen(),
                              ),
                            );
                          },
                          child: const Text(
                            'Sign Up Here!',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF3F8CFF),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 28),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _InputField extends StatelessWidget {
  final String hint;
  final IconData icon;
  final bool obscureText;
  final Widget? suffixIcon;
  final TextEditingController? controller;
  final VoidCallback? onChanged;

  const _InputField({
    required this.hint,
    required this.icon,
    this.obscureText = false,
    this.suffixIcon,
    this.controller,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 58,
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        onChanged: (_) {
          if (onChanged != null) {
            onChanged!();
          }
        },
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.white,
          hintText: hint,
          hintStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFFB3B8C2),
          ),
          prefixIcon: Icon(icon, color: const Color(0xFF3F8CFF), size: 24),
          suffixIcon: suffixIcon == null
              ? null
              : Padding(
                  padding: const EdgeInsets.only(right: 14),
                  child: suffixIcon,
                ),
          suffixIconConstraints: const BoxConstraints(
            minWidth: 35,
            minHeight: 35,
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 18),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }
}
