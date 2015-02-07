#!/bin/bash

GHOST="/ghost"
OVERRIDE="/ghost-override"

CONFIG="config.js"
DATA="content/data"
IMAGES="content/images"
THEMES="content/themes"

echo "=> Set up SymLinks:"
echo "========================================================================"
echo "      Data:    $OVERRIDE/$DATA to $GHOST/$DATA"
echo "      Images:  $OVERRIDE/$IMAGES to $GHOST/$IMAGES"
echo "      Config:  $OVERRIDE/$CONFIG to $GHOST/$CONFIG"
echo "      Themes:  $OVERRIDE/$THEMES to $GHOST/$THEMES"
echo "========================================================================"

# Change to working directory
cd "$GHOST"

# Symlink data directory.
mkdir -p "$OVERRIDE/$DATA"
rm -fr "$DATA"
ln -s "$OVERRIDE/$DATA" "$DATA"

# Symlink images directory
mkdir -p "$OVERRIDE/$IMAGES"
rm -fr "$IMAGES"
ln -s "$OVERRIDE/$IMAGES" "$IMAGES"

# Symlink config file.
if [[ -f "$OVERRIDE/$CONFIG" ]]; then
  rm -f "$CONFIG"
  ln -s "$OVERRIDE/$CONFIG" "$CONFIG"
fi

# Symlink themes.
if [[ -d "$OVERRIDE/$THEMES" ]]; then
  for theme in $(find "$OVERRIDE/$THEMES" -mindepth 1 -maxdepth 1 -type d -exec basename {} \;)
  do
    rm -fr "$THEMES/$theme"
    ln -s "$OVERRIDE/$THEMES/$theme" "$THEMES/$theme"
  done
fi

echo "=> Change config based on ENV parameters:"
echo "========================================================================"
echo "      WEB_URL:    $WEB_URL"
echo "========================================================================"

# Start Ghost
chown -R ghost:ghost /data /ghost /ghost-override
su ghost << EOF
cd "$GHOST"
NODE_ENV=${NODE_ENV:-production} npm start
EOF
