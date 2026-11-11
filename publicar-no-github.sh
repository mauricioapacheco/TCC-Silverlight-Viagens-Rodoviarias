#!/usr/bin/env bash
set -euo pipefail

REPO="mauricioapacheco/TCC-Silverlight-Viagens-Rodoviarias"
cd "$(dirname "${BASH_SOURCE[0]}")"

for BIN in git gh; do
  if ! command -v "$BIN" >/dev/null 2>&1; then
    echo "ERRO: $BIN não encontrado. Instale com: sudo apt install git gh"
    exit 1
  fi
done

if ! gh auth status >/dev/null 2>&1; then
  echo "Faça login no GitHub para criar o repositório."
  gh auth login --hostname github.com --web --git-protocol https
fi

if [[ ! -d .git ]]; then
  git init -b main
fi

git switch -C main

if ! git config user.email >/dev/null || ! git config user.name >/dev/null; then
  echo "Configure seu nome/e-mail do Git antes de publicar (git config --global user.name / user.email)."
  exit 1
fi

git add README.md .gitignore documentos imagens publicar-no-github.sh
if ! git diff --cached --quiet; then
  git commit -m "docs: preserva TCC Silverlight de 2011 e documentação histórica"
fi

if ! gh repo view "$REPO" >/dev/null 2>&1; then
  gh repo create "$REPO" --public --description "TCC de Ciência da Computação (2011): consulta de viagens rodoviárias com Silverlight, C#, XAML e SQL Server. Acervo acadêmico histórico."
fi

URL="https://github.com/${REPO}.git"
if git remote get-url origin >/dev/null 2>&1; then
  if [[ "$(git remote get-url origin)" != "$URL" ]]; then
    echo "ERRO: remote origin aponta para outro repositório. Nenhum push realizado."
    exit 1
  fi
else
  git remote add origin "$URL"
fi

git push -u origin main
printf '\nPublicado em: https://github.com/%s\n' "$REPO"
