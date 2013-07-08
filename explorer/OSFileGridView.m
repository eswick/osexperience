//
//  OSFileGridView.m
//  
//
//  Created by Evan Swick on 6/16/13.
//
//

#import "OSFileGridView.h"

#define selectionDragViewOpacity 0.5

@implementation OSFileGridView
@synthesize selectionDragView = _selectionDragView;
@synthesize selectionDragViewStartPoint = _selectionDragViewStartPoint;




int marginSize = 25;
int iconSize = 72;


-(id)initWithDirectory:(NSString*)directory frame:(CGRect)frame{
    if(![super initWithFrame:frame]){
        return nil;
    }

    [self becomeFirstResponder];

    self.selectionDragView = [[UIView alloc] init];
    self.selectionDragView.backgroundColor = [UIColor grayColor];
    self.selectionDragView.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.selectionDragView.layer.borderWidth = 1.0f;
    self.selectionDragView.alpha = selectionDragViewOpacity;
    self.selectionDragView.hidden = true;
    [self addSubview:self.selectionDragView];
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGesture:)];
    tapGesture.numberOfTapsRequired = 1;
    [self addGestureRecognizer:tapGesture];

    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanGesture:)];
    panGesture.maximumNumberOfTouches = 1;
    [self addGestureRecognizer:panGesture];

    [self drawFiles];
    
    
    return self;
}


-(void)handlePanGesture:(UIPanGestureRecognizer *)gesture{

    if([gesture state] == UIGestureRecognizerStateChanged){

        [self.selectionDragView setFrame:CGRectFromCGPoints(self.selectionDragViewStartPoint, [gesture locationInView:self])];

        for(OSFileView *fileView in self.subviews){
            if(![fileView isKindOfClass:[OSFileView class]])
                continue;
            if(CGRectIntersectsRect(fileView.frame, self.selectionDragView.frame)){
                if([fileView selected] == false)
                    [fileView setSelected:true animated:false];
            }else{
                if([fileView selected] == true)
                    [fileView setSelected:false animated:false];
            }
        }

    }else if([gesture state] == UIGestureRecognizerStateBegan){

        [self bringSubviewToFront:self.selectionDragView];
        self.selectionDragView.alpha = selectionDragViewOpacity;
        self.selectionDragView.hidden = false;
        self.selectionDragViewStartPoint = [gesture locationInView:self];

    }else if([gesture state] == UIGestureRecognizerStateEnded){

        [UIView animateWithDuration:0.25
            delay:0.0
            options: UIViewAnimationCurveEaseOut
            animations:^{
                self.selectionDragView.alpha = 0;
            } 
            completion:^(BOOL finished){
                self.selectionDragView.hidden = true;
                [self.selectionDragView setFrame:CGRectMake(0, 0, 0, 0)];
        }];

    }
}


-(void)handleTapGesture:(UITapGestureRecognizer *)gesture{
    for(OSFileView *fileView in self.selectedViews){
        [fileView setSelected:false animated:true];
    }
}



-(void)drawFiles{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *dirContents = [fileManager contentsOfDirectoryAtPath:@"/var/mobile/Desktop" error:nil];

    for(NSString *file in dirContents){

        OSFileView *fileView = [[OSFileView alloc] initWithFile:[[OSFile alloc] initWithFile:[NSString stringWithFormat:@"/var/mobile/Desktop/%@", file]]];




        UILongPressGestureRecognizer *panGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleFilePanGesture:)];
        panGesture.minimumPressDuration = 0.25;
        [fileView addGestureRecognizer:panGesture];

        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleFileTapGesture:)];
        tapGesture.numberOfTapsRequired = 1;
        [fileView addGestureRecognizer:tapGesture];


        [self addSubview:fileView];
    }

}



-(void)handleFileTapGesture:(UITapGestureRecognizer *)gesture{
    if(![(OSFileView*)[gesture view] selected]){
        for(OSFileView *fileView in [self selectedViews]){
            [fileView setSelected:false animated:true];
        }
        [(OSFileView*)[gesture view] setSelected:true animated:true];
    }

    UIMenuItem *open = [[UIMenuItem alloc] initWithTitle:@"Open" action:@selector(openFile:)];
    //UIMenuItem *delete = [[UIMenuItem alloc] initWithTitle:@"Delete" action:@selector(openFile:)];

    UIMenuController *menu = [UIMenuController sharedMenuController];

    [menu setMenuItems:[NSArray arrayWithObjects:open, nil]];
    [menu setTargetRect:gesture.view.frame inView:self];
    [menu setMenuVisible:YES animated:YES];
}


-(void)openFile:(id)sender{
    NSLog(@"%@", sender);
}

-(BOOL)canBecomeFirstResponder{
    return true;
}

-(NSMutableArray*)selectedViews{
    NSMutableArray *views = [[[NSMutableArray alloc] initWithCapacity:0] autorelease];
    for(OSFileView *fileView in [self subviews]){
        if(![fileView isKindOfClass:[OSFileView class]]){
            continue;
        }
        if([fileView selected]){
            [views addObject:fileView];
        }
    }
    return views;
}






-(void)handleFilePanGesture:(UIPanGestureRecognizer *)gesture{
    
    if([gesture state] == UIGestureRecognizerStateEnded){
        
        for(OSFileView *fileView in self.selectedViews){


        //Find nearest spot on grid for placement

        int x = fileView.frame.origin.x;
        int y = fileView.frame.origin.y;

        bool xGoingUp = false;
        bool yGoingUp = false;


        if(x % (marginSize + iconSize) > ((marginSize + iconSize) / 2) ){
            xGoingUp = true;
        }

        if(y % (marginSize + iconSize) > ((marginSize + iconSize) / 2) ){
            yGoingUp = true;
        }

        while(x % (marginSize + iconSize) != 0){
            if(xGoingUp){
                x++;
            }else{
                x--;
            }
        }
    
        while(y % (marginSize + iconSize) != 0){
            if(yGoingUp){
                y++;
            }else{
                y--;
            }
        }


        //Check if placement spot is out of bounds
        if(x + iconSize + marginSize > self.frame.size.width){
            while(x % (marginSize + iconSize) != 0 || x + iconSize + marginSize > self.frame.size.width){
                x--;
            }
        }

        if(y + iconSize + marginSize > self.frame.size.height){
            while(y % (marginSize + iconSize) != 0 || y + iconSize + marginSize > self.frame.size.height){
                y--;
            }
        }

        if(y < 0){
            while(y % (marginSize + iconSize) != 0 || y < 0){
                y++;
            }
        }

        if(x < 0){
            while(x % (marginSize + iconSize) != 0 || x < 0){
                x++;
            }
        }



      
 


        [UIView animateWithDuration:0.25
            delay:0.0
            options: UIViewAnimationCurveEaseOut
            animations:^{
                fileView.alpha = 1;
                fileView.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1, 1);
                [fileView setFrame:CGRectMake(x, y, fileView.frame.size.width, fileView.frame.size.height)];
            } 
            completion:^(BOOL finished){
        }];

     }

    }else if([gesture state] == UIGestureRecognizerStateBegan) {


        


        if(![(OSFileView *)[gesture view] selected]){
            for(OSFileView *fileView in self.selectedViews){
                [fileView setSelected:false animated:false];
            }
            [(OSFileView *)[gesture view] setSelected:true animated:false];
        }


        for(OSFileView *fileView in self.selectedViews){
            [self bringSubviewToFront:fileView];


            [fileView setStartingPoint:fileView.frame.origin];
            [fileView setDragOffset:CGPointSub(fileView.center, [gesture locationInView:self])];


            [UIView animateWithDuration:0.25 delay:0.0 options: UIViewAnimationCurveEaseOut animations:^{
                    fileView.center = CGPointAdd([fileView dragOffset], [gesture locationInView:self]);
                    fileView.alpha = 0.9;
                    fileView.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1.1, 1.1);
                } completion:^(BOOL finished){
            }];

        }




    }else{
        for(OSFileView *fileView in self.selectedViews){
            fileView.center = CGPointAdd([fileView dragOffset], [gesture locationInView:self]);
        }
    }

}


- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration{

}


- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation{

}


CGRect CGRectFromCGPoints(CGPoint p1, CGPoint p2){
    return CGRectMake(MIN(p1.x, p2.x), MIN(p1.y, p2.y), fabs(p1.x - p2.x), fabs(p1.y - p2.y));
}

@end
