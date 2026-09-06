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
Flake + modules + lab host + QEMU twin + NixOS VM test + cloud CI.  
A physical machine is not required to evaluate, build, or boot a generation.

## Quick start (no real computer)

You do not need a tablet or a lab box. You need Nix (locally, in Codespaces, or in CI).

```bash
git clone https://github.com/getboring/didymus-os.git
cd didymus-os
nix develop

# 1. Prove the configs exist (no KVM, seconds)
nix eval .#nixosConfigurations.qemu-lab.config.system.build.toplevel.drvPath
nix eval .#nixosConfigurations.didymus-lab.config.system.build.toplevel.drvPath

# 2. Boot a VM and assert the twin layer (needs /dev/kvm)
nix build .#checks.x86_64-linux.didymus-lab -L

# 3. Interactive QEMU — no physical disk is touched
nix build .#qemu-vm
./result/bin/run-didymus-qemu-vm
```

From a phone: push to `main` or open a PR. GitHub Actions and Garnix do steps 1–3.  
Garnix does **not** use Actions minutes — enable the [Garnix GitHub App](https://garnix.io) on this repo if Actions runners are dark.

Full ladder, including ISO: [`docs/TESTING.md`](docs/TESTING.md).

## Hosts

| Flake output | What it is | Disks |
| --- | --- | --- |
| `nixosConfigurations.didymus-lab` | Physical lab twin | labelled `didymus-root` / `didymus-boot` |
| `nixosConfigurations.qemu-lab` | Same software, QEMU | virtio, auto-format |
| `checks.x86_64-linux.didymus-lab` | Headless NixOS VM test | none (test driver) |
| `packages.qemu-vm` | Interactive `run-didymus-qemu-vm` | none on the host |
| `packages.iso` | Live installer ISO | opt-in, not a CI gate |

## Project layout

```
didymus-os/
├── flake.nix                 # Entry point
├── flake.lock                # Pinned nixos-26.05
├── garnix.yaml               # Public Nix CI (no Actions minutes)
├── modules/                  # Didymus modules
│   ├── twin.nix              # Twin generation + receipt system
│   ├── boring.nix            # Tired-test defaults
│   └── didymus.nix           # Core options
├── hosts/
│   ├── didymus-lab/          # Software + physical hardware
│   └── qemu-lab/             # VM overlay (no real disks)
├── profiles/                 # Ready-to-use profiles (desktop, server, agent, etc.)
├── docs/
│   ├── philosophy.md
│   └── TESTING.md            # Cloud / QEMU / CI ladder
├── scripts/
└── iso/
```

## Philosophy (one paragraph)

Didymus OS takes the best of NixOS (pure, declarative, rollbacks) and adds an explicit twin layer so you always have a verifiable counterpart. It is designed so that a tired human (or the next operator) can understand the state of the machine without replaying the entire history. Every meaningful change leaves a receipt. Clever breaks are allowed; boring foundations are required.

## Roadmap (first release)

- [x] Flake scaffold + core modules
- [x] QEMU lab host + NixOS VM test (no physical machine)
- [x] Cloud CI (GitHub Actions + Garnix)
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
