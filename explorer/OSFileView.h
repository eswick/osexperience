#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "OSFile.h"
#import "OSFileGridView.h"




@interface OSFileView : UIView {

	UIPanGestureRecognizer *_panGesture;
	UILongPressGestureRecognizer *_holdGesture;

	UIImageView *_iconView;
	UILabel *_fileLabel;
	UIView *_selectionBackdrop;

	OSFile *_file;
	CGPoint _dragOffset;
	CGPoint _startingPoint;

	bool _selected;
	OSFileGridViewType _type;
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
@property (readwrite) OSFileGridViewType type;

-(id)initWithFile:(OSFile*)file type:(OSFileGridViewType)type;

-(void)setSelected:(bool)selected animated:(bool)animated;






@end