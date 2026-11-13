# Carbonio CE Docker Compose — research sample

This directory tracks an upstream-based Docker Compose example for **development/testing**, not a production-ready Carbonio installation.

## What this is

The Compose definition is adapted from Zextras' `carbonio-dockerization-tools` project. The upstream project provides a multi-container Carbonio CE stack and supporting files. The image references currently point at the Zextras development registry; access requires the appropriate Zextras VPN/registry access and credentials.

Official references:
- Dockerization tooling: https://github.com/zextras/carbonio-dockerization-tools
- Carbonio CE architecture: https://docs.zextras.com/carbonio-ce/html/architecture/components.html
- Carbonio CE installation guide: https://docs.zextras.com/carbonio-ce/html/install/installation.html
- Carbonio CE requirements: https://docs.zextras.com/carbonio-ce/html/install/requirements.html

## Important limitations

- This is a **development/testing reference**, not an officially supported production deployment recipe.
- The Compose file depends on helper directories that are not duplicated in this repository: `consul-service-registrator/`, `provisioning/`, `consul/`, `postgres/`, `carbonio-docs-editor/`, `composed-ui/`, and `ssl/`.
- The upstream Compose uses a privileged helper and mounts the Docker socket. That gives the helper broad control over the Docker host. Run only on a dedicated test host and review the upstream code before starting it.
- The sample publishes mail/web ports. Do not expose it directly to the Internet.
- Replace the development TLS certificate with a valid certificate before any non-local use.
- Do not commit a real `.env`, passwords, tokens, private keys, or production data.

For production, follow the current Carbonio vendor installation and deployment documentation for the target OS/release. Carbonio CE is a multi-component platform; the vendor installation guide uses package installation and component ordering rather than treating it as a generic single-container application.

## Prerequisites

- A dedicated Ubuntu/Linux test host.
- Docker Engine and Docker Compose plugin **v2.20 or later**.
- Git.
- Zextras registry access (the upstream tool documentation currently specifies VPN connectivity and `docker login registry.dev.zextras.com`).

## Prepare the helper files

From this directory:

```bash
bash prepare-dependencies.sh
```

The script clones the upstream tools repository into the ignored `.upstream/` directory and copies only the helper directories referenced by this Compose file. It does not overwrite this repository's sanitized Compose file.

If you prefer not to run a helper script, clone the upstream repository and copy those helper directories manually from `internal/embedded/carbonio-dockerization/`.

## Configure and start

```bash
cp .env.example .env
nano .env
docker login registry.dev.zextras.com
docker compose config
docker compose pull
docker compose up -d
```

Set every required secret in `.env` to a unique strong value. Keep `POSTGRES_PASSWORD` and `CARBONIO_POSTGRES_DB_PASSWORD` aligned for this sample's PostgreSQL setup. Never use the example placeholder values.

Inspect services:

```bash
docker compose ps
docker compose logs -f --tail=100
```

Stop the stack:

```bash
docker compose down
```

Do not use `docker compose down -v` unless you intentionally want to delete the persisted data volumes.

## Authentication and secrets in this sample

The Compose file does not implement end-user login itself. It wires Carbonio services together and passes service credentials through environment variables. Sensitive values are referenced using required Compose interpolations such as `${LDAP_ADMIN_PASSWORD:?required_in_dotenv}`; set them in the untracked `.env` file. Docker environment variables can still be inspected by users with access to the Docker daemon, so this is not a secrets vault. Use a suitable secret-management mechanism for production.

## Scope of authentication analysis for this repository

The parent repository currently contains no application source code or authentication implementation outside this Carbonio deployment sample. Therefore there is no project-specific authentication middleware, login handler, session/token store, OAuth/JWT flow, or credential lifecycle to trace yet.
