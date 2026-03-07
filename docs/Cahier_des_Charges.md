# CAHIER DES CHARGES — AutoMium
**Outil personnel de Pentesting & Analyse de Malware**

> **Plateforme :** Kali Linux (Desktop)
> **Stack :** Flutter + Python FastAPI
> **Stockage :** SQLite / JSON
> **Version :** 1.0 — 2025
> **Confidentialité :** Usage strictement personnel

---

## Table des Matières

1. [Présentation du Projet](#1-présentation-du-projet)
2. [Périmètre Fonctionnel](#2-périmètre-fonctionnel)
3. [Architecture Technique](#3-architecture-technique)
4. [Stack Technologique](#4-stack-technologique)
5. [Exigences de Sécurité](#5-exigences-de-sécurité)
6. [Plan de Développement](#6-plan-de-développement)
7. [Analyse des Risques](#7-analyse-des-risques)
8. [Livrables Attendus](#8-livrables-attendus)
9. [Critères de Recette](#9-critères-de-recette)
10. [Glossaire](#10-glossaire)

---

## 1. Présentation du Projet

### 1.1 Identification

| Champ | Détail |
|---|---|
| **Nom du projet** | AutoMium |
| **Nature** | Outil personnel de cybersécurité |
| **Plateforme cible** | Kali Linux (Desktop) |
| **Propriétaire** | Usage personnel et privé |
| **Version initiale** | 1.0 |
| **Date de rédaction** | 2025 |

### 1.2 Contexte

> AutoMium est un outil personnel conçu pour centraliser, automatiser et sécuriser les workflows de pentesting et d'analyse de malware sur Kali Linux, **sans aucune dépendance externe** ni transmission de données vers des services cloud.

Dans un contexte où les professionnels de la cybersécurité jonglent quotidiennement entre de nombreux outils spécialisés (nmap, Metasploit, YARA, Hydra, etc.), AutoMium propose une interface unifiée, portable et sécurisée permettant de :

- Centraliser l'accès aux outils Kali Linux dans un seul environnement.
- Automatiser les tâches répétitives : scans, analyses, génération de rapports.
- Stocker les résultats localement sans risque de fuite de données.
- Offrir une portabilité Desktop (Linux).

### 1.3 Objectifs Stratégiques

| Objectif | Description |
|---|---|
| **Centralisation** | Regrouper tous les outils de pentest dans une seule interface. |
| **Automatisation** | Réduire le temps des tâches répétitives (scans, rapports). |
| **Sécurité des données** | 100% local, aucune donnée transmise à l'extérieur. |
| **Portabilité** | Fonctionne sur PC Kali. |
| **Extensibilité** | Architecture modulaire pour ajouter de nouveaux outils. |

---

## 2. Périmètre Fonctionnel

### 2.1 Module 1 — Pentesting Réseau

| Fonctionnalité | Description | Outils Kali |
|---|---|---|
| Scan de ports | Détecter les ports ouverts et services sur une IP/cible. | `nmap` |
| Détection de vulnérabilités | Identifier les failles CVE sur les services détectés. | `nmap`, `nikto` |
| Brute-force | Tester des identifiants sur SSH, FTP, HTTP, etc. | `hydra` |
| Exploitation | Exploiter les failles identifiées via des modules. | `metasploit` |
| Génération de rapports | Sauvegarder les résultats en PDF ou JSON. | `reportlab` |

### 2.2 Module 2 — Analyse de Malware

| Fonctionnalité | Description | Outils Kali |
|---|---|---|
| Analyse statique | Extraire les strings, en-têtes et patterns d'un fichier suspect. | `yara`, `peframe`, `strings` |
| Analyse dynamique | Exécuter le fichier dans un sandbox isolé. | `docker`, `firejail` |
| Détection de patterns | Comparer avec des règles YARA ou signatures connues. | `yara`, `clamav` |
| Rapport IOC | Sauvegarder les hashes, IOCs et résultats d'analyse. | `SQLite`, `JSON` |

### 2.3 Module 3 — Automatisation & Utilitaires

| Fonctionnalité | Description | Technologies |
|---|---|---|
| Scripts personnalisés | Enchaîner des commandes (ex : scan + exploitation). | `Bash`, `Python` |
| Terminal intégré | Afficher les sorties des commandes en temps réel. | Flutter Terminal |
| Gestion des rapports | Historique, recherche et filtrage des résultats. | `SQLite`, `Hive` |
| Sauvegarde / Restore | Exporter et importer données et configurations. | `ZIP`, `JSON` |

---

## 3. Architecture Technique

### 3.1 Schéma Global

```
┌─────────────────────────────────────────┐
│       Interface Flutter (Desktop) │
└───────────────────┬─────────────────────┘
                    │ REST API / WebSockets
┌───────────────────▼─────────────────────┐
│         Backend Python (FastAPI)         │
└───────────────────┬─────────────────────┘
                    │ subprocess (appels système)
┌───────────────────▼─────────────────────┐
│   Outils Kali Linux                      │
│   nmap · yara · metasploit · hydra ...  │
└───────────────────┬─────────────────────┘
                    │
┌───────────────────▼─────────────────────┐
│         Stockage Local                   │
│         SQLite  ·  Fichiers JSON         │
└─────────────────────────────────────────┘
```

### 3.2 Détail des Couches

| Couche | Technologie | Rôle |
|---|---|---|
| Frontend | Flutter (Dart) | Interface utilisateur Desktop |
| Communication | REST API / WebSockets | Échange de données en temps réel |
| Backend | Python FastAPI | Orchestration des outils et logique métier |
| Outils Système | nmap, yara, metasploit… | Exécution des analyses et pentests |
| Stockage | SQLite + JSON | Persistance locale des rapports et configs |

### 3.3 Frontend Flutter

Le frontend est développé en Dart avec Flutter, garantissant une portabilité native sur Linux Desktop et Android/iOS.

- Widgets natifs : boutons, terminaux intégrés, tableaux de bord.
- Stockage local via **Hive** ou **SQLite** pour les rapports et configurations.
- Communication backend via le package `http` (REST) ou WebSockets.
- Terminal temps réel pour afficher la sortie des commandes système.

### 3.4 Backend Python (FastAPI)

Le backend repose sur FastAPI, exposant une API REST consommée par le frontend.

| Endpoint | Méthode | Description |
|---|---|---|
| `/scan` | GET | Lancer un scan nmap sur une IP cible |
| `/analyze` | POST | Analyser un fichier suspect avec YARA/peframe |
| `/report` | GET / POST | Sauvegarder ou récupérer les rapports |
| `/bruteforce` | POST | Lancer une attaque hydra sur un service cible |
| `/status` | GET | Vérifier l'état des outils et du backend |

### 3.5 Stockage Local

Aucune donnée ne quitte la machine locale. Deux mécanismes complémentaires :

- **SQLite** : rapports structurés, historique des scans, résultats d'analyses, gestion des sessions.
- **Fichiers JSON** : configurations, exports, règles YARA personnalisées, paramètres utilisateur.

### 3.6 Exemples de Code

**Frontend Flutter — Lancer un scan :**
```dart
Future<void> launchScan(String ip) async {
  final response = await http.get(
    Uri.parse('http://localhost:8000/scan?ip=$ip')
  );
  if (response.statusCode == 200) {
    setState(() {
      scanResults = response.body;
    });
  }
}
```

**Backend Python — Endpoint scan :**
```python
from fastapi import FastAPI
import subprocess

app = FastAPI()

@app.get("/scan")
def scan(ip: str):
    result = subprocess.run(
        ["nmap", "-sV", ip],
        capture_output=True,
        text=True
    )
    return {"result": result.stdout}
```

**Stockage SQLite :**
```python
import sqlite3

def save_report(scan_type: str, results: str):
    conn = sqlite3.connect("reports.db")
    cursor = conn.cursor()
    cursor.execute("""
        CREATE TABLE IF NOT EXISTS reports (
            id      INTEGER PRIMARY KEY AUTOINCREMENT,
            type    TEXT,
            results TEXT,
            date    TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        )
    """)
    cursor.execute(
        "INSERT INTO reports (type, results) VALUES (?, ?)",
        (scan_type, results)
    )
    conn.commit()
    conn.close()
```

---

## 4. Stack Technologique

| Catégorie | Technologie | Justification |
|---|---|---|
| **Frontend** | Flutter (Dart) | Portable, moderne, Desktop |
| **Backend** | Python 3.x + FastAPI | Léger, intégration aisée avec les outils Kali |
| **Base de données** | SQLite | Local, sans serveur, simple et robuste |
| **Communication** | REST API + WebSockets | Flexible et temps réel pour le terminal |
| **Pentesting** | nmap, metasploit, hydra, nikto | Outils standards et éprouvés de Kali Linux |
| **Analyse Malware** | yara, peframe, strings, clamav | Puissants, open-source et maintenus |
| **Sandboxing** | Docker / Firejail | Isolation sécurisée pour l'analyse dynamique |
| **Automatisation** | Bash + Python subprocess | Scripts pour enchaîner les outils |
| **Rapports** | reportlab (PDF) + JSON | Exports lisibles et exploitables |

---

## 5. Exigences de Sécurité

### 5.1 Principe de Moindre Privilège

AutoMium doit fonctionner avec les privilèges minimaux nécessaires. Les commandes nécessitant des droits élevés doivent être clairement identifiées et isolées.

- Ne jamais exécuter l'ensemble de l'application en `root`.
- Utiliser `sudo` uniquement pour les commandes qui le nécessitent explicitement.
- Journaliser toutes les exécutions avec élévation de privilèges.

### 5.2 Validation des Entrées

> Toutes les entrées utilisateur doivent être validées côté backend avant toute exécution de commande système, afin de prévenir les injections de commandes.

- Validation du format IP/CIDR avant lancement de `nmap`.
- Vérification des chemins de fichiers pour les analyses malware.
- Sanitisation de tous les paramètres transmis via l'API REST.
- Utilisation de listes blanches pour les options acceptées par les outils.

### 5.3 Isolation des Analyses

- Toute analyse de fichier suspect se fait dans un environnement isolé (Docker ou Firejail).
- Les fichiers suspects sont placés dans des répertoires dédiés avec droits restreints.
- Le réseau est désactivé dans le sandbox lors de l'analyse dynamique.

### 5.4 Protection des Données

- Aucune donnée transmise vers des services externes — **zéro cloud**.
- Option de chiffrement des rapports sensibles via GPG.
- Sauvegarde automatique régulière : SQLite + export JSON chiffré.

---

## 6. Plan de Développement

| Phase | Durée estimée | Livrables |
|---|---|---|
| Phase 1 : Préparation | 1-2 jours | Environnement configuré, structure du projet, modèles de données |
| Phase 2 : Frontend Flutter | 3-5 jours | Interface fonctionnelle, terminaux, écrans modules |
| Phase 3 : Backend Python | 3-5 jours | API FastAPI + scripts d'intégration outils Kali |
| Phase 4 : Intégration & Tests | 2-3 jours | Outil fonctionnel, testé et débogué |
| Phase 5 : Déploiement | 1 jour | Binaire Flutter Linux + documentation complète |

### Phase 1 — Préparation

- [ ] Configurer l'environnement (Flutter SDK, Python 3.x, outils Kali).
- [ ] Créer la structure du projet (`frontend/`, `backend/`, `scripts/`, `docs/`).
- [ ] Définir les modèles de données : `ScanReport`, `MalwareAnalysis`, `Config`.
- [ ] Initialiser le dépôt Git local et définir le `.gitignore`.

### Phase 2 — Frontend Flutter

- [ ] Interface principale : menu de navigation, onglets pour chaque module.
- [ ] Terminal intégré pour afficher les sorties en temps réel.
- [ ] Écran de lancement de scan réseau (saisie IP, options nmap).
- [ ] Écran d'analyse de fichier malware (import fichier, résultats YARA).
- [ ] Écran de visualisation et filtrage des rapports historiques.

### Phase 3 — Backend Python

- [ ] Configurer FastAPI avec les endpoints `/scan`, `/analyze`, `/report`, `/bruteforce`.
- [ ] Écrire les wrappers Python pour chaque outil Kali via `subprocess`.
- [ ] Implémenter la gestion SQLite : création des tables, CRUD des rapports.
- [ ] Ajouter la validation et la sanitisation de toutes les entrées.

### Phase 4 — Intégration & Tests

- [ ] Connecter le frontend Flutter au backend Python.
- [ ] Tester chaque fonctionnalité (scans, analyses, rapports, terminal).
- [ ] Corriger les bugs et optimiser les performances.
- [ ] Vérifier l'absence de fuite réseau (Wireshark).

### Phase 5 — Déploiement

- [ ] Compiler le binaire Flutter pour Linux Desktop.
- [ ] Créer le script de démarrage `start_backend.sh`.
- [ ] Rédiger la documentation d'installation et le manuel utilisateur.
- [ ] Archiver le projet (Git local + ZIP de sauvegarde).

---

## 7. Analyse des Risques

| Risque | Probabilité | Impact | Solution |
|---|---|---|---|
| Problèmes de permissions root | Élevée | Élevé | Développer avec un utilisateur standard, `sudo` ciblé. |
| Outils Kali introuvables | Moyenne | Élevé | Vérifier les chemins au démarrage (`which nmap`). |
| Injections de commandes | Moyenne | Critique | Validation stricte des entrées, whitelist des paramètres. |
| Performances lentes | Moyenne | Moyen | Optimiser les threads, timeout sur les commandes. |
| Corruption de données SQLite | Faible | Élevé | Sauvegardes automatiques + transactions SQL. |
| Fuite hors sandbox malware | Faible | Critique | Docker/Firejail avec réseau désactivé. |

---

## 8. Livrables Attendus

### 8.1 Code Source

```
AutoMium/
├── frontend/          # Application Flutter (Dart)
├── backend/           # API FastAPI + wrappers outils Kali (Python)
├── scripts/           # Scripts Bash/Python pour l'automatisation
├── data/              # Schémas SQLite, règles YARA, configs JSON
└── docs/              # Documentation et exemples de rapports
```

### 8.2 Documentation

- Guide d'installation : dépendances, configuration de l'environnement.
- Manuel utilisateur : lancer un scan, analyser un malware, consulter les rapports.
- Documentation de l'API FastAPI (auto-générée par FastAPI/Swagger UI).
- Exemples de rapports générés (PDF + JSON).

### 8.3 Exécutables

- Binaire Flutter compilé pour **Linux Desktop**.
- Script de démarrage du backend : `start_backend.sh`.
- Archive ZIP du projet complet pour sauvegarde.

---

## 9. Critères de Recette

### 9.1 Tests Fonctionnels

| Test | Critère d'acceptation |
|---|---|
| Scan réseau | Un scan nmap sur une IP locale retourne les résultats affichés en < 60s. |
| Analyse malware | Un fichier EICAR est correctement détecté par YARA et ClamAV. |
| Brute-force SSH | Hydra teste une liste de credentials et retourne le résultat. |
| Rapport PDF | Le rapport généré est lisible, complet et sauvegardé localement. |
| Terminal temps réel | La sortie des commandes s'affiche progressivement dans l'UI. |
| Sandbox isolation | Un fichier malveillant analysé ne peut pas contacter le réseau. |

### 9.2 Tests Non-Fonctionnels

- Aucune donnée transmise à l'extérieur *(vérification réseau avec Wireshark)*.
- Interface responsive : utilisable en 1920×1080.
- Le backend démarre en moins de **5 secondes**.
- Les rapports SQLite persistent après redémarrage complet de l'application.

---

## 10. Glossaire

| Terme | Définition |
|---|---|
| **IOC** | Indicator of Compromise — Indicateur de compromission d'un système. |
| **CVE** | Common Vulnerabilities and Exposures — Base de données des vulnérabilités connues. |
| **YARA** | Outil de classification de malware basé sur des règles textuelles. |
| **Sandbox** | Environnement d'exécution isolé pour analyser du code malveillant en sécurité. |
| **FastAPI** | Framework Python moderne pour la création d'APIs REST performantes. |
| **SQLite** | Base de données relationnelle légère, embarquée, sans serveur dédié. |
| **Firejail** | Outil de sandboxing Linux utilisant les namespaces pour isoler les processus. |
| **peframe** | Outil d'analyse statique des exécutables PE (Windows) sous Linux. |
| **Hydra** | Outil de brute-force réseau supportant de nombreux protocoles (SSH, FTP, HTTP…). |
| **Flutter** | Framework Google pour créer des applications natives multi-plateformes. |
| **subprocess** | Module Python permettant d'exécuter des commandes système depuis le code. |
| **WebSocket** | Protocole de communication bidirectionnel et persistant entre client et serveur. |

---

*Document confidentiel — AutoMium v1.0 — Usage strictement personnel*