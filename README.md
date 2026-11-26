# bitbucket-pipelines dotnet-build

[![logo](./logo.png)](https://frontliners.nl)

Docker images to automate dotnet builds:

- `frontliners/dotnet-build:slim` / `frontliners/dotnet-build:<version>-slim` (`Dockerfile.slim`): minimal image containing the .NET SDK, `zip`, and build/publish scripts (`dotnet-build.sh`).
- `frontliners/dotnet-build:latest` / `frontliners/dotnet-build:full` / `frontliners/dotnet-build:<version>` / `frontliners/dotnet-build:<version>-full` (`Dockerfile`): full image built on top of `slim`, adding the .NET 10 runtime, Node.js, OpenJDK, Docker Compose, and headless browser testing tools (Cypress GUI libraries, Chromium, Firefox).

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
| push       | push all `slim` and `full` tags                                 |
| push:slim  | push `:slim` and `:<version>-slim`                              |
| push:full  | push `:latest`, `:<version>`, `:full`, and `:<version>-full`    |
| publish    | build and push all `slim` and `full` tags                       |
