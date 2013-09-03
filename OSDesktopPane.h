#import <objc/runtime.h>
#import <UIKit/UIKit.h>
#import "OSPane.h"
#import "OSWallpaperView.h"
#import "explorer/OSFileGridView.h"
#import "include.h"
#import "OSWindow.h"


@interface OSDesktopPane : OSPane <OSWindowDelegate> {
	SBWallpaperView *_wallpaperView;
	OSFileGridView *_gridView;
	SBFakeStatusBarView *_statusBar;
}

@property (nonatomic, retain) SBWallpaperView *wallpaperView;
@property (nonatomic, retain) OSFileGridView *gridView;
@property (nonatomic, retain) SBFakeStatusBarView *statusBar;



@end