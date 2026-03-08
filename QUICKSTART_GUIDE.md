# 🚀 AutoMium - Guide de Démarrage Rapide

## ⚡ Installation et Test en 5 Minutes

### Étape 1: Installation des Dépendances

```bash
# Se placer dans le répertoire du projet
cd /home/codelie/AutiMium

# Lancer le script d'installation
chmod +x install.sh
./install.sh
```

**Ce que fait le script:**
- ✅ Installe les dépendances Python (FastAPI, JWT, etc.)
- ✅ Installe les outils Kali (nmap, yara, hydra)
- ✅ Configure Flutter SDK si nécessaire
- ✅ Crée le fichier `.env` avec configuration JWT
- ✅ Active le support Linux Desktop pour Flutter

---

### Étape 2: Configuration de la Sécurité

**⚠️ IMPORTANT: Changez les credentials par défaut!**

Éditez `backend/.env`:
```bash
nano backend/.env
```

Changez ces valeurs:
```env
JWT_SECRET_KEY=votre-clé-très-secrète-ici
DEFAULT_ADMIN_PASSWORD=NouveauMotDePasseFort!
```

**Générer une clé secrète:**
```bash
python3 -c "import secrets; print(secrets.token_urlsafe(32))"
```

---

### Étape 3: Tester le Backend

```bash
# Démarrer le backend
cd backend
source venv/bin/activate
./start.sh
```

**Vérifier que ça marche:**
```bash
# Dans un autre terminal
curl http://localhost:8000/health
```

**Réponse attendue:**
```json
{
  "status": "healthy",
  "database": "connected"
}
```

---

### Étape 4: Tester l'Authentification JWT

```bash
# Login avec les credentials admin
curl -X POST "http://localhost:8000/auth/login" \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -d "username=admin&password=AutoMium2024!"
```

**Réponse:**
```json
{
  "access_token": "eyJhbGciOiJIUzI1NiIs...",
  "token_type": "bearer",
  "expires_in": 86400
}
```

**Utiliser le token:**
```bash
TOKEN="eyJhbGciOiJIUzI1NiIs..."  # Copiez le token ci-dessus

curl -X GET "http://localhost:8000/auth/me" \
  -H "Authorization: Bearer $TOKEN"
```

---

### Étape 5: Exécuter les Tests Unitaires

```bash
cd backend
./run_tests.sh
```

**Résultat attendu:**
```
✅ All tests passed!

Test Summary:
-------------
15 tests collected
```

---

### Étape 6: Tester le Frontend Flutter

```bash
# Dans un nouveau terminal
cd frontend

# Récupérer les dépendances
flutter pub get

# Lancer l'application
flutter run -d linux
```

**Si Flutter n'est pas installé:**
```bash
# Le script install.sh devrait l'avoir installé
# Vérifiez:
flutter --version

# Si non trouvé, redémarrez le terminal ou:
source ~/.bashrc
flutter --version
```

---

### Étape 7: Tester l'Automatisation

```bash
# Test d'un script d'automatisation réseau
python scripts/automation.py network 127.0.0.1

# Test d'un script personnalisé
python scripts/automation.py custom scripts/configs/quick_malware_triage.json
```

**Les rapports sont sauvegardés dans:**
```
data/reports/
```

---

## 🎯 Checklist de Validation

### Backend
- [ ] Le backend démarre sans erreur
- [ ] Endpoint `/health` retourne "healthy"
- [ ] Login JWT fonctionne
- [ ] Token permet d'accéder à `/auth/me`
- [ ] Tous les tests passent (`./run_tests.sh`)

### Frontend
- [ ] Flutter se lance sans erreur
- [ ] L'interface graphique s'affiche
- [ ] La connexion au backend est établie
- [ ] Les écrans sont fonctionnels

### Automation
- [ ] Scripts Python s'exécutent correctement
- [ ] Les rapports JSON sont générés
- [ ] Les timeouts fonctionnent

---

## 🔧 Dépannage Rapide

### Problème: Port 8000 déjà utilisé
```bash
# Trouver le processus
lsof -i :8000

# Tuer le processus
kill -9 <PID>
```

### Problème: Module introuvable (Python)
```bash
cd backend
source venv/bin/activate
pip install -r requirements.txt
```

### Problème: Flutter ne trouve pas Linux desktop
```bash
flutter config --enable-linux-desktop
sudo apt install -y clang cmake ninja-build pkg-config libgtk-3-dev
```

### Problème: Échec des tests d'authentification
```bash
# Vérifier que .env existe
cat backend/.env

# Régénérer un hash de mot de passe
cd backend
source venv/bin/activate
python3 -c "from passlib.context import CryptContext; print(CryptContext(schemes=['bcrypt']).hash('NouveauMDP'))"
```

---

## 📚 Documentation Complète

- **README principal:** `README.md`
- **Améliorations détaillées:** `IMPROVEMENTS_SUMMARY.md`
- **Architecture backend:** `backend/ARCHITECTURE.md`
- **Documentation API:** http://localhost:8000/docs
- **Cahier des charges:** `docs/Cahier_des_Charges.md`

---

## 🎉 Vous Êtes Prêt!

Votre AutoMium v2.1 est maintenant:
- ✅ **Sécurisé** avec authentification JWT
- ✅ **Testé** avec pytest
- ✅ **Documenté** avec guides complets
- ✅ **Automatisé** avec scripts Python
- ✅ **Maintenable** avec architecture améliorée

**Prochaine étape:** Lancer `./start.sh` pour démarrer l'application complète!

---

<div align="center">

### 🛡️ AutoMium v2.1 - Ready for Action!

*Installation • Configuration • Test • Production*

</div>
