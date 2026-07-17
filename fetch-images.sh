#!/usr/bin/env bash
# Downloads the lead photo for each building from Wikipedia into ./images/.
# Run this ON YOUR MAC (this repo's folder), where the network is open:
#     cd ~/Projects/indianarchitecture.org
#     bash fetch-images.sh
# Then commit + push. Cards use images/<slug>.jpg and fall back to a
# coloured tile if a file is missing, so partial runs are safe.

set -u
cd "$(dirname "$0")"
mkdir -p images
UA="inarc-image-fetch/1.0 (https://indianarchitecture.org; ab@bbarch.net)"

# slug  ->  Wikipedia article title
titles=(
  "greatest-buildings|Taj Mahal"
  "world-heritage|Humayun's Tomb"
  "modern-masters|Indian Institute of Management Ahmedabad"
  "brutalist-india|Chandigarh Capitol Complex"
  "artdeco-india|Eros Cinema"
  "palace-architecture|Hawa Mahal"
  "humayuns-tomb|Humayun's Tomb"
  "qutb-minar|Qutb Minar"
  "rashtrapati-bhavan|Rashtrapati Bhavan"
  "lotus-temple|Lotus Temple"
  "hall-of-nations|Hall of Nations, New Delhi"
  "connaught-place|Connaught Place, New Delhi"
  "sabarmati-ashram|Sabarmati Ashram"
  "mill-owners|Mill Owners' Association Building"
  "iim-ahmedabad|Indian Institute of Management Ahmedabad"
  "national-assembly-dhaka|Jatiya Sangsad Bhaban"
)

get_url() {  # $1 = article title -> prints original image URL (or nothing)
  python3 - "$1" <<'PY'
import sys, json, urllib.parse, urllib.request
title = sys.argv[1]
api = ("https://en.wikipedia.org/w/api.php?action=query&format=json"
       "&prop=pageimages&piprop=original&redirects=1&titles="
       + urllib.parse.quote(title))
req = urllib.request.Request(api, headers={"User-Agent":
      "inarc-image-fetch/1.0 (https://indianarchitecture.org; ab@bbarch.net)"})
try:
    data = json.load(urllib.request.urlopen(req, timeout=20))
    for p in data["query"]["pages"].values():
        if "original" in p:
            print(p["original"]["source"]); break
except Exception as e:
    sys.stderr.write(f"  ! {e}\n")
PY
}

for row in "${titles[@]}"; do
  slug="${row%%|*}"; title="${row#*|}"
  url="$(get_url "$title")"
  if [ -n "$url" ]; then
    echo "↓ $slug  ←  $title"
    curl -sL --fail -H "User-Agent: $UA" "$url" -o "images/$slug.jpg" \
      && echo "   saved images/$slug.jpg" \
      || echo "   ! download failed"
  else
    echo "✗ no lead image found for: $title  ($slug) — will use placeholder"
  fi
  sleep 0.3
done

echo
echo "Done. Review ./images/, then:  git add images && git commit -m 'Add building photos' && git push"
