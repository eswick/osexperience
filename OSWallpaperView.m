#import "OSWallpaperView.h"




@implementation OSWallpaperView


-(id)init{
	if(![super initWithFrame:[[UIScreen mainScreen] bounds]]){
		return nil;
	}

	NSData *wallpaperFile = [NSData dataWithContentsOfFile:@"/var/mobile/Library/SpringBoard/LockBackground.cpbitmap"];
    CGImageRef wallpaper = CGImageFromCPBitmap((unsigned char*)[wallpaperFile bytes], [wallpaperFile length]);
    [self setImage:[UIImage imageWithCGImage:wallpaper]];


    self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.backgroundColor = [UIColor blackColor];
    self.contentMode = UIViewContentModeScaleAspectFill;

    return self;
}




@end