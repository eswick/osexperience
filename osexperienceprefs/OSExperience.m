#import <Preferences/Preferences.h>
#import "../OSPreferences.h"

#define DYLIB_INSTALL_PATH @"/var/mobile/Library/Preferences/com.eswick.osexperience.license"

@interface OSExperienceListController : PSListController
@end

#define RESPRING_ALERT 1

@implementation OSExperienceListController

- (id)specifiers {
	if(_specifiers == nil) {
		_specifiers = [[self loadSpecifiersFromPlistName:@"OSExperience" target:self] retain];
	}
	return _specifiers;
}

- (void)setEnabled:(NSNumber*)enabled forSpecifier:(PSSpecifier*)specifier{
	[prefs setENABLED:[enabled boolValue]];
	[self showRespringPrompt];
}

- (NSNumber*)getEnabled:(PSSpecifier*)specifier{
	return [NSNumber numberWithBool:[prefs ENABLED]];
}

- (void)setLivePreviews:(NSNumber*)enabled forSpecifier:(PSSpecifier*)specifier{
	[prefs setLIVE_PREVIEWS:[enabled boolValue]];
}

- (NSNumber*)getLivePreviews:(PSSpecifier*)specifier{
	return [NSNumber numberWithBool:[prefs LIVE_PREVIEWS]];
}

- (NSNumber*)getAppTransitionSpeed:(PSSpecifier*)specifier{
	return [NSNumber numberWithFloat:[prefs SCROLL_TO_PANE_DURATION]];
}

- (void)setAppTransitionSpeed:(NSNumber*)speed forSpecifier:(PSSpecifier*)specifier{
	[prefs setSCROLL_TO_PANE_DURATION:[speed floatValue]];
}

- (void)follow:(id)arg1{
    if([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"twitter://"]]){
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"twitter://user?screen_name=e_swick"]];
    }else{
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://www.twitter.com/e_swick"]];
    }
}

- (void)showRespringPrompt{
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Respring" message:@"This setting requires a respring to take effect. Respring now?" delegate:self cancelButtonTitle:@"Later" otherButtonTitles:@"OK", nil];
	alert.tag = RESPRING_ALERT;
	[alert show];
	[alert release];
}


- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	if(alertView.tag == RESPRING_ALERT){
		if(buttonIndex == 1)
			system("killall -9 backboardd");
	}
}

@end
