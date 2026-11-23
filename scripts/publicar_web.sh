#!/usr/bin/env bash
# Compila a versão Web e publica SOMENTE a branch gh-pages (a main não é tocada).
# Execute na raiz do projeto, no Codespaces, com o git já autenticado.
set -euo pipefail

REPO_URL="https://github.com/dougpsnts/edit-doc-flutter.git"

flutter pub get
flutter build web --release --base-href "/edit-doc-flutter/"

cd build/web
touch .nojekyll
rm -rf .git
git init -q
git checkout -q -b gh-pages
git add -A
git commit -q -m "Publica versão Web (GitHub Pages)"
git remote add origin "$REPO_URL"
# --force afeta apenas gh-pages, que contém só os arquivos estáticos gerados.
git push --force origin gh-pages
echo "Publicado. Em Settings > Pages use: branch gh-pages, pasta / (root)."
echo "URL esperada: https://dougpsnts.github.io/edit-doc-flutter/"
