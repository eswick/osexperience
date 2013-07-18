#import "OSPane.h"




@implementation OSPane
@synthesize name = _name;
@synthesize thumbnail = _thumbnail;



-(id)initWithName:(NSString*)name thumbnail:(UIImage*)thumbnail{
	CGRect frame = [[UIScreen mainScreen] bounds];
	if(![self isPortrait]){
		float widthPlaceholder = frame.size.width;
		frame.size.width = frame.size.height;
		frame.size.height = widthPlaceholder;
	}


	if(![super initWithFrame:frame]){
		return nil;
	}

	self.name = name;
	self.thumbnail = thumbnail;

	return self;

}


-(BOOL)showsDock{
	return false;
}

-(BOOL)isPortrait{
	if([[UIApplication sharedApplication] statusBarOrientation] == UIInterfaceOrientationPortrait || [[UIApplication sharedApplication] statusBarOrientation] == UIInterfaceOrientationPortraitUpsideDown){
        return true;
    }
    return false;
}


@end