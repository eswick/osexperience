#import "OSSwipeGestureRecognizer.h"
#import "OSViewController.h"

@implementation OSSwipeGestureRecognizer

- (BOOL)canBePreventedByGestureRecognizer:(UIGestureRecognizer *)preventingGestureRecognizer{
	return false;
}

- (BOOL)canPreventGestureRecognizer:(UIGestureRecognizer *)preventedGestureRecognizer{
	return true;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
	if(self.direction == UISwipeGestureRecognizerDirectionUp && [[OSViewController sharedInstance] missionControlIsActive]){
		self.state = UIGestureRecognizerStateFailed;
		return;
	}
	[super touchesBegan:touches withEvent:event];
}
@end