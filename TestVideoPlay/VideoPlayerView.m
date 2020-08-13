//
//  VideoPlayerView.m
//  TestVideoPlay
//
//  Created by Be More on 8/4/20.
//  Copyright © 2020 Yami No Mid. All rights reserved.
//

#import "VideoPlayerView.h"
#import "CustomSlider.h"

CGFloat videoSliderHeight = 50;
CGFloat thumbRadius = 20;
CGFloat textFontSize = 13;
CGFloat marginIn = 16;
CGFloat beginPoint = 0;
CGFloat stopPoint = 0;
CGFloat viewPreviewWidth = 0;

@interface VideoPlayerView () {
    NSLayoutConstraint *viewPreviewXConstraints;
}
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
@property (nonatomic, assign) NSString *loadKey;
@property (nonatomic, assign) AVPlayerLayer *videoPlayerLayer;
@property (nonatomic, assign) AVPlayerLayer *videoPreviewLayer;
@property (nonatomic, assign) NSLayoutConstraint *videoSliderBottomConstraints;
@property (nonatomic, assign) NSTimer *timer;
@property (nonatomic, strong) UILabel *trackTimeLabel;
@property (nonatomic, strong) UIView *viewPreview;
@end

@implementation VideoPlayerView

- (UIActivityIndicatorView *)activitiesIndicatorView {
    if (!_activitiesIndicatorView) {
        _activitiesIndicatorView = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleLarge];
        _activitiesIndicatorView.color = UIColor.whiteColor;
        _activitiesIndicatorView.translatesAutoresizingMaskIntoConstraints = false;
        [_activitiesIndicatorView startAnimating];
    }
    return _activitiesIndicatorView;
}

- (UIButton *)pausePlayButton {
    if (!_pausePlayButton) {
        _pausePlayButton = [UIButton buttonWithType:UIButtonTypeSystem];
        [_pausePlayButton setImage:[UIImage imageNamed:@"pause"] forState:UIControlStateNormal];
        _pausePlayButton.translatesAutoresizingMaskIntoConstraints = false;
        _pausePlayButton.tintColor = UIColor.whiteColor;
        [_pausePlayButton setHidden:true];
        [_pausePlayButton addTarget:self action:@selector(handlePlay:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _pausePlayButton;
}

- (UILabel *)currentTimeLabel {
    if (!_currentTimeLabel) {
        _currentTimeLabel = [UILabel new];
        _currentTimeLabel.text = @"00:00";
        _currentTimeLabel.textColor = UIColor.whiteColor;
        _currentTimeLabel.textAlignment = NSTextAlignmentLeft;
        _currentTimeLabel.font = [UIFont boldSystemFontOfSize:textFontSize];
        _currentTimeLabel.translatesAutoresizingMaskIntoConstraints = false;
    }
    return _currentTimeLabel;
}

- (UILabel *)slashLabel {
    if (!_slashLabel) {
        _slashLabel = [UILabel new];
        _slashLabel.text = @"/";
        _slashLabel.textColor = UIColor.whiteColor;
        _slashLabel.textAlignment = NSTextAlignmentCenter;
        _slashLabel.font = [UIFont boldSystemFontOfSize:textFontSize];
        _slashLabel.translatesAutoresizingMaskIntoConstraints = false;
    }
    return _slashLabel;
}

- (UILabel *)trackTimeLabel {
    if(!_trackTimeLabel) {
        _trackTimeLabel = [UILabel new];
        [_trackTimeLabel setTextColor:UIColor.whiteColor];
        [_trackTimeLabel setHidden:true];
        _trackTimeLabel.font = [UIFont boldSystemFontOfSize:textFontSize];
        _trackTimeLabel.translatesAutoresizingMaskIntoConstraints = false;
    }
    return _trackTimeLabel;
}

- (UIView *)viewPreview {
    if(!_viewPreview) {
        _viewPreview = [UIView new];
        _viewPreview.backgroundColor = UIColor.blackColor;
        _viewPreview.layer.borderWidth = 1;
        [_viewPreview setHidden:true];
        _viewPreview.layer.borderColor = UIColor.whiteColor.CGColor;
        _viewPreview.translatesAutoresizingMaskIntoConstraints = false;
    }
    return _viewPreview;
}

- (UILabel *)videoLenghtLabel {
    if (!_videoLenghtLabel) {
        _videoLenghtLabel = [UILabel new];
        _videoLenghtLabel.text = @"00:00";
        _videoLenghtLabel.textColor = UIColor.whiteColor;
        _videoLenghtLabel.textAlignment = NSTextAlignmentRight;
        _videoLenghtLabel.font = [UIFont boldSystemFontOfSize:textFontSize];
        _videoLenghtLabel.translatesAutoresizingMaskIntoConstraints = false;
    }
    return _videoLenghtLabel;
}

- (CustomSlider *)videoSlider {
    if(!_videoSlider) {
        _videoSlider = [CustomSlider new];
        _videoSlider.minimumTrackTintColor = UIColor.redColor;
        _videoSlider.maximumTrackTintColor = UIColor.lightGrayColor;
        [_videoSlider setThumbImage:[self makeCircleWith:CGSizeMake(thumbRadius, thumbRadius) color:UIColor.redColor] forState:UIControlStateNormal];
        _videoSlider.translatesAutoresizingMaskIntoConstraints = false;
        [_videoSlider addTarget:self action:@selector(handleSliderChange:event:) forControlEvents:UIControlEventValueChanged];
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(sliderTapped:)];
        [_videoSlider addGestureRecognizer:tapGesture];
    }
    
    return _videoSlider;
}

- (void)sliderTapped:(UIGestureRecognizer *)g
{
    if (_isDoneLoading) {
        UISlider* s = (UISlider*)g.view;
        if (s.highlighted) {
            return;
        }
        [self stopTimer];
        if (_isDonePlaying) {
            [self.pausePlayButton setImage:[UIImage imageNamed:@"play"] forState:UIControlStateNormal];
            [_player pause];
            self.isDonePlaying = false;
            self.isPlaying = false;
        }
        _isSliding = true;
        CGPoint pt = [g locationInView: s];
        CGFloat percentage = pt.x / s.bounds.size.width;
        CGFloat delta = percentage * (s.maximumValue - s.minimumValue);
        CGFloat value = s.minimumValue + delta;
        [s setValue:value animated:false];
        CMTime duration = self.player.currentItem.duration;
        Float64 seconds = CMTimeGetSeconds(duration);
        double seekValue = (Float64) self.videoSlider.value * seconds;
        CMTime seekTime = CMTimeMake((int64_t) seekValue, 1);
        [self.player seekToTime:seekTime completionHandler:^(BOOL finished) {
            [self setTimer];
            self->_isSliding = false;
        }];
    }
}

- (void)handleSliderChange: (UISlider *)slider event: (UIEvent *) event {
    _isFourceStop = false;

    CGRect trackRect = [slider trackRectForBounds:slider.bounds];
    CGRect thumbRect = [slider thumbRectForBounds:slider.bounds trackRect:trackRect value:slider.value];
    
    if (thumbRect.origin.x >= beginPoint && thumbRect.origin.x <= stopPoint && self->viewPreviewXConstraints) {
        self->viewPreviewXConstraints.constant = thumbRect.origin.x - viewPreviewWidth / 2;
        [self layoutIfNeeded];
    }
    CMTime duration = self.player.currentItem.duration;
    
//    if (_isDoneLoading) {
        Float64 seconds = CMTimeGetSeconds(duration);
        double value = (Float64) self.videoSlider.value * seconds;
        CMTime seekTime = CMTimeMake((int64_t) value, 1);
        
        // handle slider state.
        UITouch *touchEvent = [[event allTouches] anyObject];
        switch (touchEvent.phase) {
            case UITouchPhaseBegan:
                self.isSliding = true;
                [self stopTimer];
                [_player pause];
                [self hideTimeLabel:YES];
                if (_isDonePlaying) {
                    [self.pausePlayButton setImage:[UIImage imageNamed:@"play"] forState:UIControlStateNormal];
                }
                break;
            case UITouchPhaseMoved:
                [self.playerPreview seekToTime:seekTime completionHandler:^(BOOL finished) {
                }];
                break;
            case UITouchPhaseEnded:
                [self setTimer];
                [self hideTimeLabel:NO];
                if (self->_isPlaying) {
                    [self->_player play];
                }
                if (_isDonePlaying) {
                    [_player pause];
                    self.isDonePlaying = false;
                    self.isPlaying = false;
                }
                [self seekTime:seekTime];
                break;
            default:
                break;
        }
//    }
}

- (void)seekTime:(CMTime)time {
    [self.player seekToTime:time completionHandler:^(BOOL finished) {
        self.isSliding = false;
    }];
}

- (UIImageView *)imageFullScreen {
    if (!_imageFullScreen) {
        _imageFullScreen = [UIImageView new];
        _imageFullScreen.image = [UIImage imageNamed:@"fullScreen"];
        _imageFullScreen.image = [_imageFullScreen.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        _imageFullScreen.tintColor = UIColor.whiteColor;
        _imageFullScreen.translatesAutoresizingMaskIntoConstraints = false;
        [_imageFullScreen setUserInteractionEnabled:true];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(handleFullScreen:)];
        [_imageFullScreen addGestureRecognizer:tap];
    }
    return _imageFullScreen;
}

- (void)handleFullScreen: (UIImageView *)sender {
    NSNumber *value = UIDeviceOrientationIsLandscape([UIDevice currentDevice].orientation) ? [NSNumber numberWithInt:UIInterfaceOrientationPortrait] : [NSNumber numberWithInt:UIInterfaceOrientationLandscapeRight];
    [[UIDevice currentDevice] setValue:value forKey:@"orientation"];
    [UIViewController attemptRotationToDeviceOrientation];
    [self stopTimer];
    [self setTimer];
}

- (UIView *)controlsContainerView {
    if (!_controlsContainerView) {
        _controlsContainerView = [UIView new];
        _controlsContainerView.backgroundColor = UIColor.blackColor;
        _controlsContainerView.translatesAutoresizingMaskIntoConstraints = false;
    }
    
    return _controlsContainerView;
}

- (UIImage *)makeCircleWith:(CGSize)size color: (UIColor*) color {
    UIGraphicsBeginImageContextWithOptions(size, false, 0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, color.CGColor);
    CGContextSetStrokeColorWithColor(context, UIColor.clearColor.CGColor);
    CGRect bounds = CGRectMake(0, 0, size.width, size.height);
    CGContextAddEllipseInRect(context, bounds);
    CGContextDrawPath(context, kCGPathFill);
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

- (void)handlePlay:(UIButton *)sender {
    if (_isPlaying && !_isDonePlaying) {
        [_player pause];
        _isFourceStop = true;
        [self.pausePlayButton setImage:[UIImage imageNamed:@"play"] forState:UIControlStateNormal];
    } else if (!_isPlaying && !_isDonePlaying) {
        [_player play];
        _isFourceStop = false;
        [_pausePlayButton setImage:[UIImage imageNamed:@"pause"] forState:UIControlStateNormal];
    } else {
        self.videoSlider.value = 0;
        [self.player seekToTime:kCMTimeZero];
        [self.player play];
        [self.pausePlayButton setImage:[UIImage imageNamed:@"pause"] forState:UIControlStateNormal];
        _isDonePlaying = !_isDonePlaying;
    }
    _isPlaying = !_isPlaying;
    [self stopTimer];
    [self setTimer];
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _isPlaying = false;
        _isSliding = false;
        _isDoneLoading = false;
        _isSetTimmer = false;
        _isDonePlaying = false;
        _isFourceStop = false;
        
        viewPreviewWidth = (UIScreen.mainScreen.bounds.size.width - 3 * marginIn) / 2;
        beginPoint = marginIn + viewPreviewWidth / 2;
        stopPoint = UIScreen.mainScreen.bounds.size.width - beginPoint;
        
        _urlString = @"https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/TearsOfSteel.mp4";
        _loadKey = @"currentItem.loadedTimeRanges";
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(handleHideShowControlView)];
        [self addGestureRecognizer:tap];
        [self setUpPlayerViews];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
    }
    return self;
}

- (void)setUpViews {
    // activities indicator constraints.
    [self.controlsContainerView addSubview:self.activitiesIndicatorView];
    [[self.activitiesIndicatorView.centerXAnchor constraintEqualToAnchor:self.controlsContainerView.centerXAnchor]setActive:true];
    [[self.activitiesIndicatorView.centerYAnchor constraintEqualToAnchor:self.controlsContainerView.centerYAnchor]setActive:true];
    
    // pause play button constraints.
    [self.controlsContainerView addSubview:self.pausePlayButton];
    [[self.pausePlayButton.centerYAnchor constraintEqualToAnchor:self.controlsContainerView.centerYAnchor]setActive:true];
    [[self.pausePlayButton.centerXAnchor constraintEqualToAnchor:self.controlsContainerView.centerXAnchor]setActive:true];
    [[self.pausePlayButton.widthAnchor constraintEqualToConstant:50]setActive: true];
    [[self.pausePlayButton.heightAnchor constraintEqualToConstant:50]setActive: true];
    
    [self.controlsContainerView addSubview:self.videoSlider];
    [[self.videoSlider.rightAnchor constraintEqualToAnchor:self.controlsContainerView.rightAnchor]setActive:true];
    [[self.videoSlider.leftAnchor constraintEqualToAnchor:self.controlsContainerView.leftAnchor]setActive:true];
    _videoSliderBottomConstraints = [self.videoSlider.bottomAnchor constraintEqualToAnchor:self.controlsContainerView.bottomAnchor constant:videoSliderHeight / 2];
    [_videoSliderBottomConstraints setActive:true];
    [[self.videoSlider.heightAnchor constraintEqualToConstant:videoSliderHeight]setActive:true];
    
    // current time label constraints.
    [self.controlsContainerView addSubview:self.currentTimeLabel];
    [[self.currentTimeLabel.bottomAnchor constraintEqualToAnchor:self.videoSlider.topAnchor]setActive:true];
    [[self.currentTimeLabel.leftAnchor constraintEqualToAnchor:self.controlsContainerView.leftAnchor constant:marginIn]setActive:true];
    [[self.currentTimeLabel.heightAnchor constraintEqualToConstant:24]setActive:true];
    
    // slash label constraints.
    [self.controlsContainerView addSubview:self.slashLabel];
    [[self.slashLabel.leftAnchor constraintEqualToAnchor:self.currentTimeLabel.rightAnchor constant:3]setActive:true];
    [[self.slashLabel.centerYAnchor constraintEqualToAnchor:self.currentTimeLabel.centerYAnchor]setActive:true];
    [[self.slashLabel.heightAnchor constraintEqualToConstant:24]setActive:true];
    
    // current time label constraints.
    [self.controlsContainerView addSubview:self.videoLenghtLabel];
    [[self.videoLenghtLabel.leftAnchor constraintEqualToAnchor:self.slashLabel.rightAnchor constant: 3]setActive:true];
    [[self.videoLenghtLabel.centerYAnchor constraintEqualToAnchor:self.currentTimeLabel.centerYAnchor]setActive:true];
    [[self.videoLenghtLabel.heightAnchor constraintEqualToConstant:24]setActive:true];
    
    // image full screen constraints.
    [self.controlsContainerView addSubview:self.imageFullScreen];
    [[self.imageFullScreen.rightAnchor constraintEqualToAnchor:self.controlsContainerView.rightAnchor constant:-marginIn]setActive:true];
    [[self.imageFullScreen.bottomAnchor constraintEqualToAnchor:self.videoSlider.topAnchor]setActive:true];
    [[self.imageFullScreen.heightAnchor constraintEqualToConstant:20]setActive:true];
    [[self.imageFullScreen.widthAnchor constraintEqualToConstant:20]setActive:true];
    
    // preview view constraints.
    [self.controlsContainerView addSubview:self.viewPreview];
    self->viewPreviewXConstraints = [self.viewPreview.leftAnchor constraintEqualToAnchor:self.controlsContainerView.leftAnchor constant:marginIn];
    [self->viewPreviewXConstraints setActive:true];
    [[self.viewPreview.widthAnchor constraintEqualToConstant:viewPreviewWidth]setActive:true];
    [[self.viewPreview.heightAnchor constraintEqualToAnchor:self.viewPreview.widthAnchor multiplier:9.0/16.0]setActive:true];
    
    // track label constraints.
    [self.controlsContainerView addSubview:self.trackTimeLabel];
    [[self.trackTimeLabel.centerXAnchor constraintEqualToAnchor:self.viewPreview.centerXAnchor]setActive:true];
    [[self.trackTimeLabel.topAnchor constraintEqualToAnchor:self.viewPreview.bottomAnchor]setActive:true];
    [[self.trackTimeLabel.bottomAnchor constraintEqualToAnchor:self.videoSlider.topAnchor]setActive:true];
    
}

- (void)setUpPlayerViews {
    NSURL *url = [NSURL URLWithString:_urlString];
    _player = [AVPlayer playerWithURL:url];
    _videoPlayerLayer = [AVPlayerLayer playerLayerWithPlayer:_player];
    
    _playerPreview = [AVPlayer playerWithURL:url];
    _videoPreviewLayer = [AVPlayerLayer playerLayerWithPlayer:_playerPreview];
    
    // set up all constraints.
    dispatch_async(dispatch_get_main_queue(), ^{
        self->_videoPlayerLayer.frame = self.bounds;
        [self.layer addSublayer:self->_videoPlayerLayer];
        
        [self setUpGradientLayer];
        [self addSubview:self.controlsContainerView];
        [[self.controlsContainerView.topAnchor constraintEqualToAnchor:self.topAnchor]setActive:true];
        [[self.controlsContainerView.bottomAnchor constraintEqualToAnchor:self.bottomAnchor]setActive:true];
        [[self.controlsContainerView.rightAnchor constraintEqualToAnchor:self.rightAnchor]setActive:true];
        [[self.controlsContainerView.leftAnchor constraintEqualToAnchor:self.leftAnchor]setActive:true];
        [self setUpViews];
        
        // set up preview player layer.
        self->_videoPreviewLayer.frame = CGRectMake(0, 0, viewPreviewWidth, viewPreviewWidth * (9.0 / 16.0));
        [self.viewPreview.layer addSublayer:self->_videoPreviewLayer];
    });
    
    // done playing notify.
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(donePlaying) name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
    
    // needed constant.
    CMTime interval = CMTimeMake(1, 2);
    __weak __typeof__(self) weakSelf = self;
//    _player.currentItem.playbackBufferEmpty
    // main player.
    [_player addObserver:self forKeyPath:_loadKey options: NSKeyValueObservingOptionNew context:nil];
    [_player addObserver:self forKeyPath: @"currentItem.playbackBufferEmpty" options: NSKeyValueObservingOptionNew context:nil];
    [_player addObserver:self forKeyPath: @"currentItem.playbackLikelyToKeepUp" options: NSKeyValueObservingOptionNew context:nil];
    [_player addObserver:self forKeyPath: @"currentItem.playbackBufferFull" options: NSKeyValueObservingOptionNew context:nil];
    [_player addPeriodicTimeObserverForInterval:interval queue:dispatch_get_main_queue() usingBlock:^(CMTime time) {
        __typeof__(self) strongSelf = weakSelf;
        if (!strongSelf) {
            return;
        }
        Float64 second = CMTimeGetSeconds(time);
        strongSelf->_currentTimeLabel.text = [NSString stringWithFormat:@"%@:%@",  [strongSelf getMin:time],[strongSelf getSecond:time]];
        CMTime duration = strongSelf->_player.currentItem.duration;
        Float64 durationSeconds = CMTimeGetSeconds(duration);
        if (!strongSelf->_isSliding) {
            strongSelf->_videoSlider.value = (float) (second / durationSeconds);
        }
    }];
    
    // preview player
    [_playerPreview addPeriodicTimeObserverForInterval:interval queue:dispatch_get_main_queue() usingBlock:^(CMTime time) {
        __typeof__(self) strongSelf = weakSelf;
        if (!strongSelf) {
            return;
        }
        strongSelf->_trackTimeLabel.text = [NSString stringWithFormat:@"%@:%@",  [strongSelf getMin:time],[strongSelf getSecond:time]];
    }];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    
    if (keyPath == _loadKey) {
        [self.activitiesIndicatorView stopAnimating];
        [self.pausePlayButton setHidden:false];
        if (!_isFourceStop) {
            [_player play];
            _isPlaying = true;
        }
        if (!_isSetTimmer) {
            [NSTimer scheduledTimerWithTimeInterval:1.5 target:self selector:@selector(handleHideShowControlView) userInfo:nil repeats:NO];
            _isSetTimmer = true;
        }
        self.isDoneLoading = true;
        self.controlsContainerView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.3];
        CMTime duration = self.player.currentItem.duration;
        self.videoLenghtLabel.text = [NSString stringWithFormat: @"%@:%@", [self getMin:duration], [self getSecond:duration]];
    }else if ([keyPath  isEqual: @"currentItem.playbackBufferEmpty"]) {
        [self.activitiesIndicatorView stopAnimating];
        [self.pausePlayButton setHidden:false];
         [self.player play];
    } else if ([keyPath  isEqual: @"currentItem.playbackLikelyToKeepUp"]) {
        if (!_isFourceStop) {
            [self.activitiesIndicatorView startAnimating];
            [self.pausePlayButton setHidden:true];
            [self.player pause];
        }
    } else if ([keyPath  isEqual: @"currentItem.playbackBufferFull"]) {
        [self.activitiesIndicatorView stopAnimating];
        [self.pausePlayButton setHidden:false];
        [self.player play];
    }
}

- (void)donePlaying {
    self.controlsContainerView.alpha = 1;
    UIImage *playbackImage = [[UIImage imageNamed:@"playback"]imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [self.pausePlayButton setImage:playbackImage forState:UIControlStateNormal];
    self.pausePlayButton.tintColor = UIColor.whiteColor;
    _isDonePlaying = true;
    _isPlaying = false;
    _isFourceStop = true;
}

- (void)setUpGradientLayer {
    CAGradientLayer *gradient = [CAGradientLayer new];
    gradient.frame = self.bounds;
    NSArray<UIColor *> *arrayColor = [[NSArray alloc]initWithObjects:UIColor.clearColor, UIColor.blackColor, nil];
    gradient.colors = [NSArray arrayWithArray:arrayColor];
    NSArray<NSNumber *> * locations = [[NSArray alloc]initWithObjects: [NSNumber numberWithFloat:0.7], [NSNumber numberWithFloat:1.2], nil];
    gradient.locations = locations;
    [self.controlsContainerView.layer addSublayer:gradient];
}

- (void)handleHideShowControlView {
    if (_isDoneLoading) {
        [UIView animateWithDuration:0.3 animations:^{
            self.controlsContainerView.alpha =  self.controlsContainerView.alpha == 1 ? 0 : 1;
            [self stopTimer];
        }];
        if (self.controlsContainerView.alpha == 1) {
            [self setTimer];
        }
    }
}

- (void)setTimer {
    _timer = [NSTimer scheduledTimerWithTimeInterval:2 target:self selector:@selector(handleHideShowControlView) userInfo:nil repeats:NO];
}

- (void)stopTimer {
    [self.timer invalidate];
    self.timer = nil;
}

- (void)hideTimeLabel: (BOOL)isShow {
    [self.viewPreview setHidden:!isShow];
    [self.trackTimeLabel setHidden:!isShow];
    [self.currentTimeLabel setHidden:isShow];
    [self.slashLabel setHidden:isShow];
    [self.videoLenghtLabel setHidden:isShow];
}

- (NSString *)getSecond:(CMTime)time {
    Float64 second = CMTimeGetSeconds(time);
    int calculateSecond = (int) second % 60;
    return [NSString stringWithFormat:@"%02d", calculateSecond];
}

- (NSString *)getMin:(CMTime)time {
    Float64 second = CMTimeGetSeconds(time);
    int calculateMin = (int) second / 60;
    return [NSString stringWithFormat:@"%02d", calculateMin];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    dispatch_async(dispatch_get_main_queue(), ^{
        self->_videoPlayerLayer.frame = self.bounds;
    });
    _videoSliderBottomConstraints.constant = UIDeviceOrientationIsLandscape([UIDevice currentDevice].orientation) ? -30 : videoSliderHeight / 2;
    [self layoutIfNeeded];
}

-(UIImage *)createThumbnailOfVideoFromRemoteUrl:(CMTime)atTime {
    NSURL *url = [NSURL URLWithString:self.urlString];
    AVAsset *asset = [AVAsset assetWithURL:url];
    AVAssetImageGenerator *assetImageGenerate = [AVAssetImageGenerator assetImageGeneratorWithAsset:asset];
    assetImageGenerate.appliesPreferredTrackTransform = true;
    
    CGImageRef imageRef = [assetImageGenerate copyCGImageAtTime:atTime actualTime:nil error:nil];
    UIImage *thumbImage = [UIImage imageWithCGImage:imageRef];
    
    return thumbImage;
}

@end
