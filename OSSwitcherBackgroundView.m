#import "OSSwitcherBackgroundView.h"

#define lightColor [UIColor colorWithRed:60.0/255.0 green:60.0/255.0 blue:75.0/255.0 alpha:1]
#define darkColor [UIColor colorWithRed:55.0/255.0 green:55.0/255.0 blue:65.0/255.0 alpha:1]

@implementation OSSwitcherBackgroundView

+ (Class)layerClass{
	return [CAGradientLayer class];
}

- (id)initWithFrame:(CGRect)arg1{
	if(![super initWithFrame:arg1])
		return nil;

	self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.backgroundColor = [UIColor colorWithRed:65.0/255.0 green:65.0/255.0 blue:75.0/255.0 alpha:1];
    
    [(CAGradientLayer*)[self layer] setColors:
    	[NSArray arrayWithObjects:
    		(id)[darkColor CGColor], 
    		(id)[lightColor CGColor], 
    		(id)[lightColor CGColor], 
    		(id)[darkColor CGColor], 
    	nil]
    ];

    [(CAGradientLayer*)[self layer] setStartPoint:CGPointMake(0, 0.5)];
    [(CAGradientLayer*)[self layer] setEndPoint:CGPointMake(1, 0.5)];
   
    [(CAGradientLayer*)[self layer] setLocations: 
    	[NSArray arrayWithObjects:
			[NSNumber numberWithFloat:0],
			[NSNumber numberWithFloat:0.02],
			[NSNumber numberWithFloat:0.98],
			[NSNumber numberWithFloat:1],
		nil]
	];

    return self;
}

@end