# One Prompt Android TV

Use one prompt to guide an AI coding agent through a cautious Android TV debloat and a clean Apple TV inspired launcher setup. The prompt asks preference questions before changing device behavior, uses the maintained CleanYourTV scripts, backs up state, verifies changes with TV screenshots, and closes ADB at the end.

## Use it

1. Open [`prompt.md`](prompt.md) and replace `<MODEL NAME HERE>` with the model shown in your TV's About screen.
2. Paste the full prompt into an AI coding agent that can run shell commands on a computer on the same network as your TV.
3. Keep the TV nearby. Follow its questions, enable ADB only when asked, accept the on-screen debugging prompt, and inspect screenshots and proposed package changes before proceeding.
4. The prompt instructs the agent to clone the maintained tools repository when it is missing: <https://github.com/Gathin23/cleanyourtv>.

This prompt is for Android TV / Google TV. It does not apply to Samsung Tizen, LG webOS, Roku, VIDAA, SmartCast, or Fire TV. See <https://cleanyour.tv/not-android> for non-Android sets.

## Safety

ADB over a network is plaintext on port 5555. Use a trusted network, limit the time debugging is enabled, and require a verified closed-port check before finishing. Never allow the agent to disable packages that your TV needs, and do not continue if the TV model/OS or a package's purpose is unclear. Keep the stock launcher enabled until the replacement is installed and confirmed as Home. Backups and restore instructions are required before any package changes.

The prompt is a starting workflow, not a guarantee that every TV supports sideloading or a third-party Home app. Follow the stop conditions in the prompt and the maintained repository's device-specific notes.

## Upstream

The safety scripts, reference launcher, device notes, and maintained prompt source live in [CleanYourTV](https://github.com/Gathin23/cleanyourtv). Please report safety improvements upstream rather than forking its tooling here.
