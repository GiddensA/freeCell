//
//  CardImageView.h
//  FreeCells2
//
//  Created by Alan L  Hamilton on 2020/10/2.
//  Copyright © 2020 Alan L  Hamilton. All rights reserved.
//

#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

@interface CardImageView : NSImageView
@property (nonatomic) IBInspectable NSInteger index;
@property (nonatomic) IBInspectable NSInteger row;
@property (nonatomic) IBInspectable NSInteger column;
@end

NS_ASSUME_NONNULL_END
