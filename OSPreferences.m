#import "OSPreferences.h"

#define PREFS_PATH @"/var/mobile/Library/Preferences/com.eswick.osexperience.plist"


/* Dictionary tools */
#define dictionary [NSDictionary dictionaryWithContentsOfFile:PREFS_PATH]

#define getPrefValue(key) ([dictionary objectForKey:@#key] ? [dictionary objectForKey:@#key] : [DEFAULTS objectForKey:@#key])
#define setPrefValue(key,value) \
({ \
	NSMutableDictionary *tempDict = [NSMutableDictionary dictionaryWithDictionary:dictionary]; \
	[tempDict setObject:value forKey:@#key];\
	[tempDict writeToFile:PREFS_PATH atomically:true];\
})

#define getBoolValue(key) [getPrefValue(key) boolValue]
#define setBoolValue(key,value) setPrefValue(key,[NSNumber numberWithBool:value])

#define fileManager [NSFileManager defaultManager]

/* Value helpers */
#define FLOAT_RDONLY(name) - (float)name{ return [getPrefValue(name) floatValue]; }
#define BOOL_RDWT(name) - (BOOL)name { return getBoolValue(name); } - (void)set##name:(BOOL)value{ setBoolValue(name,value); } 
#define VALUE(name,default) @#name : @(default),
/* ======== */




#define DEFAULTS \
@{\
	VALUE(ENABLED, true)\
	VALUE(SNAP_MARGIN, 20)\
	VALUE(PANE_SEPARATOR_SIZE, 40)\
	VALUE(SCROLL_TO_PANE_DURATION, 1.0)\
	VALUE(LIVE_PREVIEWS, true)\
    VALUE(TUTORIAL_SHOWN, false)\
}

@implementation OSPreferences


BOOL_RDWT			(ENABLED);
BOOL_RDWT			(LIVE_PREVIEWS);
BOOL_RDWT           (TUTORIAL_SHOWN);
FLOAT_RDONLY		(SNAP_MARGIN);
FLOAT_RDONLY		(PANE_SEPARATOR_SIZE);
FLOAT_RDONLY		(SCROLL_TO_PANE_DURATION);


+ (id)sharedInstance{
    static OSPreferences *_prefs;

    if (_prefs == nil)
    {
        _prefs = [[self alloc] init];

        if(![fileManager fileExistsAtPath:PREFS_PATH]){
        	/* Write defaults */
        	[DEFAULTS writeToFile:PREFS_PATH atomically:true];
        }
    }

    return _prefs;
}

@end
