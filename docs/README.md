# Documentation iso3d

Ce dossier contient la documentation technique approfondie de la librairie iso3d.

## Documents disponibles

### [RENDERING.md](RENDERING.md)
Documentation complète du système de rendu isométrique.

**Contenu:**
- Projection isométrique (formules mathématiques)
- Rendu des tuiles (diamant, blocs 3D, sprites)
- Tri en profondeur (depth sorting)
- Pipeline de rendu complet
- Gestion des hauteurs et animations
- Optimisations et performances

**Public cible:**
- Développeurs voulant comprendre le fonctionnement interne
- Contributeurs souhaitant étendre la librairie
- Utilisateurs avancés optimisant leurs performances

## Autres documentations

### Documentation utilisateur

- **[iso3d/README.md](../iso3d/README.md)** - Guide principal de la librairie
- **[maps/README.md](../maps/README.md)** - Format des fichiers map
- **[assets/README.md](../assets/README.md)** - Pré-requis des sprites

### Exemples

- **[main.lua](../main.lua)** - Démo interactive complète
- **[tilesets/](../tilesets/)** - Exemples de tilesets
- **[maps/](../maps/)** - Exemples de maps

## Structure de la documentation

```
WingX/
├── docs/                    # Documentation technique (ce dossier)
│   ├── README.md           # Ce fichier
│   └── RENDERING.md        # Système de rendu
├── iso3d/                  # Code source de la librairie
│   └── README.md           # Guide utilisateur principal
├── maps/                   # Fichiers de maps
│   └── README.md           # Format de fichiers .map
├── assets/                 # Sprites et ressources
│   └── README.md           # Pré-requis des sprites
├── tilesets/               # Définitions de tilesets
│   ├── simple.lua          # Tileset simple
│   ├── basic.lua           # Tileset complet
│   └── animated.lua        # Tileset avec animations
└── main.lua                # Démo interactive
```

## Contribuer à la documentation

Si vous souhaitez améliorer la documentation:

1. **Clarté:** Utilisez des exemples concrets
2. **Visuels:** Diagrammes ASCII pour illustrer les concepts
3. **Code:** Incluez des extraits de code commentés
4. **Structure:** Organisez avec une table des matières
5. **Références:** Liez vers d'autres sections pertinentes

## Questions fréquentes

**Q: Quelle est la différence entre les documents docs/ et les README dans les dossiers?**

R:
- **docs/** : Documentation technique approfondie pour développeurs
- **README dans dossiers** : Guides pratiques pour utilisateurs

**Q: Où trouver des exemples de code?**

R: Les exemples sont dans:
- `main.lua` - Démo complète et interactive
- `iso3d/README.md` - Exemples d'utilisation de l'API
- `docs/RENDERING.md` - Exemples de calculs de rendu

**Q: La documentation est-elle à jour?**

R: Oui, la documentation est mise à jour à chaque changement majeur de la librairie.
