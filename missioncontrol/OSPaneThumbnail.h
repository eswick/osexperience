#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "../include.h"
#import "../UIImage+Extensions.h"



@class OSThumbnailPlaceholder, OSAppMirrorView, OSThumbnailView, OSPane, OSPaneThumbnail, OSWindow;

@protocol OSPaneThumbnailDelegate

- (void)paneThumbnailTapped:(OSPaneThumbnail*)thumbnail;

@end


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
	BOOL _pressed;
	UIView *_shadowOverlayView;
}

@property (nonatomic, assign) OSPane *pane;
@property (nonatomic, retain) UILabel *label;
@property (nonatomic, retain) UIImageView *icon;
@property (nonatomic, retain) UIImageView *imageView;
@property (nonatomic, readwrite) CGPoint grabPoint;
@property (nonatomic, retain) OSThumbnailPlaceholder *placeholder;
@property (nonatomic, getter=isSelected, readwrite) BOOL selected;
@property (nonatomic, retain) UIView *selectionView;
@property (nonatomic, retain) UIButton *closebox;
@property (nonatomic, readwrite) BOOL closeboxVisible;
@property (nonatomic, getter=isPressed, readwrite) BOOL pressed;
@property (nonatomic, retain) UIView *shadowOverlayView;
@property (nonatomic, retain) OSAppMirrorView *mirrorView;
@property (nonatomic, retain) UIView *windowContainer;
@property (nonatomic, assign) id<OSPaneThumbnailDelegate> delegate; 

- (id)initWithPane:(OSPane*)pane;
- (void)updateSize;
- (void)setCloseboxVisible:(BOOL)visible animated:(BOOL)animated;
- (void)prepareForDisplay;
- (void)didHide;
- (CGRect)previewRectForWindow:(OSWindow*)window;
- (void)updateWindowPreviews;



@end