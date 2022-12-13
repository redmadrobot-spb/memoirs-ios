#ifdef __APPLE__

#import <mach/mach.h>

// without this access to mach_task_self_ produces a warning in concurrent code. And I have no idea how to fix this.
mach_port_t workaroundMachTaskSelf() {
    return mach_task_self_;
}

#endif
