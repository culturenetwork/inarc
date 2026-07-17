# IndianArchitecture.org

The digital atlas of India's built heritage and contemporary architecture — a
location-aware platform to discover, understand and experience architecture
across India.

> If Google Maps tells you how to get somewhere, IndianArchitecture.org tells
> you why it matters.

This repository currently holds an **early clickable prototype**: a static,
multi-page HTML mockup that demonstrates the core page types and the intended
look and feel. Content is illustrative (architecturally accurate sample text,
not the full researched database).

## Pages

| File                   | Purpose                                                        |
| ---------------------- | ------------------------------------------------------------- |
| `index.html`           | Homepage — search, featured collections, map teaser, rollout  |
| `map.html`             | Interactive Leaflet map with markers, filters and sidebar     |
| `building-iima.html`   | Sample building profile (IIM Ahmedabad, Louis Kahn)           |
| `city-delhi.html`      | Sample city guide (Delhi)                                      |
| `architect-kahn.html`  | Sample architect page (Louis Kahn)                            |
| `assets/styles.css`    | Shared design system (typography, colours, components)        |

## Running locally

It's plain static HTML — just open `index.html` in a browser, or serve the
folder:

```bash
python3 -m http.server 8000
# then visit http://localhost:8000
```

The map page loads Leaflet and map tiles from a CDN, so it needs an internet
connection; everything else works offline.

## Deploying

Any static host works. For **GitHub Pages**: repo Settings → Pages → deploy
from the `main` branch (root). The site will be served with `index.html` as the
entry point.

## Status

Prototype. Photography is rendered as styled placeholders; buttons such as
Save / Share / Layers show placeholder actions. Next steps under consideration:
real filters and layer switching on the map, the AI-assistant search flow, and
a data model for scaling the building/architect/city database.

## Related

Paired with **DelhiCulture** — buildings answer *"what should I experience and
why"*; DelhiCulture answers *"what's happening today"*.
