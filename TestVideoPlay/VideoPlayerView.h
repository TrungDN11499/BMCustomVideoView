//
//  VideoPlayerView.h
//  TestVideoPlay
//
//  Created by Be More on 8/4/20.
//  Copyright © 2020 Yami No Mid. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVKit/AVKit.h>
#import <AVFoundation/AVFoundation.h>
#import "CustomSlider.h"

NS_ASSUME_NONNULL_BEGIN

@interface VideoPlayerView : UIView
@property (nonatomic, strong) UIActivityIndicatorView *activitiesIndicatorView;
@property (nonatomic, strong) UIButton *pausePlayButton;
@property (nonatomic, strong) UILabel *currentTimeLabel;
@property (nonatomic, strong) UILabel *videoLenghtLabel;
@property (nonatomic, strong) UILabel *slashLabel;
@property (nonatomic, strong) CustomSlider *videoSlider;
@property (nonatomic, strong) UIImageView *imageFullScreen;
@property (nonatomic, strong) UIView *controlsContainerView;
@property (nonatomic, assign) bool isPlaying;
@property (nonatomic, assign) bool isSliding;
@property (nonatomic, assign) bool isDoneLoading;
@property (nonatomic, assign) bool isSetTimmer;
@property (nonatomic, assign) bool isDonePlaying;
@property (nonatomic, assign) bool isFourceStop;
@property (nonatomic, assign) NSString *urlString;
@property (nonatomic, strong) AVPlayer *player;
@property (nonatomic, strong) AVPlayer *playerPreview;
@property (nonatomic, assign) AVPlayerLayer *videoPlayerLayer;
@property (nonatomic, assign) AVPlayerLayer *videoPreviewLayer;
@property (nonatomic, assign) NSLayoutConstraint *videoSliderBottomConstraints;
@property (nonatomic, assign, nullable) NSTimer *timer;
@property (nonatomic, strong) UILabel *trackTimeLabel;
@property (nonatomic, strong) UIView *viewPreview;
@end

NS_ASSUME_NONNULL_END
