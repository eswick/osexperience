#import <UIKit/UIGestureRecognizerSubclass.h>
#import "explorer/CGPointExtension.h"


typedef enum{
	OSPinchGestureRecognizerTypeInwards,
	OSPinchGestureRecognizerTypeOutwards
} OSPinchGestureRecognizerType;

@interface OSPinchGestureRecognizer : UIGestureRecognizer{
	int _minimumNumberOfTouches;
	CGPoint _centroid;
	float _cumulativeStartingDistance;
	OSPinchGestureRecognizerType _type;
}
@property (nonatomic, readwrite) int minimumNumberOfTouches;
@property (nonatomic, readwrite) CGPoint centroid;
@property (nonatomic, readwrite) float cumulativeStartingDistance;
@property (nonatomic, readwrite) OSPinchGestureRecognizerType type;

- (void)reset;
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event;
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event;
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event;
- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event;


@end