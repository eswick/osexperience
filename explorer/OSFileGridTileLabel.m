#import "OSFileGridTileLabel.h"
#import <CoreText/CoreText.h>

#define NSMakeRangeFromCFRange(cfr) NSMakeRange( cfr.location == kCFNotFound ? NSNotFound : cfr.location, cfr.length )
#define fixLineRect(rect) rect.origin.y = self.bounds.size.height - rect.origin.y - rect.size.height * 2; rect.size.height += -self.font.descender;

@interface UIColor ()
+ (UIColor*)tableSelectionColor;
@end

@implementation OSFileGridTileLabel

CGRect rectFromLine(CTLineRef line, CTFrameRef frame, CGPoint origin){
	CGFloat ascent, descent, leading;
	CTLineGetTypographicBounds(line, &ascent, &descent, &leading);

	CFRange lineRange = CTLineGetStringRange(line);
	CGFloat lineStart = CTLineGetOffsetForStringIndex(line, lineRange.location, NULL);
	CGFloat lineEnd = CTLineGetOffsetForStringIndex(line, lineRange.location + lineRange.length, NULL);

	CGRect box = CGPathGetBoundingBox(CTFrameGetPath(frame));
	CGFloat lineHeight = ascent + descent + leading;

	CGFloat rectX = box.origin.x + origin.x + lineStart;
	CGFloat rectY = box.origin.y + origin.y - lineHeight;

	CGRect rectForLine = CGRectMake( rectX, rectY, lineEnd - lineStart, lineHeight);

	return rectForLine;
}

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

		/* Make new attributed string */
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

		[style release];
		[secondLineStyle release];

		/*Reset framesetter and frame */
		CFRelease(framesetter);
		CFRelease(frame);

		framesetter = CTFramesetterCreateWithAttributedString((CFAttributedStringRef)string);
		frame = CTFramesetterCreateFrame(framesetter, CFRangeMake(0, [string length]), path, NULL);
	}



	
	if(self.selected){
	/* Update text path */
		self.path = [UIBezierPath bezierPath];


		lines = CTFrameGetLines(frame);

		CGPoint *lineOrigins = malloc(CFArrayGetCount(lines));
		CTFrameGetLineOrigins(frame, CFRangeMake(0, 0), lineOrigins);
	//Line 1
		if(CFArrayGetCount(lines) > 0){
			CTLineRef line1 = CFArrayGetValueAtIndex(lines, 0);
			CGRect lineFrame1 = rectFromLine(line1, frame, lineOrigins[0]);

			fixLineRect(lineFrame1);

			UIBezierPath *linePath = [UIBezierPath bezierPathWithRoundedRect:lineFrame1 cornerRadius:0];

			[self.path appendPath:linePath];
		}

		if(CFArrayGetCount(lines) > 1){
			CTLineRef line2 = CFArrayGetValueAtIndex(lines, 1);
			CGRect lineFrame2 = rectFromLine(line2, frame, lineOrigins[1]);
			
			fixLineRect(lineFrame2);

			UIBezierPath *linePath = [UIBezierPath bezierPathWithRoundedRect:lineFrame2 cornerRadius:0];

			[self.path appendPath:linePath];
		}

	//end

		free(lineOrigins);
	}

	/* Draw text */
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

- (void)setSelected:(BOOL)selected{
	if(_selected == selected)
		return;
	_selected = selected;

	if(selected){
		self.shadowColor = [UIColor clearColor];
		self.layer.shadowColor = [[UIColor clearColor] CGColor];

		CAShapeLayer *maskLayer = [CAShapeLayer layer];
		maskLayer.frame = self.layer.bounds;
		maskLayer.path = self.path.CGPath;
		self.layer.mask = maskLayer;

		self.backgroundColor = [UIColor tableSelectionColor];
	}else{
		self.shadowColor = [UIColor blackColor];
		self.layer.shadowColor = [[UIColor blackColor] CGColor];
		self.layer.mask = nil;
		self.backgroundColor = [UIColor clearColor];
	}

	[self setNeedsDisplay];
}

@end