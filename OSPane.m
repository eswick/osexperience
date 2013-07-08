#import "OSPane.h"




@implementation OSPane
@synthesize name = _name;
@synthesize thumbnail = _thumbnail;



-(id)initWithName:(NSString*)name thumbnail:(UIImage*)thumbnail{
	if(![super initWithFrame:[[UIScreen mainScreen] bounds]]){
		return nil;
	}

	self.name = name;
	self.thumbnail = thumbnail;

	return self;

}


@end