//
//  NSDateAdditions.m
//  Created by Devin Ross on 7/28/09.
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
#import "NSDate+TKCategory.h"

static NSString *gregorianSyncToken = @"gregorianSyncToken";
static NSString *currentCalendarSyncToken = @"currentCalendarSyncToken";
static NSString *utcDayDateFormatterSyncToken = @"utcDayDateFormatterSyncToken";
static NSString *systemDayDateFormatterSyncToken = @"systemDayDateFormatterSyncToken";
static NSString *utcMonthDateFormatterSyncToken = @"utcMonthDateFormatterSyncToken";
static NSString *systemMonthDateFormatterSyncToken = @"systemMonthDateFormatterSyncToken";

@implementation NSDate (TKCategory)

+ (NSCalendar*)gregorian; {
	static NSCalendar *gregorian = nil;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
	});
	
	return gregorian;
}

+ (NSCalendar*)currentCalendar; {
	static NSCalendar *currentCalendar = nil;
	static dispatch_once_t onceToken2;
	dispatch_once(&onceToken2, ^{
		currentCalendar = [NSCalendar currentCalendar];
	});
	
	return currentCalendar;
}

+ (NSDateFormatter*)utcDayDateFormatter; {
	static NSDateFormatter *utcDayDateFormatter = nil;
	static dispatch_once_t onceToken3;
	dispatch_once(&onceToken3, ^{
		utcDayDateFormatter = [[NSDateFormatter alloc] init];
		[utcDayDateFormatter setDateFormat:@"yyyy-MM-dd"];
		[utcDayDateFormatter setTimeZone:[NSTimeZone timeZoneWithName:@"GMT"]];
	});
	
	return utcDayDateFormatter;
}

+ (NSDateFormatter*)systemDayDateFormatter; {
	static NSDateFormatter *systemDayDateFormatter = nil;
	static dispatch_once_t onceToken5;
	dispatch_once(&onceToken5, ^{
		systemDayDateFormatter = [[NSDateFormatter alloc] init];
		[systemDayDateFormatter setDateFormat:@"yyyy-MM-dd"];
	});
	
	return systemDayDateFormatter;
}

+ (NSDateFormatter*)utcMonthDateFormatter; {
	static NSDateFormatter *utcMonthDateFormatter = nil;
	static dispatch_once_t onceToken4;
	dispatch_once(&onceToken4, ^{
		utcMonthDateFormatter = [[NSDateFormatter alloc] init];
		[utcMonthDateFormatter setDateFormat:@"yyyy-MM"];
		[utcMonthDateFormatter setTimeZone:[NSTimeZone timeZoneWithName:@"GMT"]];
	});
	
	return utcMonthDateFormatter;
}

+ (NSDateFormatter*)systemMonthDateFormatter; {
	static NSDateFormatter *systemMonthDateFormatter = nil;
	static dispatch_once_t onceToken6;
	dispatch_once(&onceToken6, ^{
		systemMonthDateFormatter = [[NSDateFormatter alloc] init];
		[systemMonthDateFormatter setDateFormat:@"yyyy-MM"];
	});
	
	return systemMonthDateFormatter;
}

+ (NSDate*) yesterday{
	TKDateInformation inf = [[NSDate date] dateInformation];
	inf.day--;
	return [NSDate dateFromDateInformation:inf];
}

+ (NSDate*) month{
    return [[NSDate date] monthDate];
}

- (NSDate*) monthDate {
	NSDate *date = nil;
	
	@synchronized(gregorianSyncToken) {
		NSCalendar *gregorian = [NSDate gregorian];
		NSDateComponents *comp = [gregorian components:(NSYearCalendarUnit | NSMonthCalendarUnit) fromDate:self];
		[comp setDay:1];
		date = [gregorian dateFromComponents:comp];
	}
	
    return date;
}


- (int) weekday{
	int weekday = 0;
	
	@synchronized(gregorianSyncToken) {
		NSCalendar *gregorian = [NSDate gregorian];
		NSDateComponents *comps = [gregorian components:(NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit | NSWeekdayCalendarUnit) fromDate:self];
		weekday = [comps weekday];
	}
	
	return weekday;
}

- (NSDate*) timelessDate {
	NSDate *date = nil;
	
	@synchronized(gregorianSyncToken) {
		NSCalendar *gregorian = [NSDate gregorian];
		NSDateComponents *comp = [gregorian components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit) fromDate:self];
		date = [gregorian dateFromComponents:comp];
	}
	
	return date;
}

- (NSDate*) timelessDateGMT {
	TKDateInformation info = [self dateInformation];
	info.hour = 0;
	info.minute = 0;
	info.second = 0;
	
	return [NSDate dateFromDateInformation:info timeZone:[NSTimeZone timeZoneWithName:@"GMT"]];
}

- (NSDate*) monthlessDate {
	NSDate *date = nil;
	
	@synchronized(gregorianSyncToken) {
		NSCalendar *gregorian = [NSDate gregorian];
		NSDateComponents *comp = [gregorian components:(NSYearCalendarUnit | NSMonthCalendarUnit) fromDate:self];
		date = [gregorian dateFromComponents:comp];
	}
	
	return date;
}

- (BOOL) isToday{
	NSString *todayString = nil;
	@synchronized(systemDayDateFormatterSyncToken) {
		NSDateFormatter *systemDayDateFormatter = [NSDate systemDayDateFormatter];
		todayString = [systemDayDateFormatter stringFromDate:[NSDate date]];
	}
	
	NSString *selfDayString = nil;
	@synchronized(utcDayDateFormatterSyncToken) {
		NSDateFormatter *utcDayDateFormatter = [NSDate utcDayDateFormatter];
		selfDayString = [utcDayDateFormatter stringFromDate:self];
	}
	
	return [todayString isEqualToString:selfDayString];
}

- (BOOL) isFutureDate {
	NSString *todayString = nil;
	@synchronized(systemDayDateFormatterSyncToken) {
		NSDateFormatter *systemDayDateFormatter = [NSDate systemDayDateFormatter];
		todayString = [systemDayDateFormatter stringFromDate:[NSDate date]];
	}
	
	NSString *selfDayString = nil;
	@synchronized(utcDayDateFormatterSyncToken) {
		NSDateFormatter *utcDayDateFormatter = [NSDate utcDayDateFormatter];
		selfDayString = [utcDayDateFormatter stringFromDate:self];
	}
	
	return ([todayString compare:selfDayString] == NSOrderedAscending);
}

- (BOOL) isSameDay:(NSDate*)anotherDate{
	NSString *anotherDayString = nil;
	NSString *selfDayString = nil;
	
	@synchronized(utcDayDateFormatterSyncToken) {
		NSDateFormatter *utcDayDateFormatter = [NSDate utcDayDateFormatter];
		anotherDayString = [utcDayDateFormatter stringFromDate:anotherDate];
		selfDayString = [utcDayDateFormatter stringFromDate:self];
	}
	
	return [anotherDayString isEqualToString:selfDayString];	
}

- (BOOL) isSameMonth:(NSDate*)anotherDate{
	TKDateInformation info1 = [self dateInformationWithTimeZone:[NSTimeZone timeZoneWithName:@"GMT"]];
	TKDateInformation info2 = [anotherDate dateInformationWithTimeZone:[NSTimeZone timeZoneWithName:@"GMT"]];
	return (info1.year == info2.year && info1.month == info2.month);
} 

- (BOOL) isBetweenFromDate:(NSDate*)fromDate toDate:(NSDate*)toDate{
	if (fromDate == nil || toDate == nil) return NO;
	
	return ([self isEqualToDate:fromDate] || [self isEqualToDate:toDate] ||
			([self laterDate:fromDate] == self && [self earlierDate:toDate] == self));
}

/* This implementation fails */
- (int) monthsBetweenDate:(NSDate *)toDate{
	NSInteger months = 0;
	@synchronized(gregorianSyncToken) {
		NSCalendar *gregorian = [NSDate gregorian];
		NSDateComponents *components = [gregorian components:NSMonthCalendarUnit
													fromDate:[self monthlessDate]
													  toDate:[toDate monthlessDate]
													 options:0];
		months = [components month];
	}
	
    return abs(months);
}

- (NSInteger) daysBetweenDate:(NSDate*)date {
    NSTimeInterval time = [self timeIntervalSinceDate:date];
    return ((abs(time) / (60.0 * 60.0 * 24.0)) + 0.5);
}

- (NSDate *) dateByAddingDays:(NSInteger)days {
	NSDateComponents *c = [[NSDateComponents alloc] init];
	c.day = days;
	
	NSDate *date = nil;
	
	@synchronized(currentCalendarSyncToken) {
		NSCalendar *currentCalendar = [NSDate currentCalendar];
		date = [currentCalendar dateByAddingComponents:c toDate:self options:0];
	}
	
	return date;
}

+ (NSDate *) dateWithDatePart:(NSDate *)aDate andTimePart:(NSDate *)aTime {
	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	[dateFormatter setDateFormat:@"dd/MM/yyyy"];
	NSString *datePortion = [dateFormatter stringFromDate:aDate];
	
	[dateFormatter setDateFormat:@"HH:mm"];
	NSString *timePortion = [dateFormatter stringFromDate:aTime];
	
	[dateFormatter setDateFormat:@"dd/MM/yyyy HH:mm"];
	NSString *dateTime = [NSString stringWithFormat:@"%@ %@",datePortion,timePortion];
	return [dateFormatter dateFromString:dateTime];
}


- (NSString*) dayString:(BOOL)inUTC{
	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];	
	[dateFormatter setDateFormat:@"dd"];
	if (inUTC) {
		[dateFormatter setTimeZone:[NSTimeZone timeZoneWithName:@"GMT"]];
	}
	return [dateFormatter stringFromDate:self];
}

- (NSString*) monthString:(BOOL)inUTC{
	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];	
	[dateFormatter setDateFormat:@"MMMM"];
	if (inUTC) {
		[dateFormatter setTimeZone:[NSTimeZone timeZoneWithName:@"GMT"]];
	}
	return [dateFormatter stringFromDate:self];
}

- (NSString*) yearString:(BOOL)inUTC{
	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];	
	[dateFormatter setDateFormat:@"yyyy"];
	if (inUTC) {
		[dateFormatter setTimeZone:[NSTimeZone timeZoneWithName:@"GMT"]];
	}
	return [dateFormatter stringFromDate:self];
}

- (NSString*) isoDateString:(BOOL)inUTC{
	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];	
	[dateFormatter setDateFormat:@"yyyy-MM-dd"];
	if (inUTC) {
		[dateFormatter setTimeZone:[NSTimeZone timeZoneWithName:@"GMT"]];
	}
	return [dateFormatter stringFromDate:self];
}

- (NSString*) isoTimeString:(BOOL)inUTC{
	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];	
	[dateFormatter setDateFormat:@"HH:mm:ss"];
	if (inUTC) {
		[dateFormatter setTimeZone:[NSTimeZone timeZoneWithName:@"GMT"]];
	}
	return [dateFormatter stringFromDate:self];
}

+ (NSDate*) isoDateFromString:(NSString*)string inUTC:(BOOL)inUTC {
	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	[dateFormatter setDateFormat:@"yyyy-MM-dd"];
	if (inUTC) {
		[dateFormatter setTimeZone:[NSTimeZone timeZoneWithName:@"GMT"]];
	}
	return [dateFormatter dateFromString:string];
}

+ (NSDate*) lastofMonthDate{
    NSDate *day = nil;

	@synchronized(gregorianSyncToken) {
		NSCalendar *gregorian = [[NSDate date] gregorian];
		NSDateComponents *comp = [gregorian components:(NSYearCalendarUnit | NSMonthCalendarUnit) fromDate: [NSDate date]];
		[comp setDay:0];
		[comp setMonth:comp.month+1];
		day = [gregorian dateFromComponents:comp];
	}
	
	return day;
}

+ (NSDate*) lastOfCurrentMonth{
	NSDate *day = nil;
	
	@synchronized(gregorianSyncToken) {
		NSCalendar *gregorian = [NSDate gregorian];
		NSDateComponents *comp = [gregorian components:(NSYearCalendarUnit | NSMonthCalendarUnit) fromDate:[NSDate date]];
		[comp setDay:0];
		[comp setMonth:comp.month+1];
		day = [gregorian dateFromComponents:comp];
	}
	
	return day;
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
	NSDate *date = nil;
	
	@synchronized(gregorianSyncToken) {
		NSCalendar *gregorian = [NSDate gregorian];
		NSDateComponents *comp = [gregorian components:(NSYearCalendarUnit | NSMonthCalendarUnit) fromDate:self];
		[comp setDay:0];
		[comp setMonth:comp.month+1];
		date = [gregorian dateFromComponents:comp];
	}
	
    return date;
}

- (TKDateInformation) dateInformationWithTimeZone:(NSTimeZone*)tz{
	
	TKDateInformation info;
	NSDate *date = [NSDate dateWithTimeIntervalSince1970:[self timeIntervalSince1970]];
	
	@synchronized(gregorianSyncToken) {
		NSCalendar *gregorian = [NSDate gregorian];
		[gregorian setTimeZone:tz];
		NSDateComponents *comp = [gregorian components:(NSMonthCalendarUnit | NSMinuteCalendarUnit | NSYearCalendarUnit | 
														NSDayCalendarUnit | NSWeekdayCalendarUnit | NSHourCalendarUnit | NSSecondCalendarUnit) 
											  fromDate:date];
		info.day = [comp day];
		info.month = [comp month];
		info.year = [comp year];
		
		info.hour = [comp hour];
		info.minute = [comp minute];
		info.second = [comp second];
		
		info.weekday = [comp weekday];
	}
	
	return info;
	
}
- (TKDateInformation) dateInformation{
	
	TKDateInformation info;
	NSDate *date = [NSDate dateWithTimeIntervalSince1970:[self timeIntervalSince1970]];
	
	@synchronized(gregorianSyncToken) {
		NSCalendar *gregorian = [NSDate gregorian];
		NSDateComponents *comp = [gregorian components:(NSMonthCalendarUnit | NSMinuteCalendarUnit | NSYearCalendarUnit |
														NSDayCalendarUnit | NSWeekdayCalendarUnit | NSHourCalendarUnit | NSSecondCalendarUnit) 
											  fromDate:date];
		info.day = [comp day];
		info.month = [comp month];
		info.year = [comp year];
		
		info.hour = [comp hour];
		info.minute = [comp minute];
		info.second = [comp second];
		
		info.weekday = [comp weekday];
	}
    
	return info;
}
+ (NSDate*) dateFromDateInformation:(TKDateInformation)info timeZone:(NSTimeZone*)tz{
	NSDate *date = nil;
	
	@synchronized(gregorianSyncToken) {
		NSCalendar *gregorian = [NSDate gregorian];
		[gregorian setTimeZone:tz];
		NSDateComponents *comp = [gregorian components:(NSYearCalendarUnit | NSMonthCalendarUnit) fromDate:[NSDate date]];
		
		[comp setDay:info.day];
		[comp setMonth:info.month];
		[comp setYear:info.year];
		[comp setHour:info.hour];
		[comp setMinute:info.minute];
		[comp setSecond:info.second];
		[comp setTimeZone:tz];
		
		date = [gregorian dateFromComponents:comp];
	}
	
	return date;
}

+ (NSDate*) dateFromDateInformation:(TKDateInformation)info{
	NSDate *date = nil;
	
	@synchronized(gregorianSyncToken) {
		NSCalendar *gregorian = [NSDate gregorian];
		NSDateComponents *comp = [gregorian components:(NSYearCalendarUnit | NSMonthCalendarUnit) fromDate:[NSDate date]];
		
		[comp setDay:info.day];
		[comp setMonth:info.month];
		[comp setYear:info.year];
		[comp setHour:info.hour];
		[comp setMinute:info.minute];
		[comp setSecond:info.second];
		//[comp setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
		
		date = [gregorian dateFromComponents:comp];
	}
	
	return date;
}

+ (NSString*) dateInformationDescriptionWithInformation:(TKDateInformation)info{
	return [NSString stringWithFormat:@"%d %d %d %d:%d:%d",info.month,info.day,info.year,info.hour,info.minute,info.second];
}

@end
