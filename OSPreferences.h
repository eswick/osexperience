
#define prefs ([OSPreferences sharedInstance])

@interface OSPreferences : NSObject

+ (id)sharedInstance;

@property BOOL isEnabled;

@end