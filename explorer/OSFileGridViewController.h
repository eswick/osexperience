
#import "OSFileViewController.h"


typedef enum{
	OSFileGridViewTypeWindowed,
	OSFileGridViewTypeDesktop
} OSFileGridViewType;

@interface OSFileGridViewController : OSFileViewController{

}

@property (nonatomic, retain) UIScrollView *view;
@property (nonatomic) OSFileGridViewType type;
@property (nonatomic) float gridSpacing;
@property (nonatomic) CGSize iconSize;

@end