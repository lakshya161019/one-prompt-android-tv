# One Prompt Android TV

This repository is self-contained: it includes the one-shot task prompt plus compressed bundles of CleanYourTV's safety-checked tools, launcher source, device examples, themes, and documentation. You do not need to clone another repository.

## Use it

1. Open [`prompt.md`](prompt.md) and replace `<MODEL NAME HERE>` with the model shown in your TV's About screen.
2. Clone or download this repository, then paste the full prompt into an AI coding agent that can run shell commands on a computer on the same network as the TV.
3. The prompt tells the agent to extract `cleanyourtv-core.zip` and `cleanyourtv-reference.zip` into the repository root before using any device tools.
4. Keep the TV nearby. Follow the prompt's questions, enable ADB only when asked, accept the on-screen debugging prompt, and inspect screenshots and proposed package changes before proceeding.

This is for Android TV / Google TV. It does not apply to Samsung Tizen, LG webOS, Roku, VIDAA, SmartCast, or Fire TV. See <https://cleanyour.tv/not-android> for non-Android sets.

## Safety

ADB over a network is plaintext on port 5555. Use a trusted network, limit the time debugging is enabled, and require a verified closed-port check before finishing. Never allow the agent to disable packages that your TV needs, and do not continue if the TV model/OS or a package's purpose is unclear. Keep the stock launcher enabled until the replacement is installed and confirmed as Home. Backups and restore instructions are required before any package changes.

The workflow is not a guarantee that every TV supports sideloading or a third-party Home app. Follow the stop conditions in `prompt.md` and the bundled device-specific notes.

## Bundled source

- `cleanyourtv-core.zip` contains `tools/`, `launcher/`, and `themes/`.
- `cleanyourtv-reference.zip` contains `docs/` and `examples/`.

Both archives are clean snapshots of [Gathin23/CleanYourTV](https://github.com/Gathin23/cleanyourtv) at upstream commit `57c00a40dafe040b0be1f32086e96c05a1a37054`. The upstream MIT license and notice are included in [`LICENSE`](LICENSE). This repository does not automatically receive future upstream fixes; review a clean upstream revision and update the bundled archives when refreshing it.

