#import "CGPointExtension.h"



CGFloat CGPointDistance(const CGPoint v1, const CGPoint v2){
	return hypotf(v1.x - v2.x, v1.y - v2.y);
}