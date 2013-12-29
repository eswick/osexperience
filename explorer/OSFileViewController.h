#import <libfsmonitor/libfsmonitor.h>

@interface OSFileViewController : NSObject <FSMonitorDelegate>

@property (retain) UIView *view;
@property (retain, nonatomic) NSURL *path;
@property (retain) FSMonitor *monitor;
@property (nonatomic) BOOL loaded;
@property (nonatomic) NSDirectoryEnumerationOptions enumerationOptions;

- (void)loadView;
- (void)pathChanged;
- (void)layoutView;
- (void)monitor:(FSMonitor*)monitor recievedEventInfo:(NSDictionary*)info;

@end