import 'dart:io'; // Wird für Platform.isAndroid/isIOS benötigt

import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

class QrScannerScreen extends StatefulWidget {
  const QrScannerScreen({super.key});

  @override
  State<QrScannerScreen> createState() => _QrScannerScreenState();
}

class _QrScannerScreenState extends State<QrScannerScreen> {
  // GlobalKey wird vom QRView Widget benötigt, um den Controller zu erhalten
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? controller; // Der Controller für den Scanner
  Barcode? result; // Speichert das letzte Scan-Ergebnis (optional)
  bool _isScanComplete = false; // Verhindert mehrfaches Poppen

  // Wichtig für Hot Reload und korrekte Kamera-Initialisierung
  // Kamera pausieren/fortsetzen, wenn die App unterbrochen wird
  @override
  void reassemble() {
    super.reassemble();
    // Kamera für verschiedene Plattformen korrekt handhaben
    if (Platform.isAndroid) {
      controller?.pauseCamera();
    }
    controller?.resumeCamera();
  }

  @override
  void dispose() {
    controller?.dispose(); // WICHTIG: Controller freigeben!
    super.dispose();
  }

  // Funktion, die aufgerufen wird, wenn der QRView erstellt wird
  void _onQRViewCreated(QRViewController controller) {
    setState(() {
      this.controller = controller; // Controller speichern
    });
    // Auf gescannte Daten lauschen
    controller.scannedDataStream.listen((scanData) {
      // Nur beim ersten erfolgreichen Scan reagieren
      if (!_isScanComplete && scanData.code != null) {
        setState(() {
          _isScanComplete = true; // Markieren, dass der Scan abgeschlossen ist
          result = scanData; // Optional: Ergebnis speichern
        });
        debugPrint('QR Code gefunden: ${scanData.code}');
        // Zurück zum vorherigen Screen und den Code übergeben
        Navigator.of(context).pop(scanData.code);
      }
    });
     // Kamera sofort starten (oder nach kurzer Verzögerung, falls nötig)
     controller.resumeCamera();
  }

  // Funktion zum Umschalten der Fackel
  Future<void> _toggleFlash() async {
    await controller?.toggleFlash();
    setState(() {}); // UI neu bauen, um Icon-Status zu aktualisieren (siehe unten)
  }

  // Funktion zum Wechseln der Kamera
  Future<void> _flipCamera() async {
    await controller?.flipCamera();
    setState(() {}); // UI neu bauen, um Icon-Status zu aktualisieren (siehe unten)
  }

  @override
  Widget build(BuildContext context) {
    // Optional: Visuelles Overlay für den Scanbereich
    var scanArea = (MediaQuery.of(context).size.width < 400 ||
            MediaQuery.of(context).size.height < 400)
        ? 200.0 // Kleinere Größe für kleinere Screens
        : 300.0; // Standardgröße

    return Scaffold(
      appBar: AppBar(
        title: const Text('QR-Code ausrichten'),
        backgroundColor: Colors.pinkAccent,
        actions: [
          // --- Button für Fackel (mit Statusprüfung) ---
          FutureBuilder<bool?>(
            future: controller?.getFlashStatus(), // Prüft den aktuellen Status
            builder: (context, snapshot) {
              bool isFlashOn = snapshot.data ?? false; // Standard: aus
              return IconButton(
                color: Colors.white,
                icon: Icon(isFlashOn ? Icons.flash_on : Icons.flash_off,
                           color: isFlashOn ? Colors.yellow : Colors.grey),
                tooltip: 'Fackel umschalten',
                onPressed: _toggleFlash,
              );
            },
          ),
          // --- Button für Kamerawechsel (mit Statusprüfung) ---
          FutureBuilder<CameraFacing>(
            future: controller?.getCameraInfo(), // Prüft die aktuelle Kamera
             builder: (context, snapshot) {
               CameraFacing facing = snapshot.data ?? CameraFacing.back; // Standard: Rückseite
               return IconButton(
                 color: Colors.white,
                 icon: Icon(facing == CameraFacing.front ? Icons.camera_front : Icons.camera_rear),
                 tooltip: 'Kamera wechseln',
                 onPressed: _flipCamera,
               );
             },
          ),
        ],
      ),
      body: Column( // Column, um QRView und ggf. andere Elemente zu stapeln
        children: <Widget>[
          Expanded( // Lässt den Scanner den verfügbaren Platz füllen
            flex: 5, // Gibt dem Scanner mehr Platz
            child: QRView(
              key: qrKey, // Der GlobalKey
              onQRViewCreated: _onQRViewCreated, // Callback
              // Definiert den Scanbereich visuell (optional, aber empfohlen)
              overlay: QrScannerOverlayShape(
                  borderColor: Colors.pinkAccent,
                  borderRadius: 10,
                  borderLength: 30,
                  borderWidth: 10,
                  cutOutSize: scanArea),
              onPermissionSet: (ctrl, p) => _onPermissionSet(context, ctrl, p), // Behandlung von Berechtigungen
            ),
          ),
          // Optional: Unten einen Bereich für Text oder Buttons hinzufügen
          // Expanded(
          //   flex: 1,
          //   child: Center(
          //     child: (result != null)
          //         ? Text('Letzter Scan: ${result!.code}')
          //         : const Text('Richte die Kamera auf einen QR-Code'),
          //   ),
          // )
        ],
      ),
    );
  }

  // Callback, wenn Berechtigungen geprüft wurden (wird von QRView aufgerufen)
  void _onPermissionSet(BuildContext context, QRViewController ctrl, bool p) {
    debugPrint('${DateTime.now().toIso8601String()}_onPermissionSet $p');
    if (!p) { // Wenn keine Berechtigung erteilt wurde
       ScaffoldMessenger.of(context).showSnackBar(
         const SnackBar(content: Text('Keine Kamera-Berechtigung!')),
       );
       // Optional: Zurück navigieren, wenn keine Berechtigung erteilt wird
       // Navigator.of(context).pop();
    }
  }
}