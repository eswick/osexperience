#import <objc/runtime.h>
#import <UIKit/UIKit.h>
#import "OSPane.h"
#import "OSWallpaperView.h"
#import "explorer/OSFileGridViewController.h"
#import "include.h"
#import "OSWindow.h"
#import "OSSlider.h"


@interface OSDesktopPane : OSPane <OSWindowDelegate> {
	SBWallpaperView *_wallpaperView;
	OSFileGridViewController *_fileGridViewController;
	SBFakeStatusBarView *_statusBar;
	OSWindow *_activeWindow;
	NSMutableArray *_windows;
	UIView *_desktopViewContainer;
}

@property (nonatomic, retain) SBWallpaperView *wallpaperView;
@property (nonatomic, retain) OSFileGridViewController *fileGridViewController;
@property (nonatomic, retain) SBFakeStatusBarView *statusBar;
@property (nonatomic, assign) OSWindow *activeWindow;
@property (nonatomic, retain) NSMutableArray *windows;
@property (nonatomic, retain) UIView *desktopViewContainer;



@end