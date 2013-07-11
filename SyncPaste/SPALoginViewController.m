//
//  SPALoginViewController.m
//  SyncPaste
//
//  Created by Giles Williams on 11/07/2013.
//  Copyright (c) 2013 Giles Williams. All rights reserved.
//

#import "SPALoginViewController.h"
#import <Dropbox/Dropbox.h>

@interface SPALoginViewController ()

@end

@implementation SPALoginViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)pressedLogin:(id)sender {
    DBAccount *account = [[DBAccountManager sharedManager] linkedAccount];
    if (account) {
        [self dismissViewControllerAnimated:YES completion:^{
            
        }];
    } else {
        [[DBAccountManager sharedManager] linkFromController:self];
    }
}

@end
