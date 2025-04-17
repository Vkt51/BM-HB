import 'package:flutter/material.dart';

// Importiere die nächsten Screens
import 'question_screen.dart';
import 'results_screen.dart';

class AnswerRankingScreen extends StatefulWidget {
  final String userName;
  final int numberOfQuestions;
  final int currentQuestionIndex; // 0-basiert
  final List<String> participants; // Namen: ['Jacqueline', 'Petra', 'Angelika Baerbock']
  final String chosenQuestion;

  const AnswerRankingScreen({
    super.key,
    required this.userName,
    required this.numberOfQuestions,
    required this.currentQuestionIndex,
    required this.participants,
    required this.chosenQuestion,
  });

  @override
  State<AnswerRankingScreen> createState() => _AnswerRankingScreenState();
}

class _AnswerRankingScreenState extends State<AnswerRankingScreen> {
  // Liste, die die aktuelle Reihenfolge der Antworten speichert.
  late List<Map<String, String>> _rankedAnswers;

  @override
  void initState() {
    super.initState();
    // Initialisiere die Liste mit den Dummy-Antworten
    _initializeAnswers();
  }

  void _initializeAnswers() {
    // Dummy-Antworten basierend auf dem Namen zuordnen
    Map<String, String> dummyAnswers = {
      'Jacqueline': 'schwanz schwanz',
      'Petra': 'gott ist groß',
      'Angelika Baerbock': 'ich liebe das völkerrecht',
    };

    // Stelle sicher, dass wir die übergebene Teilnehmerliste verwenden
    _rankedAnswers = widget.participants.map((name) {
      return {
        'name': name,
        'answer': dummyAnswers[name] ?? 'Keine Antwort erhalten', // Fallback
      };
    }).toList();
     print("AnswerRankingScreen initState: Initialisierte Antworten: $_rankedAnswers"); // Debug Print
  }

  // Funktion für Drag & Drop
  void _onReorder(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) {
        newIndex -= 1;
      }
      final Map<String, String> item = _rankedAnswers.removeAt(oldIndex);
      _rankedAnswers.insert(newIndex, item);
       print("AnswerRankingScreen onReorder: Neue Reihenfolge: $_rankedAnswers"); // Debug Print
    });
  }

  void _goToNextStep() {
    print("--- AnswerRankingScreen: _goToNextStep gestartet ---"); // Debug Print
    print('Aktuelle Frage (Index): ${widget.currentQuestionIndex}');
    print('Anzahl Fragen: ${widget.numberOfQuestions}');
    print('Gewählte Reihenfolge: $_rankedAnswers');

    int nextQuestionIndex = widget.currentQuestionIndex + 1;

    // Prüfen, ob es die letzte Frage war
    if (nextQuestionIndex < widget.numberOfQuestions) {
      // Zur nächsten Frage navigieren
      print('Navigiere zur nächsten Frage (Index $nextQuestionIndex)');
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => QuestionScreen(
            userName: widget.userName,
            numberOfQuestions: widget.numberOfQuestions,
            participants: widget.participants,
            currentQuestionIndex: nextQuestionIndex, // Nächsten Index übergeben
          ),
        ),
      );
    } else {
      // Zur Ergebnis-Seite navigieren
      print('Letzte Frage beantwortet. Navigiere zu den Ergebnissen.');
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => ResultsScreen( // Hier wird ResultsScreen aufgerufen
            userName: widget.userName,
            numberOfQuestions: widget.numberOfQuestions, // Wird benötigt für Simulation
            participants: widget.participants,     // Wird benötigt für Simulation/Scores
            // collectedRankings werden hier NICHT übergeben, da ResultsScreen sie simuliert
          ),
        ),
      );
    }
     print("--- AnswerRankingScreen: _goToNextStep beendet ---"); // Debug Print
  }

  @override
  Widget build(BuildContext context) {
     print("AnswerRankingScreen build: Baue UI für Frage ${widget.currentQuestionIndex + 1}"); // Debug Print
    return Scaffold(
      appBar: AppBar(
        title: Text('Antworten Frage ${widget.currentQuestionIndex + 1}/${widget.numberOfQuestions}'),
        backgroundColor: Colors.pinkAccent,
         automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            // Angezeigte Frage
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Text(
                  '"${widget.chosenQuestion}"',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(fontStyle: FontStyle.italic),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Bringe die Antworten in deine bevorzugte Reihenfolge (Beste oben):',
              style: Theme.of(context).textTheme.titleSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 15),

            // Die Drag-and-Drop Liste
            Expanded(
              child: ReorderableListView(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                children: <Widget>[
                  // Prüfen ob _rankedAnswers initialisiert wurde und nicht leer ist
                  if (_rankedAnswers != null)
                     for (int index = 0; index < _rankedAnswers.length; index += 1)
                      Card(
                        key: ValueKey(_rankedAnswers[index]['name']), // Eindeutiger Key
                        elevation: 3,
                        margin: const EdgeInsets.symmetric(vertical: 6.0),
                        child: ListTile(
                          leading: CircleAvatar(
                             backgroundColor: Colors.pink.shade300,
                             foregroundColor: Colors.white,
                             child: Text('${index + 1}'),
                          ),
                          title: Text(
                            // Sicherstellen, dass Name nicht null ist
                            _rankedAnswers[index]['name'] ?? 'Unbekannt',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                             // Sicherstellen, dass Antwort nicht null ist
                             _rankedAnswers[index]['answer'] ?? 'Keine Antwort',
                          ),
                          trailing: ReorderableDragStartListener(
                             index: index,
                             child: const Icon(Icons.drag_handle, color: Colors.grey),
                          ),
                        ),
                      )
                  else
                     const Center(child: CircularProgressIndicator()), // Zeige Ladeanzeige, wenn Daten noch nicht da sind
                ],
                onReorder: _onReorder,
              ),
            ), // Ende Expanded ReorderableListView

            const SizedBox(height: 20),

            // --- Weiter Button ---
            ElevatedButton(
              onPressed: _goToNextStep,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green.shade600,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 15),
                textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Text(
                 (widget.currentQuestionIndex + 1 < widget.numberOfQuestions)
                     ? 'Weiter zur nächsten Frage'
                     : 'Zur Auswertung'
              ),
            ),
          ],
        ),
      ),
    );
  }
}