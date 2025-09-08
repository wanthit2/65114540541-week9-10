// page/saved_teams_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:myapp/controller/team_controller.dart';
import 'package:myapp/model/pokemon_model.dart';

class SavedTeamsScreen extends StatelessWidget {
  SavedTeamsScreen({super.key});

  // เรียกใช้ Controller ที่มีอยู่แล้ว
  final TeamController controller = Get.find();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Saved Teams'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      // ใช้ Obx เพื่อให้ UI อัปเดตอัตโนมัติเมื่อ savedTeams เปลี่ยนแปลง
      body: Obx(
        () {
          if (controller.savedTeams.isEmpty) {
            return const Center(
              child: Text(
                'You have no saved teams.',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            );
          }
          // แสดงผลเป็นรายการ
          return ListView.builder(
            itemCount: controller.savedTeams.length,
            itemBuilder: (context, index) {
              final team = controller.savedTeams[index];
              final teamName = team['name'] as String;
              // แปลงข้อมูล pokemon จาก Map กลับเป็น Object
              final pokemonsData = team['pokemons'] as List;
              final pokemons = pokemonsData
                  .map((p) => Pokemon.fromJson(p as Map<String, dynamic>))
                  .toList();

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(12),
                  title: Text(
                    teamName,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  subtitle: Row(
                    children: pokemons.map((pokemon) {
                      return Padding(
                        padding: const EdgeInsets.only(top: 8.0, right: 8.0),
                        child: Image.network(pokemon.imageUrl, height: 50),
                      );
                    }).toList(),
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                    // --- ส่วนที่แก้ไข ---
                    // เมื่อกดปุ่ม ให้เรียกฟังก์ชันลบทีมโดยตรง
                    onPressed: () {
                      controller.deleteSavedTeam(index);
                    },
                    // --- จบส่วนที่แก้ไข ---
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}