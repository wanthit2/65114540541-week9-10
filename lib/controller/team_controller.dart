// team_controller.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:myapp/model/pokemon_model.dart';
import 'package:myapp/page/saved_teams_screen.dart'; // เพิ่ม import สำหรับหน้าใหม่

class TeamController extends GetxController {
  // --- ตัวแปรเดิม ---
  var allPokemon = <Pokemon>[].obs;
  var selectedTeam = <Pokemon>[].obs;
  var teamName = 'My Pokémon Team'.obs;
  var isLoading = true.obs;
  var searchQuery = ''.obs;

  // --- ตัวแปรใหม่สำหรับจัดเก็บทีมทั้งหมดที่บันทึกไว้ ---
  var savedTeams = <Map<String, dynamic>>[].obs;

  final _storage = GetStorage();

  List<Pokemon> get filteredPokemon {
    if (searchQuery.isEmpty) {
      return allPokemon;
    } else {
      return allPokemon
          .where((p) =>
              p.name.toLowerCase().contains(searchQuery.value.toLowerCase()))
          .toList();
    }
  }

  @override
  void onInit() {
    super.onInit();
    loadCurrentTeamFromStorage(); // เปลี่ยนชื่อเพื่อความชัดเจน
    loadSavedTeamsFromStorage();  // โหลดรายการทีมที่เคยบันทึกไว้
    fetchPokemon();
  }

  Future<void> fetchPokemon() async {
    // ... โค้ดส่วนนี้เหมือนเดิม ...
    try {
      isLoading(true);
      final response = await http
          .get(Uri.parse('https://pokeapi.co/api/v2/pokemon?limit=151'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final results = data['results'] as List;
        allPokemon.value =
            results.map((json) => Pokemon.fromJson(json)).toList();
      } else {
        Get.snackbar('Error', 'Failed to load Pokémon');
      }
    } catch (e) {
      Get.snackbar('Error', 'An error occurred: $e');
    } finally {
      isLoading(false);
    }
  }

  void selectPokemon(Pokemon pokemon) {
    if (selectedTeam.contains(pokemon)) {
      selectedTeam.remove(pokemon);
    } else {
      if (selectedTeam.length < 3) {
        selectedTeam.add(pokemon);
      } else {
        Get.snackbar(
          'Team Full',
          'You can only select up to 3 Pokémon.',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    }
    saveCurrentTeamToStorage(); // บันทึกทีมที่กำลังแก้ไขอยู่
  }

  void updateTeamName(String newName) {
    teamName.value = newName;
    saveCurrentTeamToStorage();
  }

  void resetTeam() {
    selectedTeam.clear();
    saveCurrentTeamToStorage();
  }

  // --- แก้ไข/เปลี่ยนชื่อฟังก์ชันบันทึก ---
  // บันทึก "ทีมปัจจุบันที่กำลังเลือก" อัตโนมัติ
  void saveCurrentTeamToStorage() {
    _storage.write('currentTeamName', teamName.value);
    _storage.write(
        'currentSelectedTeam', selectedTeam.map((p) => p.toJson()).toList());
  }

  // โหลด "ทีมปัจจุบันที่กำลังเลือก" ตอนเปิดแอป
  void loadCurrentTeamFromStorage() {
    teamName.value = _storage.read('currentTeamName') ?? 'My Pokémon Team';
    final savedTeam = _storage.read<List>('currentSelectedTeam');
    if (savedTeam != null) {
      selectedTeam.value =
          savedTeam.map((json) => Pokemon.fromJson(json)).toList();
    }
  }

  // --- ฟังก์ชันใหม่สำหรับจัดการ "รายการทีมที่บันทึก" ---

  // ฟังก์ชันหลัก: เมื่อผู้ใช้กด "บันทึกทีม"
 void saveFinalTeam() {
    if (selectedTeam.isEmpty) {
      Get.snackbar(
        'Cannot Save',
        'Please select at least one Pokémon.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange.shade800,
        colorText: Colors.white,
      );
      return;
    }
    
    // สร้าง Map เพื่อเก็บข้อมูลทีมปัจจุบัน
    final newTeam = {
      'name': teamName.value,
      'pokemons': selectedTeam.map((p) => p.toJson()).toList(),
    };

    // เพิ่มทีมใหม่เข้าไปในรายการทีมที่บันทึกไว้
    savedTeams.add(newTeam);
    // บันทึกรายการทีมทั้งหมดลง Storage
    _storage.write('savedTeamsList', savedTeams.toList());

    Get.snackbar(
      'Success',
      'Team "${teamName.value}" has been saved!',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green,
      colorText: Colors.white,
    );
    
    // --- ส่วนที่เพิ่มเข้ามา ---
    // รีเซ็ตทีมที่เลือกและชื่อทีมปัจจุบัน
    selectedTeam.clear();
    teamName.value = 'My Pokémon Team';
    // บันทึกสถานะที่รีเซ็ตแล้วลง storage
    saveCurrentTeamToStorage();
    // --- จบส่วนที่เพิ่มเข้ามา ---

    // ไปยังหน้าแสดงทีมที่บันทึกไว้
    Get.to(() => SavedTeamsScreen());
  }

  // โหลดรายการทีมทั้งหมดจาก Storage ตอนเปิดแอป
  void loadSavedTeamsFromStorage() {
    final data = _storage.read<List>('savedTeamsList');
    if (data != null) {
      // GetStorage จะอ่านเป็น List<dynamic> ต้องแปลงกลับเป็นชนิดที่เราต้องการ
      savedTeams.value = data.map((item) => Map<String, dynamic>.from(item)).toList();
    }
  }

  // ลบทีมออกจากรายการที่บันทึกไว้
  void deleteSavedTeam(int index) {
    String deletedTeamName = savedTeams[index]['name'];
    savedTeams.removeAt(index);
    _storage.write('savedTeamsList', savedTeams.toList());
    Get.snackbar(
      'Deleted',
      'Team "$deletedTeamName" was removed.',
      snackPosition: SnackPosition.BOTTOM,
    );
  }
}