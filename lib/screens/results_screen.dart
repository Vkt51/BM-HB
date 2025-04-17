import 'package:flutter/material.dart';
import 'dart:math'; // Für Beispiel-Daten Generierung

// Importiere den Start-Screen für "Neues Spiel"
import 'home_screen.dart';

class ResultsScreen extends StatelessWidget {
  final String userName;
  final int numberOfQuestions; // Wie viele Fragen wurden gestellt?
  final List<String> participants; // Namen der Teilnehmer

  // !! WICHTIG: Dies ist eine Simulation !!
  // In einer echten App müssten die 'collectedRankings'
  // übergeben oder aus einem State gelesen werden.
  final List<List<Map<String, String>>> collectedRankings;

  // Konstruktor, der die simulierten Daten erstellt
  ResultsScreen({
    super.key,
    required this.userName,
    required this.numberOfQuestions,
    required this.participants,
  }) : collectedRankings = _generateSimulatedRankings(numberOfQuestions, participants);


  // --- Hilfsfunktion zur Generierung SIMULIERTER Rankings ---
  // Erzeugt zufällige Rankings für jede Frage, nur für Demo-Zwecke!
  static List<List<Map<String, String>>> _generateSimulatedRankings(int numQuestions, List<String> participantNames) {
     print("--- GENERIERE SIMULIERTE RANKINGS (NUR ZUR DEMO) ---");
     final random = Random();
     List<List<Map<String, String>>> allRankings = [];

     // Dummy-Antworten pro Person (könnten auch zufälliger sein)
     Map<String, List<String>> possibleAnswers = {
       'Jacqueline': ['Ja klar!', 'Auf jeden Fall!', 'Immer doch!', 'Logisch!', 'Schwanz schwanz'],
       'Petra': ['Vielleicht...', 'Mal sehen.', 'Wer weiß?', 'Möglich.', 'Gott ist groß'],
       'Angelika Baerbock': ['Niemals!', 'Eher nicht.', 'Glaube kaum.', 'Unwahrscheinlich.', 'Ich liebe das Völkerrecht'],
     };

     for (int i = 0; i < numQuestions; i++) {
       // Mische die Teilnehmer für diese Runde zufällig
       List<String> shuffledNames = List.from(participantNames)..shuffle(random);
       List<Map<String, String>> questionRanking = [];
       for (String name in shuffledNames) {
         // Wähle eine zufällige Antwort für diese Person
         String answer = possibleAnswers[name]?[random.nextInt(possibleAnswers[name]!.length)] ?? 'Keine Antwort';
         questionRanking.add({'name': name, 'answer': answer});
       }
       allRankings.add(questionRanking);
     }
     print("--- Simulierte Rankings erstellt: $allRankings ---");
     return allRankings;
  }
  // --- Ende Simulations-Funktion ---


  // --- Berechnet die Endpunktzahl basierend auf den Rankings ---
  Map<String, int> _calculateScores() {
    // Map zum Speichern der Punkte pro Teilnehmer
    Map<String, int> scores = { for (var p in participants) p : 0 };

    // Punktevergabe: 3 Punkte für Platz 1, 2 für Platz 2, 1 für Platz 3
    const int pointsRank1 = 3;
    const int pointsRank2 = 2;
    const int pointsRank3 = 1;

    // Gehe durch die Rankings jeder Frage
    for (List<Map<String, String>> questionRanking in collectedRankings) {
      if (questionRanking.isNotEmpty) {
        // Punkte für Platz 1
        scores[questionRanking[0]['name']!] = (scores[questionRanking[0]['name']!] ?? 0) + pointsRank1;
      }
      if (questionRanking.length > 1) {
        // Punkte für Platz 2
         scores[questionRanking[1]['name']!] = (scores[questionRanking[1]['name']!] ?? 0) + pointsRank2;
      }
       if (questionRanking.length > 2) {
        // Punkte für Platz 3
         scores[questionRanking[2]['name']!] = (scores[questionRanking[2]['name']!] ?? 0) + pointsRank3;
      }
      // Bei mehr als 3 Teilnehmern müsste die Logik erweitert werden
    }
    print("--- Berechnete Scores: $scores ---");
    return scores;
  }


  @override
  Widget build(BuildContext context) {
    // Berechne die Scores
    final scores = _calculateScores();

    // Sortiere die Teilnehmer nach Punkten (absteigend)
    // Wandle die Map in eine Liste von MapEntries um und sortiere sie
    final List<MapEntry<String, int>> sortedScores = scores.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value)); // b vs a für absteigend

    print("--- Sortierte Scores: $sortedScores ---");

    String winnerName = sortedScores.isNotEmpty ? sortedScores[0].key : "Niemand";

    return Scaffold(
      appBar: AppBar(
        title: Text('Herzblatt Ergebnis für $userName'),
        backgroundColor: Colors.pinkAccent,
        automaticallyImplyLeading: false, // Kein Zurück
      ),
      body: Container( // Hintergrund hinzufügen?
         decoration: BoxDecoration(
           gradient: LinearGradient(
             begin: Alignment.topCenter,
             end: Alignment.bottomCenter,
             colors: [Colors.pink.shade50, Colors.white],
           ),
         ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center, // Zentriert vertikal
            crossAxisAlignment: CrossAxisAlignment.stretch, // Streckt Elemente horizontal
            children: [
              Text(
                '✨ And the winner is... ✨',
                style: TextStyle(
                   fontSize: 26,
                   fontWeight: FontWeight.bold,
                   color: Colors.pink.shade700,
                   shadows: const [ Shadow(blurRadius: 2.0, color: Colors.black26, offset: Offset(1, 1))]
                 ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 15),
              // Gewinner-Anzeige
              if (sortedScores.isNotEmpty)
                Card(
                   color: Colors.pink.shade100,
                   elevation: 5,
                   shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                   child: Padding(
                     padding: const EdgeInsets.all(16.0),
                     child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                           const Icon(Icons.favorite, color: Colors.red, size: 30),
                           const SizedBox(width: 15),
                           Text(
                             winnerName,
                             style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.black87),
                           ),
                            const SizedBox(width: 15),
                           const Icon(Icons.favorite, color: Colors.red, size: 30),
                        ],
                     ),
                   ),
                 )
              else
                 const Text("Keine Ergebnisse vorhanden.", textAlign: TextAlign.center),

              const SizedBox(height: 30),
              Text(
                'Deine Herzblatt-Rangliste:',
                style: Theme.of(context).textTheme.titleLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 15),

              // Gesamte Rangliste anzeigen
              Expanded( // Nimmt verfügbaren Platz
                child: ListView.builder(
                  shrinkWrap: true, // Verhindert unendliche Höhe in Column
                  itemCount: sortedScores.length,
                  itemBuilder: (context, index) {
                    final entry = sortedScores[index];
                    final rank = index + 1;
                    final isWinner = index == 0;

                    return Card(
                      elevation: isWinner ? 4 : 2,
                      margin: const EdgeInsets.symmetric(vertical: 7.0, horizontal: 10.0),
                       shape: RoundedRectangleBorder(
                           borderRadius: BorderRadius.circular(10),
                           side: isWinner ? const BorderSide(color: Colors.pinkAccent, width: 1.5) : BorderSide.none
                       ),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: isWinner ? Colors.pink : Colors.grey.shade400,
                          child: Text(
                            '$rank',
                            style: TextStyle(
                               color: Colors.white,
                               fontWeight: isWinner ? FontWeight.bold : FontWeight.normal
                           ),
                          ),
                        ),
                        title: Text(
                          entry.key, // Name des Teilnehmers
                           style: TextStyle(
                               fontSize: 18,
                               fontWeight: isWinner ? FontWeight.bold : FontWeight.normal
                           ),
                        ),
                        trailing: Text(
                          '${entry.value} Punkte', // Punktzahl
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.pink.shade700,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ), // Ende Expanded ListView

              const SizedBox(height: 30),

              // Button zum Neustarten
              ElevatedButton.icon(
                 icon: const Icon(Icons.refresh),
                 label: const Text('Neues Spiel starten'),
                 onPressed: () {
                   // Geht zurück zum allerersten Screen (HomeScreen) in der Navigationshistorie
                   Navigator.of(context).pushAndRemoveUntil(
                       MaterialPageRoute(builder: (context) => const HomeScreen()),
                       (Route<dynamic> route) => false, // Entfernt alle vorherigen Routes
                   );
                 },
                 style: ElevatedButton.styleFrom(
                   backgroundColor: Colors.pinkAccent,
                   foregroundColor: Colors.white,
                   padding: const EdgeInsets.symmetric(vertical: 15),
                   textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                 ),
               )
            ],
          ),
        ),
      ),
    );
  }
}