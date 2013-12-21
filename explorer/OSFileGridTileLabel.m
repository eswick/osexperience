#import "OSFileGridTileLabel.h"
#import <CoreText/CoreText.h>
#import <math.h>

#define NSMakeRangeFromCFRange(cfr) NSMakeRange( cfr.location == kCFNotFound ? NSNotFound : cfr.location, cfr.length )
#define fixLineRect(rect) rect.origin.y = self.bounds.size.height - rect.origin.y - rect.size.height * 2; rect.size.height += -self.font.descender;

#define widthMargin 10

#define CGRectTopLeft(rect) rect.origin
#define CGRectTopRight(rect) CGPointMake(rect.origin.x + rect.size.width, rect.origin.y)
#define CGRectBottomLeft(rect) CGPointMake(rect.origin.x, rect.origin.y + rect.size.height)
#define CGRectBottomRight(rect) CGPointMake(rect.origin.x + rect.size.width, rect.origin.y + rect.size.height)

#define deg2rad(degrees)  ((M_PI * degrees)/ 180)

@interface UIColor ()
+ (UIColor*)tableSelectionColor;
@end

@implementation OSFileGridTileLabel
@synthesize selected = _selected;

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

+ (UIBezierPath*)pathWithTopLine:(CGRect)topLine bottomLine:(CGRect)bottomLine{
	//float insideRadius = 10.0f;
	float topLineRadius = topLine.size.height / 2;
	float bottomLineRadius = bottomLine.size.height / 2;

	UIBezierPath *path = [UIBezierPath bezierPath];

	[path moveToPoint:CGRectTopLeft(topLine)];

	[path addLineToPoint:CGRectTopLeft(topLine)];
	[path addLineToPoint:CGRectTopRight(topLine)];

	//First line top right arc
	[path addArcWithCenter:CGPointMake(CGRectTopRight(topLine).x, topLine.size.height / 2) radius:topLineRadius startAngle:deg2rad(270) endAngle:deg2rad(0) clockwise:true];

	if(CGRectIsNull(bottomLine)){
		//First line bottom right arc
		[path addArcWithCenter:CGPointMake(CGRectTopRight(topLine).x, topLine.size.height / 2) radius:topLineRadius startAngle:deg2rad(0) endAngle:deg2rad(90) clockwise:true];

		[path addLineToPoint:CGRectBottomLeft(topLine)];
		//First line left arc
		[path addArcWithCenter:CGPointMake(CGRectTopLeft(topLine).x, topLine.size.height / 2) radius:topLineRadius startAngle:deg2rad(90) endAngle:deg2rad(270) clockwise:true];

		[path closePath];
		return path;
	}else 
		return nil;

	if(CGRectTopRight(bottomLine).x >= CGRectTopRight(topLine).x){
		[path addLineToPoint:CGPointMake(CGRectTopRight(topLine).x + topLineRadius, bottomLine.origin.y)];
		//[path addArcWithCenter:CGPointMake(CGRectTopRight(topLine).x + topLineRadius + insideRadius, bottomLine.origin.y - insideRadius) radius:insideRadius startAngle:deg2rad(180) endAngle:deg2rad(90) clockwise:false];
		
		[path addLineToPoint:CGRectTopRight(bottomLine)];

		[path addArcWithCenter:CGPointMake(CGRectTopRight(bottomLine).x, bottomLine.origin.y + bottomLine.size.height / 2) radius:bottomLineRadius startAngle:deg2rad(270) endAngle:deg2rad(90) clockwise:true];
		[path addLineToPoint:CGPointMake(CGRectBottomLeft(bottomLine).x, CGRectBottomLeft(bottomLine).y)];
	}



	[path closePath];
	return path;
}

- (void) drawRect:(CGRect)rect{

	CGContextRef context = UIGraphicsGetCurrentContext();
 
	/* Flip the coordinate system */
	CGContextSetTextMatrix(context, CGAffineTransformIdentity);
	CGContextTranslateCTM(context, 0, self.bounds.size.height);
	CGContextScaleCTM(context, 1.0, -1.0);

	if(self.selected){

		self.layer.shadowColor = [[UIColor clearColor] CGColor];

		CGContextSetFillColorWithColor(context, [[UIColor tableSelectionColor] CGColor]);
		
		[self.path fill];
	}else{
		self.layer.shadowColor = [[UIColor blackColor] CGColor];
	}

	/* Draw text */
	CTFrameDraw(self.textFrame, context);
}

- (void)redrawText{
	/* Get bounds for drawing text */
	CGMutablePathRef path = CGPathCreateMutable();
	CGPathAddRect(path, NULL, CGRectMake(widthMargin / 2, 0, self.bounds.size.width - widthMargin, self.bounds.size.height));

	NSAttributedString *attributedText = [self attributedText];
	CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString((CFAttributedStringRef)attributedText);
	CTFrameRef frame = CTFramesetterCreateFrame(framesetter, CFRangeMake(0, [attributedText length]), path, NULL);
	CFArrayRef lines = CTFrameGetLines(frame);

	if(CFArrayGetCount(lines) == 2){
		CFRange range = CTLineGetStringRange(CFArrayGetValueAtIndex(lines, 1));

		/* Make new attributed string to center bottom line */
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

		/* Reset framesetter and frame */
		CFRelease(framesetter);
		CFRelease(frame);

		framesetter = CTFramesetterCreateWithAttributedString((CFAttributedStringRef)string);
		CTFramesetterSuggestFrameSizeWithConstraints(framesetter, CFRangeMake(0, [attributedText length]), NULL, CGSizeMake(self.bounds.size.width - 50, self.bounds.size.height), NULL);
		frame = CTFramesetterCreateFrame(framesetter, CFRangeMake(0, [string length]), path, NULL);
	}

	if(self.textFrame != NULL){
		CFRelease(self.textFrame);
	}

	self.textFrame = frame;

	CFRelease(framesetter);
	CFRelease(path);

	[self updateSelectionPath];
	[self setNeedsDisplay];
}

- (void)updateSelectionPath{
	self.path = [UIBezierPath bezierPath];

	CFArrayRef lines = CTFrameGetLines(self.textFrame);

	CGPoint *lineOrigins = malloc(CFArrayGetCount(lines));
	CTFrameGetLineOrigins(self.textFrame, CFRangeMake(0, 0), lineOrigins);

	CGRect lineFrame1, lineFrame2;

	//Line 1
	if(CFArrayGetCount(lines) > 0){
		CTLineRef line1 = CFArrayGetValueAtIndex(lines, 0);
		lineFrame1 = rectFromLine(line1, self.textFrame, lineOrigins[0]);

		fixLineRect(lineFrame1);
	}

	//Line 2
	if(CFArrayGetCount(lines) == 2){
		CTLineRef line2 = CFArrayGetValueAtIndex(lines, 1);
		lineFrame2 = rectFromLine(line2, self.textFrame, lineOrigins[1]);

		fixLineRect(lineFrame2);

		self.path = [OSFileGridTileLabel pathWithTopLine:lineFrame1 bottomLine:lineFrame2];

	}else{
		self.path = [OSFileGridTileLabel pathWithTopLine:lineFrame1 bottomLine:CGRectNull];
	}

	free(lineOrigins);

	[self.path applyTransform:CGAffineTransformMakeScale(1.0, -1.0)];
	[self.path applyTransform:CGAffineTransformMakeTranslation(0, self.bounds.size.height)];
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
	if(_selected == selected){
		return;
	}

	_selected = selected;
	
	[self setNeedsDisplay];
}

@end
