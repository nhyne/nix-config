---
name: validate-proof
description: Validate your work, capture screenshot proof, combine into an animated GIF, and open an HTML review page
---

You are in proof-validation mode. Prove that your implementation is correct by running checks, capturing screenshots, and producing an animated GIF embedded in an HTML review page.

## Requirements

- `screencapture` — built-in on macOS
- `ffmpeg` — must be installed (`brew install ffmpeg`)

## Step 1: Set up temp directory

```bash
PROOF_DIR=$(mktemp -d /tmp/proof.XXXXXX)
echo "Proof dir: $PROOF_DIR"
```

## Step 2: Validate

Identify all relevant checks for this project (type checking, tests, lint, build). Run each one. For each step:

1. Print a visible header so the terminal clearly shows what's being validated:
   ```
   echo -e "\n========================================\n  STEP N: <description>\n========================================\n"
   ```
2. Run the command (let it print to the terminal normally).
3. Immediately capture a screenshot:
   ```bash
   sleep 0.5 && screencapture -x "$PROOF_DIR/proof_N.png"
   ```

Repeat for every validation step (tests, type check, lint, build, etc.).

## Step 3: Build the animated GIF

After all screenshots are captured, combine them using ffmpeg. Use a 2-second delay per frame and scale to 1280px wide:

```bash
ffmpeg -y \
  -framerate 0.5 \
  -pattern_type glob -i "$PROOF_DIR/proof_*.png" \
  -vf "fps=0.5,scale=1280:-1:flags=lanczos,split[s0][s1];[s0]palettegen[p];[s1][p]paletteuse" \
  "$PROOF_DIR/validation_proof.gif"
```

If glob ordering is wrong, list files explicitly:
```bash
ffmpeg -y \
  -framerate 0.5 \
  -i "$PROOF_DIR/proof_1.png" -i "$PROOF_DIR/proof_2.png" \
  ... \
  -filter_complex "[0][1]...concat=n=N:v=1:a=0,fps=0.5,scale=1280:-1:flags=lanczos,split[s0][s1];[s0]palettegen[p];[s1][p]paletteuse" \
  "$PROOF_DIR/validation_proof.gif"
```

## Step 4: Create the HTML review page

Write an HTML file at `$PROOF_DIR/index.html` with:
- A clean dark background
- The animated GIF displayed full-width and centered
- A summary table listing each validation step and its pass/fail result
- The path to the proof directory shown at the bottom

Use this template (fill in actual step results):

```html
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <title>Validation Proof</title>
  <style>
    body { background: #0d1117; color: #e6edf3; font-family: monospace; max-width: 1300px; margin: 0 auto; padding: 2rem; }
    h1 { color: #58a6ff; }
    img { width: 100%; border: 1px solid #30363d; border-radius: 8px; margin: 1.5rem 0; }
    table { border-collapse: collapse; width: 100%; margin-top: 1rem; }
    th, td { border: 1px solid #30363d; padding: 0.6rem 1rem; text-align: left; }
    th { background: #161b22; color: #8b949e; }
    .pass { color: #3fb950; }
    .fail { color: #f85149; }
    footer { margin-top: 2rem; color: #484f58; font-size: 0.8rem; }
  </style>
</head>
<body>
  <h1>Validation Proof</h1>
  <img src="validation_proof.gif" alt="Validation proof">
  <table>
    <tr><th>#</th><th>Step</th><th>Result</th></tr>
    <!-- one row per validation step -->
    <tr><td>1</td><td>Type check</td><td class="pass">PASS</td></tr>
  </table>
  <footer>Proof captured at: PROOF_DIR_PLACEHOLDER</footer>
</body>
</html>
```

Replace `PROOF_DIR_PLACEHOLDER` with the actual `$PROOF_DIR` value.

## Step 5: Open the page

```bash
open "$PROOF_DIR/index.html"
```

Report the path to `$PROOF_DIR` so the user can find the files.
