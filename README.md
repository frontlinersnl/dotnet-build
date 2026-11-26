# bitbucket-pipelines dotnet-build

[![logo](./logo.png)](https://frontliners.nl)

Docker images to automate dotnet builds:

- `frontliners/dotnet-build:slim` / `frontliners/dotnet-build:<version>-slim` (`Dockerfile.slim`): minimal image containing the .NET SDK, Node.js, `zip`, and build/publish scripts (`dotnet-build.sh`).
- `frontliners/dotnet-build:latest` / `frontliners/dotnet-build:full` / `frontliners/dotnet-build:<version>` / `frontliners/dotnet-build:<version>-full` (`Dockerfile`): full image built on top of `slim`, adding the .NET 10 runtime, Docker Compose, and headless browser testing tools (Cypress GUI libraries, Chromium, Firefox).

## Instructions

1. update dockerfile(s), and version number in package.json
2. build local versions (`slim` first, then `full` on top of `slim`):

    ```sh
    npm run build
    ```

3. push new versions to dockerhub:

    ```sh
    npm run push
    ```

4. tag and push again (optional but recommended):

    ```sh
    npm run publish
    ```

## Usage

Use the `slim` image for simple dotnet build & publish steps, and the full image (`latest` or `full`) for steps requiring additional tooling (e.g. Docker Compose, Node.js, Java, or browser tests):

```yaml
pipelines:
  default:
    - step:
        name: Build and publish
        image: frontliners/dotnet-build:slim
        script:
          - /dotnet-build.sh
    - step:
        name: Integration tests
        image: frontliners/dotnet-build:latest
        script:
          - docker-compose --version
```

## scripts

| Command    | Description                                                     |
| ---------- | --------------------------------------------------------------- |
| build      | build and version-tag both `slim` and `full` (`latest`) images  |
| build:slim | build only the `slim` image (`:slim`, `:<version>-slim`)        |
| build:full | build only the `full` image (`:latest`, `:<version>`, `:full`, `:<version>-full`) on top of `slim` |
| push       | push versioned `slim` and `full` tags                                                              |
| push:slim  | push `:<version>-slim`                                                                             |
| push:full  | push `:<version>` and `:<version>-full`                                                            |
| publish    | build and push versioned `slim` and `full` tags                                                    |

## CI/CD

Both [docker-publish.yml](.github/workflows/docker-publish.yml) (GitHub Actions) and [bitbucket-pipelines.yml](bitbucket-pipelines.yml) (Bitbucket Pipelines) build and push `slim` and `full` images using `docker buildx` with `--sbom=true`.

Configure the following variables / secrets in GitHub Actions and Bitbucket Pipelines:

- `DOCKER_USERNAME`: Docker Hub username (variable)
- `DOCKER_PASSWORD`: Docker Hub password or access token (secret / secured variable)

Tagging behavior:

- Every commit (including `master` merge commits): builds and pushes `<commit-sha>-slim` and `<commit-sha>-full`.
- `master` branch only: also builds and pushes versioned tags from `package.json` (`<major>`, `<major>.<minor>`, `<major>.<minor>.<patch>` with `-slim` and `-full` suffixes, plus bare full versions, `:slim`, `:full`, and `:latest`) and creates/pushes the git tag matching `package.json`'s `version` if it does not already exist.
