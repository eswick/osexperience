
#define prefs ([OSPreferences sharedInstance])
#define PROP_RDONLY(type,name) @property (readonly) type name
#define PROP_RDWT(type,name) @property type name

@interface OSPreferences : NSObject

+ (id)sharedInstance;

PROP_RDWT			(BOOL,ENABLED);
PROP_RDWT			(BOOL,LIVE_PREVIEWS);
PROP_RDWT			(float,SCROLL_TO_PANE_DURATION);
PROP_RDONLY			(float,SNAP_MARGIN);
PROP_RDONLY			(float,PANE_SEPARATOR_SIZE);
PROP_RDWT			(BOOL,TUTORIAL_SHOWN);
PROP_RDWT			(BOOL,SHOW_MG_POPUP);

@end