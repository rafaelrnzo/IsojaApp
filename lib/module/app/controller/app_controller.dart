import 'dart:math';

import 'package:app_isoja/module/app/widget/BottomSheet.dart';
import 'package:flutter/material.dart';
import 'package:app_isoja/state_util.dart';
import '../view/app_view.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'dart:async';
import 'dart:convert';
import 'package:flutter/services.dart';

class AppController extends State<AppView> implements MvcController {
  static late AppController instance;
  late AppView view;

  @override
  void initState() {
    instance = this;
    super.initState();

    FlutterBluetoothSerial.instance.state.then((state) {
      setState(() {
        bluetoothState = state;
      });
    });

    deviceState = 0; // neutral

    // If the bluetooth of the device is not enabled,
    // then request permission to turn on bluetooth
    // as the app starts up
    enableBluetooth();

    // Listen for further state changes
    FlutterBluetoothSerial.instance
        .onStateChanged()
        .listen((BluetoothState state) {
      setState(() {
        bluetoothState = state;
        if (bluetoothState == BluetoothState.STATE_OFF) {
          isButtonUnavailable = true;
        }
        getPairedDevices();
      });
    });
  }

  @override
  void dispose() {
    // Avoid memory leak and disconnect
    if (isConnected!) {
      isDisconnecting = true;
      connection?.dispose();
      // connection = null;
    }

    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.build(context, this);
  BluetoothState bluetoothState = BluetoothState.UNKNOWN;
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  final FlutterBluetoothSerial bluetooth = FlutterBluetoothSerial.instance;
  BluetoothConnection? connection;
  late int deviceState;
  int indexNum = 0;
  bool isDisconnecting = false;

  //*Color//
  final Color bgColor = Color.fromRGBO(199, 204, 219, 1);
  final Color container = Color.fromRGBO(225, 229, 238, 1);
  final Color container2 = Color.fromRGBO(42, 50, 75, 1);
  final Color text = Color.fromRGBO(42, 50, 75, 1);
  final Color subText = Color.fromRGBO(0, 0, 0, 0.56);
  final Color sheet = Color.fromRGBO(119, 204, 229, 1);

  Future<void> enableBluetooth() async {
    // Retrieving the current Bluetooth state
    bluetoothState = await FlutterBluetoothSerial.instance.state;

    // If the bluetooth is off, then turn it on first
    // and then retrieve the devices that are paired.
    if (bluetoothState == BluetoothState.STATE_OFF) {
      await FlutterBluetoothSerial.instance.requestEnable();
      await getPairedDevices();
      // return true;
    } else {
      await getPairedDevices();
    }
    // return false;
  }

  // To track whether the device is still connected to Bluetooth
  // bool? get isConnected => connection?.isConnected;
  bool? get isConnected => connection != null && connection!.isConnected;

  // Define some variables, which will be required later
  List<BluetoothDevice> devicesList = [];
  BluetoothDevice? device;
  bool connected = false;
  bool isVisible = true;
  bool isButtonUnavailable = false;

  Future<void> getPairedDevices() async {
    List<BluetoothDevice> devices = [];

    // To get the list of paired devices
    try {
      devices = await bluetooth.getBondedDevices();
    } on PlatformException {
      debugPrint("Error");
    }

    // It is an error to call [setState] unless [mounted] is true.
    if (!mounted) {
      return;
    }

    // Store the [devices] list in the [_devicesList] for accessing
    // the list outside this class
    setState(() {
      devicesList = devices;
    });
  }

  List<DropdownMenuItem<BluetoothDevice>> getDeviceItems() {
    List<DropdownMenuItem<BluetoothDevice>> items = [];
    if (devicesList.isEmpty) {
      items.add(const DropdownMenuItem(
        child: Text(
          'Select a Device',
          style: TextStyle(color: Colors.white),
        ),
      ));
    } else {
      for (var device in devicesList) {
        items.add(DropdownMenuItem(
          value: device,
          child: Text(device.name!),
        ));
      }
    }
    return items;
  }

  // Method to connect to bluetooth
  void connect() async {
    setState(() {
      isButtonUnavailable = true;
    });
    if (device == null) {
      show('No device selected');
    } else {
      // if (connection == null || (connection != null && !isConnected!)) {
      if (!isConnected!) {
        await BluetoothConnection.toAddress(device?.address).then((conn) {
          debugPrint('Connected to the device');
          connection = conn;
          setState(() {
            // connected = true;
            isVisible = false;
          });

          connection?.input?.listen(null).onDone(() {
            if (isDisconnecting) {
              debugPrint('Disconnecting locally!');
            } else {
              debugPrint('Disconnected remotely!');
            }
            if (mounted) {
              setState(() {});
            }
          });
        }).catchError((error) {
          debugPrint('Cannot connect, exception occurred');
          debugPrint(error);
        });
        show('Device connected');
        // showModalBottomSheet(
        //     enableDrag: false,
        //     isDismissible: false,
        //     isScrollControlled: false,
        //     context: context,
        //     builder: (context) => buildSheet()
        //     );
        setState(() => isButtonUnavailable = false);
      }
    }
  }

  void malas() {
    showModalBottomSheet(
        context: context,
        enableDrag: false,
        isDismissible: false,
        isScrollControlled: true,
        builder: (context) => 
        Scaffold(
      backgroundColor: Colors.black54,
      appBar: AppBar(
        title: Text('Index Stacked'),
      ),
      body: Column(
        children: [_buildIndexStackedWidgets(), _buildButtons()],
      ),
    )
);
  }

  // Method to disconnect bluetooth
  void disconnect() async {
    Navigator.pop(context);

    setState(() {
      isButtonUnavailable = true;
      deviceState = 0;
      isVisible = true;
    });

    await connection?.close();
    show('Device disconnected');
    if (!connection!.isConnected) {
      setState(() {
        connected = false;
        isButtonUnavailable = false;
      });
    }
  }

  // Method to send message,
  // for turning the Bluetooth device on
  void sendOnMessageToBluetooth() async {
    Uint8List data = utf8.encode("1" "\r\n") as Uint8List;
    connection?.output.add(data);
    await connection?.output.allSent;
    show('Device Turned On');
    setState(() {
      deviceState = 1; // device on
    });
  }

  // Method to send message,
  // for turning the Bluetooth device off
  void sendOffMessageToBluetooth() async {
    Uint8List data = utf8.encode("0" "\r\n") as Uint8List;
    connection?.output.add(data);
    await connection?.output.allSent;
    show('Device Turned Off');
    setState(() {
      deviceState = -1; // device off
    });
  }

  // Method to show a Snackbar,
  // taking message as the text
  Future show(
    String message, {
    Duration duration = const Duration(seconds: 3),
  }) async {
    await Future.delayed(const Duration(milliseconds: 100));
  }

  ///*Kodingan Bottom Sheet
  Widget buildSheet() =>  
   Scaffold(
      backgroundColor: Colors.black54,
      appBar: AppBar(
        title: Text('Index Stacked'),
      ),
      body: Column(
        children: [_buildIndexStackedWidgets(), _buildButtons()],
      ),
    );

    _buildIndexStackedWidgets() {
    return Expanded(
      flex: 3,
      child: IndexedStack(
        index: indexNum,
        children: [
          Column(
            children: [
              Image.asset('assets/image1.png'),
              Text(
                'Widget 1',
                style: TextStyle(
                    color: Colors.red,
                    fontSize: 30,
                    fontWeight: FontWeight.bold),
              )
            ],
          ),
          Column(
            children: [
              Image.asset('assets/image2.png'),
              Text(
                'Widget 2',
                style: TextStyle(
                    color: Colors.green,
                    fontSize: 50,
                    fontWeight: FontWeight.bold),
              )
            ],
          ),
          Column(
            children: [
              Image.asset('assets/image3.png'),
              Text(
                'Widget 3',
                style: TextStyle(
                    color: Colors.yellow,
                    fontSize: 80,
                    fontWeight: FontWeight.bold),
              )
            ],
          ),
        ],
      ),
    );
  }

  _buildButtons() {
    return Expanded(
        flex: 1,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            TextButton(
              child: Text("data1"),
              onPressed: () {
                setState(() {
                  indexNum = 0;
                });
              },
            ),
            TextButton(
              child: Text("data2"),
              onPressed: () {
                setState(() {
                  indexNum = 1;
                });
              },
            ),
            TextButton(
              child: Text("data3"),
              onPressed: () {
                setState(() {
                  indexNum = 2;
                });
              },
            ),
          ],
        ));}
}
