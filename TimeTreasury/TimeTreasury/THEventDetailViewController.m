//
//  THEventDetailViewController.m
//  TimeTreasury
//
//  Created by WangHenry on 6/8/14.
//  Copyright (c) 2014 WangHenry. All rights reserved.
//

#import "THEventDetailViewController.h"
#import "THFileManager.h"
#define TemporaryAudioName @"TempAudio"

@interface THEventDetailViewController ()
@property (strong, nonatomic) IBOutlet UITextField *nameTextFile;
@property (strong, nonatomic) IBOutlet UIImageView *photoView;
@property (strong, nonatomic) IBOutlet UILabel *typeLabel;
@property (strong, nonatomic) IBOutlet UIImageView *typeMark;

@property (strong, nonatomic) IBOutlet UIButton *addStartTimeButton;
@property (strong, nonatomic) IBOutlet UIButton *addEndTimeButton;
@property (strong, nonatomic) IBOutlet UILabel *addStartTimeLabel;
@property (strong, nonatomic) IBOutlet UILabel *addEndTimeLabel;
@property (strong, nonatomic) IBOutlet UIButton *audioRecordButton;
@property (strong, nonatomic) IBOutlet UIButton *addImageButton;
@property (strong, nonatomic) IBOutlet UILabel *statusLabel;


@property (strong, nonatomic) IBOutlet UILabel *audioLabel;
@property (strong, nonatomic) IBOutlet UILabel *imageLabel;
@property (strong, nonatomic) IBOutlet UIButton *audioDeleteButton;
@property (strong, nonatomic) IBOutlet UIView *datePickerView;
@property (strong, nonatomic) IBOutlet UIDatePicker *datePicker;


@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *audioPlayingIndicator;
@property (strong, nonatomic) AVAudioPlayer* player;
@property (strong, nonatomic) AVAudioRecorder* recorder;

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
@end

@implementation THEventDetailViewController





- (void)viewDidLoad
{
    [super viewDidLoad];
    _numberOfLinePickingDate = -1;
    _hasPhoto = NO;
    _hasAudio = NO;
    
    //set background
    UIImageView* bkView = [[UIImageView alloc] initWithFrame:self.view.frame];
    bkView.image = [UIImage imageNamed:@"paperBackground.jpg"];
    [self.view addSubview:bkView];
    [self.view sendSubviewToBack:bkView];
    
    //create a new file used to store temprary audio
    _audioTempUrl = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
    _audioTempUrl = [_audioTempUrl URLByAppendingPathComponent:TemporaryAudioName];
    
    _nameTextFile.delegate = self;
    if (_event) {
        THFileManager* fileManager = [THFileManager sharedInstance];
        //set name
        _nameTextFile.text = _event.eventModel.name;
        [_nameTextFile sizeToFit];
        
        //get image
        _photoView.layer.masksToBounds = YES;
        _photoView.layer.cornerRadius = 10;
        
        if (_event.eventModel.photoGuid) {
            NSString* imageFileName  = _event.eventModel.photoGuid;
            imageFileName = [imageFileName stringByAppendingPathExtension:@"jpeg"];
            UIImage* photo =  [fileManager loadImageWithFileName:imageFileName];
            _photoView.image = photo;
            _photo = photo;
            _hasPhoto  = YES;
            [_addImageButton setImage:[UIImage imageNamed:@"Delete"] forState:UIControlStateNormal];
            _imageLabel.text = @"Click to delete photo";
            
        }
        else
        {
            _photoView.image = [UIImage imageNamed:@"Default.jpeg"];
        }
        
        
        
        //get type
        NSString* typeText;
        switch (_event.eventModel.type.integerValue) {
            case THCASUALEVENT:
            {
                typeText = @"Casual";
                _typeMark.image = [UIImage imageNamed:@"Casual.png"];
                break;
            }
            case THPLANNEDEVENT:
            {
                typeText = @"Plan";
                _typeMark.image = [UIImage imageNamed:@"Planned.png"];
            }
                break;
            case THDAILYEVENT:
            {
                typeText = @"Daily";
                _typeMark.image = [UIImage imageNamed:@"Daily.png"];
            }
                break;
            case THMONTHLYEVENT:
            {
                typeText = @"Monthly";
                _typeMark.image = [UIImage imageNamed:@"Monthly.png"];
                break;
            }
            case THWEEKLYEVENT:
            {
                typeText = @"Weekly";
                _typeMark.image = [UIImage imageNamed:@"weekly.png"];
                break;
            }
            default:
                break;
        }
        _typeLabel.text = typeText;
        
        //set time
        _formatter = [[NSDateFormatter alloc] init];
        [_formatter setDateStyle:NSDateFormatterShortStyle];
        [_formatter setTimeStyle:NSDateFormatterShortStyle];
        if (_event.startTime) {
            [_addStartTimeButton setImage:[UIImage imageNamed:@"Delete.png"] forState:UIControlStateNormal];
            _addStartTimeLabel.text = [_formatter stringFromDate:_event.startTime];
            [_addStartTimeLabel sizeToFit];
            _startTime = _event.startTime;
        }
        if (_event.endTime) {
            [_addEndTimeButton setImage:[UIImage imageNamed:@"Delete.png"] forState:UIControlStateNormal];
            _addEndTimeLabel.text = [_formatter stringFromDate:_event.endTime];
            [_addEndTimeLabel sizeToFit];
            _endTime = _event.endTime;
        }
        
        //set status
        NSString* statusText;
        switch (_event.status.integerValue) {
            case CURRENT:
                statusText = @"Current";
                break;
            case FINISHED:
                statusText = @"Finished";
                break;
            case UNFINISHED:
                statusText = @"Unfinished";
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
}
- (IBAction)addStartTimeAction:(id)sender {
    UIButton* button = (UIButton*)sender;
    if (_startTime) {
        _startTime = nil;
        [button setImage:[UIImage imageNamed:@"Add.png"] forState:UIControlStateNormal];
        _addStartTimeLabel.text = @"Add start time";
    }
    else
    {
        _numberOfLinePickingDate = 0;
        [_datePickerView setFrame:CGRectMake(0, 517, 320, 200)];
        [UIView animateWithDuration:0.3 animations:^void{
            [_datePickerView setFrame:CGRectMake(0, 317, 320, 200
                                                 )];
        }];
        
        _addStartTimeLabel.layer.borderWidth = 1;
        _addStartTimeLabel.layer.borderColor = [[UIColor redColor] CGColor];
        _addStartTimeLabel.layer.borderWidth = 0;
        
        _addStartTimeButton.enabled = NO;
        _addEndTimeButton.enabled = NO;
        _addStartTimeLabel.text = [_formatter stringFromDate:_datePicker.date];
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
        _numberOfLinePickingDate = 1;
        [_datePickerView setFrame:CGRectMake(0, 517, 320, 200)];
        [UIView animateWithDuration:0.3 animations:^void{
            [_datePickerView setFrame:CGRectMake(0, 317, 320, 200
                                                 )];
        }];
        
        _addEndTimeLabel.layer.borderWidth = 1;
        _addEndTimeLabel.layer.borderColor = [[UIColor redColor] CGColor];
        _addEndTimeLabel.layer.borderWidth = 0;
        
        _addStartTimeButton.enabled = NO;
        _addEndTimeButton.enabled = NO;
        _addEndTimeLabel.text = [_formatter stringFromDate:_datePicker.date];
    }
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
        [_addImageButton setImage:[UIImage imageNamed:@"Add.png"] forState:UIControlStateNormal];
        _imageLabel.text = @"Click to add photo";
        
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
    [_addImageButton setImage:[UIImage imageNamed:@"Delete.png"] forState:UIControlStateNormal];
    _imageLabel.text = @"Click to delete photo";
}

- (IBAction)saveAction:(id)sender {
    THCoreDataManager* dataManager = [THCoreDataManager sharedInstance];
    THFileManager* fileManager = [THFileManager sharedInstance];
    _event.eventModel.name = _nameTextFile.text;
    
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
            [fileManager writeContentOfFile:_audioTempUrl to:[fileManager getAudioURLWithName:_event.eventModel.audioGuid]];
        }
        else
        {
            NSString* guid = [[NSUUID UUID] UUIDString];
            [fileManager writeContentOfFile:_audioTempUrl to:[fileManager getAudioURLWithName:guid]];
            _event.eventModel.audioGuid = guid;
        }
    }
    
    [dataManager saveContext];
    switch (_eventStatus) {
        case CURRENT:
        {
            if (!_startTime) {
                _startTime = [NSDate date];
            }
            [dataManager startNewEvent:_event withStartTime:_startTime];
            break;
        }
        case FINISHED:
        {
            if (_event.status.integerValue==CURRENT) {
                [dataManager stopCurrentEvent];
            }
            _event.status = [NSNumber numberWithInteger:FINISHED];
            _event.startTime = _startTime;
            _event.endTime = _endTime;
            
            break;
        }
        case UNFINISHED:
        {
            if (_event.status.integerValue==CURRENT) {
                [dataManager stopCurrentEvent];
            }
            _event.status=[NSNumber numberWithInteger:UNFINISHED];
        }
        default:
            break;
    }
    [dataManager saveContext];
    [self.navigationController popViewControllerAnimated:YES];
    
}


- (IBAction)datePickerDoneAction:(id)sender {
    [UIView animateWithDuration:0.3 animations:^void{
        [_datePickerView setFrame:CGRectMake(0, 517, 320, 200
                                             )];
    } completion:^(BOOL finished){
        [_datePickerView setFrame:CGRectMake(0, 517, 320, 0)];
    }];
    if (_numberOfLinePickingDate==0) {
        _startTime = _datePicker.date;
        [_addStartTimeButton setImage:[UIImage imageNamed:@"Delete.png"] forState:UIControlStateNormal];
        _addStartTimeLabel.layer.borderWidth = 0;
    }
    else if(_numberOfLinePickingDate==1)
    {
        _endTime = _datePicker.date;
        [_addEndTimeButton setImage:[UIImage imageNamed:@"Delete.png"] forState:UIControlStateNormal];
        _addEndTimeLabel.layer.borderWidth = 0;
    }
    _addEndTimeButton.enabled = YES;
    _addStartTimeButton.enabled = YES;
    _numberOfLinePickingDate = -1;
}

- (IBAction)datePickerNowAction:(id)sender {
    [_datePicker setDate:[NSDate date] animated:YES];
}

- (IBAction)datePickerValueChanged:(id)sender {
    if (_numberOfLinePickingDate==0) {
        _addStartTimeLabel.text = [_formatter stringFromDate:_datePicker.date];
    }
    else if(_numberOfLinePickingDate==1)
    {
        _addEndTimeLabel.text = [_formatter stringFromDate:_datePicker.date];
    }
}
- (IBAction)audioDeleteAction:(id)sender {
    _hasAudio = NO;
    [_audioRecordButton setImage:[UIImage imageNamed:@"AudioRecord.png"] forState:UIControlStateNormal];
    _audioPlayingIndicator.alpha=0;
    _audioDeleteButton.alpha = 0;
    _audioLabel.text = @"Click to add audio";
}

- (IBAction)statusChanged:(id)sender {
    [_formatter setDateStyle:NSDateFormatterShortStyle];
    [_formatter setTimeStyle:NSDateFormatterShortStyle];
    if (_eventStatus==FINISHED) {
        _eventStatus=CURRENT;
        _addStartTimeButton.enabled=YES;
        _addEndTimeButton.enabled = NO;
        if (_event.startTime) {
            _addStartTimeLabel.text = [_formatter stringFromDate:_event.startTime];
            [_addStartTimeButton setImage:[UIImage imageNamed:@"Delete.png"] forState:UIControlStateNormal];
            _startTime = _event.startTime;
        }
        _endTime=nil;
         [_addEndTimeButton setImage:[UIImage imageNamed:@"Add.png"] forState:UIControlStateNormal];
        _addEndTimeLabel.text=@"Add start time";
        _statusLabel.text = @"Current";
    }
    else if(_eventStatus==UNFINISHED)
    {
        _eventStatus=FINISHED;
        _addEndTimeButton.enabled = YES;
        _addStartTimeButton.enabled=YES;
        if (_event.startTime) {
            _addStartTimeLabel.text = [_formatter stringFromDate:_event.startTime];
            [_addStartTimeButton setImage:[UIImage imageNamed:@"Delete.png"] forState:UIControlStateNormal];
            _startTime = _event.startTime;
        }
        if (_event.endTime) {
            _addEndTimeLabel.text = [_formatter stringFromDate:_event.startTime];
            [_addEndTimeButton setImage:[UIImage imageNamed:@"Delete.png"] forState:UIControlStateNormal];
            _endTime = _event.endTime;
        }
        
        _statusLabel.text = @"Finished";
    }
    else if(_eventStatus==CURRENT)
    {
        _eventStatus=UNFINISHED;
        _addEndTimeButton.enabled = NO;
        _addStartTimeButton.enabled=NO;
        [_addEndTimeButton setImage:[UIImage imageNamed:@"Add.png"] forState:UIControlStateNormal];
        [_addStartTimeButton setImage:[UIImage imageNamed:@"Add.png"] forState:UIControlStateNormal];
        _startTime=nil;
        _endTime =nil;
        _addStartTimeLabel.text=@"Add start time";
        _addEndTimeLabel.text=@"Add start time";
        _statusLabel.text = @"Unfinished";
    }
    
}
#pragma mark - audio play delegate
-(void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
    [_audioPlayingIndicator stopAnimating];
}

#pragma mark - text field delegate
-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    [_nameTextFile setFrame:CGRectMake(_nameTextFile.frame.origin.x, _nameTextFile.frame.origin.y, 300-_nameTextFile.frame.origin.x, _nameTextFile.frame.size.height)];
}

-(void)textFieldDidEndEditing:(UITextField *)textField
{
    [_nameTextFile sizeToFit];
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [_nameTextFile resignFirstResponder];
    return YES;
}
@end
