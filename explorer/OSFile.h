



@interface OSFile : NSObject{
	NSString *_filename;
	NSString *_path;
	UIImage *_icon;
	bool _isDirectory;
}


@property (nonatomic, retain) NSString *filename;
@property (nonatomic, retain) NSString *path;
@property (nonatomic, retain) UIImage *icon;
@property (readonly) bool isDirectory;



-(NSString *)absolutePath;

-(id)initWithFile:(NSString *)file;


@end
