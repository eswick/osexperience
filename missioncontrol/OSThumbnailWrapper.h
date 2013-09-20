#import <UIKit/UIKit.h>
#import "OSThumbnailView.h"


@interface OSThumbnailWrapper : UIView{
	BOOL _shouldLayoutSubviews;
}
@property (nonatomic, readwrite) BOOL shouldLayoutSubviews;


- (void)forceLayoutSubviews;


@end