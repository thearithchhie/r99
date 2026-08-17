#!/bin/bash

MIGRATION_DIR="src/main/resources/db/migration"

if [ -z "$1" ]; then
    echo "Usage: ./make-migration.sh <description>"
    echo "Example: ./make-migration.sh create_products_table"
    exit 1
fi

# Find the next version number
LAST=$(ls "$MIGRATION_DIR"/V*.sql 2>/dev/null | grep -oE 'V[0-9]+' | grep -oE '[0-9]+' | sort -n | tail -1)
NEXT=$((${LAST:-0} + 1))

FILENAME="$MIGRATION_DIR/V${NEXT}__$1.sql"

touch "$FILENAME"
echo "Created: $FILENAME"