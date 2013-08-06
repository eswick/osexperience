#import <UIKit/UIKit.h>
#import "OSThumbnailView.h"


@interface OSThumbnailWrapper : UIView{
	BOOL _shouldAnimate;
}
@property (nonatomic, readwrite) BOOL shouldAnimate;


- (void)layoutSubviewsAnimated;


@end