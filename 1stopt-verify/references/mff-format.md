# Minimal MFF Format

This skill uses a tiny `.mff` wrapper that 1stOpt V11 accepted during local testing.

## Minimal payload

```text
NewCodeBlock;
ComplexPar x;
Function x^2-4=0;
```

## Important behavior

- `NewCodeBlock` acts as the block marker.
- The file is not plain text only; it uses a short binary wrapper plus an ASCII payload.
- The payload length is stored as a 32-bit little-endian integer immediately after the `auto2fitfile` marker.
- For the reusable verification case, a fixed V11 header and a fixed `CodeSheet1..3` tail were sufficient.

## Validation target

When the user asks for a closed-loop test, the expected solve should show:

- `x=2`
- or `x=-2`
- or both roots

Do not claim success unless the UI shows a real solve result after `F9`.
