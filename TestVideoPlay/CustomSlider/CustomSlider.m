//
//  CustomSlider.m
//  TestVideoPlay
//
//  Created by Be More on 8/6/20.
//  Copyright © 2020 Yami No Mid. All rights reserved.
//

#import "CustomSlider.h"

@interface CustomSlider ()
@property (nonatomic, strong) UILabel *trackTimeLabel;
@property (nonatomic, strong) UIView *thumbView;
@end

@implementation CustomSlider

- (UILabel *)trackTimeLabel {
    
    if(!_trackTimeLabel) {
        _trackTimeLabel = [UILabel new];
//        [_trackTimeLabel setTextColor:UIColor.whiteColor];
        _trackTimeLabel.text = @"test text";
       
        [_trackTimeLabel addGestureRecognizer:  [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(top)]];
    }
    return _trackTimeLabel;
}

-(void)top {
    NSLog(@"Tap");
}

- (UIView *)thumbView {
    if(!_thumbView) {
        _thumbView = [UIView new];
        [_thumbView setUserInteractionEnabled:true];
        [_thumbView addGestureRecognizer:  [[UITapGestureRecognizer alloc] initWithTarget:self.superview action:@selector(top)]];
        _thumbView.backgroundColor = UIColor.redColor;
    }
    return _thumbView;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    _thumbView.frame = [self thumbRectForBounds:CGRectMake(0, 0, 10, 10) trackRect: [self trackRectForBounds:self.bounds]  value:self.value];
    _trackTimeLabel.frame = [self thumbRectForBounds:self.bounds trackRect: [self trackRectForBounds:self.bounds]  value:self.value];
}


- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setUpViews];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        [self setUpViews];
    }
    return self;
}

- (void)setUpViews {
//    [self addSubview:self.trackTimeLabel];
//    [self addSubview:self.thumbView];
//    self.thumbView.layer.zPosition = self.layer.zPosition + 1;
}

@end
