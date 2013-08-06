#import <UIKit/UIKit.h>
#import "../include.h"
#import "../OSViewController.h"
#import "../libcpbitmap.h"
#import "UIImage+StackBlur.h"
#import "../OSWallpaperView.h"




@interface OSIconContentView : UIView{
	SBWallpaperView *_wallpaperView;
	UIView *_contentView;
}


@property (nonatomic, retain) SBWallpaperView *wallpaperView;
@property (nonatomic, retain) UIView *contentView;


-(void)prepareForDisplay;



@end