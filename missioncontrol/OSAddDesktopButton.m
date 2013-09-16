#import "OSAddDesktopButton.h"



@implementation OSAddDesktopButton
@synthesize wallpaper = _wallpaper;

- (id)init{

	CGRect frame = CGRectZero;
	frame = [[UIScreen mainScreen] bounds];

 	frame.origin.x = frame.size.width;

	if(!UIInterfaceOrientationIsPortrait([UIApp statusBarOrientation])){
		float width = frame.size.width;
		frame.size.width = frame.size.height;
		frame.size.height = width;
		frame.origin.x = frame.size.height;
	}

	frame = CGRectApplyAffineTransform(frame, CGAffineTransformScale(CGAffineTransformIdentity, 0.15, 0.15));


	if(![super initWithFrame:frame])
		return nil;

	self.backgroundColor = [UIColor greenColor];
	self.clipsToBounds = true;


	self.wallpaper = [[objc_getClass("SBWallpaperView") alloc] initWithOrientation:[[UIApplication sharedApplication] statusBarOrientation] variant:1];
	self.wallpaper.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	
	self.wallpaper.frame = self.frame;
	frame = self.wallpaper.frame;
	frame.origin = CGPointZero;
	[self.wallpaper setFrame:frame];
	
	self.wallpaper.contentMode = UIViewContentModeScaleAspectFill;
	[self.wallpaper setGradientAlpha:0.0];
	[self addSubview:self.wallpaper];


	return self;
}

- (void)dealloc{
	[self.wallpaper release];
	[super dealloc];
}

@end