# Pixie

**Pixie** is a small 2D adventure game written in **x86-64 Assembly (FASM)** with platform-specific implementations for **Linux and Windows**.

The project started as an experiment in learning how to build a game while working close to the machine: calling a C library from assembly, managing game state, handling floating-point movement and physics, and organizing a small game into reusable assembly modules.

![Pixie demo](assets/demo.gif)

## What is Pixie?

Pixie is intentionally small. Rather than hiding the implementation behind a large engine or framework, the game uses hand-written x86-64 assembly for its gameplay and rendering-side logic, with [raylib](https://www.raylib.com/) providing the windowing, input, texture, and drawing API.

The codebase currently contains separate platform implementations for:

- **Linux x86-64** — `src/linux_x64/`
- **Windows x86-64** — `src/windows_x64/`

The two implementations share the same general game concepts while using platform-appropriate entry points, includes, libraries, and build tooling.

## Features

- Player movement and jumping
- Horizontal acceleration and deceleration
- Gravity and simple ground handling
- Player state machine (`idle`, `run`, `jump`, `fall`, `break`)
- Sprite animation
- Sprite flipping / directional rendering
- 2D camera handling
- Parallax background rendering

## Why Assembly?

Pixie is primarily a learning project and an exploration of low-level game programming.

Writing the gameplay systems in assembly makes details that are normally hidden by higher-level languages explicit: calling conventions, register usage, stack layout, memory access, floating-point operations, and interaction with external C functions.

For example, the player implementation directly interacts with raylib functions while maintaining the player state and physics data in assembly. This makes Pixie useful as a practical x86-64 learning project as well as a game.

## Architecture

Platform-specific source is kept separate:

```text
src/
├── linux_x64/
│   ├── camera.asm
│   ├── parallax.asm
│   ├── pixie.asm
│   ├── player.asm
│   └── sprite.asm
│
└── windows_x64/
    ├── camera.asm
    ├── main.asm
    ├── parallax.asm
    ├── player.asm
    ├── sprite.asm
    ├── EQUATES/
    ├── MACRO/
    └── WIN64A.INC
```

The Linux and Windows trees also contain their own headers/includes and raylib libraries.

## Requirements

### Linux x86-64

- Linux on x86-64
- [FASM](https://flatassembler.net/)
- GNU `ld`
- `make`
- [raylib](https://www.raylib.com/)

The repository includes the Linux raylib library under `src/linux_x64/lib/`.

### Windows x86-64

- Windows x86-64
- [FASM](https://flatassembler.net/)
- A linker compatible with the provided Windows build setup
- [raylib](https://www.raylib.com/)

The repository includes the Windows-specific build assets under `src/windows_x64/lib/` and a Windows batch build script.

## Building

### Linux

Clone the repository:

```bash
git clone https://github.com/0xFA99/Pixie.git
cd Pixie
```

Build the default Debug configuration:

```bash
make
```

Run it:

```bash
make run
```

The binary is generated at:

```text
build/linux_x64/Pixie
```

Clean the build directory:

```bash
make clean
```

For a release build:

```bash
make MODE=release
```

The release target strips the binary and attempts to compress it with UPX when available.

### Windows

From a suitable x86-64 Windows/FASM build environment, run:

```bat
build.bat
```

The Windows build outputs:

```text
build\windows_x64\Pixie.exe
```

The batch script assembles the files under `src\windows_x64\`, links them with the Windows raylib library, and copies the required DLL beside the executable.

## Build Pipelines

### Linux

```text
FASM (.asm)
    ↓
ELF64 object files (.o)
    ↓
GNU ld
    ↓
Linux x86-64 executable
    ↓
raylib + system libraries
```

### Windows

```text
FASM (.asm)
    ↓
COFF/object files
    ↓
Windows x86-64 linker
    ↓
Windows executable (.exe)
    ↓
raylib DLL + system libraries
```

The exact linker/toolchain differs between the platform implementations.

## Learning Goals

Pixie is an ongoing experiment around:

- x86-64 assembly programming
- Platform-specific assembly development
- Linux ELF64 and Windows executable/toolchain concepts
- Calling conventions and ABI differences
- Register and stack management
- Floating-point operations with SSE instructions
- Calling C APIs from assembly
- Game-state machines
- Basic 2D physics
- Sprite animation and rendering
- Separating game systems into low-level modules

## Status

Pixie is a personal learning project. It is functional, but the architecture and gameplay are still experimental and may change as the project evolves.

## License

See [LICENSE](LICENSE) for the current license.
