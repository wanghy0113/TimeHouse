//
//  EventModel.m
//  TimeTreasury
//
//  Created by WangHenry on 9/5/14.
//  Copyright (c) 2014 WangHenry. All rights reserved.
//

#import "EventModel.h"
#import "Event.h"


@implementation EventModel

@dynamic audioGuid;
@dynamic category;
@dynamic doneTime;
@dynamic guid;
@dynamic name;
@dynamic photoGuid;
@dynamic planedEndTime;
@dynamic planedStartTime;
@dynamic regularDay;
@dynamic shouldSaveAsModel;
@dynamic totalDuration;
@dynamic type;
@dynamic event;

@end

@implementation RegularDay

+(Class)transformedValueClass
{
    return [NSArray class];
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

