#!/bin/bash

cd /api || return

# Add nuget source if access token is set
if [ -n "$MYGET_ACCESS_TOKEN" ]
then
    echo "Adding inforit nuget source"
    SOURCE="https://www.myget.org/F/inforit/auth/$MYGET_ACCESS_TOKEN/api/v3/index.json"
    VAR=$(sed "/<\/packageSources>/i <add key=\"inforit.org\" value=\"$SOURCE\" protocolVersion=\"3\" />" ~/.nuget/NuGet/NuGet.Config)
    echo "$VAR" > ~/.nuget/NuGet/NuGet.Config
fi

PROJECT_NAME="Api"
DIST="./dist"
RELEASE="Release"

# change project name from default "Api"
if [ -n "NAME" ]
then
  $PROJECT_NAME = $NAME
fi

PROJECT_DIST="$DIST/$PROJECT_NAME"
ARTIFACTS_DIST="$DIST/artifacts"``

rm -rf ./**/bin
rm -rf ./**/obj
rm -rf "$DIST"

# create artifacts dir
mkdir -p "$ARTIFACTS_DIST"

# clean dependencies
dotnet clean

# restore dependencies
dotnet restore

# build project
dotnet build -c $RELEASE --no-restore

# run tests
dotnet test --no-restore -c $RELEASE -r "$DIST/test-results"

# publish
dotnet publish -c $RELEASE -o "$PROJECT_DIST"

# copy deployment files over
cp -r deployment/ $PROJECT_DIST

# generate artifacts dir
zip -r "$ARTIFACTS_DIST/$PROJECT_NAME.zip" "$PROJECT_DIST"
