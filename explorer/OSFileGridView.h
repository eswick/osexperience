//
//  OSFileGridView.h
//  
//
//  Created by Evan Swick on 6/16/13.
//
//
#import <QuartzCore/QuartzCore.h>
#import <UIKit/UIKit.h>
#import "OSFileView.h"
#import "CGPointExtension.h"
#import "../include.h"

@interface OSFileGridView : UIView {
	UIView *_selectionDragView;
	CGPoint _selectionDragViewStartPoint;
}
@property(nonatomic, retain) UIView *selectionDragView;
@property(nonatomic) CGPoint selectionDragViewStartPoint;



-(id)initWithDirectory:(NSString*)directory frame:(CGRect)frame;
-(NSMutableArray*)selectedViews;
-(void)drawFiles;
-(void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration;
-(void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation;
CGRect CGRectFromCGPoints(CGPoint p1, CGPoint p2);


@end
