# Pixie - A Tiny Adventure in Assembly!

Welcome to **Pixie**, a simple yet magical gmae written in **x64 assembly (FASM)** using the raw pixel-shooting power of **Raylib** and the blood, sweat and tears of my remining neurons!

This is not just a game. It's a cry for help.
It's a rebellion against modern software bloat.

![Demo](assets/demo.gif)

## Getting Started
### Requirements
- Linux (x86_64)
- [FASM](https://flatassembler.net/) - because who needs sanity
- [Raylib](https://www.raylib.com/) - one of the few C libs that didn't gaslight me (yet)
- `ld` (GNU linker)
- `make` - cause I like to pretend things are automated
- optional: a therapist (for debug trauma)
---

### Build & Run
Clone the repo:
```sh
$ git clone https://github.com/0xFA99/Pixie.git
$ cd Pixie
$ make
$ ./Pixie
```
> **Warning:** running this may cause your CPU to feel disrespected and overachive out of fear.
To clean up:
```sh
$ make clean
```

## Whats Cookin on `dev` branch???
- Using SIMD to move 2 floats at once, just so I can save **0.00001% CPU**, even if the framerate doesnt care.
- Planning to write my own memory allocator because libc was giving me trust issues.
- Considering porting the whole game to run in ring 0 for "maximum vibes"
- Thinkin of refactoring the whole codebase, cause everythinkg looks like it was written by 3 diff personalities.

## TO-DO
- [x] Draw Sprite
- [x] Add Camera2D
- [X] Add Flip Sprite
- [X] Add Sprite Animation
- [X] Add Movement
- [X] Add Parallax Background
- [ ] Add mental health recovery mechanic
- [ ] Add sound effects if I dont scream first
- [ ] Port to brainfuck or Morse code (maybe)

## Warning
This project was written in FASM, with zero safety nets, training wheels or regrets.
By running it, you agree that:
- if anything breaks dont contact me - contact a shaman.
- if your GPU starts chanting in Latin, thats a feature.
- understanding this code may unlock ancient knowledge or possibly just migrains

## Use freely, suffer responsibly.
