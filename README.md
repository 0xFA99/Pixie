# Pixie

**Pixie** is a small 2D adventure game written directly in **x86-64 Assembly (FASM)** for Linux.

The project began as an experiment in learning how to build a game while working close to the machine: calling a C library from assembly, managing game state, handling floating-point movement and physics, and organizing a small game into reusable assembly modules.

![Pixie demo](assets/demo.gif)

## What is Pixie?

Pixie is intentionally small. Rather than hiding the implementation behind a large engine or framework, the game uses hand-written x86-64 assembly for its gameplay and rendering-side logic, with [raylib](https://www.raylib.com/) providing the windowing, input, texture, and drawing API.

Current gameplay code includes:

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

For example, the player implementation directly calls raylib functions such as `IsKeyPressed`, `IsKeyDown`, and `DrawTexturePro`, while maintaining the player state and physics data in assembly. This makes Pixie useful as a practical x86-64 learning project as well as a game.

## Architecture

The Linux x86-64 implementation is split into several assembly modules:

```text
src/linux_x64/
├── camera.asm   # Camera handling
├── parallax.asm # Parallax background
├── pixie.asm    # Main game logic / entry point
├── player.asm   # Input, movement, physics, animation state
└── sprite.asm   # Sprite and animation handling
```

The project keeps the low-level code separate by responsibility while still staying small enough to understand as a whole.

## Requirements

- Linux on x86-64
- [FASM](https://flatassembler.net/)
- GNU `ld`
- `make`
- [raylib](https://www.raylib.com/)

The repository contains the raylib shared library used by the build under `src/linux_x64/lib/`.

## Build

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

Or run the generated binary directly:

```bash
./build/linux_x64/Pixie
```

Clean the build directory:

```bash
make clean
```

### Release build

The Makefile also provides a release mode:

```bash
make MODE=release
```

The release target strips the binary and attempts to compress it with UPX when available.

## Build Pipeline

Pixie uses a deliberately small build pipeline:

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

The linker resolves the external C/raylib functions used by the assembly modules, while FASM produces the ELF64 object files.

## Learning Goals

Pixie is an ongoing experiment around:

- x86-64 assembly programming
- Linux ELF64 binaries
- FASM and GNU toolchains
- x86-64 calling conventions
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
