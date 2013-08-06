#import "OSPaneThumbnail.h"




@implementation OSPaneThumbnail
@synthesize pane = _pane;
@synthesize label = _label;
@synthesize icon = _icon;
@synthesize grabPoint = _grabPoint;
@synthesize placeholder = _placeholder;
@synthesize selected = _selected;
@synthesize selectionView = _selectionView;
@synthesize imageView = _imageView;


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

	//self.backgroundColor = [UIColor whiteColor];
	self.userInteractionEnabled = true;


	self.imageView = [[UIImageView alloc] initWithFrame:self.frame];
	self.imageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	self.imageView.layer.masksToBounds = NO;
	self.imageView.layer.shadowOffset = CGSizeMake(0, 0);
	self.imageView.layer.shadowRadius = 5;
	self.imageView.layer.shadowOpacity = 0.5;
	self.imageView.layer.shadowPath = [UIBezierPath bezierPathWithRect:self.imageView.bounds].CGPath;
	[self addSubview:self.imageView];


	self.pane = pane;
	[self updateImage];


	if([self.pane isKindOfClass:[OSAppPane class]]){
		self.icon = [[UIImageView alloc] init];
		
		UIImage *icon = [[[objc_getClass("SBApplicationIcon") alloc] initWithApplication:[(OSAppPane*)self.pane application]] generateIconImage:2];
		self.icon.image = icon;
		[icon release];

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
	self.label.layer.shouldRasterize = true;
	self.label.font = [UIFont boldSystemFontOfSize:15];
	self.label.adjustsFontSizeToFitWidth = false;

	[self addSubview:self.label];


	frame = self.imageView.frame;
	frame.size.width += 2;
	frame.size.height += 2;
	frame.origin.x = -1;
	frame.origin.y = -1;

	self.selectionView.frame = frame;
	self.selectionView = [[UIView alloc] initWithFrame:frame];
	self.selectionView.layer.borderColor = [UIColor whiteColor].CGColor;
	self.selectionView.layer.borderWidth = 1.0f;

	[self addSubview:self.selectionView];
	[self sendSubviewToBack:self.selectionView];


	return self;

}

- (void)dealloc{
	[self.label release];
	[self.imageView release];
	[self.selectionView release];

	if(self.icon)
		[self.icon release];


	[super dealloc];
}

- (void)setSelected:(BOOL)selected{
	_selected = selected;

	if(selected){
		self.selectionView.hidden = false;
	}else{
		self.selectionView.hidden = true;
	}
}

- (void)layoutSubviews{

	self.icon.center = CGPointMake(self.bounds.size.width / 2, self.frame.size.height - 18);

	CGPoint labelOrigin = [[OSThumbnailView sharedInstance] convertPoint:CGPointMake(0, [[OSThumbnailView sharedInstance] frame].size.height) toView:self];
	CGPoint labelCenter;
	labelCenter.x = self.frame.size.width / 2;
	labelCenter.y = ((labelOrigin.y - self.frame.size.height) / 2) + self.frame.size.height;
	self.label.center = labelCenter;


	CGRect frame = self.imageView.frame;
	frame.size.width += 2;
	frame.size.height += 2;
	frame.origin.x = -1;
	frame.origin.y = -1;
	self.selectionView.frame = frame;
}

- (void)updateSize{
	CGRect frame = [[UIScreen mainScreen] bounds];

	if(![[OSThumbnailView sharedInstance] isPortrait]){
		float width = frame.size.width;
		frame.size.width = frame.size.height;
		frame.size.height = width;
	}

	frame = CGRectApplyAffineTransform(frame, CGAffineTransformScale(CGAffineTransformIdentity, 0.15, 0.15));
	frame.origin = self.frame.origin;
	self.frame = frame;

	self.imageView.layer.shadowPath = [UIBezierPath bezierPathWithRect:self.imageView.bounds].CGPath;
}


- (void)updateImage{
	dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{

		UIImage *image;

		if([self.pane isKindOfClass:[OSAppPane class]]){
			UIView *zoomView = [[objc_getClass("SBUIController") sharedInstance] systemGestureSnapshotForApp:[(OSAppPane*)self.pane application] includeStatusBar:true decodeImage:true];
			UIGraphicsBeginImageContextWithOptions(zoomView.bounds.size, zoomView.opaque, 0.5);
    		[zoomView.layer renderInContext:UIGraphicsGetCurrentContext()];
  			image = UIGraphicsGetImageFromCurrentImageContext();
		}else{
			UIGraphicsBeginImageContextWithOptions(self.bounds.size, self.pane.opaque, 0.0);
			CGContextConcatCTM(UIGraphicsGetCurrentContext(), CGAffineTransformMakeScale(0.15, 0.15));
    		[self.pane.layer renderInContext:UIGraphicsGetCurrentContext()];
    		image = UIGraphicsGetImageFromCurrentImageContext();
    	}

    	dispatch_async(dispatch_get_main_queue(), ^{
    		[self.imageView setImage:image];
    	});
	});
}



@end