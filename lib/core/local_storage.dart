import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

class LocalStorage {
  static Future<Directory> _appDir() async {
    return getApplicationDocumentsDirectory();
  }

  static Future<File> _requestsFile() async {
    final dir = await _appDir();
    return File('${dir.path}/requests.json');
  }

  static Future<File> _reservationsFile() async {
    final dir = await _appDir();
    return File('${dir.path}/reservations.json');
  }

  // Requests
  static Future<List<Map<String, dynamic>>> getRequests() async {
    try {
      final file = await _requestsFile();
      if (!file.existsSync()) return [];
      final content = file.readAsStringSync();
      final data = jsonDecode(content) as List<dynamic>;
      return data.map((e) => Map<String, dynamic>.from(e as Map)).toList();
    } on FileSystemException {
      return [];
    }
  }

  static Future<void> saveRequests(List<Map<String, dynamic>> requests) async {
    final file = await _requestsFile();
    await file.writeAsString(jsonEncode(requests));
  }

  static Future<void> addRequest(Map<String, dynamic> request) async {
    final requests = await getRequests();
    requests.add(request);
    await saveRequests(requests);
  }

  static Future<void> updateRequestStatus(String id, String status) async {
    final requests = await getRequests();
    final idx = requests.indexWhere((r) => r['id'] == id);
    if (idx != -1) {
      requests[idx]['status'] = status;
      await saveRequests(requests);
    }
  }

  // Reservations
  static Future<List<Map<String, dynamic>>> getReservations() async {
    try {
      final file = await _reservationsFile();
      if (!file.existsSync()) return [];
      final content = file.readAsStringSync();
      final data = jsonDecode(content) as List<dynamic>;
      return data.map((e) => Map<String, dynamic>.from(e as Map)).toList();
    } on FileSystemException {
      return [];
    }
  }

  static Future<void> saveReservations(
    List<Map<String, dynamic>> reservations,
  ) async {
    final file = await _reservationsFile();
    await file.writeAsString(jsonEncode(reservations));
  }

  static Future<void> addReservation(Map<String, dynamic> reservation) async {
    final reservations = await getReservations();
    reservations.add(reservation);
    await saveReservations(reservations);
  }
}
