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


	self.wallpaperView = [[objc_getClass("SBWallpaperView") alloc] initWithOrientation:[[UIApplication sharedApplication] statusBarOrientation] variant:1];
	self.wallpaperView.image = [self.wallpaperView.image stackBlur:50.0];
	[self addSubview:self.wallpaperView];


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
	[self bringSubviewToFront:self.wallpaperView];
	[self addSubview:self.contentView];
	[self bringSubviewToFront:self.statusBar];
}

-(void)dealloc{
	[self.statusBar release];
	[self.wallpaperView release];
	[super dealloc];
}

@end