
#import <os/log.h>
#define log(s, ...) os_log(OS_LOG_DEFAULT, "__jifcall__ " s, ##__VA_ARGS__)