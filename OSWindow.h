#import <UIKit/UIKit.h>
#import "include.h"



@interface OSWindow : UIView{
	UIToolbar *_windowBar;
}

@property (nonatomic, retain) UIToolbar *windowBar;

- (id)initWithFrame:(CGRect)arg1 title:(NSString*)title;
- (void)stopButtonPressed;

@end