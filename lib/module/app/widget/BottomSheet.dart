import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:get/get.dart';
import '../../app/controller/app_controller.dart';

class BtmSheet extends StatefulWidget {
  BtmSheet({super.key});

  @override
  State<BtmSheet> createState() => _BtmSheetState();
}

class _BtmSheetState extends State<BtmSheet> {
  AppController appliController = Get.put(AppController());
  AppController appController = Get.find();
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Row(
        children: [
          ElevatedButton(
              onPressed: appController.connected
                  ? appController.sendOnMessageToBluetooth
                  : null,
              child: Text("malas"))
        ],
      ),
    );
  }
}
