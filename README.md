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

On every push to `main`, `.github/workflows/deploy.yml` runs three jobs in order,
each gating the next:

1. **build** — checks out this repo and the `ruhrohgue` app repo, builds the app
   with Maven (Corretto 17), runs it locally and executes the Playwright/Java e2e
   suite and a Postman API rate-limit test against that local process, then
   packages `Dockerfile`, `nginx.conf`, `entrypoint.sh`, `Dockerrun.aws.json`, and
   the built jar into `deployment.zip` and uploads it as a workflow artifact.
2. **acceptance** (`needs: build`) — authenticates to AWS via OIDC (no stored
   access keys), registers the uploaded bundle as an application version, and
   creates a throwaway, single-instance Elastic Beanstalk environment
   (`ruhrohgue-acc-<run id>`) matching production's instance type and IAM
   instance profile, with its own score file under the `acceptance/` S3 prefix
   so acceptance runs never touch production's score table. Once the
   environment reports healthy, it re-runs the same e2e and Postman suites
   against it over plain HTTP — never through Cloudflare, whose bot challenge
   blocks scripted POSTs. The environment, its score object, and its
   application version are always deleted afterwards, success or failure.
3. **deploy** (`needs: acceptance`) — only reached once acceptance has passed.
   Ships the exact same `deployment.zip` that acceptance tested to the
   `RuhRohgue-Production-env` environment in `eu-west-3`, labelled
   `release-<sha>`.

A separate scheduled workflow, `cleanup-acceptance-environments.yml`, sweeps
every 30 minutes and terminates any `ruhrohgue-acc-*` environment older than
two hours, covering runs where the acceptance job's own teardown step couldn't
execute (e.g. a cancelled or force-stopped run).

Both AWS-touching jobs assume an IAM role over OIDC (`secrets.AWS_DEPLOY_ROLE_ARN`)
rather than using stored access keys. That role, its trust policy, and the rest
of the one-time AWS console setup are tracked in
[multideplo#5](https://github.com/roncproject/multideplo/issues/5).

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
