#import "OSTutorialController.h"
#import "../include.h"
#import "../explorer/CGPointExtension.h"
#import "../OSPreferences.h"

#define snapMargin [prefs SNAP_MARGIN]

@implementation OSTutorialController

+ (id)sharedInstance{
    static OSTutorialController *_sharedController;

    if (_sharedController == nil)
    {
        _sharedController = [[self alloc] init];
    }

    return _sharedController;
}

- (id)init{

	if(![super init])
		return nil;




	return self;
}

- (void)beginTutorial{

	self.view = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
	self.view.backgroundColor = [UIColor blackColor];

	[[UIApp keyWindow] addSubview:self.view];
	[[%c(SBBacklightController) sharedInstance] preventIdleSleep];
	[[%c(SBBacklightController) sharedInstance] cancelLockScreenIdleTimer];


	self.systemGesturesOriginallyEnabled = [[NSUserDefaults standardUserDefaults] boolForKey:@"SBUseSystemGestures"];
	[[NSUserDefaults standardUserDefaults] setBool:true forKey:@"SBUseSystemGestures"];
	[UIApp userDefaultsDidChange:@"SBUseSystemGestures"];

	[UIApp setStatusBarHidden:YES withAnimation:UIStatusBarAnimationSlide];

	self.snapIndicator = [[UIView alloc] init];
	self.snapIndicator.backgroundColor = [UIColor grayColor];
	self.snapIndicator.alpha = 0.5;
	self.snapIndicator.layer.borderColor = [[UIColor whiteColor] CGColor];
	self.snapIndicator.layer.borderWidth = 1;
	self.snapIndicator.hidden = true;
	[self.view addSubview:self.snapIndicator];
	[self.snapIndicator release];

	self.inProgress = true;
	self.currentStep = 0;

	[self nextStep];

}

- (void)endTutorial{

	[UIView animateWithDuration:0.75 delay:0  options:UIViewAnimationOptionCurveEaseIn animations:^{
		self.view.alpha = 0;
	} completion:^(BOOL finished){

	}];

	[[NSUserDefaults standardUserDefaults] setBool:self.systemGesturesOriginallyEnabled forKey:@"SBUseSystemGestures"];
	[UIApp userDefaultsDidChange:@"SBUseSystemGestures"];

	[[%c(SBBacklightController) sharedInstance] allowIdleSleep];
	[[%c(SBBacklightController) sharedInstance] resetLockScreenIdleTimer];

	self.inProgress = false;

	[[OSPreferences sharedInstance] setTUTORIAL_SHOWN:true];

}

- (void)nextStep{
	self.currentStep++;
	[self beginStep:self.currentStep];
}

- (void)beginStep:(OSTutorialStep)step{
	switch(step){
		case OSTutorialStepIntro: [self beginIntroStep]; break;
		case OSTutorialStepMenuBar: [self beginMenuBarStep]; break;
		case OSTutorialStepSnap: [self beginSnapStep]; break;
		case OSTutorialStepRotate: [self beginRotateStep]; break;
		case OSTutorialStepThankYou: [self beginThankYouStep]; break;
		default: break;
	}
}

/* ====== Tutorial Steps ====== */

- (void)beginThankYouStep{

	NSDictionary *thankyous = [NSDictionary dictionaryWithContentsOfFile:@"/Library/Application Support/OS Experience/thankyou.plist"];

	UILabel *intro = [[UILabel alloc] init];

	intro.numberOfLines = 0;
	intro.textAlignment = NSTextAlignmentCenter;
	intro.text = @"I want to personally thank the following people. Without your advice and support, this would not have been possible.";
	intro.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:30];
	intro.textColor = [UIColor whiteColor];
	CGRect frame = CGRectZero;
	frame.size = [intro.text sizeWithFont:intro.font constrainedToSize:self.view.frame.size lineBreakMode:NSLineBreakByTruncatingTail];
	intro.frame = frame;

	intro.center = CGPointMake(self.view.bounds.size.width / 2, self.view.bounds.size.height / 6);
	intro.alpha = 0;

	[self.view addSubview:intro];

	int index = 1;

	for(NSString *name in [thankyous objectForKey:@"names"]){
		UILabel *nameLabel = [[UILabel alloc] init];
		nameLabel.text = name;
		nameLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:30];
		nameLabel.textColor = [UIColor whiteColor];
		CGRect frame = CGRectZero;
		frame.size = [nameLabel.text sizeWithFont:nameLabel.font constrainedToSize:self.view.frame.size lineBreakMode:NSLineBreakByTruncatingTail];
		nameLabel.frame = frame;
		nameLabel.center = CGPointMake(self.view.bounds.size.width / 2, intro.frame.origin.y + intro.frame.size.height + ((nameLabel.frame.size.height + 5) * index) + 30);
		nameLabel.alpha = 0;

		[self.view addSubview:nameLabel];

		index++;
	}

	for(int i = 0; i < self.view.subviews.count; i++){
		[UIView animateWithDuration:0.75 delay:i * 0.75 options:UIViewAnimationOptionCurveEaseIn animations:^{

			[[self.view.subviews objectAtIndex:i] setAlpha:1];

		} completion:^(BOOL finished){

		}];
	}

	dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (index * 0.75 + 5) * NSEC_PER_SEC), dispatch_get_main_queue(), ^{

		[UIView animateWithDuration:0.75 delay:0  options:UIViewAnimationOptionCurveEaseIn animations:^{
			for(UIView *subview in self.view.subviews){
				[subview setAlpha:0];
			}
		} completion:^(BOOL finished){

		}];

	});

	dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (index * 0.75 + 5 + 2) * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
		UILabel *outro = [[UILabel alloc] init];

		outro.numberOfLines = 0;
		outro.textAlignment = NSTextAlignmentCenter;
		outro.text = @"Over the past year of development, I have put my\nheart and soul into OS Experience.\n\nI hope you enjoy it as much as I have.";
		outro.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:30];
		outro.textColor = [UIColor whiteColor];
		CGRect frame = CGRectZero;
		frame.size = [outro.text sizeWithFont:outro.font constrainedToSize:self.view.frame.size lineBreakMode:NSLineBreakByWordWrapping];
		outro.frame = frame;
		outro.center = CGPointMake(self.view.bounds.size.width / 2, self.view.bounds.size.height / 2);
		outro.alpha = 0;

		[self.view addSubview:outro];

		[UIView animateWithDuration:0.75 delay:0  options:UIViewAnimationOptionCurveEaseIn animations:^{
			outro.alpha = 1;
		} completion:^(BOOL finished){
			[UIView animateWithDuration:0.75 delay:5  options:UIViewAnimationOptionCurveEaseIn animations:^{
				outro.alpha = 0;
			} completion:^(BOOL finished){
				[self endTutorial];
			}];
		}];

	});



}


- (void)beginIntroStep{


	UILabel *welcome = [[UILabel alloc] init];
	welcome.text = @"Welcome to";
	welcome.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:30];
	welcome.textColor = [UIColor whiteColor];

	UILabel *ose = [[UILabel alloc] init];
	ose.text = @"OS Experience";
	ose.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:50];
	ose.textColor = [UIColor whiteColor];

	CGRect frame = CGRectZero;
	frame.size = [ose.text sizeWithFont:ose.font constrainedToSize:self.view.frame.size lineBreakMode:NSLineBreakByTruncatingTail];
	ose.frame = frame;

	frame.size = [welcome.text sizeWithFont:welcome.font constrainedToSize:self.view.frame.size lineBreakMode:NSLineBreakByTruncatingTail];
	welcome.frame = frame;

	ose.center = CGPointMake(self.view.bounds.size.width / 2, (self.view.bounds.size.height / 2) + (ose.frame.size.height / 2));
	welcome.center = CGPointMake(self.view.bounds.size.width / 2, (self.view.bounds.size.height / 2) - (ose.frame.size.height / 2));

	ose.alpha = 0;
	welcome.alpha = 0;

	[self.view addSubview:welcome];
	[self.view addSubview:ose];

	[UIView animateWithDuration:0.75 delay:7 options:UIViewAnimationOptionCurveEaseIn animations:^{
		welcome.alpha = 1;
	} completion:^(BOOL finished){

	}];

	[UIView animateWithDuration:0.75 delay:8 options:UIViewAnimationOptionCurveEaseIn animations:^{
		ose.alpha = 1;
	} completion:^(BOOL finished){
		[UIView animateWithDuration:0.75 delay:2 options:UIViewAnimationOptionCurveEaseIn animations:^{
			ose.alpha = 0;
			welcome.alpha = 0;
		} completion:^(BOOL finished){
			[ose removeFromSuperview];
			[welcome removeFromSuperview];
			[ose release];
			[welcome release];

			[self nextStep];
		}];
	}];


}

- (void)beginMenuBarStep{

	self.windowBar = [[UIToolbar alloc] init];
	self.windowBar.frame = CGRectMake(0, -44, self.view.frame.size.width, 44);

	/* Set up window bar items */
	NSMutableArray *items = [[NSMutableArray alloc] init];


	UIBarButtonItem *closeButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemStop target:self action:@selector(stopButtonPressed)];
	closeButton.enabled = false;

	UIBarButtonItem *title = [[UIBarButtonItem alloc] initWithTitle:@"Tutorial" style:UIBarButtonItemStylePlain target:nil action:nil];
	UIBarButtonItem *contractButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageWithContentsOfFile:@"/Library/Application Support/OS Experience/168-1.png"] style:UIBarButtonItemStylePlain target:self action:@selector(contractButtonPressed)];
	self.contractButton = contractButton;

	[items addObject:closeButton];
	[items addObject:[[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil] autorelease]];
	[items addObject:title];
	[items addObject:[[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil] autorelease]];
	[items addObject:contractButton];

	[self.windowBar setItems:items animated:false];
	[items release];

	[self.view addSubview:self.windowBar];
	[self.windowBar release];

	[title release];
	[contractButton release];
	[closeButton release];


	UIPanGestureRecognizer *panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanGesture:)];
	[title.view addGestureRecognizer:panRecognizer];

	UILongPressGestureRecognizer *rotateRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(expandButtonHeld:)];
	[self.contractButton.view addGestureRecognizer:rotateRecognizer];

	[rotateRecognizer release];
	[panRecognizer release];

	/* Set up circle views */
	self.circleViews = [[NSMutableArray alloc] init];
	float yindex = [[UIScreen mainScreen] bounds].size.height / 2;
	for(int i = 0; i < 4; i++){
		if(i == 1)
			yindex -= 50;
		else if(i == 2)
			yindex += 25;
		else if(i == 3)
			yindex += 25;

		UIView *circleView = [[UIView alloc] initWithFrame:CGRectMake((100 * i) + ([[UIScreen mainScreen] bounds].size.width / 2) - 200 + (100 / 4), 0 + yindex, 35, 35)];
		circleView.layer.cornerRadius = circleView.frame.size.height / 2;
		circleView.backgroundColor = [UIColor whiteColor];

		[self.view addSubview:circleView];
		[self.circleViews addObject:circleView];

		[circleView release];
	}

	[self.circleViews release];

	/* Set up label */
	self.instructionLabel = [[UILabel alloc] init];
	self.instructionLabel.text = @"Open the menu bar.";
	self.instructionLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:50];
	self.instructionLabel.textColor = [UIColor whiteColor];
	self.instructionLabel.alpha = 0;

	CGRect frame = CGRectZero;
	frame.size = [self.instructionLabel.text sizeWithFont:self.instructionLabel.font constrainedToSize:self.view.frame.size lineBreakMode:NSLineBreakByTruncatingTail];
	self.instructionLabel.frame = frame;
	self.instructionLabel.center = CGPointMake(self.view.bounds.size.width / 2, self.view.bounds.size.height / 4);

	[self.view addSubview:self.instructionLabel];
	[self.instructionLabel release];

	/* Animate label in */
	[UIView animateWithDuration:0.5 delay:0.25 options:UIViewAnimationOptionCurveEaseInOut animations:^{
		self.instructionLabel.alpha = 1;
	}completion:^(BOOL finished){

	}];

	/* Run slide down animation */
	for(UIView *circleView in self.circleViews){
		CGRect frame = circleView.frame;
		frame.origin.y += [[UIScreen mainScreen] bounds].size.height;
		circleView.frame = frame;
		circleView.alpha = 0;
	}

	self.shouldStopAnimation = false;

	[self runMenuOpenAnimation];


}

- (void)runMenuOpenAnimation{
	for(UIView *circleView in self.circleViews){
		CGRect frame = circleView.frame;
		frame.origin.y -= [[UIScreen mainScreen] bounds].size.height;
		circleView.frame = frame;
	}

	[UIView animateWithDuration:0.5 delay:0.25 options:UIViewAnimationOptionCurveEaseInOut animations:^{
		for(UIView *circleView in self.circleViews){
			circleView.alpha = 1;
		}
	}completion:^(BOOL finished){
		[UIView animateWithDuration:2 delay:0.25 options:UIViewAnimationOptionCurveEaseInOut animations:^{
			for(UIView *circleView in self.circleViews){
				CGRect frame = circleView.frame;
				frame.origin.y += [[UIScreen mainScreen] bounds].size.height;
				circleView.frame = frame;
				circleView.alpha = 0;
			}
		}completion:^(BOOL finished){
			if(!self.shouldStopAnimation)
				[self runMenuOpenAnimation];
		}];
	}];
}

- (void)menuBarStepDownGesture{


	CGRect frame = self.windowBar.frame;
	frame.origin.y = 0;

	[self setInstructionLabelText:@"Minimize the window."];

	self.shouldStopAnimation = true;
	[UIView animateWithDuration:0.25 delay:0.0 options:UIViewAnimationOptionCurveEaseIn animations:^{
		self.windowBar.frame = frame;
	}completion:^(BOOL finished){

		[UIView animateWithDuration:0.5 delay:0.25 options:UIViewAnimationOptionAutoreverse | UIViewAnimationOptionRepeat | UIViewAnimationOptionCurveEaseInOut | UIViewAnimationOptionAllowUserInteraction animations:^{
			self.contractButton.view.alpha = 0.1;
		} completion:nil];
	}];


}

- (void)setInstructionLabelText:(NSString*)text{
	[UIView animateWithDuration:0.5 delay:0.25 options:UIViewAnimationOptionCurveEaseInOut animations:^{
		self.instructionLabel.alpha = 0;
	} completion:^(BOOL finished){

		CGSize constraints = self.view.frame.size;

		if(self.currentStep >= OSTutorialStepRotate){
			constraints.width = constraints.width / 2;
		}

		self.instructionLabel.text = text;

		CGRect frame = CGRectZero;
		frame.size = [self.instructionLabel.text sizeWithFont:self.instructionLabel.font constrainedToSize:constraints lineBreakMode:NSLineBreakByWordWrapping];
		self.instructionLabel.frame = frame;

		int heightDivisor = 4;
		if(self.currentStep >= OSTutorialStepSnap)
			heightDivisor = 5;

		if(self.currentStep >= OSTutorialStepRotate){
			self.instructionLabel.center = CGPointMake(self.view.bounds.size.width - (self.view.bounds.size.width / 4), self.view.bounds.size.height / 2);
		}else{
			self.instructionLabel.center = CGPointMake(self.view.bounds.size.width / 2, self.view.bounds.size.height / heightDivisor);
		}

		[UIView animateWithDuration:0.5 delay:0.25 options:UIViewAnimationOptionCurveEaseInOut animations:^{
			self.instructionLabel.alpha = 1;
		} completion:nil];
	}];


}

- (void)stopButtonPressed{

}

- (void)contractButtonPressed{

	if(self.currentStep != OSTutorialStepMenuBar)
		return;

	self.contractButton.enabled = false;
	[self.contractButton.view.layer removeAllAnimations];

	CGRect frame = self.view.frame;
	frame = CGRectApplyAffineTransform(frame, CGAffineTransformMakeScale(0.5, 0.5));

	self.appView = [[UIView alloc] initWithFrame:frame];
	self.appView.backgroundColor = [UIColor whiteColor];
	self.appView.center = CGPointMake(self.view.bounds.size.width / 2, (self.view.bounds.size.height / 2) + (self.appView.frame.size.height / 3));
	frame = self.appView.frame;

	self.appView.alpha = 0;
	self.appView.backgroundColor = [UIColor grayColor];

	[self.view addSubview:self.appView];

	[UIView animateWithDuration:0.5 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
		self.contractButton.view.alpha = 1;

		CGRect frame = self.windowBar.frame;

		frame.size.width = self.appView.frame.size.width;
		frame.origin = CGPointMake(self.appView.frame.origin.x, self.appView.frame.origin.y - frame.size.height);

		self.windowBar.frame = frame;

	}completion:^(BOOL finished){
		[UIView animateWithDuration:0.5 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
			self.appView.alpha = 1;
		}completion:nil];

		[self setInstructionLabelText:@"Rotate the device."];
		[self nextStep];
	}];


}


- (void)handlePanGesture:(UIPanGestureRecognizer*)gesture{

	if(!self.snapped || self.currentStep != OSTutorialStepSnap)
		return;

	if([gesture state] == UIGestureRecognizerStateBegan){
		self.grabPoint = [gesture locationInView:self.windowBar];
	}else if([gesture state] == UIGestureRecognizerStateChanged){
		CGRect frame = self.windowBar.frame;
		frame.origin = CGPointSub([gesture locationInView:self.view], self.grabPoint);
		if(frame.origin.y < 0)
			frame.origin.y = 0;
		self.windowBar.frame = frame;

		frame = self.appView.frame;
		frame.origin.y = self.windowBar.frame.origin.y + self.windowBar.frame.size.height;
		frame.origin.x = self.windowBar.frame.origin.x;

		self.appView.frame = frame;

	if([gesture locationInView:self.view].x < snapMargin){
			if(UIInterfaceOrientationIsLandscape([UIApp statusBarOrientation])){
				if(!self.showingLeftSnapIndicator){
					[self.view insertSubview:self.snapIndicator belowSubview:self.windowBar];
					[self setLeftSnapIndicatorVisible:true animated:true];
				}
			}
		}else{
			if(self.showingLeftSnapIndicator)
				[self setLeftSnapIndicatorVisible:false animated:true];
		}
	}else if([gesture state] == UIGestureRecognizerStateEnded && self.showingLeftSnapIndicator){

		[UIView animateWithDuration:0.25 delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^{

			self.windowBar.frame = CGRectMake(0, 0, self.snapIndicator.frame.size.width, self.windowBar.frame.size.height);

			CGRect frame = self.appView.frame;
			frame.origin.y = self.windowBar.frame.origin.y + self.windowBar.frame.size.height;
			frame.origin.x = self.windowBar.frame.origin.x;
			frame.size.height = self.snapIndicator.frame.size.height - self.windowBar.frame.size.height;
			frame.size.width = self.snapIndicator.frame.size.width;

			self.appView.frame = frame;
			self.shouldStopAnimation = true;

		} completion:^(BOOL finished){
			[self nextStep];
		}];

		[self setLeftSnapIndicatorVisible:false animated:true];
	}


}

- (void)setLeftSnapIndicatorVisible:(BOOL)visible animated:(BOOL)animated{


	self.showingLeftSnapIndicator = visible;

	if(visible){
		self.snapIndicator.hidden = false;
		self.snapIndicator.frame = CGRectMake(0, self.view.bounds.size.height / 2, 0, 0);

		void (^snapToFrame)(void) = ^{
			self.snapIndicator.frame = CGRectMake(0, 0, self.view.bounds.size.width / 2, self.view.bounds.size.height);
		};

		if(animated){
			[UIView animateWithDuration:0.25
				delay:0.0
				options:UIViewAnimationOptionCurveEaseOut
				animations:snapToFrame
				completion:nil
			];
		}else{
			snapToFrame();
		}
	}else{

		if(animated){
			[UIView animateWithDuration:0.25
				delay:0.0
				options:UIViewAnimationOptionCurveEaseOut
				animations:^{
					self.snapIndicator.alpha = 0;
				}
				completion:^(BOOL finished){
					self.snapIndicator.alpha = 0.5;
					self.snapIndicator.hidden = true;
				}];
		}else{
			self.snapIndicator.hidden = true;
		}
	}


}


- (void)beginSnapStep{
}

- (void)runSnapInstruction:(UIView*)circleView{
	CGRect frame = circleView.frame;
	frame.origin = CGPointMake(self.windowBar.frame.origin.x + (self.windowBar.frame.size.width / 2), self.windowBar.frame.origin.y + (self.windowBar.frame.size.height / 2));

	circleView.frame = frame;
	circleView.alpha = 0;

	[UIView animateWithDuration:0.5 delay:0.25 options:UIViewAnimationOptionCurveEaseInOut animations:^{
		circleView.alpha = 1;
	}completion:^(BOOL finished){
		[UIView animateWithDuration:2 delay:0.25 options:UIViewAnimationOptionCurveEaseInOut animations:^{
			CGRect frame = circleView.frame;
			frame.origin.x = -(circleView.frame.size.width / 2);
			frame.origin.y = self.view.bounds.size.height / 2;

			circleView.frame = frame;
		}completion:^(BOOL finished){
			[UIView animateWithDuration:0.25 delay:0.25 options:UIViewAnimationOptionCurveEaseInOut animations:^{
				circleView.alpha = 0;
			}completion:^(BOOL finished){
				if(!self.shouldStopAnimation)
					[self runSnapInstruction:circleView];
			}];
		}];
	}];
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration{
	if(self.currentStep == OSTutorialStepSnap){

		if(!UIInterfaceOrientationIsLandscape(toInterfaceOrientation) || self.snapped == true){
			return;
		}

		int rotationDegrees;

		switch(toInterfaceOrientation){
			case UIInterfaceOrientationPortrait:
				rotationDegrees = 0;
				break;
			case UIInterfaceOrientationPortraitUpsideDown:
				rotationDegrees = 180;
				break;
			case UIInterfaceOrientationLandscapeLeft:
				rotationDegrees = 270;
				break;
			case UIInterfaceOrientationLandscapeRight:
				rotationDegrees = 90;
				break;
		}


		self.view.transform = CGAffineTransformMakeRotation(DegreesToRadians(rotationDegrees));

		CGRect frame = self.view.frame;
		float height = frame.size.height;

		frame.size.height = frame.size.width;
		frame.size.width = height;
		frame.origin = CGPointZero;

		self.view.frame = frame;

		self.appView.center = CGPointMake(self.view.bounds.size.width / 2, (self.view.bounds.size.height / 2) + (self.appView.frame.size.height / 3));
		self.instructionLabel.center = CGPointMake(self.view.bounds.size.width / 2, self.view.bounds.size.height / 10);

		frame = self.windowBar.frame;
		frame.size.width = self.appView.frame.size.width;
		frame.origin = CGPointMake(self.appView.frame.origin.x, self.appView.frame.origin.y - frame.size.height);

		self.windowBar.frame = frame;

		[self setInstructionLabelText:@"Snap the app."];
		self.snapped = true;

		self.shouldStopAnimation = false;
		[self.view addSubview:[self.circleViews firstObject]];
		[self runSnapInstruction:[self.circleViews firstObject]];

	}
}

- (void)beginRotateStep{


	self.contractButton.enabled = true;

	self.instructionLabel.numberOfLines = 0;
	self.instructionLabel.textAlignment = NSTextAlignmentCenter;
	[self setInstructionLabelText:@"Hold the arrows\nto rotate."];

	[UIView animateWithDuration:0.5 delay:0.25 options:UIViewAnimationOptionAutoreverse | UIViewAnimationOptionRepeat | UIViewAnimationOptionCurveEaseInOut | UIViewAnimationOptionAllowUserInteraction animations:^{
		self.contractButton.view.alpha = 0.1;
	} completion:nil];


}

- (void)expandButtonHeld:(UIGestureRecognizer*)recognizer{


	if(self.currentStep != OSTutorialStepRotate || [recognizer state] != UIGestureRecognizerStateBegan)
		return;

	[UIView animateWithDuration:0.5 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
		CGRect frame = self.appView.frame;
		frame.size.width = self.view.frame.size.width;
		self.appView.frame = frame;

		frame = self.windowBar.frame;
		frame.size.width = self.view.frame.size.width;
		self.windowBar.frame = frame;
	}completion:^(BOOL finished){
		[UIView animateWithDuration:1 delay:1 options:UIViewAnimationOptionCurveEaseInOut animations:^{
			self.appView.alpha = 0;
			self.instructionLabel.alpha = 0;
			self.windowBar.alpha = 0;
		} completion:^(BOOL finished){
			if(finished){
				for(UIView *view in self.circleViews){
					[view removeFromSuperview];
				}

				[self.appView removeFromSuperview];
				[self.windowBar removeFromSuperview];
				[self.instructionLabel removeFromSuperview];
				[self nextStep];
			}
		}];
	}];


}

- (void)handleDownGesture{
	switch(self.currentStep){
		case OSTutorialStepMenuBar:{
			[self menuBarStepDownGesture];
		}
		default: break;
	}
}

- (void)handleUpGesture{

}

- (BOOL)allowSystemGestureType:(SBSystemGestureType)type atLocation:(struct CGPoint)arg2{

	if(type & SBSystemGestureTypeShowControlCenter)
		return true;

	if(type & SBSystemGestureTypeSwitcher)
		return true;

	if(type & SBSystemGestureTypeSwitcher && self.currentStep == OSTutorialStepMenuBar){
		return true;
	}

	return false;
}


- (void)dealloc{
	[self.view release];
	[self.windowBar release];

	[super dealloc];
}



@end
