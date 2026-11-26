# bitbucket-pipelines dotnet-build

[![logo](./logo.png)](https://frontliners.nl)

Docker images to automate dotnet builds:

- `frontliners/dotnet-build:slim` (`Dockerfile.slim`): minimal image containing the .NET SDK, `zip`, and build/publish scripts (`dotnet-build.sh`).
- `frontliners/dotnet-build:latest` / `frontliners/dotnet-build:full` (`Dockerfile`): full image built on top of `slim`, adding the .NET 10 runtime, Node.js, OpenJDK, Docker Compose, and headless browser testing tools (Cypress GUI libraries, Chromium, Firefox).

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

| Command    | Description                                         |
| ---------- | --------------------------------------------------- |
| build      | build both `slim` and `full` (`latest`) containers  |
| build:slim | build only the `slim` container                     |
| build:full | build only the `full` container on top of `slim`    |
| push       | push both `slim` and `full` (`latest`) containers   |
| push:slim  | push only the `slim` container                      |
| push:full  | push only the `full` (`latest`) container           |
| publish    | build, version-tag, and push both `slim` and `full` |
