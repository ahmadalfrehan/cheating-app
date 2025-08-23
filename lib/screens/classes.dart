import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../getx/controller.dart';
import '../widgets/customdrawer.dart';

class Classes extends StatefulWidget {
  Classes({super.key});

  @override
  State<Classes> createState() => _ClassesState();
}

class _ClassesState extends State<Classes> {
  final controller = Get.put(AppController());

  @override
  void initState() {
    controller.getHome();
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(

      drawer: CustomDrawer(onItemTap: (v) {}),
      appBar: AppBar(
        title: Text("Classes"),
        actions: [
          Icon(Icons.radio_button_checked, color: Colors.green),
          InkWell(
            onTap: () {
              controller.getHome();
            },
            child: Text(' 8 Active  '),
          ),
        ],
      ),
      body: Obx(
        () =>
            controller.isLoading.value
                ? Center(child: CircularProgressIndicator())
                : Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: GridView.builder(
                    itemCount:
                        controller.classesResponse.value.data.classes.length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2, // Two columns
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 3 / 4,
                    ),
                    itemBuilder: (context, index) {
                      final item =
                          controller.classesResponse.value.data.classes[index];
                      return InkWell(
                        onTap: () {
                          controller.classroomId.value = item.id;
                          Navigator.pushNamed(context, '/start');
                          // Get.to(()=>Start());
                        },
                        child: Card(
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Expanded(
                                child: ClipRRect(
                                  borderRadius: BorderRadius.vertical(
                                    top: Radius.circular(12),
                                  ),
                                  child: Image.network(
                                    'https://plus.unsplash.com/premium_photo-1680807869780-e0876a6f3cd5?w=600&auto=format&fit=crop&q=60&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxzZWFyY2h8MXx8Y2xhc3Nyb29tfGVufDB8fDB8fHww',
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      item.name,
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    Text(
                                      item.capacity.toString(),
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.green,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
      ),
    );
  }
}
