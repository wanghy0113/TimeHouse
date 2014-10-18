//
//  THCoreDataManager.m
//  TimeTreasury
//
//  Created by WangHenry on 5/29/14.
//  Copyright (c) 2014 WangHenry. All rights reserved.
//

#import "THCoreDataManager.h"
#import "Event.h"
#import "EventModel.h"
#import "THDateProcessor.h"
@implementation THCoreDataManager

+(instancetype)sharedInstance
{
    static dispatch_once_t t;
    static id singleton;
    dispatch_once(&t, ^{
        singleton = [[self alloc] init];
    });
    return singleton;
}

-(id)init
{
    self = [super init];
    if (self) {
        [self setupManagedObjectContext];
        NSEntityDescription* entityDescription = [NSEntityDescription entityForName:@"Event" inManagedObjectContext:_managedObjectContext];
        NSFetchRequest* request = [[NSFetchRequest alloc] init];
        NSPredicate* predict = [NSPredicate predicateWithFormat:@"status==0"];
        [request setEntity:entityDescription];
        [request setPredicate:predict];
        NSArray* array = [_managedObjectContext executeFetchRequest:request error:nil];
        if ([array count]!=0) {
            _currentEvent = (Event*)[[_managedObjectContext executeFetchRequest:request error:nil] objectAtIndex:0];
        }
    }
    return self;
}

#pragma mark - model URL
-(NSURL*)modelURL
{
    return [[NSBundle mainBundle] URLForResource:@"THModel" withExtension:@"momd"];
}

#pragma mark - store URL
-(NSURL*)storeURL
{
    NSURL* url = [[[NSFileManager defaultManager]
                   URLsForDirectory:NSDocumentDirectory
                   inDomains:NSUserDomainMask] lastObject];
    return [url URLByAppendingPathComponent:@"THData.sql"];
}

#pragma mark - Core Data Stack
-(void)setupManagedObjectContext
{
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:[self modelURL]];
    _persistentStoreCoordinator=[[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:_managedObjectModel];
    _managedObjectContext=[[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
    _managedObjectContext.persistentStoreCoordinator= _persistentStoreCoordinator;
    _managedObjectContext.mergePolicy=NSMergeByPropertyObjectTrumpMergePolicy;
    [_managedObjectContext.persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:[self storeURL] options:nil error:nil];
}

-(BOOL)saveContext
{
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
//    if (managedObjectContext != nil) {
//        if ([managedObjectContext hasChanges]) {
//            return [managedObjectContext save:&error];
//        }
//    }
    BOOL s = [managedObjectContext save:&error];
    NSLog(@"core data save successfully?%d",s);
    return s;
}



//add event model
-(EventModel*)addEventModel:(NSString*)name withGUID:(NSString*)guid withPlannedStartTime:(NSDate*)start withPlannedEndTime:(NSDate*)end withPhotoGuid:(NSString*)photoGuid withAudioGuid:(NSString*)audioGuid
               withCategory:(NSString*)category withEventType:(THEVENTTYPE)eventType withRegularDay:(NSArray*)days shouldSaveAsModel:(BOOL)saveAsModel
{
    EventModel* eventModel = [NSEntityDescription insertNewObjectForEntityForName:@"EventModel"
                                                 inManagedObjectContext:_managedObjectContext];
    eventModel.name = name;
    eventModel.planedStartTime = start;
    eventModel.planedEndTime = end;
    eventModel.photoGuid = photoGuid;
    eventModel.audioGuid = audioGuid;
    eventModel.type = [NSNumber numberWithInteger:eventType];
    eventModel.catogery = category;
    eventModel.guid = guid;
    eventModel.shouldSaveAsModel = [NSNumber numberWithBool:saveAsModel];
    eventModel.regularDay = days;
    
    [self saveContext];
    return eventModel;
}

//add event
-(Event*)addEventWithGuid:(NSString*)guid withEventModel:(EventModel*)eventModel withDate:(NSString*)date
{
    Event* event = [NSEntityDescription insertNewObjectForEntityForName:@"Event" inManagedObjectContext:_managedObjectContext];
    
    event.guid = guid;
    event.eventModel = eventModel;
    event.date = date;
    //event.status = [NSNumber numberWithInteger:UNFINISHED];
    [event setValue:[NSNumber numberWithInteger:UNFINISHED] forKey:@"status"];
    if (eventModel.planedStartTime) {
        //if this event model has a planned start time, add a local notification
        UILocalNotification* lNote = [[UILocalNotification alloc] init];
        lNote.fireDate = eventModel.planedStartTime;
        lNote.alertBody = [NSString stringWithFormat:@"It's %@ time!",eventModel.name];
        lNote.timeZone = [NSTimeZone systemTimeZone];
        lNote.soundName = UILocalNotificationDefaultSoundName;
        if (eventModel.type.integerValue == THDAILYEVENT || eventModel.type.integerValue == THWEEKLYEVENT) {
            //we should change its planned time to today's
            NSDate* todauDate = [THDateProcessor dateToToday:eventModel.planedStartTime];
            lNote.fireDate = todauDate;
        }
        event.notification = lNote;
        [[UIApplication sharedApplication] scheduleLocalNotification:lNote];
    }
    
    [self saveContext];
    return event;
    
}

//delete event
-(void)deleteEvent:(Event*)event
{
    if (event.notification) {
        [[UIApplication sharedApplication] cancelLocalNotification:event.notification];
    }
    [_managedObjectContext deleteObject:event];
    [self saveContext];
}

//get event model
-(EventModel*)getEventModelByGuid:(NSString *)guid
{
    NSEntityDescription* entityDescription = [NSEntityDescription entityForName:@"EventModel" inManagedObjectContext:_managedObjectContext];
    NSFetchRequest* request = [[NSFetchRequest alloc] init];
    NSPredicate* predicate = [NSPredicate predicateWithFormat:@"guid==%@",guid];
    [request setPredicate:predicate];
    [request setEntity:entityDescription];
    NSArray* array = [_managedObjectContext executeFetchRequest:request error:nil];
    return (EventModel*)[array objectAtIndex:0];
    
}

//get events by status
-(NSArray*)getEventsByStatus:(THEVENTSTATUS)eventStatus
{
    NSFetchRequest* request = [[NSFetchRequest alloc] init];
    NSEntityDescription* entityDescription = [NSEntityDescription entityForName:@"Event" inManagedObjectContext:_managedObjectContext];
    NSPredicate* predict = [NSPredicate predicateWithFormat:@"status==%d",eventStatus];
    [request setEntity:entityDescription];
    [request setPredicate:predict];
    NSArray* array = [_managedObjectContext executeFetchRequest:request error:nil];
    return array;
}

//get finished events in a given date
-(NSArray*)getFinishedEventsFromDate:(NSDate *)startDate toDate:(NSDate *)endDate
{
    NSArray* startDateBoundaries = [THDateProcessor getBoundaryDateBy:startDate];
    NSArray* endDateBoundaries = [THDateProcessor getBoundaryDateBy:endDate];
    NSDate* sDate = [startDateBoundaries objectAtIndex:0];
    NSDate* eDate = [endDateBoundaries objectAtIndex:1];
    NSFetchRequest* request = [[NSFetchRequest alloc] init];
    NSEntityDescription* entityDescription = [NSEntityDescription entityForName:@"Event" inManagedObjectContext:_managedObjectContext];
    NSPredicate* predict = [NSPredicate predicateWithFormat:@"(status==1) AND (endTime >= %@ AND endTime<=%@)",sDate,eDate];
  //  NSPredicate* predict = [NSPredicate predicateWithFormat:@"status==1"];
    [request setEntity:entityDescription];
    [request setPredicate:predict];
    return [_managedObjectContext executeFetchRequest:request error:nil];
}

-(NSArray*)getRegularEventsModelByDate:(NSDate*)date ofType:(THEVENTTYPE) eventType
{
    NSCalendar* calendar = [NSCalendar currentCalendar];
    //get the weekday number
    NSDateComponents* components = [calendar components:NSWeekdayCalendarUnit fromDate:date];
    NSInteger weekday = [components weekday];
    
    //get the month day number
    components = [calendar components:NSDayCalendarUnit fromDate:date];
    NSInteger day = [components day];
    
    //get daily events
    if (eventType == THDAILYEVENT) {
        return [self getRegularEventsModelByType:THDAILYEVENT];

    }
    else if (eventType == THWEEKLYEVENT)   //get weekly events
    {
        NSArray* weeklyEvents = [self getRegularEventsModelByType:THWEEKLYEVENT];
        NSMutableArray* results = [[NSMutableArray alloc] init];
        for (EventModel* model in weeklyEvents) {
            if ([model.regularDay containsObject:[NSNumber numberWithInteger:weekday]]) {
                [results addObject:model];
            }
        }
        return results;
    }
    
    
    return nil;
    
}

//get event by guid
-(Event*)getEventByGuid:(NSString *)guid
{
    NSFetchRequest* request = [[NSFetchRequest alloc] init];
    NSEntityDescription* entityDescription = [NSEntityDescription entityForName:@"Event" inManagedObjectContext:_managedObjectContext];
    NSPredicate* predict = [NSPredicate predicateWithFormat:@"guid==%d",guid];
    [request setEntity:entityDescription];
    [request setPredicate:predict];
    NSArray* array = [_managedObjectContext executeFetchRequest:request error:nil];
    if ([array count]==0) {
        return nil;
    }
    else
    {
        return [array objectAtIndex:0];
    }
}

//get regular events by event type
-(NSArray*)getRegularEventsModelByType:(THEVENTTYPE)eventType
{
    NSFetchRequest* request = [[NSFetchRequest alloc] init];
    NSEntityDescription* entityDescription = [NSEntityDescription entityForName:@"EventModel" inManagedObjectContext:_managedObjectContext];
    NSPredicate* predict = [NSPredicate predicateWithFormat:@"type==%d",eventType];
    [request setEntity:entityDescription];
    [request setPredicate:predict];
    return [_managedObjectContext executeFetchRequest:request error:nil];
}
//stop current event(will only be called when an event is currently running)
-(void)stopCurrentEvent
{
    assert(_currentEvent!=nil);
    
    _currentEvent.endTime = [NSDate date];
    //_currentEvent.status = [NSNumber numberWithInteger:FINISHED];
    [_currentEvent setValue:[NSNumber numberWithInteger:FINISHED] forKey:@"status"];
    CGFloat duration = [_currentEvent.endTime timeIntervalSinceDate:_currentEvent.startTime];
    _currentEvent.duration = [NSNumber numberWithFloat:duration];
    [self saveContext];
    NSLog(@"stop event, status now: %@", _currentEvent.status);
    _currentEvent = nil;
}

//start new event
-(void)startNewEvent:(Event*)event
{
    if (_currentEvent!=nil) {
        [self stopCurrentEvent];
    }
    event.startTime = [NSDate date];
    //event.status = [NSNumber numberWithBool:CURRENT];
    [event setValue:[NSNumber numberWithInteger:CURRENT] forKey:@"status"];
    event.endTime = nil;
    [self saveContext];
    _currentEvent = event;
    
}

//start an event with a start time
-(void)startNewEvent:(Event*)event withStartTime:(NSDate*)time;
{
    if (_currentEvent!=nil) {
        [self stopCurrentEvent];
    }
    event.startTime = time;
   // event.status = [NSNumber numberWithBool:CURRENT];
    [event setValue:[NSNumber numberWithInteger:CURRENT] forKey:@"status"];
    [self saveContext];
    _currentEvent = event;
}

-(void)refreshEvent:(Event *)event
{
    if (event.status.integerValue == CURRENT) {
        [self stopCurrentEvent];
    }
   // event.status = [NSNumber numberWithInteger:UNFINISHED];
    [event setValue:[NSNumber numberWithInteger:UNFINISHED] forKey:@"status"];
    event.startTime = nil;
    event.endTime = nil;
    event.duration = nil;
    [self saveContext];
}

-(NSArray*)getQuickStartEventModel
{
    NSFetchRequest* request = [[NSFetchRequest alloc] init];
    NSEntityDescription* entityDescription = [NSEntityDescription entityForName:@"EventModel"
                                                         inManagedObjectContext:_managedObjectContext];
    NSPredicate* predict = [NSPredicate predicateWithFormat:@"shouldSaveAsModel==1"];
    [request setEntity:entityDescription];
    [request setPredicate:predict];
    NSArray* array = [_managedObjectContext executeFetchRequest:request error:nil];
    return array;
}

@end
