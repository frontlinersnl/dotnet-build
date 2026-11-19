# Frontliners .NET build images

Build and publish full and slim CI images to `frontliners/dotnet-build`. Both use the shared build script version from `package.json`. The slim image packages published output with zip. The full image also provides Node.js, Java, Docker Compose and browser testing tools.

## Choose the SDK and runtimes

The first argument after `--` selects the build SDK. Each remaining argument adds a .NET and ASP.NET Core shared runtime from the matching Microsoft ASP.NET image. The SDK already includes its own runtimes. Supply just the SDK for zero additional runtimes. Omitting all arguments keeps the existing SDK 11 + runtime 10 configuration.

| Command | Versioned tag at release 14.0.0 |
| --- | --- |
| `npm run publish:slim -- 11 10 9` | `14.0.0-sdk11-runtime10-runtime9-slim` |
| `npm run publish -- 11 10 9` | `14.0.0-sdk11-runtime10-runtime9` |
| `npm run publish:slim -- 10 9 8 7` | `14.0.0-sdk10-runtime9-runtime8-runtime7-slim` |
| `npm run publish:slim -- 11` | `14.0.0-sdk11-slim` |
| `npm run publish:slim` | `14.0.0-sdk11-runtime10-slim` |

Use major versions such as `11` or `11.0`. Runtime versions are deduplicated and ordered newest first. The selected upstream images and their native dependencies must support the build platform.

Each publish builds once, then pushes the versioned tag and a moving tag with the same SDK/runtime suffix. Only the original full SDK 11 + runtime 10 profile also publishes the compatibility tags `14.0.0` and `latest`.

## Build and verify before publishing

Run from the project directory with Docker available. Use an account with push access to the Frontliners repository when publishing.

```sh
npm run build:slim -- 11 10 9
docker run --rm frontliners/dotnet-build:sdk11-runtime10-runtime9-slim dotnet --list-runtimes
docker login
npm run push:slim -- 11 10 9
```

Use `build`, `push`, or `publish` for the full variant. For separate build and push operations, pass the same versions to both commands. Update the shared package version for a new release.

## Bitbucket Pipelines

```yaml
image: frontliners/dotnet-build:14.0.0-sdk11-runtime10-runtime9-slim

pipelines:
  default:
    - step:
        script:
          - /dotnet-build.sh
```
