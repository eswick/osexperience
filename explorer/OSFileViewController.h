


@interface OSFileViewController : NSObject

@property (retain) UIView *view;
@property (retain) NSURL *path;
@property (nonatomic) BOOL loaded;
@property (nonatomic) NSDirectoryEnumerationOptions enumerationOptions;

- (void)loadView;
- (void)pathChanged;
- (void)layoutView;

@end