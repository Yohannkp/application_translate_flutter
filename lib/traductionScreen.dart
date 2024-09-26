import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';

class TranslationScreen extends StatefulWidget {
  @override
  _TranslationScreenState createState() => _TranslationScreenState();
}

class _TranslationScreenState extends State<TranslationScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _textController = TextEditingController();
  String _translatedText = "";
  String _selectedLanguage = 'en'; // Langue par défaut : Anglais
  Map<String, String> _languages = {
    'en': 'Anglais',
    'fr': 'Français',
    'es': 'Espagnol',
    'de': 'Allemand',
    'it': 'Italien',
    'pt': 'Portugais',
    'ru': 'Russe',
    'zh': 'Chinois',
    'ja': 'Japonais',
    'ko': 'Coréen',
    'ar': 'Arabe',
    'hi': 'Hindi',
    'nl': 'Néerlandais',
    'sv': 'Suédois',
    'no': 'Norvégien',
    'da': 'Danois',
    'fi': 'Finnois',
    'pl': 'Polonais',
    'tr': 'Turc',
    'el': 'Grec',
    'he': 'Hébreu',
    'th': 'Thaï',
    'vi': 'Vietnamien',
    'id': 'Indonésien',
  };

  late AnimationController _controller;
  late Animation<double> _fadeInAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _fadeInAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    );
  }

  Future<void> traduireTexte(String text, String langue) async {
    const apiUrl = 'https://api.groq.com/openai/v1/chat/completions';
    const apiKey = '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';

    final headers = {
      'Authorization': 'Bearer $apiKey',
      'Content-Type': 'application/json',
    };

    final body = jsonEncode({
      'messages': [
        {
          'role': 'user',
          'content': 'Traduction en $langue : $text et renvoie uniquement le texte corrigé, sans aucune explication, commentaire ou autre information.'
        }
      ],
      'model': 'llama3-8b-8192'
    });

    final response = await http.post(
      Uri.parse(apiUrl),
      headers: headers,
      body: body,
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(utf8.decode(response.bodyBytes));
      setState(() {
        _translatedText = data['choices'][0]['message']['content'];
        _controller.forward(); // Démarrer l'animation de transition
      });
    } else {
      print('Erreur : ${response.statusCode}');
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF1F1B24),

      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: _textController,
                maxLines: 5,
                style: TextStyle(color: Colors.white, fontFamily: 'Roboto'),
                decoration: InputDecoration(
                  hintText: 'Entrez le texte à traduire...',
                  hintStyle: TextStyle(color: Colors.grey[500]),
                  filled: true,
                  fillColor: Color(0xFF2E2A35),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              SizedBox(height: 20),
              DropdownButton<String>(
                dropdownColor: Color(0xFF2E2A35),
                value: _selectedLanguage,
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedLanguage = newValue!;
                  });
                },
                items: _languages.keys.map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(
                      _languages[value] ?? value,
                      style: TextStyle(color: Colors.white),
                    ),
                  );
                }).toList(),
                style: TextStyle(
                  color: Colors.white,
                  fontFamily: 'Roboto',
                ),
                iconEnabledColor: Colors.white,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {

                  if(_textController.text ==""){
                    showTopSnackBar(
                      Overlay.of(context),
                      CustomSnackBar.error(
                        message:
                        "Ce champ ne peut pas être vide, entrez du texte s'il vous plait!",
                      ),
                    );
                  }else{
                    traduireTexte(_textController.text, _selectedLanguage);
                  }

                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: EdgeInsets.symmetric(vertical: 15),
                ),
                child: Text(
                  'Traduire',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Montserrat',
                    color: Colors.white,
                  ),
                ),
              ),
              SizedBox(height: 20),
              FadeTransition(
                opacity: _fadeInAnimation,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Texte traduit :',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontFamily: 'Roboto',
                        fontSize: 18,
                      ),
                    ),
                    SizedBox(height: 10),
                    Container(
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Color(0xFF2E2A35),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        _translatedText,
                        style: TextStyle(
                          color: Colors.white,
                          fontFamily: 'Roboto',
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
