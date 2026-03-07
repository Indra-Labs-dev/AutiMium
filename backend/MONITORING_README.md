# 📊 Network Monitoring - Documentation

## Vue d'ensemble

Le module **Network Monitoring** d'AutoMium permet de surveiller en temps réel l'activité réseau, les connexions établies, et détecter d'éventuelles anomalies.

---

## 🎯 Fonctionnalités

### 1. Surveillance des Connexions
- ✅ Voir toutes les connexions TCP/UDP actives
- ✅ Identifier les processus associés
- ✅ Adresses locales et distantes
- ✅ États des connexions (ESTABLISHED, LISTEN, etc.)

### 2. Analyse des Interfaces
- ✅ Liste complète des interfaces réseau
- ✅ Adresses MAC, IPv4, IPv6
- ✅ État (UP/DOWN)
- ✅ Statistiques par interface

### 3. Détection Nouveaux Appareils
- ✅ Scanner le réseau local
- ✅ Comparer avec appareils connus
- ✅ Alerter sur nouveaux dispositifs
- ✅ Table ARP complète

### 4. Surveillance Trafic
- ✅ Bytes/packets RX/TX
- ✅ Erreurs de transmission
- ✅ Format humain (KB, MB, GB)
- ✅ Historique (futur)

---

## 🔧 Commandes Sous-jacentes

Le monitoring utilise ces commandes système :

```bash
# Connexions actives
ss -tunapl

# Interfaces réseau
ip -j addr
# ou
ifconfig -a

# Table ARP
arp -an

# Statistiques
cat /proc/net/dev
```

---

## 📡 API Reference

### GET /monitoring/connections

Récupère toutes les connexions actives.

**Réponse:**
```json
{
  "success": true,
  "total_connections": 15,
  "listening_ports": 8,
  "connections": [
    {
      "type": "tcp",
      "state": "ESTABLISHED",
      "local_address": "192.168.1.100:443",
      "peer_address": "10.0.0.1:54321",
      "process": "nginx"
    }
  ],
  "timestamp": "2026-03-07T23:45:00"
}
```

---

### GET /monitoring/interfaces

Récupère les informations des interfaces.

**Réponse:**
```json
{
  "success": true,
  "interfaces": [
    {
      "name": "eth0",
      "state": "UP",
      "mac_address": "AA:BB:CC:DD:EE:FF",
      "ipv4_addresses": ["192.168.1.100"],
      "ipv6_addresses": ["fe80::1"]
    }
  ],
  "timestamp": "2026-03-07T23:45:00"
}
```

---

### GET /monitoring/statistics

Récupère les statistiques de trafic.

**Réponse:**
```json
{
  "success": true,
  "statistics": {
    "eth0": {
      "rx_bytes": 1234567890,
      "rx_packets": 987654,
      "tx_bytes": 987654321,
      "tx_packets": 876543
    }
  },
  "timestamp": "2026-03-07T23:45:00"
}
```

---

### GET /monitoring/arp

Récupère la table ARP.

**Réponse:**
```json
{
  "success": true,
  "entries_count": 5,
  "arp_table": [
    {
      "interface": "eth0",
      "ip_address": "192.168.1.1",
      "mac_address": "00:11:22:33:44:55"
    }
  ],
  "timestamp": "2026-03-07T23:45:00"
}
```

---

### POST /monitoring/detect-devices

Détecte les nouveaux appareils.

**Requête:**
```json
{
  "known_macs": ["AA:BB:CC:DD:EE:FF", "11:22:33:44:55:66"]
}
```

**Réponse:**
```json
{
  "success": true,
  "total_devices": 5,
  "new_devices": [
    {
      "ip_address": "192.168.1.50",
      "mac_address": "FF:EE:DD:CC:BB:AA",
      "interface": "eth0"
    }
  ],
  "all_devices": [...],
  "timestamp": "2026-03-07T23:45:00"
}
```

---

## 💻 Utilisation dans Flutter

### Exemple: Récupérer les connexions

```dart
import 'package:provider/provider.dart';
import '../providers/api_provider.dart';

// Dans un widget
final apiProvider = context.read<ApiProvider>();

try {
  final connections = await apiProvider.getActiveConnections();
  
  if (connections['success']) {
    print('Total: ${connections['total_connections']}');
    
    for (var conn in connections['connections']) {
      print('${conn['local_address']} -> ${conn['peer_address']}');
    }
  }
} catch (e) {
  print('Error: $e');
}
```

---

### Exemple: Détecter nouveaux appareils

```dart
// Appareils déjà connus
final knownMacs = [
  'AA:BB:CC:DD:EE:FF', // Routeur
  '11:22:33:44:55:66', // PC principal
];

final result = await apiProvider.detectNewDevices(
  knownMacs: knownMacs,
);

if (result['success'] && result['new_devices'].isNotEmpty) {
  // Alerter l'utilisateur
  showDialog(
    context: context,
    builder: (_) => AlertDialog(
      title: Text('Nouveaux appareils détectés!'),
      content: Text(
        '${result['new_devices'].length} appareil(s) inconnu(s)'
      ),
    ),
  );
}
```

---

## 🛠️ Cas d'Usage Pratiques

### 1. Audit de Sécurité
```dart
// Vérifier les ports ouverts suspects
final ports = await apiProvider.getListeningPorts();

for (var port in ports['listening_ports']) {
  final address = port['address'];
  final process = port['process'];
  
  // Vérifier si processus connu
  if (!trustedProcesses.contains(process)) {
    print('⚠️ Processus suspect: $process sur $address');
  }
}
```

### 2. Diagnostic Réseau
```dart
// Vérifier configuration IP
final interfaces = await apiProvider.getNetworkInterfaces();

for (var iface in interfaces) {
  print('Interface: ${iface['name']}');
  print('  État: ${iface['state']}');
  print('  IPv4: ${iface['ipv4_addresses'].join(', ')}');
  print('  IPv6: ${iface['ipv6_addresses'].join(', ')}');
}
```

### 3. Surveillance Continue
```dart
// Rafraîchir toutes les 30 secondes
Timer.periodic(Duration(seconds: 30), (_) async {
  final stats = await apiProvider.getNetworkStatistics();
  
  for (var entry in stats['statistics'].entries) {
    final ifaceName = entry.key;
    final data = entry.value;
    
    print('$ifaceName: RX ${data['rx_bytes']} / TX ${data['tx_bytes']}');
  }
});
```

---

## 🔍 Interprétation des Résultats

### États de Connexion
- **ESTABLISHED** - Connexion active
- **LISTEN** - Port en écoute
- **TIME_WAIT** - Connexion en fermeture
- **CLOSE_WAIT** - En attente de fermeture

### Indicateurs Suspects
- 🔴 Connexions vers IPs inconnues
- 🔴 Ports ouverts non autorisés
- 🔴 Processus inconnus
- 🔴 Trafic anormalement élevé
- 🔴 Nouvelles adresses MAC

### Bonnes Pratiques
- ✅ Comparer avec baseline connue
- ✅ Surveiller régulièrement
- ✅ Documenter changements
- ✅ Investiguer anomalies
- ✅ Garder historique

---

## ⚠️ Limitations

### Technique
- Nécessite privilèges pour certaines infos
- Données instantanées (pas d'historique)
- Limité aux outils installés

### Performance
- Scan complet peut prendre du temps
- Refresh fréquent = plus de CPU
- Grande quantité de données possible

---

## 🚀 Améliorations Futures

### Court Terme
- [ ] Rafraîchissement auto configurable
- [ ] Filtres personnalisables
- [ ] Export CSV/JSON
- [ ] Recherche intégrée

### Moyen Terme
- [ ] Graphiques temporels
- [ ] Alertes configurables
- [ ] Base de données historique
- [ ] Comparison baseline

### Long Terme
- [ ] IA détection anomalies
- [ ] Cartographie visuelle
- [ ] Multi-systèmes
- [ ] Intégration SIEM

---

## 📚 Ressources

### Commandes Utiles
```bash
# Voir toutes les connexions
ss -tunapl

# Voir interfaces
ip addr show

# Table ARP
ip neigh show

# Statistiques
cat /proc/net/dev
```

### Outils Complémentaires
- **Wireshark** - Analyse packet
- **nmap** - Scan réseau
- **iftop** - Trafic en temps réel
- **nethogs** - Trafic par processus

---

## 🎯 Conclusion

Le module **Network Monitoring** est un outil puissant pour :

- ✅ Surveiller l'activité réseau
- ✅ Détecter anomalies et intrusions
- ✅ Diagnostiquer problèmes
- ✅ Auditer la sécurité

**Intégré parfaitement avec AutoMium v2.1+**

---

**Version:** 1.0  
**Date:** 7 Mars 2026  
**Statut:** ✅ Opérationnel
