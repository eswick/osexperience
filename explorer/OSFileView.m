#import "OSFileView.h"

#define marginSize 25
#define iconSize 72
#define selectionAlpha 0.5


@implementation OSFileView
@synthesize holdGesture = _holdGesture;
@synthesize panGesture = _panGesture;
@synthesize iconView = _iconView;
@synthesize startingPoint = _startingPoint;
@synthesize fileLabel = _fileLabel;
@synthesize file = _file;
@synthesize selectionBackdrop = _selectionBackdrop;
@synthesize selected = _selected;
@synthesize dragOffset = _dragOffset;





-(id)initWithFile:(OSFile*)file_{

        if(![super initWithFrame:CGRectMake(0, 0, iconSize, iconSize)]){
                return nil;
        }


        self.file = file_;


        self.iconView = [[UIImageView alloc] initWithFrame:[self frame]];
        self.iconView.center = self.center;
        self.iconView.backgroundColor = [UIColor clearColor];
        self.iconView.image = self.file.icon;
        [self addSubview:self.iconView];

        

        self.fileLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, self.bounds.size.height, self.bounds.size.width + marginSize, 20.0)];

        [self.fileLabel setCenter:CGPointMake(self.center.x, 0)];

        CGRect labelRect = [self.fileLabel frame];
        labelRect.origin.y = self.bounds.size.height;
        [self.fileLabel setFrame:labelRect];

        self.fileLabel.textAlignment =  UITextAlignmentCenter;//Set up look of label
        self.fileLabel.textColor = [UIColor whiteColor];
        self.fileLabel.backgroundColor = [UIColor clearColor];
        self.fileLabel.shadowColor = [UIColor blackColor];
        self.fileLabel.font = [UIFont boldSystemFontOfSize:12];
        self.fileLabel.numberOfLines = 0;
        self.fileLabel.lineBreakMode = NSLineBreakByTruncatingMiddle;

        //Set file label shadow blur
        self.fileLabel.layer.shadowColor = [[UIColor blackColor] CGColor];
        self.fileLabel.layer.shadowOffset = CGSizeMake(0.0, 0.0);
        self.fileLabel.layer.shadowRadius = 3.0;
        self.fileLabel.layer.shadowOpacity = 1;
        self.fileLabel.layer.masksToBounds = NO;
        self.fileLabel.layer.shouldRasterize = true;
        self.fileLabel.text = self.file.filename;
        [self addSubview:self.fileLabel];


        self.selectionBackdrop = [[UIView alloc] initWithFrame:[self frame]];
        self.selectionBackdrop.backgroundColor = [UIColor darkGrayColor];
        self.selectionBackdrop.layer.cornerRadius = 5;
        self.selectionBackdrop.alpha = selectionAlpha;
        self.selectionBackdrop.layer.borderColor = [UIColor lightGrayColor].CGColor;
        self.selectionBackdrop.layer.borderWidth = 2.0f;
        self.selectionBackdrop.hidden = true;
        [self addSubview:self.selectionBackdrop];
        [self sendSubviewToBack:self.selectionBackdrop];


        



        return self;
}




-(void) setSelected:(bool)selected_ animated:(bool)animated{
                float duration;

                duration = animated ? 0.1 : 0.0;

                float startAlpha;
                float endAlpha;
                if(selected_){
                        startAlpha = 0.0;
                        endAlpha = selectionAlpha;
                }else{
                        startAlpha = selectionAlpha;
                        endAlpha = 0.0;
                }

                [self.selectionBackdrop setAlpha:startAlpha];
                [self.selectionBackdrop setHidden:false];
                [UIView animateWithDuration:duration
                        delay:0.0
                        options: UIViewAnimationOptionCurveEaseOut
                        animations:^{
                                [self.selectionBackdrop setAlpha:endAlpha];
                        } 
                        completion:^(BOOL finished){
                                if(!selected_){
                                        [self.selectionBackdrop setHidden:true];
                                }
                }];
        

        _selected = selected_;
}
      




@end