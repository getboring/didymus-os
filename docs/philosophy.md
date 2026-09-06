# Didymus OS Philosophy

## Why a twin of NixOS?

NixOS already gives us pure, declarative, roll-backable systems.
What it does not give us out of the box is an *explicit twin*.

Didymus adds:

1. **Twin awareness** — every generation can have a stable counterpart.
2. **Receipts** — signed, content-addressed records of what changed.
3. **Tired Test defaults** — configurations that remain understandable when the human is exhausted.
4. **Transferability** — the next person (or future you) can take over without archaeology.

## The Tired Test

A configuration passes the Tired Test if a tired person can answer:

- How do I boot the last known-good system?
- Where are the receipts / twin generations?
- What is the current hostname and version?
- How do I get help without leaving the machine?

If any of those require cleverness, the config fails.

## Clever breaks. Boring lasts.

Cleverness is allowed for one-off problems.
The foundation must be boring so that the clever parts do not become load-bearing.

## Twin modes

- `stable-experimental` — keep a stable twin + working experimental twin
- `primary-mirror` — every generation has a verified mirror
- `disabled` — pure NixOS (escape hatch)

## Relation to other work

- **ScopeBlind** — receipts are designed to be compatible with Ed25519 / Cedar policy verification
- **Boring* tools** — Didymus OS is the host that makes those tools durable
- **Heritage / ops work** — the same “can the next person run it” test applies

