#import <mach/mach_init.h>

// This is needed solely for the purpose of disabling current Swift 5.5 warning about using global variables with concurrency.
mach_port_t getCurrentMachTaskSelf();
