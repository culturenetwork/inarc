#!/usr/bin/env bash
# Downloads an India states GeoJSON that uses the OFFICIAL Government of India
# boundary — all of Jammu & Kashmir and Ladakh (incl. Aksai Chin) shown inside
# India — and saves it to assets/india.geojson (used by map.html).
#
# Run ON YOUR MAC:
#     cd ~/Projects/indianarchitecture.org
#     bash fetch-map.sh
#     git add assets/india.geojson && git commit -m "Add official India boundary" && git push
#
# NOTE: This pulls a community dataset that ships the official Indian boundary
# (udit-001/india-maps-data). For anything beyond a prototype, replace it with
# a Survey of India authorised map or MapmyIndia/Mappls tiles (both are legally
# the India-compliant sources). The script verifies J&K + Ladakh are present.

set -u
cd "$(dirname "$0")"
mkdir -p assets
UA="inarc-map-fetch/1.0 (https://indianarchitecture.org; ab@bbarch.net)"
out="assets/india.geojson"

candidates=(
  "https://raw.githubusercontent.com/udit-001/india-maps-data/main/geojson/states.geojson"
  "https://raw.githubusercontent.com/udit-001/india-maps-data/main/geojson/india.geojson"
  "https://raw.githubusercontent.com/udit-001/india-maps-data/master/geojson/states.geojson"
  "https://raw.githubusercontent.com/udit-001/india-maps-data/master/geojson/india.geojson"
)

ok=""
for url in "${candidates[@]}"; do
  echo "↓ trying $url"
  if curl -sL --fail -H "User-Agent: $UA" "$url" -o "$out"; then
    if grep -qi "Ladakh" "$out" && grep -qi "Jammu" "$out"; then
      echo "   ✓ saved $out (contains Jammu & Kashmir + Ladakh)"
      ok=1; break
    else
      echo "   ! downloaded but J&K/Ladakh not found — skipping this source"
    fi
  else
    echo "   ! download failed"
  fi
done

if [ -z "$ok" ]; then
  echo
  echo "Could not fetch a verified official-boundary file automatically."
  echo "Supply your own: save an official Survey of India / Mappls India states"
  echo "GeoJSON as assets/india.geojson (must include all of J&K and Ladakh)."
  exit 1
fi

# quick sanity: valid JSON?
python3 -c "import json;json.load(open('$out'));print('   ✓ valid JSON,', round(__import__('os').path.getsize('$out')/1024), 'KB')" 2>/dev/null \
  || echo "   ! warning: file may not be valid JSON — please check"

echo
echo "Done. Then:  git add assets/india.geojson && git commit -m 'Add official India boundary' && git push"
