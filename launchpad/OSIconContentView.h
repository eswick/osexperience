#import <UIKit/UIKit.h>
#import "../include.h"
#import "../OSViewController.h"
#import "../libcpbitmap.h"
#import "UIImage+StackBlur.h"
#import "../OSWallpaperView.h"




@interface OSIconContentView : UIView{
	UIImageView *_wallpaperView;
	UIView *_contentView;
}


@property (nonatomic, retain) UIImageView *wallpaperView;
@property (nonatomic, retain) UIView *contentView;


-(void)prepareForDisplay;



@end