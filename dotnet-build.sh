#!/bin/bash

# return failing exit code if any command fails
set -e

# enable nullglob - allows filename patterns which match no files to expand to a null string, rather than themselves
shopt -s nullglob

# parse flags
while getopts ":vt" opt; do
  case $opt in
    v) VERBOSE=true;;
    t) WITH_TESTING=true;;
  esac
done

# show input environment args
if [ $VERBOSE ]
then
    echo "env: BITBUCKET_CLONE_DIR=$BITBUCKET_CLONE_DIR"
    echo "env: MYGET_ACCESS_TOKEN=$MYGET_ACCESS_TOKEN" | sed -e 's/=.\+/=******/g'
    echo "env: PROJECT_NAME=$PROJECT_NAME"
    echo "env: PROJECT_FILE=$PROJECT_FILE"
    echo "env: WITH_TESTING=$WITH_TESTING"
    echo ""
fi

ROOTDIRECTORY="/api"

# go to the workdir
if [ -n "$BITBUCKET_CLONE_DIR" ]
then
    # support for relative path
    case $BITBUCKET_CLONE_DIR in
      /*) BITBUCKET_CLONE_DIR=$BITBUCKET_CLONE_DIR;;
      *) BITBUCKET_CLONE_DIR=$PWD/$BITBUCKET_CLONE_DIR;;
    esac

    cd "$BITBUCKET_CLONE_DIR" || return    
    ROOTDIRECTORY="$BITBUCKET_CLONE_DIR"
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

CS_PROJECT_FILE="Api/Api.csproj"
CS_PROJECT_NAME="Api"
DIST="./dist"
RELEASE="Release"

# change project name from default "Api"
if [ -n "$PROJECT_NAME" ]
then
  CS_PROJECT_NAME="$PROJECT_NAME"
fi

# change project file location from default "Api.csproj" if specified
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
if [ $WITH_TESTING ]
then
  echo "running tests"
  for f in *.Test/*.csproj
  do
    echo "Processing $f file..."
    dotnet test "$f" -c $RELEASE -r "$DIST/test-results" --filter "TestCategory!=[Integration]" /p:CollectCoverage=true /p:CoverletOutputFormat="opencover" /p:CoverletOutput="$DIST/test-coverlet"
  done
    
  # generate coverage report
  dotnet tool install dotnet-reportgenerator-globaltool --tool-path "$DIST/tools"
  $DIST/tools/reportgenerator -reports:"**/*.opencover*.xml" -targetdir:dist/coverage -reporttypes:"Cobertura;HTMLInline;HTMLChart;SonarQube"
fi

# publish
echo "publishing $CS_PROJECT_FILE"
dotnet publish -c $RELEASE -o "$PROJECT_DIST" $CS_PROJECT_FILE

# copy deployment files over
echo "copying deployment files $CS_PROJECT_FILE"
cp -r deployment/ $PROJECT_DIST

# generate artifacts dir
echo "generating artifacts"
rm -r $DIST/tools
cd "$PROJECT_DIST"

zip -r "$ROOTDIRECTORY/$ARTIFACTS_DIST/$CS_PROJECT_NAME.zip" "."
