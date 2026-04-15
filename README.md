# Projet DevSecOps - 5DVSCOPS 2025/2026

Pipeline GitHub Actions sécurisant une petite API Flask conteneurisée.

## Structure

- `app.py` / `requirements.txt` — API Flask (2 endpoints : `/`, `/health`)
- `Dockerfile` — image basée sur `python:3.12-slim`, utilisateur non-root (UID 10001)
- `k8s/deployment.yaml` — Deployment + Service Kubernetes avec `securityContext` durci
- `policy/k8s_security.rego` — politique Rego/Conftest : refus des pods root
- `.github/workflows/ci.yml` — pipeline CI/CD

## Pipeline (jobs)

1. **lint** : `yamllint` (manifestes + workflows) + `hadolint` (Dockerfile)
2. **build-and-scan** :
   - `docker build`
   - `trivy fs` → scan dépendances (`requirements.txt`)
   - `trivy image` → scan vulnérabilités de l'image
   - upload SARIF vers l'onglet Security GitHub
3. **policy** : `conftest test k8s/ -p policy/` — échoue si un pod tourne en root

## Exécution locale

```bash
docker build -t flask-api:ci .
docker run -p 5000:5000 flask-api:ci
# dans un autre terminal
curl localhost:5000/health

# scans en local
trivy fs .
trivy image flask-api:ci
conftest test k8s/ -p policy/
```

## Mise en route (GitHub)

```bash
git init
git add .
git commit -m "Initial DevSecOps pipeline"
git branch -M main
git remote add origin https://github.com/<USER>/<REPO>.git
git push -u origin main
```

Activer Actions dans Settings → Actions → Allow all.
Activer Dependabot : Settings → Code security → Dependabot alerts + security updates.
