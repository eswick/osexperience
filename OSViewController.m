#import "OSViewController.h"
#import "missioncontrol/OSPaneThumbnail.h"


@implementation OSViewController
@synthesize slider = _slider;
@synthesize dock = _dock;
@synthesize iconContentView = _iconContentView;
@synthesize launchpadActive = _launchpadActive;
@synthesize launchpadAnimating = _launchpadAnimating;
@synthesize missionControlActive = _missionControlActive;
@synthesize missionControlAnimating = _missionControlAnimating;
@synthesize switcherBackgroundView = _switcherBackgroundView;
@synthesize pinchInGesture = _pinchInGesture;
@synthesize pinchOutGesture = _pinchOutGesture;
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

    self.pinchInGesture = [[OSPinchGestureRecognizer alloc] initWithTarget:self action:@selector(handlePinchGesture:)];
    self.pinchInGesture.minimumNumberOfTouches = 5;
    self.pinchInGesture.type = OSPinchGestureRecognizerTypeInwards;


    self.pinchOutGesture = [[OSPinchGestureRecognizer alloc] initWithTarget:self action:@selector(handlePinchGesture:)];
    self.pinchOutGesture.minimumNumberOfTouches = 5;
    self.pinchOutGesture.type = OSPinchGestureRecognizerTypeOutwards;

    [self.pinchOutGesture release];
    [self.pinchInGesture release];
    return self;
}


- (void)setDockPercentage:(float)percentage{

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


/*----- Mission Control -------*/

- (void)setMissionControlActive:(BOOL)active{
    _missionControlActive = active;

    CPDistributedMessagingCenter *messagingCenter;
    messagingCenter = [CPDistributedMessagingCenter centerNamed:@"com.eswick.osexperience.backboardserver"];

    if(active){
        [messagingCenter sendMessageName:@"setMissionControlActivated" userInfo:nil];
    }else{
        [messagingCenter sendMessageName:@"setMissionControlDeactivated" userInfo:nil];
    }
}

- (void)setMissionControlActive:(BOOL)active animated:(BOOL)animated{

    if(active){

        //self.tempView.frame = [self missionControlWindowConstraints]; //(Visualize missionControlWindowConstraints)

        for(OSPaneThumbnail *thumbnail in [[[OSThumbnailView sharedInstance] wrapperView] subviews]){
            [thumbnail updateImage];
        }
        [[UIApplication sharedApplication] setStatusBarHidden:true withAnimation:true];

        self.switcherBackgroundView.hidden = false;
        

        [[OSThumbnailView sharedInstance] setHidden:false];

        [[[OSSlider sharedInstance] panGestureRecognizer] setMinimumNumberOfTouches:1];

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
        [[[OSSlider sharedInstance] panGestureRecognizer] setMinimumNumberOfTouches:4];

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
            [[OSThumbnailView sharedInstance] setHidden:true];
        }


    }

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



    [self.view addGestureRecognizer:self.pinchInGesture];
    [self.view addGestureRecognizer:self.pinchOutGesture];


	self.iconContentView = [[OSIconContentView alloc] init];
	self.iconContentView.alpha = 0.0f;


    //UIView *stockWallpaperView = [[[objc_getClass("SBUIController") sharedInstance] wallpaperView] superview];
    //stockWallpaperView.hidden = true;
    //stockWallpaperView.alpha = 0.0f;
    //[self.iconContentView addSubview:stockWallpaperView];


	[self.view addSubview:self.iconContentView];
	self.launchpadActive = false;


	//self.dock = [[objc_getClass("SBIconController") sharedInstance] dock];
	//CGRect dockFrame = self.dock.frame;
	//dockFrame.origin.y = [[UIScreen mainScreen] bounds].size.height - dockFrame.size.height;
	//[self.dock setFrame:dockFrame];
	//[self.view addSubview:self.dock];


    self.tempView = [[UIView alloc] init];
    self.tempView.backgroundColor = [UIColor greenColor];
    self.tempView.alpha = 0.25;
    [self.view insertSubview:self.tempView belowSubview:[OSSlider sharedInstance]]; //(Visualize missionControlWindowConstraints)


    self.missionControlAnimating = false;
    self.missionControlActive = false;

    [self.view release];
    [self.switcherBackgroundView release];
    [self.iconContentView release];


}

-(void)handlePinchGesture:(OSPinchGestureRecognizer*)gesture{

    if(gesture.state == UIGestureRecognizerStateRecognized){
        if(gesture.type == OSPinchGestureRecognizerTypeInwards){
            if(!self.launchpadIsActive)
                [self setLaunchpadActive:true animated:true];
        }else if(gesture.type == OSPinchGestureRecognizerTypeOutwards){
            if(self.launchpadIsActive)
                [self setLaunchpadActive:false animated:true];
        }
    }

}


- (void)menuButtonPressed{

	if(self.launchpadIsActive){
		[self setLaunchpadActive:false animated:true];
	}else{
		[self setLaunchpadActive:true animated:true];
	}

}


- (void)animateIconLaunch:(SBIconView*)iconView{
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
}



- (void)deactivateLaunchpadWithIconView:(SBIconView*)iconView{
    if(![iconView isInDock])
	   [self animateIconLaunch:iconView];

	[self setLaunchpadActive:false animated:true];
}


- (void)setLaunchpadActive:(BOOL)activated animated:(BOOL)animated{

	if(activated){
		[self.iconContentView prepareForDisplay];

        //if([[objc_getClass("SBIconController") sharedInstance] isShowingSearch])
          //  [[objc_getClass("SBIconController") sharedInstance] _showSearchKeyboardIfNecessary:true];

		if(animated){

			if(self.launchpadIsAnimating)
				return;

			self.iconContentView.alpha = 0.0f;
        	self.iconContentView.contentView.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.90f, 0.90f);

            self.launchpadAnimating = true;
            self.launchpadActive = true;

        	[UIView animateWithDuration:0.25 delay:0.0 options: UIViewAnimationOptionCurveEaseInOut animations:^{

                [self setDockPercentage:0.0];
                self.iconContentView.contentView.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1, 1);
                self.iconContentView.alpha = 1.0f;

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

			self.iconContentView.alpha = 1.0f;
        	self.iconContentView.contentView.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1.0f, 1.0f);

        	[UIView animateWithDuration:0.25 delay:0.0 options: UIViewAnimationOptionCurveEaseInOut animations:^{
                [[OSSlider sharedInstance] updateDockPosition];
                self.iconContentView.contentView.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.90f, 0.90f);
                self.iconContentView.alpha = 0.0f;
            } completion:^(BOOL finished){
                self.iconContentView.contentView.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1.0f, 1.0f);
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
}

-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation{
	return true;
}





-(void)dealloc{
    [self.view release];
    [self.iconContentView release];
    [self.switcherBackgroundView release];
    [self.pinchInGesture release];
    [self.pinchOutGesture release];
    [super dealloc];
}


@end