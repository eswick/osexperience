#import "OSThumbnailView.h"




@implementation OSThumbnailView
@synthesize wrapperView = _wrapperView;


+ (id)sharedInstance
{
    static OSThumbnailView *_view;

    if (_view == nil)
    {
        _view = [[self alloc] init];
    }

    return _view;
}



- (id)init{

	CGRect frame = [[UIScreen mainScreen] bounds];

	if(![self isPortrait]){
		float width = frame.size.width;
		frame.size.width = frame.size.height;
		frame.size.height = width;
	}

	frame.size.height = frame.size.height / 4;

	if(![super initWithFrame:frame])
		return nil;

	self.autoresizingMask = UIViewAutoresizingFlexibleWidth;
	self.hidden = true;


	self.wrapperView = [[OSThumbnailWrapper alloc] init];
	[self addSubview:self.wrapperView];


	return self;
}


-(void)willRotateToInterfaceOrientation: (UIInterfaceOrientation)orientation duration:(NSTimeInterval)duration{
	CGRect frame = [[UIScreen mainScreen] bounds];

	if(![self isPortrait]){
		float width = frame.size.width;
		frame.size.width = frame.size.height;
		frame.size.height = width;
	}

	frame.size.height = frame.size.height / 4;

	[self setFrame:frame];

	for(OSPaneThumbnail *thumbnail in self.wrapperView.subviews){
		[thumbnail updateSize];
		thumbnail.layer.shadowPath = [UIBezierPath bezierPathWithRect:thumbnail.bounds].CGPath;
		thumbnail.frame = CGRectMake((thumbnail.frame.size.width + thumbnailMarginSize) * [[OSPaneModel sharedInstance] indexOfPane:thumbnail.pane], 0, thumbnail.frame.size.width, thumbnail.frame.size.height);
		[thumbnail updateImage];
	}

	[self alignWrapper];

	for(OSPaneThumbnail *thumbnail in self.wrapperView.subviews){
		[thumbnail updateLabel];
	}

}

- (void)alignWrapper{
	CGPoint center = self.center;
	center.y -= wrapperCenter;
	self.wrapperView.center = center;
}



- (void)addPane:(OSPane*)pane{
	OSPaneThumbnail *thumbnail = [[OSPaneThumbnail alloc] initWithPane:pane];

	thumbnail.frame = CGRectMake((thumbnail.frame.size.width + thumbnailMarginSize) * [[OSPaneModel sharedInstance] indexOfPane:pane], 0, thumbnail.frame.size.width, thumbnail.frame.size.height);

	[self.wrapperView addSubview:thumbnail];

	[self alignWrapper];

	for(OSPaneThumbnail *paneThumbnail in self.wrapperView.subviews){
		[paneThumbnail updateLabel];
	}

	[thumbnail release];
}

- (void)alignPanes{

}


- (BOOL)isPortrait{
	if([[UIApplication sharedApplication] statusBarOrientation] == UIInterfaceOrientationPortrait || [[UIApplication sharedApplication] statusBarOrientation] == UIInterfaceOrientationPortraitUpsideDown){
        return true;
    }
    return false;
}


- (void)dealloc{
	[self.wrapperView release];
	[super dealloc];
}


@end