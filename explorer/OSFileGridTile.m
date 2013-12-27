#import "OSFileGridTile.h"
#import "OSFileGridTileLabel.h"


#define labelSpace 40

@interface UIColor ()
+ (UIColor*)tableSelectionColor;
@end

@implementation OSFileGridTile

- (id)initWithIconSize:(CGSize)iconSize gridSpacing:(float)spacing{
	if(![super initWithFrame:CGRectMake(0, 0, iconSize.width + spacing, iconSize.height + labelSpace)])
		return nil;

	self.iconSize = iconSize;
	self.gridSpacing = spacing;

	/* Icon */
	CGRect iconViewFrame = CGRectMake(0, 0, self.iconSize.width, self.iconSize.height);

	self.iconView = [[UIImageView alloc] initWithFrame:iconViewFrame];
	[self addSubview:self.iconView];

	CGPoint center = self.iconView.center;
	center.x = self.bounds.size.width / 2;
	self.iconView.center = center;


	/* Label */
	self.label = [[OSFileGridTileLabel alloc] initWithFrame:CGRectMake(0, self.iconView.frame.size.height, self.bounds.size.width, labelSpace)];

	CGPoint labelCenter = self.label.center;
	labelCenter.x = self.bounds.size.width / 2;
	self.label.center = labelCenter;

	self.label.textAlignment = NSTextAlignmentCenter;

	self.label.textColor = [UIColor whiteColor];//Remember to change for windowed mode
   	self.label.font = [UIFont boldSystemFontOfSize:12];

   	self.label.backgroundColor = [UIColor clearColor];

   	self.label.lineBreakMode = NSLineBreakByTruncatingMiddle;
   	self.label.numberOfLines = 2;


   	/* For desktop only */
	self.label.shadowColor = [UIColor blackColor];
	self.label.layer.shadowColor = [[UIColor blackColor] CGColor];
	self.label.layer.shadowOffset = CGSizeMake(0.0, 0.0);
	self.label.layer.shadowRadius = 3.0;
	self.label.layer.shadowOpacity = 1;
	/* end */

	self.label.clipsToBounds = false;
	self.label.layer.shouldRasterize = true;
	[self addSubview:self.label];

	self.selectionBackdrop = [[UIView alloc] initWithFrame:self.iconView.frame];
	self.selectionBackdrop.backgroundColor = [UIColor darkGrayColor];
	self.selectionBackdrop.layer.cornerRadius = 5;
	self.selectionBackdrop.alpha = 0.5;
	self.selectionBackdrop.layer.borderColor = [UIColor lightGrayColor].CGColor;
	self.selectionBackdrop.layer.borderWidth = 2.0f;
	self.selectionBackdrop.hidden = true;
	[self addSubview:self.selectionBackdrop];
	[self sendSubviewToBack:self.selectionBackdrop];

	[self.selectionBackdrop release];
	[self.iconView release];
	[self.label release];

	return self;
}

- (void)setSelected:(BOOL)selected{
	_selected = selected;

	if(selected)
		self.selectionBackdrop.hidden = false;
	else
		self.selectionBackdrop.hidden = true;

	[self.label setSelected:selected];
}

- (void)setUrl:(NSURL*)url{
	if(_url)
		[_url release];

	[url retain];
	_url = url;

	NSString *text = [[url path] lastPathComponent];
	self.label.text = text;

	[self.label redrawText];
}

- (void)setIcon:(UIImage*)icon{
	self.iconView.image = icon;
}

- (void)dealloc{
	[self.iconView release];
	[self.label release];
	[self.selectionBackdrop release];
	[self.url release];
	[super dealloc];
}

@end