#import "include.h"

@interface OSRemoteRenderLayer : CALayer{
	SBAppContextHostManager *_manager;
}
@property(nonatomic, retain) SBAppContextHostManager *manager;

@end