#import <UIKit/UIKit.h>
#import <objc/runtime.h>
#import "../include.h"

@class OSAddDesktopButton;

@protocol OSAddDesktopButtonDelegate

- (void)addDesktopButtonWasTapped:(OSAddDesktopButton*)button;

@end


@interface OSAddDesktopButton : UIView {
	UIImageView *_wallpaper;
	UIImageView *_plusIcon;
	UIView *_shadow;
	id<OSAddDesktopButtonDelegate> _delegate;
}

@property (nonatomic, retain) UIImageView *wallpaper;
@property (nonatomic, retain) UIImageView *plusIcon;
@property (nonatomic, assign) id<OSAddDesktopButtonDelegate> delegate;
@property (nonatomic, retain) UIView *shadow;





@end