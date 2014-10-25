//
//  THNewEventViewController.m
//  TimeHoard
//
//  Created by WangHenry on 5/27/14.
//  Copyright (c) 2014 WangHenry. All rights reserved.
//

/********************************************
 about tag: rectangle frames start from 101
            labels start from 201
            button start from 301
            month day seletion label start from 401
            time pick view 501 type pick view 502 weekday pick view 503
 *********************************************/
#import "THNewEventViewController.h"


@implementation THNewEventViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
    /*
     set up category
     */
    
    _category = 0;
    UIColor* color = [THCategoryProcessor categoryColor:_category onlyActive:YES];
    UIFont* font = [UIFont fontWithName:@"NoteWorthy-bold" size:15];
    NSAttributedString* astr = [[NSAttributedString alloc] initWithString:[THCategoryProcessor categoryString:_category onlyActive:YES]
                                                               attributes:@{NSForegroundColorAttributeName:color,NSFontAttributeName:font}];
    _addCatogeryLabel.attributedText = astr;
    [_addCatogeryButton addTarget:self action:@selector(catogeryPickerViewShow:) forControlEvents:UIControlEventTouchUpInside];
    _categoryPickerView = [[THCategoryPickerView alloc] init];
    [_categoryPickerView setFrame:CGRectMake(0, datePickerViewHidenY, 320, datePickerViewHeight)];
    _categoryPickerView.delegate = self;
    [self.view addSubview:_categoryPickerView];
    
    
    
    
    
    
    _nameField.delegate = self;
    _isSavedAsTemplate = NO;
    _newEventType = THCASUALEVENT;
    _weekdayArray = [[NSMutableArray alloc] init];
    _monthdayArray = [[NSMutableArray alloc] init];
    //initiate audio session
    AVAudioSession* session = [AVAudioSession sharedInstance];
    [session setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
    [self setAudioRecorder];
    
    _hasAudio = NO;
    [_addAudioButton addTarget:self action:@selector(audioStartRecordingButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [_deleteAudioButton addTarget:self action:@selector(audioDeleteRecordingButtonPressed:) forControlEvents:UIControlEventTouchUpInside];

    
    //initiate add catogery functions
    
    
    //-1 means no row is picking date now, 0 means start time is being picked, 1 means end time is being picked
    _datePickerView = [[THDatePickView alloc] init];
    [_datePickerView setFrame:CGRectMake(0, datePickerViewHidenY, 320, datePickerViewHeight)];
    _datePickerView.delegate = self;
    [self.view addSubview:_datePickerView];
    _datePickingRow = -1;
    
    //for navigation bar
    _navigationBarButtonCancel.target = self;
    _navigationBarButtonCancel.action = @selector(cancelButtonPressed:);
    _navigationBarButtonDone.target = self;
    _navigationBarButtonDone.action = @selector(doneButtonPressed:);
    
    //for photo view
    _photoPreView = [[UIImageView alloc] initWithFrame:CGRectMake(15, 70, 100, 100)];
    _photoPreView.layer.cornerRadius = 5;
   // _photoPreView.layer.borderWidth = 4;
    _photoPreView.layer.borderColor = [[UIColor whiteColor] CGColor];
    _photoPreView.layer.masksToBounds = YES;
    _photoPreView.backgroundColor = [UIColor grayColor];
    _photoPreView.userInteractionEnabled = YES;
    _photoPreView.image = [UIImage imageNamed:DefaultImageName];
    UITapGestureRecognizer* addPhotoTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(addPhoto:)];
    [_photoPreView addGestureRecognizer:addPhotoTap];
    [self.view addSubview:_photoPreView];
    
    //set uo date formatter
    _dateFormatter = [[NSDateFormatter alloc] init];
    [_dateFormatter setDateStyle:NSDateFormatterShortStyle];
    [_dateFormatter setTimeStyle:NSDateFormatterShortStyle];
    
    //choose to save event model
    for (int i=1;i<=4 ; i++) {
        UIView* view = [self.view viewWithTag:100+i];
        UITapGestureRecognizer* modeTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(modeFrameTouched:)];
        [view addGestureRecognizer:modeTap];
        view.userInteractionEnabled=YES;
    }
    
    //choose event type in regular mode
    for (int i=5; i<=7; i++) {
        UIView* view = [self.view viewWithTag:100+i];
        view.userInteractionEnabled=YES;
        UITapGestureRecognizer* typeTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(eventTypeTouched:)];
        [view addGestureRecognizer:typeTap];
    }
    
    //choose week day in regular mode
    UITapGestureRecognizer* weekdayTap;
    for (int i = 3; i<=9; i++) {
        UIView* view = [self.view viewWithTag:200+i];
        weekdayTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(weekFrameTouched:)];
        view.userInteractionEnabled=YES;
        [view addGestureRecognizer:weekdayTap];
    }
    
    //choose month day in regular mode
    UITapGestureRecognizer* monthdayTap;
    for (int i = 1; i<=31; i++) {
        UIView* view = [self.view viewWithTag:400+i];
        monthdayTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(monthFrameTouched:)];
        view.userInteractionEnabled=YES;
        [view addGestureRecognizer:monthdayTap];
    }
    
}

-(void)setAudioRecorder
{
    NSURL* url = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
    url = [url URLByAppendingPathComponent:TemporaryAudioName];
    
    if (!_recorder) {
        _recorder = [[AVAudioRecorder alloc] initWithURL:url settings:nil error:nil];
    }
    [_recorder prepareToRecord];

}

-(IBAction)audioStartRecordingButtonPressed:(UIButton*)sender
{
    if (!_recorder.recording && !_hasAudio) {
        //start recording
        [_recorder record];
        
        [sender setImage:[UIImage imageNamed:@"Stop.png"] forState:UIControlStateNormal];
        _audioLengthLabel.text = @"0";
        _audioTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(audioTimerHandler:) userInfo:nil repeats:YES];
    }
    else if (_recorder.recording && !_hasAudio) {
        [_recorder stop];
        [_audioTimer invalidate];
        _hasAudio = YES;
        _deleteAudioButton.alpha = 1;
        [sender setImage:[UIImage imageNamed:@"Start.png"] forState:UIControlStateNormal];
         _playingIndicator.alpha = 1;
//        [[AVAudioSession sharedInstance] setActive:NO error:nil];
    }
    else if (!_recorder.recording && _hasAudio) {
        //play audio
        if (!_player) {
            _player = [[AVAudioPlayer alloc] initWithContentsOfURL:_recorder.url error:nil];
            _player.delegate = self;
        }
       
        [_playingIndicator startAnimating];
        [_player play];
    }
}

-(IBAction)audioDeleteRecordingButtonPressed:(id)sender
{
    _hasAudio = NO;
    [_addAudioButton setImage:[UIImage imageNamed:@"AudioRecord.png"] forState:UIControlStateNormal];
    _audioLengthLabel.text = @"Click to speak";
    _deleteAudioButton.alpha = 0;
    _playingIndicator.alpha = 0;
}
#pragma makr - audio timere handler
-(void)audioTimerHandler:(id)sender
{
    if (_recorder.recording) {
        int time = (int)_recorder.currentTime;
        _audioLengthLabel.text = [NSString stringWithFormat:@"%d",time];
    }
}

#pragma mark - player recorder delegate
-(void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
    [_playingIndicator stopAnimating];
}

//mode tap gesture handler
-(void)modeFrameTouched:(UIGestureRecognizer*)gestureRecognizer
{
    UIView* view = gestureRecognizer.view;
    UIImage* unselectedImage = [UIImage imageNamed:@"Frame.png"];
    UIImage* selectedImage = [UIImage imageNamed:@"FrameWithCheck"];
    if (view.tag==101) {
        if (_isSavedAsTemplate) {
            _isSavedAsTemplate=NO;
            _saveAsTemplateFrame.image = unselectedImage;
        }
        else
        {
            _isSavedAsTemplate=YES;
            _saveAsTemplateFrame.image = selectedImage;
        }
    }
    
    if (view.tag==102) {
        if (_newEventType!=THCASUALEVENT) {
            _newEventType = THCASUALEVENT;
            
            [self resetDate]; //reset start and end date to nil
            
            _immediateEventFrame.image = selectedImage;
            _plannedEventFrame.image = unselectedImage;
            _regularEventFrame.image = unselectedImage;
            _addTimeView.userInteractionEnabled=NO ;
            _weekdayPickView.userInteractionEnabled=NO;
            _monthdayPickView.userInteractionEnabled=NO;
            _regularMenuView.userInteractionEnabled=NO;
            [UIView animateWithDuration:0.3 animations:^(void){
                _addTimeView.alpha = 0;
                _regularMenuView.alpha = 0;
                _weekdayPickView.alpha = 0;
                _monthdayPickView.alpha = 0;
            }];
            
        }
    }
    
    if (view.tag==103) {
        if (_newEventType!=THPLANNEDEVENT) {
            _newEventType = THPLANNEDEVENT;
            
            //reset date picker
            [self resetDate];
            [_datePickerView setDatePickMode: UIDatePickerModeDateAndTime];
            
            
            
            _immediateEventFrame.image = unselectedImage;
            _plannedEventFrame.image = selectedImage;
            _regularEventFrame.image = unselectedImage;
            //dismiss unrelated views
            _regularMenuView.userInteractionEnabled=NO;
            _weekdayPickView.userInteractionEnabled=NO;
            [UIView animateWithDuration:0.3 animations:^(void){
                _regularMenuView.alpha = 0;
                _weekdayPickView.alpha = 0;
                _monthdayPickView.alpha = 0;
            }];
            
            //add related views
            _addTimeView.userInteractionEnabled = YES;
            [UIView animateWithDuration:0.3 animations:^(void){
                _addTimeView.alpha = 1;
            }];
        }
    }
    
    if (view.tag==104) {
        if (_newEventType==THPLANNEDEVENT || _newEventType==THCASUALEVENT) {
            _newEventType = THDAILYEVENT;
            
            //reset date picker
            [self resetDate];
            [_datePickerView setDatePickMode: UIDatePickerModeTime];
            
            _immediateEventFrame.image = unselectedImage;
            _plannedEventFrame.image = unselectedImage;
            _regularEventFrame.image = selectedImage;
            
            _dailyFrame.image = selectedImage;
            _weeklyFrame.image = unselectedImage;
            _monthlyFrame.image = unselectedImage;
            
            
            _addTimeView.userInteractionEnabled=YES;
            _regularMenuView.userInteractionEnabled=YES;
            _weekdayPickView.userInteractionEnabled=YES;
            [UIView animateWithDuration:0.3 animations:^(void){
                _addTimeView.alpha = 1;
                _regularMenuView.alpha = 1;
            }];
            
           
        }
    }
}

//event type gesture handler
-(void)eventTypeTouched:(UIGestureRecognizer*)gestureRecognizer
{
    UIView* view = gestureRecognizer.view;
    UIImage* unselectedImage = [UIImage imageNamed:@"Frame.png"];
    UIImage* selectedImage = [UIImage imageNamed:@"FrameWithCheck"];
    if (view.tag==105) {
        if (_newEventType!=THDAILYEVENT) {
            _newEventType=THDAILYEVENT;
            _dailyFrame.image = selectedImage;
            _weeklyFrame.image = unselectedImage;
            _monthlyFrame.image = unselectedImage;
            [UIView animateWithDuration:0.3 animations:^(void){
                _weekdayPickView.alpha = 0;
                _monthdayPickView.alpha = 0;
            }];
        }
    }
    if (view.tag==106) {
        if (_newEventType!=THWEEKLYEVENT) {
            _newEventType = THWEEKLYEVENT;
            _dailyFrame.image = unselectedImage;
            _weeklyFrame.image = selectedImage;
            _monthlyFrame.image = unselectedImage;
            [UIView animateWithDuration:0.3 animations:^(void){
                _weekdayPickView.alpha = 1;
                _monthdayPickView.alpha = 0;
            }];
        }
    }
    if (view.tag==107) {
        //monthl event
        if (_newEventType!=THMONTHLYEVENT) {
            _newEventType = THMONTHLYEVENT;
            _dailyFrame.image = unselectedImage;
            _weeklyFrame.image = unselectedImage;
            _monthlyFrame.image = selectedImage;
            [UIView animateWithDuration:0.3 animations:^(void){
                _monthdayPickView.alpha = 1;
                _weekdayPickView.alpha = 0;
            }];
        }
    }
    
}

/*****
    @return
    @param
    @function reset start date and end date to nil, reset labels and buttons to initial state, reset date picker' date to current date
 *****/
-(void)resetDate
{
    _startDate = nil;
    [_addStartTimeButton setImage:[UIImage imageNamed:@"Add.png"] forState:UIControlStateNormal];
    _plannedStartTimeLabel.text = @"Add start time";
    [_plannedStartTimeLabel sizeToFit];
    _endDate = nil;
    [_addEndTimeButton setImage:[UIImage imageNamed:@"Add.png"] forState:UIControlStateNormal];
    _plannedEndTimeLabel.text = @"Add end time";
    [_plannedEndTimeLabel sizeToFit];
    
    [_datePickerView.datePicker setDate:[NSDate date]];
    
    _datePickingRow=-1;
    _plannedStartTimeLabel.layer.borderWidth = 0;
    _plannedEndTimeLabel.layer.borderWidth = 0;
    [UIView animateWithDuration:0.5 animations:^{
        [_datePickerView setFrame:CGRectMake(0,datePickerViewHidenY, _datePickerView.bounds.size.width, _datePickerView.bounds.size.height)];}];
    
    _addStartTimeButton.enabled = YES;
    _addEndTimeButton.enabled = YES;
}


//week day gesture handler
-(void)weekFrameTouched:(UIGestureRecognizer*)gestureRecognizer
{
    UIView* view = gestureRecognizer.view;
    NSNumber *dayOfTheWeek = [NSNumber numberWithInteger:view.tag-202];
    if (view.layer.borderWidth==0) {
        view.layer.borderWidth=1;
        view.layer.borderColor=[[UIColor redColor] CGColor];
        [_weekdayArray addObject:dayOfTheWeek];
    }
    else
    {
        view.layer.borderWidth=0;
        [_weekdayArray removeObjectIdenticalTo:dayOfTheWeek];
    }
    
}

//month day gesture handler
-(void)monthFrameTouched:(UIGestureRecognizer*)gestureRecognizer
{
    UIView* view = gestureRecognizer.view;
    NSNumber *dayOfTheMonth = [NSNumber numberWithInteger:view.tag-400];
    if (view.layer.borderWidth==0) {
        view.layer.borderWidth=1;
        view.layer.borderColor=[[UIColor redColor] CGColor];
        [_monthdayArray addObject:dayOfTheMonth];
    }
    else
    {
        view.layer.borderWidth=0;
        [_monthdayArray removeObjectIdenticalTo:dayOfTheMonth];
    }
    
}


#pragma makr - UI Action Sheet delegate methods
-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    UIImagePickerController* imagePickerController = [[UIImagePickerController alloc] init];
    imagePickerController.delegate=self;
    if (buttonIndex==0) {
        if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
            imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
            imagePickerController.allowsEditing = YES;
            [self presentViewController:imagePickerController animated:YES completion:nil];
        }
    }
    if (buttonIndex==1) {
        if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
            imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            [self presentViewController:imagePickerController animated:YES completion:nil];
        }
    }
}





#pragma mark - UIImagePickerController delegate method
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage* editedImage = [info objectForKey:UIImagePickerControllerEditedImage];
    UIImage* originalImage = [info objectForKey:UIImagePickerControllerOriginalImage];
    UIImageWriteToSavedPhotosAlbum(originalImage, nil, nil, nil);
    
    _photoPreView.image = editedImage;
    _photo = editedImage;
    [picker dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - cancel button handler
-(IBAction)cancelButtonPressed:(id)sender
{
    [self.navigationController popToRootViewControllerAnimated:YES];
}

#pragma mark - done button handler
-(IBAction)doneButtonPressed:(id)sender
{
    
    NSMutableArray* quickstartArray = [[[NSUserDefaults standardUserDefaults] objectForKey:@"Quickstarts"] mutableCopy];
    //if new photo has been added, save it
    if (_photo) {
        _photoGuid = [[NSUUID UUID] UUIDString];
        [[THFileManager sharedInstance] saveImage:_photo withFileName:[_photoGuid stringByAppendingPathExtension:@"jpeg"]];
    }
    //if audio has been added, save it
    if (_hasAudio) {
        _audioGuid = [[NSUUID UUID] UUIDString];
        [[THFileManager sharedInstance] renameFile:TemporaryAudioName withNewName:_audioGuid];
    }
    
    
    THCoreDataManager* dataManager = [THCoreDataManager sharedInstance];

    //get only day
    [_dateFormatter setDateStyle:NSDateFormatterShortStyle];
    [_dateFormatter setTimeStyle:NSDateFormatterNoStyle];
    NSString* day = [_dateFormatter stringFromDate:_startDate];
    if (_newEventType==THCASUALEVENT) {
        NSString* guid = [[NSUUID UUID] UUIDString];  //get event model guid
        EventModel* model = [dataManager addEventModel:_nameField.text
                                              withGUID:guid
                                  withPlannedStartTime:_startDate
                                    withPlannedEndTime:_endDate
                                         withPhotoGuid:_photoGuid
                                         withAudioGuid:_audioGuid
                                          withCategory:_category
                                         withEventType:_newEventType
                                        withRegularDay:nil
                                     shouldSaveAsModel:_isSavedAsTemplate];
        if (_isSavedAsTemplate) {
            [quickstartArray addObject:guid];
        }
        guid = [[NSUUID UUID] UUIDString];      //get event guid
        Event* event;
        event = [dataManager addEventWithGuid:guid
                               withEventModel:model
                                     withDate:day];
        [dataManager startNewEvent:event];   //if it's a current event, we should start it
    }
    
    
    if (_newEventType==THPLANNEDEVENT) {
        NSString* guid = [[NSUUID UUID] UUIDString];
        EventModel* model = [dataManager addEventModel:_nameField.text
                                              withGUID:guid
                                  withPlannedStartTime:_startDate
                                    withPlannedEndTime:_endDate
                                         withPhotoGuid:_photoGuid
                                         withAudioGuid:_audioGuid
                                          withCategory:_category
                                         withEventType:_newEventType
                                        withRegularDay:nil
                                     shouldSaveAsModel:_isSavedAsTemplate];
        if (_isSavedAsTemplate) {
            [quickstartArray addObject:guid];
        }
        guid = [[NSUUID UUID] UUIDString];
        Event* event;
        event = [dataManager addEventWithGuid:guid
                               withEventModel:model
                                     withDate:day];
    }
    
    
    if (_newEventType==THDAILYEVENT) {
        //if it is a daily event, besides add the daily event model to store, also add a new event that inherites the model
        NSString* guid = [[NSUUID UUID] UUIDString];
       EventModel* model = [dataManager addEventModel:_nameField.text
                                             withGUID:guid
                                 withPlannedStartTime:_startDate
                                   withPlannedEndTime:_endDate
                                        withPhotoGuid:_photoGuid
                                        withAudioGuid:_audioGuid
                                         withCategory:_category
                                        withEventType:_newEventType
                                       withRegularDay:nil   //no regular day for daily event
                                    shouldSaveAsModel:_isSavedAsTemplate];
        if (_isSavedAsTemplate) {
            [quickstartArray addObject:guid];
        }
        guid = [[NSUUID UUID] UUIDString];
        [dataManager addEventWithGuid:guid withEventModel:model withDate:nil];
    }
    
    
    
    if (_newEventType==THWEEKLYEVENT) {
        //if it is a weekly event, we should also check if a new event should be added to today.
        NSString* guid = [[NSUUID UUID] UUIDString];
        EventModel* model = [dataManager addEventModel:_nameField.text
                                              withGUID:guid
                                  withPlannedStartTime:_startDate
                                    withPlannedEndTime:_endDate
                                         withPhotoGuid:_photoGuid
                                         withAudioGuid:_audioGuid
                                          withCategory:_category
                                         withEventType:_newEventType
                                        withRegularDay:_weekdayArray
                                     shouldSaveAsModel:_isSavedAsTemplate];
        
        if (_isSavedAsTemplate) {
            [quickstartArray addObject:guid];
        }
        //if regular contains today, add a to-do event.
        for (NSNumber* day in _weekdayArray) {
            NSCalendar* calender = [NSCalendar currentCalendar];
            NSDateComponents* components = [calender components:NSWeekdayCalendarUnit fromDate:[NSDate date]];
            NSInteger todayNumber = [components weekday];
            if (todayNumber==day.integerValue) {
                guid = [[NSUUID UUID] UUIDString];
                [dataManager addEventWithGuid:guid withEventModel:model withDate:nil];
            }
        }
    }
    if (_newEventType==THMONTHLYEVENT) {
        //if it is a monthly event, we should also check if a new event should be added to today.
        NSString* guid = [[NSUUID UUID] UUIDString];
        EventModel* model = [dataManager addEventModel:_nameField.text
                                              withGUID:guid
                                  withPlannedStartTime:_startDate
                                    withPlannedEndTime:_endDate
                                         withPhotoGuid:_photoGuid
                                         withAudioGuid:_audioGuid
                                          withCategory:_category
                                         withEventType:_newEventType
                                        withRegularDay:_monthdayArray
                                     shouldSaveAsModel:_isSavedAsTemplate];
        if (_isSavedAsTemplate) {
            [quickstartArray addObject:guid];
        }
        //if it is a monthly event, we should also check if a new event should be added to today.
        for (NSNumber* day in _monthdayArray) {
            NSCalendar* calender = [NSCalendar currentCalendar];
            NSDateComponents* components = [calender components:NSDayCalendarUnit fromDate:[NSDate date]];
            NSInteger todayNumber = [components day];
            if (todayNumber==day.integerValue) {
                guid = [[NSUUID UUID] UUIDString];
                [dataManager addEventWithGuid:guid withEventModel:model withDate:nil];
            }
        }
    }
    
    [[NSUserDefaults standardUserDefaults] setObject:quickstartArray forKey:@"Quickstarts"];
    [self.navigationController popToRootViewControllerAnimated:YES];
}


-(void)addPhoto:(UIGestureRecognizer*) gestureRecognizer
{
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Take Photo",@"Pick From Library",nil];
    actionSheet.tag = 200;
    [actionSheet showInView:self.view];
}


-(void)dateValueChanged:(NSDate*) date
{
    if (_newEventType==THPLANNEDEVENT) {
        [_dateFormatter setDateStyle:NSDateFormatterShortStyle];
        [_dateFormatter setTimeStyle:NSDateFormatterShortStyle];
        NSString* text = [_dateFormatter stringFromDate:date];
        if (_datePickingRow==0) {
            _plannedStartTimeLabel.text = text;
            [_plannedStartTimeLabel sizeToFit];
        }
        else if (_datePickingRow==1)
        {
            _plannedEndTimeLabel.text = text;
            [_plannedEndTimeLabel sizeToFit];
        }
    }
    if (_newEventType!=THPLANNEDEVENT) {
        [_dateFormatter setDateStyle:NSDateFormatterNoStyle];
        [_dateFormatter setTimeStyle:NSDateFormatterShortStyle];
        NSString* text = [_dateFormatter stringFromDate:date];
        if (_datePickingRow==0) {
            _plannedStartTimeLabel.text = text;
            [_plannedStartTimeLabel sizeToFit];
        }
        else if (_datePickingRow==1)
        {
            _plannedEndTimeLabel.text = text;
            [_plannedEndTimeLabel sizeToFit];
        }

    }
}

-(void)catogeryPickerViewShow:(id)sender
{
        [UIView animateWithDuration:0.5 animations:^{
            [_categoryPickerView setFrame:CGRectMake(0, datePickerViewShownY, _datePickerView.bounds.size.width, _datePickerView.bounds.size.height)];}];
        [_addCatogeryButton setEnabled:false];
        [_addStartTimeButton setEnabled:false];
        [_addEndTimeButton setEnabled:false];
}



//add planned start time
-(IBAction)addPlannedStartTime:(id)sender
{
    UIButton* button = (UIButton*)sender;
    if (_startDate) {
        _startDate = nil;
        [button setImage:[UIImage imageNamed:@"Add.png"] forState:UIControlStateNormal];
        _plannedStartTimeLabel.text = @"Add start time";
        [_plannedStartTimeLabel sizeToFit];
    }
    else
    {
        
        _datePickingRow=0;
        
        _plannedStartTimeLabel.layer.borderWidth = 1;
        _plannedStartTimeLabel.layer.borderColor = [[UIColor redColor] CGColor];
        _plannedEndTimeLabel.layer.borderWidth = 0;
        
        [UIView animateWithDuration:0.5 animations:^{
            [_datePickerView setFrame:CGRectMake(0, datePickerViewShownY, _datePickerView.bounds.size.width, _datePickerView.bounds.size.height)];}];
        _addStartTimeButton.enabled = NO;
        _addEndTimeButton.enabled = NO;
        _addCatogeryButton.enabled = NO;
        
        [self dateValueChanged:[NSDate date]];
        
    }
}

//add planned end time
-(IBAction)addPlannedEndTime:(id)sender
{
    UIButton* button = (UIButton*)sender;
    if (_endDate) {
        _endDate = nil;
        [button setImage:[UIImage imageNamed:@"Add.png"] forState:UIControlStateNormal];
        _plannedEndTimeLabel.text = @"Add end time";
        [_plannedEndTimeLabel sizeToFit];
    }
    else
    {
        
        _datePickingRow=1;

        _plannedEndTimeLabel.layer.borderWidth = 1;
        _plannedEndTimeLabel.layer.borderColor = [[UIColor redColor] CGColor];
        _plannedStartTimeLabel.layer.borderWidth = 0;
        
        [UIView animateWithDuration:0.5 animations:^{
            [_datePickerView setFrame:CGRectMake(0, datePickerViewShownY, _datePickerView.bounds.size.width, _datePickerView.bounds.size.height)];}];
        
        _addEndTimeButton.enabled = NO;
        _addStartTimeButton.enabled = NO;
        _addCatogeryButton.enabled = NO;
        
        [self dateValueChanged:[NSDate date]];
       
        
    }
}

#pragma mark - delegate method for category picker view delegate
-(void)catetoryPickerView:(UIView *)view finishPicking:(NSAttributedString *)string withCategory:(NSInteger)category
{
    _category = category;
    _addCatogeryLabel.attributedText = string;
//    [_addCatogeryButton setImage:[UIImage imageNamed:@"Delete.png"] forState:UIControlStateNormal];
    [UIView animateWithDuration:0.5 animations:^{
        [_categoryPickerView setFrame:CGRectMake(0,datePickerViewHidenY, _categoryPickerView.bounds.size.width, _categoryPickerView.bounds.size.height)];}];
    
    _addStartTimeButton.enabled = YES;
    _addEndTimeButton.enabled = YES;
    _addCatogeryButton.enabled = YES;
    
}



#pragma mark - delegate method for category picker view delegate
-(void)catetoryPickerView:(UIView *)view valueChanged:(NSAttributedString *)string withCategory:(NSInteger)category
{
    _addCatogeryLabel.attributedText = string;
}


- (void)finishPickingDate:(NSDate *)date {
    if (_datePickingRow==0) {
        _startDate = date;
        [_addStartTimeButton setImage:[UIImage imageNamed:@"Delete.png"] forState:UIControlStateNormal];
    }
    else if(_datePickingRow==1)
    {
        _endDate = date;
        [_addEndTimeButton setImage:[UIImage imageNamed:@"Delete.png"] forState:UIControlStateNormal];
    }
    _datePickingRow=-1;
    _plannedStartTimeLabel.layer.borderWidth = 0;
    _plannedEndTimeLabel.layer.borderWidth = 0;
    [UIView animateWithDuration:0.5 animations:^{
        [_datePickerView setFrame:CGRectMake(0,datePickerViewHidenY, _datePickerView.bounds.size.width, _datePickerView.bounds.size.height)];}];
    
    _addStartTimeButton.enabled = YES;
    _addEndTimeButton.enabled = YES;
    _addCatogeryButton.enabled = YES;
}

#pragma mark - text field delegate
-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [_nameField resignFirstResponder];
    return YES;
}
@end
