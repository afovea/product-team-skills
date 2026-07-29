# Motion resources

Reference for [`motion-designer`](../SKILL.md). Read this when you need to name a standard, choose a library, or run intake on a third-party animated component.

Reference material only — none of it substitutes for the gates in the skill. Verify anything time-sensitive at the source rather than trusting a value recalled here. Library and vendor detail ages fastest; treat the delivery-path table below as a snapshot to re-check, not a durable fact.

**Standards and accessibility**
- WCAG 2.2 — most relevant success criteria: 2.2.2 Pause, Stop, Hide (A); 2.3.1 Three Flashes or Below Threshold (A); 1.4.13 Content on Hover or Focus (AA); 2.3.3 Animation from Interactions (AAA).
- MDN — `prefers-reduced-motion`, `prefers-reduced-data`, Web Animations API, View Transitions API, `IntersectionObserver`, Pointer Events.

**Performance**
- web.dev — INP, CLS, Long Animation Frames, and rendering-performance guidance.
- Chrome DevTools Performance panel; Lighthouse; real-device testing across refresh rates.

**Motion systems and principles**
- Material Design motion guidance — purpose-led transitions, easing and duration systems.
- Apple Human Interface Guidelines — motion, and reduced-motion behaviour on Apple platforms.
- Design-system motion documentation from mature public systems, for token naming and governance patterns.

**Libraries and component sources**
- Animation libraries — evaluate against the technology hierarchy above; prefer the simplest that meets the interaction.
- [Originkit](https://www.originkit.dev/) — a large free library of animated React/Framer components. Useful as a **reference for expressive technique families** and as an accelerator on marketing and showcase surfaces. Its components are vendored source authored Framer-first, so they arrive as code you own: run the intake checklist before adoption, and expect to add reduced-motion paths, focus visibility, lifecycle cleanup, and token alignment yourself.
  - **Authoring model.** Components are authored **Framer-first**: default export, Framer property controls, `@framerSupportedLayoutWidth/Height` layout annotations, and `framer-motion` for all animation with no CSS keyframes. This shapes what you receive on every delivery path below.
  - **Three delivery paths, and they do not deliver the same source:**

| Path | What you get | Account | Consequence for intake |
|---|---|---|---|
| **Copy code** | complete Framer-authored `.tsx`, bindings intact | sign-in required to copy | in React/Vite, Framer-only imports resolve to a **no-op shim**; property-control and layout-annotation metadata comes along as dead weight |
| **Copy to Framer** | same source, pasted to canvas via Insert → Code → New Component | sign-in required to copy | property panel works immediately; the least friction and the least review |
| **MCP** | source **adapted to the requested stack** (framer / react / nextjs / vite) — Framer bindings stripped, `"use client"` added for Next | connector sign-in, or API key | closest to clean, but adaptation is automated and unreviewed |

  - **Choosing between them:** if the target is Framer, copy-to-Framer is the intended path. If the target is React, Vite, or Next, prefer MCP — it strips the Framer bindings that copy-paste leaves behind. Copying raw source into a non-Framer project means you inherit the shim and the annotations, and you own removing them.
  - **MCP endpoint:** `https://mcp.originkit.dev/mcp` (note the separate subdomain; it is not under `www`). Tools: `list_components`, `get_component`, `search`, `fetch`. Custom connectors need **no API key** — paste the endpoint and approve the OAuth sign-in (scope `components:read`). An API key is only for editor/CLI commands: `claude mcp add originkit https://mcp.originkit.dev/mcp --transport http --header "Authorization: Bearer <key>"`. Fetches draw on a shared daily quota. Setup: [integrations page](https://www.originkit.dev/integrations?tab=mcp).
  - **Standing caution — stack adaptation is not review.** Neither copying nor MCP adaptation checks the component against your surface class, motion tokens, or accessibility floor. Every path lands unreviewed source in your repo, so every path gets the intake checklist. The MCP path is the most frictionless and therefore the easiest to skip review on.
- Other copy-paste animated component galleries — same intake rules apply. Treat every gallery preview as a demo on a showcase surface, which is rarely the surface you are building.

Use these as vocabulary and starting points. The judgement about purpose, surface class, accessibility, and performance stays with this skill.
