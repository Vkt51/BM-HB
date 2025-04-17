import 'package:flutter/material.dart';
import 'dart:math'; // Für Beispiel-Daten Generierung

// Importiere den Start-Screen für "Neues Spiel"
import 'home_screen.dart'; // Stelle sicher, dass dieser Import korrekt ist

class ResultsScreen extends StatelessWidget {
  final String userName;
  final int numberOfQuestions; // Wie viele Fragen wurden gestellt?
  final List<String> participants; // Namen der Teilnehmer

  // --- NEU: Parameter für die Raum-ID hinzugefügt ---
  final String roomId;
  // ------------------------------------------------

  // !! WICHTIG: Dies ist eine Simulation !!
  // In einer echten App müssten die 'collectedRankings'
  // übergeben oder aus Firestore basierend auf 'roomId' gelesen werden.
  final List<List<Map<String, String>>> collectedRankings;

  // --- ANGEPASSTER KONSTRUKTOR ---
  // Nimmt jetzt auch roomId entgegen
  ResultsScreen({
    super.key,
    required this.userName,
    required this.numberOfQuestions,
    required this.participants,
    // --- NEU: roomId im Konstruktor ---
    required this.roomId,
    // ------------------------------
    // Die Simulation wird weiterhin hier aufgerufen, ABER in einer echten App
    // würde man die Daten wahrscheinlich basierend auf roomId laden, nicht hier generieren.
  }) : collectedRankings = _generateSimulatedRankings(numberOfQuestions, participants) {
    // Logge die empfangene Raum-ID
    debugPrint("ResultsScreen initialisiert für Raum: $roomId");
  }
  // -----------------------------


  // --- Hilfsfunktion zur Generierung SIMULIERTER Rankings (unverändert) ---
  // Erzeugt zufällige Rankings für jede Frage, nur für Demo-Zwecke!
  static List<List<Map<String, String>>> _generateSimulatedRankings(int numQuestions, List<String> participantNames) {
     print("--- GENERIERE SIMULIERTE RANKINGS (NUR ZUR DEMO) ---");
     final random = Random();
     List<List<Map<String, String>>> allRankings = [];

     Map<String, List<String>> possibleAnswers = {
       'Jacqueline': ['Ja klar!', 'Auf jeden Fall!', 'Immer doch!', 'Logisch!', 'Schwanz schwanz'],
       'Petra': ['Vielleicht...', 'Mal sehen.', 'Wer weiß?', 'Möglich.', 'Gott ist groß'],
       'Angelika Baerbock': ['Niemals!', 'Eher nicht.', 'Glaube kaum.', 'Unwahrscheinlich.', 'Ich liebe das Völkerrecht'],
     };

     for (int i = 0; i < numQuestions; i++) {
       List<String> shuffledNames = List.from(participantNames)..shuffle(random);
       List<Map<String, String>> questionRanking = [];
       for (String name in shuffledNames) {
         String answer = possibleAnswers[name]?[random.nextInt(possibleAnswers[name]!.length)] ?? 'Keine Antwort';
         questionRanking.add({'name': name, 'answer': answer});
       }
       allRankings.add(questionRanking);
     }
     print("--- Simulierte Rankings erstellt: $allRankings ---");
     return allRankings;
  }
  // --- Ende Simulations-Funktion ---


  // --- Berechnet die Endpunktzahl basierend auf den Rankings (unverändert) ---
  Map<String, int> _calculateScores() {
    Map<String, int> scores = { for (var p in participants) p : 0 };
    const int pointsRank1 = 3;
    const int pointsRank2 = 2;
    const int pointsRank3 = 1;

    // TODO: In einer echten App würden die 'collectedRankings' nicht simuliert,
    // sondern aus Firestore für den 'roomId' geladen.
    for (List<Map<String, String>> questionRanking in collectedRankings) {
      if (questionRanking.isNotEmpty) {
        scores[questionRanking[0]['name']!] = (scores[questionRanking[0]['name']!] ?? 0) + pointsRank1;
      }
      if (questionRanking.length > 1) {
         scores[questionRanking[1]['name']!] = (scores[questionRanking[1]['name']!] ?? 0) + pointsRank2;
      }
       if (questionRanking.length > 2) {
         scores[questionRanking[2]['name']!] = (scores[questionRanking[2]['name']!] ?? 0) + pointsRank3;
      }
    }
    print("--- Berechnete Scores für Raum $roomId: $scores ---"); // roomId hinzugefügt
    return scores;
  }


  @override
  Widget build(BuildContext context) {
    // Berechne die Scores
    final scores = _calculateScores();

    // Sortiere die Teilnehmer nach Punkten (absteigend)
    final List<MapEntry<String, int>> sortedScores = scores.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    print("--- Sortierte Scores für Raum $roomId: $sortedScores ---"); // roomId hinzugefügt

    String winnerName = sortedScores.isNotEmpty ? sortedScores[0].key : "Niemand";

    return Scaffold(
      appBar: AppBar(
        title: Text('Herzblatt Ergebnis für $userName'),
        // Optional: Füge Raum-ID zum Titel hinzu für Debugging
        // title: Text('Ergebnis $userName (Raum: $roomId)'),
        backgroundColor: Colors.pinkAccent,
        automaticallyImplyLeading: false, // Kein Zurück
      ),
      body: Container(
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
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
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
              // Gewinner-Anzeige (unverändert)
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

              // Gesamte Rangliste anzeigen (unverändert)
              Expanded(
                child: ListView.builder(
                  shrinkWrap: true,
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
                          entry.key,
                           style: TextStyle(
                               fontSize: 18,
                               fontWeight: isWinner ? FontWeight.bold : FontWeight.normal
                           ),
                        ),
                        trailing: Text(
                          '${entry.value} Punkte',
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
              ),

              const SizedBox(height: 30),

              // Button zum Neustarten (unverändert)
              ElevatedButton.icon(
                 icon: const Icon(Icons.refresh),
                 label: const Text('Neues Spiel starten'),
                 onPressed: () {
                   Navigator.of(context).pushAndRemoveUntil(
                       MaterialPageRoute(builder: (context) => const HomeScreen()),
                       (Route<dynamic> route) => false,
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