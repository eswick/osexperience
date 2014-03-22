#import "OSAddDesktopButton.h"



@implementation OSAddDesktopButton
@synthesize wallpaper = _wallpaper;
@synthesize plusIcon = _plusIcon;
@synthesize delegate = _delegate;
@synthesize shadow = _shadow;

- (id)init{

	CGRect frame = CGRectZero;
	frame = [[UIScreen mainScreen] bounds];

 	frame.origin.x = frame.size.width;

	if(!UIInterfaceOrientationIsPortrait([UIApp statusBarOrientation])){
		float width = frame.size.width;
		frame.size.width = frame.size.height;
		frame.size.height = width;
		frame.origin.x = frame.size.height;
	}

	frame = CGRectApplyAffineTransform(frame, CGAffineTransformScale(CGAffineTransformIdentity, 0.15, 0.15));


	if(![super initWithFrame:frame])
		return nil;

	self.alpha = 0.75;

	self.clipsToBounds = false;
	self.layer.shadowOffset = CGSizeMake(0, 0);
	self.layer.shadowRadius = 5;
	self.layer.shadowOpacity = 0.5;
	self.layer.shadowPath = [UIBezierPath bezierPathWithRect:self.bounds].CGPath;


	self.wallpaper = [[UIImageView alloc] init];
	self.wallpaper.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	self.wallpaper.clipsToBounds = true;

	SBWallpaperImage *wallpaperImage = [[SBWallpaperImage alloc] initWithVariant:0];
	[self.wallpaper setImage:wallpaperImage];
	[wallpaperImage release];

	self.wallpaper.frame = self.frame;
	frame = self.wallpaper.frame;
	frame.origin = CGPointZero;
	[self.wallpaper setFrame:frame];
	
	self.wallpaper.contentMode = UIViewContentModeScaleAspectFill;
	[self addSubview:self.wallpaper];
	[self.wallpaper release];

	

	frame = self.frame;
	frame.size.width = frame.size.width / 2;
	frame.origin = CGPointZero;

	self.plusIcon = [[UIImageView alloc] initWithFrame:frame];

	self.plusIcon.image = [UIImage imageWithContentsOfFile:@"/Library/Application Support/OS Experience/expose-plus.png"];
	self.plusIcon.contentMode = UIViewContentModeCenter;

	self.plusIcon.layer.shadowOffset = CGSizeMake(0, 0);
	self.plusIcon.layer.shadowRadius = 0;
	self.plusIcon.layer.shadowOpacity = 0.30;
	self.plusIcon.layer.shadowPath = [UIBezierPath bezierPathWithRect:self.plusIcon.bounds].CGPath;

	[self addSubview:self.plusIcon];
	[self.plusIcon release];



	frame = self.frame;
	frame.size.width = frame.size.width / 2;
	frame.origin.x = self.frame.size.width / 2;
	self.shadow = [[UIView alloc] initWithFrame:frame];

	self.shadow.layer.shadowOffset = CGSizeMake(0, 0);
	self.shadow.layer.shadowRadius = 0;
	self.shadow.layer.shadowOpacity = 0.30;
	self.shadow.layer.shadowPath = [UIBezierPath bezierPathWithRect:self.plusIcon.bounds].CGPath;

	[self addSubview:self.shadow];
	[self.shadow release];

	UILongPressGestureRecognizer *tapGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
	tapGesture.minimumPressDuration = 0;
	[self addGestureRecognizer:tapGesture];
	[tapGesture release];


	return self;
}

- (void)handleTap:(UILongPressGestureRecognizer*)gesture{
	if(gesture.state == UIGestureRecognizerStateBegan){
		self.plusIcon.layer.shadowOpacity = 0.60;
	}else if(gesture.state == UIGestureRecognizerStateEnded){
		self.plusIcon.layer.shadowOpacity = 0.30;
		if([gesture state] == UIGestureRecognizerStateRecognized)
			[[self delegate] addDesktopButtonWasTapped:self];
	}else if(gesture.state == UIGestureRecognizerStateChanged){
		self.plusIcon.layer.shadowOpacity = 0.60;
	}

}

- (void)layoutSubviews{
	self.layer.shadowPath = [UIBezierPath bezierPathWithRect:self.bounds].CGPath;

	CGRect frame = CGRectZero;
	self.wallpaper.frame = self.frame;
	frame = self.wallpaper.frame;
	frame.origin = CGPointZero;
	[self.wallpaper setFrame:frame];


	frame = self.frame;
	frame.size.width = frame.size.width / 2;
	frame.origin = CGPointZero;
	self.plusIcon.frame = frame;
	self.plusIcon.layer.shadowPath = [UIBezierPath bezierPathWithRect:self.plusIcon.bounds].CGPath;


	frame.origin.x = self.frame.size.width / 2;
	self.shadow.frame = frame;
	self.shadow.layer.shadowPath = [UIBezierPath bezierPathWithRect:self.plusIcon.bounds].CGPath;
}

- (void)dealloc{
	[self.shadow release];
	[self.plusIcon release];
	[self.wallpaper release];
	[super dealloc];
}

@end