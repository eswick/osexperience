//
//  OSFileGridView.h
//  
//
//  Created by Evan Swick on 6/16/13.
//
//
#import <QuartzCore/QuartzCore.h>
#import <UIKit/UIKit.h>
#import "CGPointExtension.h"
#import "../include.h"


typedef enum {
	OSFileGridViewDesktop,
	OSFileGridViewWindowed
} OSFileGridViewType;

@interface OSFileGridView : UIView {
	UIView *_selectionDragView;
	CGPoint _selectionDragViewStartPoint;
	OSFileGridViewType _type;
	NSString *_path;
}
@property (nonatomic, retain) UIView *selectionDragView;
@property (nonatomic) CGPoint selectionDragViewStartPoint;
@property (nonatomic) OSFileGridViewType type;
@property (nonatomic, retain) NSString *path;



-(id)initWithDirectory:(NSString*)directory frame:(CGRect)frame type:(OSFileGridViewType)type;
-(NSMutableArray*)selectedViews;
-(void)drawFiles;
-(void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration;
-(void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation;
CGRect CGRectFromCGPoints(CGPoint p1, CGPoint p2);


@end
