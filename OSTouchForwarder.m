#import "OSTouchForwarder.h"








@implementation OSTouchForwarder
@synthesize application = _application;


-(id)initWithApplication:(SBApplication*)application{
	if(![super initWithTarget:self action:@selector(forwardTouches:)]){
		return nil;
	}

	self.application = application;

	return self;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
	[self sendEvent:event];
}


- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
	[self sendEvent:event];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event{
	[self sendEvent:event];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
	[self sendEvent:event];
}

- (BOOL)canBePreventedByGestureRecognizer:(UIGestureRecognizer *)preventingGestureRecognizer{
	return true;
}

- (BOOL)canPreventGestureRecognizer:(UIGestureRecognizer *)preventedGestureRecognizer{
	return false;
}


-(void)sendEvent:(UIEvent *)event{
	GSEventRef gsEvent = [event _gsEvent];
	const GSEventRecord* record = _GSEventGetGSEventRecord(gsEvent);

	//NSLog(@"Location: %@, Location in window: %@", NSStringFromCGPoint(record->location), NSStringFromCGPoint(record->windowLocation));

	GSSendEvent(record, (mach_port_t)[self.application eventPort]);
}


-(void)forwardTouches:(UIPanGestureRecognizer *)gesture{

}

@end