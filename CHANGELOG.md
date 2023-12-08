# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [11.0.1]

Added make as a dependency

## [11.0.0]

- [BREAKING] Renamed Inforit to Frontliners
- [BREAKING] Updated to NET 8 SDK container
- Added NET 7 runtime so NET 7 projects can still run (for example the multi target nuget package tests)

## [10.0.1]

- Updated base image with patch version `7.0.404-1-bullseye-slim-amd64`

## [10.0.0]

- default csproj path now set to src/Api.csproj
  - can be customized with env variable "CS_PROJECT_FILE"
- dotnet-build now no longer uses `"` to prevent word splitting on the nuget config path

## [9.1.0]

- container now explicitly installs nuget by default

## [9.0.0]

- Updated various internally used packages
  - NodeJS from LTS 16 to LTS 18 (this is a major break, permissive rmdirs are removed)
  - Java from 11 to 17
  - because of the rebuild chrome, firefox and a load of other packages are also updated to their latest versions

## [8.1.0]

- Updated docker-compose to v2.16.0

## [8.0.1]

- Fixed a CLI change between NET6 and NET7

## [8.0.0]

- Updated to NET 7
- Removed patheems (Patrick Heemskerk) as reviewer

## [7.2.0]

- Updated docker-compose to version 2
- Added dotnet-coverage & dotnet-format as a global tool

## [7.1.0]

- Added firefox and chrome as headless e2e testing options

## [7.0.3]

- Bump MSBuild version to 17.3

## [7.0.0-2]

- Added docker compose for e2e testing in bitbucket

## [6.2.0-2]

- Added cypress build deps
- Fixed various bugs that came up during pipeline runs

## [6.1.0]

- build file now matches test projects without case sensitivity
- Nuget config only updated when required
- Escaped simple params
- Updated editorconfig to 2 spaces per tab
- made deployment folder optional
- added JUnit logging to test projects

## [6.0.4]

- Add nodejs and npm

## [6.0.3]

- Dependabot SDK update

## [6.0.2]

- Dependabot SDK update

## [6.0.1]

- Dependabot SDK update

## [6.0.0]

- Updated dotnet core sdk container to NET6

## [5.3.1]

- Updated dotnet core sdk container

## [5.3.0]

- Due to an issue with NuGet restore and certificates, a temporary version based on [NuGet Restore Issues](https://github.com/NuGet/Announcements/issues/49)

## [5.2.0]

- Add sonarscanner

## [5.1.0]

- Add codecoverage

## [5.0.0]

- Changed base container to dotnet 5.0

## [4.2.0]

### added

- default-jre
