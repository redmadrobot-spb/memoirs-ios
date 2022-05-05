#import <mach/mach_init.h>

mach_port_t getCurrentMachTaskSelf() {
    return mach_task_self_;
}
