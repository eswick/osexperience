#import <UIKit/UIKit.h>
#import <objc/runtime.h>
#import "../include.h"




@interface OSAddDesktopButton : UIView {
	SBWallpaperView *_wallpaper;
	UIImageView *_plusIcon;
}

@property (nonatomic, retain) SBWallpaperView *wallpaper;
@property (nonatomic, retain) UIImageView *plusIcon;





@end