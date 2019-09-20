import 'package:flutter/material.dart';
import 'package:flutter_material_color_picker/flutter_material_color_picker.dart';
import 'package:queuing_machine/model/MyColors.dart';
import 'package:queuing_machine/utils/LocalStorage.dart';
import 'package:queuing_machine/utils/LocalStorage.dart' as prefix0;

class ColorSetting extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return ColorSettingState();
  }
}

class ColorSettingState extends State<ColorSetting> {
  Color _baseBg; //背景色
  Color _tempBaseBg;

  Color _logoBg; //标题背景色
  Color _tempLogoBg;

  Color _jhBg; //呼叫已至背景色
  Color _tempJhBg;

  Color _numberBg; //号码显示区域背景色
  Color _tempNumberBg;

  Color _bottomBg; //最下面显示的背景色
  Color _tempBottomBg;

  List bgcolors = [
    {"key": "baseBg", "name": "背景色"},
    {"key": "logoBg", "name": "标题背景色"},
    {"key": "jhBg", "name": "呼叫已至背景色"},
    {"key": "numberBg", "name": "号码显示区背景色"},
    {"key": "bottomBg", "name": "底部背景色"}
  ];

  Map getColor(String key) {
    Map _color = {};
    switch (key) {
      case "baseBg":
        {
          _color = {"color": _baseBg, "temp": _tempBaseBg};
        }
        break;
      case "logoBg":
        {
          _color = {"color": _logoBg, "temp": _tempLogoBg};
        }
        break;
      case "jhBg":
        {
          _color = {"color": _jhBg, "temp": _tempJhBg};
        }
        break;
      case "numberBg":
        {
          _color = {"color": _numberBg, "temp": _tempNumberBg};
        }
        break;
      case "bottomBg":
        {
          _color = {"color": _bottomBg, "temp": _tempBottomBg};
        }
        break;
      default:
        {
          _color = {};
        }
        break;
    }
    return _color;
  }

  void changeColor(String type, Color tempColor) {
    switch (type) {
      case "baseBg":
        {
          setState(() {
            _baseBg = tempColor;
          });
        }
        break;
      case "logoBg":
        {
          setState(() {
            _logoBg = tempColor;
          });
        }
        break;
      case "jhBg":
        {
          setState(() {
            _jhBg = tempColor;
          });
        }
        break;
      case "numberBg":
        {
          setState(() {
            _numberBg = tempColor;
          });
        }
        break;
      case "bottomBg":
        {
          setState(() {
            _bottomBg = tempColor;
          });
        }
        break;
      default:
        {}
        break;
    }
  }

  void _openDialog(String type, Map colors, String title, Widget content) {
    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          contentPadding: const EdgeInsets.all(6.0),
          title: Text(title),
          content: content,
          actions: [
            FlatButton(
              child: Text('CANCEL'),
              onPressed: Navigator.of(context).pop,
            ),
            FlatButton(
              child: Text('SUBMIT'),
              onPressed: () {
                Navigator.of(context).pop();
                changeColor(type, colors["temp"]);
              },
            ),
          ],
        );
      },
    );
  }

  void _openColorPicker(String type, Map colors) async {
    _openDialog(
      type,
      colors,
      "Color picker",
      MaterialColorPicker(
        selectedColor: colors["color"],
        onColorChange: (color) => {setState(() => colors["temp"] = color)},
        onMainColorChange: (color) => {print("maincolor->" + color.toString())},
        onBack: () => print("Back button pressed"),
      ),
    );
  }


  // Color _baseBg; //背景色
  // Color _tempBaseBg;

  // Color _logoBg; //标题背景色
  // Color _tempLogoBg;

  // Color _jhBg; //呼叫已至背景色
  // Color _tempJhBg;

  // Color _numberBg; //号码显示区域背景色
  // Color _tempNumberBg;

  // Color _bottomBg; //最下面显示的背景色
  // Color _tempBottomBg;
  void saveColorSetting() {

    MyColors myColor = MyColors.fromInt(_baseBg?.value, _logoBg?.value, _jhBg?.value, _numberBg?.value,_bottomBg?.value);
    LocalStorage.setJSON("colors", myColor);
    //保存设置的背景颜色
    LocalStorage.set("_baseBg", _baseBg?.value?.toString());
    LocalStorage.set("_logoBg", _logoBg?.value?.toString());
    LocalStorage.set("_jhBg", _jhBg?.value?.toString());
    LocalStorage.set("_numberBg", _numberBg?.value?.toString());
    LocalStorage.set("_bottomBg", _bottomBg?.value?.toString());

    //更新状态数据

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("颜色设置"),
        actions: <Widget>[
          FlatButton(
            onPressed: () => saveColorSetting(),
            child: Text("保存", style: TextStyle(color: Colors.white),),
          )
        ],
      ),
      body: Container(
          child: ListView(
        children: <Widget>[
          Container(
            padding: EdgeInsets.all(8),
            color: Colors.grey[200],
            child: Text("背景色"),
          ),
          ...bgcolors.map((item) => ListTile(
              onTap: () => _openColorPicker(item["key"], getColor(item["key"])),
              title: Text(item["key"]),
              subtitle: Text(item["name"]),
              trailing: CircleAvatar(
                backgroundColor: getColor(item["key"])["color"],
                radius: 35.0,
                child: const Text(""),
              ))),
          Container(
            padding: EdgeInsets.all(8),
            color: Colors.grey[200],
            child: Text("字体颜色"),
          ),
        ],
      )),
    );
  }
}
