# multideplo

Deployment configuration for the RuhRohgue game app on AWS Elastic Beanstalk.

## What this repo contains

- `Dockerfile` — builds a single container: Nginx reverse proxy in front of the Java app.
- `nginx.conf` — routes `/`, `/app1/`, `/app2/`, and `/api/` to the backing Java processes.
- `entrypoint.sh` — starts Nginx, then runs the game app (`app1.jar`) in the foreground.
- `Dockerrun.aws.json` — Elastic Beanstalk container port mapping (80 → 80).
- `.github/workflows/deploy.yml` — CI/CD pipeline (see below).

This repo does not contain application source code. The game itself lives in the
`roncproject/ruhrohgue` repo and is pulled in during CI.

## CI/CD pipeline

On every push to `main`, the workflow:

1. Checks out this repo and the `ruhrohgue` app repo.
2. Builds the app with Maven (Corretto 17).
3. Runs it locally and executes the Playwright/Java e2e test suite and a Postman
   API rate-limit test against it.
4. Uploads the test reports as build artifacts.
5. Packages `Dockerfile`, `nginx.conf`, `entrypoint.sh`, `Dockerrun.aws.json`, and the
   built jar into `deployment.zip`.
6. Deploys the bundle to the `RuhRohgue-Production-env` Elastic Beanstalk environment
   in `eu-west-3`.

## Known limitation

`app2.jar` is a placeholder file (not a real application) created during CI so the
Docker build has something to copy. Nginx routes `/app2/` and `/api/` to it, but
nothing serves those routes yet — only the game app (`/`, `/app1/`) is live.

## Running locally

```sh
docker build -t multideplo .
docker run -p 80:80 multideplo
```

The game will be reachable at `http://localhost/`.
