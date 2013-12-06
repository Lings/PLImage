//
//  PLImage.h
//  PLImage
//
//  Created by Lings on 12-7-24.
//  Copyright (c) 2012年 Palmlife.me. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PLImage : UIImage

@property (nonatomic, strong, readonly) NSString * imageName;

+ (PLImage *)imageNamed:(NSString *)name;

@end