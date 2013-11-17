#import "OSMCWindowLayoutManager.h"
#import "../OSPaneModel.h"
#import "../OSDesktopPane.h"
#import "../OSSlider.h"

#define windowConstraints [[OSViewController sharedInstance] missionControlWindowConstraints]

@implementation OSMCWindowLayoutManager



+ (void)layoutWindows{

	setMaximumScaleOfAllWindowsToScale(missionControlMaximumScale);
	setAllWindowsToScale(missionControlMaximumScale);

	placeAllWindowsWithinConstraints();
	
}

+ (CGPoint)convertPointToSlider:(CGPoint)point fromPane:(OSPane*)pane{
	return CGPointMake(([[OSPaneModel sharedInstance] indexOfPane:pane] * [[OSSlider sharedInstance] bounds].size.width) + point.x, point.y - [[OSSlider sharedInstance] frame].origin.y);
}

+ (CGPoint)convertPointFromSlider:(CGPoint)point toPane:(OSPane*)pane{
	return CGPointMake(point.x - ([[OSPaneModel sharedInstance] indexOfPane:pane] * [[OSSlider sharedInstance] bounds].size.width), point.y + [[OSSlider sharedInstance] frame].origin.y);
}

+ (CGRect)convertRectFromSlider:(CGRect)rect toPane:(OSPane*)pane{
	CGRect returnValue = CGRectZero;

	returnValue.origin = [OSMCWindowLayoutManager convertPointFromSlider:rect.origin toPane:pane];
	returnValue.size = rect.size;

	return returnValue;
}

+ (CGRect)convertRectToSlider:(CGRect)rect fromPane:(OSPane*)pane{
	CGRect returnValue = CGRectZero;

	returnValue.origin = [OSMCWindowLayoutManager convertPointToSlider:rect.origin fromPane:pane];
	returnValue.size = rect.size;

	return returnValue;
}

void placeAllWindowsWithinConstraints(){
	for(OSDesktopPane *pane in [[OSPaneModel sharedInstance] panes]){
		if(![pane isKindOfClass:[OSDesktopPane class]])
			continue;
		for(OSWindow *window in pane.windows){
			if(![window isKindOfClass:[OSWindow class]])
				continue;
			CGRect frame = [OSMCWindowLayoutManager convertRectFromSlider:window.frame toPane:pane];

			if(!CGRectContainsRect(windowConstraints, frame)){
				placeWindowWithinConstraints(window, pane);
			}
		}
	}
}

void placeWindowWithinConstraints(OSWindow *window, OSPane *pane){

	CGRect frame = [OSMCWindowLayoutManager convertRectFromSlider:window.frame toPane:pane];

	//Check top
	if(frame.origin.y < windowConstraints.origin.y)
		frame.origin.y = windowConstraints.origin.y;

	//Check bottom
	if(frame.size.height + frame.origin.y > windowConstraints.size.height + windowConstraints.origin.y){
		float difference = (frame.size.height + frame.origin.y) - (windowConstraints.size.height + windowConstraints.origin.y);
		frame.origin.y -= difference;
	}

	//Check left
	if(frame.origin.x < windowConstraints.origin.x)
		frame.origin.x = windowConstraints.origin.x;

	//Check right
	if(frame.origin.x + frame.size.width > windowConstraints.origin.x + windowConstraints.size.width){
		float difference = (frame.origin.x + frame.size.width) - (windowConstraints.size.width + windowConstraints.origin.x);
		frame.origin.x -= difference;
	}

	window.frame = [OSMCWindowLayoutManager convertRectToSlider:frame fromPane:pane];

}


void setAllWindowsToScale(float scale){
	for(OSDesktopPane *pane in [[OSPaneModel sharedInstance] panes]){
		if(![pane isKindOfClass:[OSDesktopPane class]])
			continue;
		for(OSWindow *window in pane.windows){
			if(![window isKindOfClass:[OSWindow class]])
				continue;
			window.transform = CGAffineTransformScale(CGAffineTransformIdentity, scale, scale);
		}
	}
}

void setMaximumScaleOfAllWindowsToScale(float scale){
	for(OSDesktopPane *pane in [[OSPaneModel sharedInstance] panes]){
		if(![pane isKindOfClass:[OSDesktopPane class]])
			continue;
		for(OSWindow *window in pane.windows){
			if(![window isKindOfClass:[OSWindow class]])
				continue;
			window.maxScale = scale * 100;
		}
	}
}


@end