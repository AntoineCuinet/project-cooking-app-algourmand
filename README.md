# Algourmand - Application iOS de Recettes

Algourmand est une application iOS native en **SwiftUI** dédiée à la gestion de recettes de cuisine et de repas, s'interfaçant avec une API REST **Laravel** ([dépôt backend](https://github.com/gaspardquentin/algourmand)) et une API REST publique gratuite de base de données de recettes : [TheMealDB](https://www.themealdb.com/).

![Logo](screenshot.png)

## Architecture

Le projet est entièrement modulaire et piloté par **Tuist** pour éviter les conflits Git sur les fichiers `.xcodeproj` / `.xcworkspace` :

- **`Algourmand`** : Target principale de l'application (cycle de vie `@main`, navigation, écrans racines).
- **`AlgourmandCore`** : Framework métier contenant :
  - **Modèles & DTOs** (`UserDTO`, `AuthResponse`, `RegisterRequest`, `LoginRequest`, `APIErrorResponse`, `Recipe`).
  - **Services Réseau** (`AuthServiceProtocol`, `APIAuthService`, `MockAuthService`).
  - **ViewModels** (`AuthViewModel`).
- **`AlgourmandCoreUI`** : Framework UI réutilisable (Design System, composants de cartes de recettes, styles partagés).
- **`AlgourmandTests`** : Target de tests unitaires automatisés validant la logique métier et les flux d'authentification.

---

## Système d'Authentification & API REST

L'application intègre les contrats d'API pour les endpoints d'authentification :

### Double mode de fonctionnement

L'écran principal de l'application propose un sélecteur permettant de basculer instantanément entre deux modes :

1. **Mode Mock Local (In-Memory)** *(par défaut)* :
   - Fonctionne **immédiatement sans aucun serveur**.
   - Données de test pré-remplies : `quentin@algourmand.ch` / `password123`.
   - Simulation fidèle des réponses d'erreur HTTP (`401 Invalid credentials`, `422 Email already taken`, `401 Unauthenticated`).
2. **Mode API Laravel (`http://127.0.0.1:8000/api/v1`)** :
   - Appels réels via `URLSession`.
   - Dès que le backend est lancé (`php artisan serve`), les requêtes partent directement sur le serveur local.

---

## Outils

- **Générateur de projet & Build system** : [Tuist](https://tuist.io/)
- **Gestionnaire de versions d'outils** : [Mise](https://mise.jdx.dev/) (`.mise.toml`).
- **Linter & Formateur** : [SwiftLint](https://github.com/realm/SwiftLint) (`.swiftlint.yml`) et [SwiftFormat](https://github.com/nicklockwood/SwiftFormat) (`.swiftformat`).
- **Scripts de build** : `scripts/lint.sh` et `scripts/strip_symbols.sh`.

---

## Lancement

### 1. Prérequis

- macOS avec Xcode 15+ (ou supérieur)
- Tuist installé (`brew install tuist` ou via `mise install`)

### 2. Générer et ouvrir le projet

À la racine du projet, lancez :

```bash
tuist generate
```

Le workspace `Algourmand.xcworkspace` est généré automatiquement et s'ouvre dans Xcode.

### 3. Lancer les tests unitaires

Appuyez sur `Cmd + U` dans Xcode ou lancez en ligne de commande :

```bash
xcodebuild test -workspace Algourmand.xcworkspace -scheme AlgourmandTests -destination 'platform=macOS'
```
