import 'dart:async'; // Import für Timer (falls Stateful MyApp verwendet wird)
import 'package:audioplayers/audioplayers.dart'; // Import für Audioplayer (falls Stateful MyApp verwendet wird)
import 'package:flutter/material.dart';

// Importiere Firebase Core und die generierten Optionen
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart'; // Diese Datei wurde von `flutterfire configure` erstellt

// Importiere deinen ersten Screen (passe ggf. den Pfad/Namen an)
import 'screens/loading_screen.dart';

// *** Hauptfunktion - Startpunkt der App ***
Future<void> main() async {
  // Stelle sicher, dass Flutter initialisiert ist, bevor Plugins verwendet werden.
  // Notwendig für Firebase.initializeApp vor runApp.
  WidgetsFlutterBinding.ensureInitialized();

  // Initialisiere Firebase für die aktuelle Plattform (iOS/Android etc.)
  // Verwendet die Konfiguration aus `firebase_options.dart`.
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Starte die Flutter-Anwendung
  runApp(const MyApp());
}

//---------------------------------------------------------------------
// *** VARIANTE 1: MyApp als StatelessWidget (wenn du den Jingle NICHT in MyApp verwaltet hast) ***
// Kommentiere diese Variante aus, wenn du Variante 2 verwendest.
//---------------------------------------------------------------------
/*
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ballermann Herzblatt',
      theme: ThemeData(
        // Definiere dein App-Theme
        primarySwatch: Colors.pink, // Hauptfarbe
        visualDensity: VisualDensity.adaptivePlatformDensity,
        // Optional: Weitere Theme-Anpassungen (Schriftarten, Button-Stile etc.)
        // colorScheme: ColorScheme.fromSeed(seedColor: Colors.pinkAccent),
        // useMaterial3: true, // Für Material 3 Design
      ),
      // Definiere den ersten Screen, der angezeigt wird
      home: const LoadingScreen(), // Dein Ladebildschirm
      debugShowCheckedModeBanner: false, // Entfernt das "DEBUG"-Banner
    );
  }
}
*/

//---------------------------------------------------------------------
// *** VARIANTE 2: MyApp als StatefulWidget (WENN du den Jingle hier verwaltet hast) ***
// Verwende diese Variante, wenn dein MyApp vorher schon StatefulWidget war.
// Kommentiere Variante 1 oben aus, wenn du diese verwendest.
//---------------------------------------------------------------------

 class MyApp extends StatefulWidget {
   const MyApp({super.key});

   @override
   State<MyApp> createState() => _MyAppState();
 }

 class _MyAppState extends State<MyApp> {
   // Variablen für den Jingle-Player aus der früheren Implementierung
   final AudioPlayer _jinglePlayer = AudioPlayer();
   Timer? _jingleStopTimer;
   bool _jinglePlayed = false; // Verhindert mehrfaches Spielen

   @override
   void initState() {
     super.initState();
     _playIntroJingleOnce(); // Starte den Jingle beim App-Start
   }

   // Spielt den Jingle einmalig für 30 Sekunden
   Future<void> _playIntroJingleOnce() async {
     if (_jinglePlayed) return;
     _jinglePlayed = true;

     try {
       // Passe den Pfad zu deinem Jingle an!
       await _jinglePlayer.play(AssetSource('audio/jingle.mp3'), volume: 0.8);
       debugPrint("Jingle in MyApp gestartet.");

       // Stoppe den Jingle nach 30 Sekunden
       _jingleStopTimer?.cancel();
       _jingleStopTimer = Timer(const Duration(seconds: 30), () {
         _jinglePlayer.stop();
         debugPrint("Jingle nach 30 Sekunden gestoppt.");
       });

     } catch (e) {
       debugPrint("Fehler beim Abspielen des Jingles in MyApp: $e");
     }
   }

   @override
   void dispose() {
     // Wichtig: Ressourcen freigeben, wenn die App geschlossen wird
     _jingleStopTimer?.cancel();
     _jinglePlayer.dispose();
     debugPrint("MyApp disposed, JinglePlayer released.");
     super.dispose();
   }

   @override
   Widget build(BuildContext context) {
     return MaterialApp(
       title: 'Ballermann Herzblatt',
       theme: ThemeData(
         primarySwatch: Colors.pink,
         visualDensity: VisualDensity.adaptivePlatformDensity,
         // colorScheme: ColorScheme.fromSeed(seedColor: Colors.pinkAccent),
         // useMaterial3: true,
       ),
       // Erster Screen der App
       home: const LoadingScreen(),
       debugShowCheckedModeBanner: false,
     );
   }
 }

//---------------------------------------------------------------------