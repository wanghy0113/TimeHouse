//
//  THDisplayScrollView.m
//  TimeTreasury
//
//  Created by WangHenry on 9/3/14.
//  Copyright (c) 2014 WangHenry. All rights reserved.
//

#import "THDisplayScrollView.h"

@interface THDisplayScrollView()
{
    float totalHeight;
    int running, todo, finish;
    
}
@property (strong, atomic)NSMutableArray* cellArray;
@property (strong, atomic)NSMutableArray* runningArray;
@property (strong, atomic)NSMutableArray* todoArray;
@property (strong, atomic)NSMutableArray* finishArray;
@property (strong, nonatomic)UIView* runningView;
@property (strong, nonatomic)UIView* todoView;
@property (strong, nonatomic)UIView* finishView;
@end


@implementation THDisplayScrollView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        totalHeight = 0;
        running = todo = finish = 0;
        _cellArray = [[NSMutableArray alloc] init];
        _runningArray = [[NSMutableArray alloc] init];
        _todoArray = [[NSMutableArray alloc] init];
        _finishArray = [[NSMutableArray alloc] init];
        
        _runningView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CELL_WID, 0)];
        _todoView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CELL_WID, 0)];
        _finishView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CELL_WID, 0)];
        
        _runningView.backgroundColor = [UIColor yellowColor];
        _todoView.backgroundColor = [UIColor blueColor];
        _finishView.backgroundColor = [UIColor greenColor];
        [self addSubview:_runningView];
        [self addSubview:_todoView];
        [self addSubview:_finishView];
        self.contentSize = CGSizeMake(self.bounds.size.width, totalHeight);
        
    }
    return self;
}

-(void)willMoveToSuperview:(UIView *)newSuperview
{
    NSLog(@"scroll %@ subviews count:%ld", self,[self.subviews count]);
}

-(void)addEventCell:(THEventCellView*)eventCell animation:(BOOL)animation initialFrame:(CGRect)frame
{
    
    //[eventCell addObserver:self forKeyPath:@"cellEvent.status" options:NSKeyValueObservingOptionOld|NSKeyValueObservingOptionNew context:nil];
    int index = 0;
   // NSLog(@"add Cell, status: %ld", (long)eventCell.cellEvent.status.integerValue);
    switch (eventCell.cellEvent.status.integerValue) {
        case CURRENT:
            [_runningArray addObject:eventCell];
            eventCell.frame = CGRectMake(0, _runningView.frame.size.height, CELL_WID, CELL_HEIGHT);
            [_runningView addSubview:eventCell];
        break;
            
        case UNFINISHED:
            [_todoArray addObject:eventCell];
            eventCell.frame = CGRectMake(0, _todoView.frame.size.height, CELL_WID, CELL_HEIGHT);
            [_todoView addSubview:eventCell];
        break;
            
        case FINISHED:
        //insert eventCell at the proper index
            for (int i=0; i<[_finishArray count]; ++i) {
                THEventCellView* cell = (THEventCellView*)[_finishArray objectAtIndex:i];
                if ([cell.cellEvent.startTime compare:eventCell.cellEvent.startTime]==NSOrderedDescending) {
                    index = i;
                    //  NSLog(@"here here here, index = %d", index);
                    break;
                }
            }
        
            [_finishArray insertObject:eventCell atIndex:index];
            eventCell.frame = CGRectMake(0, CELL_HEIGHT*index, CELL_WID, CELL_HEIGHT);
            [_finishView addSubview:eventCell];
            //push down views below added view
            for (int i=index+1; i<[_finishArray count]; ++i) {
                THEventCellView* cell = (THEventCellView*)[_finishArray objectAtIndex:i];
                cell.frame = CGRectMake(cell.frame.origin.x, cell.frame.origin.y+CELL_HEIGHT, CELL_WID, CELL_HEIGHT);
            }
        break;
        default:
        break;
    }
    if (animation) {
        [UIView animateWithDuration:0.5 animations:^(void){
            _runningView.frame = CGRectMake(0, 0, CELL_WID, CELL_HEIGHT*[_runningArray count]);
            _todoView.frame = CGRectMake(0, _runningView.frame.origin.y+_runningView.frame.size.height, CELL_WID, CELL_HEIGHT*[_todoArray count]);
            _finishView.frame = CGRectMake(0, _todoView.frame.origin.y+_todoView.frame.size.height, CELL_WID, CELL_HEIGHT*[_finishArray count]);
        }];
    }
    else
    {
        _runningView.frame = CGRectMake(0, 0, CELL_WID, CELL_HEIGHT*[_runningArray count]);
        _todoView.frame = CGRectMake(0, _runningView.frame.origin.y+_runningView.frame.size.height, CELL_WID, CELL_HEIGHT*[_todoArray count]);
        _finishView.frame = CGRectMake(0, _todoView.frame.origin.y+_todoView.frame.size.height, CELL_WID, CELL_HEIGHT*[_finishArray count]);
    }
    
    
    totalHeight = _runningView.frame.size.height+_todoView.frame.size.height+_finishView.frame.size.height;
    self.contentSize = CGSizeMake(self.bounds.size.width, totalHeight);
}

-(void)deleteEventCell:(THEventCellView *)eventCell
{
    [self deleteEventCell:eventCell withStatus:eventCell.cellEvent.status.integerValue];
}

-(void)deleteEventCell:(THEventCellView *)eventCell withStatus:(THEVENTSTATUS)status
{
   // [eventCell removeObserver:self forKeyPath:@"cellEvent.status"];
    int index = 0;
 //   NSLog(@"delete Cell, status: %ld", status);
    switch (status) {
        case CURRENT:
        [_runningArray removeObject:eventCell];
        [eventCell removeFromSuperview];

        break;
        case UNFINISHED:
        //pull up views below the removed view
        index = (int)[_todoArray indexOfObject:eventCell];
        for (int i=index+1; i<[_todoArray count]; ++i) {
            THEventCellView* cell = (THEventCellView*)[_todoArray objectAtIndex:i];
            cell.frame = CGRectMake(cell.frame.origin.x, cell.frame.origin.y-eventCell.frame.size.height, cell.frame.size.width, cell.frame.size.height);
        }
        [_todoArray removeObject:eventCell];
        [eventCell removeFromSuperview];
        break;
        case FINISHED:
        //pull up views below the removed view
        index = (int)[_finishArray indexOfObject:eventCell];
        for (int i=index+1; i<[_finishArray count]; ++i) {
            THEventCellView* cell = (THEventCellView*)[_finishArray objectAtIndex:i];
            cell.frame = CGRectMake(cell.frame.origin.x, cell.frame.origin.y-eventCell.frame.size.height, cell.frame.size.width, cell.frame.size.height);
        }
        [_finishArray removeObject:eventCell];
        [eventCell removeFromSuperview];
        break;
        default:
        break;
    }
    
    _runningView.frame = CGRectMake(0, 0, CELL_WID, CELL_HEIGHT*[_runningArray count]);
    _todoView.frame = CGRectMake(0, _runningView.frame.origin.y+_runningView.frame.size.height, CELL_WID, CELL_HEIGHT*[_todoArray count]);
    _finishView.frame = CGRectMake(0, _todoView.frame.origin.y+_todoView.frame.size.height, CELL_WID, CELL_HEIGHT*[_finishArray count]);
    
    
    totalHeight = _runningView.frame.size.height+_todoView.frame.size.height+_finishView.frame.size.height;
    self.contentSize = CGSizeMake(self.bounds.size.width, totalHeight);
   
}


-(void)updateEventCell:(THEventCellView*)eventCell withStatus:(THEVENTSTATUS)status
{
    [self deleteEventCell:eventCell withStatus:status];
    [self addEventCell:eventCell animation:NO initialFrame:CGRectMake(0, 0, 0, 0)];
}
@end
