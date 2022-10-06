# bitbucket-pipelines dotnet-build

[![logo](./logo.jpg)](https://inforit.nl)

Docker image to automate dotnet builds

## Instructions

1. update dockerfile, and version number in package.json
2. build local version:

   ```sh
   docker build -t inforitnl/dotnet-build .
   ```

3. push new version to dockerhub:

   ```sh
   docker push inforitnl/dotnet-build
   ```

4. tag and push again (optional but recommended):

   ```sh
   docker tag inforitnl/dotnet-build inforitnl/dotnet-build:1
   docker push inforitnl/dotnet-build:1
   ```

## Usage

```sh
image: inforitnl/dotnet-build

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
