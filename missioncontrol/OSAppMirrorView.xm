#import "OSAppMirrorView.h"
#import "../include.h"
#import <substrate.h>
#import <objcipc/objcipc.h>


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
	float scale = (UIInterfaceOrientationIsPortrait([UIApp statusBarOrientation]) ? self.bounds.size.width : self.bounds.size.height) / ([[UIScreen mainScreen] bounds].size.width * [[UIScreen mainScreen] scale]);
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

	for(SBProxyRemoteView *remoteView in self.subviews){
		CGAffineTransform transform = CGAffineTransformMakeRotation(DegreesToRadians(rotationDegree)); 
		transform = CGAffineTransformScale(transform, scale, scale);
		remoteView.transform = CGAffineTransformTranslate(transform, translationx, translationy);
	}
}

- (void)setRotation:(int)rotationDegree{
	for(SBProxyRemoteView *remoteView in self.subviews){
		float scale = (UIInterfaceOrientationIsPortrait([UIApp statusBarOrientation]) ? self.bounds.size.width : self.bounds.size.height) / ([[UIScreen mainScreen] bounds].size.width * [[UIScreen mainScreen] scale]);

		CGAffineTransform transform = CGAffineTransformMakeRotation(DegreesToRadians(rotationDegree)); 
		remoteView.transform = CGAffineTransformScale(transform, scale, scale);
	}
}

- (void)addRemoteViews{
	[self removeRemoteViews];
	
	for(NSNumber *contextID in [self getContextList]){
		SBProxyRemoteView *remoteView = [[%c(SBProxyRemoteView) alloc] init];

		[remoteView connectToContextID:[contextID intValue] forIdentifier:@"com.eswick.osexperience" application:self.application];

		[self addSubview:remoteView];
		[remoteView release];
	}
}

- (void)removeRemoteViews{
	for(SBProxyRemoteView *remoteView in self.subviews){
		[remoteView disconnect];
		[remoteView removeFromSuperview];
	}
}

- (NSArray*)getContextList{

	NSDictionary *contexts = [OBJCIPC sendMessageToAppWithIdentifier:self.application.displayIdentifier messageName:@"com.eswick.osexperience.reportMirrorContextList" dictionary:@{}];

	return [contexts objectForKey:@"contexts"];
}

@end

%ctor{
	if([OBJCIPC isApp]){
		[OBJCIPC registerIncomingMessageFromSpringBoardHandlerForMessageName:@"com.eswick.osexperience.reportMirrorContextList"  handler:^NSDictionary *(NSDictionary *message) {
    		NSMutableArray *contextIDs = [NSMutableArray array];
    	
    		for(UIWindow *window in UIApp.windows){
    			[contextIDs addObject:@([window _contextId])];
    		}

    		return @{@"contexts" : contextIDs};
		}];
	}
}