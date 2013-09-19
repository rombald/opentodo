//
//  OpenTodoTrelloRowSelectionViewController.h
//  opentodo
//
//  Created by Frank Münchmeyer on 19.09.13.
//  Copyright (c) 2013 Frank Münchmeyer. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OpenTodoTrelloRowSelectionViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>
@property NSString *trelloToken;
@property NSString *trelloAppKey;
@property NSMutableArray *selectedBoard;
@property NSMutableArray *trelloRows;

@property (weak, nonatomic) IBOutlet UITableView *rowTableView;

@end
