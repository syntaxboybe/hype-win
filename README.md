# Hype for Windows

Hype is a native Windows presentation editor. Write slides in Markdown, arrange them in a visual editor, add images or video, present fullscreen, and export to PDF or PowerPoint.

This repository is the Windows port of [Hype](https://github.com/omacom/hype). It uses native Windows file dialogs, a built-in Tokyo Night theme, and bundled runtime files. Omarchy, D-Bus, and Linux-only desktop services are not required.

## Requirements

- Windows 10 or newer
- Qt 6.9 or newer
- C++17 MinGW toolchain
- FFmpeg for video posters and PowerPoint video conversion
- `source-highlight` is optional; without it, code blocks remain readable but are not syntax-colored

MSYS2 UCRT64 is the recommended toolchain. Install Qt, MinGW, FFmpeg, and the required Qt modules in the UCRT64 environment.

## Build on Windows

From PowerShell at the repository root:

```powershell
.\bin\build-windows.ps1 -QtBin 'C:\msys64\ucrt64\bin'
```

The script:

- checks for Qt 6.9 or newer;
- builds `build\release\hype.exe`;
- deploys Qt and QML plugins;
- bundles the MinGW and FFmpeg runtime DLLs;
- writes the required `qt.conf` file.

The resulting application can run without adding the MSYS2 runtime directory to the global `PATH`.

## Create the installer

Install Inno Setup 6, then build the per-user installer:

```powershell
.\bin\package-windows.ps1 -QtBin 'C:\msys64\ucrt64\bin'
```

The installer is written to `dist\hype-setup.exe`. It installs Hype under the current user's local programs directory, registers `hype.exe` with Windows App Paths, creates a Start Menu shortcut, and optionally creates a desktop shortcut or adds Hype to Markdown files' **Open with** list. It does not require administrator rights.

To package an already-built release without rebuilding:

```powershell
.\bin\package-windows.ps1 -SkipBuild
```

## Run Hype

Run the executable directly:

```powershell
.\build\release\hype.exe open .\examples\welcome.md
```

For a shorter command, add the repository directory to your user `PATH`. The checkout includes `hype.cmd`:

```powershell
$repo = 'C:\path\to\hype'
$env:PATH = "$repo;$env:PATH"
```

Open a new PowerShell after changing the permanent user `PATH`. Then use:

```powershell
hype
hype open .\talk.md
```

- `hype` opens the last presentation.
- `hype open` opens the last presentation.
- `hype open .\talk.md` opens a specific Markdown file.
- `hype .\talk.md` also opens that file.

## Create a presentation

```powershell
hype new .\talk.md --title "My Talk"
hype open .\talk.md
```

The command creates `talk.md` plus `images` and `videos` directories beside it.

Optional metadata:

```powershell
hype new .\talk.md `
  --title "My Talk" `
  --theme tokyo-night `
  --font "JetBrains Mono"
```

Use `hype themes` to list available themes. The Windows build always includes `tokyo-night`.

## Command-line help

Hype has two kinds of commands: editor commands and display-free commands.

```powershell
hype --help
hype help
hype help format
hype help new
hype help check
hype help slides
hype help render
hype help export
hype help themes
hype help skill
```

`hype help format` prints the complete Markdown format reference. `hype help <command>` prints the options for one command.

### Create and inspect

```powershell
hype new .\talk.md --title "My Talk"
hype check .\talk.md
hype check .\talk.md --json
hype slides .\talk.md
hype slides .\talk.md --json
hype themes
hype themes --json
```

`check` reports errors and warnings with slide and line numbers. It checks slide syntax, media references, layout options, unfinished code fences, and text that becomes too small to fit.

### Render slides

Render one slide:

```powershell
hype render .\talk.md --slide 1 --output .\slide.png
```

Render every slide into a directory:

```powershell
hype render .\talk.md --output .\slides
```

Useful options:

```powershell
hype render .\talk.md --slide 1 --width 1280
hype render .\talk.md --slide 1 --output .\slide.png --json
```

The default render width is 1920 pixels. Valid widths are 160 through 7680 pixels.

### Export

The output extension selects the format:

```powershell
hype export .\talk.md .\talk.pdf
hype export .\talk.md .\talk.pptx
hype export .\talk.md .\talk.pdf --json
```

PDF and PowerPoint exports use the rendered slide appearance. Original media files are not modified.

### Coding-agent skill

Print the Hype skill reference:

```powershell
hype skill
```

Install it for coding agents:

```powershell
hype skill install
```

## Write slides in Markdown

Separate slides with `---` and leave a blank line around the separator:

````markdown
---
title: My Talk
theme: tokyo-night
---

# First slide

Write the main idea here.

---

# Second slide

- One point
- Another point

---

> A closing thought
````

Supported content includes:

- headings, paragraphs, lists, quotes, tables, and inline code;
- fenced code blocks with languages such as `powershell`, `javascript`, `json`, `rust`, or `ruby`;
- hidden speaker notes in `<!-- comments -->`;
- SVG code blocks;
- images, animated images, and videos.

Use `hype help format` for the complete syntax reference.

## Add images and video

Keep media beside the Markdown file:

```text
my-talk/
  talk.md
  images/
    city.jpg
    diagram.png
  videos/
    demo.mp4
```

Reference media by filename:

```markdown
![fit](diagram.png)

---

![span](city.jpg)

---

![loop muted](demo.mp4)
```

Common media options:

| Markdown | Result |
| --- | --- |
| `![fit](photo.jpg)` | Show the complete image |
| `![span](photo.jpg)` | Fill the slide and crop as needed |
| `![fit background=blur](photo.jpg)` | Use a blurred image behind the fitted image |
| `![position=bottom-right size=10%](logo.png)` | Place a small logo |
| `![loop muted](demo.mp4)` | Loop a video without sound |
| `![autoplay=false](demo.mp4)` | Wait for Space before playing |

Paste or drag media into the editor with **Ctrl+V**. Hype stores pasted media in the presentation's `images` or `videos` directory.

Each slide supports one image or video. Copy the complete presentation folder when sharing it.

## Edit and present

Hype saves automatically after editing pauses. Use **Ctrl+S** to save, or choose a file when saving a new presentation.

Click **Present** or press:

- **Ctrl+Space** or **F5**: present from the selected slide;
- **Shift+F5**: present from the first slide;
- **Arrow keys**: navigate;
- **Space**: play or pause video;
- **Escape**: return to editing.

With multiple displays, Hype presents fullscreen on the selected audience display and can show presenter notes on the other display.

## Keyboard shortcuts

| Shortcut | Action |
| --- | --- |
| Ctrl+N / Ctrl+O | New presentation / open file |
| Ctrl+S / Ctrl+Shift+S | Save / save as |
| Ctrl+E / Ctrl+Shift+E | Export PDF / PowerPoint |
| Ctrl+M | Toggle slide overview |
| Ctrl+. | Toggle Markdown mode |
| Ctrl+B / Ctrl+I / Ctrl+U | Bold / italic / underline |
| Ctrl+H / Ctrl+K / Ctrl+/ | Headline / code block / hidden comment |
| Ctrl+Enter | Add a slide |
| Ctrl+D | Duplicate selected slides |
| Delete | Delete selected slides |
| Ctrl+Z / Ctrl+Shift+Z | Undo / redo |
| ? / F1 | Show all shortcuts |
| Ctrl+Space / F5 | Present from the selected slide |
| Shift+F5 | Present from the first slide |
| Escape | Leave presentation mode |

## Recovery and backups

Hype keeps `.hype-backups` beside each saved presentation and maintains local recovery snapshots for unfinished work. Use **Version history** in the file menu to restore an earlier version.

Recovery snapshots contain Markdown and slide boundaries, not copies of images or videos. Keep the presentation folder intact when restoring or moving a project.

## Troubleshooting

### `hype` is not recognized

Use the executable directly:

```powershell
.\build\release\hype.exe open .\talk.md
```

Or add the repository directory containing `hype.cmd` to `PATH`, open a new PowerShell, and check the resolved command:

```powershell
where.exe hype
```

### A DLL error appears

Rebuild the deployed package so the runtime files are copied beside the executable:

```powershell
.\bin\build-windows.ps1 -QtBin 'C:\msys64\ucrt64\bin'
```

### Video export or video posters fail

Ensure these executables are available on `PATH`:

```powershell
Get-Command ffmpeg
Get-Command ffprobe
```

## Development

Build after source changes:

```powershell
.\bin\build-windows.ps1 -QtBin 'C:\msys64\ucrt64\bin'
```

The main Windows files are:

- `src\main.cpp`: Windows application startup and Qt platform setup;
- `src\filedialog.cpp`: native Windows file dialogs;
- `bin\build-windows.ps1`: build and deployment;
- `hype.cmd`: PowerShell and Command Prompt launcher;
- `hype.pro`: Qt project configuration.

Changes are committed using Conventional Commits, for example:

```text
feat(windows): add native build and launcher support
fix(windows): prevent startup crash on Windows
```
