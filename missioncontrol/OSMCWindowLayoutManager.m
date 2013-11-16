#import "OSMCWindowLayoutManager.h"
#import "../OSPaneModel.h"
#import "../OSDesktopPane.h"
#import "../OSSlider.h"


@implementation OSMCWindowLayoutManager



+ (void)layoutWindows{
	setMaximumScaleOfAllWindowsToScale(missionControlMaximumScale);
	setAllWindowsToScale(missionControlMaximumScale);
}

+ (CGPoint)convertPointToSlider:(CGPoint)point fromPane:(OSPane*)pane{
	return CGPointMake(([[OSPaneModel sharedInstance] indexOfPane:pane] * [[OSSlider sharedInstance] bounds].size.width) + point.x, point.y - [[OSSlider sharedInstance] frame].origin.y);
}

+ (CGPoint)convertPointFromSlider:(CGPoint)point toPane:(OSPane*)pane{
	return CGPointMake(point.x - ([[OSPaneModel sharedInstance] indexOfPane:pane] * [[OSSlider sharedInstance] bounds].size.width), point.y + [[OSSlider sharedInstance] frame].origin.y);
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