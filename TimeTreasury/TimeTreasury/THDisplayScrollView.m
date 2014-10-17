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
        self.contentSize = CGSizeMake(self.bounds.size.width, totalHeight);
        
    }
    return self;
}

-(void)addEventCell:(THEventCellView*)eventCell animation:(BOOL)animation initialFrame:(CGRect)frame
{
    [eventCell addObserver:self forKeyPath:@"cellEvent.status" options:NSKeyValueObservingOptionOld|NSKeyValueObservingOptionNew context:nil];
    int index = 0;
    switch (eventCell.cellEvent.status.integerValue) {
        case CURRENT:
        running++;
        [self.cellArray insertObject:eventCell atIndex:running-1];
        index = running;
        break;
        case UNFINISHED:
        todo++;
        [self.cellArray insertObject:eventCell atIndex:running+todo-1];
        index = running+todo;
        break;
        case FINISHED:
        finish++;
        [self.cellArray insertObject:eventCell atIndex:running+todo+finish-1];
        index = running+todo+finish;
        break;
        default:
        break;
    }
    totalHeight = totalHeight + eventCell.bounds.size.height;
    self.contentSize = CGSizeMake(self.bounds.size.width, totalHeight);
    eventCell.frame = CGRectMake(0, eventCell.bounds.size.height*(index-1),
                                 eventCell.bounds.size.width, eventCell.bounds.size.height);
    [self addSubview:eventCell];
    
    
    if (animation) {
        for (int i=index; i<[_cellArray count]; ++i) {
            UIView* view = [_cellArray objectAtIndex:i];
            [UIView animateWithDuration:0.5 animations:^(void)
            {
                [view setFrame:CGRectMake(0, view.frame.origin.y+view.frame.size.height, view.frame.size.width, view.frame.size.height)];
            }];
        }
    }
    else
    {
        for (int i=index; i<[_cellArray count]; ++i) {
            UIView* view = [_cellArray objectAtIndex:i];
            [view setFrame:CGRectMake(0, view.frame.origin.y+view.frame.size.height, view.frame.size.width, view.frame.size.height)];
        }
    }
    
    
}

-(void)deleteEventCell:(THEventCellView *)eventCell
{
    int index = 0;
    for (int i=0; i<[_cellArray count]; ++i) {
        if ([_cellArray objectAtIndex:i]==eventCell) {
            index = i;
            UIView* view = (UIView*)[_cellArray objectAtIndex:index];
            [view removeFromSuperview];
            [_cellArray removeObjectAtIndex:index];
            switch (eventCell.cellEvent.status.integerValue) {
                case CURRENT:
                running--;
                break;
                case UNFINISHED:
                todo--;
                case FINISHED:
                finish--;
                default:
                break;
            }
            break;
        }
    }
    for(int i=index;i<[_cellArray count];++i)
    {
        UIView* view = (UIView*)[_cellArray objectAtIndex:i];
        [UIView animateWithDuration:0.5 animations:^void{
            [view setFrame:CGRectMake(0, view.frame.origin.y-view.frame.size.height, view.frame.size.width, view.frame.size.height)];
        }];
    }
   
}


-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    NSLog(@"%@ has changed from %@ to %@", keyPath, [change objectForKey:NSKeyValueChangeOldKey], [change objectForKey:NSKeyValueChangeNewKey]);
}

@end
