import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_small_shop/screens/HomeScreen.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
// import 'package:blue_thermal_printer/blue_thermal_printer.dart';
import '../util/Constants.dart';

class OrderSuccessScreen extends StatefulWidget {
  final String title;
  final String order_id;

  const OrderSuccessScreen({super.key, required this.title, required this.order_id});

  @override
  State<OrderSuccessScreen> createState() => _OrderSuccessScreenState();
}

class _OrderSuccessScreenState extends State<OrderSuccessScreen> {
  // BlueThermalPrinter bluetooth = BlueThermalPrinter.instance;
  // List<BluetoothDevice> devices = [];
  // BluetoothDevice? selectedDevice;

  @override
  void initState() {
    super.initState();
    // _getDevices();
  }

  // Future<void> _getDevices() async {
  //   List<BluetoothDevice> availableDevices = await bluetooth.getBondedDevices();
  //   setState(() {
  //     devices = availableDevices;
  //   });
  // }
  //
  // Future<void> _connectToDevice(BluetoothDevice device) async {
  //   if (!(await bluetooth.isConnected)!) {
  //     await bluetooth.connect(device);
  //   }
  //   setState(() {
  //     selectedDevice = device;
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle_outline, size: 100, color: Colors.green),
            SizedBox(height: 20),
            Text(
              "Order #${widget.order_id}",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black),
            ),
            SizedBox(height: 10),
            Text(
              "Thank you for your purchase! Your order will be processed soon.",
              style: TextStyle(fontSize: 16, color: Colors.black54),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 30),
            // DropdownButton<BluetoothDevice>(
            //   hint: Text("Select Printer"),
            //   value: selectedDevice,
            //   items: devices.map((device) {
            //     return DropdownMenuItem(
            //       value: device,
            //       child: Text(device.name ?? "Unknown"),
            //     );
            //   }).toList(),
            //   onChanged: (device) {
            //     if (device != null) _connectToDevice(device);
            //   },
            // ),
            SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                _showReceiptBottomSheet(context);
              },
              child: Text("View Receipt"),
            ),
            SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                // _printReceipt();
              },
              child: Text("Print Receipt"),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (context) => HomeScreen(title: 'Home')));
              },
              child: Text("Go To Home"),
            ),
          ],
        ),
      ),
    );
  }

  void _showReceiptBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Receipt", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black)),
              Text("Receipt", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black)),
              SizedBox(height: 10),
              Text("Order #: ${widget.order_id}", style: TextStyle(fontSize: 18, color: Colors.black)),
              SizedBox(height: 10),
              ElevatedButton(
                onPressed: () {
                  // _printReceipt();
                  Navigator.pop(context);
                },
                child: Text("Print Receipt"),
              ),
            ],
          ),
        );
      },
    );
  }

  // Future<void> _printReceipt() async {
  //   if (!(await bluetooth.isConnected)!) {
  //     ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Printer not connected!')));
  //     return;
  //   }
  //
  //   try {
  //     final response = await http.get(Uri.parse("${Constants.BASE_URL}${Constants.PRINT_RECEIPT_ROUTE}${widget.order_id}"));
  //
  //     if (response.statusCode == 200) {
  //       var responseData = json.decode(response.body);
  //       if (responseData == null || responseData['data'] == null) {
  //         throw Exception('Invalid API response format');
  //       }
  //
  //       var orderData = responseData['data'];
  //       print(orderData);
  //       String receiptText = _formatReceipt(orderData);
  //
  //       bluetooth.printNewLine();
  //       bluetooth.printCustom("ORDER RECEIPT", 2, 1);
  //       bluetooth.printNewLine();
  //       bluetooth.printCustom(receiptText, 1, 0);
  //       bluetooth.printNewLine();
  //       bluetooth.printNewLine();
  //       bluetooth.paperCut();
  //
  //       ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Printing Receipt')));
  //     } else {
  //       throw Exception('Failed to fetch receipt: ${response.statusCode}');
  //     }
  //   } catch (e) {
  //     print('Error: $e');
  //     ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
  //   }
  // }

  String _formatReceipt(Map<String, dynamic> data) {
    StringBuffer receipt = StringBuffer();
    receipt.writeln("Order ID: ${data['order_id'] ?? 'N/A'}");
    receipt.writeln("--------------------------------");
    if (data.containsKey('order_id') && data['order_id'] != null) {
      receipt.writeln("Customer: ${data['customer_name'] ?? 'Guest'}");
    }
    receipt.writeln("--------------------------------");
    if (data['order_id'] != null && data['items'] != null) {
      List items = data['items'];
      for (var item in items) {
        // Decode product name and handle potential issues
        String productName = item['product_name'] ?? 'Unknown';
        receipt.writeln("$productName - ${item['quantity']} x ₹${item['unit_price']}");
      }
    } else {
      receipt.writeln("No items found.");
    }
    receipt.writeln("--------------------------------");
    receipt.writeln("Total: ₹${data['total_amount'] ?? '0.00'}");
    return receipt.toString();
  }
}