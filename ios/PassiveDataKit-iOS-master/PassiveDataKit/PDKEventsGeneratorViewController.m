//
//  PDKEventGeneratorViewController.m
//  PassiveDataKit
//
//  Created by Chris Karr on 7/2/16.
//  Copyright © 2016 Audacious Software. All rights reserved.
//

#import "PassiveDataKit.h"

#import "PDKEventsGeneratorViewController.h"
#import "PDKEventsGenerator.h"

@interface PDKEventsGeneratorViewController ()

@property UIView * detailsView;
@property UITableView * parametersView;
@property UIView * separator;

@end

@implementation PDKEventsGeneratorViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.detailsView = [[UIView alloc] init];
    
    [self.view addSubview:self.detailsView];

    NSUserDefaults * defaults = [[NSUserDefaults alloc] initWithSuiteName:@"PassiveDataKit"];
    
    NSNumber * canDisable = [defaults valueForKey:PDKEventsGeneratorCanDisable];
    
    if (canDisable == nil || [canDisable boolValue]) {
        self.parametersView = [[UITableView alloc] init];
        self.parametersView.dataSource = self;
        self.parametersView.delegate = self;
        
        [self.view addSubview:self.parametersView];
        
        self.separator = [[UIView alloc] init];
        self.separator.backgroundColor = self.navigationController.navigationBar.barTintColor;
        self.separator.layer.shadowColor = [UIColor colorWithWhite:0.0 alpha:0.5].CGColor;
        self.separator.layer.shadowOpacity = 0.5;
        self.separator.layer.shadowRadius = 2.0;
        self.separator.layer.shadowOffset = CGSizeMake(0, 0);
        
        [self.view addSubview:self.separator];
    }
}

- (void) viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];

    if (self.separator != nil) {
        self.detailsView.frame = CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height - 60);
        self.separator.frame = CGRectMake(0, self.view.bounds.size.height - 60, self.view.bounds.size.width, 16);
        self.parametersView.frame = CGRectMake(0, self.view.bounds.size.height - 44, self.view.bounds.size.width, 44);
    } else {
        self.detailsView.frame = self.view.bounds;
    }

    NSString * path = [[NSBundle mainBundle] pathForResource:@"pdk_events_description" ofType:@"html"];
    
    if (path == nil) {
        UILabel * warningLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        warningLabel.backgroundColor = [UIColor blackColor];
        
        NSString * message = [NSString stringWithFormat:NSLocalizedStringFromTableInBundle(@"warning_pdk_missing_resource", @"PassiveDataKit", [NSBundle bundleForClass:self.class], nil), @"pdk_events_description.html"];
        
        UIFont * font = [UIFont fontWithName:@"Menlo-Bold" size:16];
        
        CGRect titleRect = [message boundingRectWithSize:CGSizeMake(self.view.frame.size.width - 16, 1000)
                                                 options:NSStringDrawingUsesLineFragmentOrigin
                                              attributes:@{ NSFontAttributeName: font }
                                                 context:nil];
        
        warningLabel.frame = CGRectMake(8, 8, self.view.frame.size.width - 16, titleRect.size.height);
        warningLabel.text = message;
        warningLabel.font = font;
        warningLabel.textColor = [UIColor colorWithRed:0 green:1.0 blue:0 alpha:1.0];
        warningLabel.textAlignment = NSTextAlignmentLeft;
        warningLabel.numberOfLines = 0;
        
        [self.detailsView addSubview:warningLabel];
    } else {
        WKWebView * webView = [[WKWebView alloc] initWithFrame:self.detailsView.bounds];
        webView.navigationDelegate = self;
        [webView loadFileURL:[NSURL fileURLWithPath:path] allowingReadAccessToURL:[NSURL fileURLWithPath:path]];
        
        [self.detailsView addSubview:webView];
    }
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.navigationItem.title = NSLocalizedStringFromTableInBundle(@"name_generator_events", @"PassiveDataKit", [NSBundle bundleForClass:self.class], nil);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSUserDefaults * defaults = [[NSUserDefaults alloc] initWithSuiteName:@"PassiveDataKit"];
    
    NSNumber * canDisable = [defaults valueForKey:PDKEventsGeneratorCanDisable];
    
    if (canDisable == nil || [canDisable boolValue]) {
        return 1;
    } else {
        return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"DataSourceCell"];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"DataSourceCell"];
    }
    
    cell.accessoryType = UITableViewCellAccessoryNone;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.accessoryView = nil;
    
    if (indexPath.row == 0) {
        cell.textLabel.text = NSLocalizedStringFromTableInBundle(@"title_pdk_events_generator_enable", @"PassiveDataKit", [NSBundle bundleForClass:self.class], nil);
        cell.detailTextLabel.text = NSLocalizedStringFromTableInBundle(@"subtitle_pdk_events_generator_enable", @"PassiveDataKit", [NSBundle bundleForClass:self.class], nil);
        
        UISwitch * toggle = [[UISwitch alloc] init];

        NSUserDefaults * defaults = [[NSUserDefaults alloc] initWithSuiteName:@"PassiveDataKit"];
        
        NSNumber * isEnabled = [defaults valueForKey:PDKEventsGeneratorEnabled];
        
        if (isEnabled == nil) {
            isEnabled = @YES;
        }
        
        [toggle setOn:isEnabled.boolValue];

        [toggle addTarget:self action:@selector(dataEnabled:) forControlEvents:UIControlEventValueChanged];
        cell.accessoryView = toggle;
        
    }
    
    return cell;
}

- (void) dataEnabled:(UISwitch *) toggle {
    NSUserDefaults * defaults = [[NSUserDefaults alloc] initWithSuiteName:@"PassiveDataKit"];

    [defaults setBool:toggle.isOn forKey:PDKEventsGeneratorEnabled];
    
    [defaults synchronize];
}

- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler
{
    [[UIApplication sharedApplication] openURL:navigationAction.request.URL];
    
    decisionHandler(WKNavigationActionPolicyAllow);
}

@end
