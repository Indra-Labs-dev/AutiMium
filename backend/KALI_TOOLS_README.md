# Kali Linux Tools - Backend Modular Implementation

## 📁 Structure du Dossier

```
backend/app/routes/kali_tools/
├── __init__.py              # Package initialization, exports all routers
├── recon.py                 # Reconnaissance tools (theHarvester, whois, etc.)
├── scanning.py              # Scanning & enumeration (nmap, masscan, etc.)
├── exploitation.py          # Exploitation tools (searchsploit, msfvenom)
├── malware.py               # Malware analysis (yara, peframe, clamav)
├── forensics.py             # Digital forensics (binwalk, foremost, exiftool)
├── wireless.py              # Wireless attacks (aircrack-ng, reaver)
├── password_attacks.py      # Password attacks (hydra, john, hashcat)
├── web_attacks.py           # Web attacks (sqlmap, nikto, wpscan)
└── sniffing.py              # Sniffing & spoofing (tcpdump, arpspoof)
```

---

## 🎯 Architecture Modulaire

Chaque module est **autonome** et contient :

1. **Router FastAPI** indépendant
2. **Pydantic Models** spécifiques
3. **Endpoints POST** pour l'exécution des outils
4. **Endpoint GET /tools** pour la documentation
5. **Gestion d'erreurs** complète
6. **Timeout handling** adapté

---

## 📦 Modules Détaillés

### 1. Reconnaissance (`recon.py`)

**Outils supportés :**
- ✅ theHarvester - Email/subdomain enumeration
- ✅ whois - Domain information
- ✅ nslookup - DNS lookup
- ✅ dnsrecon - DNS enumeration
- ⚠️ recon-ng - Framework (nécessite setup manuel)

**Endpoint:** `POST /api/kali/recon/`

**Request:**
```json
{
  "target": "example.com",
  "tool": "theHarvester",
  "options": "-b google,linkedin"
}
```

---

### 2. Scanning (`scanning.py`)

**Outils supportés :**
- ✅ nmap - Network mapper
- ✅ masscan - Fast port scanner
- ✅ enum4linux - SMB enumeration
- ✅ nikto - Web server scanner
- ✅ gobuster - Directory brute-forcer

**Endpoint:** `POST /api/kali/scan/`

**Request:**
```json
{
  "target": "192.168.1.1",
  "tool": "nmap",
  "ports": "22,80,443",
  "aggressive": true,
  "options": "-sV"
}
```

---

### 3. Exploitation (`exploitation.py`)

**Outils supportés :**
- ✅ searchsploit - Exploit database search
- ✅ msfvenom - Payload generator
- ⚠️ metasploit - Console interactive

**Endpoint:** `POST /api/kali/exploit/`

**Request:**
```json
{
  "target": "apache",
  "tool": "searchsploit"
}
```

---

### 4. Malware Analysis (`malware.py`)

**Outils supportés :**
- ✅ yara - Pattern matching
- ✅ peframe - PE file analyzer
- ✅ clamav - Antivirus scanner
- ✅ strings - Extract strings

**Endpoint:** `POST /api/kali/malware/`

**Request:**
```json
{
  "target": "/path/to/suspicious.exe",
  "tool": "yara",
  "rules": "/path/to/rules.yar"
}
```

---

### 5. Forensics (`forensics.py`)

**Outils supportés :**
- ✅ binwalk - Firmware analysis
- ✅ foremost - File carving
- ✅ exiftool - Metadata extraction
- ✅ strings - String extraction
- ⚠️ autopsy - GUI required

**Endpoint:** `POST /api/kali/forensics/`

**Request:**
```json
{
  "target": "/path/to/image.bin",
  "tool": "binwalk",
  "output_dir": "/tmp/extracted"
}
```

---

### 6. Wireless Attacks (`wireless.py`)

**Outils supportés :**
- ✅ airodump-ng - Packet capture
- ✅ aireplay-ng - Deauthentication attacks
- ✅ aircrack-ng - WEP/WPA cracking
- ✅ reaver - WPS attacks

**Endpoint:** `POST /api/kali/wireless/`

**Request:**
```json
{
  "interface": "wlan0mon",
  "tool": "airodump-ng",
  "channel": 6,
  "target_bssid": "AA:BB:CC:DD:EE:FF"
}
```

---

### 7. Password Attacks (`password_attacks.py`)

**Outils supportés :**
- ✅ hydra - Online brute-force
- ✅ john - Offline password cracker
- ✅ hashcat - GPU-accelerated cracking

**Endpoint:** `POST /api/kali/password/`

**Request:**
```json
{
  "service": "ssh",
  "target": "192.168.1.1",
  "tool": "hydra",
  "username_list": "/usr/share/wordlists/users.txt",
  "password_list": "/usr/share/wordlists/rockyou.txt",
  "port": 22
}
```

---

### 8. Web Application Attacks (`web_attacks.py`)

**Outils supportés :**
- ✅ sqlmap - SQL injection
- ✅ nikto - Web server scanner
- ✅ wpscan - WordPress scanner
- ✅ dalfox - XSS scanner

**Endpoint:** `POST /api/kali/web/`

**Request:**
```json
{
  "target": "http://example.com/vuln.php?id=1",
  "tool": "sqlmap",
  "options": "--dbs --batch"
}
```

---

### 9. Sniffing & Spoofing (`sniffing.py`)

**Outils supportés :**
- ✅ tcpdump - Packet capture
- ✅ arpspoof - ARP cache poisoning
- ⚠️ bettercap - MITM framework (manuel)
- ⚠️ wireshark - GUI required

**Endpoint:** `POST /api/kali/sniffing/`

**Request:**
```json
{
  "interface": "eth0",
  "tool": "tcpdump",
  "duration": 30
}
```

---

## 🔧 Comment Utiliser

### Via API REST

```bash
# Lancer un scan Nmap
curl -X POST http://localhost:8000/api/kali/scan/ \
  -H "Content-Type: application/json" \
  -d '{
    "target": "192.168.1.1",
    "tool": "nmap",
    "ports": "22,80,443",
    "aggressive": false
  }'

# Obtenir la liste des outils de reconnaissance
curl http://localhost:8000/api/kali/recon/tools
```

### Via Flutter Frontend

Le frontend Flutter appelle automatiquement ces endpoints via les écrans :
- `kali_recon_screen.dart`
- `kali_scanning_screen.dart`
- `kali_exploitation_screen.dart`
- etc.

---

## 🎯 Features Communes à Tous les Modules

### Response Format

Tous les endpoints retournent :

```json
{
  "success": true,
  "tool": "nmap",
  "target": "192.168.1.1",
  "output": "Starting Nmap 7.92...\nNmap done: 1 IP address...",
  "errors": "",
  "returncode": 0
}
```

### Error Handling

- **400** - Bad Request (outil inconnu, paramètres manquants)
- **408** - Timeout (opération trop longue)
- **503** - Service Unavailable (outil non installé)
- **500** - Internal Server Error

### Timeouts par Défaut

- Reconnaissance: 120s
- Scanning: 300s
- Exploitation: 60-120s
- Malware: 120-300s
- Forensics: 300s
- Wireless: 10-300s
- Password: 300-600s
- Web: 120-600s
- Sniffing: Configurable (défaut 30s)

---

## 📝 Avantages de l'Architecture Modulaire

### ✅ Maintenance Facilitée
- Chaque module est indépendant
- Modifications isolées
- Tests unitaires simplifiés

### ✅ Évolutivité
- Ajout facile de nouveaux outils
- Pas d'impact sur les autres modules
- Code plus lisible et organisé

### ✅ Réutilisation
- Modules importables individuellement
- Possibilité de créer des combinaisons
- Documentation automatique par module

### ✅ Debugging
- Logs séparés par catégorie
- Erreurs contextualisées
- Stack traces claires

---

## 🚀 Testing

### Tester un Module

```bash
# Importer le module
from app.routes.kali_tools import recon_router

# Tester l'endpoint
response = await recon_router.post("/", json={
    "target": "example.com",
    "tool": "whois"
})
```

### Tester avec Pytest

```python
def test_recon_whois():
    response = client.post("/api/kali/recon/", json={
        "target": "google.com",
        "tool": "whois"
    })
    assert response.status_code == 200
    assert response.json()["success"] == True
```

---

## 🛡️ Sécurité

### Précautions Implémentées

1. **Timeouts** - Évite les processus infinis
2. **Validation** - Pydantic models pour valider les inputs
3. **Error Handling** - Messages d'erreur sécurisés
4. **Filesystem** - Écriture limitée à `/tmp/`
5. **Privileges** - Nécessite les permissions Kali

### Avertissements

⚠️ **Ces outils sont puissants !**
- Utilisez uniquement dans un environnement contrôlé
- Ayez l'autorisation écrite des cibles
- Respectez les lois locales sur la cybersécurité

---

## 📚 Ressources

### Documentation Officielle des Outils

- [Kali Tools Documentation](https://www.kali.org/docs/)
- [Nmap Guide](https://nmap.org/book/)
- [Metasploit Unleashed](https://www.offensive-security.com/metasploit-unleashed/)
- [OWASP Testing Guide](https://owasp.org/www-project-web-security-testing-guide/)

### Wordlists Recommandées

- `/usr/share/wordlists/rockyou.txt` - Passwords
- `/usr/share/wordlists/dirb/common.txt` - Directories
- `/usr/share/wordlists/seclists/` - Comprehensive lists

---

## 🎉 Conclusion

L'architecture modulaire des Kali Tools offre :

- ✅ **9 catégories** d'outils
- ✅ **50+ outils** supportés
- ✅ **Code maintenable** et évolutif
- ✅ **Documentation** automatique
- ✅ **Erreurs gérées** proprement
- ✅ **Prêt pour la production**

**AutoMium v2.5** - *The Ultimate Kali Linux GUI* 🚀
