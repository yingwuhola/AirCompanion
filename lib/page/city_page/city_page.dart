import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'city_controller.dart';

class CityPage extends StatelessWidget {
  CityPage({super.key});

  final CityController controller = Get.put(CityController());
  final TextEditingController textEditingController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Color.fromRGBO(234, 56, 145, 0.614),
        elevation: 0,
        leading: IconButton(
          onPressed: () {
            Get.back();
          },
          icon: Icon(Icons.arrow_back, color: Colors.white),
        ),
        title: Container(
          padding: EdgeInsets.symmetric(horizontal: 8.0),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.15),
            borderRadius: BorderRadius.circular(30.0),
          ),
          child: Row(
            children: [
              Icon(Icons.search, color: Colors.white.withOpacity(0.9)),
              SizedBox(width: 8.0),
              Expanded(
                child: TextField(
                  controller: textEditingController,
                  style: TextStyle(color: Colors.white),
                  cursorColor: Colors.white,
                  decoration: InputDecoration(
                    hintText: 'Search city',
                    hintStyle: TextStyle(color: Colors.white70),
                    border: InputBorder.none,
                    isDense: true,
                  ),
                  onChanged: (v) {
                    if (v.isNotEmpty) {
                      controller.getCityList(v);
                    }
                  },
                  onSubmitted: (v) {
                    if (v.isNotEmpty) {
                      controller.getCityList(v);
                    }
                  },
                ),
              ),
              IconButton(
                icon: Icon(Icons.send, color: Colors.white),
                onPressed: () {
                  if (textEditingController.text.isNotEmpty) {
                    controller.getCityList(textEditingController.text);
                  }
                },
              ),
            ],
          ),
        ),
      ),
      body: GetBuilder<CityController>(
        builder: (_) {
          if (controller.cityList.isEmpty) {
            return Center(
              child: Text(
                'No cities found',
                style: TextStyle(fontSize: 18.0, color: Colors.grey),
              ),
            );
          }
          return ListView.builder(
            padding: EdgeInsets.all(12.0),
            itemCount: controller.cityList.length,
            itemBuilder: (context, index) {
              final item = controller.cityList[index];
              return Card(
                elevation: 3,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                margin: EdgeInsets.symmetric(vertical: 8.0),
                child: ListTile(
                  onTap: () {
                    Get.back(result: item);
                  },
                  title: Text(
                    '${item["name"]}',
                    style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    '${item["country"]}',
                    style: TextStyle(fontSize: 14.0, color: Colors.grey[600]),
                  ),
                  trailing: Icon(Icons.location_city, color: Colors.blueAccent),
                ),
              );
            },
          );
        },
      ),
    );
  }
}