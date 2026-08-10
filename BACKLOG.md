# Backlog

Deferred ideas and follow-ups — not yet scheduled. Revisit when picking up new work.

---

## CI-built, pre-cached Nix builds (replace ad hoc distributed builds)

**Status:** researched, not yet implemented (2026-08-10)

**Context:** Laptop previously offloaded builds to desktop via `nix.distributedBuilds`
(`hosts/laptop/default.nix`), which requires desktop to be online and plugged in at
the exact moment `nrsu` runs. This broke when desktop was unplugged — see the
`nix.buildMachines`/`secrets.desktop.hostname` fixes earlier in git history. Disabled
for now (`nix.distributedBuilds = false`), builder list left in place but inert.

Explored what the "amortize builds ahead of time" pattern looks like properly:

- **Hydra** — the full nixpkgs-style CI+cache tool. Ruled out: needs Postgres + a
  web app + its own evaluator, and flakes are a second-class citizen there (built
  around channels/`release.nix`). Disproportionate ops cost for two personal machines.
- **Attic** — self-hosted binary cache server (dedup, GC, scoped push tokens) sitting
  in front of S3-compatible storage. Realized it isn't an orchestrator — GitHub
  Actions (or any CI) still does 100% of the "when to build" decision either way.
  Attic just adds a nicer/managed storage layer on top of a bucket. Not worth the
  extra running service (one more thing to patch/monitor) for a single-user,
  single-repo cache.
- **Garnix** — fully hosted flake CI + cache, zero infra. Legitimate zero-ops option,
  but a recurring subscription for something cheaply self-hostable, and reintroduces
  a "depends on a third party staying around" risk (see: `hermes`/exe.dev retiring).
- **Raw S3-compatible storage (settled direction)** — Nix has native `s3://` binary
  cache support. GitHub Actions builds on push (or a `schedule:` cron trigger),
  signs the result, and `nix copy --to s3://...` ships it directly to a bucket — no
  server of our own to run. Consuming machines add the bucket as a
  `nix.settings.substituters` entry and trust the signing key via
  `trusted-public-keys`.
  - Storage backend can be **Backblaze B2** (cheap, always reachable, small monthly
    cost) or the **home NAS** (`secrets.nix` `nas.ip`, already always-on) via MinIO —
    free, but only as reliable as home power/internet. Either way, CI reaching a
    Tailscale-only home target works via the `tailscale/github-action`, which lets
    an ephemeral GH-hosted runner join the tailnet for the job.
  - Falls back gracefully: if the cache/CI hasn't caught up or is unreachable,
    `nrsu` just builds locally like it does today — not a hard dependency.

**Action item:** Look into this more and actually set it up — decide B2 vs home NAS
for storage, generate a Nix signing keypair, write the GitHub Actions workflow
(build `nixosConfigurations.laptop`/`desktop` toplevels + push), and wire
`nix.settings.substituters`/`trusted-public-keys` into `modules/nixos/networking.nix`
(or a new shared module) for both hosts.
