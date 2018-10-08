//
//  ImagesCollectionCell.m
//  Module2-MomentPin
//
//  Created by Daniyal Yousuf on 7/23/18.
//  Copyright © 2018 Daniyal Yousuf. All rights reserved.
//

#import "ImagesCollectionCell.h"

@implementation ImagesCollectionCell {
    
    __weak IBOutlet UIImageView *imageViewPhoto;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

-(void)bindData:(UIImage *)currentImage {
    imageViewPhoto.image = currentImage;
}

@end
