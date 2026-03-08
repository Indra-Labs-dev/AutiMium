# 🏗️ AutoMium - Architecture Complète v2.5

## Vue d'Ensemble

```
┌─────────────────────────────────────────────────────────────────┐
│                    FRONTEND Flutter Desktop                     │
│  ┌───────────────────────────────────────────────────────────┐ │
│  │ Navigation Rail                                           │ │
│  │ ┌──────────────────────────────────────────────────────┐ │ │
│  │ │ 📊 Dashboard          ← PREMIER ONGLET ⭐            │ │ │
│  │ │ 🔍 Network Scan                                      │ │ │
│  │ │ 🦠 Malware Analysis                                  │ │ │
│  │ │ 🔓 Bruteforce                                        │ │ │
│  │ │ 📄 Reports                                           │ │ │
│  │ │ 📡 Monitoring                                        │ │ │
│  │ │ 🛡️ Kali Tools (8 catégories) ⭐ NOUVEAU             │ │ │
│  │ └──────────────────────────────────────────────────────┘ │ │
│  └───────────────────────────────────────────────────────────┘ │
│                                                                  │
│  ┌───────────────────────────────────────────────────────────┐ │
│  │ Écrans Principaux                                         │ │
│  │                                                           │ │
│  │ 📊 Dashboard Screen ⭐ NOUVEAU                            │ │
│  │   ├─ 4 Quick Stats Cards                                 │ │
│  │   ├─ Pie Chart (Distribution)                            │ │
│  │   ├─ Circular Progress (Success Rate)                    │ │
│  │   ├─ Recent Activity Timeline                            │ │
│  │   └─ Kali Tools Status                                   │ │
│  │                                                           │ │
│  │ 🛡️ Kali Tools Screen ⭐ NOUVEAU                          │ │
│  │   ├─ 🔍 Recon Screen ✅ COMPLET                          │ │
│  │   ├─ 📡 Scanning Screen (template)                       │ │
│  │   ├─ 💥 Exploitation Screen (template)                   │ │
│  │   ├─ 🦠 Malware Screen (template)                        │ │
│  │   ├─ 🔬 Forensics Screen (template)                      │ │
│  │   ├─ 📶 Wireless Screen (template)                       │ │
│  │   ├─ 🔐 Password Screen (template)                       │ │
│  │   └─ 🌐 Web Screen (template)                            │ │
│  └───────────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────────┘
                              │
                              │ REST API / WebSocket
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│                    BACKEND FastAPI Modular                      │
│  ┌───────────────────────────────────────────────────────────┐ │
│  │ Routes (API Endpoints)                                    │ │
│  │                                                           │ │
│  │ 🔐 /auth/*              ← JWT Authentication ⭐           │ │
│  │   ├─ POST /login                                         │ │
│  │   ├─ GET  /me                                            │ │
│  │   └─ POST /refresh                                       │ │
│  │                                                           │ │
│  │ 🔍 /scan/*                                               │ │
│  │   ├─ POST /scan        (Nmap)                            │ │
│  │   └─ POST /vulnerabilities (Nikto)                       │ │
│  │                                                           │ │
│  │ 🦠 /analyze/*                                            │ │
│  │   └─ POST /malware      (YARA, PEFrame)                  │ │
│  │                                                           │ │
│  │ 🔓 /bruteforce/*                                         │ │
│  │   └─ POST /             (Hydra)                          │ │
│  │                                                           │ │
│  │ 📄 /reports/*         ⭐ NOUVEAU                          │ │
│  │   ├─ GET  /                                              │ │
│  │   ├─ GET  /:id                                           │ │
│  │   ├─ DELETE /:id                                         │ │
│  │   ├─ POST /export/:id?format=csv|html|json|pdf  ⭐       │ │
│  │   └─ POST /export-all?format=csv|html         ⭐         │ │
│  │                                                           │ │
│  │ 🛡️ /kali/*           ⭐ NOUVEAU - 50+ OUTILS             │ │
│  │   ├─ POST /recon              (6 outils)                 │ │
│  │   ├─ POST /scan/enumeration   (5 outils)                 │ │
│  │   ├─ POST /exploit            (4 outils)                 │ │
│  │   ├─ POST /post-exploit       (4 outils)                 │ │
│  │   ├─ POST /malware/generate   (7 outils)                 │ │
│  │   ├─ POST /forensics          (6 outils)                 │ │
│  │   ├─ POST /wireless           (5 outils)                 │ │
│  │   ├─ POST /password-attack    (5 outils)                 │ │
│  │   ├─ POST /web/sqli           (6 outils)                 │ │
│  │   ├─ POST /web/xss            (6 outils)                 │ │
│  │   ├─ POST /sniffing           (6 outils)                 │ │
│  │   └─ GET  /tools/catalog                                 │ │
│  │                                                           │ │
│  │ 📡 /monitoring/*                                         │ │
│  │   └─ Network monitoring endpoints                        │ │
│  │                                                           │ │
│  │ 🔌 /ws/terminal     (WebSocket temps réel)               │ │
│  └───────────────────────────────────────────────────────────┘ │
│                                                                  │
│  ┌───────────────────────────────────────────────────────────┐ │
│  │ Services (Business Logic)                                 │ │
│  │                                                           │ │
│  │ 📁 network_service.py     (Nmap orchestration)            │ │
│  │ 📁 malware_service.py     (Malware analysis)              │ │
│  │ 📁 export_service.py      ⭐ NOUVEAU - CSV/HTML           │ │
│  └───────────────────────────────────────────────────────────┘ │
│                                                                  │
│  ┌───────────────────────────────────────────────────────────┐ │
│  │ Utils                                                     │ │
│  │                                                           │ │
│  │ 🔐 auth.py              ⭐ NOUVEAU - JWT Auth             │ │
│  │ 🔧 helpers.py             (Validation, Sanitization)      │ │
│  └───────────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────────┘
                              │
                              │ subprocess
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│              KALI LINUX TOOLS (50+ Outils)                      │
│                                                                  │
│  ┌──────────────┬──────────────┬──────────────┬────────────┐  │
│  │ Recon        │ Scanning     │ Exploitation │ Malware    │  │
│  │ ├ theHarvester│ ├ nmap      │ ├ metasploit │ ├ yara     │  │
│  │ ├ whois       │ ├ masscan   │ ├ searchsploit│ ├ peframe  │  │
│  │ ├ nslookup    │ ├ enum4linux│ ├ msfvenom   │ ├ clamav   │  │
│  │ ├ dnsrecon    │ ├ nikto     │ ├ beef       │ ├ radare2  │  │
│  │ ├ maltego     │ ├ gobuster  │              │ ├ ghidra   │  │
│  │ ├ recon-ng    │              │              │            │  │
│  └──────────────┴──────────────┴──────────────┴────────────┘  │
│                                                                  │
│  ┌──────────────┬──────────────┬──────────────┬────────────┐  │
│  │ Forensics    │ Wireless     │ Password     │ Web        │  │
│  │ ├ autopsy    │ ├ aircrack-ng│ ├ hydra     │ ├ sqlmap   │  │
│  │ ├ sleuthkit  │ ├ reaver     │ ├ john      │ ├ burpsuite│  │
│  │ ├ binwalk    │ ├ wifite     │ ├ hashcat   │ ├ owasp-zap│  │
│  │ ├ foremost   │ ├ kismet     │ ├ crunch    │ ├ xsstrike │  │
│  │ ├ volatility │ ├ hostapd    │ ├ cewl      │ ├ dalfox   │  │
│  │ ├ exiftool   │              │             │ ├ wpscan   │  │
│  └──────────────┴──────────────┴──────────────┴────────────┘  │
│                                                                  │
│  ┌──────────────┬──────────────┐                                │
│  │ Sniffing     │ Post-Exploit │                                │
│  │ ├ wireshark  │ ├ mimikatz   │                                │
│  │ ├ tcpdump    │ ├ powershell │                                │
│  │ ├ bettercap  │ ├ empire     │                                │
│  │ ├ arpspoof   │              │                                │
│  │ ├ dsniff     │              │                                │
│  │ ├ ettercap   │              │                                │
│  └──────────────┴──────────────┘                                │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│                    DATA LAYER                                   │
│                                                                  │
│  ┌───────────────────────────────────────────────────────────┐ │
│  │ SQLite Database (reports.db)                              │ │
│  │ ┌──────────────────────────────────────────────────────┐ │ │
│  │ │ reports                                              │ │ │
│  │ │ ├ id (TEXT PRIMARY KEY)                              │ │ │
│  │ │ ├ type (TEXT)                                        │ │ │
│  │ │ ├ target (TEXT)                                      │ │ │
│  │ │ ├ results (TEXT - JSON)                              │ │ │
│  │ │ ├ status (TEXT)                                      │ │ │
│  │ │ └─ created_at (TIMESTAMP)                            │ │ │
│  │ └──────────────────────────────────────────────────────┘ │ │
│  └───────────────────────────────────────────────────────────┘ │
│                                                                  │
│  ┌───────────────────────────────────────────────────────────┐ │
│  │ File Storage                                              │ │
│  │ ├ data/reports/  (PDF, CSV, HTML exports)                │ │
│  │ ├ scripts/configs/ (Automation configs)                  │ │
│  │ └─ backend/.env   (JWT config, credentials)              │ │
│  └───────────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────────┘
```

---

## 📊 Flux de Données

### Exemple 1: Dashboard Update
```
User ouvre Dashboard
    ↓
Flutter lit rapports depuis Hive (local)
    ↓
Calcule statistiques (total, succès, échecs)
    ↓
Affiche graphiques (Pie chart, Circular progress)
    ↓
Timeline activité récente
```

### Exemple 2: Export HTML
```
User clique "Export HTML"
    ↓
Frontend → POST /reports/export-all?format=html
    ↓
Backend: ReportExporter.to_html()
    ↓
Génère HTML avec gradient + stats
    ↓
Retourne fichier HTML
    ↓
Frontend télécharge fichier
```

### Exemple 3: Recon Tool
```
User sélectionne "theHarvester"
User entre "example.com"
User clique "Run"
    ↓
Frontend → POST /kali/recon
    ↓
Backend: subprocess.run(["theHarvester", ...])
    ↓
Capture stdout/stderr
    ↓
Retourne résultats au frontend
    ↓
Affichage style terminal
```

---

## 🎯 Matrice des Fonctionnalités

| Catégorie | Backend API | Frontend UI | Statut |
|-----------|-------------|-------------|---------|
| **Dashboard** | ✅ N/A | ✅ Complet | ⭐ NOUVEAU |
| **Auth JWT** | ✅ Complet | ❌ À faire | Session 1 |
| **Network Scan** | ✅ Complet | ✅ Complet | Session 1 |
| **Malware Analysis** | ✅ Complet | ✅ Complet | Session 1 |
| **Bruteforce** | ✅ Complet | ✅ Complet | Session 1 |
| **Reports** | ✅ Complet + Exports | ✅ Complet | Session 2 |
| **CSV/HTML Export** | ✅ Complet | ❌ Via API | ⭐ NOUVEAU |
| **Kali - Recon** | ✅ Complet | ✅ Complet | ⭐ NOUVEAU |
| **Kali - Scanning** | ✅ Complet | ❌ Template | ⭐ NOUVEAU |
| **Kali - Exploit** | ✅ Complet | ❌ Template | ⭐ NOUVEAU |
| **Kali - Malware** | ✅ Complet | ❌ Template | ⭐ NOUVEAU |
| **Kali - Forensics** | ✅ Complet | ❌ Template | ⭐ NOUVEAU |
| **Kali - Wireless** | ✅ Complet | ❌ Template | ⭐ NOUVEAU |
| **Kali - Password** | ✅ Complet | ❌ Template | ⭐ NOUVEAU |
| **Kali - Web** | ✅ Complet | ❌ Template | ⭐ NOUVEAU |

---

## 📈 Progression par Version

### v1.0 (Initial)
- Backend monolithique
- 5 écrans Flutter basiques
- Pas d'authentification
- Pas de tests

### v2.0 (Refactoring)
- Backend modulaire
- WebSocket temps réel
- Design system futuriste
- Documentation complète

### v2.1 (Session 1) ⭐
- Authentification JWT
- Tests unitaires Pytest
- Script installation amélioré
- Modèles Flutter
- Automation scripts

### v2.5 (Session 2) ⭐⭐
- **Dashboard avec graphiques**
- **Exports CSV/HTML**
- **50+ outils Kali intégrés**
- **Navigation dashboard**
- **Structure UI Kali Tools**
- **Recon Screen complet**

---

## 🎉 Conclusion

**Architecture Actuelle:**
- ✅ **Backend:** 27+ endpoints API
- ✅ **Frontend:** 11+ écrans Flutter
- ✅ **Kali Tools:** 50+ outils disponibles
- ✅ **Data:** SQLite + Hive
- ✅ **Real-time:** WebSocket
- ✅ **Security:** JWT Auth
- ✅ **Tests:** Pytest suite
- ✅ **Docs:** 1,500+ lignes

**Prochaine Étape:**
- Créer les 7 écrans Kali restants (templates fournis)
- Ajouter authentification dans le frontend
- Améliorer le monitoring réseau
- Notifications desktop

---

<div align="center">

### 🛡️ AutoMium v2.5 - Complete Architecture

*Dashboard • Exports • 50+ Kali Tools • Beautiful UI*

</div>
