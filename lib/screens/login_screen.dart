import 'package:flutter/material.dart';
import '../widgets/auth_widgets.dart';

class LoginScreen extends StatelessWidget {
  final String backgroundImage;

  const LoginScreen({
    this.backgroundImage = "assets/images/arr2.jpg",
  });

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    bool isDesktop = width > 800;

    return Scaffold(
      body: isDesktop ? _desktop(context) : _mobile(context),
    );
  }

  /// 🌐 WEB
  Widget _desktop(BuildContext context) {
  return Stack(
    children: [

      /// IMAGE FULL
      Positioned.fill(
        child: Image.asset(
          backgroundImage,
          fit: BoxFit.cover,
        ),
      ),

      /// OVERLAY
      Positioned.fill(
        child: Container(
          color: Colors.black.withOpacity(0.4),
        ),
      ),

      /// FORM CENTER
      Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 450), // 🔥 IMPORTANT
          child: loginForm(context, isMobile: true),
        ),
      ),
    ],
  );
}

  /// 📱 MOBILE
  Widget _mobile(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: Image.asset(backgroundImage, fit: BoxFit.cover),
        ),
        Positioned.fill(
          child: Container(color: Colors.black.withOpacity(0.6)),
        ),
        Center(
          child: Padding(
            padding: EdgeInsets.all(20),
            child: loginForm(context, isMobile: true),
          ),
        ),
      ],
    );
  }

  /// 🔥 FORM
  Widget loginForm(BuildContext context, {bool isMobile = false}) {
    Widget content = _formContent(context, isMobile);

    if (isMobile) {
      return glassContainer(child: content);
    }

    return Container(
      width: 400,
      padding: EdgeInsets.all(30),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
          )
        ],
      ),
      child: content,
    );
  }

  Widget _formContent(BuildContext context, bool isMobile) {
    Color textColor = isMobile ? Colors.white : Colors.black;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Login",
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
        SizedBox(height: 20),
        TextField(
          style: TextStyle(color: textColor),
          decoration: inputDecoration("Email", Icons.email, isMobile),
        ),
        SizedBox(height: 15),
        TextField(
          obscureText: true,
          style: TextStyle(color: textColor),
          decoration: inputDecoration("Password", Icons.lock, isMobile),
        ),
        SizedBox(height: 10),
        Align(
          alignment: Alignment.centerRight,
          child: Text("Forgot password?", style: TextStyle(color: Colors.grey)),
        ),
        SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.amber,
              padding: EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () {
              Navigator.pushReplacementNamed(context, '/');
            },
            child: Text("Login"),
          ),
        ),
        SizedBox(height: 15),
        Center(
          child: TextButton(
            onPressed: () {
              Navigator.pushNamed(context, '/signup');
            },
            child: Text(
              "Create account",
              style: TextStyle(color: textColor),
            ),
          ),
        ),
      ],
    );
  }

  InputDecoration inputDecoration(String hint, IconData icon, bool isMobile) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: Icon(icon),
      filled: true,
      fillColor: isMobile ? Colors.white.withOpacity(0.2) : Color(0xFFF3F4F6),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
    );
  }
}
