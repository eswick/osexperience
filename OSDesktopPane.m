#import "OSDesktopPane.h"




@implementation OSDesktopPane
@synthesize wallpaperView = _wallpaperView;
@synthesize gridView = _gridView;
@synthesize statusBar = _statusBar;



-(id)init{
	if(![super initWithName:@"Desktop" thumbnail:nil]){
		return nil;
	}

	self.backgroundColor = [UIColor clearColor];
	self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;

	self.wallpaperView = [[objc_getClass("SBWallpaperView") alloc] initWithOrientation:[[UIApplication sharedApplication] statusBarOrientation] variant:1];
	[self.wallpaperView setGradientAlpha:0.0];
	[self addSubview:self.wallpaperView];

	self.gridView = [[OSFileGridView alloc] initWithDirectory:@"/var/mobile/Desktop" frame:[[UIScreen mainScreen] applicationFrame]];
	[self addSubview:self.gridView];


	CGRect statusBarFrame = CGRectZero;
	statusBarFrame.size.width = self.bounds.size.width;
	statusBarFrame.size.height = 20;

	self.statusBar = [[objc_getClass("SBFakeStatusBarView") alloc] initWithFrame:statusBarFrame];
	self.statusBar.autoresizingMask = UIViewAutoresizingFlexibleWidth;
	[self.statusBar requestStyle:1];
	[self addSubview:self.statusBar];
	
	return self;

}

-(BOOL)showsDock{
	return true;
}


-(void)dealloc{
	[self.statusBar release];
	[self.wallpaperView release];
	[self.gridView release];
	[self.statusBar release];
	
	[super dealloc];
}



@end