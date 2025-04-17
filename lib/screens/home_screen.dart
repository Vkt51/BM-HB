import 'package:flutter/material.dart';
import 'dart:async'; // Für Future.delayed

// Importiere die Screens, zu denen wir navigieren
import 'create_room_screen.dart';
import 'join_room_screen.dart'; // Import für den Join-Screen hinzugefügt

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
    // Titel nach 500ms
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) setState(() => _showTitle = true);
    });

    // Subtitle nach 1500ms
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) setState(() => _showSubtitle = true);
    });

    // Buttons nach 2500ms
    Future.delayed(const Duration(milliseconds: 2500), () {
      if (mounted) setState(() => _showButtons = true);
    });
  }

  // --- Navigationsmethoden ---

  // Navigiert zum Screen "Raum erstellen"
  void _navigateToCreateRoom() {
    print("Navigiere zu 'Herzblatt-Raum erstellen'");
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CreateRoomScreen()),
    );
  }

  // Navigiert zum Screen "Raum beitreten"
  void _navigateToJoinRoom() {
    print("Navigiere zu 'Herzblatt-Raum beitreten'");
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const JoinRoomScreen()), // Ziel geändert
    );
    // Keine Snackbar mehr nötig
  }

  // Platzhalter für "Räume suchen" (vorerst deaktiviert)
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


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Herzblatt - Willkommen!'),
        backgroundColor: Colors.pinkAccent.withOpacity(0.8), // Leicht transparent
        elevation: 0, // Kein Schatten über dem Bild
      ),
      body: Stack( // Stack für Hintergrundbild und Inhalt
        fit: StackFit.expand,
        children: <Widget>[
          // --- 1. Ebene: Hintergrundbild ---
          Image.asset(
            'assets/images/auswahl_herzblatt.jpeg', // Pfad zu deinem Bild
            fit: BoxFit.cover,
            alignment: Alignment.center,
            errorBuilder: (context, error, stackTrace) {
               print("Fehler beim Laden des Hintergrundbildes (HomeScreen): $error");
               return Container(color: Colors.pink.shade50); // Fallback-Farbe
            },
          ),

          // Optional: Dunkler Overlay für bessere Lesbarkeit
          // Container(color: Colors.black.withOpacity(0.3)),

          // --- 2. Ebene: Der eigentliche Inhalt ---
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30.0), // Horizontaler Abstand
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center, // Vertikal zentriert
              crossAxisAlignment: CrossAxisAlignment.center, // Horizontal zentriert
              children: <Widget>[
                // --- Titel mit Animation ---
                AnimatedOpacity(
                  opacity: _showTitle ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 800),
                  child: Container( // Container für Text-Hintergrund
                     padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.5), // Halbtransparent schwarz
                        borderRadius: BorderRadius.circular(10),
                      ),
                    child: const Text(
                      'Hallo Lüstling!',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: Colors.white, // Weiße Schrift
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 15),

                // --- Subtitle mit Animation ---
                AnimatedOpacity(
                  opacity: _showSubtitle ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 800),
                   child: Container( // Container für Text-Hintergrund
                     padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    child: const Text(
                      'Was möchtest du tun?',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 20,
                        color: Colors.white, // Weiße Schrift
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 60), // Abstand zu Buttons

                // --- Buttons mit Animation ---
                AnimatedOpacity(
                  opacity: _showButtons ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 800),
                  child: Column(
                     mainAxisSize: MainAxisSize.min,
                     crossAxisAlignment: CrossAxisAlignment.stretch, // Buttons füllen Breite
                     children: [
                       // --- Button: Raum beitreten (AKTIV) ---
                       ElevatedButton(
                         onPressed: _navigateToJoinRoom, // Korrekte Funktion aufrufen
                         style: ElevatedButton.styleFrom(
                           // Angepasster Stil für "Aktiv"
                           backgroundColor: Colors.white.withOpacity(0.9), // Heller Hintergrund
                           foregroundColor: Colors.pinkAccent, // Farbe für Text/Icon
                           padding: const EdgeInsets.symmetric(vertical: 15),
                           textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                           side: const BorderSide(color: Colors.pinkAccent, width: 1.5), // Rand hervorheben
                           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                         ),
                         child: const Text('Herzblatt-Raum beitreten'),
                       ),
                       const SizedBox(height: 20), // Abstand

                       // --- Button: Raum erstellen ---
                       ElevatedButton(
                         onPressed: _navigateToCreateRoom,
                         style: ElevatedButton.styleFrom(
                           backgroundColor: Colors.pinkAccent.withOpacity(0.9),
                           foregroundColor: Colors.white,
                           padding: const EdgeInsets.symmetric(vertical: 15),
                           textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                         ),
                         child: const Text('Herzblatt-Raum erstellen'),
                       ),
                       const SizedBox(height: 20), // Abstand

                       // --- Button: Raum suchen (weiterhin Platzhalter/Deaktiviert) ---
                       ElevatedButton(
                         onPressed: _navigateToSearchRoom,
                         style: ElevatedButton.styleFrom(
                           backgroundColor: Colors.grey[400]?.withOpacity(0.8), // Ausgegraut mit Transparenz
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
          ), // Ende Padding (Inhalt)
        ],
      ), // Ende Stack
    );
  }
}