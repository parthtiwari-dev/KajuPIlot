# Oracle Deployment

This is the production path for the private KajuPilot VPS deployment.

Public traffic should enter only through Caddy on `80/443`.
Do not expose the API, admin app, Postgres, or Redis ports directly.

## Public URLs

For the current Oracle IP:

```text
API:   https://api.141.148.213.89.sslip.io/api/v1
Admin: https://admin.141.148.213.89.sslip.io
```

The release APK must be built with the API URL above.

## Oracle Cloud Ports

The OCI security list needs:

```text
22   TCP   0.0.0.0/0   SSH
80   TCP   0.0.0.0/0   Caddy HTTP challenge and redirect
443  TCP   0.0.0.0/0   HTTPS for API and admin
```

Do not add public rules for:

```text
3000  API container
3001  Admin container
5432  Postgres
6379  Redis
```

Those ports stay private inside Docker.

## SSH

From Windows:

```powershell
ssh -i "C:\great learning self paced\z Final Projects\oracle-auto-provision\oracle_key" ubuntu@141.148.213.89
```

## Server Preflight

Check whether another service is already using `80` or `443`:

```bash
sudo ss -ltnp | grep -E ':80|:443' || true
```

If another project is already bound to `80/443`, stop and route KajuPilot through that existing reverse proxy instead of starting the bundled Caddy container.

Open `80/443` in the Ubuntu firewall without touching other existing ports:

```bash
sudo iptables -C INPUT -p tcp --dport 80 -j ACCEPT 2>/dev/null || sudo iptables -I INPUT -p tcp --dport 80 -j ACCEPT
sudo iptables -C INPUT -p tcp --dport 443 -j ACCEPT 2>/dev/null || sudo iptables -I INPUT -p tcp --dport 443 -j ACCEPT
sudo netfilter-persistent save || true
```

Install Docker if it is not already installed:

```bash
sudo apt-get update
sudo apt-get install -y ca-certificates curl gnupg git make openssl

sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg

. /etc/os-release
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $VERSION_CODENAME stable" | sudo tee /etc/apt/sources.list.d/docker.list

sudo apt-get update
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

sudo usermod -aG docker ubuntu
```

Log out and SSH back in after adding the Docker group:

```bash
exit
```

## Deploy From Git

After local changes are pushed to GitHub:

```bash
cd ~
git clone https://github.com/parthtiwari-dev/KajuPIlot.git kajupilot
cd ~/kajupilot
```

For later updates:

```bash
cd ~/kajupilot
git pull origin main
```

If GitHub auth is annoying on the VPS, package the repo locally and copy the tarball instead.

## Generate Production Env

On Oracle:

```bash
cd ~/kajupilot
bash scripts/oracle-prod-env.sh
```

The script prompts for:

- admin username
- admin password
- setup code
- AI provider
- OpenAI key
- optional Groq key

It writes `.env` with:

```text
DEPLOY_TARGET=production
API_HOST=api.141.148.213.89.sslip.io
ADMIN_HOST=admin.141.148.213.89.sslip.io
NEXT_PUBLIC_API_URL=https://api.141.148.213.89.sslip.io/api/v1
ALLOWED_ORIGINS=https://admin.141.148.213.89.sslip.io
```

## Start Production

Use the explicit production targets:

```bash
make prod-up
make prod-migrate
make prod-ps
make prod-health
```

Equivalent switch form:

```bash
make up DEPLOY_TARGET=prod
make migrate DEPLOY_TARGET=prod
```

Prefer `prod-*` on the VPS so it is obvious that no dev port override is being used.

## Verify

From the server or your laptop:

```bash
curl -fsS https://api.141.148.213.89.sslip.io/api/v1/health
curl -fsS https://api.141.148.213.89.sslip.io/api/v1/ai/providers
```

Open admin:

```text
https://admin.141.148.213.89.sslip.io
```

Admin has two login layers:

```text
Caddy popup: ADMIN_USER + admin password
Admin screen: ADMIN_USER + ADMIN_SECRET
```

The production env generator uses the same password for both.

## Build The Phone APK

On Windows, after the deployed API is healthy:

```powershell
cd "C:\great learning self paced\z Final Projects\KajuPIlot"
make release-oracle ORACLE_IP=141.148.213.89
adb install -r "kajupilot\build\app\outputs\flutter-apk\app-arm64-v8a-release.apk"
```

This bakes the deployed API URL into the APK:

```text
https://api.141.148.213.89.sslip.io/api/v1
```

The mobile app syncs through that public HTTPS API. Postgres, Redis, and raw container ports remain private.
