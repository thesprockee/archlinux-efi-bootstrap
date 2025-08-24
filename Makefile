# Arch Linux EFI Bootstrap Makefile
# Builds a UEFI application that can download and boot Arch Linux installer

# Project settings
PROJECT_NAME = archlinux-bootstrap
VERSION = 0.1.0

# Directories
SRCDIR = src
INCDIR = include
BUILDDIR = build
DISTDIR = dist

# Compiler and tools
ARCH = x86_64
CC = gcc
LD = ld
OBJCOPY = objcopy

# GNU-EFI paths (adjust these based on your system)
GNUEFI_LIB_PATH = /usr/lib
GNUEFI_INC_PATH = /usr/include/efi

# Compiler flags
CFLAGS = -ffreestanding -fno-stack-protector -fno-stack-check \
         -fshort-wchar -mno-red-zone -maccumulate-outgoing-args \
         -Wall -Wextra -Werror -DEFI_FUNCTION_WRAPPER \
         -I$(INCDIR) -I$(GNUEFI_INC_PATH) -I$(GNUEFI_INC_PATH)/$(ARCH) \
         -I$(GNUEFI_INC_PATH)/protocol

# Linker flags
LDFLAGS = -nostdlib -T $(GNUEFI_LIB_PATH)/elf_$(ARCH)_efi.lds \
          -shared -Bsymbolic -L$(GNUEFI_LIB_PATH) $(GNUEFI_LIB_PATH)/crt0-efi-$(ARCH).o

LIBS = -lefi -lgnuefi

# Source files
SOURCES = $(wildcard $(SRCDIR)/*.c)
OBJECTS = $(SOURCES:$(SRCDIR)/%.c=$(BUILDDIR)/%.o)

# Targets
TARGET_EFI = $(DISTDIR)/$(PROJECT_NAME).efi
TARGET_SO = $(BUILDDIR)/$(PROJECT_NAME).so

.PHONY: all clean install check-deps

all: check-deps $(TARGET_EFI)

$(TARGET_EFI): $(TARGET_SO) | $(DISTDIR)
	@echo "Creating EFI binary: $@"
	$(OBJCOPY) -j .text -j .sdata -j .data -j .dynamic -j .dynsym -j .rel \
	           -j .rela -j .reloc --target=efi-app-$(ARCH) $< $@

$(TARGET_SO): $(OBJECTS) | $(BUILDDIR)
	@echo "Linking: $@"
	$(LD) $(LDFLAGS) $(OBJECTS) -o $@ $(LIBS)

$(BUILDDIR)/%.o: $(SRCDIR)/%.c | $(BUILDDIR)
	@echo "Compiling: $<"
	$(CC) $(CFLAGS) -c $< -o $@

$(BUILDDIR):
	@mkdir -p $(BUILDDIR)

$(DISTDIR):
	@mkdir -p $(DISTDIR)

clean:
	@echo "Cleaning build artifacts..."
	@rm -rf $(BUILDDIR) $(DISTDIR)

install: $(TARGET_EFI)
	@echo "Installing to /boot/efi/EFI/archlinux-bootstrap/"
	@sudo mkdir -p /boot/efi/EFI/archlinux-bootstrap
	@sudo cp $(TARGET_EFI) /boot/efi/EFI/archlinux-bootstrap/
	@echo "Installation complete. Add entry to your EFI boot manager."

check-deps:
	@echo "Checking dependencies..."
	@which $(CC) > /dev/null || (echo "Error: $(CC) not found. Install gcc" && exit 1)
	@test -f $(GNUEFI_LIB_PATH)/crt0-efi-$(ARCH).o || (echo "Error: GNU-EFI not found at $(GNUEFI_LIB_PATH)" && exit 1)
	@test -d $(GNUEFI_INC_PATH) || (echo "Error: GNU-EFI headers not found at $(GNUEFI_INC_PATH)" && exit 1)
	@echo "Dependencies OK"

# Help target
help:
	@echo "Arch Linux EFI Bootstrap Build System"
	@echo "======================================"
	@echo ""
	@echo "Targets:"
	@echo "  all       - Build the EFI application (default)"
	@echo "  clean     - Remove build artifacts"
	@echo "  install   - Install to /boot/efi/EFI/archlinux-bootstrap/"
	@echo "  check-deps- Check if required dependencies are available"
	@echo "  help      - Show this help message"
	@echo ""
	@echo "Dependencies:"
	@echo "  - gcc (C compiler)"
	@echo "  - gnu-efi (EFI development library)"
	@echo ""
	@echo "On Ubuntu/Debian: sudo apt install gcc gnu-efi"
	@echo "On Arch Linux: sudo pacman -S gcc gnu-efi"