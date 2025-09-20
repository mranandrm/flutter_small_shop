import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:sms_autofill/sms_autofill.dart';

class OtpScreen extends StatefulWidget {
  final String phone;
  const OtpScreen({super.key, required this.phone});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> with CodeAutoFill {
  String otpCode = "";
  bool loading = false;

  @override
  void codeUpdated() {
    setState(() => otpCode = code ?? "");
    if (otpCode.length == 6) verifyOtp(otpCode);
  }

  @override
  void initState() {
    super.initState();
    listenForCode();
  }

  @override
  void dispose() {
    cancel();
    super.dispose();
  }

  Future<void> verifyOtp(String otp) async {
    setState(() => loading = true);

    final response = await http.post(
      Uri.parse("http://192.168.1.98:8000/api/verify-otp"),
      body: {"phone": widget.phone, "otp": otp},
    );

    setState(() => loading = false);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Login Successful")),
      );
      // Save token (data['token']) in local storage for future API calls
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Invalid or expired OTP")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Verify OTP")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Enter the 6-digit OTP sent to ${widget.phone}"),
            const SizedBox(height: 20),
            PinFieldAutoFill(
              codeLength: 6,
              onCodeChanged: (val) {
                if (val != null && val.length == 6) {
                  verifyOtp(val);
                }
              },
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: otpCode.length == 6 && !loading
                  ? () => verifyOtp(otpCode)
                  : null,
              child: loading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text("Verify OTP"),
            ),
          ],
        ),
      ),
    );
  }
}
