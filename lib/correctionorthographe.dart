import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:lottie/lottie.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/safe_area_values.dart';
import 'package:top_snackbar_flutter/tap_bounce_container.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';
import 'package:rive/rive.dart';

import 'AnimatedEnum.dart';

class SpellCheckerScreen extends StatefulWidget {
  @override
  _SpellCheckerScreenState createState() => _SpellCheckerScreenState();
}

class _SpellCheckerScreenState extends State<SpellCheckerScreen> {
  Artboard? _artboard;
  late RiveAnimationController idle;
  late RiveAnimationController handsDown;
  late RiveAnimationController handsUp;
  late RiveAnimationController success;
  late RiveAnimationController fail;
  late RiveAnimationController lookdownleft;
  late RiveAnimationController lookdownright;

  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode(); // Créer un FocusNode
  List<Map<String, String>> _messages = [];
  bool _isLoading = false; // Indicateur de chargement

  Future<void> correctionOrthographe(String text) async {
    setState(() {
      _messages.add({
        'role': 'user',
        'message': text,
      });
      _scrollToBottom(); // Afficher immédiatement le message utilisateur
      _isLoading = true; // Commence le chargement
    });

    await Future.delayed(Duration(seconds: 2)); // Délai de 2 secondes

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
          'content':

          "Corrige uniquement les fautes d'orthographe dans ce texte. Ne fais aucun autre changement, ne retourne aucun commentaire, garde le texte exactement tel qu'il est sauf pour corriger les erreurs d'orthographe : $text"
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
      final data = jsonDecode(utf8.decode(response.bodyBytes));  // Décodage UTF-8 ici
      setState(() {
        _messages.add({
          'role': 'bot',
          'message': data['choices'][0]['message']['content'],
        });
        _isLoading = false; // Fin du chargement
        _scrollToBottom();
        addSuccess();
      });
    } else {
      print('Erreur : ${response.statusCode}');
      setState(() {
        _isLoading = false; // Fin du chargement même en cas d'erreur
        _scrollToBottom(); // Scroll to bottom even if there's an error
      });
    }
    await Future.delayed(Duration(seconds: 2));
    addIdle();
    _textController.clear(); // Vider le champ de texte après soumission
  }




  // Scroll vers le bas de la ListView
  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }
  /*
  FlutterTts flutterTts = FlutterTts();

  Future<void> _speak(String text) async {
    await flutterTts.setLanguage("fr-FR");  // Définit la langue en français
    await flutterTts.setPitch(1.0);         // Définit le ton
    await flutterTts.speak(text);           // Parle le texte
  }*/
  @override
  void initState() {
    // TODO: implement initState
    print("Fonction de dépard");

    idle = SimpleAnimation(Animated.idle.name);
    handsDown = SimpleAnimation(Animated.hands_down.name);
    handsUp = SimpleAnimation(Animated.Hands_up.name);
    success = SimpleAnimation(Animated.success.name);
    fail = SimpleAnimation(Animated.fail.name);
    lookdownleft = SimpleAnimation(Animated.look_down_left.name);
    lookdownright = SimpleAnimation(Animated.look_down_right.name);
    rootBundle.load("lib/assets/animated_login_character.riv").then((value) {
      final file = RiveFile.import(value);

      final artboart = file.mainArtboard;
      artboart.addController(idle);
      setState(() {
        _artboard = artboart;
      });
    }




    );

    bool listening = false;

    _focusNode.addListener(() {
      if (_focusNode.hasFocus) {
        setState(() {
          listening = true;
        });
      } else {
        addHandsDown();
      }
    });
    super.initState();


  }

  @override
  void dispose() {
    _focusNode.dispose(); // Libérer la mémoire en supprimant le FocusNode
    super.dispose();
  }
  void removeAllController(){
    _artboard!.artboard.removeController(idle);
    _artboard!.artboard.removeController(handsDown);
    _artboard!.artboard.removeController(handsUp);
    _artboard!.artboard.removeController(success);
    _artboard!.artboard.removeController(fail);
    _artboard!.artboard.removeController(lookdownleft);
    _artboard!.artboard.removeController(lookdownright);

  }

  void addIdle(){
    removeAllController();
    _artboard!.artboard.addController(idle);
  }void addHandsUp(){
    removeAllController();
    _artboard!.artboard.addController(handsUp);
  }void addHandsDown(){
    removeAllController();
    _artboard!.artboard.addController(handsDown);
  }void addfail(){
    removeAllController();
    _artboard!.artboard.addController(fail);
  }void addSuccess(){
    removeAllController();
    _artboard!.artboard.addController(success);
  }void addlookdownright(){
    removeAllController();
    _artboard!.artboard.addController(lookdownright);
  }void addlookdownleft(){
    removeAllController();
    _artboard!.artboard.addController(lookdownleft);
  }




  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF1F1B24),

      body: Stack(
        children: [

          _artboard == null?SizedBox():
          Rive(artboard: _artboard!),
          Column(
            children: [

              Expanded(
                child: ListView.builder(
                  controller: _scrollController, // Controller pour le scroll
                  itemCount: _messages.length,
                  itemBuilder: (context, index) {
                    final message = _messages[index];
                    final isUserMessage = message['role'] == 'user';
                    return Align(
                      alignment: isUserMessage
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      child: Container(
                        padding: EdgeInsets.all(12),
                        margin: EdgeInsets.symmetric(vertical: 4, horizontal: 16),
                        decoration: BoxDecoration(
                          color: isUserMessage
                              ? Color(0xFF006CFF)
                              : Color(0xFF37304D),
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(16),
                            topRight: Radius.circular(16),
                            bottomLeft: isUserMessage
                                ? Radius.circular(16)
                                : Radius.circular(0),
                            bottomRight: isUserMessage
                                ? Radius.circular(0)
                                : Radius.circular(16),
                          ),
                        ),
                        child: Text(
                          message['message']!,
                          style: TextStyle(
                            color: Colors.white,
                            fontFamily: 'Roboto',
                            fontSize: 16,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              Container(
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Color(0xFF27212E),
                  border: Border(
                    top: BorderSide(color: Colors.grey[700]!, width: 0.5),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        focusNode: _focusNode,
                        controller: _textController,
                        style: TextStyle(
                          color: Colors.white,
                          fontFamily: 'Roboto',
                        ),
                        onChanged: (_){
                          addHandsDown();
                        },
                        decoration: InputDecoration(
                          hintText: 'Tapez votre message...',
                          hintStyle: TextStyle(
                            color: Colors.grey[500],
                            fontFamily: 'Roboto',
                          ),
                          filled: true,
                          fillColor: Color(0xFF2E2A35),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        onSubmitted: (_) {
                          correctionOrthographe(_textController.text);
                        },
                      ),
                    ),
                    SizedBox(width: 10),
                    FloatingActionButton(
                      onPressed: () {
                        if (!_isLoading) {
                          addIdle();
                          if(_textController.text ==""){
                            addfail();

                            Future<void> attendreDeuxSecondes() async {
                              await Future.delayed(Duration(seconds: 2));
                              print("ok");
                              addIdle();
                            }

                            attendreDeuxSecondes();


                            showTopSnackBar(
                              Overlay.of(context),
                              CustomSnackBar.error(
                                message:
                                "Ce champ ne peut pas être vide, entrez du texte s'il vous plait!",
                              ),
                            );
                          }else{
                            addIdle();
                            correctionOrthographe(_textController.text);
                          }

                        }
                      },
                      backgroundColor: Colors.orange,
                      child: Icon(Icons.send),
                    ),
                    Container(
                      child: (_isLoading)
                          ? Align(
                        alignment: Alignment.centerLeft,
                        child: Container(
                          padding: EdgeInsets.all(12),
                          margin:
                          EdgeInsets.symmetric(vertical: 4, horizontal: 16),
                          child: LoadingAnimationWidget.horizontalRotatingDots(
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                      )
                          : Container(), // ou autre contenu lorsque la condition est fausse
                    )
                  ],
                ),
              ),
            ],
          ),

        ],
      ),
    );
  }
}
