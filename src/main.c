#include <efi.h>
#include <efilib.h>
#include "bootstrap.h"

// Global image handle for use by other modules
EFI_HANDLE gImageHandle;

// EFI entry point
EFI_STATUS
EFIAPI
efi_main(EFI_HANDLE ImageHandle, EFI_SYSTEM_TABLE *SystemTable)
{
    EFI_STATUS Status;
    
    // Store global image handle
    gImageHandle = ImageHandle;
    
    // Initialize the EFI library
    InitializeLib(ImageHandle, SystemTable);
    
    // Clear screen and print welcome message
    uefi_call_wrapper(ST->ConOut->ClearScreen, 1, ST->ConOut);
    Print(L"Arch Linux EFI Bootstrap v0.1.0\n");
    Print(L"================================\n\n");
    
    // Initialize network
    Print(L"Initializing network...\n");
    Status = init_network();
    if (EFI_ERROR(Status)) {
        Print(L"Failed to initialize network: %r\n", Status);
        goto cleanup;
    }
    Print(L"Network initialized successfully.\n");
    
    // Download Arch Linux installer
    Print(L"Downloading Arch Linux installer...\n");
    Status = download_arch_installer();
    if (EFI_ERROR(Status)) {
        Print(L"Failed to download installer: %r\n", Status);
        goto cleanup;
    }
    Print(L"Installer downloaded successfully.\n");
    
    // Launch installer
    Print(L"Launching installer...\n");
    Status = launch_installer();
    if (EFI_ERROR(Status)) {
        Print(L"Failed to launch installer: %r\n", Status);
        goto cleanup;
    }
    
cleanup:
    cleanup_network();
    
    // Wait for user input before exiting
    Print(L"\nPress any key to exit...\n");
    WaitForSingleEvent(ST->ConIn->WaitForKey, 0);
    
    return Status;
}