//
//  PDKGeneratorViewController.m
//  PassiveDataKit
//
//  Created by Chris Karr on 6/25/16.
//  Copyright © 2016 Audacious Software. All rights reserved.
//

#import "PDKGeneratorViewController.h"

@interface PDKGeneratorViewController ()

@property NSString * generator;
@end

@implementation PDKGeneratorViewController

- (id) initWithGenerator:(NSString *) generator {
    if (self = [super init]) {
        self.generator = generator;
    }
    
    return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.navigationItem.title = self.generator;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
