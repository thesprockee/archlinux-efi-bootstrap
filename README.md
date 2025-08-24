# Arch Linux EFI Bootstrap

An EFI-based Arch Linux installer that downloads and boots the Arch Linux installer directly from a UEFI environment.

## Overview

This project creates a standalone UEFI application (`.efi` file) that can:
- Boot directly from UEFI firmware
- Initialize network connectivity
- Download the latest Arch Linux installer ISO
- Load and boot the installer directly into memory

## Features

- **Standalone UEFI Application**: No need for a separate bootloader
- **Network Boot**: Downloads installer over the network
- **Memory-based**: Runs entirely from RAM without requiring storage
- **Minimal Dependencies**: Self-contained EFI binary

## Building

### Prerequisites

You need the following packages installed:

**Ubuntu/Debian:**
```bash
sudo apt install gcc gnu-efi
```

**Arch Linux:**
```bash
sudo pacman -S gcc gnu-efi
```

**Fedora:**
```bash
sudo dnf install gcc gnu-efi-devel
```

### Compilation

1. Clone the repository:
```bash
git clone https://github.com/thesprockee/archlinux-efi-bootstrap.git
cd archlinux-efi-bootstrap
```

2. Build the EFI application:
```bash
make
```

3. The resulting `archlinux-bootstrap.efi` file will be in the `dist/` directory.

### Installation

To install the EFI application to your EFI System Partition:

```bash
make install
```

This will copy the EFI file to `/boot/efi/EFI/archlinux-bootstrap/`.

You'll then need to add a boot entry using your EFI boot manager (like `efibootmgr`):

```bash
sudo efibootmgr --create --disk /dev/sdX --part Y --label "Arch Linux Bootstrap" --loader \\EFI\\archlinux-bootstrap\\archlinux-bootstrap.efi
```

Replace `/dev/sdX` with your disk and `Y` with your EFI partition number.

## Project Structure

```
archlinux-efi-bootstrap/
├── src/
│   ├── main.c          # Main EFI application entry point
│   └── network.c       # Network and download functionality
├── include/
│   └── bootstrap.h     # Header definitions
├── Makefile           # Build system
└── README.md          # This file
```

## Development Status

This is currently a skeleton implementation with the following components:

- ✅ Basic EFI application structure
- ✅ Network interface detection and initialization
- ✅ Build system with GNU-EFI
- 🚧 HTTP client implementation (stub)
- 🚧 ISO download functionality (stub)
- 🚧 Installer launch mechanism (stub)

## Current Limitations

- HTTP client is not yet implemented (placeholder)
- ISO download is simulated
- Installer launch is not implemented
- No error recovery mechanisms
- Limited network protocol support

## Contributing

This project is in early development. Contributions are welcome for:

- HTTP/HTTPS client implementation for UEFI
- ISO handling and RAM disk creation
- Kernel loading and boot protocol implementation
- Error handling and recovery
- Testing on various hardware platforms

## License

[Add license information here]

## Acknowledgments

- Built using [GNU-EFI](https://sourceforge.net/projects/gnu-efi/) library
- Inspired by various UEFI development resources and the Arch Linux community
