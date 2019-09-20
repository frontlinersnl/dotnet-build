#!/bin/bash
# return failing exit code if any command fails
set -e

# go to the workdir
if [ -n "$BITBUCKET_CLONE_DIR" ]
then
    cd "$BITBUCKET_CLONE_DIR" || return
else
    cd /api || return
fi

# Add nuget source if access token is set
if [ -n "$MYGET_ACCESS_TOKEN" ]
then
    echo "Adding private myget source"
    SOURCE="https://www.myget.org/F/inforit/auth/$MYGET_ACCESS_TOKEN/api/v3/index.json"
    VAR=$(sed "/<\/packageSources>/i <add key=\"inforit.org\" value=\"$SOURCE\" protocolVersion=\"3\" />" ~/.nuget/NuGet/NuGet.Config)
    echo "$VAR" > ~/.nuget/NuGet/NuGet.Config
fi

CS_PROJECT_FILE=""
CS_PROJECT_NAME="Api"
DIST="./dist"
RELEASE="Release"

# change project name from default "Api"
if [ -n "$PROJECT_NAME" ]
then
  CS_PROJECT_NAME="$PROJECT_NAME"
fi

# change project file location from default "*.sln" if specified
if [ -n "$PROJECT_FILE" ]
then
  CS_PROJECT_FILE="$PROJECT_FILE"
fi

PROJECT_DIST="$DIST/$CS_PROJECT_NAME"
ARTIFACTS_DIST="$DIST/artifacts"``

rm -rf ./**/bin
rm -rf ./**/obj
rm -rf "$DIST"

# create artifacts dir
mkdir -p "$ARTIFACTS_DIST"

# clean dependencies
echo "cleaning $CS_PROJECT_FILE"
dotnet clean $CS_PROJECT_FILE

# restore dependencies
echo "restoring $CS_PROJECT_FILE"
dotnet restore $CS_PROJECT_FILE

# build project
echo "building $CS_PROJECT_FILE"
dotnet build -c $RELEASE --no-restore $CS_PROJECT_FILE

# run tests
echo "running tests"
for f in *.Test/*.csproj
do
  echo "Processing $f file..."
  dotnet test "$f" --no-restore -c $RELEASE -r "$DIST/test-results"  
done

# publish
echo "publishing $CS_PROJECT_FILE"
dotnet publish -c $RELEASE -o "$PROJECT_DIST" $CS_PROJECT_FILE

# copy deployment files over
echo "copying deployment files $CS_PROJECT_FILE"
cp -r deployment/ $PROJECT_DIST

# generate artifacts dir
echo "generating artifacts"
zip -r "$ARTIFACTS_DIST/$CS_PROJECT_NAME.zip" "$PROJECT_DIST"
