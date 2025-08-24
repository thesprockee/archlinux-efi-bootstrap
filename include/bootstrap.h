#ifndef _BOOTSTRAP_H_
#define _BOOTSTRAP_H_

#include <efi.h>
#include <efilib.h>

// Network configuration
#define ARCH_ISO_URL L"http://mirror.rackspace.com/archlinux/iso/latest/archlinux-x86_64.iso"
#define DOWNLOAD_BUFFER_SIZE (64 * 1024 * 1024)  // 64MB buffer

// Function prototypes
EFI_STATUS init_network(void);
EFI_STATUS download_arch_installer(void);
EFI_STATUS launch_installer(void);
void cleanup_network(void);

// HTTP client functions
EFI_STATUS http_get(CHAR16 *url, VOID **buffer, UINTN *size);

// Memory management
EFI_STATUS allocate_download_buffer(VOID **buffer, UINTN size);
void free_download_buffer(VOID *buffer);

#endif /* _BOOTSTRAP_H_ */