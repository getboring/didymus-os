# Testing Didymus OS without a real computer

A generation is real when it evaluates, builds, and boots. Hardware is the last
step, not the first.

## Ladder

Do these in order. Stop when the next one is more machine than you have.

| Step | Command | Needs |
|------|---------|-------|
| 1. Eval | `nix eval .#nixosConfigurations.qemu-lab.config.system.build.toplevel.drvPath` | Nix + flakes |
| 2. Build | `nix build .#nixosConfigurations.qemu-lab.config.system.build.toplevel` | Nix, cache, disk |
| 3. VM test | `nix build .#checks.x86_64-linux.didymus-lab -L` | `/dev/kvm` |
| 4. Interactive VM | `nix build .#qemu-vm && ./result/bin/run-didymus-qemu-vm` | `/dev/kvm` |
| 5. ISO | `nix build .#iso` | lots of disk; not a CI gate |

`didymus-lab` (physical) is the same software as `qemu-lab`. It is **not**
bootable in QEMU: it expects disks labelled `didymus-root` and `didymus-boot`.
Eval and build it anyway — the disks only matter at boot.

```bash
nix eval .#nixosConfigurations.didymus-lab.config.system.build.toplevel.drvPath
```

## Cloud builders (no laptop)

This repository is public. Two CI paths:

1. **Garnix** — native Nix CI. Install the [Garnix GitHub App](https://garnix.io)
   on `getboring/didymus-os`. It builds everything in `garnix.yaml` (eval, VM
   test, QEMU closure). It does **not** use GitHub Actions minutes.
2. **GitHub Actions** — `.github/workflows/ci.yml`. Same Determinate Nix path
   as `getboring/boring-agent-appliance`. `workflow_dispatch` works from the
   GitHub mobile app. Needs the account to be able to allocate `ubuntu-24.04`
   runners, and the runner must expose `/dev/kvm`.

If Actions cannot allocate a runner, Garnix is the path. Do not wait on a lab
box.

## What the VM test asserts

`checks.x86_64-linux.didymus-lab` boots the lab software (no physical disks)
and checks:

- hostname `didymus-lab`, version `0.1.0-scaffold`
- `/etc/didymus/{README,TWIN.md,TIRED-TEST.md}`
- `didymus-twin-init.service` ran and stayed active
- `/var/lib/didymus/receipts/.initialized` exists and names `stable-experimental`
- `sshd` is up

If you add a twin behaviour, add a subtest. A generation that only evaluates
is not yet a twin.

## What still needs hardware

- labelled disks / installer
- Secure Boot key enrollment
- real NIC, GPU, TPM
- the live ISO on a USB stick

Until then, a green VM test is the receipt that the software twin boots.

## Tired Test

A tired person should be able to answer, from this file and the CI log:

1. Did this commit eval?
2. Did a VM boot?
3. Where are the twin receipts inside the guest?

If the answer is “I need the tablet,” this file failed.
