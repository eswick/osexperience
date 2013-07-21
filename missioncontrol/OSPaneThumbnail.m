#import "OSPaneThumbnail.h"




@implementation OSPaneThumbnail
@synthesize pane = _pane;
@synthesize label = _label;
@synthesize icon = _icon;


- (id)initWithPane:(OSPane*)pane{
	CGRect frame = [[UIScreen mainScreen] bounds];

	if(![[OSThumbnailView sharedInstance] isPortrait]){
		float width = frame.size.width;
		frame.size.width = frame.size.height;
		frame.size.height = width;
	}

	frame = CGRectApplyAffineTransform(frame, CGAffineTransformScale(CGAffineTransformIdentity, 0.15, 0.15));

	if(![super initWithFrame:frame])
		return nil;

	self.backgroundColor = [UIColor whiteColor];

	self.layer.masksToBounds = NO;
	self.layer.shadowOffset = CGSizeMake(0, 0);
	self.layer.shadowRadius = 5;
	self.layer.shadowOpacity = 0.5;
	self.layer.shadowPath = [UIBezierPath bezierPathWithRect:self.bounds].CGPath;


	self.pane = pane;
	[self updateImage];


	if([self.pane isKindOfClass:[OSAppPane class]]){
		self.icon = [[UIImageView alloc] init];
		self.icon.image = [[[objc_getClass("SBApplicationIcon") alloc] initWithApplication:[(OSAppPane*)self.pane application]] generateIconImage:2];
		float size = [[OSThumbnailView sharedInstance] isPortrait] ? self.frame.size.width : self.frame.size.height;
		self.icon.frame = CGRectMake(0, 0, size / 2, size / 2);
		self.icon.center = CGPointMake(self.center.x, self.frame.size.height - 18);
		self.icon.layer.shadowOffset = CGSizeMake(0, 0);
		self.icon.layer.shadowRadius = 10;
		self.icon.layer.shadowOpacity = 0.5;
		self.icon.layer.shouldRasterize = true;
		[self addSubview:self.icon];
	}




	self.label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, 20)];
	self.label.center = self.center;
	self.label.backgroundColor = [UIColor clearColor];
	self.label.text = self.pane.name;
	self.label.textColor = [UIColor whiteColor];
	self.label.textAlignment = NSTextAlignmentCenter;
	self.label.shadowColor = [UIColor blackColor];
	//self.label.layer.shouldRasterize = true;
	self.label.font = [UIFont boldSystemFontOfSize:15];
	self.label.adjustsFontSizeToFitWidth = false;

	[self addSubview:self.label];

	return self;

}

- (void)dealloc{
	[self.label release];
	if(self.icon)
		[self.icon release];
	[super dealloc];
}

- (void)updateLabel{


	CGPoint labelOrigin = [[OSThumbnailView sharedInstance] convertPoint:CGPointMake(0, [[OSThumbnailView sharedInstance] frame].size.height) toView:self];

	CGPoint labelCenter;
	labelCenter.x = self.frame.size.width / 2;

	if([[OSThumbnailView sharedInstance] isPortrait]){
		labelCenter.y = ((labelOrigin.y - self.frame.size.height) / 2) + self.frame.size.height;
	}else{
		labelCenter.y = (labelOrigin.y - self.frame.size.width) + self.frame.size.height - 12;
	}

	self.label.center = labelCenter;
}

- (void)updateSize{
	CGRect frame = [[UIScreen mainScreen] bounds];

	if(![[OSThumbnailView sharedInstance] isPortrait]){
		float width = frame.size.width;
		frame.size.width = frame.size.height;
		frame.size.height = width;
	}


	self.frame = CGRectApplyAffineTransform(frame, CGAffineTransformScale(CGAffineTransformIdentity, 0.15, 0.15));

	self.icon.center = CGPointMake(self.center.x, self.frame.size.height - 18);
}


- (void)updateImage{
	dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{

		if([self.pane isKindOfClass:[OSAppPane class]]){
			UIView *zoomView = [[objc_getClass("SBUIController") sharedInstance] systemGestureSnapshotForApp:[(OSAppPane*)self.pane application] includeStatusBar:true decodeImage:true];

			UIGraphicsBeginImageContextWithOptions(zoomView.bounds.size, zoomView.opaque, 0.0);
    		[zoomView.layer renderInContext:UIGraphicsGetCurrentContext()];
    		[self setImage:UIGraphicsGetImageFromCurrentImageContext()];
    		UIGraphicsEndImageContext();

			return;
		}

		UIGraphicsBeginImageContextWithOptions(self.pane.bounds.size, self.pane.opaque, 0.0);
    	[self.pane.layer renderInContext:UIGraphicsGetCurrentContext()];
    	[self setImage:UIGraphicsGetImageFromCurrentImageContext()];
    	UIGraphicsEndImageContext();
	});
}



@end