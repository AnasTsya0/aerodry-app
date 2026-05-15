import 'package:flutter/material.dart';
import 'package:aerodry_app/screens/dashboard_screen.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  bool obscurePassword = true;
  bool obscureConfirmPassword = true;

  final fullNameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  bool isValid = false;
  String? emailError;
  String? passwordError;

  void validateForm() {
    final fullName = fullNameController.text.trim();
    final email = emailController.text.trim();
    final password = passwordController.text;
    final confirmPassword = confirmPasswordController.text;

    final emailValid = email.endsWith('@gmail.com');
    final passwordMatch = password.isNotEmpty && password == confirmPassword;

    setState(() {
      emailError = email.isEmpty || emailValid
          ? null
          : 'Please enter a valid Gmail';

      passwordError = confirmPassword.isEmpty || passwordMatch
          ? null
          : 'Passwords do not match';

      isValid = fullName.isNotEmpty && emailValid && passwordMatch;
    });
  }

  void signUpSuccess() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const DashboardScreen()),
    );
  }

  @override
  void dispose() {
    fullNameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
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

                  const SizedBox(height: 35),

                  RichText(
                    text: const TextSpan(
                      children: [
                        TextSpan(
                          text: 'Create\n',
                          style: TextStyle(
                            fontSize: 25,
                            height: 1.1,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF073E8E),
                          ),
                        ),
                        TextSpan(
                          text: 'Your Account',
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
                    'Sign up to connect your smart\nclothes drying system.',
                    style: TextStyle(
                      fontSize: 14,
                      height: 1.25,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF9AA5B1),
                    ),
                  ),

                  const SizedBox(height: 30),

                  const Text('Full Name', style: _labelStyle),
                  const SizedBox(height: 4),
                  _InputField(
                    controller: fullNameController,
                    hint: 'Enter your full name',
                    icon: Icons.person_outline_rounded,
                    onChanged: (_) => validateForm(),
                  ),

                  const SizedBox(height: 7),

                  const Text('Email', style: _labelStyle),
                  const SizedBox(height: 4),
                  _InputField(
                    controller: emailController,
                    hint: 'Enter your email',
                    icon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                    onChanged: (_) => validateForm(),
                  ),

                  if (emailError != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 0, left: 4),
                      child: Text(
                        emailError!,
                        style: const TextStyle(
                          color: Colors.red,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),

                  const SizedBox(height: 7),

                  const Text('Password', style: _labelStyle),
                  const SizedBox(height: 4),
                  _InputField(
                    controller: passwordController,
                    hint: 'Create a password',
                    icon: Icons.lock_outline_rounded,
                    obscureText: obscurePassword,
                    onChanged: (_) => validateForm(),
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

                  const SizedBox(height: 7),

                  const Text('Confirm Password', style: _labelStyle),
                  const SizedBox(height: 4),
                  _InputField(
                    controller: confirmPasswordController,
                    hint: 'Confirm a password',
                    icon: Icons.lock_outline_rounded,
                    obscureText: obscureConfirmPassword,
                    onChanged: (_) => validateForm(),
                    suffixIcon: GestureDetector(
                      onTap: () {
                        setState(() {
                          obscureConfirmPassword = !obscureConfirmPassword;
                        });
                      },
                      child: Icon(
                        obscureConfirmPassword
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        color: const Color(0xFF3F8CFF),
                        size: 23,
                      ),
                    ),
                  ),

                  if (passwordError != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 0, left: 4),
                      child: Text(
                        passwordError!,
                        style: const TextStyle(
                          color: Colors.red,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),

                  const Spacer(),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: isValid ? signUpSuccess : null,
                        style: ElevatedButton.styleFrom(
                          elevation: 0,
                          backgroundColor: isValid
                              ? const Color(0xFF449BF5)
                              : const Color(0xFFB8C7DA),
                          disabledBackgroundColor: const Color(0xFFB8C7DA),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        child: const Text(
                          'Sign Up',
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
                          'Already have an account? ',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                          ),
                        ),
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: const Text(
                            'Login here!',
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

const TextStyle _labelStyle = TextStyle(
  fontSize: 14,
  fontWeight: FontWeight.w600,
  color: Colors.black,
);

class _InputField extends StatelessWidget {
  final String hint;
  final IconData icon;
  final bool obscureText;
  final Widget? suffixIcon;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final TextInputType? keyboardType;

  const _InputField({
    required this.hint,
    required this.icon,
    this.obscureText = false,
    this.suffixIcon,
    this.controller,
    this.onChanged,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 58,
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        keyboardType: keyboardType,
        obscureText: obscureText,
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
