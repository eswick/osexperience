#import "OSWallpaperView.h"
#import <UIKit/UIKit.h>
#import "OSSlider.h"
#import "OSDesktopPane.h"
#import "include.h"
#import "launchpad/OSIconContentView.h"


@class OSSlider, OSIconContentView;

@interface OSViewController : UIViewController{
	OSSlider *_slider;
	SBDockIconListView *_dock;
	OSIconContentView *_iconContentView;
	BOOL _launchpadActive;
	BOOL _launchpadIsAnimating;
}

@property (nonatomic, retain) OSSlider *slider;
@property (nonatomic, retain) SBDockIconListView *dock;
@property (nonatomic, retain) OSIconContentView *iconContentView;
@property (nonatomic, readwrite) BOOL launchpadActive;
@property (nonatomic, readwrite) BOOL launchpadIsAnimating;


+ (id)sharedInstance;
- (void)setLaunchpadActive:(BOOL)activated animated:(BOOL)animated;
- (void)deactivateWithIconView:(SBIconView*)icon;
- (void)animateIconLaunch:(SBIconView*)iconView;
- (void)menuButtonPressed;

@end