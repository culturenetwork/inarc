#!/usr/bin/env bash
# Downloads a royalty-free lead photo for each building into ./images/.
# Sources: Wikipedia lead image first, then a Wikimedia Commons search
# fallback (Commons media is CC / public-domain). Run ON YOUR MAC:
#     cd ~/Projects/indianarchitecture.org
#     bash fetch-images.sh
#     git add images && git commit -m "Add building photos" && git push
# Safe to re-run: it skips files that already exist.

set -u
cd "$(dirname "$0")"
mkdir -p images
UA="inarc-image-fetch/1.0 (https://indianarchitecture.org; ab@bbarch.net)"

# slug | Wikipedia article title | Commons search terms (fallback)
rows=(
  "greatest-buildings|Taj Mahal|Taj Mahal"
  "world-heritage|Humayun's Tomb|Humayun's Tomb Delhi"
  "modern-masters|Indian Institute of Management Ahmedabad|IIM Ahmedabad Louis Kahn campus"
  "brutalist-india|Chandigarh Capitol Complex|Chandigarh Capitol Complex Le Corbusier"
  "artdeco-india|Eros Cinema|Eros Cinema Mumbai"
  "palace-architecture|Hawa Mahal|Hawa Mahal Jaipur"
  "humayuns-tomb|Humayun's Tomb|Humayun's Tomb Delhi"
  "qutb-minar|Qutb Minar|Qutb Minar Delhi"
  "rashtrapati-bhavan|Rashtrapati Bhavan|Rashtrapati Bhavan"
  "lotus-temple|Lotus Temple|Lotus Temple Delhi"
  "hall-of-nations|Hall of Nations, New Delhi|Hall of Nations Pragati Maidan"
  "connaught-place|Connaught Place, New Delhi|Connaught Place New Delhi"
  "sabarmati-ashram|Sabarmati Ashram|Sabarmati Ashram Ahmedabad"
  "mill-owners|Mill Owners' Association Building|Mill Owners Association Building Ahmedabad"
  "iim-ahmedabad|Indian Institute of Management Ahmedabad|IIM Ahmedabad Louis Kahn campus"
  "national-assembly-dhaka|Jatiya Sangsad Bhaban|Jatiya Sangsad Bhaban Dhaka"
)

resolve() {  # $1 title, $2 commons-search -> prints a direct image URL
  python3 - "$1" "$2" <<'PY'
import sys, json, urllib.parse, urllib.request
title, search = sys.argv[1], sys.argv[2]
UA = {"User-Agent": "inarc-image-fetch/1.0 (https://indianarchitecture.org; ab@bbarch.net)"}
def get(url):
    return json.load(urllib.request.urlopen(urllib.request.Request(url, headers=UA), timeout=25))
# 1) Wikipedia lead image
try:
    d = get("https://en.wikipedia.org/w/api.php?action=query&format=json&prop=pageimages"
            "&piprop=original&redirects=1&titles=" + urllib.parse.quote(title))
    for p in d["query"]["pages"].values():
        if "original" in p:
            print(p["original"]["source"]); sys.exit()
except Exception as e:
    sys.stderr.write(f"  wp: {e}\n")
# 2) Wikimedia Commons image search (royalty-free)
try:
    d = get("https://commons.wikimedia.org/w/api.php?action=query&format=json"
            "&generator=search&gsrnamespace=6&gsrlimit=8&gsrsearch=" + urllib.parse.quote(search) +
            "&prop=imageinfo&iiprop=url|mime&iiurlwidth=1280")
    pages = list(d.get("query", {}).get("pages", {}).values())
    pages.sort(key=lambda p: p.get("index", 99))
    for p in pages:
        ii = p.get("imageinfo", [{}])[0]
        mime = ii.get("mime", "")
        if mime.startswith("image/") and mime not in ("image/svg+xml",):
            print(ii.get("thumburl") or ii.get("url")); sys.exit()
except Exception as e:
    sys.stderr.write(f"  commons: {e}\n")
PY
}

for row in "${rows[@]}"; do
  IFS='|' read -r slug title search <<< "$row"
  if [ -s "images/$slug.jpg" ]; then echo "= keep images/$slug.jpg"; continue; fi
  url="$(resolve "$title" "$search")"
  if [ -n "$url" ]; then
    echo "↓ $slug  ←  $url"
    curl -sL --fail -H "User-Agent: $UA" "$url" -o "images/$slug.jpg" \
      && echo "   saved images/$slug.jpg" || echo "   ! download failed"
  else
    echo "✗ nothing found for: $title  ($slug)"
  fi
  sleep 0.3
done
echo
echo "Done. Then:  git add images && git commit -m 'Add building photos' && git push"
