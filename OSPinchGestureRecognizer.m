#import "OSPinchGestureRecognizer.h"



@implementation OSPinchGestureRecognizer
@synthesize minimumNumberOfTouches = _minimumNumberOfTouches;
@synthesize centroid = _centroid;
@synthesize cumulativeStartingDistance = _cumulativeStartingDistance;
@synthesize type = _type;


- (id)initWithTarget:(id)target action:(SEL)action{
    if(![super initWithTarget:target action:action])
        return nil;

   // self.delaysTouchesBegan = true;

    return self;
}




- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];


    self.centroid = CGPointZero;
    for(UITouch *touch in [event allTouches]){
        self.centroid = CGPointAdd(self.centroid, [touch locationInView:self.view]);
    }
    self.centroid = CGPointMake(self.centroid.x / [[event allTouches] count], self.centroid.y / [[event allTouches] count]);




    self.cumulativeStartingDistance = 0;
    for(UITouch *touch in [event allTouches]){
        CGPoint nowPoint = [touch locationInView:self.view];
        float distance = CGPointDistance(nowPoint, self.centroid);
        self.cumulativeStartingDistance += distance;


    }



}
 
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesMoved:touches withEvent:event];


    if([[event allTouches] count] < self.minimumNumberOfTouches){
        self.state = UIGestureRecognizerStateFailed;
        return;
    }


    if (self.state == UIGestureRecognizerStateFailed){
        return; 
    }else if(self.state == UIGestureRecognizerStateRecognized){
        return;
    }

   
    float cumulativeDistance = 0.0f;

    for(UITouch *touch in [event allTouches]){

        CGPoint nowPoint = [touch locationInView:self.view];
        cumulativeDistance += CGPointDistance(nowPoint, self.centroid);

    }


    if(self.type == OSPinchGestureRecognizerTypeInwards){
        if(cumulativeDistance < (self.cumulativeStartingDistance - (20 * [[event allTouches] count]))){
            self.state = UIGestureRecognizerStateRecognized;
        }
    }else if(self.type == OSPinchGestureRecognizerTypeOutwards){
        if(cumulativeDistance > (self.cumulativeStartingDistance + (20 * [[event allTouches] count]))){
            self.state = UIGestureRecognizerStateRecognized;
        }
    }
}


- (BOOL)canBePreventedByGestureRecognizer:(UIGestureRecognizer *)preventingGestureRecognizer{
    return false;

}

 
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesEnded:touches withEvent:event];

    self.state = UIGestureRecognizerStateFailed;

    if([[event allTouches] count] < self.minimumNumberOfTouches){
        self.state = UIGestureRecognizerStateFailed;
    }



}

- (void)reset{
	[super reset];
}
 
- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesCancelled:touches withEvent:event];
    self.state = UIGestureRecognizerStateCancelled;
}



@end

