# YourCare technology atlas

Open `dist/index.html` directly in a modern browser. It is a self-contained, offline HTML page: no install, build, API access or external assets are required.

The page maps the four local YourCare repositories, their shared backend and external integrations. It includes selectable components and connections, guided journeys, a responsibility directory, and documented hosting topology. Search, filters, keyboard controls, zoom, print, and HTML export work locally.

Evidence was reviewed on 14 October 2026. Source code and release records are identified inside the page. Hosting is a documentation snapshot, not a live infrastructure inspection. Optional integrations are labelled separately from documented production operation.

Scope: documentation only. Backend API contracts, business behavior, and all three Flutter apps are unchanged. Existing controller/DTO contracts in `you-care-backend/src`, client services, and deployment records are the source of the descriptions. No application journeys or production mutations are performed by this page.

For a local HTTP preview, run `python3 -m http.server 8765 --bind 127.0.0.1 --directory dist` from this directory.
