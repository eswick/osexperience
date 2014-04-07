

@class SBApplication;

@interface OSAppMirrorView : UIView

@property (assign) SBApplication *application;

- (id)initWithApplication:(SBApplication*)application;
- (void)addRemoteViews;
- (void)removeRemoteViews;

@end