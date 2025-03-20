#!/bin/bash
# return failing exit code if any command fails
set -e

# enable nullglob - allows filename patterns which match no files to expand to a null string, rather than themselves
shopt -s nullglob

ROOTDIRECTORY="${ROOTDIRECTORY:-"/api"}"

# go to the workdir
if [ -n "$BITBUCKET_CLONE_DIR" ]; then
  cd "$BITBUCKET_CLONE_DIR" || return
  ROOTDIRECTORY="$BITBUCKET_CLONE_DIR"
else
  cd "$ROOTDIRECTORY" || return
fi

# Add nuget source if access token is set
if [ -n "$MYGET_ACCESS_TOKEN" ]; then
  NUGET_CONFIG=~/.nuget/NuGet/NuGet.Config
  echo "Adding private myget source"
  SOURCE="https://www.myget.org/F/frontliners/auth/$MYGET_ACCESS_TOKEN/api/v3/index.json"
  if ! grep -q "$SOURCE" $NUGET_CONFIG; then
    VAR=$(sed "/<\/packageSources>/i <add key=\"Frontliners MyGet package source\" value=\"$SOURCE\" protocolVersion=\"3\" />" $NUGET_CONFIG)
    echo "$VAR" >$NUGET_CONFIG
  fi
fi

CS_PROJECT_FILE="${CS_PROJECT_FILE:-"src/Api/Api.csproj"}"
CS_PROJECT_NAME="Api"
DIST="./dist"
RELEASE="Release"

# change project name from default "Api"
if [ -n "$PROJECT_NAME" ]; then
  CS_PROJECT_NAME="$PROJECT_NAME"
fi

# change project file location from default "Api.csproj" if specified
if [ -n "$PROJECT_FILE" ]; then
  CS_PROJECT_FILE="$PROJECT_FILE"
fi

PROJECT_DIST="$DIST/$CS_PROJECT_NAME"
ARTIFACTS_DIST="$DIST/artifacts"

rm -rf ./**/bin
rm -rf ./**/obj
rm -rf "$DIST"

# Install dotnet tools
dotnet tool restore

# create artifacts dir
mkdir -p "$ARTIFACTS_DIST"

# clean dependencies
echo "cleaning $CS_PROJECT_FILE"
dotnet clean "$CS_PROJECT_FILE"

# restore dependencies
echo "restoring $CS_PROJECT_FILE"
dotnet restore "$CS_PROJECT_FILE"

# build project
echo "building $CS_PROJECT_FILE"
dotnet build --configuration $RELEASE --no-restore "$CS_PROJECT_FILE"

# run tests
shopt -s nocaseglob # disable casing
echo "running tests"
for f in *.test/*.csproj; do
  echo "Processing $f file..."
  dotnet test "$f" --configuration $RELEASE --results-directory "$DIST/test-results" /p:CollectCoverage=true /p:CoverletOutputFormat="opencover" /p:CoverletOutput="$DIST/test-coverlet"
done
shopt -u nocaseglob # enable casing

# publish
echo "publishing $CS_PROJECT_FILE"
dotnet publish --configuration $RELEASE --output "$PROJECT_DIST" "$CS_PROJECT_FILE"

# copy deployment files over
if [ -d "deployment/" ]; then
  echo "copying deployment files $CS_PROJECT_FILE"
  cp -r deployment/ "$PROJECT_DIST"
fi

# generate artifacts dir
echo "generating artifacts"
zip -r "$ARTIFACTS_DIST/$CS_PROJECT_NAME.zip" "$PROJECT_DIST/"
