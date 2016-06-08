//
//  DetailViewController.m
//  LSDemo
//
//  Created by liulei10 on 16/03/09.
//  Copyright © 2016 SAE. All rights reserved.
//

#import "DetailViewController.h"
#import "LiveStreamSessionManager.h"
#import "TextViewController.h"
#import "PlayViewController.h"

@interface DetailViewController ()
{
    NSDictionary *infoDic;
    NSInteger status;
}
@end

@implementation DetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self queryTube];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)deleteAction:(id)sender {
    [self deleteTube];
}
#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (section) {
        case 0:
            return 3;
        case 1:
            return 3;
        case 2:
            return 3;
        default:
            return 0;
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [super tableView:tableView cellForRowAtIndexPath:indexPath];
    if (infoDic) {
        if (indexPath.section == 0) {
            if (indexPath.row == 0) {
                cell.detailTextLabel.text = [infoDic valueForKey:@"name"];
            } else if (indexPath.row == 1) {
                cell.detailTextLabel.text = [infoDic valueForKey:@"description"];
            } else if (indexPath.row == 2) {
                NSString *string = @"关闭";
                if (status == 1) {
                    string = @"无信号";
                } else if (status == 2) {
                    string = @"正在直播";
                }
                cell.detailTextLabel.text = string;
            }
        } else if (indexPath.section == 1) {
            if (indexPath.row == 0) {
                NSLog(@"push url: %@", [infoDic valueForKey:@"publish_url"]);
                cell.detailTextLabel.text = [infoDic valueForKey:@"publish_url"];
            } else if (indexPath.row == 1){
                cell.detailTextLabel.text = status == 0 ? @"等待开启":@"无法操作";
            } else if (indexPath.row == 2) {
                cell.detailTextLabel.text = status != 0 ? @"可以关闭":@"无法操作";
            }
        }
    }
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (infoDic) {
        if (indexPath.section == 1 && indexPath.row == 1) {
            if (status == 0) {
                [self startTube];
            }
        } else if (indexPath.section == 1 && indexPath.row == 2) {
            if (status != 0) {
                [self stopTube];
            }
        } else if (indexPath.section == 2) {
            if (indexPath.row == 0) {
                [self getTubeStatus];
            } else if (indexPath.row == 1) {
                [self updateTubeInfo];
            } else if (indexPath.row == 2) {
                [self playTube];
            }
        }
    }
}

#pragma mark - 
-(void)queryTube
{
    [[LiveStreamSessionManager manager] queryTube:self.tubeId callback:^(id  _Nullable responseObject, NSError * _Nullable error) {
        if (error) {
            NSLog(@"query error: %@", error.localizedDescription);
        } else {
            infoDic = responseObject;
            status = [[infoDic valueForKey:@"status"] integerValue];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.tableView reloadData];
            });
            
        }
    }];
}

-(void)startTube
{
    [[LiveStreamSessionManager manager] startTube:self.tubeId callback:^(id  _Nullable responseObject, NSError * _Nullable error) {
        if (error) {
            NSLog(@"start error: %@", error.localizedDescription);
        } else {
            NSLog(@"start: %@",responseObject);
            [self queryTube];
        }
    }];
}

-(void)stopTube
{
    [[LiveStreamSessionManager manager] stopTube:self.tubeId callback:^(id  _Nullable responseObject, NSError * _Nullable error) {
        if (error) {
            NSLog(@"stop error: %@", error.localizedDescription);
        } else {
            NSLog(@"stop: %@", responseObject);
            [self queryTube];
        }
    }];
}

-(void)getTubeStatus
{
    [[LiveStreamSessionManager manager] getTubeStatus:self.tubeId callback:^(id  _Nullable responseObject, NSError * _Nullable error) {
        if (error) {
            NSLog(@"query error: %@", error.localizedDescription);
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self performSegueWithIdentifier:@"showDetail" sender:responseObject];
            });
        }
    }];
}

-(void)updateTubeInfo
{
    NSString *current = [NSString stringWithFormat:@"%.0f",[NSDate date].timeIntervalSince1970];
    [[LiveStreamSessionManager manager] updateTube:self.tubeId name:current description:current callback:^(id  _Nullable responseObject, NSError * _Nullable error) {
        if (error) {
            NSLog(@"update error: %@", error.localizedDescription);
        } else {
            NSLog(@"update success: %@", responseObject);
            [self queryTube];
        }
    }];
}

-(void)deleteTube
{
    [[LiveStreamSessionManager manager] deleteTube:self.tubeId callback:^(id  _Nullable responseObject, NSError * _Nullable error) {
        if (error) {
            NSLog(@"delete error: %@", error.localizedDescription);
        } else {
            NSLog(@"delete success: %@", responseObject);
        }
    }];
}

-(void)playTube
{
    [self performSegueWithIdentifier:@"playTube" sender:self.tubeId];
}
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"showDetail"]) {
        TextViewController *vc = segue.destinationViewController;
        vc.responseResult = sender;
    } else if ([segue.identifier isEqualToString:@"playTube"]) {
        PlayViewController *vc = segue.destinationViewController;
        vc.tubeId = self.tubeId;
    }
}


@end
