#define PRODUCT_NAME @"OS Experience"
#define PACKAGE_ID   @"com.eswick.osexperience"

%hook SBLockScreenViewController

static dispatch_once_t onceToken;

- (void)finishUIUnlockFromSource:(int)arg1{
	%orig;

	dispatch_once (&onceToken, ^{
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Installation Failed" message:[NSString stringWithFormat:@"Something went wrong when installing %@. Please re-install it in Cydia.", PRODUCT_NAME] delegate:self cancelButtonTitle:@"Later" otherButtonTitles:@"Cydia", nil];
		[alert show];
		[alert release];
	});
}

%new
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	if(buttonIndex == 1){
		[[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"cydia://package/%@", PACKAGE_ID]]];
	}
}

%end