import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'init_controller.dart';

class InitPage extends StatelessWidget {
  InitPage({super.key});
  final InitController controller = Get.put(InitController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset("assets/images/logo.png", width: 160, height: 160),
            Text("AirCompanion", style: TextStyle(fontSize: 18)),
          ],
        ),
      ),
    );
  }
}
