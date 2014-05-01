#import "OSPreferences.h"

#define PREFS_PATH @"/var/mobile/Library/Preferences/com.eswick.osexperience.plist"


/* Dictionary tools */
#define dictionary [NSDictionary dictionaryWithContentsOfFile:PREFS_PATH]

#define getPrefValue(key) [dictionary objectForKey:@#key]
#define setPrefValue(key,value) \
({ \
	NSMutableDictionary *tempDict = [NSMutableDictionary dictionaryWithDictionary:dictionary]; \
	[tempDict setObject:value forKey:@#key];\
	[tempDict writeToFile:PREFS_PATH atomically:true];\
})

#define getBoolValue(key) [getPrefValue(key) boolValue]
#define setBoolValue(key,value) setPrefValue(key,[NSNumber numberWithBool:value])

/* ======== */

#define fileManager [NSFileManager defaultManager]

#define DEFAULTS \
@{\
	@"ENABLED" : @true\
}

@implementation OSPreferences

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

- (BOOL)isEnabled{
	return getBoolValue(ENABLED);
}

- (void)setIsEnabled:(BOOL)enabled{
	setBoolValue(ENABLED, enabled);
}



@end
