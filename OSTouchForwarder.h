#import <UIKit/UIKit.h>
#import <GraphicsServices/GraphicsServices.h>
#import "include.h"




@interface OSTouchForwarder : UIGestureRecognizer{
	SBApplication *_application;
}

@property (nonatomic, retain) SBApplication *application;


- (id)initWithApplication:(SBApplication*)application;
- (void)sendEvent:(UIEvent*)event;


@end