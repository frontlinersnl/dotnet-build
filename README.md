# bitbucket-pipelines dotnet-build

[![logo](./logo.png)](https://frontliners.nl)

Docker image to automate dotnet builds

## Instructions

1. update dockerfile, and version number in package.json
2. build local version:

    ```sh
    npm run build
    ```

3. push new version to dockerhub:

    ```sh
    npm run push
    ```

4. tag and push again (optional but recommended):

    ```sh
    npm run publish
    ```

## Usage

```sh
image: frontliners/dotnet-build

pipelines:
  default:
    - step:
        script:
          - /dotnet-build.sh
```

## scripts

| Command | Description                         |
| ------- | ----------------------------------- |
| build   | build the container with latest tag |
| push    | pushes the container                |
