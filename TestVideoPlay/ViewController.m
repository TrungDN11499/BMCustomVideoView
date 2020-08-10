//
//  ViewController.m
//  TestVideoPlay
//
//  Created by Be More on 8/3/20.
//  Copyright © 2020 Yami No Mid. All rights reserved.
//

#import "ViewController.h"
#import "VideoPlayerView.h"

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UIView *videoView;
@property (nonatomic, strong) VideoPlayerView *videoPlayer;
@end

@implementation ViewController

- (VideoPlayerView *)videoPlayer {
    if (!_videoPlayer) {
        _videoPlayer = [VideoPlayerView new];
        _videoPlayer.translatesAutoresizingMaskIntoConstraints = false;
    }
    return _videoPlayer;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.videoView addSubview:self.videoPlayer];
    
    [[self.videoPlayer.topAnchor constraintEqualToAnchor:self.videoView.topAnchor]setActive:true];
    [[self.videoPlayer.bottomAnchor constraintEqualToAnchor:self.videoView.bottomAnchor]setActive:true];
    [[self.videoPlayer.rightAnchor constraintEqualToAnchor:self.videoView.rightAnchor]setActive:true];
    [[self.videoPlayer.leftAnchor constraintEqualToAnchor:self.videoView.leftAnchor]setActive:true];
}

@end
