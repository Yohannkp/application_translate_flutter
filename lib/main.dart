import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:tpgoupeflutter2/correctionorthographe.dart';
import 'package:tpgoupeflutter2/hiddenDrawer.dart';
import 'package:tpgoupeflutter2/traductionScreen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CORRECTEUR & TRADUCTION',

      home: HiddenDrawer(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MainMenuScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF1F1B24),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                color: Color(0xFF1F1B24),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 40,
                    child: Lottie.network(
                        'https://lottie.host/6de84e75-cdeb-4995-ba07-1eb67281af41/aAsjcy92Tr.json'),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Bienvenue',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: Icon(Icons.spellcheck, color: Color(0xFF6200EA)),
              title: Text('Correction d\'orthographe'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SpellCheckerScreen()),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.translate, color: Color(0xFF6200EA)),
              title: Text('Traduction'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => TranslationScreen()),
                );
              },
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // Background gradient
          Container(
            decoration: BoxDecoration(
            ),
            child: Lottie.network(
                'https://lottie.host/23a73cbf-a646-4c0f-b4c8-bcfc55513533/7orkBBzHWt.json',reverse: true),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Bienvenue chez \nT R A N S C O R R E',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Montserrat',
                  ),
                ),
                SizedBox(height: 20),
                Text(
                  'Cliquez sur le menu pour commencer',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 20,
                    fontFamily: 'Roboto',
                  ),
                ),
                SizedBox(height: 50),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
