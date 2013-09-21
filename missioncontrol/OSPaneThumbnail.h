#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "../OSPane.h"
#import "OSThumbnailView.h"
#import "../OSAppPane.h"
#import "../include.h"
#import "../UIImage+Extensions.h"

@class OSThumbnailPlaceholder;

@interface OSPaneThumbnail : UIView{
	OSPane *_pane;
	UILabel *_label;
	UIImageView *_icon;
	UIImageView *_imageView;
	CGPoint _grabPoint;
	OSThumbnailPlaceholder *_placeholder;
	BOOL _selected;
	UIView *_selectionView;
	UIButton *_closebox;
	BOOL _closeboxVisible;
}

@property (nonatomic, retain) OSPane *pane;
@property (nonatomic, retain) UILabel *label;
@property (nonatomic, retain) UIImageView *icon;
@property (nonatomic, retain) UIImageView *imageView;
@property (nonatomic, readwrite) CGPoint grabPoint;
@property (nonatomic, retain) OSThumbnailPlaceholder *placeholder;
@property (nonatomic, getter=isSelected, readwrite) BOOL selected;
@property (nonatomic, retain) UIView *selectionView;
@property (nonatomic, retain) UIButton *closebox;
@property (nonatomic, readwrite) BOOL closeboxVisible;
 
- (id)initWithPane:(OSPane*)pane;
- (void)updateImage;
- (void)updateSize;
- (void)setCloseboxVisible:(BOOL)visible animated:(BOOL)animated;



@end