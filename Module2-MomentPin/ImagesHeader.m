//
//  ImagesHeader.m
//  Module2-MomentPin
//
//  Created by Daniyal Yousuf on 7/23/18.
//  Copyright © 2018 Daniyal Yousuf. All rights reserved.
//

#import "ImagesHeader.h"

@implementation ImagesHeader {
    
    __weak IBOutlet UILabel *lblTitle;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

-(void)bindData:(NSString *)title {
    lblTitle.text = title;
}

@end
