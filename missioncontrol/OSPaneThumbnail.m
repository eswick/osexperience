#import "OSPaneThumbnail.h"
#import "OSThumbnailPlaceholder.h"




@implementation OSPaneThumbnail
@synthesize pane = _pane;
@synthesize label = _label;
@synthesize icon = _icon;
@synthesize grabPoint = _grabPoint;
@synthesize placeholder = _placeholder;
@synthesize selected = _selected;
@synthesize selectionView = _selectionView;
@synthesize imageView = _imageView;
@synthesize closebox = _closebox;
@synthesize closeboxVisible = _closeboxVisible;
@synthesize pressed = _pressed;
@synthesize shadowOverlayView = _shadowOverlayView;


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

	self.placeholder = [[OSThumbnailPlaceholder alloc] initWithPane:[self pane]];

	self.closebox = [UIButton buttonWithType:UIButtonTypeCustom];
	self.closebox.frame = CGRectMake(0, 0, 30, 30);
	[self.closebox setImage:[UIImage imageWithContentsOfFile:@"/Library/Application Support/OS Experience/closebox.png"] forState:UIControlStateNormal];
	self.closebox.center = (CGPoint){0, 0};

	[self.closebox addTarget:self action:@selector(closeboxTapped) forControlEvents:UIControlEventTouchUpInside];

	[self setCloseboxVisible:false animated:false];

	[self addSubview:self.closebox];

	self.pressed = false;

	self.shadowOverlayView = [[UIView alloc] initWithFrame:self.frame];
	self.shadowOverlayView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
	self.shadowOverlayView.backgroundColor = [UIColor blackColor];
	self.shadowOverlayView.alpha = 0.5;
	self.shadowOverlayView.hidden = true;
	[self addSubview:self.shadowOverlayView];

	return self;

}

- (void)setCloseboxVisible:(BOOL)visible animated:(BOOL)animated{
	if(animated){

		if(visible){
			self.closebox.alpha = 0;
			self.closebox.hidden = false;
			self.closeboxVisible = true;
			[UIView animateWithDuration:0.15 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
				self.closebox.alpha = 1;
			}completion:^(BOOL finished){}];
		}else{
			self.closebox.alpha = 1;
			self.closeboxVisible = false;
			[UIView animateWithDuration:0.15 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
				self.closebox.alpha = 0;
			}completion:^(BOOL finished){
				self.closebox.hidden = true;
			}];
		}

	}else{
		if(visible){
			self.closebox.hidden = false;
			self.closebox.alpha = 1;
			self.closeboxVisible = true;
		}else{
			self.closebox.hidden = true;
			self.closebox.alpha = 0;
			self.closeboxVisible = false;
		}
	}
}

- (void)dealloc{
	[self.label release];
	[self.imageView release];
	[self.selectionView release];
	[self.placeholder release];
	[self.closebox release];
	[self.shadowOverlayView release];

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

- (void)closeboxTapped{
	[[OSPaneModel sharedInstance] removePane:self.pane];
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

		UIImage *image = nil;

		if([self.pane isKindOfClass:[OSAppPane class]]){
			UIView *zoomView = [[objc_getClass("SBUIController") sharedInstance] systemGestureSnapshotWithIOSurfaceSnapshotOfApp:[(OSAppPane*)self.pane application] includeStatusBar:true];
			
			CGRect frame = zoomView.bounds;
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

			UIGraphicsBeginImageContextWithOptions(frame.size, zoomView.opaque, [UIScreen mainScreen].scale);
    		[zoomView.layer renderInContext:UIGraphicsGetCurrentContext()];
  			image = [UIGraphicsGetImageFromCurrentImageContext() imageRotatedByDegrees:appViewDegrees];

		}else if([self.pane isKindOfClass:[OSDesktopPane class]]){

			UIGraphicsBeginImageContextWithOptions(self.bounds.size, self.pane.opaque, 4);
			CGContextConcatCTM(UIGraphicsGetCurrentContext(), CGAffineTransformMakeScale(0.15, 0.15));
    		[self.pane.layer renderInContext:UIGraphicsGetCurrentContext()];
    		
    		for(OSWindow *window in [(OSDesktopPane*)self.pane windows]){
    			CGContextTranslateCTM(UIGraphicsGetCurrentContext(), window.originInDesktop.x, window.originInDesktop.y);
    			[window.layer renderInContext:UIGraphicsGetCurrentContext()];
    		}
    		
    		image = UIGraphicsGetImageFromCurrentImageContext();
    	}

    	UIGraphicsEndImageContext();
    	
    	dispatch_async(dispatch_get_main_queue(), ^{
    		[self animateToImage:image];
    	});
	});
}

- (void)animateToImage:(UIImage*)image{
	UIImageView *newImageView = [[UIImageView alloc] initWithFrame:self.imageView.frame];
	newImageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	newImageView.alpha = 0;
	newImageView.image = image;

	[self addSubview:newImageView];
	[self sendSubviewToBack:newImageView];
	[self sendSubviewToBack:self.imageView];
	[self sendSubviewToBack:self.selectionView];

	[UIView animateWithDuration:0.25 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
		newImageView.alpha = 1;
	}completion:^(BOOL finished){
		[self.imageView removeFromSuperview];
		//[self.imageView release];
		//self.imageView = nil;
		self.imageView = newImageView;

		self.imageView.layer.shadowOffset = CGSizeMake(0, 0);
		self.imageView.layer.shadowRadius = 5;
		self.imageView.layer.shadowOpacity = 0.5;
		self.imageView.layer.shadowPath = [UIBezierPath bezierPathWithRect:newImageView.bounds].CGPath;
	}];
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event{
    if(CGRectContainsPoint(self.closebox.frame, point)){
		return self.closebox;
	}else{
		return [super hitTest:point withEvent:event];
	}
}

- (void)setPressed:(BOOL)pressed{
	_pressed = pressed;
	if(pressed){
		self.shadowOverlayView.hidden = false;
	}else{
		self.shadowOverlayView.hidden = true;
	}
}

- (BOOL)isPressed{
	return _pressed;
}

@end