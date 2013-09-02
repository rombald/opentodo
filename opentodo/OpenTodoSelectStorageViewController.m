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
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"SelectStorage"]) {
        UINavigationController *navController = (UINavigationController *)segue.destinationViewController;
        OpenTodoViewController *opentodoview = (OpenTodoViewController *)navController.topViewController;
        opentodoview.localStorage = YES;
    }
}

@end
