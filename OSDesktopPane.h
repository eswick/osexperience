#import <objc/runtime.h>
#import <UIKit/UIKit.h>
#import "OSPane.h"
#import "OSWallpaperView.h"
#import "include.h"
#import "OSWindow.h"
#import "OSSlider.h"


@interface OSDesktopPane : OSPane <OSWindowDelegate> {
	SBFStaticWallpaperView *_wallpaperView;
	SBFakeStatusBarView *_statusBar;
	OSWindow *_activeWindow;
	NSMutableArray *_windows;
	UIView *_desktopViewContainer;
}

@property (nonatomic, retain) SBWallpaperController *wallpaperController;
@property (nonatomic, assign) SBFStaticWallpaperView *wallpaperView;
@property (nonatomic, retain) SBFakeStatusBarView *statusBar;
@property (nonatomic, assign) OSWindow *activeWindow;
@property (nonatomic, retain) NSMutableArray *windows;

@property (nonatomic, assign) BOOL showingRightSnapIndicator;
@property (nonatomic, assign) BOOL showingLeftSnapIndicator;
@property (nonatomic, retain) UIView *snapIndicator;

@end