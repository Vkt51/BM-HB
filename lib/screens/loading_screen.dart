import 'package:flutter/material.dart';
import 'dart:async';
import 'home_screen.dart'; // Stellt sicher, dass dieser Import korrekt ist und die Datei existiert

class LoadingScreen extends StatefulWidget {
  const LoadingScreen({super.key});

  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {
  Timer? _navigationTimer;

  @override
  void initState() {
    super.initState();
    _startNavigationTimer();
  }

  void _startNavigationTimer() {
    // Kurze Anzeigedauer für den Ladescreen (z.B. 4 Sekunden)
    // Passe dies nach Bedarf an.
    const loadingDuration = Duration(seconds: 4);

    _navigationTimer = Timer(loadingDuration, () {
      print("Ladescreen-Anzeigedauer vorbei, Navigation wird gestartet.");
      // mounted prüft, ob das Widget noch Teil des Widget-Baums ist.
      // Wichtig bei asynchronen Operationen, um Fehler zu vermeiden.
      if (mounted) {
        Navigator.of(context).pushReplacement(
          // Ersetzt den aktuellen Screen, sodass man nicht zurück navigieren kann.
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      }
    });
  }

  @override
  void dispose() {
    // Wichtig: Timer abbrechen, wenn das Widget entfernt wird,
    // um Speicherlecks und Fehler zu vermeiden.
    _navigationTimer?.cancel();
    print("LoadingScreen disposed.");
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Stack wird verwendet, um Widgets übereinander zu legen (Bild hinten, Inhalt vorne)
      body: Stack(
        // fit: StackFit.expand sorgt dafür, dass der Stack den gesamten verfügbaren Platz einnimmt.
        fit: StackFit.expand,
        children: <Widget>[
          // 1. Ebene: Das Hintergrundbild
          Image.asset(
            // ---- WICHTIG: Passe diesen Pfad an deine Bilddatei an! ----
            'assets/images/loading_herzblatt.png',
            // BoxFit.cover skaliert das Bild so, dass es den gesamten Bereich
            // ausfüllt, auch wenn Teile davon abgeschnitten werden.
            fit: BoxFit.cover,
            // --- HIER KANNST DU DIE AUSRICHTUNG ANPASSEN ---
            // Standard ist Alignment.center. Experimentiere mit anderen Werten,
            // um zu steuern, welcher Teil des Bildes erhalten bleibt, wenn
            // es wegen BoxFit.cover abgeschnitten wird.
            alignment: Alignment.center, // Z.B. Mitte des Bildes bleibt sichtbar
            // alignment: Alignment.topCenter, // Oberer Teil des Bildes bleibt sichtbar
            // alignment: Alignment.bottomCenter, // Unterer Teil des Bildes bleibt sichtbar
            // alignment: Alignment.centerLeft, // Linker Teil ...
            // alignment: Alignment.centerRight, // Rechter Teil ...
            // -------------------------------------------------
            // errorBuilder wird aufgerufen, wenn das Bild nicht geladen werden kann.
            errorBuilder: (context, error, stackTrace) {
               print("Fehler beim Laden des Hintergrundbildes: $error");
               // Zeigt eine einfache rosa Box als Fallback an.
               return Container(color: Colors.pink.shade100);
            },
          ),

          // Optional: Ein halbtransparenter Overlay, um den Text lesbarer zu machen.
          // Entferne oder passe die Deckkraft (Opacity) nach Bedarf an.
          // Container(
          //   color: Colors.black.withOpacity(0.3), // Schwarz mit 30% Deckkraft
          // ),

          // 2. Ebene: Die zentrierten Ladeelemente (Anzeige und Text)
          Center(
            child: Column(
              // Zentriert die Kinder vertikal in der Column.
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Die runde Ladeanzeige.
                const CircularProgressIndicator(
                  // Farbe der Anzeige (hier weiß für Kontrast).
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  // Dicke des Kreises.
                  strokeWidth: 5.0,
                ),
                // Abstand zwischen Ladeanzeige und Text.
                const SizedBox(height: 30),
                // Container für den Text, um einen Hintergrund hinzuzufügen.
                Container(
                  // Innenabstand im Container.
                  padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                  // Dekoration des Containers (Hintergrundfarbe, abgerundete Ecken).
                  decoration: BoxDecoration(
                    // Halbtransparenter schwarzer Hintergrund für bessere Lesbarkeit.
                    color: Colors.black.withOpacity(0.5),
                    // Abgerundete Ecken.
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Text(
                    "Herzblatt lädt...",
                    // Text-Styling.
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white, // Weiße Schriftfarbe.
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}