#import "../OSPane.h"

#define missionControlMaximumScale 0.70

@interface OSMCWindowLayoutManager : NSObject{

}

+ (void)layoutWindows;
+ (CGPoint)convertPointToSlider:(CGPoint)point fromPane:(OSPane*)pane;
+ (CGPoint)convertPointFromSlider:(CGPoint)point toPane:(OSPane*)pane;
+ (CGRect)convertRectFromSlider:(CGRect)rect toPane:(OSPane*)pane;
+ (CGRect)convertRectToSlider:(CGRect)rect fromPane:(OSPane*)pane;

@end