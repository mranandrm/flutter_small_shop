import 'package:blue_thermal_printer/blue_thermal_printer.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/material.dart';
import '../util/Constants.dart';


class PrinterService {
  final BlueThermalPrinter bluetooth = BlueThermalPrinter.instance;

  Future<List<BluetoothDevice>> getDevices() async {
    return await bluetooth.getBondedDevices();
  }

  Future<void> connect(BluetoothDevice device) async {
    if (!(await bluetooth.isConnected)!) {
      await bluetooth.connect(device);
    }
  }

  Future<void> disconnect() async {
    if ((await bluetooth.isConnected)!) {
      await bluetooth.disconnect();
    }
  }

  Future<void> printText(String text) async {
    if ((await bluetooth.isConnected)!) {
      bluetooth.printNewLine();
      bluetooth.printCustom(text, 1, 1); // (Text, Size, Alignment)
      bluetooth.printNewLine();
      bluetooth.paperCut();
    }
  }

  Future<void> printReceipt(BuildContext context, int orderId) async {
    if (!(await bluetooth.isConnected)!) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Printer not connected!')));
      return;
    }

    try {
      // printText("working");
      final response = await http.get(Uri.parse("${Constants.BASE_URL}${Constants.PRINT_RECEIPT_ROUTE}$orderId"));

      print(Uri.parse("${Constants.BASE_URL}${Constants.PRINT_RECEIPT_ROUTE}$orderId"));

      if (response.statusCode == 200) {
        var responseData = json.decode(response.body);
        if (responseData == null || responseData['data'] == null) {
          throw Exception('Invalid API response format');
        }

        var orderData = responseData['data'];
        print(orderData);
        print("API Response: ${response.body}");
        String receiptText = _formatReceipt(orderData);

        bluetooth.printNewLine();
        bluetooth.printCustom("ORDER RECEIPT", 2, 1);
        bluetooth.printNewLine();
        bluetooth.printCustom(receiptText, 1, 0);
        bluetooth.printNewLine();
        bluetooth.printNewLine();
        bluetooth.paperCut();

        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Printing Receipt')));
      } else {
        throw Exception('Failed to fetch receipt: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  String _formatReceipt(Map<String, dynamic> data) {
    StringBuffer receipt = StringBuffer();
    receipt.writeln(data['title'] ?? "Shop Name");
    receipt.writeln(data['moto'] ?? "");
    receipt.writeln("--------------------------------");
    receipt.writeln("Order ID: ${data['order_id'] ?? 'N/A'}");
    receipt.writeln("Customer: ${data['customer_name'] ?? 'Guest'}");
    receipt.writeln("Date: ${data['order_date'] ?? ''}");
    receipt.writeln("--------------------------------");

    if (data['items'] != null) {
      List items = data['items'];
      for (var item in items) {
        String productName = item['product_name'] ?? 'Unknown';
        int qty = item['quantity'] ?? 0;
        String price = item['unit_price'] ?? '0.00';
        receipt.writeln("$productName - $qty x $price");
      }
    } else {
      receipt.writeln("No items found.");
    }

    receipt.writeln("--------------------------------");
    receipt.writeln("Total: ${data['total_amount'] ?? '0.00'}");
    receipt.writeln("--------------------------------");
    receipt.writeln("Thank you! Visit Again ❤️");
    return receipt.toString();
  }


}