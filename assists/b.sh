#!/usr/bin/env sh

# assist: brightness slider

CURBRIGHT="$(/usr/share/instantassist/utils/b.sh g)"
MAXBRIGHT="$(/usr/share/instantassist/utils/b.sh m)"
islide -c "/usr/share/instantassist/utils/b.sh 2 " -s "$CURBRIGHT" -m "$MAXBRIGHT"
