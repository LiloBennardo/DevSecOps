# Rapport DevSecOps — Pipeline CI/CD sécurisé

**Étudiant :** _(à compléter)_  **Module :** 5DVSCOPS 2025/2026  **Dépôt :** _(lien GitHub)_

## 1. Démarche

Le projet implémente un pipeline GitHub Actions en trois étages (lint, build+scan, policy) autour d'une petite API Flask conteneurisée et déployée via un manifeste Kubernetes. La sécurité est « shift-left » : chaque push/PR déclenche linting, scan SCA, scan image et vérification de politique.

## 2. Outils intégrés

| Étage | Outil | Rôle |
|---|---|---|
| Lint YAML | `yamllint` | Qualité des manifestes k8s et workflows |
| Lint Dockerfile | `hadolint` | Bonnes pratiques Docker |
| SCA | `trivy fs` | Vulnérabilités des dépendances Python |
| Image scan | `trivy image` | CVE dans les couches de l'image |
| Policy-as-code | `conftest` + Rego | Refus des pods root / privilèges |
| Supply chain | Dependabot | MAJ auto pip / docker / actions |
| Reporting | SARIF → Security tab | Centralisation des findings |

## 3. Vulnérabilités typiquement détectées

- **Image de base `python:3.12-slim`** : quelques CVE HIGH sur `libc`, `openssl`, `zlib` (souvent _unfixed_ — d'où `ignore-unfixed: true`).
- **Dépendances** : selon versions, `Werkzeug` / `Flask` peuvent remonter des CVE MEDIUM (ex. ReDoS, debugger exposé).
- **Dockerfile** : hadolint signale l'absence de version pinned si on retire `--no-cache-dir` ou si on utilise `latest`.
- **Manifeste k8s** : sans `securityContext`, Conftest échoue (pod root).

## 4. Recommandations

1. **Pinner** les versions de base (`python:3.12.5-slim@sha256:...`).
2. **Multi-stage build** pour réduire la surface (retirer `pip`, compilateurs).
3. **Renouveler** régulièrement via Dependabot + rebuild planifié.
4. **Gate** : passer `exit-code: 1` sur Trivy CRITICAL une fois le backlog traité.
5. **Signer** les images (cosign) et activer l'attestation SLSA.
6. **Runtime** : `readOnlyRootFilesystem`, `drop: ALL`, NetworkPolicy restrictive.

## 5. Réflexion sécurité

Le DevSecOps déplace les contrôles au plus tôt, mais ne dispense pas du RASP/monitoring runtime. Les scans statiques voient les CVE connues, pas la logique métier — un SAST (ex. Semgrep) et un DAST complèteraient utilement. La policy-as-code (Rego) matérialise la gouvernance en code versionné, auditable, testable : c'est la brique la plus durable du pipeline.

## 6. Livrables

- Dépôt GitHub avec Actions activées : _(lien)_
- Workflow : `.github/workflows/ci.yml`
- Politique Conftest : `policy/k8s_security.rego`
- Captures des logs Trivy et du job Conftest : _(à joindre)_
