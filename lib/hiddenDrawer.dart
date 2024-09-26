import 'package:flutter/material.dart';
import 'package:hidden_drawer_menu/hidden_drawer_menu.dart';
import 'package:tpgoupeflutter2/correctionorthographe.dart';
import 'package:tpgoupeflutter2/main.dart';
import 'package:tpgoupeflutter2/traductionScreen.dart';
class HiddenDrawer extends StatefulWidget {
  const HiddenDrawer({super.key});

  @override
  State<HiddenDrawer> createState() => _HiddenDrawerState();
}

class _HiddenDrawerState extends State<HiddenDrawer> {
  List<ScreenHiddenDrawer> _pages = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _pages = [
      ScreenHiddenDrawer(ItemHiddenMenu(name: "T R A D U C T I O N", baseStyle: TextStyle(),colorLineSelected: Colors.orange, selectedStyle: TextStyle(color: Colors.white,fontWeight: FontWeight.bold)), TranslationScreen()),
      ScreenHiddenDrawer(ItemHiddenMenu(name: "O R T H O G R A P H E", baseStyle: TextStyle(),colorLineSelected: Colors.orange, selectedStyle: TextStyle(color: Colors.white,fontWeight: FontWeight.bold)), SpellCheckerScreen()),
      ScreenHiddenDrawer(ItemHiddenMenu(name: "A C C E U I L", baseStyle: TextStyle(),colorLineSelected: Colors.orange, selectedStyle: TextStyle(color: Colors.white,fontWeight: FontWeight.bold)), MainMenuScreen()),
          ];
  }
  @override
  Widget build(BuildContext context) {
    return HiddenDrawerMenu(screens: _pages, backgroundColorMenu: Color(0xFF27212E),backgroundColorAppBar: Color(0xFF27212E),styleAutoTittleName: TextStyle(fontWeight: FontWeight.bold),isTitleCentered: true,slidePercent: 70,initPositionSelected: 2,);
  }
}
