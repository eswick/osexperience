#import "OSPane.h"
#import "OSSlider.h"
#import "missioncontrol/OSThumbnailView.h"

@class OSSlider, OSDesktopPane;

@interface OSPaneModel : NSObject{
	NSMutableArray *_panes;
}

@property (atomic, retain) NSMutableArray *panes;


+ (id)sharedInstance;


- (unsigned int)count;
- (void)insertPane:(OSPane*)pane atIndex:(unsigned int)index;
- (void)addPaneToFront:(OSPane*)pane;
- (void)addPaneToBack:(OSPane*)pane;
- (void)removePane:(OSPane*)pane;
- (unsigned int)indexOfPane:(OSPane*)pane;
- (OSPane*)paneAtIndex:(unsigned int)index;
- (OSDesktopPane*)firstDesktopPane;
- (unsigned int)desktopPaneCount;


@end