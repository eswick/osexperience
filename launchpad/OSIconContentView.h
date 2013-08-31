#import <UIKit/UIKit.h>
#import "../include.h"
#import "../OSViewController.h"
#import "../libcpbitmap.h"
#import "UIImage+StackBlur.h"
#import "../OSWallpaperView.h"




@interface OSIconContentView : UIView{
	SBWallpaperView *_wallpaperView;
	UIView *_contentView;
	SBFakeStatusBarView *_statusBar;
}


@property (nonatomic, retain) SBWallpaperView *wallpaperView;
@property (nonatomic, retain) UIView *contentView;
@property (nonatomic, retain) SBFakeStatusBarView *statusBar;


-(void)prepareForDisplay;



@end