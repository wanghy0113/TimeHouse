//
//  THSettingsViewController.m
//  TimeTreasury
//
//  Created by WangHenry on 6/16/14.
//  Copyright (c) 2014 WangHenry. All rights reserved.
//

#import "THSettingsViewController.h"

@interface THSettingsViewController ()
@property (strong, nonatomic) IBOutlet UIButton *instructionButton;
@property (strong, nonatomic) IBOutlet UIButton *aboutButton;
@property (strong, nonatomic) IBOutlet UIButton *settingsButton;
@property (strong, nonatomic) IBOutlet UITextView *contentTextView;
- (IBAction)intructionButtonAction:(id)sender;
- (IBAction)aboutButtonAction:(id)sender;
- (IBAction)settingsButtonAction:(id)sender;


@end

@implementation THSettingsViewController



- (void)viewDidLoad
{
    [super viewDidLoad];
    //set view background
    UIImageView* bkView = [[UIImageView alloc] initWithFrame:self.view.frame];
    bkView.image = [UIImage imageNamed:@"paperBackground.jpg"];
    [self.view addSubview:bkView];
    [self.view sendSubviewToBack:bkView];

    // Do any additional setup after loading the view.
}





- (IBAction)intructionButtonAction:(id)sender {
    if (_contentTextView.alpha!=0) {
        [UIView animateWithDuration:0.3 animations:^void{
            _contentTextView.alpha = 0;
        }];
        _contentTextView.text = @"";
        [UIView animateWithDuration:0.3 animations:^void{
            _contentTextView.alpha = 1;
        }];
    }
}

- (IBAction)aboutButtonAction:(id)sender {
    [UIView animateWithDuration:0.3 animations:^void{
        _contentTextView.alpha = 0;
    }];
    _contentTextView.text = @"Author: Hongyi Wang\nEmail: henrywang0113@gmail.com\n\nYour suggestions are appreciated!";
    [UIView animateWithDuration:0.3 animations:^void{
        _contentTextView.alpha = 1;
    }];
}

- (IBAction)settingsButtonAction:(id)sender {
}
@end
