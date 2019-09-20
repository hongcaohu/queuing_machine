import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:queuing_machine/utils/LocalStorage.dart';
import 'package:scoped_model/scoped_model.dart';

import 'MyColors.dart';

class ColorModel extends Model{
  MyColors _colors;

  get colors async {
    if(_colors==null) {
      return await getColors();
    }
    return _colors;
  }
  
  void increment(MyColors colors){
    _colors = colors;
    notifyListeners();
  }

    // LocalStorage.set("_baseBg", _baseBg?.value?.toString());
    // LocalStorage.set("_logoBg", _logoBg?.value?.toString());
    // LocalStorage.set("_jhBg", _jhBg?.value?.toString());
    // LocalStorage.set("_numberBg", _numberBg?.value?.toString());
    // LocalStorage.set("_bottomBg", _bottomBg?.value?.toString());
  getColors() async {
    int baseBg = int.parse((await LocalStorage.get("_baseBg"))??Color.fromARGB(255, 163, 170, 173).value.toString());
    int logoBg = int.parse((await LocalStorage.get("_logoBg"))??Color.fromARGB(255, 71, 74, 79).value.toString());
    int jhBg = int.parse((await LocalStorage.get("_jhBg"))??Colors.black.value.toString());
    int numberBg = int.parse((await LocalStorage.get("_numberBg"))??Color.fromARGB(255, 71, 74, 79).value.toString());
    int bottomBg = int.parse((await LocalStorage.get("_bottomBg"))??Color.fromARGB(255, 140, 149, 154).value.toString());
    return MyColors.fromInt(baseBg, logoBg, jhBg, numberBg, bottomBg);
  }
}