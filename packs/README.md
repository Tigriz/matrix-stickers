Ce dossier regroupe tout les packs de stickers qu'ont créé les IIEns.
Il est possible de visualiser les stickers en allant dans le dossier d'un des packs.

# Utiliser un pack de sticker
Vous pouvez utiliser n'importe quel pack disponible ici.
Pour cela:
1. Télecharger le fichier nomdupack.json du pack de sticker.
2. Ajouter-le au dossier pack de votre stickerpicker
  ```bash
  cp nomdupack.json ~/html/stickerpicker/web/packs
  ```
3. Mettre à jour le fichier index.json se trouvant dans le dossier packs de votre stickerpicker.

# Déposer un pack de sticker
Déposez vos packs ici, vous pouvez faire une pull request.
Il est conseillé de mettre un README avec un aperçu tel que produit par le script `matrixpack.sh`.

# Bonus : Générer une prévisualisation des packs
Pour obtenir une prévisualisation de l'ensemble des packs :
1. Cloner ce dépôt si ce n'est pas déjà fait
  ```bash
  git clone https://git.iiens.net/Tigriz/matrix-stickers.git
  ```
2. Se placer dans le sous-dossier `packs` et lancer le script pour générer la prévisualisation
  ```bash
  cd matrix-stickers/packs
  ./make-preview-page.sh
  ```
3. Ouvrir le `previews.html` généré dans un navigateur
