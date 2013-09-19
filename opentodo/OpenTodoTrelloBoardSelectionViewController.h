//
//  OpenTodoTrelloBoardSelectionViewController.h
//  opentodo
//
//  Created by Frank Münchmeyer on 19.09.13.
//  Copyright (c) 2013 Frank Münchmeyer. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OpenTodoTrelloBoardSelectionViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>
@property NSData *jsonTrelloData;
@property NSString *trelloToken;
@property NSString *trelloAppKey;
@property NSMutableArray *boards;

@property (weak, nonatomic) IBOutlet UITableView *boardTableView;

@end
