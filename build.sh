#!/usr/bin/env bash

set -e

cd "$(dirname $0)"

export VERSION_TYPE=dev

if [ -z "$BUILD_NUMBER" ]; then echo "BUILD_NUMBER unset"; exit 1; fi
if [ -z "$VERSION_TYPE" ]; then echo "VERSION_TYPE unset"; exit 1; fi
if [ -z "$HMCL_SIGNATURE_KEY" ]; then echo "HMCL_SIGNATURE_KEY unset"; exit 1; fi

VERSION="1.0.$BUILD_NUMBER"

mkdir -p ./build

./gradlew build


HPMCL_JAR_SHA1=$(cat "./HMCL/build/libs/HPMCL-$VERSION.jar.sha1")
HPMCL_PACK_SHA1=$(cat "./HMCL/build/libs/HPMCL-$VERSION.pack.sha1")
HPMCL_PACK_XZ_SHA1=$(cat "./HMCL/build/libs/HPMCL-$VERSION.pack.xz.sha1")

cat pom.xml | sed -e "s/HPMCL_VERSION/$VERSION/" > "./HMCL/build/libs/HPMCL-$VERSION.pom"
cat version.json | sed -e "s/HPMCL_VERSION/$VERSION/g" \
  | sed -e "s/HPMCL_JAR_SHA1/$HPMCL_JAR_SHA1/" | sed -e "s/HPMCL_PACK_SHA1/$HPMCL_PACK_SHA1/" | sed -e "s/HPMCL_PACK_XZ_SHA1/$HPMCL_PACK_XZ_SHA1/" > ./build/hpmcl-$VERSION.json

allExts=(pom jar exe pack pack.xz)

for ext in ${allExts[@]}; do
  cp "./HMCL/build/libs/HPMCL-$VERSION.$ext" "./build/hpmcl-$VERSION.$ext"
  gpg -ab "./build/hpmcl-$VERSION.$ext"
done

cd ./build

jar -cvf hpmcl-$VERSION-bundle.jar \
  ./hpmcl-$VERSION.pom ./hpmcl-$VERSION.pom.asc \
  ./hpmcl-$VERSION.jar ./hpmcl-$VERSION.jar.asc ./hpmcl-$VERSION.exe ./hpmcl-$VERSION.exe.asc \
  ./hpmcl-$VERSION.pack ./hpmcl-$VERSION.pack.asc ./hpmcl-$VERSION.pack.xz ./hpmcl-$VERSION.pack.xz.asc

