//
//  THCoreDataManager.h
//  TimeTreasury
//
//  Created by WangHenry on 5/29/14.
//  Copyright (c) 2014 WangHenry. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "Event.h"
#import "EventModel.h"



@interface THCoreDataManager : NSObject
typedef NS_ENUM(NSInteger, THEVENTTYPE)
{
    THCASUALEVENT,
    THPLANNEDEVENT,
    THDAILYEVENT,
    THWEEKLYEVENT,
    THMONTHLYEVENT,
    THYEARLYEVENT,
};
typedef NS_ENUM(NSInteger, THEVENTSTATUS)
{
    CURRENT,
    FINISHED,
    UNFINISHED,
};
@property (readonly,strong,nonatomic)NSManagedObjectContext* managedObjectContext;
@property (readonly,strong,nonatomic)NSManagedObjectModel* managedObjectModel;
@property (readonly,strong,nonatomic)NSPersistentStoreCoordinator* persistentStoreCoordinator;

@property (strong, nonatomic) Event* currentEvent;

+(instancetype)sharedInstance;


-(void)setupManagedObjectContext;

-(BOOL)saveContext;

//add event model to store
-(EventModel*)addEventModel:(NSString*)name withGUID:(NSString*)guid withPlannedStartTime:(NSDate*)start withPlannedEndTime:(NSDate*)end withPhotoGuid:(NSString*)photoGuid withAudioGuid:(NSString*)audioGuid withCategory:(NSString*)category withEventType:(THEVENTTYPE)eventType withRegularDay:(NSArray*)days shouldSaveAsModel:(BOOL)saveAsModel;

//add event to store
-(Event*)addEventWithGuid:(NSString*)guid withEventModel:(EventModel*)eventModel withDate:(NSString*)date;

//get event model by guid
-(EventModel*)getEventModelByGuid:(NSString*)guid;

-(Event*)getEventByGuid:(NSString*)guid;

//get events by status
-(NSArray*)getEventsByStatus:(THEVENTSTATUS)eventStatus;

//get finished events before a given date
-(NSArray*)getFinishedEventsFromDate:(NSDate*)startDate toDate:(NSDate*)endDate;

//get event model by type
-(NSArray*)getRegularEventsModelByType:(THEVENTTYPE) eventType;

//get regular events model
-(NSArray*)getRegularEventsModelByDate:(NSDate*)date ofType:(THEVENTTYPE) eventType;

//get image
-(UIImage*)loadImageWithFileName:(NSString*)name;

//get event models by type and category
-(NSArray*)getEventModelsByType:(THEVENTTYPE)type andCategory:(NSString*)category;

//delete event
-(void)deleteEvent:(Event*)event;

//delete event model with delete rule : casade
-(void)deleteEventModel:(EventModel*)eventModel;

//stop current evvent
-(void)stopCurrentEvent;

//start an event
-(void)startNewEvent:(Event*)event;

//start an event with a start time
-(void)startNewEvent:(Event*)event withStartTime:(NSDate*)time;

//refresh an event back to to do status
-(void)refreshEvent:(Event*)event;

//get quick start event model
-(NSArray*)getQuickStartEventModel;
@end
