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
	self.clipsToBounds = true;

	self.wallpaperView = [[OSWallpaperView alloc] init];
	[self addSubview:self.wallpaperView];

	self.gridView = [[OSFileGridView alloc] initWithDirectory:@"/var/mobile/Desktop" frame:[[UIScreen mainScreen] applicationFrame]];
	[self addSubview:self.gridView];


	self.statusBar = [[objc_getClass("SBFakeStatusBarView") alloc] initWithFrame:CGRectMake(0, 0, 20, self.frame.size.width)];
	[self addSubview:self.statusBar];

	
	return self;

}


-(BOOL)showsDock{
	return true;
}






@end