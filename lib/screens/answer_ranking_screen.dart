import 'package:flutter/material.dart';
// Füge hier ggf. Firestore-Imports hinzu, wenn du echte Antworten lädst
// import 'package:cloud_firestore/cloud_firestore.dart';

// Importiere die nächsten Screens
import 'question_screen.dart'; // Stellt sicher, dass QuestionScreen roomId akzeptiert
import 'results_screen.dart'; // WICHTIG: ResultsScreen muss auch roomId akzeptieren!

class AnswerRankingScreen extends StatefulWidget {
  final String userName;
  final int numberOfQuestions;
  final int currentQuestionIndex; // 0-basiert
  final List<String> participants; // Namen: ['Jacqueline', 'Petra', 'Angelika Baerbock']
  final String chosenQuestion;

  // --- NEU: Parameter für die Raum-ID hinzugefügt ---
  final String roomId;
  // ------------------------------------------------

  const AnswerRankingScreen({
    super.key,
    required this.userName,
    required this.numberOfQuestions,
    required this.currentQuestionIndex,
    required this.participants,
    required this.chosenQuestion,
    // --- NEU: roomId im Konstruktor hinzugefügt ---
    required this.roomId,
    // -------------------------------------------
  });

  @override
  State<AnswerRankingScreen> createState() => _AnswerRankingScreenState();
}

class _AnswerRankingScreenState extends State<AnswerRankingScreen> {
  // Liste, die die aktuelle Reihenfolge der Antworten speichert.
  // WICHTIG: Das muss später durch echte Daten aus Firestore ersetzt werden.
  late List<Map<String, String>> _rankedAnswers = []; // Initial leer
  bool _isLoadingAnswers = true; // Zum Anzeigen eines Ladeindikators

  @override
  void initState() {
    super.initState();
    // Raum-ID beim Initialisieren loggen
    debugPrint("AnswerRankingScreen initialisiert für Raum: ${widget.roomId}, Frage: ${widget.currentQuestionIndex + 1}");

    // Initialisiere die Liste mit den (Dummy-)Antworten
    _loadAndInitializeAnswers(); // Geändert zu einer async-freundlichen Methode
  }

  // --- Platzhalter-Methode zum Laden von Antworten ---
  // TODO: Ersetze diese Methode durch deine Firestore-Logik
  void _loadAndInitializeAnswers() {
    setState(() {
      _isLoadingAnswers = true;
    });
    // --- HIER DEINE FIRESTORE LOGIK ZUM LADEN DER ANTWORTEN ---
    // Beispiel:
    // FirebaseFirestore.instance
    //     .collection('rooms').doc(widget.roomId)
    //     .collection('answers').doc('question_${widget.currentQuestionIndex}') // Annahme
    //     .get()
    //     .then((snapshot) {
    //       if (snapshot.exists && mounted) {
    //         Map<String, dynamic> answersData = snapshot.data()!;
    //         // Baue die _rankedAnswers Liste aus den Firestore-Daten auf
    //         _rankedAnswers = widget.participants.map((name) {
    //           return {
    //              'name': name,
    //              'answer': answersData[name] ?? 'Keine Antwort abgegeben', // Hole Antwort anhand des Namens
    //           };
    //         }).toList();
    //         setState(() { _isLoadingAnswers = false; });
    //       } else {
    //         // Fallback oder Fehlerbehandlung
    //         _initializeDummyAnswers(); // Nutze Dummies, wenn nichts gefunden wurde
    //         setState(() { _isLoadingAnswers = false; });
    //       }
    //     }).catchError((error) {
    //        print("Fehler beim Laden der Antworten: $error");
    //        _initializeDummyAnswers(); // Dummies bei Fehler
    //        setState(() { _isLoadingAnswers = false; });
    //     });

    // --- START DUMMY LOGIK (ENTFERNEN, WENN FIRESTORE IMPLEMENTIERT IST) ---
    // Dummy-Antworten basierend auf dem Namen zuordnen
    Map<String, String> dummyAnswers = {
      'Jacqueline': 'Immer schön cremig bleiben!',
      'Petra': 'Hauptsache, der Sangria knallt.',
      'Angelika Baerbock': 'Das Völkerrecht gilt auch am Strand!',
    };
     // Simuliere eine kurze Ladezeit
    Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) { // Prüfe, ob Widget noch da ist
           _rankedAnswers = widget.participants.map((name) {
            return {
              'name': name,
              'answer': dummyAnswers[name] ?? 'Keine Antwort erhalten', // Fallback
            };
          }).toList();
          setState(() { _isLoadingAnswers = false; }); // Ladevorgang beenden
           print("AnswerRankingScreen initState: Initialisierte (Dummy) Antworten: $_rankedAnswers");
        }
    });
     // --- ENDE DUMMY LOGIK ---
  }
  // ----------------------------------------------------


  // Funktion für Drag & Drop (unverändert)
  void _onReorder(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) {
        newIndex -= 1;
      }
      // Stelle sicher, dass _rankedAnswers initialisiert ist
      if (_rankedAnswers.isNotEmpty) {
        final Map<String, String> item = _rankedAnswers.removeAt(oldIndex);
        _rankedAnswers.insert(newIndex, item);
        print("AnswerRankingScreen onReorder: Neue Reihenfolge: $_rankedAnswers");
      }
    });
  }

  // --- ANGEPASST: _goToNextStep ---
  // Übergibt roomId an die nächsten Screens
  void _goToNextStep() {
    print("--- AnswerRankingScreen: _goToNextStep gestartet (Raum: ${widget.roomId}) ---");
    print('Aktuelle Frage (Index): ${widget.currentQuestionIndex}');
    print('Anzahl Fragen: ${widget.numberOfQuestions}');
    print('Gewählte Reihenfolge: $_rankedAnswers');

    // TODO: Hier sollte die gewählte Reihenfolge (_rankedAnswers)
    // für die aktuelle Frage (widget.currentQuestionIndex)
    // in Firestore gespeichert werden (z.B. unter dem Raum oder User).

    int nextQuestionIndex = widget.currentQuestionIndex + 1;

    // Prüfen, ob es die letzte Frage war
    if (nextQuestionIndex < widget.numberOfQuestions) {
      // Zur nächsten Frage navigieren
      print('Navigiere zur nächsten Frage (Index $nextQuestionIndex) für Raum ${widget.roomId}');
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => QuestionScreen(
            userName: widget.userName,
            numberOfQuestions: widget.numberOfQuestions,
            participants: widget.participants,
            currentQuestionIndex: nextQuestionIndex, // Nächsten Index übergeben
            // --- roomId weitergeben ---
            roomId: widget.roomId,
            // ------------------------
          ),
        ),
      );
    } else {
      // Zur Ergebnis-Seite navigieren
      print('Letzte Frage beantwortet. Navigiere zu den Ergebnissen für Raum ${widget.roomId}.');
      // WICHTIG: Stelle sicher, dass ResultsScreen roomId akzeptiert!
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => ResultsScreen(
            userName: widget.userName,
            numberOfQuestions: widget.numberOfQuestions,
            participants: widget.participants,
            // collectedRankings werden hier NICHT übergeben, da ResultsScreen sie simuliert/holt
            // --- roomId weitergeben ---
            roomId: widget.roomId,
            // ------------------------
          ),
        ),
      );
    }
     print("--- AnswerRankingScreen: _goToNextStep beendet ---");
  }
  // -----------------------------------

  @override
  Widget build(BuildContext context) {
     print("AnswerRankingScreen build: Baue UI für Raum ${widget.roomId}, Frage ${widget.currentQuestionIndex + 1}");
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
            // Angezeigte Frage (unverändert)
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

            // --- Die Drag-and-Drop Liste ---
            Expanded(
              // Zeige Ladeindikator, während Antworten geladen werden
              child: _isLoadingAnswers
                  ? const Center(child: CircularProgressIndicator(color: Colors.pinkAccent))
                  : ReorderableListView(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      children: <Widget>[
                         // Rendere die Liste nur, wenn sie nicht leer ist
                         if (_rankedAnswers.isNotEmpty)
                           for (int index = 0; index < _rankedAnswers.length; index += 1)
                            Card(
                              // Verwende eine Kombination aus Name und Antwort für den Key, falls Namen nicht einzigartig sind
                              key: ValueKey('${_rankedAnswers[index]['name']}_${_rankedAnswers[index]['answer']}'),
                              elevation: 3,
                              margin: const EdgeInsets.symmetric(vertical: 6.0),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)), // Rundere Ecken
                              child: ListTile(
                                leading: CircleAvatar(
                                   backgroundColor: Colors.pink.shade300,
                                   foregroundColor: Colors.white,
                                   child: Text('${index + 1}', style: const TextStyle(fontWeight: FontWeight.bold)), // Rang anzeigen
                                ),
                                title: Text(
                                  _rankedAnswers[index]['name'] ?? 'Unbekannt',
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                                subtitle: Text(
                                   _rankedAnswers[index]['answer'] ?? 'Keine Antwort',
                                ),
                                trailing: ReorderableDragStartListener(
                                   index: index,
                                   child: const Icon(Icons.drag_handle, color: Colors.grey),
                                ),
                              ),
                            )
                          // Zeige eine Nachricht an, wenn keine Antworten vorhanden sind (nach dem Laden)
                         else if (!_isLoadingAnswers)
                             const Center(child: Text('Keine Antworten zum Anzeigen gefunden.'))

                      ],
                      onReorder: _onReorder,
                    ),
            ), // Ende Expanded ReorderableListView

            const SizedBox(height: 20),

            // --- Weiter Button (unverändert in der Logik, aber beachte isLoadingAnswers) ---
            ElevatedButton(
              // Deaktiviere Button, während Antworten laden
              onPressed: _isLoadingAnswers ? null : _goToNextStep,
              style: ElevatedButton.styleFrom(
                backgroundColor: _isLoadingAnswers ? Colors.grey : Colors.green.shade600, // Farbe anpassen
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 15),
                textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: _isLoadingAnswers
                   ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3))
                   : Text(
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