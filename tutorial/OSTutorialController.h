#import "../include.h"

typedef enum{
	OSTutorialStepIntro = 1,
	OSTutorialStepMenuBar,
	OSTutorialStepSnap,
	OSTutorialStepRotate,
	OSTutorialStepThankYou,
} OSTutorialStep;

@interface OSTutorialController : NSObject

@property (retain) UIView *view;
@property (retain) UIToolbar *windowBar;
@property (readwrite) BOOL inProgress;
@property (readwrite) OSTutorialStep currentStep;
@property (retain) NSMutableArray *circleViews;
@property (readwrite) BOOL shouldStopAnimation;
@property (retain) UILabel *instructionLabel;
@property (assign) UIBarButtonItem *contractButton;
@property (retain) UIView *appView;
@property (assign) CGPoint grabPoint;
@property (assign) BOOL showingLeftSnapIndicator;
@property (retain) UIView *snapIndicator;
@property (assign) BOOL snapped;

+ (id)sharedInstance;

- (void)beginTutorial;

- (void)handleUpGesture;
- (void)handleDownGesture;

- (BOOL)allowSystemGestureType:(SBSystemGestureType)type atLocation:(struct CGPoint)arg2;
- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration;

@end