//
//  ViewController.m
//  LSDemo
//
//  Created by liulei10 on 16/03/07.
//  Copyright © 2016 SAE. All rights reserved.
//

#import "ViewController.h"
#import "LiveStreamSessionManager.h"
#import "LiveStreamSDK.h"
#import "DetailViewController.h"

@interface ViewController ()<UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableview;
@property (nonatomic, strong) NSArray *list;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.list = nil;
    [LiveStreamSDK configWithAK:@"xxx" andSK:@"xxx"];
    [self.tableview reloadData];
}

#pragma mark - 
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return 2;
    } else if (section == 1) {
        return self.list ? self.list.count : 0;
    } else {
        return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            cell.textLabel.text = @"列表";
        } else if (indexPath.row == 1) {
            cell.textLabel.text = @"创建";
        }
    } else if (indexPath.section == 1) {
        cell.textLabel.text = [self.list[indexPath.row] valueForKey:@"name"];
        cell.detailTextLabel.text = [self.list[indexPath.row] valueForKey:@"tube_id"];
    }
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            [self getTubeList];
        } else if (indexPath.row == 1) {
            [self createTube];
        }
    } else if (indexPath.section == 1){
        [self performSegueWithIdentifier:@"showTube" sender:[self.list[indexPath.row] valueForKey:@"tube_id"]];
    }
    
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"showTube"]) {
        DetailViewController *vc = segue.destinationViewController;
        vc.tubeId = sender;
    }
}
#pragma mark - 
-(void)getTubeList
{
    [[LiveStreamSessionManager manager] getTubeList:^(id _Nullable responseObject, NSError * _Nullable error) {
        if (!error) {
            self.list = responseObject;
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.tableview reloadData];
            });
        }
    }];
}

-(void)createTube
{
    [[LiveStreamSessionManager manager] createTube:@"ley" description:@"test" connectLimit:10 callback:^(id  _Nullable responseObject, NSError * _Nullable error) {
        if (!error) {
            [self getTubeList];
        }
    }];
}
@end
