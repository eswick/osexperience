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
	

	self.wallpaperView = [[OSWallpaperView alloc] init];
	[self addSubview:self.wallpaperView];

	self.gridView = [[OSFileGridView alloc] initWithDirectory:@"/var/mobile/Desktop" frame:[[UIScreen mainScreen] applicationFrame]];
	[self addSubview:self.gridView];

	self.wallpaperView.clipsToBounds = true;
	//self.gridView.clipsToBounds = true;

	
	return self;

}


-(BOOL)showsDock{
	return true;
}


-(void)dealloc{
	[self.wallpaperView release];
	[self.gridView release];
	[self.statusBar release];
	
	[super dealloc];
}



@end