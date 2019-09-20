import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class LocalStorage {
  static Future get(String key) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(key);
  }
 
  static Future set(String key, String value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString(key, value);
  }
 
  static Future setJSON(String key, value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    value = json.encode(value); //对value进行编码，将对象传递给json.encode方法
    prefs.setString(key, value);
  }
 
  static Future remove(String key) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove(key);
  }
}