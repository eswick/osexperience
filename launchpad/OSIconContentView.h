#import <UIKit/UIKit.h>
#import "../include.h"
#import "../OSViewController.h"
#import "../OSWallpaperView.h"




@interface OSIconContentView : UIView{
	UIView *_wallpaperView;
	UIView *_contentView;
	SBFakeStatusBarView *_statusBar;
}

@property (nonatomic, retain) UIView *wallpaperView;
@property (nonatomic, retain) UIView *contentView;
@property (nonatomic, retain) SBFakeStatusBarView *statusBar;

-(void)prepareForDisplay;

@end