#import "../OSPane.h"

#define missionControlMaximumScale 0.70

@interface OSMCWindowLayoutManager : NSObject{

}

+ (void)layoutWindows;
+ (CGPoint)convertPointToSlider:(CGPoint)point fromPane:(OSPane*)pane;
+ (CGPoint)convertPointFromSlider:(CGPoint)point toPane:(OSPane*)pane;

@end