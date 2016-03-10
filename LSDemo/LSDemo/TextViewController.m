//
//  TextViewController.m
//  LSDemo
//
//  Created by liulei10 on 16/03/09.
//  Copyright © 2016 SAE. All rights reserved.
//

#import "TextViewController.h"

@interface TextViewController ()
@property (weak, nonatomic) IBOutlet UITextView *textView;

@end

@implementation TextViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    if (self.responseResult) {
        NSLog(@"%@",self.responseResult);
        self.textView.text = [NSString stringWithFormat:@"%@", self.responseResult];
    }
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
