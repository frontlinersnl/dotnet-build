# Frontliners .NET build images

Build and publish full and dotnet-only CI images to `frontliners/dotnet-build`. Both use the shared build script version from `package.json`. The dotnet-only image packages published output with zip. The full image also provides Node.js, Java, Docker Compose and browser testing tools.

## Choose a variant, SDK and additional runtimes

Use `npm run <build|push|publish> <variant> <sdk> [runtime ...]`. Every command requires a variant and one SDK. Each following version adds a .NET and ASP.NET Core shared runtime. The SDK includes its own runtime.

| Command | Versioned image tag |
| --- | --- |
| `npm run build dotnet-only 10 9 8` | `14.0.0-sdk10-runtime9_8-dotnet-only` |
| `npm run publish full 11 10 9` | `14.0.0-sdk11-runtime10_9-full` |
| `npm run publish dotnet-only 11` | `14.0.0-sdk11-dotnet-only` |

Versions such as `10` and `10.0` are equivalent. Extra runtimes are deduplicated and sorted newest first. Each publish builds once and pushes one tag prefixed with the shared build script version and ending with the selected variant. Multiple additional runtimes share one tag segment, for example `runtime10_9_8`.

## Add a variant

Copy `Dockerfile.dotnet-only` to `Dockerfile.browser` in the project root and customize the tools it installs. Keep the SDK_VERSION build argument, its use in FROM, and the BEGIN/END additional runtimes comment lines. The build command inserts the requested runtime copies between those lines. Use lowercase names made of letters, digits and hyphen-separated words. Run `npm run build browser 11 10` to build the new variant.

## Build and verify before publishing

Run from the project directory with Docker available. Use an account with push access to the Frontliners repository when publishing.

```sh
npm run build dotnet-only 11 10 9
docker run --rm frontliners/dotnet-build:14.0.0-sdk11-runtime10_9-dotnet-only dotnet --list-runtimes
docker login
npm run push dotnet-only 11 10 9
```

For separate build and push operations, pass the same versions to both commands. Update the shared package version for a new release.

## Bitbucket Pipelines

```yaml
image: frontliners/dotnet-build:14.0.0-sdk11-runtime10_9-dotnet-only

pipelines:
  default:
    - step:
        script:
          - /dotnet-build.sh
```
