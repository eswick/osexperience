#import "OSDesktopPane.h"




@implementation OSDesktopPane
@synthesize wallpaperView = _wallpaperView;
@synthesize gridView = _gridView;



-(id)init{
	if(![super initWithName:@"Desktop" thumbnail:nil]){
		return nil;
	}

	self.backgroundColor = [UIColor clearColor];
	self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	self.clipsToBounds = true;

	self.wallpaperView = [[OSWallpaperView alloc] init];
	[self addSubview:self.wallpaperView];

	self.gridView = [[OSFileGridView alloc] initWithDirectory:@"/var/mobile/Desktop" frame:[[UIScreen mainScreen] bounds]];
	[self addSubview:self.gridView];



	return self;

}


-(BOOL)showsDock{
	return true;
}






@end