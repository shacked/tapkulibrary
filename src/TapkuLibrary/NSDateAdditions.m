//
//  NSDateAdditions.m
//  Dater
//
//  Created by Devin Ross on 7/28/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "NSDateAdditions.h"


@implementation NSDate (TKCategory)

+ (NSDate*) firstOfCurrentMonth{
	
	NSDate *day = [NSDate date];
	NSCalendar *gregorian = [[[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar] autorelease];
	NSDateComponents *comp = [gregorian components:(NSYearCalendarUnit | NSMonthCalendarUnit) fromDate:day];
	[comp setDay:1];
	return [gregorian dateFromComponents:comp];
	
}

+ (NSDate*) lastOfCurrentMonth{
	NSDate *day = [NSDate date];
	NSCalendar *gregorian = [[[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar] autorelease];
	NSDateComponents *comp = [gregorian components:(NSYearCalendarUnit | NSMonthCalendarUnit) fromDate:day];
	[comp setDay:0];
	[comp setMonth:comp.month+1];
	return [gregorian dateFromComponents:comp];
}

- (NSDate*) timelessDate {
	NSDate *day = self;
	NSCalendar *gregorian = [[[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar] autorelease];
	NSDateComponents *comp = [gregorian components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit) fromDate:day];
	return [gregorian dateFromComponents:comp];
}

- (NSDate*) monthlessDate {
	NSDate *day = self;
	NSCalendar *gregorian = [[[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar] autorelease];
	NSDateComponents *comp = [gregorian components:(NSYearCalendarUnit | NSMonthCalendarUnit) fromDate:day];
	return [gregorian dateFromComponents:comp];
}


- (NSDate*) firstOfCurrentMonthForDate {
	
	NSDate *day = self;
	NSCalendar *gregorian = [[[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar] autorelease];
	NSDateComponents *comp = [gregorian components:(NSYearCalendarUnit | NSMonthCalendarUnit) fromDate:day];
	[comp setDay:1];
	return [gregorian dateFromComponents:comp];
	
}

- (NSDate*) firstOfNextMonthForDate {
	NSDate *day = self;
	NSCalendar *gregorian = [[[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar] autorelease];
	NSDateComponents *comp = [gregorian components:(NSYearCalendarUnit | NSMonthCalendarUnit) fromDate:day];
	[comp setDay:1];
	[comp setMonth:comp.month+1];
	return [gregorian dateFromComponents:comp];
}


- (NSNumber*) dayNumber{
	NSDateFormatter *dateFormatter = [[[NSDateFormatter alloc] init] autorelease];	
	[dateFormatter setDateFormat:@"d"];
	return [NSNumber numberWithInt:[[dateFormatter stringFromDate:self] intValue]];
}

- (NSString*) hourString {
	NSDateFormatter *dateFormatter = [[[NSDateFormatter alloc] init] autorelease];	
	[dateFormatter setDateFormat:@"h a"];
	return [dateFormatter stringFromDate:self];
}

- (NSString*) monthString{
	NSDateFormatter *dateFormatter = [[[NSDateFormatter alloc] init] autorelease];	
	[dateFormatter setDateFormat:@"MMMM"];
	return [dateFormatter stringFromDate:self];
}

- (NSString*) yearString{
	NSDateFormatter *dateFormatter = [[[NSDateFormatter alloc] init] autorelease];	
	[dateFormatter setDateFormat:@"yyyy"];
	return [dateFormatter stringFromDate:self];
}

- (NSString*) monthYearString{
	NSDateFormatter *dateFormatter = [[[NSDateFormatter alloc] init] autorelease];	
	[dateFormatter setDateFormat:@"MMMM yyyy"];
	return [dateFormatter stringFromDate:self];
}

- (int) weekday{
	
	NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
	NSDateComponents *comps = [gregorian components:(NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit | NSWeekdayCalendarUnit) fromDate:self];
	int weekday = [comps weekday];
	[gregorian release];
	return weekday;
}


// Calendar starting on Monday instead of Sunday (Australia, Europe against US american calendar)
- (int) weekdayMondayFirst{
	
	NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
	NSDateComponents *comps = [gregorian components:(NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit | NSWeekdayCalendarUnit) fromDate:self];
	int weekday = [comps weekday];
	[gregorian release];
	
	CFCalendarRef currentCalendar = CFCalendarCopyCurrent();
	if (CFCalendarGetFirstWeekday(currentCalendar) == 2) {
		weekday -= 1;
		if (weekday == 0) {
			weekday = 7;
		}
	}
	CFRelease(currentCalendar);
	
	return weekday;
}

- (int) daysInMonth{

	NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
	NSDateComponents *comp = [gregorian components:(NSYearCalendarUnit | NSMonthCalendarUnit) fromDate:self];
	[comp setDay:0];
	[comp setMonth:comp.month+1];
	
	int days = [[gregorian components:NSDayCalendarUnit fromDate:[gregorian dateFromComponents:comp]] day];
	[gregorian release];
	
	return days;
}

- (int) month
{
	// !!! hour between 0 - 24 - Check at midnight
	
	NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
	NSDateComponents *comp = [gregorian components:(NSMonthCalendarUnit) fromDate:self];
	
	int month = [comp month];
	[gregorian release];
	
	return month;
}

- (int) hour
{
	// !!! hour between 0 - 24 - Check at midnight
	
	NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
	NSDateComponents *comp = [gregorian components:(NSHourCalendarUnit) fromDate:self];
	
	int hour = [comp hour];
	[gregorian release];
	
	return hour;
}

- (int) minute
{
	NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
	NSDateComponents *comp = [gregorian components:(NSMinuteCalendarUnit) fromDate:self];
	
	int minute = [comp minute];
	[gregorian release];
	
	return minute;
}

/* ----- start snippet from http://www.alexcurylo.com/blog/2009/07/25/snippet-naturaldates/ ----- */


- (int)differenceInDaysTo:(NSDate *)toDate
{
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    
    NSDateComponents *components = [gregorian components:NSDayCalendarUnit
                                                fromDate:self
                                                  toDate:toDate
                                                 options:0];
    NSInteger days = [components day];
    [gregorian release];
    return days;
}

/* ----- end snippet from http://www.alexcurylo.com/blog/2009/07/25/snippet-naturaldates/ ----- */


- (int)differenceInMonthsTo:(NSDate *)toDate
{
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    
    NSDateComponents *components = [gregorian components:NSMonthCalendarUnit
                                                fromDate:[self monthlessDate]
                                                  toDate:[toDate monthlessDate]
                                                 options:0];
    NSInteger months = [components month];
    [gregorian release];
    return months;
}

/* ----- start snippet from http://www.alexcurylo.com/blog/2009/07/25/snippet-naturaldates/ ----- */

- (BOOL)isSameDay:(NSDate*)anotherDate
{
	NSCalendar* calendar = [NSCalendar currentCalendar];
	NSDateComponents* components1 = [calendar components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit) fromDate:self];
	NSDateComponents* components2 = [calendar components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit) fromDate:anotherDate];
	return ([components1 year] == [components2 year] && [components1 month] == [components2 month] && [components1 day] == [components2 day]);
} 

- (BOOL)isToday
{
	return [self isSameDay:[NSDate date]];
} 
 
/* ----- end snippet from http://www.alexcurylo.com/blog/2009/07/25/snippet-naturaldates/ ----- */

@end