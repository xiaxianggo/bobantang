//
//  BBTDownloadCell.h
//  bobantang
//
//  Created by Xia Xiang on 10/7/14.
//  Copyright (c) 2014 Xia Xiang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BBTDownloadCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UILabel *downloadStatLabel;
@property (nonatomic, weak) IBOutlet UILabel *downloadedCountLabel;
@property (nonatomic, weak) IBOutlet UILabel *fullSizeCountLabel;

@property (nonatomic, weak) IBOutlet UIProgressView *downloadProgressView;
@end
