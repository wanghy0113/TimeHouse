//
//  THEventDetailViewController.m
//  TimeTreasury
//
//  Created by WangHenry on 6/8/14.
//  Copyright (c) 2014 WangHenry. All rights reserved.
//

#import "THEventDetailViewController.h"
#import "THFileManager.h"
#import "THColorPanel.h"
#define TemporaryAudioName @"TempAudio"

@interface THEventDetailViewController ()
@property (strong, nonatomic) IBOutlet UITextField *nameTextField;
@property (strong, nonatomic) IBOutlet UIImageView *photoView;
@property (strong, nonatomic) IBOutlet UILabel *typeLabel;

@property (strong, nonatomic) IBOutlet UIButton *addStartTimeButton;
@property (strong, nonatomic) IBOutlet UIButton *addEndTimeButton;
@property (strong, nonatomic) IBOutlet UILabel *addStartTimeLabel;
@property (strong, nonatomic) IBOutlet UILabel *addEndTimeLabel;
@property (strong, nonatomic) IBOutlet UIButton *audioRecordButton;
@property (strong, nonatomic) IBOutlet UILabel *statusLabel;
@property (strong, nonatomic) IBOutlet UIButton *addCategoryButton;
@property (strong, nonatomic) IBOutlet UILabel *CategoryLabel;
@property (strong, nonatomic) NSString* category;

@property (strong, nonatomic) IBOutlet UILabel *audioLabel;
@property (strong, nonatomic) IBOutlet UIButton *audioDeleteButton;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *audioPlayingIndicator;
@property (strong, nonatomic) IBOutlet UIButton *deletePhotoButton;
@property (strong, nonatomic) IBOutlet UITextView *noteTextView;
@property (strong, nonatomic) IBOutlet UIButton *noteEditDoneButton;
@property (strong, nonatomic) AVAudioPlayer* player;
@property (strong, nonatomic) AVAudioRecorder* recorder;

@property (strong, nonatomic)THDatePickView* datePickerView;
@property (strong, nonatomic)THCategoryPickerView* categoryPickerView;
@property (strong, nonatomic) IBOutlet UILabel *fromLabel;

@property (assign) BOOL hasPhoto;
@property (assign) BOOL hasAudio;
@property (assign) NSInteger numberOfLinePickingDate;
@property (strong, nonatomic) UIImage* photo;
@property (strong, nonatomic) NSDate* startTime;
@property (strong, nonatomic) NSDate* endTime;
@property (strong, nonatomic) NSDateFormatter* formatter;
@property (weak, nonatomic) NSTimer* audioTimer;
@property (strong, nonatomic) NSURL* audioTempUrl;
@property (assign) THEVENTSTATUS eventStatus;
@property (strong, nonatomic)NSString* note;
@end

@implementation THEventDetailViewController





- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _hasPhoto = NO;
    _hasAudio = NO;
    //set category and category picker view
    _category = @"";
    [_addCategoryButton addTarget:self action:@selector(catogeryPickerViewShow:) forControlEvents:UIControlEventTouchUpInside];
    _categoryPickerView = [[THCategoryPickerView alloc] init];
    [_categoryPickerView setFrame:CGRectMake(0, datePickerViewHidenY, 320, datePickerViewHeight)];
    _categoryPickerView.delegate = self;
    [self.view addSubview:_categoryPickerView];
    
    //-1 means no row is picking date now, 0 means start time is being picked, 1 means end time is being picked
    _datePickerView = [[THDatePickView alloc] init];
    [_datePickerView setFrame:CGRectMake(0, datePickerViewHidenY, 320, datePickerViewHeight)];
    _datePickerView.delegate = self;
    [self.view addSubview:_datePickerView];
    _numberOfLinePickingDate = -1;
    
    //set background
//    UIImageView* bkView = [[UIImageView alloc] initWithFrame:self.view.frame];
//    bkView.image = [UIImage imageNamed:@"PaperBackground.png"];
//    [self.view addSubview:bkView];
//    [self.view sendSubviewToBack:bkView];
    
    //create a new file used to store temprary audio
    _audioTempUrl = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
    _audioTempUrl = [_audioTempUrl URLByAppendingPathComponent:TemporaryAudioName];
    _nameTextField.delegate = self;
    
    if (_event) {
        THFileManager* fileManager = [THFileManager sharedInstance];
        //set category
        _category = _event.eventModel.catogery;
        UIFont* font = [UIFont fontWithName:@"Noteworthy-bold" size:15];
        UIColor* color = [UIColor grayColor];
        NSString* string = @"Uncategorized";
        if ([_category length]!=0) {
            color = [THColorPanel getColorFromCategory:_category];
            string = _category;
            [_addCategoryButton setImage:[UIImage imageNamed:@"Delete.png"] forState:UIControlStateNormal];
        }
        NSAttributedString* attr = [[NSAttributedString alloc] initWithString:string
                                                                   attributes:@{NSForegroundColorAttributeName:color, NSFontAttributeName:font}];
        _CategoryLabel.attributedText = attr;
        
        //set name
        _nameTextField.text = _event.eventModel.name;
        
        //get image
        if (_event.eventModel.photoGuid) {
            NSString* imageFileName  = _event.eventModel.photoGuid;
            imageFileName = [imageFileName stringByAppendingPathExtension:@"jpeg"];
            UIImage* photo =  [fileManager loadImageWithFileName:imageFileName];
            _photoView.image = photo;
            _photo = photo;
            _hasPhoto  = YES;
        }
        else
        {
            _photoView.image = [UIImage imageNamed:@"Default.jpeg"];
        }
        
        
        
        //get type
        NSString* typeText;
        switch (_event.eventModel.type.integerValue) {
            case THCASUALEVENT:
                typeText = @"Once";
                break;
            case THPLANNEDEVENT:
                typeText = @"Once";
                break;
            case THDAILYEVENT:
                typeText = @"Daily";
                [_nameTextField setEnabled:NO];
                [_addCategoryButton setEnabled:NO];
                [_deletePhotoButton setEnabled:NO];
                [_addStartTimeButton setEnabled:NO];
                [_addEndTimeButton setEnabled:NO];
                break;
            case THMONTHLYEVENT:
                typeText = @"Monthly";
                [_nameTextField setEnabled:NO];
                [_addCategoryButton setEnabled:NO];
                [_deletePhotoButton setEnabled:NO];
                [_addStartTimeButton setEnabled:NO];
                [_addEndTimeButton setEnabled:NO];
                break;
            case THWEEKLYEVENT:
                typeText = @"Weekly";
                [_nameTextField setEnabled:NO];
                [_addCategoryButton setEnabled:NO];
                [_deletePhotoButton setEnabled:NO];
                [_addStartTimeButton setEnabled:NO];
                [_addEndTimeButton setEnabled:NO];
                break;
            default:
                break;
        }
        _typeLabel.text = typeText;
        
        //set time
        _formatter = [[NSDateFormatter alloc] init];
        [_formatter setDateStyle:NSDateFormatterShortStyle];
        [_formatter setTimeStyle:NSDateFormatterShortStyle];
        if (_event.startTime) {
            _addStartTimeLabel.text = [_formatter stringFromDate:_event.startTime];
            [_addStartTimeButton setImage:[UIImage imageNamed:@"Delete.png"] forState:UIControlStateNormal] ;
            _startTime = _event.startTime;
        }
        if (_event.endTime) {
            _addEndTimeLabel.text = [_formatter stringFromDate:_event.endTime];
            [_addEndTimeButton setImage:[UIImage imageNamed:@"Delete.png"] forState:UIControlStateNormal] ;
            _endTime = _event.endTime;
        }
        
        //set status
        NSString* statusText;
        switch (_event.status.integerValue) {
            case CURRENT:
                statusText = @"Current";
                [_addEndTimeButton setEnabled:NO];
                [_addStartTimeButton setEnabled:NO];
                break;
            case FINISHED:
                statusText = @"Done";
                break;
            case UNFINISHED:
                statusText = @"To Do";
                _fromLabel.text = @"Plan";
                break;
            default:
                break;
        }
        _eventStatus = _event.status.integerValue;
        _statusLabel.text = statusText;
        
        //set Audio
        if (_event.eventModel.audioGuid) {
            NSURL* oldAudioUrl = [[THFileManager sharedInstance] getAudioURLWithName:_event.eventModel.audioGuid];
            [_audioRecordButton setImage:[UIImage imageNamed:@"Start.png"] forState:UIControlStateNormal];
            NSData* data = [NSData dataWithContentsOfURL:oldAudioUrl];
            [data writeToURL:_audioTempUrl atomically:YES];
            _hasAudio = YES;
            _player = [[AVAudioPlayer alloc] initWithContentsOfURL:_audioTempUrl error:nil];
            int length = (int)_player.duration;
            
            _audioLabel.text = [NSString stringWithFormat:@"%d",length];
            _audioPlayingIndicator.alpha = 1;
            _audioDeleteButton.alpha = 1;
        }
    }
    
    
    //text view
    _noteTextView.delegate = self;
    if ([_event.note length]==0) {
        _noteTextView.text = @"Add some note here...";
    }
    else
    {
        _noteTextView.text = _event.note;
    }
    [_noteEditDoneButton addTarget:self action:@selector(noteDoneButtonTouched:) forControlEvents:UIControlEventTouchUpInside];
    _note = @"";
}


- (IBAction)addStartTimeAction:(id)sender {
//    UIButton* button = (UIButton*)sender;
//    if (_startTime) {
//        _startTime = nil;
//        [button setImage:[UIImage imageNamed:@"Add.png"] forState:UIControlStateNormal];
//        _addStartTimeLabel.text = @"Add start time";
//    }
//    else
//    {
//        _numberOfLinePickingDate = 0;
//        [_datePickerView setFrame:CGRectMake(0, 517, 320, 200)];
//        [UIView animateWithDuration:0.3 animations:^void{
//            [_datePickerView setFrame:CGRectMake(0, 317, 320, 200
//                                                 )];
//        }];
//        
//        _addStartTimeLabel.layer.borderWidth = 1;
//        _addStartTimeLabel.layer.borderColor = [[UIColor redColor] CGColor];
//        _addStartTimeLabel.layer.borderWidth = 0;
//        
//        _addStartTimeButton.enabled = NO;
//        _addEndTimeButton.enabled = NO;
//        _addStartTimeLabel.text = [_formatter stringFromDate:_datePicker.date];
//    }
    UIButton* button = (UIButton*)sender;
    if (_startTime) {
        _startTime = nil;
        [button setImage:[UIImage imageNamed:@"Add.png"] forState:UIControlStateNormal];
        _addStartTimeLabel.text = @"Add start time";
    }
    else
    {
        _numberOfLinePickingDate=0;
        
        _addStartTimeLabel.layer.borderWidth = 1;
        _addStartTimeLabel.layer.borderColor = [[UIColor redColor] CGColor];
        _addEndTimeLabel.layer.borderWidth = 0;
        
        [UIView animateWithDuration:0.5 animations:^{
            [_datePickerView setFrame:CGRectMake(0, datePickerViewShownY, _datePickerView.bounds.size.width, _datePickerView.bounds.size.height)];}];
        _addStartTimeButton.enabled = NO;
        _addEndTimeButton.enabled = NO;
        _addCategoryButton.enabled = NO;
        
        if (_startTime) {
            [self dateValueChanged:_startTime];
        }
        else
        {
            [self dateValueChanged:[NSDate date]];
        }
        
        
    }

}
- (IBAction)addEndTimeAction:(id)sender {
    UIButton* button = (UIButton*)sender;
    if (_endTime) {
        _endTime = nil;
        [button setImage:[UIImage imageNamed:@"Add.png"] forState:UIControlStateNormal];
        _addEndTimeLabel.text = @"Add end time";
    }
    else
    {
        _numberOfLinePickingDate=1;
        
        _addEndTimeLabel.layer.borderWidth = 1;
        _addEndTimeLabel.layer.borderColor = [[UIColor redColor] CGColor];
        _addStartTimeLabel.layer.borderWidth = 0;
        
        [UIView animateWithDuration:0.5 animations:^{
            [_datePickerView setFrame:CGRectMake(0, datePickerViewShownY, _datePickerView.bounds.size.width, _datePickerView.bounds.size.height)];}];
        
        _addEndTimeButton.enabled = NO;
        _addStartTimeButton.enabled = NO;
        _addCategoryButton.enabled = NO;
        
        if (_endTime) {
            [self dateValueChanged:_endTime];
        }
        else
        {
            [self dateValueChanged:[NSDate date]];
        }
    }
}

-(void)dateValueChanged:(NSDate*) date
{
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateStyle:NSDateFormatterShortStyle];
    [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
    NSString* text = [dateFormatter stringFromDate:date];
    if (_numberOfLinePickingDate==0) {
        _addStartTimeLabel.text = text;
    }
    else if (_numberOfLinePickingDate==1)
    {
        _addEndTimeLabel.text = text;
    }
}

-(void)catogeryPickerViewShow:(id)sender
{
    if ([_category isEqualToString:@""]) {
        [UIView animateWithDuration:0.5 animations:^{
            [_categoryPickerView setFrame:CGRectMake(0, datePickerViewShownY, _datePickerView.bounds.size.width, _datePickerView.bounds.size.height)];}];
        [_categoryPickerView toTop:nil];
        [_addCategoryButton setEnabled:false];
        [_addStartTimeButton setEnabled:false];
        [_addEndTimeButton setEnabled:false];
    }
    else
    {
        _category = @"";
        UIFont* font = [UIFont fontWithName:@"Noteworthy-bold" size:15];
        UIColor* color = [UIColor grayColor];
        NSString* string = @"Uncategorized";
        NSAttributedString* attr = [[NSAttributedString alloc] initWithString:string
                                                                   attributes:@{NSForegroundColorAttributeName:color, NSFontAttributeName:font}];
        _CategoryLabel.attributedText = attr;
        [_addCategoryButton setImage:[UIImage imageNamed:@"Add.png"] forState:UIControlStateNormal];
        _CategoryLabel.attributedText = [[NSAttributedString alloc] initWithString:@"Add Category" attributes:@{NSForegroundColorAttributeName:[UIColor colorWithRed:0 green:0.529 blue:1 alpha:1],NSFontAttributeName:[UIFont fontWithName:@"NoteWorthy-Bold" size:15]}];
    }
}

#pragma mark - delegate method for category picker view delegate
-(void)CatetoryPickerView:(UIView *)view finishPicking:(NSAttributedString *)catogery
{
    _category = [catogery string];
    _CategoryLabel.attributedText = catogery;
    [_addCategoryButton setImage:[UIImage imageNamed:@"Delete.png"] forState:UIControlStateNormal];
    [UIView animateWithDuration:0.5 animations:^{
        [_categoryPickerView setFrame:CGRectMake(0,datePickerViewHidenY, _categoryPickerView.bounds.size.width, _categoryPickerView.bounds.size.height)];}];
    
    _addStartTimeButton.enabled = YES;
    _addEndTimeButton.enabled = YES;
    _addCategoryButton.enabled = YES;
    
}



#pragma mark - delegate method for category picker view delegate
-(void)CatetoryPickerView:(UIView *)view valueChanged:(NSAttributedString *)catogery
{
    _CategoryLabel.attributedText = catogery;
}



- (void)finishPickingDate:(NSDate *)date {
    if (_numberOfLinePickingDate==0) {
        _startTime = date;
        [_addStartTimeButton setImage:[UIImage imageNamed:@"Delete.png"] forState:UIControlStateNormal];
    }
    else if(_numberOfLinePickingDate==1)
    {
        _endTime = date;
        [_addEndTimeButton setImage:[UIImage imageNamed:@"Delete.png"] forState:UIControlStateNormal];
    }
    _numberOfLinePickingDate=-1;
    _addStartTimeLabel.layer.borderWidth = 0;
    _addEndTimeLabel.layer.borderWidth = 0;
    [UIView animateWithDuration:0.5 animations:^{
        [_datePickerView setFrame:CGRectMake(0,datePickerViewHidenY, _datePickerView.bounds.size.width, _datePickerView.bounds.size.height)];}];
    
    _addStartTimeButton.enabled = YES;
    _addEndTimeButton.enabled = YES;
    _addCategoryButton.enabled = YES;
}


- (IBAction)audioRecordAction:(id)sender {
    if (_hasAudio && !_recorder.recording) {
        _player = [[AVAudioPlayer alloc] initWithContentsOfURL:_audioTempUrl error:nil];
        _player.delegate = self;
        [_player play];
        [_audioPlayingIndicator startAnimating];
    }
    else if(!_hasAudio && !_recorder.recording)
    {
        //set recorder
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
        _recorder = [[AVAudioRecorder alloc] initWithURL:_audioTempUrl settings:nil error:nil];
        [_recorder prepareToRecord];
        [_audioRecordButton setImage:[UIImage imageNamed:@"Stop.png"] forState:UIControlStateNormal];
        _audioTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(audioRecordCount:) userInfo:nil repeats:YES];
        [_recorder record];
        _audioLabel.text = @"0";
        
    }
    else if(!_hasAudio && _recorder.recording)
    {
        [_recorder stop];
        [_audioTimer invalidate];
        [_audioRecordButton setImage:[UIImage imageNamed:@"Start.png"] forState:UIControlStateNormal];
        _audioPlayingIndicator.alpha = 1;
        _audioDeleteButton.alpha = 1;
        _hasAudio = YES;

    }
}

-(void)audioRecordCount:(id)sender
{
    int length = (int)_recorder.currentTime;
    _audioLabel.text = [NSString stringWithFormat:@"%d",length];
}

- (IBAction)addPhotoAction:(id)sender {
    if (_hasPhoto) {
        _hasPhoto = NO;
        self.photoView.image=[UIImage imageNamed:@"Default.jpeg"];
        [_deletePhotoButton setImage:[UIImage imageNamed:@"Add.png"] forState:UIControlStateNormal];
    }
    else
    {
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Take Photo",@"Pick From Library",nil];
        actionSheet.tag = 200;
        [actionSheet showInView:self.view];
    }
}

#pragma mark - UIAction Sheet delegate
-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    UIImagePickerController* imagePickerController = [[UIImagePickerController alloc] init];
    imagePickerController.delegate=self;
    if (buttonIndex==0) {
        if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
            imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
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
    UIImage* image = [info objectForKey:UIImagePickerControllerOriginalImage];
    _photoView.image = image;
    _photo = image;
    _hasPhoto = YES;
    [picker dismissViewControllerAnimated:YES completion:nil];
    [_deletePhotoButton setImage:[UIImage imageNamed:@"Delete.png"] forState:UIControlStateNormal];
}

- (IBAction)saveAction:(id)sender {
    THCoreDataManager* dataManager = [THCoreDataManager sharedInstance];
    THFileManager* fileManager = [THFileManager sharedInstance];
    _event.eventModel.name = _nameTextField.text;
    _event.eventModel.catogery = _category;
    //check if photo has been added and modified
    if (!_hasPhoto) {
        _event.eventModel.photoGuid=nil;
    }
    else
    {
        NSData* data = UIImageJPEGRepresentation(_photo, 0);
        NSString* name = _event.eventModel.photoGuid;
        if (name) {
             name = [name stringByAppendingPathExtension:@"jpeg"];
        }
        else
        {
            NSString* guid =  [[NSUUID UUID] UUIDString];
            _event.eventModel.photoGuid = guid;
            name = [guid stringByAppendingPathExtension:@"jpeg"];
        }
        [data writeToURL:[fileManager getPhotoURLWithName:name] atomically:YES];
    }
    
    //check if audio has been added or modified
    if (!_hasAudio) {
        _event.eventModel.audioGuid=nil;
    }
    else
    {
        if (_event.eventModel.audioGuid) {
            [fileManager writeContentOfURL:_audioTempUrl to:[fileManager getAudioURLWithName:_event.eventModel.audioGuid]];
        }
        else
        {
            NSString* guid = [[NSUUID UUID] UUIDString];
            [fileManager writeContentOfURL:_audioTempUrl to:[fileManager getAudioURLWithName:guid]];
            _event.eventModel.audioGuid = guid;
        }
    }
    
    _event.startTime = _startTime;
    _event.endTime = _endTime;
    _event.note = _note;
    [dataManager saveContext];
    
    [self.presentingViewController dismissViewControllerAnimated:self completion:nil];
}

- (IBAction)cancelAction:(id)sender {
      [self.presentingViewController dismissViewControllerAnimated:self completion:nil];
}

- (IBAction)audioDeleteAction:(id)sender {
    _hasAudio = NO;
    [_audioRecordButton setImage:[UIImage imageNamed:@"AudioRecord.png"] forState:UIControlStateNormal];
    _audioPlayingIndicator.alpha=0;
    _audioDeleteButton.alpha = 0;
    _audioLabel.text = @"Click to add audio";
}

#pragma mark - audio play delegate
-(void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
    [_audioPlayingIndicator stopAnimating];
}


#pragma mark - text view delegate
-(void)textViewDidBeginEditing:(UITextView *)textView
{
    if ([textView.text isEqualToString:@"Add some note here..."]) {
        textView.text = @"";
    }
    [UIView animateWithDuration:0.2 animations:^(void)
    {
        [self.view setFrame:CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y-200, self.view.frame.size.width, self.view.frame.size.height)];
         _noteEditDoneButton.alpha = 1;
    }];
    [_addStartTimeButton setEnabled:NO];
    [_addEndTimeButton setEnabled:NO];
}

-(void)noteDoneButtonTouched:(id)sender
{
    [UIView animateWithDuration:0.2 animations:^(void)
     {
         [self.view setFrame:CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y+200, self.view.frame.size.width, self.view.frame.size.height)];
         _noteEditDoneButton.alpha = 0;
     }];
    _note = _noteTextView.text;
    [_addStartTimeButton setEnabled:YES];
    [_addEndTimeButton setEnabled:YES];
    [_noteTextView resignFirstResponder];
}

#pragma mark - text field delegate
-(void)textFieldDidBeginEditing:(UITextField *)textField
{
//    [_nameTextField setFrame:CGRectMake(_nameTextFile.frame.origin.x, _nameTextFile.frame.origin.y, 300-_nameTextFile.frame.origin.x, _nameTextFile.frame.size.height)];
}

-(void)textFieldDidEndEditing:(UITextField *)textField
{
//    [_nameTextFile sizeToFit];
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [_nameTextField resignFirstResponder];
    return YES;
}
@end
