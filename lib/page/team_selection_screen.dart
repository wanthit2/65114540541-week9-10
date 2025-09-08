// team_selection_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:myapp/controller/team_controller.dart';
import 'package:myapp/model/pokemon_model.dart';
import 'package:myapp/page/saved_teams_screen.dart'; // เพิ่ม import

class TeamSelectionScreen extends StatelessWidget {
  TeamSelectionScreen({super.key});

  final TeamController controller = Get.put(TeamController());
  final TextEditingController textController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    textController.text = controller.teamName.value;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Obx(
          () => Text(controller.teamName.value),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.view_list),
            onPressed: () => Get.to(() => SavedTeamsScreen()),
            tooltip: 'View Saved Teams',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              controller.resetTeam();
              // เพิ่มบรรทัดนี้เพื่อรีเซ็ต TextField ด้วยเมื่อกด refresh
              textController.text = controller.teamName.value;
            },
            tooltip: 'Reset Team',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            _buildTeamEditor(),
            const SizedBox(height: 10),
            _buildSelectedTeamDisplay(),
            const Divider(),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: ElevatedButton.icon(
                icon: const Icon(Icons.save),
                label: const Text('Save Team'),
                onPressed: () {
                  // --- ส่วนที่แก้ไข ---
                  // 1. เรียกใช้ฟังก์ชันบันทึกเหมือนเดิม
                  controller.saveFinalTeam();
                  // 2. สั่งให้ TextField อัปเดตเป็นค่าล่าสุด (ที่ถูกรีเซ็ตแล้ว)
                  textController.text = controller.teamName.value;
                  // --- จบส่วนที่แก้ไข ---
                },
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  textStyle: const TextStyle(fontSize: 16),
                  backgroundColor: Colors.redAccent,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
            _buildSearchBar(),
            const SizedBox(height: 10),
            _buildPokemonGrid(),
          ],
        ),
      ),
    );
  }
  
  // ... โค้ดส่วน `_build...` ที่เหลือเหมือนเดิมทั้งหมด ...
  Widget _buildTeamEditor() {
    return TextField(
      controller: textController,
      decoration: const InputDecoration(
        labelText: 'Team Name',
        border: OutlineInputBorder(),
        suffixIcon: Icon(Icons.edit),
      ),
      onChanged: (value) => controller.updateTeamName(value),
    );
  }

  Widget _buildSelectedTeamDisplay() {
    // ... no changes ...
    return Obx(
      () => Container(
        height: 100,
        padding: const EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(3, (index) {
            if (index < controller.selectedTeam.length) {
              final pokemon = controller.selectedTeam[index];
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.network(pokemon.imageUrl, height: 60, width: 60),
                  Text(pokemon.name, style: const TextStyle(fontSize: 12)),
                ],
              );
            }
            return const CircleAvatar(
              backgroundColor: Colors.grey,
              child: Icon(Icons.question_mark),
            );
          }),
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    // ... no changes ...
    return TextField(
      decoration: const InputDecoration(
        labelText: 'Search Pokémon',
        prefixIcon: Icon(Icons.search),
        border: OutlineInputBorder(),
      ),
      onChanged: (value) => controller.searchQuery.value = value,
    );
  }

  Widget _buildPokemonGrid() {
    // ... no changes ...
    return Expanded(
      child: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        return GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            childAspectRatio: 0.8,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
          ),
          itemCount: controller.filteredPokemon.length,
          itemBuilder: (context, index) {
            final pokemon = controller.filteredPokemon[index];
            return _buildPokemonCard(pokemon);
          },
        );
      }),
    );
  }

  Widget _buildPokemonCard(Pokemon pokemon) {
    // ... no changes ...
    return Obx(
      () {
        final isSelected = controller.selectedTeam.contains(pokemon);
        return GestureDetector(
          onTap: () => controller.selectPokemon(pokemon),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: isSelected
                      ? Colors.blue.withOpacity(0.5)
                      : Colors.black.withOpacity(0.1),
                  blurRadius: 5,
                  spreadRadius: 1,
                )
              ],
              border: Border.all(
                color: isSelected ? Colors.blueAccent : Colors.grey.shade200,
                width: 2,
              ),
            ),
            transform: isSelected
                ? (Matrix4.identity()..scale(1.05))
                : Matrix4.identity(),
            child: Stack(
              children: [
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.network(pokemon.imageUrl,
                          height: 70, width: 70, fit: BoxFit.cover),
                      const SizedBox(height: 8),
                      Text(
                        pokemon.name.capitalizeFirst!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                AnimatedOpacity(
                  duration: const Duration(milliseconds: 200),
                  opacity: isSelected ? 1.0 : 0.0,
                  child: const Positioned(
                    top: 4,
                    right: 4,
                    child:
                        Icon(Icons.check_circle, color: Colors.blueAccent),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}