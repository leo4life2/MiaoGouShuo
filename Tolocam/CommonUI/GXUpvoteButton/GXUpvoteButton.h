//
//  GXUpvoteButton.h
//
//  Created by apple on 2017/12/19.
//  Copyright © 2017年 getElementByYou. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol LikeButtonDelegate <NSObject>

- (void)likeButtonPressEnd:(NSInteger)count;

@end

@interface GXUpvoteButton : UIButton
@property (nonatomic, weak)id<LikeButtonDelegate> delegate;
@end
