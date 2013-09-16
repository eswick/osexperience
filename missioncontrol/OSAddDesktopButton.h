#import <UIKit/UIKit.h>
#import <objc/runtime.h>
#import "../include.h"

@class OSAddDesktopButton;

@protocol OSAddDesktopButtonDelegate

- (void)addDesktopButtonWasTapped:(OSAddDesktopButton*)button;

@end


@interface OSAddDesktopButton : UIView {
	SBWallpaperView *_wallpaper;
	UIImageView *_plusIcon;
	id<OSAddDesktopButtonDelegate> _delegate;
}

@property (nonatomic, retain) SBWallpaperView *wallpaper;
@property (nonatomic, retain) UIImageView *plusIcon;
@property (nonatomic, assign) id<OSAddDesktopButtonDelegate> delegate;





@end