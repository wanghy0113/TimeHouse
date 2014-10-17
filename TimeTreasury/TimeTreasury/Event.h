//
//  Event.h
//  TimeTreasury
//
//  Created by WangHenry on 9/5/14.
//  Copyright (c) 2014 WangHenry. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class EventModel;

@interface Event : NSManagedObject

@property (nonatomic, retain) NSString * date;
@property (nonatomic, retain) NSNumber * duration;
@property (nonatomic, retain) NSDate * endTime;
@property (nonatomic, retain) NSString * guid;
@property (nonatomic, retain) id notification;
@property (nonatomic, retain) NSDate * startTime;
@property (nonatomic, retain) NSNumber * status;
@property (nonatomic, retain) EventModel *eventModel;

@end

@interface Notification : NSValueTransformer

@end
