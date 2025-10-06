import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

import '../../models/Cart.dart';

class PaymentScreen extends StatefulWidget {

  final List<Cart> products;
  final double totalPrice;

  const PaymentScreen({
    super.key,
    required this.products,
    required this.totalPrice,
  });

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {

  late Razorpay _razorpay;

  @override
  void initState(){

    super.initState();

    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS,_handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR,_handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET,_handleExternalWallet);
  }

  void _openChekout() {

    var options = {

      'key' : dotenv.env['RAZORPAY_KEY'],
       'amount' : (this.widget.totalPrice * 100).toInt(), // ✅ amount in paise
       'name': 'Small Shop',
      'description' : 'Test Payment',
      'perfill': {},

    };

    try{
       _razorpay.open(options);
    }
    catch (e) {
        debugPrint('Error: $e');
    }
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response){
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Success: ${response.paymentId}"),)
    );
  }

  void _handlePaymentError(PaymentFailureResponse response){
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Success: ${response.message}"),)
    );
  }

  void _handleExternalWallet(ExternalWalletResponse response){
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Success: ${response.walletName}"),)
    );
  }

  @override
  void dispose() {
    _razorpay.clear(); // Clean up
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      
      appBar:  AppBar(title: Text('Razorpay Payment'),),
      body: Center(
        child: ElevatedButton(
            onPressed: _openChekout, 
            child: Text('Pay ₹${this.widget.totalPrice}')),
      ),
    );
  }
}
