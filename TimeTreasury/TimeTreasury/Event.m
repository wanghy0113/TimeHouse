//
//  Event.m
//  TimeTreasury
//
//  Created by WangHenry on 9/5/14.
//  Copyright (c) 2014 WangHenry. All rights reserved.
//

#import "Event.h"
#import "EventModel.h"


@implementation Event

@dynamic eventDay;
@dynamic duration;
@dynamic endTime;
@dynamic guid;
@dynamic notification;
@dynamic startTime;
@dynamic status;
@dynamic note;
@dynamic eventModel;

@end

@implementation Notification

+(Class)transformedValueClass
{
    return [UILocalNotification class];
}

+(BOOL)allowsReverseTransformation
{
    return YES;
}

-(id)transformedValue:(id)value
{
    return [NSKeyedArchiver archivedDataWithRootObject:value];
}

-(id)reverseTransformedValue:(id)value
{
    return [NSKeyedUnarchiver unarchiveObjectWithData:value];
}

@end
