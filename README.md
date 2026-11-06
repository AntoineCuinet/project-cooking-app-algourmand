# Algourmand - Cooking application

Algourmand est une application IOS native en SwiftUI pour la gestion de recettes de cuisine et de repas s'interfaçant avec une API REST Laravel.

---

## Architecture

Le projet est découpé en modules gérés via **Tuist** :

- **`Algourmand`** : Target principale de l'application
- **`AlgourmandCore`** : Framework métier
- **`AlgourmandCoreUI`** : Framework UI partagé
- **`AlgourmandTests`** : Target de tests unitaires

---

## Outils

- **Générateur de projet & Build system** : [Tuist](https://tuist.io/)
- **Gestionnaire de versions d'outils** : [Mise](https://mise.jdx.dev/) (`.mise.toml`).
- **Linter & Formateur** : [SwiftLint](https://github.com/realm/SwiftLint) (`.swiftlint.yml`) et [SwiftFormat](https://github.com/nicklockwood/SwiftFormat) (`.swiftformat`).
- **Scripts de build** : `scripts/lint.sh` et `scripts/strip_symbols.sh`.

---

## Lancement

### Prérequis

- Xcode 15+
- Tuist

### Générer et ouvrir le projet dans Xcode

À la racine du projet, lancez :

```bash
tuist generate
```

Tuist génère `Algourmand.xcworkspace` et ouvre automatiquement Xcode.
