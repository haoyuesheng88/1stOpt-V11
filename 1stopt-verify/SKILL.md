---
name: 1stopt-verify
description: Connect to an already-open local 1stOpt 11.0 window on Windows, generate or load a minimal verification `.mff`, run it with `F9`, and verify the solve closes the loop. Use when the user mentions 1stOpt, FirstOpt, 1stOpt 11.0, an already-open 1stOpt window, entering a test function, F9, or a reusable verification workflow for 1stOpt V11.
---

# 1stOpt Verify

Use this skill when 1stOpt 11.0 is already installed locally and the user wants Codex to connect to the open desktop app, run a simple verification function, and confirm the result.

Assume Windows, PowerShell, and a user-visible 1stOpt session.

## Default verification target

The fastest stable verification case is:

```text
NewCodeBlock;
ComplexPar x;
Function x^2-4=0;
```

Expected result:

- `x=2`
- or `x=-2`
- or both roots, depending on the active 1stOpt mode

## Known UI facts

- Process name is typically `FirstOpt`
- The application window may appear as `1stOpt`
- The visible work window is often a `TFitForm`
- The code editor is commonly `TSynEdit`
- `NewCodeBlock` is a required block marker for this simple payload
- `F9` is the run shortcut

## Workflow

1. Run [scripts/find-open-firstopt.ps1](./scripts/find-open-firstopt.ps1) to locate visible 1stOpt windows.
2. Prefer the currently active 1stOpt work window if the user already has a file open.
3. If direct typing into the editor is unreliable, create a standalone verification file with [scripts/new-1stopt-verify-mff.ps1](./scripts/new-1stopt-verify-mff.ps1) instead of overwriting the user's current file.
4. Open that file in 1stOpt with [scripts/open-firstopt-file.ps1](./scripts/open-firstopt-file.ps1).
5. Bring the target window to the foreground and send `F9` with [scripts/send-firstopt-f9.ps1](./scripts/send-firstopt-f9.ps1).
6. If the visible result needs evidence, capture the target window with [scripts/capture-firstopt-window.ps1](./scripts/capture-firstopt-window.ps1).
7. Confirm the result pane, result list, or visible solution contains `x=2`, `x=-2`, or both.

## Preferred command

For the normal closed-loop path, use:

```powershell
& ".\1stopt-verify\scripts\invoke-firstopt-verify.ps1"
```

This script:

- creates a minimal verification `.mff`
- opens it in 1stOpt
- brings the window forward
- sends `F9`

## Safety rules

- Do not overwrite the user's existing `.mff` unless they ask for that specifically.
- Treat `C:\Program Files (x86)\1stOpt 11.0` as potentially read-only.
- Prefer generating a new `.mff` in a writable workspace.
- If multiple 1stOpt windows are open, say which one you used.
- If `F9` is the only blocked step, ask the user for one foreground click before asking for anything larger.

## Output checklist

When you report back, include:

- which 1stOpt window or file was used
- which function was run
- whether `F9` was sent
- what visible result was observed
- whether verification succeeded, failed, or was blocked

## References

- Minimal `.mff` structure and payload notes: [references/mff-format.md](./references/mff-format.md)
