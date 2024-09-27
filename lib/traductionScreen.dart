// On importe les outils qu'on va utiliser pour bosser :
// Convertir du JSON, envoyer des messages à une API, et faire de jolies interfaces avec Flutter.
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';

// Classe principale pour notre écran de traduction
class TranslationScreen extends StatefulWidget {
  @override
  _TranslationScreenState createState() => _TranslationScreenState();
}

// Ici c’est là où la magie opère : on gère l’état de l’appli avec des animations cool
class _TranslationScreenState extends State<TranslationScreen>
    with SingleTickerProviderStateMixin {

  // Contrôle le texte que l’utilisateur tape dans le champ
  final TextEditingController _textController = TextEditingController();

  // On garde ici le texte traduit, prêt à être affiché
  String _translatedText = "";

  // Langue par défaut (Anglais), mais ça peut changer avec le menu déroulant
  String _selectedLanguage = 'en';

  // Voici toutes les langues qu'on peut choisir (code langue : nom complet)
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

  // AnimationController pour faire un joli effet quand le texte traduit apparaît
  late AnimationController _controller;
  late Animation<double> _fadeInAnimation;

  // Initialisation de l’animation (on va faire un fade-in trop stylé)
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500), // L'animation va durer 500ms
      vsync: this,
    );
    _fadeInAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn, // On fait en sorte que l'apparition soit smooth
    );
  }

  // Fonction qui envoie une requête à l'API pour traduire le texte
  Future<void> traduireTexte(String text, String langue) async {

    // URL de l'API et clé d'authentification (comme un sésame magique)
    const apiUrl = 'https://api.groq.com/openai/v1/chat/completions';
    const apiKey = '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';

    // En-têtes pour dire à l'API qu’on parle en JSON et qu’on est autorisés à lui causer
    final headers = {
      'Authorization': 'Bearer $apiKey',
      'Content-Type': 'application/json ',
    };

    // On envoie le texte avec la langue choisie à l'API en format JSON
    final body = jsonEncode({
      'messages': [
        {
          'role': 'user',
          'content': 'Traduction en $langue : $text et renvoie uniquement le texte corrigé, sans aucune explication, commentaire ou autre information.'
        }
      ],
      'model': 'llama3-8b-8192'
    });

    // On envoie la requête POST et on attend la réponse de l'API
    final response = await http.post(
      Uri.parse(apiUrl),
      headers: headers,
      body: body,
    );

    // Si ça fonctionne (status 200), on récupère le texte traduit
    if (response.statusCode == 200) {
      final data = jsonDecode(utf8.decode(response.bodyBytes));
      setState(() {
        _translatedText = data['choices'][0]['message']['content']; // On affiche le texte traduit
        _controller.forward(); // Démarre l'animation pour faire apparaître le texte
      });
    } else {
      // Si ça plante, on affiche une erreur
      print('Erreur : ${response.statusCode}');
    }
  }

  // On clean le contrôleur d’animation quand l’écran est fermé
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // Voilà la partie où on construit toute l’interface visuelle
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF1F1B24), // Couleur de fond trop stylée

      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [

              // Champ de texte où l'utilisateur entre ce qu'il veut traduire
              TextField(
                controller: _textController, // Relie le champ au TextEditingController
                maxLines: 5, // Nombre de lignes de texte (ici 5)
                style: TextStyle(color: Colors.white, fontFamily: 'Roboto'), // Style du texte
                decoration: InputDecoration(
                  hintText: 'Entrez le texte à traduire...', // Texte indicatif
                  hintStyle: TextStyle(color: Colors.grey[500]), // Couleur du hint
                  filled: true,
                  fillColor: Color(0xFF2E2A35), // Couleur de fond du champ
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12), // Bord arrondi du champ
                    borderSide: BorderSide.none, // Pas de bordure visible
                  ),
                ),
              ),

              SizedBox(height: 20), // Petit espace entre les éléments

              // Menu déroulant pour choisir la langue de traduction
              DropdownButton<String>(
                dropdownColor: Color(0xFF2E2A35), // Couleur de fond du menu
                value: _selectedLanguage, // La langue sélectionnée actuellement
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedLanguage = newValue!; // On met à jour la langue sélectionnée
                  });
                },
                items: _languages.keys.map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value, // Le code de la langue
                    child: Text(
                      _languages[value] ?? value, // Le nom de la langue
                      style: TextStyle(color: Colors.white), // Couleur du texte
                    ),
                  );
                }).toList(),
                style: TextStyle(
                  color: Colors.white,
                  fontFamily: 'Roboto',
                ),
                iconEnabledColor: Colors.white, // Couleur de l'icône du menu déroulant
              ),

              SizedBox(height: 20), // Encore un petit espace

              // Bouton pour lancer la traduction
              ElevatedButton(
                onPressed: () {
                  // Si le champ de texte est vide, on affiche une alerte
                  if(_textController.text == ""){
                    showTopSnackBar(
                      Overlay.of(context),
                      CustomSnackBar.error(
                        message:
                        "Ce champ ne peut pas être vide, entrez du texte s'il vous plaît!",
                      ),
                    );
                  } else {
                    // Sinon, on appelle la fonction pour traduire le texte
                    traduireTexte(_textController.text, _selectedLanguage);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange, // Couleur du bouton
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12), // Bord arrondi
                  ),
                  padding: EdgeInsets.symmetric(vertical: 15), // Taille du bouton
                ),
                child: Text(
                  'Traduire', // Texte sur le bouton
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Montserrat',
                    color: Colors.white,
                  ),
                ),
              ),

              SizedBox(height: 20), // Encore un espace

              // Transition pour faire apparaître le texte traduit en mode smooth
              FadeTransition(
                opacity: _fadeInAnimation, // Utilise l’animation définie plus haut
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

                    // Conteneur pour afficher le texte traduit
                    Container(
                      padding: EdgeInsets.all(12), // Espace interne au conteneur
                      decoration: BoxDecoration(
                        color: Color(0xFF2E2A35), // Couleur de fond du conteneur
                        borderRadius: BorderRadius.circular(12), // Bord arrondi
                      ),
                      child: Text(
                        _translatedText, // Le texte traduit s’affiche ici
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
