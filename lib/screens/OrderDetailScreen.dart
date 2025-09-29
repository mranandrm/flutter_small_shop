import 'package:flutter/material.dart';
import 'package:blue_thermal_printer/blue_thermal_printer.dart';
import '../../models/Order.dart';
import '../../services/PrinterService.dart';

class OrderDetailScreen extends StatefulWidget {
  final Order order;

  const OrderDetailScreen({Key? key, required this.order}) : super(key: key);

  @override
  _OrderDetailScreenState createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  final PrinterService printerService = PrinterService();
  List<BluetoothDevice> devices = [];
  BluetoothDevice? selectedDevice;

  @override
  void initState() {
    super.initState();
    _getDevices();
  }

  Future<void> _getDevices() async {
    List<BluetoothDevice> availableDevices = await printerService.getDevices();
    setState(() {
      devices = availableDevices;
    });
  }

  Future<void> _connectToDevice(BluetoothDevice device) async {
    await printerService.connect(device);
    setState(() {
      selectedDevice = device;
    });
  }

  Future<void> _printReceipt() async {
    if (selectedDevice == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('No printer selected!')));
      return;
    }

    try {
      await printerService.printReceipt(context,widget.order.id);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Printing Receipt')));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  Future<void> _showPrinterSelectionDialog() async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Select Printer"),
          content: devices.isEmpty
              ? Text("No available printers found.")
              : Column(
            mainAxisSize: MainAxisSize.min,
            children: devices.map((device) {
              return ListTile(
                title: Text(device.name ?? "Unknown"),
                onTap: () async {
                  await _connectToDevice(device);
                  Navigator.pop(context);
                  _printReceipt();
                },
              );
            }).toList(),
          ),
          actions: [
            TextButton(
              child: Text("Cancel"),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Order #${widget.order.id}"),
        actions: [
          IconButton(
            icon: Icon(Icons.print),
            onPressed: (){
              _showPrinterSelectionDialog();
            },
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Customer Name: ${widget.order.customerName}",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            // Text("Timing: ${widget.order.timings}"),
            SizedBox(height: 8),
            Text("Total Amount: ₹${widget.order.totalAmount}"),
            SizedBox(height: 8),
            Text("Created At: ${widget.order.formattedCreatedAt}"),
            Text("Updated At: ${widget.order.formattedUpdatedAt}"),
            Text("Order Items:", style: TextStyle(fontSize: 16)),
            Expanded(
              child: ListView.builder(
                itemCount: widget.order.orderItems.length,
                itemBuilder: (context, index) {
                  final item = widget.order.orderItems[index];
                  return Card(
                    margin: EdgeInsets.symmetric(vertical: 8),
                    child: ListTile(
                      title: Text(item.productName),
                      subtitle: Text(
                        "Qty: ${item.qty} | Price: ${item.unitPrice} | Subtotal: ${item.subTotal}",
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}