import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'OtpScreen.dart';


class LoginScreenOtp extends StatefulWidget {
  const LoginScreenOtp({super.key});

  @override
  State<LoginScreenOtp> createState() => _LoginScreenOtpState();
}

class _LoginScreenOtpState extends State<LoginScreenOtp> {

  final TextEditingController phoneController = TextEditingController();
  bool loading = false;

  Future<void> sendOtp() async {
    setState(() => loading = true);

    final response = await http.post(
      Uri.parse("http://192.168.1.98:8000/api/send-otp"),
      body: {"phone": phoneController.text},
    );

    setState(() => loading = false);

    if (response.statusCode == 200) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => OtpScreen(phone: phoneController.text),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to send OTP")),
      );
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Login with OTP")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: phoneController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: "Enter Mobile Number",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: loading ? null : sendOtp,
              child: loading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text("Send OTP"),
            ),
          ],
        ),
      ),
    );
  }
}
