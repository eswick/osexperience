#import "OSViewController.h"
#import "missioncontrol/OSPaneThumbnail.h"
#import <mach_verify/mach_verify.h>
#import "tutorial/OSTutorialController.h"

#define LP_VARIANCE 0.1

@implementation OSViewController
@synthesize slider = _slider;
@synthesize dock = _dock;
@synthesize iconContentView = _iconContentView;
@synthesize launchpadActive = _launchpadActive;
@synthesize launchpadAnimating = _launchpadAnimating;
@synthesize missionControlActive = _missionControlActive;
@synthesize missionControlAnimating = _missionControlAnimating;
@synthesize switcherBackgroundView = _switcherBackgroundView;
@synthesize tempView = _tempView;


+ (id)sharedInstance{
    static OSViewController *_sharedController;

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


- (void)setDockPercentage:(float)percentage{

    if(percentage < 0)
        return;

    if((self.launchpadIsActive && !self.launchpadIsAnimating) || (self.missionControlIsActive && !self.missionControlIsAnimating))
        return;

    BOOL isPortrait = false;

    if([[UIApplication sharedApplication] statusBarOrientation] == UIInterfaceOrientationPortrait || [[UIApplication sharedApplication] statusBarOrientation] == UIInterfaceOrientationPortraitUpsideDown){
        isPortrait = true;
    }

    CGRect dockFrame = self.dock.frame;
    float dockShownY = (isPortrait ? self.view.frame.size.height : self.view.frame.size.width) - dockFrame.size.height;
    dockFrame.origin.y = dockShownY + (percentage * dockFrame.size.height);

    [self.dock setFrame:dockFrame];

}

- (void)handleUpGesture{
    VERIFY_START(handleUpGesture);

    if([[OSTutorialController sharedInstance] inProgress]){
        [[OSTutorialController sharedInstance] handleUpGesture];
        return;
    }

    if([[OSViewController sharedInstance] launchpadIsAnimating] || [[OSViewController sharedInstance] launchpadIsActive])
        return;

    if([[[OSSlider sharedInstance] currentPane] isKindOfClass:[OSAppPane class]]){
        if([(OSAppPane*)[[OSSlider sharedInstance] currentPane] windowBarIsOpen]){
            [(OSAppPane*)[[OSSlider sharedInstance] currentPane] setWindowBarHidden];
            return;
        }
    }else if([[[OSSlider sharedInstance] currentPane] isKindOfClass:[OSDesktopPane class]]){
        if(!self.desktopShowsDock){
            self.desktopShowsDock = true;
            [UIView animateWithDuration:0.25 delay:0.0 options: UIViewAnimationOptionCurveEaseInOut animations:^{
                [[OSSlider sharedInstance] updateDockPosition];
            }completion:nil];
            return;
        }
    }

    if(![self missionControlIsActive]){
        [self setMissionControlActive:true animated:true];
        return;
    }

    VERIFY_STOP(handleUpGesture);
}

- (void)handleDownGesture{
    VERIFY_START(handleDownGesture);

    if([[OSTutorialController sharedInstance] inProgress]){
        [[OSTutorialController sharedInstance] handleDownGesture];
        return;
    }

    if([[OSViewController sharedInstance] launchpadIsAnimating] || [[OSViewController sharedInstance] launchpadIsActive])
        return;

    if([self missionControlIsActive]){
        [self setMissionControlActive:false animated:true];
        return;
    }else if([[[OSSlider sharedInstance] currentPane] isKindOfClass:[OSAppPane class]]){
        [(OSAppPane*)[[OSSlider sharedInstance] currentPane] setWindowBarVisible];
    }else if([[[OSSlider sharedInstance] currentPane] isKindOfClass:[OSDesktopPane class]]){
        self.desktopShowsDock = false;
        [UIView animateWithDuration:0.25 delay:0.0 options: UIViewAnimationOptionCurveEaseInOut animations:^{
            [[OSSlider sharedInstance] updateDockPosition];
        }completion:nil];
    }

    VERIFY_STOP(handleDownGesture);
}


/*----- Mission Control -------*/

- (void)setMissionControlActive:(BOOL)active{
    VERIFY_START(setMissionControlActive);

    _missionControlActive = active;

    CPDistributedMessagingCenter *messagingCenter;
    messagingCenter = [CPDistributedMessagingCenter centerNamed:@"com.eswick.osexperience.backboardserver"];

    if(active){
        [messagingCenter sendMessageName:@"setMissionControlActivated" userInfo:nil];
    }else{
        [messagingCenter sendMessageName:@"setMissionControlDeactivated" userInfo:nil];
    }

    VERIFY_STOP(setMissionControlActive);
}

- (void)setMissionControlActive:(BOOL)active animated:(BOOL)animated{
    VERIFY_START(setMissionControlActive$animated);

    if(self.missionControlIsActive == active)
        return;

    if(active){
        
        [[UIApplication sharedApplication] setStatusBarHidden:true withAnimation:true];

        self.switcherBackgroundView.hidden = false;
        [[OSSlider sharedInstance] setBackgroundColor:[UIColor clearColor]];

        [[OSThumbnailView sharedInstance] setHidden:false];

        [[OSSlider sharedInstance] addGestureRecognizer:[[OSSlider sharedInstance] panGestureRecognizer]];

        if(animated){

            self.missionControlAnimating = true;
            self.missionControlActive = true;

            CGRect frame = [[OSSlider sharedInstance] frame];
            frame.origin.y = [[OSThumbnailView sharedInstance] frame].size.height;
            [[OSSlider sharedInstance] setFrame:frame];

            for(OSPane *pane in [[OSPaneModel sharedInstance] panes]){
                CGRect frame = pane.frame;
                frame.origin.y = 0 - [[OSThumbnailView sharedInstance] frame].size.height;
                [pane setFrame:frame];
            }

            for(OSPane *pane in [[OSPaneModel sharedInstance] panes]){
                [pane missionControlWillActivate];
            }

            for(OSPaneThumbnail *thumbnail in [[[OSThumbnailView sharedInstance] wrapperView] subviews]){
                [thumbnail prepareForDisplay];
            }

            [UIView animateWithDuration:0.25 delay:0.0 options: UIViewAnimationOptionCurveEaseInOut animations:^{
                [self setDockPercentage:0.0];

                for(OSPane *pane in [[OSPaneModel sharedInstance] panes]){
                    pane.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.5, 0.5);
                    pane.userInteractionEnabled = false;
                }

                [OSMCWindowLayoutManager layoutWindows];

            } completion:^(BOOL finished){
                self.missionControlAnimating = false;
                [self.view insertSubview:[OSThumbnailView sharedInstance] belowSubview:self.slider];
            }];


        }else{
            self.missionControlActive = true;

            CGRect frame = [[OSSlider sharedInstance] frame];
            frame.origin.y = [[OSThumbnailView sharedInstance] frame].size.height;
            [[OSSlider sharedInstance] setFrame:frame];

            for(OSPane *pane in [[OSPaneModel sharedInstance] panes]){
                CGRect frame = pane.frame;
                frame.origin.y = 0 - [[OSThumbnailView sharedInstance] frame].size.height;
                [pane setFrame:frame];
            }

            for(OSPane *pane in [[OSPaneModel sharedInstance] panes]){
                [pane missionControlWillActivate];
            }

            for(OSPaneThumbnail *thumbnail in [[[OSThumbnailView sharedInstance] wrapperView] subviews]){
                [thumbnail prepareForDisplay];
            }

            [self setDockPercentage:0.0];

            for(OSPane *pane in [[OSPaneModel sharedInstance] panes]){
                pane.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.5, 0.5);
                pane.userInteractionEnabled = false;
            }

            [OSMCWindowLayoutManager layoutWindows];

            [self.view insertSubview:[OSThumbnailView sharedInstance] belowSubview:self.slider];
        }
    }else{
        [self.view insertSubview:[OSThumbnailView sharedInstance] belowSubview:self.slider];
        [[OSSlider sharedInstance] removeGestureRecognizer:[[OSSlider sharedInstance] panGestureRecognizer]];

        if(animated){

            self.missionControlAnimating = true;
            self.missionControlActive = false;

            [UIView animateWithDuration:0.25 delay:0.0 options: UIViewAnimationOptionCurveEaseInOut animations:^{
                for(OSPane *pane in [[OSPaneModel sharedInstance] panes]){
                    pane.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1.0, 1.0);
                    pane.userInteractionEnabled = true;

                    CGRect frame = [pane frame];
                    frame.origin.y = 0;
                    [pane setFrame:frame];

                    frame = [[OSSlider sharedInstance] frame];
                    frame.origin.y = 0;
                    [[OSSlider sharedInstance] setFrame:frame];

                    [pane missionControlWillDeactivate];
                }
                [[OSSlider sharedInstance] updateDockPosition];

            } completion:^(BOOL finished){
                for(OSDesktopPane *desktopPane in [[OSPaneModel sharedInstance] panes]){
                    if(![desktopPane isKindOfClass:[OSDesktopPane class]])
                        continue;
                    [desktopPane missionControlDidDeactivate];
                }
                self.switcherBackgroundView.hidden = true;
                [[OSSlider sharedInstance] setBackgroundColor:[UIColor blackColor]];

                for(OSPaneThumbnail *thumbnail in [[[OSThumbnailView sharedInstance] wrapperView] subviews]){
                    [thumbnail didHide];
                }

                [[OSThumbnailView sharedInstance] setHidden:true];
                self.missionControlAnimating = false;
            }];


        }else{
            self.missionControlActive = false;

            for(OSPane *pane in [[OSPaneModel sharedInstance] panes]){
                pane.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1.0, 1.0);
                pane.userInteractionEnabled = true;

                CGRect frame = [pane frame];
                frame.origin.y = 0;
                [pane setFrame:frame];

                frame = [[OSSlider sharedInstance] frame];
                frame.origin.y = 0;
                [[OSSlider sharedInstance] setFrame:frame];

                [pane missionControlWillDeactivate];
            }
            [[OSSlider sharedInstance] updateDockPosition];

            for(OSDesktopPane *desktopPane in [[OSPaneModel sharedInstance] panes]){
                if(![desktopPane isKindOfClass:[OSDesktopPane class]])
                    continue;
                [desktopPane missionControlDidDeactivate];
            }

            self.switcherBackgroundView.hidden = true;
            [[OSSlider sharedInstance] setBackgroundColor:[UIColor blackColor]];

            for(OSPaneThumbnail *thumbnail in [[[OSThumbnailView sharedInstance] wrapperView] subviews]){
                [thumbnail didHide];
            }
            [[OSThumbnailView sharedInstance] setHidden:true];
        }

    }

    VERIFY_STOP(setMissionControlActive$animated);
}

- (CGRect)missionControlWindowConstraints{
    CGRect area = [[UIScreen mainScreen] bounds];

    if(!UIInterfaceOrientationIsPortrait([UIApp statusBarOrientation])){
        float width = area.size.width;
        area.size.width = area.size.height;
        area.size.height = width;
    }

    area = CGRectApplyAffineTransform(area, CGAffineTransformScale(CGAffineTransformIdentity, 0.95, 1));

    area.origin.y = [[OSThumbnailView sharedInstance] frame].size.height + windowConstraintsTopMargin;
    area.size.height = self.dock.frame.origin.y - area.origin.y - windowConstraintsBottomMargin;


    CGPoint center = self.view.center;
    if(!UIInterfaceOrientationIsPortrait([UIApp statusBarOrientation])){
        float x = center.x;
        center.x = center.y;
        center.y = x;
    }

    area.origin = CGPointMake(center.x - area.size.width / 2, area.origin.y);


    return area;
}

/*------------------------------*/


-(void)loadView{
    VERIFY_START(loadView);

	self.view = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];

    self.switcherBackgroundView = [[OSSwitcherBackgroundView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.switcherBackgroundView.hidden = true;
    [self.view addSubview:self.switcherBackgroundView];


    [self.view addSubview:[OSThumbnailView sharedInstance]];


	self.slider = [OSSlider sharedInstance];
	[self.view addSubview:self.slider];

	OSDesktopPane *desktopPane = [[OSDesktopPane alloc] init];
    [[OSPaneModel sharedInstance] addPaneToBack:desktopPane];
    [desktopPane release];


	self.iconContentView = [[OSIconContentView alloc] init];
	self.iconContentView.alpha = 0.0f;

	[self.view addSubview:self.iconContentView];
	self.launchpadActive = false;

    [self setLaunchpadVisiblePercentage:0.0];

    self.tempView = [[UIView alloc] init];
    self.tempView.backgroundColor = [UIColor greenColor];
    self.tempView.alpha = 0.25;
    [self.view insertSubview:self.tempView belowSubview:[OSSlider sharedInstance]]; //(Visualize missionControlWindowConstraints)


    self.missionControlAnimating = false;
    self.missionControlActive = false;

    [self.view release];
    [self.switcherBackgroundView release];
    [self.iconContentView release];

    self.desktopShowsDock = true;

    VERIFY_STOP(loadView);
}

- (void)menuButtonPressed{

	if(self.launchpadIsActive){
		[self setLaunchpadActive:false animated:true];
	}else{
		[self setLaunchpadActive:true animated:true];
	}

}

- (void)animateIconLaunch:(SBIconView*)iconView{
    VERIFY_START(animateIconLaunch);

	UIImageView *launchZoomView = [[UIImageView alloc] init];
	launchZoomView.image = [iconView iconImageSnapshot];

	CGRect zoomViewFrame;
	zoomViewFrame.origin = [iconView convertPoint:iconView.bounds.origin toView:self.view];
	zoomViewFrame.size = launchZoomView.image.size;

	[launchZoomView setFrame:zoomViewFrame];

	[self.view addSubview:launchZoomView];

	[UIView animateWithDuration:0.25 delay:0.0 options: UIViewAnimationOptionCurveEaseInOut animations:^{
        launchZoomView.transform = CGAffineTransformScale(CGAffineTransformIdentity, 2.0f, 2.0f);
        launchZoomView.alpha = 0.0f;
    }completion:^(BOOL finished){
    	[launchZoomView removeFromSuperview];
    	[launchZoomView release];
    }];

    VERIFY_STOP(animateIconLaunch);
}

- (void)deactivateLaunchpadWithIconView:(SBIconView*)iconView{
    if(![iconView isInDock])
	   [self animateIconLaunch:iconView];

	[self setLaunchpadActive:false animated:true];
}

- (void)setLaunchpadVisiblePercentage:(float)percentage{
    self._launchpadVisiblePercentage = percentage;

    float variance = LP_VARIANCE - (LP_VARIANCE * percentage);

    self.iconContentView.contentView.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1 + variance, 1 + variance);
    self.iconContentView.alpha = percentage;
}

- (void)setLaunchpadActive:(BOOL)activated animated:(BOOL)animated{
    VERIFY_START(setLaunchpadActive$animated);

	if(activated){
		[self.iconContentView prepareForDisplay];

        //if([[objc_getClass("SBIconController") sharedInstance] isShowingSearch])
          //  [[objc_getClass("SBIconController") sharedInstance] _showSearchKeyboardIfNecessary:true];

		if(animated){

            self.iconContentView.contentView.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1 + LP_VARIANCE, 1 + LP_VARIANCE);

			if(self.launchpadIsAnimating)
				return;

            self.launchpadAnimating = true;
            self.launchpadActive = true;

        	[UIView animateWithDuration:0.25 delay:0.0 options: UIViewAnimationOptionCurveEaseInOut animations:^{

                [self setDockPercentage:0.0];
                
                [self setLaunchpadVisiblePercentage:1];

            } completion:^(BOOL finished){
                self.launchpadAnimating = false;
                [[[objc_getClass("SBIconController") sharedInstance] contentView] addSubview:[[OSViewController sharedInstance] dock]];
                [(SpringBoard*)UIApp clearMenuButtonTimer];
            }];


    	}else{
            [self setDockPercentage:0.0];
    		self.iconContentView.alpha = 1.0f;
    		self.launchpadActive = true;
            [[[objc_getClass("SBIconController") sharedInstance] contentView] addSubview:[[OSViewController sharedInstance] dock]];
    	}

	}else{
        //[[objc_getClass("SBIconController") sharedInstance] _showSearchKeyboardIfNecessary:false];

		if(animated){

			if(self.launchpadIsAnimating)
				return;

            self.launchpadAnimating = true;
            self.launchpadActive = false;

            [[[OSViewController sharedInstance] view] addSubview:[[OSViewController sharedInstance] dock]];

        	[UIView animateWithDuration:0.25 delay:0.0 options: UIViewAnimationOptionCurveEaseInOut animations:^{
                [[OSSlider sharedInstance] updateDockPosition];
                [self setLaunchpadVisiblePercentage:0];
            } completion:^(BOOL finished){
                self.launchpadAnimating = false;
                [(SpringBoard*)UIApp clearMenuButtonTimer];
            }];


    	}else{
    		self.iconContentView.alpha = 0.0f;
    		self.launchpadActive = false;
            [[OSSlider sharedInstance] updateDockPosition];
            [[[OSViewController sharedInstance] view] addSubview:[[OSViewController sharedInstance] dock]];
    	}

	}

    VERIFY_STOP(setLaunchpadActive$animated);
}

-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation{
	return true;
}





-(void)dealloc{
    [self.view release];
    [self.iconContentView release];
    [self.switcherBackgroundView release];
    [super dealloc];
}


@end