# Didymus OS

**A twin of NixOS.**  
Declarative. Reproducible. Verifiable. Boring on purpose.

> "Unless I see the receipts and put my finger on the twin generation, I will not believe."  
> — the Didymus principle

Didymus OS is an opinionated NixOS distribution (and flake framework) built for people who want systems that:
- survive the **Tired Test**
- leave **twin receipts** for every generation
- keep a **stable twin** and an **experimental twin** side-by-side
- make the next person able to run it without heroics

It is **not** another flashy distro. It is NixOS with a twin soul.

## Core ideas

| Concept | What it means |
|---------|---------------|
| **Twin generations** | Every rebuild produces a verifiable pair (primary + twin) with signed receipts |
| **Stable twin / Experimental twin** | Two concurrent profiles you can switch between without losing the other |
| **Receipts** | Ed25519-signed, content-addressed records of what changed (ScopeBlind-ready) |
| **Tired Test** | Configs must still make sense at 2 a.m. after a long day |
| **Boring lasts** | Prefer durable, well-understood primitives over novelty |

## Status

**v0.1 — Scaffolding** (September 2026)  
This is the first cut: flake + modules + host example + ISO skeleton.  
Next: twin generation manager, receipt tooling, mobile/ops surfaces, agent integration.

## Quick start (on any Nix-capable machine)

```bash
# Clone
git clone https://github.com/getboring/didymus-os.git
cd didymus-os

# Enter the development shell
nix develop

# Build a configuration for the example host
nix build .#nixosConfigurations.didymus-lab.config.system.build.toplevel

# Or create an ISO (when ready)
nix build .#iso
```

## Project layout

```
didymus-os/
├── flake.nix                 # Entry point
├── modules/                  # Didymus modules
│   ├── twin.nix              # Twin generation + receipt system
│   ├── boring.nix            # Tired-test defaults
│   ├── didymus.nix           # Core options
│   └── ...
├── hosts/                    # Host-specific configs
│   └── didymus-lab/
├── profiles/                 # Ready-to-use profiles (desktop, server, agent, etc.)
├── docs/
├── scripts/
└── iso/
```

## Philosophy (one paragraph)

Didymus OS takes the best of NixOS (pure, declarative, rollbacks) and adds an explicit twin layer so you always have a verifiable counterpart. It is designed so that a tired human (or the next operator) can understand the state of the machine without replaying the entire history. Every meaningful change leaves a receipt. Clever breaks are allowed; boring foundations are required.

## Roadmap (first release)

- [x] Flake scaffold + core modules
- [ ] Twin generation manager (systemd + CLI)
- [ ] Signed receipts (Ed25519 + content-addressed)
- [ ] `didymus` CLI (`switch`, `twin`, `receipts`, `verify`)
- [ ] Minimal desktop + server profiles
- [ ] ISO builder
- [ ] Integration points for ScopeBlind / MCP safety
- [ ] Documentation that itself passes the Tired Test

## License

AGPL-3.0-or-later (same spirit as other durable systems work).  
Modules intended for reuse will be dual-licensed more permissively later.

---

**Clever breaks. Boring lasts.**  
Built by Cody Boring / getboring  
https://getboring.io · https://codyboring.com
