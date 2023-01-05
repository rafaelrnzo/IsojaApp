import 'dart:ui';
import 'package:app_isoja/module/app/widget/BottomSheet.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:app_isoja/module/app/widget/bluetoothWave.dart';
import 'package:flutter/material.dart';
import 'package:app_isoja/core.dart';
import '../controller/app_controller.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';

class AppView extends StatefulWidget {
  const AppView({Key? key}) : super(key: key);

  Widget build(context, AppController controller) {
    controller.view = this;

    return GetMaterialApp(
      home: Scaffold(
        backgroundColor: controller.bgColor,
        body: LayoutBuilder(builder: (context, constraints) {
          return Visibility(
            visible: controller.isVisible ,
            child: SafeArea(
              child: Expanded(
                flex: 1,
                child: Container(
                  width: (constraints.maxWidth),
                  child: Column(
                    children: [
                      Expanded(
                        flex: 1,
                        child: Container(
                          child: Center(
                            child: Text(
                              "ISOJA",
                              style: TextStyle(
                                fontSize: 48,
                                color: controller.text,
                                fontFamily: 'Aquire',
                                shadows: [
                                  Shadow(
                                    blurRadius: 25.0,
                                    color: Colors.grey,
                                    offset: Offset(2, 2),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      // if(controller.connected == true){
                      Expanded(
                        flex: 3,
                        child: Container(
                          // color: Colors.blue,
                          child: BluetoothWave(),
                        ),
                      ),
                      Expanded(
                        flex: 3,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Container(
                              margin: EdgeInsets.symmetric(
                                  horizontal: (constraints.maxHeight * 0.05)),
                              padding: EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 5),
                              decoration: BoxDecoration(
                                  color: controller.container2,
                                  borderRadius: BorderRadius.circular(14)),
                              child: DropdownButton(
                                underline: Container(
                                  height: 0,
                                ),
                                hint: Text(
                                  "Select a Device",
                                  style: TextStyle(color: controller.container),
                                ),
                                isExpanded: true,
                                style:
                                    TextStyle(fontSize: 16, fontFamily: 'Inter'),
                                items: controller.getDeviceItems(),
                                onChanged: (value) => controller
                                    .setState(() => controller.device = value!),
                                value: controller.devicesList.isNotEmpty
                                    ? controller.device
                                    : null,
                                icon: Icon(Icons.arrow_drop_down_rounded),
                                iconEnabledColor: controller.container,
                                iconSize: 42,
                                dropdownColor: controller.container2,
                              ),
                            ),
                            Container(
                                child: Column(
                              children: [
                                Container(
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      fixedSize: Size(
                                          (constraints.maxWidth * 0.6),
                                          (constraints.maxHeight * 0.07)),
                                      backgroundColor: controller.container2,
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(18)),
                                    ),
                                    onPressed: 
                                      // controller.isButtonUnavailable
                                      //     ? null
                                      //     : controller.connected
                                              // ? controller.disconnect
                                      //         : controller.connect
                                      controller.malas
                                    ,
                                    child: Text(
                                      controller.connected
                                          ? 'Disconnect'
                                          : 'Connect',
                                      style: TextStyle(
                                          fontSize: 20, fontFamily: 'Inter'),
                                      // style: GoogleFonts.inter(),
                                    ),
                                  ),
                                ),
                                Container(
                                  child: Container(
                                    margin: EdgeInsets.only(
                                        top: constraints.maxHeight * 0.02),
                                    child: Text(
                                      "Turn On the Bluetooth Connnection of this device",
                                      style: TextStyle(
                                          color: controller.subText,
                                          fontSize: 14,
                                          fontFamily: 'Inter'),
                                    ),
                                  ),
                                )
                              ],
                            ))
                          ],
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Container(
                          margin: EdgeInsets.symmetric(
                              horizontal: (constraints.maxWidth * 0.05)),
                          child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  child: RawMaterialButton(
                                    onPressed: () async {
                                      await controller
                                          .getPairedDevices()
                                          .then((_) {
                                        controller.show('Device list refreshed');
                                      });
                                    },
                                    elevation: 3.0,
                                    fillColor: controller.container2,
                                    child: Icon(
                                      Icons.refresh,
                                      color: controller.container,
                                      size: (constraints.maxWidth * 0.1),
                                    ),
                                    padding: EdgeInsets.all(14.0),
                                    shape: CircleBorder(),
                                  ),
                                ),
                                Container(
                                  margin: EdgeInsets.symmetric(
                                      horizontal: (constraints.maxWidth * 0.03)),
                                  child: Row(
                                    children: [
                                      Container(
                                        margin: EdgeInsets.symmetric(
                                            horizontal:
                                                constraints.maxWidth * 0.02),
                                        child: Icon(
                                          Icons.bluetooth,
                                          color:
                                              controller.bluetoothState.isEnabled
                                                  ? controller.container2
                                                  : Color.fromARGB(
                                                      255, 130, 130, 130),
                                          size: (constraints.maxWidth / 10),
                                        ),
                                      ),
                                      Container(
                                        child: Transform.scale(
                                          scale: 2,
                                          child: Switch(
                                            value: controller
                                                .bluetoothState.isEnabled,
                                            // value: true,
                                            onChanged: (bool value) {
                                              future() async {
                                                if (value) {
                                                  await FlutterBluetoothSerial
                                                      .instance
                                                      .requestEnable();
                                                } else {
                                                  await FlutterBluetoothSerial
                                                      .instance
                                                      .requestDisable();
                                                }
                                                await controller
                                                    .getPairedDevices();
                                                controller.isButtonUnavailable =
                                                    false;

                                                if (controller.connected) {
                                                  controller.disconnect();
                                                }
                                              }

                                              future().then((_) {
                                                controller.setState(() {});
                                              });
                                            },
                                            activeColor: controller.container2,
                                            inactiveTrackColor:
                                                Color.fromRGBO(78, 78, 78, 1),
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              ]),
                        ),
                      ),
                      // ElevatedButton(onPressed: () {
                      //   Get.to(ApkView(),
                      //   arguments:
                      //   [controller.device?.name,
                      //   controller.connected]

                      //   );
                      // }, child: Text('omaga'))
                    ],
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );

  
  }

  @override
  State<AppView> createState() => AppController();
}
