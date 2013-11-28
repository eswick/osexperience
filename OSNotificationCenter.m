#import "OSNotificationCenter.h"


@implementation OSNotificationCenter

+ (id)sharedInstance
{
    static OSNotificationCenter *_center;

    if (_center == nil)
    {
        _center = [[self alloc] init];
    }

    return _center;
}

- (id)init{
	if(![super init])
		return nil;



	return self;
}
@end