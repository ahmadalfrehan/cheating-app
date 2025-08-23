import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../getx/controller.dart';

class CustomDrawer extends StatelessWidget {
  final Function(String) onItemTap;

  CustomDrawer({Key? key, required this.onItemTap}) : super(key: key);
  final controller = Get.put(AppController());

  @override
  Widget build(BuildContext context) {
    return Drawer(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Drawer Header
          DrawerHeader(
            decoration: const BoxDecoration(color: Colors.blue),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                CircleAvatar(
                  radius: 28,
                  backgroundImage: AssetImage(
                    "assets/profile.png",
                  ), // your asset
                ),
                SizedBox(height: 10),
                Text(
                  "John Doe",
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
                Text(
                  "johndoe@email.com",
                  style: TextStyle(fontSize: 14, color: Colors.white70),
                ),
              ],
            ),
          ),

          // Drawer Items
          _buildDrawerItem(Icons.home, "Home", context),
          _buildDrawerItem(Icons.class_, "Classes", context),
          _buildDrawerItem(Icons.settings, "Settings", context),

          const Spacer(),

          // Logout at bottom
          _buildDrawerItem(Icons.logout, "Logout", context),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(IconData icon, String title, BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: Colors.blue),
      title: Text(title, style: const TextStyle(fontSize: 16)),
      onTap: () {
        if (title == 'Logout') {
          controller.logout();
        } else {
          Navigator.pop(context);
          onItemTap(title);
        }
      },
    );
  }
}
