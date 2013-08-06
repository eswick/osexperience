#import "OSPaneModel.h"




@implementation OSPaneModel
@synthesize panes = _panes;


+ (id)sharedInstance
{
    static OSPaneModel *_model;

    if (_model == nil)
    {
        _model = [[self alloc] init];
    }

    return _model;
}


- (id)init{
	if(![super init])
		return nil;

	self.panes = [[NSMutableArray alloc] init];

	return self;
}

- (unsigned int)count{
	return [self.panes count];
}


- (void)insertPane:(OSPane*)pane atIndex:(unsigned int)index{
	if([self.panes containsObject:pane])
		[self.panes removeObject:pane];

	[self.panes insertObject:pane atIndex:index];
	[[OSSlider sharedInstance] alignPanes];
}


- (void)addPaneToFront:(OSPane*)pane{
	[self.panes insertObject:pane atIndex:0];
}

- (void)addPaneToBack:(OSPane*)pane{
	[self.panes addObject:pane];
	[[OSSlider sharedInstance] addPane:pane];
	[[OSThumbnailView sharedInstance] addPane:pane];
}

- (void)removePane:(OSPane*)pane{

	if([[OSViewController sharedInstance] missionControlIsActive])
		[[OSThumbnailView sharedInstance] removePane:pane animated:true];
	else
		[[OSThumbnailView sharedInstance] removePane:pane animated:false];

	[[OSSlider sharedInstance] removePane:pane];
	[self.panes removeObject:pane];
	[[OSSlider sharedInstance] alignPanes];
}

- (unsigned int)indexOfPane:(OSPane*)pane{
	return [self.panes indexOfObject:pane];
}


- (OSPane*)paneAtIndex:(unsigned int)index{
	if(index < 0 || index > self.panes.count - 1)
		return nil;
	return [self.panes objectAtIndex:index];
}

- (void)dealloc{
	[self.panes release];
	[super dealloc];
}



@end