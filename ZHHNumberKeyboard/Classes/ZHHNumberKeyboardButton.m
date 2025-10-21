//
//  ZHHNumberKeyboardButton.m
//  ZHHAnneKitExample
//
//  Created by 桃色三岁 on 2025/3/2.
//  Copyright © 2025 桃色三岁. All rights reserved.
//

#import "ZHHNumberKeyboardButton.h"
#import "ZHHNumberKeyboardHelper.h"

@interface ZHHNumberKeyboardButton ()
@property (nonatomic, strong) UIView *highlightOverlay; // 高亮遮罩层
@end

@implementation ZHHNumberKeyboardButton

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setupHighlightOverlay];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    if (self = [super initWithCoder:coder]) {
        [self setupHighlightOverlay];
    }
    return self;
}

/// 初始化高亮遮罩层
- (void)setupHighlightOverlay {
    self.highlightOverlay = [[UIView alloc] init];
    self.highlightOverlay.backgroundColor = [UIColor colorWithWhite:0 alpha:0.05]; // 更轻柔的半透明黑色（5%）
    self.highlightOverlay.userInteractionEnabled = NO;
    self.highlightOverlay.alpha = 0;
    self.highlightOverlay.layer.cornerRadius = 5;
    self.highlightOverlay.layer.masksToBounds = YES;
    [self addSubview:self.highlightOverlay];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    // 让高亮遮罩层覆盖整个按钮
    self.highlightOverlay.frame = self.bounds;
}

/// 重写 highlighted 状态的设置，添加动画效果
- (void)setHighlighted:(BOOL)highlighted {
    [super setHighlighted:highlighted];
    
    if (highlighted) {
        // 按下时：显示高亮遮罩
        [UIView animateWithDuration:0.1 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            self.highlightOverlay.alpha = 1.0;
        } completion:nil];
    } else {
        // 松开时：隐藏高亮遮罩
        [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            self.highlightOverlay.alpha = 0;
        } completion:nil];
    }
}

- (void)setBackgroundColor:(UIColor *)backgroundColor forState:(UIControlState)state {
    UIImage *backgroundImage = [ZHHNumberKeyboardHelper imageWithColor:backgroundColor size:CGSizeMake(1, 1)];
    [self setBackgroundImage:backgroundImage forState:state];
}

@end
