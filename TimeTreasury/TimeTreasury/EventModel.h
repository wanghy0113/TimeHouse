//
//  EventModel.h
//  TimeTreasury
//
//  Created by WangHenry on 9/5/14.
//  Copyright (c) 2014 WangHenry. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Event;

@interface EventModel : NSManagedObject

@property (nonatomic, retain) NSString * audioGuid;
@property (nonatomic, retain) NSNumber * category;
@property (nonatomic, retain) NSNumber * doneTime;
@property (nonatomic, retain) NSString * guid;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * photoGuid;
@property (nonatomic, retain) NSDate * planedEndTime;
@property (nonatomic, retain) NSDate * planedStartTime;
@property (nonatomic, retain) id regularDay;
@property (nonatomic, retain) NSNumber * shouldSaveAsModel;
@property (nonatomic, retain) NSNumber * totalDuration;
@property (nonatomic, retain) NSNumber * type;
@property (nonatomic, retain) NSSet *event;
@end

@interface EventModel (CoreDataGeneratedAccessors)

- (void)addEventObject:(Event *)value;
- (void)removeEventObject:(Event *)value;
- (void)addEvent:(NSSet *)values;
- (void)removeEvent:(NSSet *)values;

@end

@interface RegularDay : NSValueTransformer

@end
