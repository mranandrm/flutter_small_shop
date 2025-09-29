import 'package:blue_thermal_printer/blue_thermal_printer.dart';



import 'package:flutter/material.dart';





import '../../services/PrinterService.dart';





class ReciptPrinter extends StatefulWidget {


  const ReciptPrinter({super.key});





  @override


  State<ReciptPrinter> createState() => _ReciptPrinterState();


}





class _ReciptPrinterState extends State<ReciptPrinter> {


  PrinterService printerService = PrinterService();


  List<BluetoothDevice> devices = [];


  BluetoothDevice? selectedDevice;





  @override


  void initState() {


    super.initState();


    _getDevices();


  }





  Future<void> _getDevices() async {


    List<BluetoothDevice> availableDevices = await printerService.getDevices();


    print(availableDevices.toString());


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





  Future<void> _print() async {


    _getDevices();


    if (selectedDevice != null) {


      await printerService.printText("Hello, Thermal Printer!");


    }


  }





  @override


  Widget build(BuildContext context) {


    return MaterialApp(


      home: Scaffold(


        appBar: AppBar(title: Text("Thermal Printer")),


        body: Column(


          children: [


            DropdownButton<BluetoothDevice>(


              hint: Text("Select Printer"),


              value: selectedDevice,


              items: devices.map((device) {


                return DropdownMenuItem(


                  value: device,


                  child: Text(device.name ?? "Unknown"),


                );


              }).toList(),


              onChanged: (device) {


                print(device?.name);


                if (device != null) _connectToDevice(device);


              },


            ),


            ElevatedButton(


              onPressed: _print,


              child: Text("Print Receipt"),


            ),


          ],


        ),


      ),


    );


  }


}