# AFFiNE on Coolify 🚀

> One-click self-hosted [AFFiNE](https://affine.pro/) — an open-source Notion + Miro alternative — deployable on any VPS running [Coolify](https://coolify.io/).

AFFiNE gives you collaborative docs, whiteboards, and databases in one workspace, fully under your control.

---

## What's inside

| File | Purpose |
|---|---|
| `docker-compose.yml` | AFFiNE + PostgreSQL + Redis stack |
| `.env.example` | All config variables with comments |
| `.gitignore` | Keeps your real `.env` and data out of git |

---

## Prerequisites

- A VPS with [Coolify](https://coolify.io/) installed (v4+)
- A domain pointing to your VPS (for HTTPS)
- That's it — Coolify handles the reverse proxy and SSL

---

## Deploy on Coolify (recommended)

### 1 — Fork / clone this repo

Fork this repository to your own GitHub account so Coolify can pull from it.

### 2 — Create a new project in Coolify

1. Open your Coolify dashboard → **Projects** → **New Project**
2. Choose **Docker Compose** as the deployment type
3. Connect this GitHub repository
4. Set the **Docker Compose file path** to `docker-compose.yml`

### 3 — Set your environment variables

In Coolify's **Environment Variables** panel, add every variable from `.env.example` with real values.

The critical ones:

| Variable | Example | Notes |
|---|---|---|
| `AFFINE_SERVER_EXTERNAL_URL` | `https://affine.yourdomain.com` | Must match your Coolify domain |
| `DB_PASSWORD` | *(random string)* | Use `openssl rand -hex 16` |
| `AFFINE_ADMIN_EMAIL` | `admin@yourdomain.com` | First admin account |
| `AFFINE_ADMIN_PASSWORD` | *(strong password)* | Change after first login |

> 💡 **Tip:** In Coolify you can mark variables as **secret** so they're never shown in logs.

### 4 — Configure the domain in Coolify

- Set your domain (e.g. `affine.yourdomain.com`) in the Coolify service settings
- Enable **HTTPS / Let's Encrypt** — Coolify handles the cert automatically

### 5 — Deploy

Hit **Deploy** in Coolify. It will:
1. Pull the images
2. Run the database migration job
3. Start AFFiNE

Visit `https://affine.yourdomain.com` — you'll be prompted to create your admin account on first run.

---

## Manual deploy (plain Docker Compose, no Coolify)

```bash
# Clone the repo
git clone https://github.com/oreste-abizera/affine-coolify.git
cd affine-coolify

# Create your env file
cp .env.example .env
nano .env   # fill in all the values

# Create data directories
mkdir -p affine/storage affine/config

# Start everything
docker compose up -d

# Follow logs
docker compose logs -f affine
```

AFFiNE will be available at `http://YOUR_SERVER_IP:3010`.  
Put Nginx / Caddy / Traefik in front for HTTPS.

---

## Updating AFFiNE

### On Coolify
Just click **Redeploy** — Coolify pulls the latest `stable` image automatically.

### Manually
```bash
docker compose pull
docker compose up -d
```

To pin a specific version, set `AFFINE_REVISION=0.25.7` (or whichever tag you want) in your `.env`.

---

## Backup

Your data lives in two Docker volumes:
- `affine_postgres_data` — all your pages, databases, workspaces
- `affine_redis_data` — ephemeral cache (safe to lose)
- `./affine/storage` — uploaded files / blobs

### Quick backup script

```bash
#!/bin/bash
DATE=$(date +%Y%m%d_%H%M%S)
BACKUP_DIR=~/affine-backups/$DATE
mkdir -p "$BACKUP_DIR"

# Dump PostgreSQL
docker exec affine_postgres pg_dump -U affine affine | gzip > "$BACKUP_DIR/postgres.sql.gz"

# Copy blob storage
cp -r ./affine/storage "$BACKUP_DIR/storage"

echo "Backup saved to $BACKUP_DIR"
```

---

## Troubleshooting

**AFFiNE exits with migration errors**  
PostgreSQL wasn't ready in time. Run:
```bash
docker compose restart affine
```

**Real-time collaboration / WebSocket errors**  
Make sure your reverse proxy forwards WebSocket connections.  
In Coolify this is enabled by default. For Nginx, add:
```nginx
proxy_http_version 1.1;
proxy_set_header Upgrade $http_upgrade;
proxy_set_header Connection "upgrade";
```

**Can't create accounts / invite users**  
Check that `AFFINE_SERVER_EXTERNAL_URL` exactly matches the URL you're browsing from (including `https://`).

**View all logs**  
```bash
docker compose logs -f
```

---

## Resources

- [AFFiNE official docs](https://docs.affine.pro/self-host-affine/)
- [AFFiNE GitHub](https://github.com/toeverything/affine)
- [Coolify docs](https://coolify.io/docs)

---

## License

This deployment configuration is released into the public domain — use it however you like.  
AFFiNE itself is licensed under the [AGPL-3.0 license](https://github.com/toeverything/affine/blob/canary/LICENSE).
