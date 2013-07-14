#import <UIKit/UIKit.h>
#import "OSPane.h"
#import "OSWallpaperView.h"
#import "explorer/OSFileGridView.h"
#import "include.h"


@interface OSDesktopPane : OSPane{
	OSWallpaperView *_wallpaperView;
	OSFileGridView *_gridView;
	UIStatusBar *_statusBar;
}

@property (nonatomic, retain) OSWallpaperView *wallpaperView;
@property (nonatomic, retain) OSFileGridView *gridView;
@property (nonatomic, retain) UIStatusBar *statusBar;


@end