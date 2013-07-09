#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "OSFile.h"





@interface OSFileView : UIView {

	UIPanGestureRecognizer *panGesture;
	UILongPressGestureRecognizer *holdGesture;

	UIImageView *iconView;
	UILabel *fileLabel;
	UIView *selectionBackdrop;

	OSFile *file;
	CGPoint dragOffset;
	CGPoint startingPoint;

	bool selected;

}

@property (nonatomic, retain) UIPanGestureRecognizer *panGesture;
@property (nonatomic, retain) UILongPressGestureRecognizer *holdGesture;
@property (nonatomic, retain) UIImageView *iconView;
@property (nonatomic, retain) UILabel *fileLabel;
@property (nonatomic, readwrite) CGPoint dragOffset;
@property (nonatomic, readwrite) CGPoint startingPoint;
@property (nonatomic, retain) OSFile *file;
@property (nonatomic, retain) UIView *selectionBackdrop;
@property (readwrite) bool selected;

-(id)initWithFile:(OSFile*)file;

-(void)setSelected:(bool)selected animated:(bool)animated;






@end