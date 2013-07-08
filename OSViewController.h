#import "OSWallpaperView.h"
#import <UIKit/UIKit.h>
#import "OSSlider.h"
#import "OSDesktopPane.h"




@interface OSViewController : UIViewController{
	OSSlider *_slider;
}

@property (nonatomic, retain) OSSlider *slider;


@end