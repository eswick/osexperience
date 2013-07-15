#import "OSIconContentView.h"




@implementation OSIconContentView
@synthesize wallpaperView = _wallpaperView;
@synthesize contentView = _contentView;


-(id)init{
	if(![super initWithFrame:[[UIScreen mainScreen] bounds]]){
		return nil;
	}


	self.wallpaperView = [[UIImageView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];

	NSData *wallpaperFile = [NSData dataWithContentsOfFile:@"/var/mobile/Library/SpringBoard/LockBackground.cpbitmap"];
    CGImageRef wallpaper = CGImageFromCPBitmap((unsigned char*)[wallpaperFile bytes], [wallpaperFile length]);


    UIImage *wallpaperImage = [UIImage imageWithCGImage:wallpaper];

    self.wallpaperView.image = [[wallpaperImage normalize] stackBlur:50.0f];


    self.wallpaperView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.wallpaperView.backgroundColor = [UIColor clearColor];
    self.wallpaperView.contentMode = UIViewContentModeScaleAspectFill;

    [self addSubview:self.wallpaperView];





    self.contentView = [[objc_getClass("SBIconController") sharedInstance] contentView];
	[self addSubview:self.contentView];



	return self;


}


-(void)prepareForDisplay{
	[self addSubview:self.contentView];
}





@end