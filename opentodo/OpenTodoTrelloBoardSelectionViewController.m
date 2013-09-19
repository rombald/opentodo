//
//  OpenTodoTrelloBoardSelectionViewController.m
//  opentodo
//
//  Created by Frank Münchmeyer on 19.09.13.
//  Copyright (c) 2013 Frank Münchmeyer. All rights reserved.
//

#import "OpenTodoTrelloBoardSelectionViewController.h"
#import "OpenTodoTrelloRowSelectionViewController.h"

@interface OpenTodoTrelloBoardSelectionViewController ()

@end

@implementation OpenTodoTrelloBoardSelectionViewController
@synthesize jsonTrelloData;
@synthesize trelloToken;
@synthesize trelloAppKey;
@synthesize boards;

@synthesize boardTableView;

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
    
    self.boards = [NSJSONSerialization JSONObjectWithData:self.jsonTrelloData options:NSJSONReadingMutableLeaves error:nil];
    self.boardTableView.delegate = self;
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
    return self.boards.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"boardCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
   
    NSMutableArray *board = [self.boards objectAtIndex:indexPath.row];
    
    UILabel *boardName = (UILabel *)[cell viewWithTag:10];
    boardName.text = [NSString stringWithFormat:@"%@", [board valueForKey:@"name"]];
    
    return cell;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"selectRow"]) {
        OpenTodoTrelloRowSelectionViewController *destViewController = segue.destinationViewController;

        NSMutableArray *selectedBoard = [self.boards objectAtIndex:[[self.boardTableView indexPathForSelectedRow] row]];
        
        destViewController.trelloAppKey = self.trelloAppKey;
        destViewController.trelloToken = self.trelloToken;
        destViewController.selectedBoard = selectedBoard;
    }
}

@end
