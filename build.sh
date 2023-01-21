#!/usr/bin/env bash

set -e

cd "$(dirname $0)"

export VERSION_TYPE=dev

if [ -z "$BUILD_NUMBER" ]; then echo "BUILD_NUMBER unset"; exit 1; fi
if [ -z "$VERSION_TYPE" ]; then echo "VERSION_TYPE unset"; exit 1; fi
if [ -z "$HMCL_SIGNATURE_KEY" ]; then echo "HMCL_SIGNATURE_KEY unset"; exit 1; fi
if [ -z "$CURSEFORGE_API_KEY" ]; then echo "CURSEFORGE_API_KEY unset"; exit 1; fi
if [ -z "$MICROSOFT_AUTH_ID" ]; then echo "MICROSOFT_AUTH_ID unset"; exit 1; fi
if [ -z "$MICROSOFT_AUTH_SECRET" ]; then echo "MICROSOFT_AUTH_SECRET unset"; exit 1; fi

VERSION="1.2.$BUILD_NUMBER"

mkdir -p ./build

./gradlew build


U1_JAR_SHA1=$(cat "./HMCL/build/libs/U1-$VERSION.jar.sha1")

cat pom.xml | sed -e "s/U1_VERSION/$VERSION/" > "./HMCL/build/libs/U1-$VERSION.pom"
cat version.json | sed -e "s/U1_VERSION/$VERSION/g" | sed -e "s/U1_JAR_SHA1/$U1_JAR_SHA1/" > ./build/u1-$VERSION.json

allExts=(pom jar exe)

for ext in ${allExts[@]}; do
  cp "./HMCL/build/libs/U1-$VERSION.$ext" "./build/u1-$VERSION.$ext"
  gpg -ab "./build/u1-$VERSION.$ext"
done

cd ./build

jar -cvf u1-$VERSION-bundle.jar \
  ./u1-$VERSION.pom ./u1-$VERSION.pom.asc \
  ./u1-$VERSION.jar ./u1-$VERSION.jar.asc ./u1-$VERSION.exe ./u1-$VERSION.exe.asc
