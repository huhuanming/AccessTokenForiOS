//
//  ViewController.m
//  AccessToken
//
//  Created by 胡 桓铭 on 14/8/13.
//  Copyright (c) 2014年 agile. All rights reserved.
//

#import "ViewController.h"


@interface ViewController ()

@end

@implementation ViewController
            
- (void)viewDidLoad {
    [super viewDidLoad];
    [[AccessToken sharedInstance] setToken:@"4c20393e-c2bc-4238-94a7-6182474286af" AndKey:@"--iS-TOfVaa1HUf1AJmQ0Q"];
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    [dic setObject:@"test" forKey:@"a"];
    [dic setObject:@"我们" forKey:@"b"];
    [dic setObject:[NSNumber numberWithInt:1] forKey:@"c"];
    
    NSLog(@"%@",[[AccessToken sharedInstance] encode:[dic copy]]);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
