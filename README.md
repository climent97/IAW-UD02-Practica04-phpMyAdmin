# UD02 — Pràctica 4: phpMyAdmin

Documentació de la pràctica d'Implantació d'Aplicacions Web (IAW, 2ASIX).

La memòria tècnica amb els passos i les captures està en [`index.md`](index.md), preparada per a publicar amb GitHub Pages.

## Contingut

- `index.md`: documentació de la pràctica.
- `conf/site_phpmyadmin`: exemple de configuració del bloc `location` de Nginx.
- `scripts/.env`: rutes i opcions de configuració sense secrets.
- `scripts/install_lemp.sh`: automatització de la instal·lació de la pila LEMP.
- `scripts/install_phpmyadmin.sh`: instal·lació i protecció bàsica de phpMyAdmin.
- `capturas/`: captures que documenten les fases de la pràctica. Les imatges amb valors sensibles han sigut redactades per a publicació.

## Publicar amb GitHub Pages

1. Pugeu els fitxers a la branca `main`.
2. Obriu **Settings → Pages** en el repositori.
3. En **Build and deployment**, seleccioneu **Deploy from a branch**.
4. Seleccioneu la branca `main` i la carpeta `/(root)` i premeu **Save**.
5. Espereu que finalitze la publicació; l'URL apareixerà en la pàgina de configuració de Pages.

## Seguretat

No publiqueu contrasenyes reals, el fitxer `/etc/nginx/.htpasswd`, còpies de configuració amb secrets ni captures que mostren contrasenyes o hashes. El fitxer `scripts/.env` d'aquest repositori només conté rutes i opcions no secretes; els scripts sol·liciten les contrasenyes de manera interactiva.

La concessió `GRANT ALL PRIVILEGES ON *.* ... WITH GRANT OPTION` permet administrar totes les bases de dades i delegar privilegis. Utilitzeu-la només en un laboratori quan siga explícitament necessari; en altres casos, limiteu els privilegis a la base de dades corresponent.
