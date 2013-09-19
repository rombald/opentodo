//
//  OpenTodoTrelloRowSelectionViewController.m
//  opentodo
//
//  Created by Frank Münchmeyer on 19.09.13.
//  Copyright (c) 2013 Frank Münchmeyer. All rights reserved.
//

#import "OpenTodoTrelloRowSelectionViewController.h"

@interface OpenTodoTrelloRowSelectionViewController ()

@end

@implementation OpenTodoTrelloRowSelectionViewController
@synthesize trelloToken;
@synthesize trelloAppKey;
@synthesize selectedBoard;

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
    
    NSLog(@"Token: %@ | AppKey: %@ | selectedBoard: %@", self.trelloToken, self.trelloAppKey, [self.selectedBoard valueForKey:@"name"]);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
