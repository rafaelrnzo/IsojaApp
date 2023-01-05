import 'package:flutter/src/widgets/basic.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/material.dart';
import 'package:simple_ripple_animation/simple_ripple_animation.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
// import 'package:simple_ripple_animation/simple_ripple_animation.dart';


class BluetoothWave extends StatelessWidget {
  const BluetoothWave({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context,constraints) {
        return Container(
          child: RippleAnimation(
          child: Container(
              child: RawMaterialButton(
                onPressed: () {
                  FlutterBluetoothSerial.instance.openSettings();
                },
                elevation: 0,
                fillColor: Color.fromRGBO(42, 50, 75, 1),
                child: Icon(
                  Icons.bluetooth,
                  color: Color.fromRGBO(225, 229, 238, 1),
                  size: (constraints.maxWidth * 0.3),
            ),
            padding: EdgeInsets.all(constraints.maxWidth * 0.1),
            shape: CircleBorder(),
          )),
          color: Color.fromARGB(42, 50, 75, 1),
          repeat: true,
          minRadius: 70,
          ripplesCount: 3,
          duration: const Duration(milliseconds: 1500),
        ),
        );
      }
    );
  }
}
