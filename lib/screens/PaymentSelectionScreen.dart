import 'package:flutter/material.dart';
import 'package:flutter_small_shop/screens/payment/PaymentScreen.dart';

import '../models/Cart.dart';
import 'OrderConfirmScreen.dart';

class PaymentSelectionScreen extends StatefulWidget {
  final List<Cart> products;

  const PaymentSelectionScreen({super.key, required this.products});

  @override
  State<PaymentSelectionScreen> createState() => _PaymentSelectionScreenState();
}

class _PaymentSelectionScreenState extends State<PaymentSelectionScreen> {
  String? _selectedPaymentMethod = 'CASH';

  @override
  void initState() {
    super.initState();
  }

  double get totalPrice {
    double total = 0.0;
    for (var item in widget.products) {
      total += item.price * item.qty;
    }
    return total;
  }


  void _onPaymentMethodSelected(String? method) {
    setState(() {
      _selectedPaymentMethod = method;
    });

    if (_selectedPaymentMethod == 'UPI' ||  _selectedPaymentMethod == 'CARD')
    {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PaymentScreen(
            products: widget.products,
            totalPrice: totalPrice
          )
        ),
      );
    }
  }

  Widget _buildPaymentMethodCard({
    required String value,
    required IconData icon,
    required String label,
  }) {
    final bool isSelected = _selectedPaymentMethod == value;
    return GestureDetector(
      onTap: () => _onPaymentMethodSelected(value),
      child: Card(
        elevation: 4.0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        color: Colors.white,
        child: ListTile(
          leading: Icon(
            icon,
            size: 32,
            color: isSelected ? Colors.pink : Colors.black,
          ),
          title: Text(
            label,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isSelected ? Colors.pink : Colors.black,
            ),
          ),
          trailing: Radio<String>(
            value: value,
            groupValue: _selectedPaymentMethod,
            onChanged: _onPaymentMethodSelected,
            activeColor: Colors.pink,
          ),
        ),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Payment Method'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Choose your payment method:',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            _buildPaymentMethodCard(
              value: 'CASH',
              icon: Icons.attach_money,
              label: 'Cash',
            ),
            _buildPaymentMethodCard(
              value: 'UPI',
              icon: Icons.qr_code_scanner,
              label: 'UPI',
            ),
            _buildPaymentMethodCard(
              value: 'GPAY',
              icon: Icons.send_to_mobile,
              label: 'GPAY',
            ),
          ],
        ),
      ),
      bottomSheet: Container(
        height: 80.0,
        color: Colors.orange,
        child: Center(
          child: TextButton(
            onPressed: _selectedPaymentMethod == null
                ? null
                : () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => OrderConfirmScreen(
                    title: 'Order Confirmation',
                    products: widget.products,
                    paymentMethod: _selectedPaymentMethod!,
                  ),
                ),
              );
            },
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all<Color>(
                _selectedPaymentMethod == null ? Colors.grey : Colors.pink,
              ),
              padding: MaterialStateProperty.all<EdgeInsets>(
                const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
              ),
              foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
              shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
            ),
            child: const Text(
              'CONTINUE',
              style: TextStyle(
                fontSize: 16.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }
}