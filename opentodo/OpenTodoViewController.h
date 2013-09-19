//
//  OpenTodoViewController.h
//  opentodo
//
//  Created by Frank Münchmeyer on 27.08.13.
//  Copyright (c) 2013 Frank Münchmeyer. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OpenTodoViewController : UITableViewController
@property BOOL localStorage;
@property BOOL iCloudStorage;
@property BOOL trelloStorage;

@property NSMutableArray *trelloBoard;
@property NSMutableArray *trelloList;
@property NSString *trelloAppKey;
@property NSString *trelloToken;

@property (strong, nonatomic) NSMutableArray *iCloudToDos;

@end