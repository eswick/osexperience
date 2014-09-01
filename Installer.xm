
#import <Foundation/Foundation.h>
#import <gestalt.h>

#include <sys/sysctl.h>
#include <mach/machine.h>
#include <mach-o/loader.h>
#include <mach-o/fat.h>
#include "include.h"

#define ACTIVATION_SERVER "http://repo.eswick.com/a2"
#define ACTIVATION_BACKUP_SERVER "http://fallback.eswick.com/a2"
#define PRODUCT_ID "com.eswick.osexperience"
#define DYLIB_INSTALL_PATH @"/var/mobile/Library/Preferences/com.eswick.osexperience.license"

#define TAG_ERROR 1

@interface OSDownloadController : NSObject

@property (assign) UIAlertView *oseAlertView;
@property (assign) NSURLConnection *connection;
@property (assign) NSMutableData *receivedData;
@property (assign) double progress;
@property (assign) size_t downloadSize;
@property (assign) BOOL shouldUseFallbackServer;

- (void)beginDownload;

@end

%group SpringBoard

%hook SBLockScreenViewController

%property (assign) UIAlertView *oseAlertView;


- (void)finishUIUnlockFromSource:(int)arg1{
	%orig;

	OSDownloadController *controller = [[OSDownloadController alloc] init];
	[controller beginDownload];

}

%end

%end



@implementation OSDownloadController


- (void)beginDownload{

	self.oseAlertView = [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"Downloading License\nPlease Wait... (%.0f%%)", self.progress] message:nil delegate:self cancelButtonTitle:nil otherButtonTitles:nil];

	UIActivityIndicatorView *loading = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
	[loading startAnimating];

	MSHookIvar<UIView*>(self.oseAlertView, "_accessoryView") = loading;
	[self.oseAlertView show];


	/* get arch */
	NSString *arch = nil;

	size_t size;
    cpu_type_t type;
    size = sizeof(type);
    sysctlbyname("hw.cputype", &type, &size, NULL, 0);

    if(type == CPU_TYPE_ARM)
    	arch = @"arm";
    else if(type == CPU_TYPE_ARM64)
    	arch = @"arm64";
    else
    	printf("unsupported arch\n"), exit(1);

	NSURL *url = [NSURL URLWithString:self.shouldUseFallbackServer ? @ACTIVATION_BACKUP_SERVER : @ACTIVATION_SERVER];
	NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:url];

	req.HTTPMethod = @"POST";
	NSString *postString = [NSString stringWithFormat:@"productid=%@&udid=%@&arch=%@&version=%@", @PRODUCT_ID, MGCopyAnswer(CFSTR("UniqueDeviceID")), arch, @VERSION];
	req.HTTPBody = [postString dataUsingEncoding:NSUTF8StringEncoding];

	self.receivedData = [[NSMutableData alloc] initWithLength:0];
	self.connection = [[NSURLConnection alloc] initWithRequest:req delegate:self startImmediately:true];
}

- (void)error:(NSString*)text{

	[self.connection cancel];

	[self.oseAlertView dismissWithClickedButtonIndex:0 animated:true];
	[self.oseAlertView release];
	self.oseAlertView = nil;


	if(self.shouldUseFallbackServer){
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error Occurred" message:[NSString stringWithFormat:@"An error occurred while downloading the license for OS Experience: %@", text] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:@"Try Again", nil];
		alert.tag = TAG_ERROR;
		[alert show];
		[alert release];
	}else{
		self.shouldUseFallbackServer = true;
		[self beginDownload];
	}
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex{
	if([alertView tag] == TAG_ERROR){
		if(buttonIndex == 1){
			if(self.receivedData){
				[self.receivedData release];
				self.receivedData = nil;
			}
			if(self.connection){
				[self.connection release];
				self.connection = nil;
			}

			self.shouldUseFallbackServer = false;
			[self beginDownload];

		}

	}
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error{
   	[self error:[[error userInfo] objectForKey:NSLocalizedDescriptionKey]];
}

- (NSCachedURLResponse *)connection:(NSURLConnection *)connection willCacheResponse:(NSCachedURLResponse *)cachedResponse{
    return nil;
}

- (void)connection:(NSURLConnection*)connection didReceiveData:(NSData*)data{
    [self.receivedData appendData:data];

    self.progress = (double)self.receivedData.length / (double)self.downloadSize;

    self.oseAlertView.title = [NSString stringWithFormat:@"Downloading License\nPlease Wait... (%.0f%%)", self.progress * 100];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection{

	if (self.receivedData == nil){
		[self error:@"download failed"];
		return;
	}

	if ([self.receivedData length] < sizeof(uint32_t)){
		[self error:@"invalid size"];
		return;
	}

	uint32_t magic = *((uint32_t*)[self.receivedData bytes]);
	if ((magic != MH_MAGIC) && (magic != MH_MAGIC_64) && (MH_MAGIC != OSSwapBigToHostInt32(FAT_MAGIC))){
		[self error:@"invalid data"];
		return;
	}

	NSError *error = nil;

	if(![[NSFileManager defaultManager] fileExistsAtPath:[DYLIB_INSTALL_PATH stringByDeletingLastPathComponent]]) {
		[[NSFileManager defaultManager] createDirectoryAtPath:[DYLIB_INSTALL_PATH stringByDeletingLastPathComponent] withIntermediateDirectories:YES attributes:nil error:&error];
		if (error != nil){
			[self error:[[error userInfo] objectForKey:NSLocalizedDescriptionKey]];
			return;
		}
	}

	if(![self.receivedData writeToFile:DYLIB_INSTALL_PATH atomically:true]){
		[self error:@"write failed"];
		return;
	}

	[self.oseAlertView dismissWithClickedButtonIndex:0 animated:true];
	[self.oseAlertView release];
	self.oseAlertView = nil;

	system("killall backboardd");
}


- (void)connection:(NSURLConnection*)connection didReceiveResponse:(NSHTTPURLResponse*)response{
	if(response == nil)
		[self error:@"no response"];

	if(![response isKindOfClass:[NSHTTPURLResponse class]])
		[self error:@"invalid response"];

	NSInteger statusCode = [response statusCode];
	switch(statusCode){
		case 402: [self error:@"server denied request"]; break;
		case 500: [self error:@"internal server error"]; break;
		case 200: break;
		default:  [self error:[NSString stringWithFormat:@"status code %li", (long)statusCode]]; break;
	}

	[self.receivedData setLength:0];
	self.downloadSize = [response expectedContentLength];
}

@end


%ctor{
	if(![[NSFileManager defaultManager] fileExistsAtPath:DYLIB_INSTALL_PATH]){
		if([[[NSBundle mainBundle] bundleIdentifier] isEqualToString:@"com.apple.springboard"]){
			%init(SpringBoard);
		}
	}else{
		dlopen(NULL,RTLD_NOW|RTLD_GLOBAL);
		void *result = dlopen([DYLIB_INSTALL_PATH UTF8String], RTLD_LAZY | RTLD_GLOBAL);
		if(result == NULL){
			NSLog(@"Error opening %@", DYLIB_INSTALL_PATH);
		}
	}
}
