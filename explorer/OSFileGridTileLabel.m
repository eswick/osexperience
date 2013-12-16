#import "OSFileGridTileLabel.h"
#import <CoreText/CoreText.h>

#define NSMakeRangeFromCFRange(cfr) NSMakeRange( cfr.location == kCFNotFound ? NSNotFound : cfr.location, cfr.length )

@interface UIColor ()
+ (UIColor*)tableSelectionColor;
@end

@implementation OSFileGridTileLabel

- (void) drawRect:(CGRect)rect{
	CGContextRef context = UIGraphicsGetCurrentContext();
 
	// Flip the coordinate system
	CGContextSetTextMatrix(context, CGAffineTransformIdentity);
	CGContextTranslateCTM(context, 0, self.bounds.size.height);
	CGContextScaleCTM(context, 1.0, -1.0);


	CGMutablePathRef path = CGPathCreateMutable();
	CGPathAddRect(path, NULL, self.bounds);

	NSAttributedString *attributedText = [self attributedText];
	CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString((CFAttributedStringRef)attributedText);
	CTFrameRef frame = CTFramesetterCreateFrame(framesetter, CFRangeMake(0, [attributedText length]), path, NULL);
	CFArrayRef lines = CTFrameGetLines(frame);

	if(CFArrayGetCount(lines) == 2){
		CFRange range = CTLineGetStringRange(CFArrayGetValueAtIndex(lines, 1));

		NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:self.text];
		[string addAttribute:NSFontAttributeName value:self.font range:NSMakeRange(0, [string length])];
		[string addAttribute:NSForegroundColorAttributeName value:self.textColor range:NSMakeRange(0, [string length])];

		NSMutableParagraphStyle *secondLineStyle = [[NSMutableParagraphStyle alloc] init];
		secondLineStyle.alignment = NSTextAlignmentCenter;
		secondLineStyle.lineBreakMode = NSLineBreakByTruncatingMiddle;

		NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
		style.alignment = NSTextAlignmentCenter;

		[string addAttribute:NSParagraphStyleAttributeName value:secondLineStyle range:NSMakeRangeFromCFRange(range)];
		[string addAttribute:NSParagraphStyleAttributeName value:style range:NSMakeRange(0, range.location)];



		/*Reset framesetter and frame */
		CFRelease(framesetter);
		CFRelease(frame);

		framesetter = CTFramesetterCreateWithAttributedString((CFAttributedStringRef)string);
		frame = CTFramesetterCreateFrame(framesetter, CFRangeMake(0, [string length]), path, NULL);
	}

	CTFrameDraw(frame, context);

	CFRelease(framesetter);
	CFRelease(path);
	CFRelease(frame);
}

- (NSAttributedString*)attributedText{
	NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:self.text];

	[string addAttribute:NSFontAttributeName value:self.font range:NSMakeRange(0, [string length])];
	[string addAttribute:NSForegroundColorAttributeName value:self.textColor range:NSMakeRange(0, [string length])];

	NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
	style.alignment = NSTextAlignmentCenter;

	[string addAttribute:NSParagraphStyleAttributeName value:style range:NSMakeRange(0, [string length])];

	[style release];

	return [string autorelease];
}

@end