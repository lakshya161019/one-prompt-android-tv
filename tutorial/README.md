# Beginner video tutorial

Watch [`one-prompt-android-tv-beginner.webm`](one-prompt-android-tv-beginner.webm) for a narrated, captioned walkthrough of the safe setup flow. It covers identifying the TV, preparing ADB, backups, choosing packages and launcher apps, checking screenshots, optional Private DNS, and closing ADB at the end.

This is an illustrated explainer, not a recording of a specific television. Menus and support vary by model. Keep the TV remote nearby, answer the prompt's questions, and follow the model-specific stop conditions in [`../prompt.md`](../prompt.md). Never disable a package just because its name looks unfamiliar.

## For beginners

1. Read the main [README](../README.md) and check that the TV is Android TV or Google TV.
2. Open [`../prompt.md`](../prompt.md), replace `<MODEL NAME HERE>` with the exact model from Settings → About, and paste the whole prompt into an assistant that can use this repository and connect to your TV.
3. Keep the TV and computer on the same trusted network. Keep the remote nearby. Before enabling debugging, check what is connected to the TV's USB ports and whether a USB Ethernet adapter carries its network.
4. Follow the assistant's questions. Review the package list and proposed changes before allowing them. It should back up state, use the repository's safety checks, and verify changes with screenshots pulled from the TV.
5. Keep the restore script. At the end, have the assistant switch off debugging, revoke authorizations, and verify the ADB ports are closed.

## Re-render the video on Windows

Requires Google Chrome, Node.js, PowerShell 7, and the Windows `System.Speech` voice `Microsoft Zira Desktop` (or another installed Windows voice).

```powershell
pwsh -NoProfile -ExecutionPolicy Bypass -File .\tutorial\render.ps1
```

The script synthesizes narration locally and records the slides to WebM. It does not contact the TV or send the narration to a service.

