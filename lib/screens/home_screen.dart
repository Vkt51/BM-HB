import 'package:flutter/material.dart';
import 'dart:async'; // Für Future.delayed

// Importiere die Screens, zu denen wir navigieren
import 'create_room_screen.dart';
import 'join_room_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // State-Variablen für die Animationen
  bool _showTitle = false;
  bool _showSubtitle = false;
  bool _showButtons = false;

  @override
  void initState() {
    super.initState();
    _startAnimations();
  }

  // Startet die Einblendanimationen nacheinander
  void _startAnimations() {
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) setState(() => _showTitle = true);
    });
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) setState(() => _showSubtitle = true);
    });
    Future.delayed(const Duration(milliseconds: 2500), () {
      if (mounted) setState(() => _showButtons = true);
    });
  }

  // --- Navigationsmethoden (unverändert) ---
  void _navigateToCreateRoom() {
    print("Navigiere zu 'Herzblatt-Raum erstellen'");
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CreateRoomScreen()),
    );
  }
  void _navigateToJoinRoom() {
    print("Navigiere zu 'Herzblatt-Raum beitreten'");
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const JoinRoomScreen()),
    );
  }
  void _navigateToSearchRoom() {
    print("Funktion 'Herzblatt-Räume suchen' ausgewählt (ausgeklammert)");
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Funktion 'Räume suchen' ist noch nicht aktiv."),
        duration: Duration(seconds: 2),
      ),
    );
  }
  // -----------------------------------------

  // --- Funktion für den INFO-DIALOG (unverändert) ---
  void _showAppExplanationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white.withAlpha(242), // Ca. 95% Opazität
          title: const Row(
            children: [
              Icon(Icons.help_outline, color: Colors.pinkAccent),
              SizedBox(width: 10),
              Text(
                'Was\'n hier los?',
                 style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Text(
              _getCreativeAppExplanation(),
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.black.withAlpha(204), height: 1.4), // Ca. 80% Opazität
            ),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
             side: const BorderSide(color: Colors.pinkAccent, width: 1)
          ),
          actionsAlignment: MainAxisAlignment.center,
          actions: <Widget>[
            TextButton(
              style: TextButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Colors.pinkAccent,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))
              ),
              child: const Text('Alles klar, Chef!'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  // --- Funktion für den WITZIGEN TEXT (unverändert) ---
  String _getCreativeAppExplanation() {
    return '''
Stell dir vor: Die Sonne knallt, der Sangria fließt in Strömen und die Bässe wummern... aber irgendwas fehlt noch zum perfekten Ballermann-Glück? ☀️🍹🎶

Vielleicht jemand, der mit dir über die schlechtesten Anmachsprüche lacht, die letzte Pommes teilt oder einfach nur verhindert, dass du deinen Hotelschlüssel schon wieder im Sand verlierst? 😉

Genau dafür gibt's **Ballermann Herzblatt!** ❤️

Wir sind wie dein bester Kumpel und die Flirt-Fee in einer App vereint. Finde coole Leute für die nächste Party-Eskalation, den romantischen Sonnenuntergangs-Flirt oder einfach nur jemanden, der auch dringend ein Konter-Bier braucht. 🍻

**Kurz gesagt:** Die App, damit dein Herz am Ballermann nicht nur im Takt der Musik, sondern vielleicht auch ein bisschen höher schlägt! 🥰

*(Keine Garantie auf die große Liebe, aber auf eine verdammt gute Zeit!)*
''';
  }
  // -----------------------------------------


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Herzblatt - Willkommen!'),
        backgroundColor: Colors.pinkAccent.withAlpha(204), // Ca. 80% Opazität
        elevation: 0,
      ),
      body: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          // --- 1. Ebene: Hintergrundbild (unverändert) ---
          Image.asset(
            'assets/images/auswahl_herzblatt.png',
            fit: BoxFit.cover,
            alignment: Alignment.center,
            errorBuilder: (context, error, stackTrace) {
               // print("Fehler beim Laden des Hintergrundbildes (HomeScreen): $error"); // Besser Logging verwenden
               return Container(color: Colors.pink.shade50);
            },
          ),

          // --- NEU: 2. Ebene: Dunkler Overlay für bessere Lesbarkeit ---
          // Deckt das Bild zu 40% ab (macht es zu 60% sichtbar)
          Container(color: Colors.black.withOpacity(0.4)),
          // --------------------------------------------------------

          // --- 3. Ebene: Der eigentliche Inhalt ---
          Padding(
             // Padding reduziert, besonders oben/unten, da spaceBetween wegfällt
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
            child: Column(
              // --- KORRIGIERT: mainAxisAlignment entfernt/geändert ---
              // mainAxisAlignment: MainAxisAlignment.spaceBetween, // ENTFERNT
              mainAxisAlignment: MainAxisAlignment.start, // Beginnt oben
              crossAxisAlignment: CrossAxisAlignment.stretch,
              // ---------------------------------------------------
              children: <Widget>[

                // --- INFO-BUTTON GANZ OBEN (unverändert) ---
                ElevatedButton.icon(
                  icon: const Icon(Icons.help_outline, size: 20),
                  label: const Text('Was ist Ballermann Herzblatt?'),
                  onPressed: () {
                    _showAppExplanationDialog(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black.withAlpha(153), // Ca. 60% Opazität
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    textStyle: const TextStyle(fontSize: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
                // --- ENDE INFO-BUTTON ---

                // --- NEU: Fester Abstand zwischen oberem Button und Mittelteil ---
                const SizedBox(height: 40), // Passe diesen Wert nach Bedarf an
                // -------------------------------------------------------------

                // --- Container für den animierten Mittelteil ---
                // Wickeln diesen Teil optional in Expanded oder Center, je nach gewünschtem Verhalten
                // Center zentriert den Block vertikal im verbleibenden Raum
                 Center( // Sorgt dafür, dass der Block im Restplatz zentriert wird
                  child: Column( // Die innere Column bleibt wie sie war
                     mainAxisSize: MainAxisSize.min,
                     crossAxisAlignment: CrossAxisAlignment.center,
                     children: [
                        // --- Titel mit Animation ---
                        AnimatedOpacity(
                          opacity: _showTitle ? 1.0 : 0.0,
                          duration: const Duration(milliseconds: 800),
                          child: Container(
                             padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                              decoration: BoxDecoration(
                                color: Colors.black.withAlpha(128), // 50% Opazität
                                borderRadius: BorderRadius.circular(10),
                              ),
                            child: const Text(
                              'Hallo Lüstling!',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 36,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 15),

                        // --- Subtitle mit Animation ---
                        AnimatedOpacity(
                          opacity: _showSubtitle ? 1.0 : 0.0,
                          duration: const Duration(milliseconds: 800),
                           child: Container(
                             padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                              decoration: BoxDecoration(
                                color: Colors.black.withAlpha(128), // 50% Opazität
                                borderRadius: BorderRadius.circular(10),
                              ),
                            child: const Text(
                              'Was möchtest du tun?',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 20,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 40),

                        // --- Buttons mit Animation ---
                        AnimatedOpacity(
                          opacity: _showButtons ? 1.0 : 0.0,
                          duration: const Duration(milliseconds: 800),
                          child: Column(
                             mainAxisSize: MainAxisSize.min,
                             crossAxisAlignment: CrossAxisAlignment.stretch,
                             children: [
                               // --- Button: Raum beitreten (AKTIV) ---
                               ElevatedButton(
                                 onPressed: _navigateToJoinRoom,
                                 style: ElevatedButton.styleFrom(
                                   backgroundColor: Colors.white.withAlpha(230), // Ca. 90% Opazität
                                   foregroundColor: Colors.pinkAccent,
                                   padding: const EdgeInsets.symmetric(vertical: 15),
                                   textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                   side: const BorderSide(color: Colors.pinkAccent, width: 1.5),
                                   shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                 ),
                                 child: const Text('Herzblatt-Raum beitreten'),
                               ),
                               const SizedBox(height: 20),

                               // --- Button: Raum erstellen ---
                               ElevatedButton(
                                 onPressed: _navigateToCreateRoom,
                                 style: ElevatedButton.styleFrom(
                                   backgroundColor: Colors.pinkAccent.withAlpha(230), // Ca. 90% Opazität
                                   foregroundColor: Colors.white,
                                   padding: const EdgeInsets.symmetric(vertical: 15),
                                   textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                   shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                 ),
                                 child: const Text('Herzblatt-Raum erstellen'),
                               ),
                               const SizedBox(height: 20),

                               // --- Button: Raum suchen (weiterhin Platzhalter/Deaktiviert) ---
                               ElevatedButton(
                                 onPressed: _navigateToSearchRoom,
                                 style: ElevatedButton.styleFrom(
                                   backgroundColor: Colors.grey[400]?.withAlpha(204), // Ca. 80% Opazität
                                   foregroundColor: Colors.grey[700],
                                   padding: const EdgeInsets.symmetric(vertical: 15),
                                   textStyle: const TextStyle(fontSize: 18),
                                   shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                 ),
                                 child: const Text('Herzblatt-Raum in der Nähe suchen'),
                               ),
                             ],
                          ),
                        ),
                     ],
                  ),
                ), // Ende des Center-Widgets
              ],
            ),
          ), // Ende Padding (Inhalt)
        ],
      ), // Ende Stack
    );
  }
}