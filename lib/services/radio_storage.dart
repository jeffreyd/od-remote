import 'package:shared_preferences/shared_preferences.dart';
import '../models/radio_device.dart';

class RadioStorageService {
  static const _key = 'saved_radios';

  Future<List<RadioDevice>> loadRadios() async {
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getString(_key);
    if (json == null || json.isEmpty) return [];
    return RadioDevice.listFromJson(json);
  }

  Future<void> saveRadios(List<RadioDevice> radios) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, RadioDevice.listToJson(radios));
  }
}
