#import "OSWindow.h"



@implementation OSWindow
@synthesize windowBar = _windowBar;


- (id)initWithFrame:(CGRect)arg1 title:(NSString*)title{
	if(![super initWithFrame:arg1])
		return nil;



	self.windowBar = [[UIToolbar alloc] init];
	self.windowBar.frame = CGRectMake(0, 0, self.frame.size.width, 44);
	self.windowBar.autoresizingMask = UIViewAutoresizingFlexibleWidth;

	NSMutableArray *items = [[NSMutableArray alloc] init];

	UIBarButtonItem *closeButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemStop target:self action:@selector(stopButtonPressed)];
	UIBarButtonItem *titleLabel = [[UIBarButtonItem alloc] initWithTitle:title style:UIBarButtonItemStylePlain target:nil action:nil];

	[items addObject:closeButton];
	[items addObject:[[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil] autorelease]];
	[items addObject:titleLabel];
	[items addObject:[[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil] autorelease]];



	[self.windowBar setItems:items animated:false];
	[items release];
	[self addSubview:self.windowBar];

	titleLabel.view.userInteractionEnabled = false;
	[title release];
	[closeButton release];

	return self;
}



- (void)stopButtonPressed{


}


@end