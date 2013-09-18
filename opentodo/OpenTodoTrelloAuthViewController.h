//
//  OpenTodoTrelloAuthViewController.h
//  opentodo
//
//  Created by Frank Münchmeyer on 17.09.13.
//  Copyright (c) 2013 Frank Münchmeyer. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OpenTodoTrelloAuthViewController : UIViewController <UIWebViewDelegate>
@property (nonatomic, strong) IBOutlet UIWebView *webView;
@property (weak, nonatomic) IBOutlet UILabel *spinnerBackground;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *spinner;

@property NSString *trelloToken;

@end
