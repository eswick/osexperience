#import "OSWallpaperView.h"
#import <UIKit/UIKit.h>
#import "OSSlider.h"
#import "OSDesktopPane.h"
#import "include.h"


@class OSSlider;

@interface OSViewController : UIViewController{
	OSSlider *_slider;
	SBDockIconListView *_dock;
}

@property (nonatomic, retain) OSSlider *slider;
@property (nonatomic, retain) SBDockIconListView *dock;

+(id)sharedInstance;

@end