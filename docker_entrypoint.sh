#!/bin/bash

source /etc/apache2/envvars

if [ "$CLEAN_CACHE_AT_STARTUP" = "yes" ]; then
  echo "[info] Clean cache using drush"
  drush cache-rebuild
fi

# show metadata
drush status

echo " [info] Start the apache2 server in foreground."
apache2 -DFOREGROUND
