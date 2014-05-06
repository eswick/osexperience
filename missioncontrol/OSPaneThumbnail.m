#import "OSPaneThumbnail.h"
#import "OSThumbnailPlaceholder.h"
#import "OSAppMirrorView.h"
#import "OSThumbnailView.h"
#import <mach_verify/mach_verify.h>


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
	VERIFY_START(initWithPane);

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

	self.windowContainer = [[UIView alloc] initWithFrame:self.frame];
	self.windowContainer.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	self.windowContainer.clipsToBounds = true;
	[self addSubview:self.windowContainer];

	self.imageView = [[UIImageView alloc] initWithFrame:self.frame];
	self.imageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	self.imageView.layer.masksToBounds = NO;
	self.imageView.layer.shadowOffset = CGSizeMake(0, 0);
	self.imageView.layer.shadowRadius = 5;
	self.imageView.layer.shadowOpacity = 0.5;
	self.imageView.layer.shadowPath = [UIBezierPath bezierPathWithRect:self.imageView.bounds].CGPath;
	[self addSubview:self.imageView];

	self.pane = pane;	

	if([self.pane isKindOfClass:[OSAppPane class]]){
		//Initialize remote view
		self.mirrorView = [[OSAppMirrorView alloc] initWithApplication:[(OSAppPane*)pane application]];
		self.mirrorView.frame = self.bounds;
		self.mirrorView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;

		[self addSubview:self.mirrorView];


		//Initialize icon
		self.icon = [[UIImageView alloc] init];
		
		SBApplicationIcon *sbAppIcon = [[objc_getClass("SBApplicationIcon") alloc] initWithApplication:[(OSAppPane*)self.pane application]];

		UIImage *appIcon = [sbAppIcon generateIconImage:2];
		self.icon.image = appIcon;

		[sbAppIcon release];

		float size = [[OSThumbnailView sharedInstance] isPortrait] ? self.frame.size.width : self.frame.size.height;
		self.icon.frame = CGRectMake(0, 0, size / 2, size / 2);
		self.icon.center = CGPointMake(self.center.x, self.frame.size.height - 18);
		self.icon.layer.shadowOffset = CGSizeMake(0, 0);
		self.icon.layer.shadowRadius = 10;
		self.icon.layer.shadowOpacity = 0.5;
		self.icon.layer.shouldRasterize = true;
		[self addSubview:self.icon];
		[self.icon release];
	}else if([self.pane isKindOfClass:[OSDesktopPane class]]){
		self.imageView.image = [[[[OSThumbnailView sharedInstance] addDesktopButton] wallpaper] image];
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


	frame = self.frame;
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

	[self bringSubviewToFront:self.windowContainer];

	[self.imageView release];
	[self.label release];
	[self.selectionView release];
	[self.placeholder release];
	[self.shadowOverlayView release];
	[self.windowContainer release];

	UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
	[self addGestureRecognizer:tapGesture];
	[tapGesture release];

	VERIFY_STOP(initWithPane);

	return self;
}

- (void)handleTap:(UITapGestureRecognizer*)gesture{
	VERIFY_START(handleTap);

	if([gesture state] == UIGestureRecognizerStateRecognized)
		[[self delegate] paneThumbnailTapped:self];

	VERIFY_STOP(handleTap);
}

- (void)setCloseboxVisible:(BOOL)visible animated:(BOOL)animated{
	VERIFY_START(setCloseboxVisible);

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

	VERIFY_STOP(setCloseboxVisible);
}

- (void)removeWindowPreviews{
	for(OSAppMirrorView *mirrorView in self.windowContainer.subviews){
		if(![mirrorView isKindOfClass:[OSAppMirrorView class]])
			continue;
		[mirrorView removeRemoteViews];
		[mirrorView removeFromSuperview];
	}
}

- (CGRect)previewRectForWindow:(OSWindow*)window{
	if(![self.pane isKindOfClass:[OSDesktopPane class]])
		return CGRectNull;

	CGRect frame = window.bounds;
	frame.origin = window.originInDesktop;
	frame.origin.y += window.windowBar.bounds.size.height;
	frame.size.height -= window.windowBar.bounds.size.height;

	frame = CGRectApplyAffineTransform(frame, CGAffineTransformMakeScale(0.15, 0.15));

	return frame;
}

- (void)updateWindowPreviews{
	if(![self.pane isKindOfClass:[OSDesktopPane class]])
		return;
	OSDesktopPane *desktopPane = (OSDesktopPane*)self.pane;

	[self removeWindowPreviews];

	for(OSAppWindow *window in desktopPane.windows){
		if(![window isKindOfClass:[OSAppWindow class]])
			continue;

		OSAppMirrorView *mirrorView = [[OSAppMirrorView alloc] initWithApplication:window.application];

		CGRect frame = window.bounds;
		frame.origin = window.originInDesktop;
		frame = CGRectApplyAffineTransform(frame, CGAffineTransformMakeScale(0.15, 0.15));

		mirrorView.frame = frame;

		[mirrorView addRemoteViews];
		[self.windowContainer addSubview:mirrorView];
		[mirrorView release];
	}
}

- (void)prepareForDisplay{
	[self updateWindowPreviews];
	[self.mirrorView addRemoteViews];
}

- (void)didHide{
	[self removeWindowPreviews];
	[self.mirrorView removeRemoteViews];
}

- (void)dealloc{

	[self.label release];
	[self.imageView release];
	[self.selectionView release];
	[self.placeholder release];
	[self.closebox release];
	[self.shadowOverlayView release];
	[self.icon release];
	[self.mirrorView release];
	[self.windowContainer release];
	
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
	if([self.pane isKindOfClass:[OSDesktopPane class]])
		[[OSPaneModel sharedInstance] removePane:self.pane];
	else if([self.pane isKindOfClass:[OSAppPane class]])
		[[(OSAppPane*)self.pane application] suspend];
}

- (void)layoutSubviews{

	self.icon.center = CGPointMake(self.bounds.size.width / 2, self.frame.size.height - 18);

	CGPoint labelOrigin = [[OSThumbnailView sharedInstance] convertPoint:CGPointMake(0, [[OSThumbnailView sharedInstance] frame].size.height) toView:self];
	CGPoint labelCenter;
	labelCenter.x = self.frame.size.width / 2;
	labelCenter.y = ((labelOrigin.y - self.frame.size.height) / 2) + self.frame.size.height;
	self.label.center = labelCenter;


	CGRect frame = self.bounds;
	frame.size.width += 2;
	frame.size.height += 2;
	frame.origin.x = -1;
	frame.origin.y = -1;
	self.selectionView.frame = frame;

	[self.mirrorView layoutSubviews];

	for(OSAppMirrorView *mirrorView in self.windowContainer.subviews){
		[mirrorView layoutSubviews];
	}
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