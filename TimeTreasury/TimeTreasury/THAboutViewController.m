//
//  THAboutViewController.m
//  TimeTreasury
//
//  Created by WangHenry on 10/26/14.
//  Copyright (c) 2014 WangHenry. All rights reserved.
//

#import "THAboutViewController.h"

@interface THAboutViewController ()
@property (strong, nonatomic) IBOutlet UITableViewCell *rateMeCell;
@property (strong, nonatomic) IBOutlet UITableViewCell *contactMeCell;

@end

@implementation THAboutViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section==3) {
        //email me
        MFMailComposeViewController* evc = [[MFMailComposeViewController alloc] init];
        evc.mailComposeDelegate = self;
        evc.title = @"Time House";
        [evc setSubject:@"Time House"];
        [evc setToRecipients:@[@"henrywang0113@gmail.com"]];
        [evc setMessageBody:@"Hi, Hongyi! I'm a time house user..." isHTML:nil];
        [self presentViewController:evc animated:YES completion:nil];
    }else if(indexPath.section==2)
    {
        //rate me on app store
    }
}

-(void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
