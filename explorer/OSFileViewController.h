#import <libfsmonitor/libfsmonitor.h>

@interface OSFileViewController : UIViewController

@property (retain) NSURL *path;

- (id)initWithPath:(NSURL*)path;

@end