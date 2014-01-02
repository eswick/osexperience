#import "OSExplorerSidebarController.h"

#define rgba(r,g,b,a) [UIColor colorWithRed:(r/255.0) green:(g/255.0) blue:(b/255.0) alpha:a]

@implementation OSExplorerSidebarController

- (id)init{
	if(![super init])
		return nil;

	

	return self;
}

- (void)loadView{
	self.view = [[UIView alloc] init];

	self.view.backgroundColor = rgba(235,238,241,1.0);

	self.rightBorder = [CALayer layer];
	self.rightBorder.backgroundColor = rgba(172,172,172,1.0).CGColor;

	[self.view.layer addSublayer:self.rightBorder];

	[self.view release];
}

- (void)viewDidLayoutSubviews{
	[CATransaction begin]; 
   	[CATransaction setValue: (id) kCFBooleanTrue forKey: kCATransactionDisableActions];
	self.rightBorder.frame = CGRectMake(CGRectGetWidth(self.view.frame) - 1, 0, 1, CGRectGetHeight(self.view.frame));
	[CATransaction commit];
}

@end