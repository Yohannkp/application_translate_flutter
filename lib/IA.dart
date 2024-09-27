import 'dart:convert';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';

class IA extends StatefulWidget {
  @override
  _IAScreenState createState() => _IAScreenState();
}

class _IAScreenState extends State<IA> with SingleTickerProviderStateMixin {
  final TextEditingController _textController = TextEditingController();
  String _translatedText = "";
  String _selectedLanguage = 'en'; // Langue par défaut : Anglais
  bool isSpeaking = false; // Variable pour suivre l'état du TTS

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

  FlutterTts flutterTts = FlutterTts();

  void textToSpeech(String text) async {
    await flutterTts.setLanguage("fr-FR");
    await flutterTts.setVolume(0.5);
    await flutterTts.setSpeechRate(0.5);
    await flutterTts.setPitch(1);

    // Gérer les événements quand le TTS commence et finit de parler
    flutterTts.setStartHandler(() {
      setState(() {
        isSpeaking = true; // Le TTS a commencé à parler
      });
    });

    flutterTts.setCompletionHandler(() {
      setState(() {
        isSpeaking = false; // Le TTS a fini de parler
      });
    });

    flutterTts.setCancelHandler(() {
      setState(() {
        isSpeaking = false; // Le TTS a été annulé
      });
    });

    await flutterTts.speak(text);
  }

  void stopSpeech() async {
    await flutterTts.stop();
    setState(() {
      isSpeaking = false; // Arrêt du TTS
    });
  }

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
          'content': 'Repond à cette question : $text'
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
      textToSpeech(data['choices'][0]['message']['content']);
    } else {
      print('Erreur : ${response.statusCode}');
    }
  }

  @override
  void dispose() {
    // Arrêter le TTS quand l'application est fermée
    flutterTts.stop();
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
              // Animation sur le champ de texte avec AnimatedContainer
              AnimatedContainer(
                duration: Duration(milliseconds: 500),
                curve: Curves.easeInOut,
                padding: const EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  color: Color(0xFF2E2A35),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TextField(
                  controller: _textController,
                  maxLines: 5,
                  style: TextStyle(color: Colors.white, fontFamily: 'Roboto'),
                  decoration: InputDecoration(
                    hintText: 'Que puis-je faire pour vous ?',
                    hintStyle: TextStyle(color: Colors.grey[500]),
                    border: InputBorder.none,
                  ),
                ),
              ),
              SizedBox(height: 20),
              // Bouton d'envoi avec animation sur le changement de couleur
              AnimatedContainer(
                duration: Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                child: ElevatedButton(
                  onPressed: () {
                    if (_textController.text == "") {
                      CustomSnackBar.error(
                        message:
                        "Ce champ ne peut pas être vide, entrez du texte s'il vous plait!",
                      );
                    } else {
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
                    'Envoyer',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Montserrat',
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20),

              // Animation d'apparition/disparition du bouton "Arrêter"
              Center(
                child: AnimatedOpacity(
                  opacity: isSpeaking ? 1.0 : 0.0,
                  duration: Duration(milliseconds: 500),
                  curve: Curves.easeInOut,
                  child: isSpeaking
                      ? SizedBox(
                    width: 60, // Réduire la taille du bouton
                    height: 60, // Réduire la taille du bouton
                    child: ElevatedButton(
                      onPressed: stopSpeech, // Appel à la fonction pour stopper le TTS
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: Icon(Icons.stop, color: Colors.white), // Icône stop
                    ),
                  )
                      : SizedBox.shrink(), // Afficher un élément vide si le TTS n'est pas en cours
                ),
              ),

              SizedBox(height: 20),

              // Animation de la transition pour la réponse
              FadeTransition(
                opacity: _fadeInAnimation,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Réponse :',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontFamily: 'Roboto',
                        fontSize: 18,
                      ),
                    ),
                    SizedBox(height: 10),
                    AnimatedContainer(
                      duration: Duration(milliseconds: 500),
                      curve: Curves.easeInOut,
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
