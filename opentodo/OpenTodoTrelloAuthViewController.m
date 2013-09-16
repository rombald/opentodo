//
//  OpenTodoTrelloAuthViewController.m
//  opentodo
//
//  Created by Frank Münchmeyer on 17.09.13.
//  Copyright (c) 2013 Frank Münchmeyer. All rights reserved.
//

#import "OpenTodoTrelloAuthViewController.h"

@interface OpenTodoTrelloAuthViewController ()

@end

@implementation OpenTodoTrelloAuthViewController
@synthesize webView;

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

    webView.delegate = self;

    NSURL *url = [NSURL URLWithString:@"https://trello.com/1/authorize?key=9305fdfeca9d8484d1674a628e368137&expiration=never&name=OpenTodo&response_type=token&scope=read,write"];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [webView loadRequest:request];

    [[self navigationController] setNavigationBarHidden:NO animated:YES];
}

- (void)webViewDidFinishLoad:(UIWebView *)web_view
{
    NSString *htmlBody = [web_view stringByEvaluatingJavaScriptFromString:@"document.body.innerHTML"];
    NSLog(@"%@", htmlBody);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
