#import <UIKit/UIKit.h>
#import "OSPane.h"
#import "OSWallpaperView.h"
#import "explorer/OSFileGridView.h"


@interface OSDesktopPane : OSPane{
	OSWallpaperView *_wallpaperView;
	OSFileGridView *_gridView;
}

@property (nonatomic, retain) OSWallpaperView *wallpaperView;
@property (nonatomic, retain) OSFileGridView *gridView;


@end