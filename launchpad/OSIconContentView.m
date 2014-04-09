#import "OSIconContentView.h"


@implementation OSIconContentView
@synthesize wallpaperView = _wallpaperView;
@synthesize contentView = _contentView;
@synthesize statusBar = _statusBar;


-(id)init{
	if(![super initWithFrame:[[UIScreen mainScreen] bounds]]){
		return nil;
	}

	self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;

    self.contentView = [[objc_getClass("SBIconController") sharedInstance] contentView];
	[self addSubview:self.contentView];


	CGRect statusBarFrame = CGRectZero;
	statusBarFrame.size.width = self.bounds.size.width;
	statusBarFrame.size.height = 20;

	self.statusBar = [[objc_getClass("SBFakeStatusBarView") alloc] initWithFrame:statusBarFrame];
	self.statusBar.autoresizingMask = UIViewAutoresizingFlexibleWidth;
	[self.statusBar requestStyle:3];
	[self addSubview:self.statusBar];

	return self;
}


-(void)prepareForDisplay{
	self.wallpaperView = [[[objc_getClass("SBWallpaperController") sharedInstance] _blurViewsForVariant:0] anyObject];
	[self addSubview:self.wallpaperView];
	[self bringSubviewToFront:self.wallpaperView];

	self.wallpaperView.alpha = 1;

	[self addSubview:self.contentView];
	[self bringSubviewToFront:self.statusBar];
}

-(void)dealloc{
	[self.statusBar release];
	[self.wallpaperView release];
	[super dealloc];
}

@end