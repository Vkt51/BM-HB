import 'package:flutter/material.dart';
import 'dart:math'; // Für die Zufallsauswahl

// Importiere den nächsten Screen
import 'answer_ranking_screen.dart'; // Stelle sicher, dass dieser Import korrekt ist

class QuestionScreen extends StatefulWidget {
  final String userName;
  final int numberOfQuestions; // Gesamtzahl der Fragen
  final List<String> participants;
  final int currentQuestionIndex; // Index der aktuellen Frage (0-basiert)

  // --- NEU: Parameter für die Raum-ID hinzugefügt ---
  final String roomId;
  // ------------------------------------------------

  const QuestionScreen({
    super.key,
    required this.userName,
    required this.numberOfQuestions,
    required this.participants,
    this.currentQuestionIndex = 0, // Standardmäßig die erste Frage (Index 0)
    // --- NEU: roomId im Konstruktor hinzugefügt ---
    required this.roomId,
    // -------------------------------------------
  });

  @override
  State<QuestionScreen> createState() => _QuestionScreenState();
}

class _QuestionScreenState extends State<QuestionScreen> {
  // --- Die Datenbank mit Fragen (unverändert) ---
  final List<String> _allQuestions = [
    "Wenn ich eine Sonnenliege wäre – wie würdest du dich auf mir breitmachen?",
    "Was ist dein geheimes Talent, das man erst nach Mitternacht zu sehen bekommt?",
    "Du darfst mir mit Sonnencreme eine Botschaft auf den Rücken schreiben – was steht da?",
    "Stell dir vor, wir landen gemeinsam im Whirlpool – wie lange dauert’s, bis du „aus Versehen“ Körperkontakt suchst?",
    "Welcher Drink bringt dich in Flirtlaune – und welcher in Entgleisungsstimmung?",
    "Wenn dein Bett Geschichten erzählen könnte – hätte ich einen Gastauftritt?",
    "Was ziehst du zuerst aus: dein Shirt oder deine Hemmungen?",
    "Lieber ein schmutziger Gedanke oder ein sauberer Flirt?",
    "Wenn ich eine Kugel Eis wäre – an welcher Stelle würdest du anfangen zu schlecken?",
    "Welche Ausrede würdest du benutzen, um mit mir allein aufs Hotelzimmer zu verschwinden?",
    "Du darfst eine Challenge vorschlagen: Wahrheit oder Pflicht – was traust du dich?",
    "Stell dir vor, du musst mich verführen, ohne zu reden – wie sieht das aus?",
    "Was würdest du an mir ablecken, wenn’s ein Trinkspiel verlange?",
    "Wenn du mich massieren müsstest, wo fängst du an – und wo hörst du auf?",
    "Welche Stelle an deinem Körper ist am „unerwartetsten empfindlich“?",
    "Was war das Verbotenste, was du je im Urlaub gemacht hast – und würdest du’s mit mir wieder tun?",
    "Was wäre dein Spitzname für mich – nur flüsterbar im Dunkeln?",
    "Wenn wir in der Dusche landen – wer hält das Duschgel und wer rutscht aus?",
    "Welcher Song bringt dich dazu, plötzlich ganz langsam zu tanzen – egal wie voll der Club ist?",
    "Was wär dein Codewort, wenn du diskret andeuten willst: „Ich will jetzt was starten“?",
    "Du darfst eine Minute lang flüstern, was du mit mir anstellen würdest – was sagst du zuerst?",
    "Was an dir sollte ich unbedingt entdecken – aber nur unter vier Augen?",
    "Wenn ich an dir knabbern dürfte wie an einer Ananas – wo sollte ich anfangen?",
    "Was war dein wildester Gedanke, als du mich zum ersten Mal gesehen hast?",
    "In welchem Moment hättest du am liebsten gesagt: „Komm mit, ich zeig dir was“?",
    "Wenn ich dein Badetuch wäre – was würde ich alles mitbekommen?",
    "Was würdest du tun, wenn wir nachts allein am Strand wären – und niemand guckt?",
    "Du darfst mir ein Tattoo machen – wo und was?",
    "Was macht dich heißer: eine gute Zunge oder eine gute Pointe?",
    "Wenn wir zusammen im Aufzug stecken bleiben – was passiert in den ersten 10 Minuten?",
  ];

  // State Variablen (unverändert)
  List<String> _randomOptions = [];
  int? _selectedOptionIndex;
  final _customQuestionController = TextEditingController();
  String? _finalSelectedQuestion;
  bool _isCustomQuestionFocused = false;

  @override
  void initState() {
    super.initState();
    // Die empfangene Raum-ID kann hier verwendet werden (z.B. für Debugging)
    debugPrint("QuestionScreen initialisiert für Raum: ${widget.roomId}");
    _selectRandomQuestions();
    _customQuestionController.addListener(_onCustomQuestionChanged);
  }

  // _selectRandomQuestions (unverändert)
  void _selectRandomQuestions() {
    final random = Random();
    final count = min(3, _allQuestions.length);
    final Set<String> selected = {};

    while (selected.length < count) {
      final randomIndex = random.nextInt(_allQuestions.length);
      selected.add(_allQuestions[randomIndex]);
    }
    setState(() {
      _randomOptions = selected.toList();
      _selectedOptionIndex = null;
      _finalSelectedQuestion = null;
    });
  }

  // _onCustomQuestionChanged (unverändert)
  void _onCustomQuestionChanged() {
     if (_customQuestionController.text.isNotEmpty && _isCustomQuestionFocused) {
      setState(() {
        _selectedOptionIndex = null;
        _finalSelectedQuestion = _customQuestionController.text.trim();
      });
    } else if (_customQuestionController.text.isEmpty && _selectedOptionIndex == null) {
       setState(() {
          _finalSelectedQuestion = null;
       });
    }
  }

  // _selectRandomOption (unverändert)
  void _selectRandomOption(int index) {
    setState(() {
      _selectedOptionIndex = index;
      _customQuestionController.clear();
       _isCustomQuestionFocused = false;
      _finalSelectedQuestion = _randomOptions[index];
      FocusScope.of(context).unfocus();
    });
  }

   // --- ANGEPASST: _navigateToAnswerScreen ---
   // Navigiert zum nächsten Screen (Antworten-Ranking) und übergibt roomId
  void _navigateToAnswerScreen() {
    if (_finalSelectedQuestion == null || _finalSelectedQuestion!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Bitte wähle oder gib eine Frage ein!')),
      );
      return;
    }

    print('Frage ausgewählt: "$_finalSelectedQuestion" für Raum ${widget.roomId}'); // roomId hinzugefügt
    print('Aktueller Frageindex (0-basiert): ${widget.currentQuestionIndex}');

    // WICHTIG: Stelle sicher, dass AnswerRankingScreen auch 'roomId' erwartet!
    // Du musst AnswerRankingScreen wahrscheinlich genauso anpassen wie diesen Screen.
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AnswerRankingScreen(
          userName: widget.userName,
          numberOfQuestions: widget.numberOfQuestions,
          currentQuestionIndex: widget.currentQuestionIndex,
          participants: widget.participants,
          chosenQuestion: _finalSelectedQuestion!,
          // --- NEU: roomId an den nächsten Screen weitergeben ---
          roomId: widget.roomId,
          // ---------------------------------------------------
        ),
      ),
    );
  }
  // -----------------------------------------

  @override
  void dispose() {
    _customQuestionController.removeListener(_onCustomQuestionChanged);
    _customQuestionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isNextButtonEnabled = _finalSelectedQuestion != null && _finalSelectedQuestion!.isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        title: Text('Frage ${widget.currentQuestionIndex + 1} von ${widget.numberOfQuestions}'),
        // Optional: Raum-ID im Titel für Debugging anzeigen
        // title: Text('Frage ${widget.currentQuestionIndex + 1}/${widget.numberOfQuestions} (Raum: ${widget.roomId})'),
        backgroundColor: Colors.pinkAccent,
        automaticallyImplyLeading: false, // Keinen Zurück-Pfeil
      ),
      body: GestureDetector(
         onTap: () => FocusScope.of(context).unfocus(),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Text(
                'Wähle eine Frage für die Anwärter:',
                style: Theme.of(context).textTheme.titleLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 25),

              // Zufällige Fragen Optionen (unverändert)
              ..._randomOptions.asMap().entries.map((entry) {
                int index = entry.key;
                String question = entry.value;
                bool isSelected = _selectedOptionIndex == index;

                return Card(
                  elevation: isSelected ? 6 : 2,
                  color: isSelected ? Colors.pink.shade100 : Colors.white,
                  margin: const EdgeInsets.symmetric(vertical: 6.0),
                  child: ListTile(
                    leading: Icon(
                      isSelected ? Icons.check_circle : Icons.radio_button_unchecked,
                      color: isSelected ? Colors.pink : Colors.grey,
                    ),
                    title: Text(question),
                    onTap: () => _selectRandomOption(index),
                  ),
                );
              }).toList(),

              const SizedBox(height: 20),
              Text(
                '--- Oder ---',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey.shade600, fontStyle: FontStyle.italic),
              ),
              const SizedBox(height: 20),

              // Eigene Frage Eingabefeld (unverändert)
              Focus(
                 onFocusChange: (hasFocus) {
                   setState(() {
                     _isCustomQuestionFocused = hasFocus;
                     if (hasFocus && _customQuestionController.text.isEmpty) {
                       _selectedOptionIndex = null;
                       _finalSelectedQuestion = null;
                     } else if (hasFocus && _customQuestionController.text.isNotEmpty) {
                        _selectedOptionIndex = null;
                        _finalSelectedQuestion = _customQuestionController.text.trim();
                     }
                   });
                 },
                child: TextFormField(
                  controller: _customQuestionController,
                  decoration: const InputDecoration(
                    labelText: 'Deine eigene Frage',
                    hintText: 'Sei kreativ...',
                    border: OutlineInputBorder(),
                    suffixIcon: Icon(Icons.edit),
                  ),
                  maxLines: 2,
                ),
              ),
              const SizedBox(height: 40),

              // Weiter Button (unverändert)
              ElevatedButton.icon(
                icon: const Icon(Icons.arrow_forward_ios, size: 18),
                label: const Text('Weiter zur Antwortrunde'),
                onPressed: isNextButtonEnabled ? _navigateToAnswerScreen : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: isNextButtonEnabled ? Colors.green.shade600 : Colors.grey,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                   shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}