#import "OSWallpaperView.h"
#import <UIKit/UIKit.h>
#import "OSSlider.h"
#import "OSDesktopPane.h"
#import "include.h"
#import "launchpad/OSIconContentView.h"
#import "missioncontrol/OSThumbnailView.h"
#import "missioncontrol/OSMCWindowLayoutManager.h"
#import "OSSwitcherBackgroundView.h"

#define windowConstraintsTopMargin 7
#define windowConstraintsBottomMargin 7

@class OSSlider, OSIconContentView;

@interface OSViewController : UIViewController{
	OSSlider *_slider;
	SBDockView *_dock;
	OSIconContentView *_iconContentView;
	BOOL _launchpadActive;
	BOOL _launchpadAnimating;
	BOOL _missionControlActive;
	BOOL _missionControlAnimating;
	OSSwitcherBackgroundView *_switcherBackgroundView;
	UIView *_tempView;
}

@property (nonatomic, assign) OSSlider *slider;
@property (nonatomic, assign) SBDockView *dock;
@property (nonatomic, retain) OSIconContentView *iconContentView;
@property (nonatomic, readwrite, getter=launchpadIsActive) BOOL launchpadActive;
@property (nonatomic, readwrite, getter=launchpadIsAnimating) BOOL launchpadAnimating;
@property (nonatomic, readwrite, getter=missionControlIsActive) BOOL missionControlActive;
@property (nonatomic, readwrite, getter=missionControlIsAnimating) BOOL missionControlAnimating;
@property (nonatomic, retain) OSSwitcherBackgroundView *switcherBackgroundView;
@property (nonatomic, retain) UIView *tempView;
@property (nonatomic, readwrite) float _launchpadVisiblePercentage;



+ (id)sharedInstance;
- (void)setLaunchpadActive:(BOOL)activated animated:(BOOL)animated;
- (void)deactivateLaunchpadWithIconView:(SBIconView*)icon;
- (void)animateIconLaunch:(SBIconView*)iconView;
- (void)menuButtonPressed;
- (void)setDockPercentage:(float)percentage;
- (void)setMissionControlActive:(BOOL)active animated:(BOOL)animated;
- (CGRect)missionControlWindowConstraints;
- (void)setLaunchpadVisiblePercentage:(float)percentage;


@end