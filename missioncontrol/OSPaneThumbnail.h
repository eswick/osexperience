#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "../OSPane.h"
#import "OSThumbnailView.h"
#import "../OSAppPane.h"

@class OSThumbnailPlaceholder;

@interface OSPaneThumbnail : UIImageView{
	OSPane *_pane;
	UILabel *_label;
	UIImageView *_icon;
	CGPoint _grabPoint;
	id _placeholder;
}

@property (nonatomic, retain) OSPane *pane;
@property (nonatomic, retain) UILabel *label;
@property (nonatomic, retain) UIImageView *icon;
@property (nonatomic, readwrite) CGPoint grabPoint;
@property (nonatomic, retain) id placeholder;

- (id)initWithPane:(OSPane*)pane;
- (void)updateImage;
- (void)updateSize;



@end
/*
@interface UIView(Additions)

- (BOOL)needsDisplay;

@end*/