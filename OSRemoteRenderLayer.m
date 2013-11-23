#import "OSRemoteRenderLayer.h"
#import <CoreGraphics/CoreGraphics.h>
#import <QuartzCore/QuartzCore.h>


@implementation OSRemoteRenderLayer
@synthesize manager = _manager;

- (id)init{
	return [super init];
}

- (void)renderInContext:(CGContextRef)ctx{

	int appViewDegrees;

	switch([UIApp statusBarOrientation]){
		case UIInterfaceOrientationPortrait:
			appViewDegrees = 0;
			break;
		case UIInterfaceOrientationPortraitUpsideDown:
			appViewDegrees = 180;
			break;
		case UIInterfaceOrientationLandscapeLeft:
			appViewDegrees = 90;
			break;
		case UIInterfaceOrientationLandscapeRight:
			appViewDegrees = 270;
			break;
	}

	CGImageRef image = [self.manager createIOSurfaceForFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];

	CGContextSetBlendMode(ctx, kCGBlendModeCopy);

	CGAffineTransform verticalFlip = CGAffineTransformMake(1, 0, 0, -1, 0, self.frame.size.height);
    CGContextConcatCTM(ctx, verticalFlip);

    CGContextDrawImage(ctx, CGRectMake(0.0, 0.0, self.frame.size.width, self.frame.size.height), image);
}

@end