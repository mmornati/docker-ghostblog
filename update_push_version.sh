#!/bin/bash

VERSION=$1 && \
sed -i '' "s/^ARG GHOST_VERSION.*$/ARG GHOST_VERSION=\"$VERSION\"/" Dockerfile && \
git add . && \
git commit -m "Ghost updated to $VERSION version" && \
git tag -a $VERSION -m "Ghost updated to $VERSION version" && \
git push --tags