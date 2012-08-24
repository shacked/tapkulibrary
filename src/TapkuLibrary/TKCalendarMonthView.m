//
//  TKCalendarMonthView.m
//  Created by Devin Ross on 6/10/10.
//
/*
 
 tapku.com || http://github.com/devinross/tapkulibrary
 
 Permission is hereby granted, free of charge, to any person
 obtaining a copy of this software and associated documentation
 files (the "Software"), to deal in the Software without
 restriction, including without limitation the rights to use,
 copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the
 Software is furnished to do so, subject to the following
 conditions:
 
 The above copyright notice and this permission notice shall be
 included in all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
 EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
 OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
 NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
 HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
 WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
 FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
 OTHER DEALINGS IN THE SOFTWARE.
 
 */

#import "TKCalendarMonthView.h"
#import "NSDate+TKCategory.h"
#import "TKGlobal.h"
#import "UIImage+TKCategory.h"

@interface TKCalendarMonthView ()

@property (strong,nonatomic) NSDate *startDateSelected;
@property (strong,nonatomic) NSDate *endDateSelected;
@property (strong,nonatomic) UIScrollView *tileBox;
@property (strong,nonatomic) UIImageView *topBackground;
@property (strong,nonatomic) UILabel *monthYear;
@property (strong,nonatomic) UIButton *leftArrow;
@property (strong,nonatomic) UIButton *rightArrow;
@property (strong,nonatomic) UIImageView *shadow;

- (void) dateWasTouched:(NSDate*)date touchEnded:(UIGestureRecognizerState)touchState;

@end

#pragma mark NSDate (calendarcategory)
@interface NSDate (calendarcategory)

+ (NSDate*) lastofMonthDate;

+ (NSDate*) lastOfCurrentMonth;

- (NSDate*) firstOfMonth;

- (NSDate*) nextMonth;

- (NSDate*) previousMonth;

- (NSDate*) lastOfMonthDate;

@end


@implementation NSDate (calendarcategory)

+ (NSDate*) lastofMonthDate{
    NSDate *day = [NSDate date];
	NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
	NSDateComponents *comp = [gregorian components:(NSYearCalendarUnit | NSMonthCalendarUnit) fromDate:day];
	[comp setDay:0];
	[comp setMonth:comp.month+1];
	return [gregorian dateFromComponents:comp];
}

+ (NSDate*) lastOfCurrentMonth{
	NSDate *day = [NSDate date];
	NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
	NSDateComponents *comp = [gregorian components:(NSYearCalendarUnit | NSMonthCalendarUnit) fromDate:day];
	[comp setDay:0];
	[comp setMonth:comp.month+1];
	return [gregorian dateFromComponents:comp];
}

- (NSDate*) firstOfMonth{
	TKDateInformation info = [self dateInformationWithTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
	info.day = 1;
	info.minute = 0;
	info.second = 0;
	info.hour = 0;
	return [NSDate dateFromDateInformation:info timeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
}

- (NSDate*) nextMonth{
	
	
	TKDateInformation info = [self dateInformationWithTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
	info.month++;
	if(info.month>12){
		info.month = 1;
		info.year++;
	}
	info.minute = 0;
	info.second = 0;
	info.hour = 0;
	
	return [NSDate dateFromDateInformation:info timeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
	
}

- (NSDate*) previousMonth{
	
	
	TKDateInformation info = [self dateInformationWithTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
	info.month--;
	if(info.month<1){
		info.month = 12;
		info.year--;
	}
	
	info.minute = 0;
	info.second = 0;
	info.hour = 0;
	return [NSDate dateFromDateInformation:info timeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
	
}

- (NSDate*) lastOfMonthDate {
	NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
	NSDateComponents *comp = [gregorian components:(NSYearCalendarUnit | NSMonthCalendarUnit) fromDate:self];
	[comp setDay:0];
	[comp setMonth:comp.month+1];
	NSDate *date = [gregorian dateFromComponents:comp];
    return date;
}

@end


#pragma mark - TKCalendarMonthTiles
@interface TKCalendarMonthTiles : UIView {}

@property (strong,nonatomic) UIFont *countFont;
@property (strong,nonatomic) UIFont *dotFont;
@property (strong,nonatomic) UIFont *dateFont;
@property (assign,nonatomic) TKCalendarMonthView *monthView;
@property (strong,nonatomic) NSDate *monthDate;
@property (strong,nonatomic) NSArray *dates;

+ (NSArray*) rangeOfDatesInMonthGrid:(NSDate*)date startOnSunday:(BOOL)sunday;

- (id) initWithMonth:(NSDate*)date marks:(NSArray*)marks startDayOnSunday:(BOOL)sunday;

- (id) initWithMonth:(NSDate*)date marks:(NSArray*)marks startDayOnSunday:(BOOL)sunday monthView:(TKCalendarMonthView*)monthView;

@end


@implementation TKCalendarMonthTiles {
	id target;
	SEL action;
	
	int firstOfPrev,lastOfPrev;
	NSArray *marks;
	int today;
	BOOL markWasOnToday;
	
	int selectedDay,selectedPortion;
	
	int firstWeekday, daysInMonth;
	UILabel *dot;
	UILabel *currentDay;
	UIImageView *selectedImageView;
	BOOL startOnSunday;
	NSDate *lastDateTouched;
	
	CGMutablePathRef innerShadowPath;
}

@synthesize countFont, dotFont, dateFont, monthView, monthDate, dates;

+ (NSArray*) rangeOfDatesInMonthGrid:(NSDate*)date startOnSunday:(BOOL)sunday{
	
	NSDate *firstDate, *lastDate;
	
	TKDateInformation info = [date dateInformationWithTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
	info.day = 1;
	info.hour = 0;
	info.minute = 0;
	info.second = 0;
	
	NSDate *currentMonth = [NSDate dateFromDateInformation:info timeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
	info = [currentMonth dateInformationWithTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
	
	
	NSDate *previousMonth = [currentMonth previousMonth];
	NSDate *nextMonth = [currentMonth nextMonth];
	
	if(info.weekday > 1 && sunday){
		
		TKDateInformation info2 = [previousMonth dateInformationWithTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
		
		int preDayCnt = [previousMonth daysBetweenDate:currentMonth];		
		info2.day = preDayCnt - info.weekday + 2;
		firstDate = [NSDate dateFromDateInformation:info2 timeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
		
		
	}else if(!sunday && info.weekday != 2){
		
		TKDateInformation info2 = [previousMonth dateInformationWithTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
		int preDayCnt = [previousMonth daysBetweenDate:currentMonth];
		if(info.weekday==1){
			info2.day = preDayCnt - 5;
		}else{
			info2.day = preDayCnt - info.weekday + 3;
		}
		firstDate = [NSDate dateFromDateInformation:info2 timeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
		
		
		
	}else{
		firstDate = currentMonth;
	}
	
	
	
	int daysInMonth = [currentMonth daysBetweenDate:nextMonth];		
	info.day = daysInMonth;
	NSDate *lastInMonth = [NSDate dateFromDateInformation:info timeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
	TKDateInformation lastDateInfo = [lastInMonth dateInformationWithTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];

	
	
	if(lastDateInfo.weekday < 7 && sunday){
		
		lastDateInfo.day = 7 - lastDateInfo.weekday;
		lastDateInfo.month++;
		lastDateInfo.weekday = 0;
		if(lastDateInfo.month>12){
			lastDateInfo.month = 1;
			lastDateInfo.year++;
		}
		lastDate = [NSDate dateFromDateInformation:lastDateInfo timeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
	
	}else if(!sunday && lastDateInfo.weekday != 1){
		
		
		lastDateInfo.day = 8 - lastDateInfo.weekday;
		lastDateInfo.month++;
		if(lastDateInfo.month>12){ lastDateInfo.month = 1; lastDateInfo.year++; }

		
		lastDate = [NSDate dateFromDateInformation:lastDateInfo timeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];

	}else{
		lastDate = lastInMonth;
	}
	
	
	
	return [NSArray arrayWithObjects:firstDate,lastDate,nil];
}

- (id) initWithMonth:(NSDate*)date marks:(NSArray*)markArray startDayOnSunday:(BOOL)sunday{
	if(!(self=[super initWithFrame:CGRectZero])) return nil;

	countFont = [UIFont boldSystemFontOfSize:10];
	dotFont = [UIFont boldSystemFontOfSize:18];
	dateFont = [UIFont boldSystemFontOfSize:22];
	
	firstOfPrev = -1;
	marks = markArray;
	monthDate = date;
	startOnSunday = sunday;
	
	TKDateInformation dateInfo = [monthDate dateInformationWithTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
	firstWeekday = dateInfo.weekday;
	
	NSDate *prev = [monthDate previousMonth];	
	daysInMonth = [[monthDate nextMonth] daysBetweenDate:monthDate];
	
	self.dates = [TKCalendarMonthTiles rangeOfDatesInMonthGrid:date startOnSunday:sunday];
	NSUInteger numberOfDaysBetween = [[self.dates objectAtIndex:0] daysBetweenDate:[self.dates lastObject]];
	NSUInteger scale = (numberOfDaysBetween / 7) + 1;
	CGFloat h = 44.0f * scale;
	
	
	TKDateInformation todayInfo = [[NSDate date] dateInformation];
	today = dateInfo.month == todayInfo.month && dateInfo.year == todayInfo.year ? todayInfo.day : -5;
	
	int preDayCnt = [prev daysBetweenDate:monthDate];		
	if(firstWeekday>1 && sunday){
		firstOfPrev = preDayCnt - firstWeekday+2;
		lastOfPrev = preDayCnt;
	}else if(!sunday && firstWeekday != 2){
		
		if(firstWeekday ==1){
			firstOfPrev = preDayCnt - 5;
		}else{
			firstOfPrev = preDayCnt - firstWeekday+3;
		}
		lastOfPrev = preDayCnt;
	}
	
	
	self.frame = CGRectMake(0, 1.0, 320.0f, h+1);	
	self.multipleTouchEnabled = NO;
	
	return self;
}

- (id) initWithMonth:(NSDate*)date marks:(NSArray*)markArray startDayOnSunday:(BOOL)sunday monthView:(TKCalendarMonthView*)view{
	TKCalendarMonthTiles *tiles = [self initWithMonth:date marks:markArray startDayOnSunday:sunday];
	tiles.monthView = view;
	
	return self;
}


#pragma mark Drawing/Layout Methods
- (CGRect) rectForCellAtIndex:(int)index{
	
	int row = index / 7;
	int col = index % 7;
	
	return CGRectMake(col*46, row*44+6, 47, 45);
}

- (void) drawRect:(CGRect)rect {
	
	if (self.monthView.allowsRangeSelection) {
		innerShadowPath = CGPathCreateMutable();
	}
	
	/* Note: Tiled image gets drawn flipped */
	CGContextRef context = UIGraphicsGetCurrentContext();
	UIImage *tile = [UIImage imageWithContentsOfFile:TKBUNDLE(@"TapkuLibrary.bundle/Images/calendar/Month Calendar Date Tile.png")];
	CGRect r = CGRectMake(0, 0, 46, 44);
	CGContextDrawTiledImage(context, r, tile.CGImage);
	
	int index = 0;
	/* Draw the dates from the end of the last month, if there are any */
	if(firstOfPrev>0){
		for(int i = firstOfPrev;i<= lastOfPrev;i++){
			[self drawTileForIndex:index day:i currentMonth:NO];
			index++;
		}
	}
	
	/* Draw the dates from this month */
	for(int i=1; i <= daysInMonth; i++){
		[self drawTileForIndex:index day:i currentMonth:YES];
		index++;
	}
	
	/* Draw the dates from next month, if there are any */
	int i = 1;
	while(index % 7 != 0){
		[self drawTileForIndex:index day:i currentMonth:NO];
		i++;
		index++;
	}
	
	/* Draw the inner shadow on the selected polygon */
	if (self.monthView.allowsRangeSelection) {
		if (!CGPathIsEmpty(innerShadowPath)) {
			CGContextRef context = UIGraphicsGetCurrentContext();
			
			// Help determining where the shadow is falling
	//		UIColor *aColor = [UIColor whiteColor];
	//		[aColor setFill];
	//		CGContextAddPath(context, innerShadowPath);
	//		CGContextFillPath(context);
			
			/* Technique outlined here http://stackoverflow.com/questions/4431292/inner-shadow-effect-on-uiview-layer */
			CGMutablePathRef path = CGPathCreateMutable();
			CGPathAddRect(path, NULL, CGRectInset(CGPathGetPathBoundingBox(innerShadowPath), -2, -2));
			CGPathAddPath(path, NULL, innerShadowPath);
			CGPathCloseSubpath(path);
			CGContextAddPath(context, innerShadowPath); 
			CGContextClip(context);         
			CGContextSaveGState(context);
			CGContextSetShadowWithColor(context, CGSizeMake(0.0f, 0.0f), 4.0f, [UIColor blackColor].CGColor);   
			CGContextSaveGState(context);   
			CGContextAddPath(context, path);
			CGContextEOFillPath(context);
			CGPathRelease(path);    
		}
		CGPathRelease(innerShadowPath);
	}
}

- (void) drawTileForIndex:(NSUInteger)index day:(NSUInteger)day currentMonth:(BOOL)monthFlag{
	CGRect rect = [self rectForCellAtIndex:index];
	
	NSDate *date = [[self.dates objectAtIndex:0] dateByAddingDays:index];
	NSArray *dateRange = [self.monthView dateRangeSelected];
	NSDate *startDate = [dateRange objectAtIndex:0];
	NSDate *endDate = [dateRange objectAtIndex:1];
	
	/* Determine if this cell is selected or today, and highlight accordingly */
	BOOL selected = [date isBetweenFromDate:startDate toDate:endDate];
	BOOL endpoint = NO;
	BOOL isToday = [date isToday];
	if (selected) {
		CGRect rect2 = rect;
		rect2.origin.y -= 7;
		
		/* Check if this is an end point of the selection */
		if ([date isSameDay:startDate] || [date isSameDay:endDate]) {
			endpoint = YES;
			
			/* Draw black line frame */
			[[UIColor colorWithWhite:0.2f alpha:1.0f] set];
			UIRectFrame(rect2);
			
			/* Draw the gradient */
			CGRect innerRect = CGRectInset(rect2, 1, 1);
			[self drawGradientInRect:innerRect withTintColor:self.monthView.highlightColor];
				  
			/* Draw the header inner white shadow */
			[[UIColor colorWithWhite:1.0f alpha:0.9f] set];
			CGRect headerShadowRect = CGRectMake(innerRect.origin.x, innerRect.origin.y, innerRect.size.width, 1.0);
			UIRectFill(headerShadowRect);
			
			if (self.monthView.allowsRangeSelection) {
				/* Draw left handle if startDate */
				if ([date isSameDay:startDate]) {
					[[UIImage imageWithContentsOfFile:TKBUNDLE(@"TapkuLibrary.bundle/Images/calendar/Month Calendar Endpoint Left.png")] drawInRect:innerRect];
				}
				
				/* Draw right handle if endDate */
				if ([date isSameDay:endDate]) {
					[[UIImage imageWithContentsOfFile:TKBUNDLE(@"TapkuLibrary.bundle/Images/calendar/Month Calendar Endpoint Right.png")] drawInRect:innerRect];
				}
			}
		}
		else {
			
			rect2.origin.y += 1;
			rect2.size.height -= 1;
			rect2.size.width -= 1;
			
			CGRect fillRect = CGRectInset(rect2, 1, 1);
			fillRect.origin.y -= 1;
			fillRect.size.height += 1;
			fillRect.size.width += 1;
			[self.monthView.highlightColor set];
			UIRectFill(fillRect);
			
			/* Add this to the inner shadow path for later */
			CGPathAddRect(innerShadowPath, NULL, rect2);
		}
	}
	else if (isToday) {
		CGRect rect2 = rect;
		rect2.origin.x += 1;
		rect2.origin.y -= 6;
		rect2.size.width -= 2;
		rect2.size.height -= 2;
		
		UIColor *todayColor = [UIColor colorWithRed:115.0f/255.0f green:137.0f/255.0f blue:165.0f/255.0f alpha:1.0f];
		[todayColor set];
		UIRectFill(rect2);
	}

	UIColor *fontColor = [UIColor colorWithRed:59/255. green:73/255. blue:88/255. alpha:1];
	UIColor *shadowColor = [UIColor whiteColor];
	CGFloat shadowOffset = 1;
	
	if (selected || isToday) {
		fontColor = [UIColor whiteColor];
		shadowColor = [UIColor blackColor];
		if (endpoint) {
			shadowOffset = -1;
		}
	}
	else if (!monthFlag) {
		fontColor = [UIColor grayColor];
	}
	
	/* Draw the shadow layer */
	CGRect shadowRect = rect;
	{
		[shadowColor set];
		
		/* Draw the day number */
		NSString *str = [NSString stringWithFormat:@"%d",day];
		shadowRect.size.height -= 2;
		shadowRect.origin.y += shadowOffset;
		[str drawInRect: shadowRect
			   withFont: self.dateFont
		  lineBreakMode: UILineBreakModeWordWrap 
			  alignment: UITextAlignmentCenter];
		
		/* Draw the mark or count */
		NSNumber *mark = [NSNumber numberWithInteger:0];
		if ([marks count] > 0) {
			mark = [marks objectAtIndex:index];
		}
		
		if ([mark integerValue] > 0) {
			if ([mark integerValue] > 1 || self.monthView.showCounts) {
				shadowRect.size.height = 10.0f;
				shadowRect.origin.y += 22.0f;
				
				[[mark stringValue] drawInRect: shadowRect
									  withFont: self.countFont
								 lineBreakMode: UILineBreakModeWordWrap 
									 alignment: UITextAlignmentCenter];
			}
			else if ([mark integerValue] == 1) {
				shadowRect.size.height = 10.0f;
				shadowRect.origin.y += 18.0f + shadowOffset/4.0f;
				
				[@"•" drawInRect: shadowRect
						withFont: self.dotFont
				   lineBreakMode: UILineBreakModeWordWrap 
					   alignment: UITextAlignmentCenter];
			}
		}
	}
	
	/* Draw the text layer */
	{
		[fontColor set];
		
		/* Draw the day number */
		NSString *str = [NSString stringWithFormat:@"%d",day];
		rect.size.height -= 2;
		[str drawInRect: rect
			   withFont: self.dateFont
		  lineBreakMode: UILineBreakModeWordWrap 
			  alignment: UITextAlignmentCenter];
		
		/* Draw the mark or count */
		NSNumber *mark = [NSNumber numberWithInteger:0];
		if ([marks count] > 0) {
			mark = [marks objectAtIndex:index];
		}
		
		if ([mark integerValue] > 0) {
			if ([mark integerValue] > 1 || self.monthView.showCounts) {
				rect.size.height = 10;
				rect.origin.y += 22;
				
				[[mark stringValue] drawInRect: rect
								   withFont: self.countFont
							  lineBreakMode: UILineBreakModeWordWrap 
								  alignment: UITextAlignmentCenter];
			}
			else if ([mark integerValue] == 1) {
				rect.size.height = 10;
				rect.origin.y += 18;
				
				[@"•" drawInRect: rect
						withFont: self.dotFont
				   lineBreakMode: UILineBreakModeWordWrap 
					   alignment: UITextAlignmentCenter];
			}
		}
	}
}

- (void) drawGradientInRect:(CGRect)rect withTintColor:(UIColor *)tintColor{
	CGContextRef context = UIGraphicsGetCurrentContext();
	CGContextSaveGState(context);
	CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceGray();
	
	// FILL GRADIENT	
	const CGFloat *background_gradient;
	const CGFloat *locations;
	NSInteger numberOfColorsInGradient;
	static const CGFloat g0[] = {0.7, 1.0, 0.6, 1.0, 0.5, 1.0, 0.45, 1.0};
	static const CGFloat l0[] = {0.0, 0.47, 0.53, 1.0};
	background_gradient = g0;
	locations = l0;
	numberOfColorsInGradient = 4;
	
	CGRect fillRect = rect;
	CGContextAddRect(context, fillRect);
	CGContextClip(context);
	
	CGGradientRef fillGradient = CGGradientCreateWithColorComponents(colorSpace, background_gradient, locations, numberOfColorsInGradient);	
	CGContextDrawLinearGradient(context, fillGradient, CGPointMake(0, CGRectGetMinY(fillRect)), CGPointMake(0,CGRectGetMaxY(fillRect)), 0);
	CGGradientRelease(fillGradient);
	
	CGColorSpaceRelease(colorSpace);
	
	[tintColor set];
	UIRectFillUsingBlendMode(rect, kCGBlendModeOverlay);	
	
	CGContextRestoreGState(context);
}


#pragma mark Touch Event Methods
- (NSDate*)dateForPoint:(CGPoint)p{
	int column = p.x / 46;
	int row = p.y / 44;
	if (row == (int) (self.bounds.size.height / 44)) {
		row --;	
	}
	
	NSUInteger index = (row * 7) + column;
	NSDate *date = [[self.dates objectAtIndex:0] dateByAddingDays:index];
	
	return date;
}

- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
	CGPoint p = [[touches anyObject] locationInView:self];
	if(p.y > self.bounds.size.height || p.y < 0) return;
	
	NSDate *date = [self dateForPoint:p];
	lastDateTouched = date;

	[self.monthView dateWasTouched:date touchEnded:UIGestureRecognizerStateBegan];
} 

- (void) touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
	CGPoint p = [[touches anyObject] locationInView:self];
	if(p.y > self.bounds.size.height || p.y < 0) return;
	
	NSDate *date = [self dateForPoint:p];

	/* Only trigger update if the date changed */
	if (![date isSameDay:lastDateTouched]) {
		lastDateTouched = date;
		[self.monthView dateWasTouched:date touchEnded:UIGestureRecognizerStateChanged];
	}
}

- (void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
	CGPoint p = [[touches anyObject] locationInView:self];
	if(p.y > self.bounds.size.height || p.y < 0) return;

	lastDateTouched = nil;
	[self.monthView dateWasTouched:[self dateForPoint:p] touchEnded:UIGestureRecognizerStateEnded];	
}

@end


#pragma mark - TKCalendarMonthView

@implementation TKCalendarMonthView {
	TKCalendarMonthTiles *currentTile,*oldTile;
	UIButton *leftArrow, *rightArrow;
	UIImageView *topBackground, *shadow;
	UILabel *monthYear;
	UIScrollView *tileBox;
	BOOL sunday;
	NSInteger endpoint; // -1 = left, 0 = none, 1 = right
}

@synthesize delegate,dataSource,startDateSelected,endDateSelected,showCounts,allowsRangeSelection,highlightColor;

- (id) init{
	self = [self initWithSundayAsFirst:YES];
	return self;
}

- (id) initWithSundayAsFirst:(BOOL)s{
	if (!(self = [super initWithFrame:CGRectZero])) return nil;
	self.backgroundColor = [UIColor grayColor];
	self.showCounts = NO;
	self.allowsRangeSelection = NO;
	self.highlightColor = [UIColor colorWithRed:0 green:114.0f/255.0f blue:226.0f/255.0f alpha:1.0f];
	self.startDateSelected = nil;
	self.endDateSelected = nil;

	sunday = s;
	currentTile = [[TKCalendarMonthTiles alloc] initWithMonth:[[NSDate date] firstOfMonth] marks:nil startDayOnSunday:sunday monthView:self];
	
	CGRect r = CGRectMake(0, 0, self.tileBox.bounds.size.width, self.tileBox.bounds.size.height + self.tileBox.frame.origin.y);
	self.frame = r;
	
	[self addSubview:self.topBackground];
	[self.tileBox addSubview:currentTile];
	[self addSubview:self.tileBox];
	
	NSDate *date = [NSDate date];
	self.monthYear.text = [NSString stringWithFormat:@"%@ %@",[date monthString:NO],[date yearString:NO]];
	[self addSubview:self.monthYear];
	
	
	[self addSubview:self.leftArrow];
	[self addSubview:self.rightArrow];
	[self addSubview:self.shadow];
	self.shadow.frame = CGRectMake(0, self.frame.size.height-self.shadow.frame.size.height+21, self.shadow.frame.size.width, self.shadow.frame.size.height);
	
	
	NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
	[dateFormat setDateFormat:@"eee"];
	[dateFormat setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
	
	TKDateInformation sund;
	sund.day = 5;
	sund.month = 12;
	sund.year = 2010;
	sund.hour = 0;
	sund.minute = 0;
	sund.second = 0;
	sund.weekday = 0;
	
	
	NSTimeZone *tz = [NSTimeZone timeZoneForSecondsFromGMT:0];
	NSString * sun = [dateFormat stringFromDate:[NSDate dateFromDateInformation:sund timeZone:tz]];
	
	sund.day = 6;
	NSString *mon = [dateFormat stringFromDate:[NSDate dateFromDateInformation:sund timeZone:tz]];
	
	sund.day = 7;
	NSString *tue = [dateFormat stringFromDate:[NSDate dateFromDateInformation:sund timeZone:tz]];
	
	sund.day = 8;
	NSString *wed = [dateFormat stringFromDate:[NSDate dateFromDateInformation:sund timeZone:tz]];
	
	sund.day = 9;
	NSString *thu = [dateFormat stringFromDate:[NSDate dateFromDateInformation:sund timeZone:tz]];
	
	sund.day = 10;
	NSString *fri = [dateFormat stringFromDate:[NSDate dateFromDateInformation:sund timeZone:tz]];
	
	sund.day = 11;
	NSString *sat = [dateFormat stringFromDate:[NSDate dateFromDateInformation:sund timeZone:tz]];
	
	NSArray *ar;
	if(sunday) ar = [NSArray arrayWithObjects:sun,mon,tue,wed,thu,fri,sat,nil];
	else ar = [NSArray arrayWithObjects:mon,tue,wed,thu,fri,sat,sun,nil];
	
	int i = 0;
	for(NSString *s in ar){
		UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(46 * i, 29, 46, 15)];
		[self addSubview:label];
		label.text = s;
		label.textAlignment = UITextAlignmentCenter;
		label.shadowColor = [UIColor whiteColor];
		label.shadowOffset = CGSizeMake(0, 1);
		label.font = [UIFont systemFontOfSize:11];
		label.backgroundColor = [UIColor clearColor];
		label.textColor = [UIColor colorWithRed:59/255. green:73/255. blue:88/255. alpha:1];
		i++;
	}
	
	return self;
}

- (NSDate*) dateForMonthChange:(UIView*)sender {
	BOOL isNext = (sender.tag == 1);
	NSDate *nextMonth = isNext ? [currentTile.monthDate nextMonth] : [currentTile.monthDate previousMonth];
	
	TKDateInformation nextInfo = [nextMonth dateInformationWithTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
	NSDate *localNextMonth = [NSDate dateFromDateInformation:nextInfo];
	
	return localNextMonth;
}

- (void) changeMonthAnimation:(UIView*)sender{
	
	BOOL isNext = (sender.tag == 1);
	NSDate *nextMonth = isNext ? [currentTile.monthDate nextMonth] : [currentTile.monthDate previousMonth];
	
	TKDateInformation nextInfo = [nextMonth dateInformationWithTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
	NSDate *localNextMonth = [NSDate dateFromDateInformation:nextInfo];
	
	
	NSArray *dates = [TKCalendarMonthTiles rangeOfDatesInMonthGrid:nextMonth startOnSunday:sunday];
	NSArray *ar = [self.dataSource calendarMonthView:self marksFromDate:[dates objectAtIndex:0] toDate:[dates lastObject]];
	TKCalendarMonthTiles *newTile = [[TKCalendarMonthTiles alloc] initWithMonth:nextMonth marks:ar startDayOnSunday:sunday monthView:self];
	
	int overlap =  0;
	
	if(isNext){
		overlap = [newTile.monthDate isEqualToDate:[dates objectAtIndex:0]] ? 0 : 44;
	}else{
		overlap = [currentTile.monthDate compare:[dates lastObject]] !=  NSOrderedDescending ? 44 : 0;
	}
	
	float y = isNext ? currentTile.bounds.size.height - overlap : newTile.bounds.size.height * -1 + overlap +2;
	
	newTile.frame = CGRectMake(0, y, newTile.frame.size.width, newTile.frame.size.height);
	newTile.alpha = 0;
	[self.tileBox addSubview:newTile];
	
	
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationDuration:0.1];
	newTile.alpha = 1;

	[UIView commitAnimations];
	
	self.userInteractionEnabled = NO;
	
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationDelegate:self];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
	[UIView setAnimationDidStopSelector:@selector(animationEnded)];
	[UIView setAnimationDelay:0.1];
	[UIView setAnimationDuration:0.4];
	
	
	
	if(isNext){
		
		currentTile.frame = CGRectMake(0, -1 * currentTile.bounds.size.height + overlap + 2, currentTile.frame.size.width, currentTile.frame.size.height);
		newTile.frame = CGRectMake(0, 1, newTile.frame.size.width, newTile.frame.size.height);
		self.tileBox.frame = CGRectMake(self.tileBox.frame.origin.x, self.tileBox.frame.origin.y, self.tileBox.frame.size.width, newTile.frame.size.height);
		self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.bounds.size.width, self.tileBox.frame.size.height+self.tileBox.frame.origin.y);
		
		self.shadow.frame = CGRectMake(0, self.frame.size.height-self.shadow.frame.size.height+21, self.shadow.frame.size.width, self.shadow.frame.size.height);
		
		
	}else{
		
		newTile.frame = CGRectMake(0, 1, newTile.frame.size.width, newTile.frame.size.height);
		self.tileBox.frame = CGRectMake(self.tileBox.frame.origin.x, self.tileBox.frame.origin.y, self.tileBox.frame.size.width, newTile.frame.size.height);
		self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.bounds.size.width, self.tileBox.frame.size.height+self.tileBox.frame.origin.y);
		currentTile.frame = CGRectMake(0,  newTile.frame.size.height - overlap, currentTile.frame.size.width, currentTile.frame.size.height);
		
		self.shadow.frame = CGRectMake(0, self.frame.size.height-self.shadow.frame.size.height+21, self.shadow.frame.size.width, self.shadow.frame.size.height);
		
	}
	
	
	[UIView commitAnimations];
	
	oldTile = currentTile;
	currentTile = newTile;

	monthYear.text = [NSString stringWithFormat:@"%@ %@",[localNextMonth monthString:NO],[localNextMonth yearString:NO]];
}

- (void) changeMonth:(UIButton *)sender{
	
	NSDate *newDate = [self dateForMonthChange:sender];
	if ([self.delegate respondsToSelector:@selector(calendarMonthView:monthShouldChange:animated:)] && ![self.delegate calendarMonthView:self monthShouldChange:newDate animated:YES] ) 
		return;
	
	
	if ([self.delegate respondsToSelector:@selector(calendarMonthView:monthWillChange:animated:)] ) 
		[self.delegate calendarMonthView:self monthWillChange:newDate animated:YES];
	
	[self changeMonthAnimation:sender];
	
	if([self.delegate respondsToSelector:@selector(calendarMonthView:monthDidChange:animated:)])
		[self.delegate calendarMonthView:self monthDidChange:currentTile.monthDate animated:YES];
}

- (void) animationEnded{
	self.userInteractionEnabled = YES;
	[oldTile removeFromSuperview];
	oldTile = nil;
}


#pragma mark Date Selection Methods
//- (void)setStartDateSelected:(NSDate *)date{
//	if (date != nil) {
//		startDateSelected = [date timelessDateGMT];
//	}
//	else {
//		startDateSelected = nil;
//	}
//	
//}
//
//- (void)setEndDateSelected:(NSDate *)date{
//	if (date != nil) {
//		endDateSelected = [date timelessDateGMT];
//	}
//	else {
//		endDateSelected = nil;
//	}
//	
//}

- (void) selectDate:(NSDate*)date{
	[self selectFromDate:date toDate:date];
}	

- (void) selectFromDate:(NSDate*)fromDate toDate:(NSDate*)toDate{
	self.startDateSelected = fromDate;
	self.endDateSelected = toDate;
	
	[self dateWasSelected];
}

- (NSDate*) dateSelected{
	return self.startDateSelected;
}

- (NSArray*) dateRangeSelected{	
	if (self.startDateSelected != nil && self.endDateSelected != nil) {		
		NSDate *endDateAdjusted = [[self.endDateSelected dateByAddingDays:1] dateByAddingTimeInterval:-1];
		return [NSArray arrayWithObjects:self.startDateSelected, endDateAdjusted, nil];
	}
	
	return nil;
}

- (void) dateWasSelected{	
	NSDate *date = self.startDateSelected;
	
	if (date != nil) {
		NSDate *month = [date firstOfMonth];
		if([month isEqualToDate:[currentTile monthDate]]){
			if([self.delegate respondsToSelector:@selector(calendarMonthView:didSelectDate:)])
				[self.delegate calendarMonthView:self didSelectDate:[self dateSelected]];
			
			[currentTile setNeedsDisplay];
		}else {
			
			/* Give delegate the option to block this change */
			if ([delegate respondsToSelector:@selector(calendarMonthView:monthShouldChange:animated:)] && ![self.delegate calendarMonthView:self monthShouldChange:month animated:YES] ) 
				return;
			
			/* Alert delegeate of pending month change */
			if ([self.delegate respondsToSelector:@selector(calendarMonthView:monthWillChange:animated:)] )
				[self.delegate calendarMonthView:self monthWillChange:month animated:YES];
			
			/* Build the new month tile */
			NSArray *dates = [TKCalendarMonthTiles rangeOfDatesInMonthGrid:month startOnSunday:sunday];
			NSArray *data = [self.dataSource calendarMonthView:self marksFromDate:[dates objectAtIndex:0] toDate:[dates lastObject]];
			TKCalendarMonthTiles *newTile = [[TKCalendarMonthTiles alloc] initWithMonth:month marks:data startDayOnSunday:sunday monthView:self];

			/* Replace the current month tile with the new month tile.  Adjust position and frame as months may be different number of weeks */
			[currentTile removeFromSuperview];
			currentTile = newTile;
			[self.tileBox addSubview:currentTile];
			self.tileBox.frame = CGRectMake(0, 44, newTile.frame.size.width, newTile.frame.size.height);
			self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.bounds.size.width, self.tileBox.frame.size.height+self.tileBox.frame.origin.y);
			
			/* Update shadow position and month title label */
			self.shadow.frame = CGRectMake(0, self.frame.size.height-self.shadow.frame.size.height+21, self.shadow.frame.size.width, self.shadow.frame.size.height);
			self.monthYear.text = [NSString stringWithFormat:@"%@ %@",[date monthString:NO],[date yearString:NO]];
			
			/* Alert delegeate of month change */
			if([self.delegate respondsToSelector:@selector(calendarMonthView:monthDidChange:animated:)])
				[self.delegate calendarMonthView:self monthDidChange:date animated:NO];
		}
	}
}

- (void) dateWasTouched:(NSDate*)date touchEnded:(UIGestureRecognizerState)touchState{
	if (date != nil) {		
		if (self.allowsRangeSelection) {
			if (touchState == UIGestureRecognizerStateBegan) {
				endpoint = 0;
				endpoint = ([date isSameDay:self.startDateSelected]) ? -1 : (([date isSameDay:self.endDateSelected]) ? 1 : 0);
				
				/* If we don't have a selection or the date isn't one of the end points of the current range */
				if ((self.startDateSelected == nil && self.endDateSelected == nil) || endpoint == 0) {
					self.startDateSelected = date;
					self.endDateSelected = date;
					endpoint = 1;
				}
			}
			else if (touchState == UIGestureRecognizerStateChanged) {
				/* Rest handle selection if we are crossing over with the drag */
				if ([self.startDateSelected isSameDay:date] && [self.endDateSelected isSameDay:date]) {
					endpoint = 0;
					return;
				}
				else {
					/* Extend selection earlier */
					if ([self.startDateSelected earlierDate:date] == date) {
						self.startDateSelected = date;
						
						/* Pick the handle if it is not set */
						if (endpoint == 0) {
							endpoint = -1;
						}
					}
					/* Extend selection later */
					else if ([self.endDateSelected laterDate:date] == date) {
						self.endDateSelected = date;
						
						/* Pick the handle if it is not set */
						if (endpoint == 0) {
							endpoint = 1;
						}
					}
					/* Compress range from one side */
					else {
						if (endpoint == -1) {
							self.startDateSelected = date;
						}
						else if (endpoint == 1) {
							self.endDateSelected = date;
						}
					}
				}
			}
		}
		else {
			self.startDateSelected = date;
			self.endDateSelected = date;
		}
		
		[currentTile setNeedsDisplay];
	}
	
	/* Notify delegate of date selection */	
	if([self.delegate respondsToSelector:@selector(calendarMonthView:didSelectDate:)])
		[self.delegate calendarMonthView:self didSelectDate:[self dateSelected]];
	
	if (self.allowsRangeSelection && [self.delegate respondsToSelector:@selector(calendarMonthView:didSelectFromDate:toDate:)]) {
		NSArray *dateRange = [self dateRangeSelected];
		[self.delegate calendarMonthView:self didSelectFromDate:[dateRange objectAtIndex:0] toDate:[dateRange objectAtIndex:1]];
	}
	
	/* Check if we have a month change */
	if (touchState == UIGestureRecognizerStateEnded && ![date isSameMonth:currentTile.monthDate]) {
		
		UIButton *arrowButton;
		if ([date earlierDate:currentTile.monthDate] == date) {
			arrowButton = self.leftArrow;
		}
		else {
			arrowButton = self.rightArrow;
		}
		
		NSDate* newMonth = [self dateForMonthChange:arrowButton];
		if ([self.delegate respondsToSelector:@selector(calendarMonthView:monthShouldChange:animated:)] && ![delegate calendarMonthView:self monthShouldChange:newMonth animated:YES])
			return;
		
		if ([self.delegate respondsToSelector:@selector(calendarMonthView:monthWillChange:animated:)])					
			[self.delegate calendarMonthView:self monthWillChange:newMonth animated:YES];
		
		[self changeMonthAnimation:arrowButton];
		
		if([self.delegate respondsToSelector:@selector(calendarMonthView:didSelectDate:)])
			[self.delegate calendarMonthView:self didSelectDate:date];
		
		if([self.delegate respondsToSelector:@selector(calendarMonthView:monthDidChange:animated:)])
			[self.delegate calendarMonthView:self monthDidChange:[date monthDate] animated:YES];
	}
}

- (NSDate*) monthDate{
	return [currentTile monthDate];
}


- (void) reload{
	NSArray *dates = [TKCalendarMonthTiles rangeOfDatesInMonthGrid:[currentTile monthDate] startOnSunday:sunday];
	NSArray *ar = [self.dataSource calendarMonthView:self marksFromDate:[dates objectAtIndex:0] toDate:[dates lastObject]];
	
	TKCalendarMonthTiles *refresh = [[TKCalendarMonthTiles alloc] initWithMonth:[currentTile monthDate] marks:ar startDayOnSunday:sunday monthView:self];
	
	[self.tileBox addSubview:refresh];
	[currentTile removeFromSuperview];
	currentTile = refresh;
	
}


#pragma mark Properties
- (UIImageView *) topBackground{
	if(topBackground==nil){
		topBackground = [[UIImageView alloc] initWithImage:[UIImage imageWithContentsOfFile:TKBUNDLE(@"TapkuLibrary.bundle/Images/calendar/Month Grid Top Bar.png")]];
	}
	return topBackground;
}

- (UILabel *) monthYear{
	if(monthYear==nil){
		monthYear = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.tileBox.frame.size.width, 38)];
		
		monthYear.textAlignment = UITextAlignmentCenter;
		monthYear.backgroundColor = [UIColor clearColor];
		monthYear.font = [UIFont boldSystemFontOfSize:22];
		monthYear.textColor = [UIColor colorWithRed:59/255. green:73/255. blue:88/255. alpha:1];
	}
	return monthYear;
}

- (UIButton *) leftArrow{
	if(leftArrow==nil){
		leftArrow = [UIButton buttonWithType:UIButtonTypeCustom];
		leftArrow.tag = 0;
		[leftArrow addTarget:self action:@selector(changeMonth:) forControlEvents:UIControlEventTouchUpInside];
		[leftArrow setImage:[UIImage imageNamedTK:@"TapkuLibrary.bundle/Images/calendar/Month Calendar Left Arrow"] forState:0];
		leftArrow.frame = CGRectMake(0, 0, 48, 38);
	}
	return leftArrow;
}

- (UIButton *) rightArrow{
	if(rightArrow==nil){
		rightArrow = [UIButton buttonWithType:UIButtonTypeCustom];
		rightArrow.tag = 1;
		[rightArrow addTarget:self action:@selector(changeMonth:) forControlEvents:UIControlEventTouchUpInside];
		rightArrow.frame = CGRectMake(320-45, 0, 48, 38);
		[rightArrow setImage:[UIImage imageNamedTK:@"TapkuLibrary.bundle/Images/calendar/Month Calendar Right Arrow"] forState:0];
	}
	return rightArrow;
}

- (UIScrollView *) tileBox{
	if(tileBox==nil){
		tileBox = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 44, 320, currentTile.frame.size.height)];
	}
	return tileBox;
}

- (UIImageView *) shadow{
	if(shadow==nil){
		shadow = [[UIImageView alloc] initWithImage:[UIImage imageWithContentsOfFile:TKBUNDLE(@"TapkuLibrary.bundle/Images/calendar/Month Calendar Shadow.png")]];
	}
	return shadow;
}

@end