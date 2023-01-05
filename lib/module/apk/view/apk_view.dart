import 'package:flutter/material.dart';
import '../controller/apk_controller.dart';
import 'package:app_isoja/core.dart';
import 'package:get/get.dart';
import '../../app/controller/app_controller.dart';

class ApkView extends StatelessWidget {
  const ApkView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ApkController>(
      init: ApkController(),
      builder: (controller) {
        controller.view = this;
        var data = Get.arguments;
        Get.put(AppController());
        AppController appController = Get.find<AppController>();

        return Scaffold(
          appBar: AppBar(
            title: const Text("Apk"),
          ),
          body: SingleChildScrollView(
            child: Container(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                children: [
                  Text("name: {$data[0]}"),
                  ElevatedButton(
                    onPressed: appController.connected
                        ? appController.sendOnMessageToBluetooth
                        : null,
                    child: const Text("ON"),
                  ),                                                   
                  ElevatedButton(
                    onPressed: appController.connected
                        ? appController.sendOffMessageToBluetooth
                        : null,
                    child: const Text("OFF"),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
