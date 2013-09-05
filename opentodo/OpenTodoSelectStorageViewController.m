//
//  OpenTodoSelectStorageViewController.m
//  opentodo
//
//  Created by Frank Münchmeyer on 02.09.13.
//  Copyright (c) 2013 Frank Münchmeyer. All rights reserved.
//

#import "OpenTodoSelectStorageViewController.h"
#import "OpenToDoDetailViewController.h"
#import "OpenTodoViewController.h"

@interface OpenTodoSelectStorageViewController ()

@end

@implementation OpenTodoSelectStorageViewController

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
	// Do any additional setup after loading the view.
    
    [[self navigationController] setNavigationBarHidden:YES animated:NO];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    OpenTodoViewController *opentodoview = segue.destinationViewController;

    if ([[segue identifier] isEqualToString:@"SelectStorageLocalStorage"]) {
        opentodoview.localStorage = YES;
    } else if ([[segue identifier] isEqualToString:@"SelectStorageiCloud"]) {
        opentodoview.iCloudStorage = YES;
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [[self navigationController] setNavigationBarHidden:YES animated:YES];
}

@end
