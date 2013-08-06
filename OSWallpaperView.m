#import "OSWallpaperView.h"




@implementation OSWallpaperView


+(UIImage*)wallpaperImage{
    static UIImage *image;

    if(image == nil){

        //NSData *wallpaperFile = [NSData dataWithContentsOfFile:@"/var/mobile/Library/SpringBoard/LockBackground.cpbitmap"];
        //CGImageRef wallpaper = CGImageFromCPBitmap((unsigned char*)[wallpaperFile bytes], [wallpaperFile length]);
        //image = [UIImage imageWithCGImage:wallpaper];
        //CFRelease(wallpaper);
    }

    return image;
}


-(id)init{
	if(![super initWithFrame:[[UIScreen mainScreen] bounds]]){
		return nil;
	}


    [self setImage:[OSWallpaperView wallpaperImage]];

    self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.backgroundColor = [UIColor blackColor];
    self.contentMode = UIViewContentModeScaleAspectFill;

    return self;
}




@end

