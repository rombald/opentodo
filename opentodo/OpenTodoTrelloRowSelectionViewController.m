//
//  OpenTodoTrelloRowSelectionViewController.m
//  opentodo
//
//  Created by Frank Münchmeyer on 19.09.13.
//  Copyright (c) 2013 Frank Münchmeyer. All rights reserved.
//

#import "OpenTodoTrelloRowSelectionViewController.h"
#import "OpenTodoViewController.h"

@interface OpenTodoTrelloRowSelectionViewController ()

@end

@implementation OpenTodoTrelloRowSelectionViewController
@synthesize trelloToken;
@synthesize trelloAppKey;
@synthesize selectedBoard;
@synthesize trelloRows;

@synthesize rowTableView;

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
    
    NSString *trelloListRowsString = [NSString stringWithFormat:@"https://trello.com/1/boards/%@/lists?key=%@&token=%@", [self.selectedBoard valueForKey:@"id"], self.trelloAppKey, self.trelloToken];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:trelloListRowsString]];
    NSURLResponse *response;
    NSError *error;
    
    NSData *responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    
    if (!error) {
        self.trelloRows = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableLeaves error:nil];
        self.rowTableView.delegate = self;
    } else {
        NSLog(@"%@", error);
    }
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
    return self.trelloRows.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"rowCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    NSMutableArray *trelloRow = [self.trelloRows objectAtIndex:indexPath.row];
    UILabel *rowName = (UILabel *)[cell viewWithTag:101];
    rowName.text = [NSString stringWithFormat:@"%@", [trelloRow valueForKey:@"name"]];
    
    return cell;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{ 
    if ([[segue identifier] isEqualToString:@"SelectStorageTrello"]) {
        OpenTodoViewController *opentodoview = segue.destinationViewController;
        
        NSMutableArray *selectedList = [self.trelloRows objectAtIndex:[[self.rowTableView indexPathForSelectedRow] row]];
        
        opentodoview.trelloStorage = YES;
        opentodoview.trelloToken = self.trelloToken;
        opentodoview.trelloAppKey = self.trelloAppKey;
        opentodoview.trelloBoard = self.selectedBoard;
        opentodoview.trelloList = selectedList;
    }
}

@end
