#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>



@interface OSPane : UIView{
	NSString *_name;
	UIImage *_thumbnail;
}

@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) UIImage *thumbnail;


- (id)initWithName:(NSString*)name thumbnail:(UIImage*)thumbnail;
- (BOOL)showsDock;
- (BOOL)isPortrait;



@end