//
//  THDateProcessor.m
//  TimeTreasury
//
//  Created by WangHenry on 6/7/14.
//  Copyright (c) 2014 WangHenry. All rights reserved.
//

#import "THDateProcessor.h"

@implementation THDateProcessor


//get date from string with local identifier "en_US"
+(NSDate*)dateFromString:(NSString*)dateString withTimeZone:(NSTimeZone*)timeZone withFormat:(NSString*)format
{
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setTimeZone:timeZone];
    [dateFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"]];
    [dateFormatter setDateFormat:format];
    NSDate *date = [dateFormatter dateFromString:dateString];
    return date;
}


//convert seconds to hh/mm/ss formate
+(NSString*)timeFromSecond:(CGFloat)seconds withFormateDescriptor:(NSString*)descriptor
{
    NSInteger secondsInt = (int)seconds;
    NSInteger day = secondsInt/86400;
    NSInteger hour = secondsInt/3600;
    NSInteger minute = (secondsInt%3600)/60;
    NSInteger second = (secondsInt%3600%60);
    NSString* time = NULL;
    if ([descriptor isEqualToString:@"hh:mm:ss"]) {
    time = [NSString stringWithFormat:@"%3ld:%02ld:%02ld",(long)hour,(long)minute,(long)second];
    }
    else if([descriptor isEqualToString:@"dddhhhmmmsss"])
    {
        if (day>0) {
            time = [NSString stringWithFormat:@"%ldd%ldh%ldm%lds",(long)day, (long)hour,(long)minute,(long)second];
        }
        else if(hour>0){
            time = [NSString stringWithFormat:@"%ldh%ldm%lds",(long)hour,(long)minute,(long)second];
        }
        else if(minute>0)
        {
            time = [NSString stringWithFormat:@"%ldm%lds",(long)minute,(long)second];
        }
        else
        {
            time = [NSString stringWithFormat:@"%lds",(long)second];
        }
    }
    return time;
}

//get the start time and end time of a day from a date
+(NSArray*)getBoundaryDateBy:(NSDate*)date
{
    //gather current calendar
    NSCalendar *calendar = [NSCalendar currentCalendar];
    
    //gather date components from date
    NSDateComponents *dateComponents = [calendar components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit) fromDate:date];
    
    //set date components
    [dateComponents setHour:0];
    [dateComponents setMinute:0];
    [dateComponents setSecond:0];
    NSDate* startDate = [calendar dateFromComponents:dateComponents];
    
    [dateComponents setHour:23];
    [dateComponents setMinute:59];
    [dateComponents setSecond:59];
    NSDate* endDate = [calendar dateFromComponents:dateComponents];
    
    NSArray* array = [[NSArray alloc] initWithObjects:startDate,endDate, nil];
    return array;
}

//change date to today
+(NSDate*)dateToToday:(NSDate*)date
{
    //gather current calendar
    NSCalendar *calendar = [NSCalendar currentCalendar];
    
    //gather date components from date
    NSDateComponents *dateComponents = [calendar components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit) fromDate:[NSDate date]];
    NSDateComponents *oriDateComponents = [calendar components:(NSHourCalendarUnit|NSMinuteCalendarUnit|NSSecondCalendarUnit) fromDate:date];
    //set date components
    [dateComponents setHour:oriDateComponents.hour];
    [dateComponents setMinute:oriDateComponents.minute];
    [dateComponents setSecond:oriDateComponents.second];
    NSDate* returnDate = [calendar dateFromComponents:dateComponents];
    NSLog(@"origdate:%@,todaydate:%@",date,returnDate);
    return returnDate;
}

+(BOOL)isSameDay:(NSDate*)date1 andDate:(NSDate*)date2
{
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
    [dateFormatter setTimeStyle:NSDateFormatterNoStyle];
    NSString* startDatestr = [dateFormatter stringFromDate:date1];
    NSString* endDatestr = [dateFormatter stringFromDate:date2];
    return [startDatestr isEqualToString:endDatestr];

}

+ (NSDate *)dateWithoutTime:(NSDate*)date
{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    calendar.timeZone = [NSTimeZone defaultTimeZone];
    NSDateComponents *components = [calendar components:(NSYearCalendarUnit
                                                         | NSMonthCalendarUnit
                                                         | NSDayCalendarUnit )
                                               fromDate:date];
    
    return [calendar dateFromComponents:components];
}
@end
