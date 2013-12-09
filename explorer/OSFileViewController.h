


@interface OSFileViewController : NSObject

@property (nonatomic, retain) UIView *view;
@property (nonatomic, retain) NSURL *path;
@property (nonatomic) BOOL loaded;
@property (nonatomic) NSDirectoryEnumerationOptions enumerationOptions;

- (void)loadView;
- (void)pathChanged;
- (void)layoutView;

@end