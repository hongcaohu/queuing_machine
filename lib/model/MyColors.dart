import 'package:flutter/material.dart';

class MyColors {
  Color _baseBg; //背景色
  Color _logoBg; //标题背景色
  Color _jhBg; //呼叫已至背景色
  Color _numberBg; //号码显示区域背景色
  Color _bottomBg; //最下面显示的背景色

  get baseBg => _baseBg;
  get logoBg => _logoBg;
  get jhBg => _jhBg;
  get numberBg => _numberBg;
  get bottomBg => _bottomBg;

  MyColors.fromInt(int baseBg, int logoBg, int jhBg, int numberBg, int bottomBg) {
    this._baseBg = Color(baseBg);
    this._logoBg = Color(logoBg);
    this._jhBg = Color(jhBg);
    this._numberBg = Color(numberBg);
    this._bottomBg = Color(bottomBg);
  }
  
}