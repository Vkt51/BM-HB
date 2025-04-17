import 'package:flutter/material.dart';
import 'dart:math'; // Für die Zufallsauswahl

// Importiere den nächsten Screen
import 'answer_ranking_screen.dart';

class QuestionScreen extends StatefulWidget {
  final String userName;
  final int numberOfQuestions; // Gesamtzahl der Fragen
  final List<String> participants;
  final int currentQuestionIndex; // Index der aktuellen Frage (0-basiert)

  const QuestionScreen({
    super.key,
    required this.userName,
    required this.numberOfQuestions,
    required this.participants,
    this.currentQuestionIndex = 0, // Standardmäßig die erste Frage (Index 0)
  });

  @override
  State<QuestionScreen> createState() => _QuestionScreenState();
}

class _QuestionScreenState extends State<QuestionScreen> {
  // --- Die Datenbank mit Fragen ---
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

  // State Variablen
  List<String> _randomOptions = []; // Die 3 zufälligen Fragen
  int? _selectedOptionIndex; // Index der ausgewählten zufälligen Frage (0, 1, 2)
  final _customQuestionController = TextEditingController();
  String? _finalSelectedQuestion; // Die letztendlich ausgewählte Frage (Text)
  bool _isCustomQuestionFocused = false; // Trackt, ob das Textfeld fokussiert ist

  @override
  void initState() {
    super.initState();
    _selectRandomQuestions();
    // Listener hinzufügen, um zu erkennen, wenn der Benutzer tippt
    _customQuestionController.addListener(_onCustomQuestionChanged);
  }

  void _selectRandomQuestions() {
    final random = Random();
    // Sicherstellen, dass wir nicht mehr Fragen auswählen wollen, als verfügbar sind
    final count = min(3, _allQuestions.length);
    final Set<String> selected = {}; // Set verhindert Duplikate

    while (selected.length < count) {
      final randomIndex = random.nextInt(_allQuestions.length);
      selected.add(_allQuestions[randomIndex]);
    }
    setState(() {
      _randomOptions = selected.toList();
      _selectedOptionIndex = null; // Auswahl zurücksetzen
      _finalSelectedQuestion = null; // Auswahl zurücksetzen
    });
  }

  // Wird aufgerufen, wenn der Benutzer in das Textfeld tippt
  void _onCustomQuestionChanged() {
     if (_customQuestionController.text.isNotEmpty && _isCustomQuestionFocused) {
      setState(() {
        _selectedOptionIndex = null; // Zufällige Auswahl aufheben
        _finalSelectedQuestion = _customQuestionController.text.trim();
      });
    } else if (_customQuestionController.text.isEmpty && _selectedOptionIndex == null) {
       // Wenn das Feld geleert wird und keine Zufallsoption gewählt ist
       setState(() {
          _finalSelectedQuestion = null;
       });
    }
  }

  // Wird aufgerufen, wenn eine der Zufallsfragen ausgewählt wird
  void _selectRandomOption(int index) {
    setState(() {
      _selectedOptionIndex = index;
      _customQuestionController.clear(); // Eigenes Feld leeren
       _isCustomQuestionFocused = false; // Fokus-Tracking zurücksetzen
      _finalSelectedQuestion = _randomOptions[index];
      // Tastatur ausblenden, falls sie offen war
      FocusScope.of(context).unfocus();
    });
  }

   // Navigiert zum nächsten Screen (Antworten-Ranking)
  void _navigateToAnswerScreen() {
    if (_finalSelectedQuestion == null || _finalSelectedQuestion!.isEmpty) {
      // Sollte nicht passieren, wenn der Button korrekt aktiviert/deaktiviert wird,
      // aber als Sicherheitsnetz.
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Bitte wähle oder gib eine Frage ein!')),
      );
      return;
    }

    print('Frage ausgewählt: "$_finalSelectedQuestion"');
    print('Aktueller Frageindex (0-basiert): ${widget.currentQuestionIndex}');

    Navigator.push( // Normaler Push, um zurück zu können falls nötig? Oder pushReplacement?
      context,
      MaterialPageRoute(
        builder: (context) => AnswerRankingScreen(
          userName: widget.userName,
          numberOfQuestions: widget.numberOfQuestions,
          currentQuestionIndex: widget.currentQuestionIndex,
          participants: widget.participants,
          chosenQuestion: _finalSelectedQuestion!,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _customQuestionController.removeListener(_onCustomQuestionChanged);
    _customQuestionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Zustand für den "Weiter"-Button
    final bool isNextButtonEnabled = _finalSelectedQuestion != null && _finalSelectedQuestion!.isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        // Zeigt "Frage 1 von 3", "Frage 2 von 3" etc. an
        title: Text('Frage ${widget.currentQuestionIndex + 1} von ${widget.numberOfQuestions}'),
        backgroundColor: Colors.pinkAccent,
        automaticallyImplyLeading: false, // Keinen Zurück-Pfeil
      ),
      body: GestureDetector( // Um Tastatur bei Klick daneben auszublenden
         onTap: () => FocusScope.of(context).unfocus(),
        child: SingleChildScrollView( // Ermöglicht Scrollen, wenn Inhalt zu lang wird
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

              // --- Zufällige Fragen Optionen ---
              ..._randomOptions.asMap().entries.map((entry) {
                int index = entry.key;
                String question = entry.value;
                bool isSelected = _selectedOptionIndex == index;

                return Card(
                  elevation: isSelected ? 6 : 2, // Hervorheben bei Auswahl
                  color: isSelected ? Colors.pink.shade100 : Colors.white, // Hintergrund bei Auswahl
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
              }).toList(), // Muss zu einer Liste gemacht werden

              const SizedBox(height: 20),
              Text(
                '--- Oder ---',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey.shade600, fontStyle: FontStyle.italic),
              ),
              const SizedBox(height: 20),

              // --- Eigene Frage Eingabefeld ---
              Focus( // Um Fokus-Änderungen zu erkennen
                 onFocusChange: (hasFocus) {
                   setState(() {
                     _isCustomQuestionFocused = hasFocus;
                     // Wenn Fokus gesetzt wird und Textfeld leer ist, Auswahl aufheben
                     if (hasFocus && _customQuestionController.text.isEmpty) {
                       _selectedOptionIndex = null;
                       _finalSelectedQuestion = null;
                     } else if (hasFocus && _customQuestionController.text.isNotEmpty) {
                        // Wenn Fokus gesetzt wird und Text vorhanden ist, diesen als Auswahl nehmen
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
                  maxLines: 2, // Erlaubt etwas längere Fragen
                ),
              ),
              const SizedBox(height: 40),

              // --- Weiter Button ---
              ElevatedButton.icon(
                icon: const Icon(Icons.arrow_forward_ios, size: 18),
                label: const Text('Weiter zur Antwortrunde'),
                // Button ist nur aktiv, wenn eine Frage ausgewählt oder eingegeben wurde
                onPressed: isNextButtonEnabled ? _navigateToAnswerScreen : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: isNextButtonEnabled ? Colors.green.shade600 : Colors.grey,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                   shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 20), // Platz am Ende
            ],
          ),
        ),
      ),
    );
  }
}