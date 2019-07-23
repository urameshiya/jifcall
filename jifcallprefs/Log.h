
#import <os/log.h>
#define log(s, ...) os_log(OS_LOG_DEFAULT, "__jifcallprefs__ " s, ##__VA_ARGS__)