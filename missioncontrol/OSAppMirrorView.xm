#import "OSAppMirrorView.h"
#import "../include.h"
#import <substrate.h>
#import <objcipc/objcipc.h>
#import "../OSPreferences.h"

@interface OSContextServer : NSObject

@end

@implementation OSAppMirrorView


- (id)initWithApplication:(SBApplication*)application{


	if(![super init])
		return nil;

	self.application = application;
	self.clipsToBounds = true;



	return self;
}

- (void)layoutSubviews{

	int rotationDegree;
	int translationx = 0, translationy = 0;
	float scale = (UIInterfaceOrientationIsPortrait([UIApp statusBarOrientation]) ? self.bounds.size.width : self.bounds.size.height) / [[UIScreen mainScreen] bounds].size.width;
	float oppositeScale = ([[UIScreen mainScreen] bounds].size.width * [[UIScreen mainScreen] scale] / (UIInterfaceOrientationIsPortrait([UIApp statusBarOrientation]) ? self.bounds.size.width : self.bounds.size.height));

	switch([self.application statusBarOrientation]){
		case UIInterfaceOrientationPortrait:
		rotationDegree = 0;
		break;
		case UIInterfaceOrientationPortraitUpsideDown:
		rotationDegree = 180;
		translationy = (-oppositeScale) * self.bounds.size.height;
		translationx = (-oppositeScale) * self.bounds.size.width;
		break;
		case UIInterfaceOrientationLandscapeLeft:
		rotationDegree = 90;
		translationy = (-oppositeScale) * self.bounds.size.width;
		break;
		case UIInterfaceOrientationLandscapeRight:
		rotationDegree = 270;
		translationx = (-oppositeScale) * self.bounds.size.height;
		break;
	}

	for(UIView *view in self.subviews){
		if([view isKindOfClass:%c(SBProxyRemoteView)]){
			CGAffineTransform transform = CGAffineTransformMakeRotation(DegreesToRadians(rotationDegree));
			transform = CGAffineTransformScale(transform, scale / [[UIScreen mainScreen] scale], scale / [[UIScreen mainScreen] scale]);
			view.transform = CGAffineTransformTranslate(transform, translationx, translationy);
		}else if([view isKindOfClass:%c(SBFullscreenZoomView)]){
			view.transform = CGAffineTransformMakeScale(scale, scale);
			view.transform = CGAffineTransformRotate(view.transform, DegreesToRadians(rotationDegree));

			CGRect frame = view.frame;
			frame.origin = CGPointMake(0,0);
			view.frame = frame;
		}
	}
}

- (void)setRotation:(int)rotationDegree{
	for(SBProxyRemoteView *remoteView in self.subviews){
		if(![remoteView isKindOfClass:[%c(SBProxyRemoteView) class]])
			continue;
		float scale = (UIInterfaceOrientationIsPortrait([UIApp statusBarOrientation]) ? self.bounds.size.width : self.bounds.size.height) / ([[UIScreen mainScreen] bounds].size.width * [[UIScreen mainScreen] scale]);

		CGAffineTransform transform = CGAffineTransformMakeRotation(DegreesToRadians(rotationDegree));
		remoteView.transform = CGAffineTransformScale(transform, scale, scale);
	}
}

- (void)addRemoteViews{
	[self removeRemoteViews];

	if(![prefs LIVE_PREVIEWS]){
		[self addSubview:[[%c(SBUIController) sharedInstance] systemGestureSnapshotWithIOSurfaceSnapshotOfApp:self.application includeStatusBar:true]];
		return;
	}

	for(NSNumber *contextID in [self getContextList]){
		SBProxyRemoteView *remoteView = [[%c(SBProxyRemoteView) alloc] init];

		[remoteView connectToContextID:[contextID intValue] forIdentifier:@"com.eswick.osexperience" application:self.application];

		[self addSubview:remoteView];
		[remoteView release];
	}
}

- (void)removeRemoteViews{
	for(UIView *view in self.subviews){
		if([view isKindOfClass:[%c(SBProxyRemoteView) class]])
			[(SBProxyRemoteView*)view disconnect];
		[view removeFromSuperview];
	}
}

- (NSArray*)getContextList{

	NSMutableArray *contextIDs = [NSMutableArray array];

	for(SBWindowContext *context in [MSHookIvar<SBWindowContextManager*>([self.application mainScreenContextHostManager], "_contextManager") contextsForScreen:[UIScreen mainScreen]]){
		[contextIDs addObject:@([context identifier])];
	}

	return contextIDs;
}

@end
