#!/bin/bash

VERSION=$(cat version.txt)
BUILD_NUMBER=${GITHUB_RUN_NUMBER}

# Example version: 1.0.0+45
FULL_VERSION="$VERSION+$BUILD_NUMBER"

echo "Updating pubspec.yaml to version: $FULL_VERSION"

# Replace version: x.y.z+build
sed -i "s/^version: .*/version: $FULL_VERSION/" pubspec.yaml

echo "Updated version to $FULL_VERSION"
echo $VERSION > version.txt

# Output version for GitHub Actions
echo "version=$FULL_VERSION" >> "$GITHUB_OUTPUT"
