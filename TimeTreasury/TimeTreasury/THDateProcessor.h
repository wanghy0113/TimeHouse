//
//  THDateProcessor.h
//  TimeTreasury
//
//  Created by WangHenry on 6/7/14.
//  Copyright (c) 2014 WangHenry. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface THDateProcessor : NSObject
//get date from string with local identifier "en_US"
+(NSDate*)dateFromString:(NSString*)dateString withTimeZone:(NSTimeZone*)timeZone withFormat:(NSString*)format;

//convert seconds to hh/mm/ss formate
+(NSString*)timeFromSecond:(CGFloat)seconds withFormateDescriptor:(NSString*)descriptor;

//get the start time and end time of a day from a date
+(NSArray*)getBoundaryDateBy:(NSDate*)date;

+(NSDate*)dateToToday:(NSDate*)date;

+(BOOL)isSameDay:(NSDate*)date1 andDate:(NSDate*)date2;

+(BOOL)isBetweenDays:(NSDate*)day between:(NSDate*)start and:(NSDate*)end;

/**
 * Returns current (self) date without time components. Effectively, it's just a beginning of a day.
 */
+(NSDate *) dateWithoutTime:(NSDate*)date;

+(NSDate *)combineDates:(NSDate*)day andTime:(NSDate*)time;

@end
