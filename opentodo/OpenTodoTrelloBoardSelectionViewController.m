//
//  OpenTodoTrelloBoardSelectionViewController.m
//  opentodo
//
//  Created by Frank Münchmeyer on 19.09.13.
//  Copyright (c) 2013 Frank Münchmeyer. All rights reserved.
//

#import "OpenTodoTrelloBoardSelectionViewController.h"

@interface OpenTodoTrelloBoardSelectionViewController ()

@end

@implementation OpenTodoTrelloBoardSelectionViewController
@synthesize jsonTrelloData;
@synthesize trelloToken;
@synthesize trelloAppKey;
@synthesize todos;

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
    
    self.todos = [NSJSONSerialization JSONObjectWithData:self.jsonTrelloData options:NSJSONReadingMutableLeaves error:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.todos.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"boardCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
   
    NSMutableArray *todo = [self.todos objectAtIndex:indexPath.row];
    
    UILabel *boardName = (UILabel *)[cell viewWithTag:10];
    boardName.text = [NSString stringWithFormat:@"%@", [todo valueForKey:@"name"]];
    
    return cell;
}

@end
