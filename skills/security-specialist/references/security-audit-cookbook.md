# Security audit cookbook

Reference for [`security-specialist`](../SKILL.md). Read this when running a security audit, a secure design review, or a PR review for introduced vulnerabilities.

Treat these as a checklist, not a script — skip what doesn't apply, deepen where the project is exposed. Stack-specific examples name common platforms; translate them to whatever the project actually uses rather than assuming the named one.

## 1. Secrets and environment variables
- Hardcoded credentials in source files, comments, or commit history.
- Client-side env prefixes that leak server secrets: `NEXT_PUBLIC_`, `VITE_`, `EXPO_PUBLIC_`, `REACT_APP_` — anything in these is in the public bundle.
- What belongs client-side: Supabase anon key, Stripe publishable key, Firebase client config.
- What must NEVER be client-side: Supabase `service_role`, Stripe secret key, DB connection strings, JWT signing secrets, OAuth client secrets, AI provider keys.
- `.env*.local` in `.gitignore` before first commit. `.env*.example` files contain only placeholders.
- Run `gitleaks detect` on history; rotate any committed secret.

## 2. Database access control
- **Supabase RLS:** every `public.*` table has `enable row level security`. Policies scope to `auth.uid() = user_id` with matching `with check`. Avoid `using (true)` and `using (auth.uid() is not null)`.
- **Sensitive columns** on user-writable tables (`is_admin`, `subscription_tier`, `god_mode_enabled`, `credits`) must be locked at the column-grant level, not just trusted to RLS.
- **Junction tables, audit logs, metadata tables** need their own policies — they're forgotten frequently.
- **`security definer` functions** belong in a `private` schema with `set search_path = ''` and validated inputs.
- **Storage buckets** need `storage.objects` policies scoping by `(storage.foldername(name))[1] = (select auth.uid())::text`.
- **Firebase / Convex** equivalents: `request.auth.uid == userId`, `ctx.auth.getUserIdentity()` checks, field-level diff validation, no subcollection-implicit-rules assumption.

## 3. Authentication and authorisation
- Use `jwt.verify()` not `jwt.decode()`; reject `alg: "none"`; validate issuer/audience/expiry.
- Edge functions, Server Actions, route handlers — every public endpoint authenticates **and** authorises (owner, role, tenant) at the top, even when middleware "should" have caught it.
- Service-role DB clients in edge functions bypass RLS — caller must scope every query by `user_id` themselves.
- Tokens in `localStorage` are XSS-stealable; HttpOnly cookies (or in-memory + HttpOnly refresh) are stronger for sensitive data.
- Password minimum at sign-up matches password change; consider HIBP-style breach checks; offer optional MFA.
- Admin role checks should query the role table at request time, not trust JWT claims that may be stale.

## 4. Rate limiting and abuse prevention
- Apply to: auth (login/signup/reset/OTP), AI calls, email/SMS, file processing, anything fan-out or expensive.
- Combine **per-IP and per-user** axes — IP-only is bypassed by VPN rotation, user-only by account churn.
- Counters belong in a private store (Redis, private-schema table) — never a public-readable Supabase table.
- Fail-closed on irreversible or paid-downstream operations. Fail-open is acceptable on read-side endpoints.
- Set hard spending caps on every billable upstream (AI providers, cloud).

## 5. Payments
- Look up prices server-side; never trust `req.body.amount`.
- Verify webhook signatures; rotate webhook secrets.
- Subscription state checks must hit the source of truth, not a stale cached flag.

## 6. AI / LLM integration
- Provider API keys server-side only.
- Per-user usage caps in code; provider-level caps as backstop only.
- Separate `system` and `user` messages — never concatenate user input into the system prompt.
- Treat LLM output as untrusted user input: sanitise before HTML rendering, never `eval`, validate tool/function-call parameters against a schema.
- Where the data is sensitive or tenant-scoped, validate that the AI handler's data fetch is scoped to the calling user's records — a single missing ownership filter is a cross-tenant data leak.
- Daily spend summary + alert webhook — surprise bills are how this fails first.

## 7. Mobile / PWA / offline-first
- API keys in JS / native bundles are exposed.
- `AsyncStorage` / `localStorage` for tokens is XSS / forensic-extraction risk.
- Deep link / universal link validation.
- Service worker scope: which requests are cached, what does it leak when offline.
- IndexedDB query persistence: what does it cache, can it cache sensitive data by accident.

## 8. Deployment and headers
- CSP, HSTS, X-Frame-Options, X-Content-Type-Options, Referrer-Policy, Permissions-Policy on every response.
- Headers configured for the actual host (Vercel needs `vercel.json`; `_headers` is Netlify/Cloudflare Pages — check what your platform reads).
- Source maps disabled in production.
- `.git/` not served publicly.
- CORS whitelisted to known origins; no `Access-Control-Allow-Origin: *` with credentials.
- Environment separation: production keys never in preview / staging.

## 9. Data access and input validation
- Parameterised queries / ORM methods; never string-concatenate user input into SQL.
- Validate all external input at boundaries with a runtime schema (Zod, Yup, Joi). TypeScript types are compile-time only.
- Don't spread request bodies into DB updates (mass assignment); pick allowed fields explicitly.
- Beware ORM operator injection: an unvalidated `req.body` to Prisma `findFirst` lets `{ email: { contains: "" } }` match every record.
