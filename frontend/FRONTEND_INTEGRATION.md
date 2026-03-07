# Frontend Flutter - Architecture & Intégration Backend

## 🎯 Vue d'ensemble

Le frontend AutoMium est développé en **Flutter** (application desktop cross-platform) et a été entièrement mis à jour pour s'intégrer avec le **nouveau backend modulaire**.

---

## 📁 Structure du Projet

```
frontend/
├── lib/
│   ├── main.dart                      # Point d'entrée + configuration
│   │
│   ├── providers/                     # State Management (Provider)
│   │   ├── api_provider.dart          # API REST vers backend
│   │   ├── report_provider.dart       # Gestion des rapports
│   │   └── terminal_provider.dart     # WebSocket temps réel
│   │
│   ├── screens/                       # Écrans principaux
│   │   ├── home_screen.dart           # Dashboard principal
│   │   ├── network_scan_screen.dart   # Scan réseau
│   │   ├── malware_analysis_screen.dart # Analyse malware
│   │   ├── bruteforce_screen.dart     # Attaques Hydra
│   │   └── reports_screen.dart        # Rapports
│   │
│   └── widgets/                       # Composants réutilisables
│       └── terminal_widget.dart       # Terminal WebSocket temps réel
│
├── pubspec.yaml                       # Dépendances
└── assets/                            # Ressources (icônes, images)
```

---

## 🔗 Intégration avec le Backend Modulaire

### 1. **ApiProvider** - Communication REST

**Fichier:** `lib/providers/api_provider.dart`

**Endpoints mis à jour:**
```dart
// Network Scanning
POST /scan/scan              → networkScan()
POST /scan/vulnerabilities   → vulnerabilityScan()

// Malware Analysis  
POST /analyze/malware        → analyzeMalware()

// Bruteforce
POST /bruteforce/            → bruteforce()

// Reports
GET  /reports/               → getAllReports()
GET  /reports/{id}           → getReport()
POST /reports/export/{id}    → exportReport()
DELETE /reports/{id}         → deleteReport()

// Tools
GET  /tools/status           → getStatus()
GET  /tools/install/{name}   → getInstallInstructions()

// Terminal (REST)
POST /terminal/execute       → executeTerminalCommand()
```

**Exemple d'utilisation:**
```dart
final apiProvider = context.read<ApiProvider>();

// Scanner réseau
final result = await apiProvider.networkScan(
  ip: '192.168.1.1',
  ports: '22,80,443',
  aggressive: true,
  osDetection: true,
);

// Analyser un malware
final analysis = await apiProvider.analyzeMalware(
  filePath: '/tmp/suspicious.exe',
  analysisType: 'static',
);
```

---

### 2. **TerminalProvider** - WebSocket Temps Réel

**Fichier:** `lib/providers/terminal_provider.dart`

**Fonctionnalités:**
- Connexion WebSocket à `ws://localhost:8000/ws/terminal`
- Envoi de commandes en temps réel
- Réception du flux de sortie terminal
- Gestion des états (connecté/déconnecté)
- Historique des messages

**Types de messages:**
```dart
{
  "type": "start",      // Commande démarrée
  "type": "output",     // Ligne de sortie terminal
  "type": "complete",   // Commande terminée
  "type": "error"       // Erreur
}
```

**Exemple d'utilisation:**
```dart
final terminalProvider = context.read<TerminalProvider>();

// Se connecter
terminalProvider.connect();

// Envoyer une commande
terminalProvider.sendCommand('nmap -sV 127.0.0.1');

// Écouter les messages (via Consumer)
Consumer<TerminalProvider>(
  builder: (context, provider, child) {
    return ListView.builder(
      itemCount: provider.messages.length,
      itemBuilder: (context, index) {
        final msg = provider.messages[index];
        return Text('${msg.type}: ${msg.data}');
      },
    );
  },
)
```

---

### 3. **TerminalWidget** - Composant UI

**Fichier:** `lib/widgets/terminal_widget.dart`

**Caractéristiques:**
- Interface style terminal avec effet glassmorphism
- Sortie en temps réel avec couleurs syntaxiques
- Zone de saisie de commandes
- Boutons d'action (clear, timestamps, reconnect)
- Scroll automatique vers le bas
- Historique des messages

**Utilisation:**
```dart
TerminalWidget(
  initialCommand: 'nmap -sV 127.0.0.1',
  autoConnect: true,
)
```

---

## 🎨 Design System

### Couleurs Principales
```dart
Primary:      Color(0xFF0066FF)  // Bleu futuriste
Secondary:    Color(0xFF00D4FF)  // Cyan brillant
Tertiary:     Color(0xFF00FFFF)  // Cyan clair
Surface:      Color(0xFF0A0E27)  // Bleu nuit foncé
Background:   Color(0xFF050818)  // Noir bleuté
Error:        Color(0xFFFF3366)  // Rouge néon
```

### Effets Spéciaux
- **Glassmorphism**: Cartes semi-transparentes avec flou
- **Glow Effects**: Ombres lumineuses cyan/bleu
- **Gradients**: Dégradés futuristes
- **Border Radii**: Coins arrondis (12-16px)

### Thèmes
```dart
- Material 3 (Material You)
- Dark theme par défaut
- Typographie: Google Fonts (Orbitron, Rajdhani)
- Icônes: Font Awesome Flutter
```

---

## 📦 Dépendances Principales

### HTTP & API
```yaml
http: ^1.1.0                # Client HTTP REST
web_socket_channel: ^2.4.0  # WebSocket pour temps réel
```

### State Management
```yaml
provider: ^6.1.1            # Gestion d'état réactive
```

### UI Components
```yaml
google_fonts: ^6.1.0        # Polices futuristes
font_awesome_flutter: ^10.6.0  # Icônes premium
```

### Utilities
```yaml
file_picker: ^6.1.1         # Sélection de fichiers
url_launcher: ^6.2.2        # Ouverture de liens
intl: ^0.18.1               # Internationalisation
pdf: ^3.10.7                # Génération PDF
printing: ^5.11.1           # Impression/PDF
```

### Storage
```yaml
hive: ^2.2.3                # Base de données locale
hive_flutter: ^1.1.0
path_provider: ^2.1.1       # Chemins de fichiers
```

---

## 🚀 Fonctionnalités Implémentées

### 1. **Dashboard Principal**
- État de la connexion backend
- Statistiques rapides
- Accès rapide aux outils
- Indicateurs en temps réel

### 2. **Scan Réseau**
- Formulaire de configuration complet
- Options avancées (ports, OS detection, scripts)
- Affichage structuré des résultats
- Export des rapports
- Terminal temps réel intégré

### 3. **Analyse Malware**
- Sélection de fichiers
- Type d'analyse (static/dynamic/full)
- Affichage des menaces détectées
- Niveau de dangerosité
- Recommandations de sécurité

### 4. **Bruteforce (Hydra)**
- Configuration de l'attaque
- Sélection des wordlists
- Service et port personnalisables
- Suivi en temps réel
- Résultats détaillés

### 5. **Rapports**
- Liste de tous les rapports
- Filtrage par type/date
- Visualisation détaillée
- Export PDF/JSON
- Suppression de rapports

### 6. **Terminal Temps Réel**
- Exécution de commandes shell
- Flux de sortie en direct
- Historique des commandes
- Code couleur intelligent
- Contrôle total (pause, clear, etc.)

---

## 🔄 Flux de Données

### Requête API Typique
```
User Action (UI)
    ↓
Screen Widget
    ↓
Provider (State Management)
    ↓
ApiProvider (HTTP Request)
    ↓
Backend Modular (FastAPI)
    ↓
External Tool (nmap, yara, etc.)
    ↓
Backend parses results
    ↓
ApiProvider receives JSON
    ↓
Provider updates state
    ↓
UI rebuilds with new data
```

### Flux WebSocket
```
User types command
    ↓
TerminalWidget.sendCommand()
    ↓
TerminalProvider sends via WebSocket
    ↓
Backend executes command
    ↓
Backend streams output line-by-line
    ↓
TerminalProvider receives messages
    ↓
Provider notifies listeners
    ↓
TerminalWidget rebuilds each line
```

---

## 🧪 Tests et Débogage

### Tester la connexion backend
```dart
final apiProvider = context.read<ApiProvider>();
await apiProvider.checkConnection();

print(apiProvider.isConnected);      // true/false
print(apiProvider.statusMessage);    // "Connected"
```

### Gérer les erreurs
```dart
try {
  final result = await apiProvider.networkScan(ip: '127.0.0.1');
  // Handle success
} catch (e) {
  // Show error to user
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text('Error: $e')),
  );
}
```

### Logs et debugging
```dart
// Activer les logs dans ApiProvider
void _log(String message) {
  debugPrint('[ApiProvider] $message');
}

// Voir les messages WebSocket
provider.messages.forEach((msg) {
  debugPrint('Terminal: ${msg.type} - ${msg.data}');
});
```

---

## 📱 Capture d'Écran (Description)

### Home Screen
- Header: Logo AutoMium + statut backend
- Cards: 
  - Network Scanner (icône réseau + bouton "Start")
  - Malware Analysis (icône virus + statut)
  - Bruteforce (icône clé + dernier scan)
  - Reports (icône document + nombre de rapports)
- Navigation rail latérale
- Thème sombre avec accents cyan/bleu

### Network Scan Screen
- Formulaire haut: IP, ports, options (checkboxes)
- Bouton "Launch Scan" (bleu brillant)
- Terminal widget (moitié basse)
- Résultats dans des cards glassmorphism
- Progress indicator circulaire

### Terminal Widget Detail
- Header: Status (vert/rouge) + boutons actions
- Corps: Sortie monospace couleur verte/blanche
- Footer: Prompt "$ " + input + bouton "Run"
- Scroll automatique vers le bas
- Timestamp optionnel en gris

---

## 🎯 Bonnes Pratiques

### State Management
✅ Utiliser `Provider` pour l'état global  
✅ `ChangeNotifier` pour les providers  
✅ `Consumer` pour reconstruire les widgets  
✅ Éviter les `setState` inutiles  

### API Calls
✅ Toujours utiliser `try-catch`  
✅ Afficher des messages d'erreur utilisateur-friendly  
✅ Timeout sur les requêtes longues  
✅ Indicateurs de chargement  

### WebSocket
✅ Gérer la déconnexion proprement  
✅ Reconnect automatique en cas d'erreur  
✅ Limiter la taille de l'historique  
✅ Scroll automatique vers le bas  

### UI/UX
✅ Feedback visuel immédiat  
✅ Messages d'erreur clairs  
✅ Indicateurs de progression  
✅ Animations fluides (200-300ms)  
✅ Accessibilité (contrastes, tailles)  

---

## 🔮 Améliorations Futures

### Court Terme
- [ ] Validation des formulaires en temps réel
- [ ] Historique des commandes terminal
- [ ] Recherche/filtre dans les rapports
- [ ] Notifications push (succès/échec)

### Moyen Terme
- [ ] Mode offline avec Hive
- [ ] Synchronisation automatique
- [ ] Personnalisation du thème
- [ ] Raccourcis clavier globaux

### Long Terme
- [ ] Support mobile (responsive)
- [ ] Multi-langues (i18n)
- [ ] Plugins/extensions
- [ ] Collaboration en temps réel

---

## 📚 Ressources

### Documentation Flutter
- [Flutter Docs](https://flutter.dev/docs)
- [Provider Package](https://pub.dev/packages/provider)
- [WebSocket Channel](https://pub.dev/packages/web_socket_channel)

### Design
- [Material Design 3](https://m3.material.io/)
- [Glassmorphism UI](https://ui8.net/glassmorphism)

### Backend Integration
- [FastAPI Documentation](https://fastapi.tiangolo.com/)
- [WebSocket Protocol](https://developer.mozilla.org/en-US/docs/Web/API/WebSockets_API)

---

## ✅ Checklist d'Intégration

### Backend Ready
- [x] API endpoints fonctionnels
- [x] WebSocket opérationnel
- [x] CORS configuré
- [x] Documentation Swagger

### Frontend Ready
- [x] Providers configurés
- [x] Routes API mappées
- [x] Terminal widget créé
- [x] Design system appliqué

### Integration
- [x] Connexion backend testée
- [x] Network scan fonctionnel
- [x] Malware analysis connecté
- [x] Rapports consultables
- [x] Terminal temps réel OK

### Testing
- [ ] Tests unitaires providers
- [ ] Tests d'intégration API
- [ ] Tests E2E complets
- [ ] Gestion des erreurs

---

**Statut:** ✅ Frontend intégré au backend modulaire  
**Version:** 2.0  
**Date:** 7 Mars 2026  
**Prochaine étape:** Tests end-to-end et optimisation
