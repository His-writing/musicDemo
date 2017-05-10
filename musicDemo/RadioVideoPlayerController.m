//
//  KrVideoPlayerController.m
//  KrVideoPlayerPlus
//
//  Created by JiaHaiyang on 15/6/19.
//  Copyright (c) 2015年 JiaHaiyang. All rights reserved.
//
//#import "ADBMobile.h"
#import "RadioVideoPlayerController.h"
#import "RadioVideoPlayerControlView.h"

#import <AVFoundation/AVFoundation.h>
//#import "NewsChildViewController.h"

#import "MacroCommon.h"

static const CGFloat kVideoPlayerControllerAnimationTimeinterval = 0.3f;

@interface RadioVideoPlayerController()

@property (nonatomic, strong) RadioVideoPlayerControlView *videoControl;
@property (nonatomic, strong) UIView *movieBackgroundView;
@property (nonatomic, assign) BOOL isFullscreenMode;
@property (nonatomic, assign) CGRect originFrame;
@property (nonatomic, strong) NSTimer *durationTimer;
@property (nonatomic, assign) BOOL isFrist;
@end

@implementation RadioVideoPlayerController

- (void)dealloc
{
    [self cancelObserver];
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super init];
    if (self) {
        self.isFrist = YES;
        self.view.frame = frame;
        self.view.backgroundColor = [UIColor whiteColor];
        self.controlStyle = MPMovieControlStyleNone;
        [self.view addSubview:self.videoControl];
        self.videoControl.frame = self.view.bounds;
        [self configObserver];
        [self configControlAction];
        //        [self ListeningRotating];
    }
    return self;
}

#pragma mark - Override Method

- (void)setContentURL:(NSURL *)contentURL
{
    
    //    [self stop];
    
    //    [self pauseButtonHidden];
    //    [self.videoControl.indicatorView startAnimating];
    
    //    [self.videoControl animateShow];
    
    
    //    if ([self isPreparedToPlay]) {
    //
    //    }
    
    
    [super setContentURL:contentURL];
    
    [self startDurationTimer];
    
    
    
      //  [self prepareToPlay];
    
    //    [self.videoControl.indicatorView startAnimating];
    
}


-(void)setTitleLabled:(NSString *)text{
    
    
    self.videoControl.titleLabled.text=text;
    
}
#pragma mark - Publick Method

- (void)showInWindow
{
    UIWindow *keyWindow = [[UIApplication sharedApplication] keyWindow];
    if (!keyWindow) {
        keyWindow = [[[UIApplication sharedApplication] windows] firstObject];
    }
    [keyWindow addSubview:self.view];
    self.view.alpha = 0.0;
    [UIView animateWithDuration:kVideoPlayerControllerAnimationTimeinterval animations:^{
        self.view.alpha = 1.0;
    } completion:^(BOOL finished) {
        
    }];
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
}

- (void)dismiss
{
    [self stopDurationTimer];
    [self stop];
    [UIView animateWithDuration:kVideoPlayerControllerAnimationTimeinterval animations:^{
        self.view.alpha = 0.0;
    } completion:^(BOOL finished) {
        
        
        [self.view removeFromSuperview];
//        if (self.dimissCompleteBlock) {
//            self.dimissCompleteBlock();
//        }
    }];
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
}

#pragma mark - Private Method

- (void)configObserver
{
    //	媒体网络加载状态改变
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onMPMoviePlayerLoadStateDidChangeNotification) name:MPMoviePlayerLoadStateDidChangeNotification object:nil];
    //	播放状态改变，可配合playbakcStat
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onMPMoviePlayerPlaybackStateDidChangeNotification) name:MPMoviePlayerPlaybackStateDidChangeNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onMPMoviePlayerReadyForDisplayDidChangeNotification) name:MPMoviePlayerReadyForDisplayDidChangeNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onMPMovieDurationAvailableNotification) name:MPMovieDurationAvailableNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onMPMediaPlaybackIsPreparedToPlayDidChangeNotification) name:MPMediaPlaybackIsPreparedToPlayDidChangeNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(movieFinished:) name:MPMoviePlayerPlaybackDidFinishNotification object:nil];
    
}

- (void)movieFinished:(NSNotification *)note {
   
//    NewsChildViewController* NCVC = (NewsChildViewController*)self.ChildVC;
//    [ADBMobile mediaClose:NCVC.NewsContent.Title];
}

- (void)cancelObserver
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)configControlAction
{
    [self.videoControl.playButton addTarget:self action:@selector(playButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [self.videoControl.certerPlayButton addTarget:self action:@selector(playButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [self.videoControl.playButton1 addTarget:self action:@selector(playButtonClick) forControlEvents:UIControlEventTouchUpInside];
    
    
    
    
    [self.videoControl.certerPauseButton addTarget:self action:@selector(pauseButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [self.videoControl.pauseButton addTarget:self action:@selector(pauseButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [self.videoControl.pauseButton1 addTarget:self action:@selector(pauseButtonClick) forControlEvents:UIControlEventTouchUpInside];
    
    
    
    
    [self.videoControl.closeButton addTarget:self action:@selector(closeButtonClick) forControlEvents:UIControlEventTouchUpInside];
//    [self.videoControl.fullScreenButton addTarget:self action:@selector(fullScreenButtonClick) forControlEvents:UIControlEventTouchUpInside];
//    [self.videoControl.fullScreenButton1 addTarget:self action:@selector(fullScreenButtonClick) forControlEvents:UIControlEventTouchUpInside];
    
//    [self.videoControl.shrinkScreenButton addTarget:self action:@selector(shrinkScreenButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [self.videoControl.shrinkScreenButton1 addTarget:self action:@selector(shrinkScreenButtonClick) forControlEvents:UIControlEventTouchUpInside];
    
    
    //变化
    [self.videoControl.progressSlider addTarget:self action:@selector(progressSliderValueChanged:) forControlEvents:UIControlEventValueChanged];
    //单点触摸按下事件
    [self.videoControl.progressSlider addTarget:self action:@selector(progressSliderTouchBegan:) forControlEvents:UIControlEventTouchDown];
    //所有在控件之外触摸抬起事件(
    [self.videoControl.progressSlider addTarget:self action:@selector(progressSliderTouchEnded:) forControlEvents:UIControlEventTouchUpInside];
    //所有在控件之外触摸抬起事件(
    [self.videoControl.progressSlider addTarget:self action:@selector(progressSliderTouchEnded:) forControlEvents:UIControlEventTouchUpOutside];
    
    
    [self setProgressSliderMaxMinValues];
    [self monitorVideoPlayback];
}

- (void)onMPMoviePlayerPlaybackStateDidChangeNotification
{
//    
//    NewsInfoViewController* NIVC = (NewsInfoViewController*)self.ChildVC.parentViewController;
//    NewsChildViewController* NCVC = (NewsChildViewController*)self.ChildVC;
    
    if (self.playbackState == MPMoviePlaybackStatePlaying) {
        
//        NIVC.newsInfoListScrollView.scrollEnabled = NO;
        
        
        
        [self playButtonHidden];
        
      
        //        NSLog(@"播放");
        [self startDurationTimer];
        //        [self.videoControl.indicatorView stopAnimating];
        
        [self hiddenLoad];
        
        [self.videoControl autoFadeOutControlBar];
    } else {
        
        
        [self  pauseButtonHidden];
        [self stopDurationTimer];
        
        
    }
    
    
        switch (self.playbackState) {
    
            case MPMoviePlaybackStateStopped:
                NSLog(@"停止");
                [self.videoControl animateShow];
            
//                if (NCVC.NewsContent.Title.length>0) {
////                    [ADBMobile mediaStop:NCVC.NewsContent.Title offset:self.currentPlaybackTime];
//                }else{
////                    [ADBMobile mediaStop:@"" offset:self.currentPlaybackTime];
//                }
//                
//                NIVC.newsInfoListScrollView.scrollEnabled = YES;
//                
                break;
    
            case MPMoviePlaybackStatePlaying:
                NSLog(@"播放中");
//                if (NCVC.NewsContent.Title.length>0) {
//                 [ADBMobile mediaPlay:NCVC.NewsContent.Title offset: isnan(self.currentPlaybackTime) ? 0.0 : self.currentPlaybackTime];
//                }else{
//                 [ADBMobile mediaPlay:@"" offset: isnan(self.currentPlaybackTime) ? 0.0 : self.currentPlaybackTime];
//                }
//                NIVC.newsInfoListScrollView.scrollEnabled = NO;
            
                break;
    
            case MPMoviePlaybackStatePaused:
                NSLog(@"暫停");
//                if (NCVC.NewsContent.Title.length>0) {
//                 [ADBMobile mediaStop:NCVC.NewsContent.Title offset:self.currentPlaybackTime];
//                }else{
//                 [ADBMobile mediaStop:@"" offset:self.currentPlaybackTime];
//                }
//                NIVC.newsInfoListScrollView.scrollEnabled = YES;
    
                break;
    
            case MPMoviePlaybackStateInterrupted:
                NSLog(@"播放被中斷");
//                if (NCVC.NewsContent.Title.length>0) {
//                 [ADBMobile mediaStop:NCVC.NewsContent.Title offset:self.currentPlaybackTime];
//                }else{
//                  [ADBMobile mediaStop:@"" offset:self.currentPlaybackTime];
//                }
//               NIVC.newsInfoListScrollView.scrollEnabled = NO;
                break;
    
            case MPMoviePlaybackStateSeekingForward:
                NSLog(@"往前快轉");
//                if (NCVC.NewsContent.Title.length>0) {
//                 [ADBMobile mediaStop:NCVC.NewsContent.Title offset:self.currentPlaybackTime];
//                }else{
//                 [ADBMobile mediaStop:@"" offset:self.currentPlaybackTime];
//                }
//                NIVC.newsInfoListScrollView.scrollEnabled = NO;
                break;
    
            case MPMoviePlaybackStateSeekingBackward:
                NSLog(@"往後快轉");
//                if (NCVC.NewsContent.Title.length>0) {
//                 [ADBMobile mediaStop:NCVC.NewsContent.Title offset:self.currentPlaybackTime];
//                }else{
//                 [ADBMobile mediaStop:@"" offset:self.currentPlaybackTime];
//                }
//                NIVC.newsInfoListScrollView.scrollEnabled = NO;
                break;
    
            default:
                NSLog(@"無法辨識的狀態");
                break;
        }
    
}

-(void)hiddenLoad{
    
    self.videoControl.loadViewBg.hidden=YES;
    self.videoControl.bottomBar.hidden=NO;
    
    
    
}

-(void)hiddenbottonBar{
    
    
    self.videoControl.loadViewBg.hidden=NO;
    self.videoControl.bottomBar.hidden=YES;
    
}

- (void)onMPMoviePlayerLoadStateDidChangeNotification
{
    
    
    
    if (self.loadState & MPMovieLoadStateStalled) {
        
        [self  playButtonHidden];
        
        //        [self.videoControl.indicatorView startAnimating];
        
        [self hiddenbottonBar];
    }
    
    //    MPMovieLoadStateUnknown        = 0,
    //    MPMovieLoadStatePlayable       = 1 << 0,
    //    MPMovieLoadStatePlaythroughOK  = 1 << 1, // Playback will be automatically started in this state when shouldAutoplay is YES
    //    MPMovieLoadStateStalled
    
    //    NSLog(@"loadState-----%lu",(unsigned long)self.loadState);
    //    // 合并提取事件输入的error标识来获取错误信息
    //    if (self.loadState==MPMovieLoadStateUnknown) {
    //        [self pause];
    //        NSLog(@"合并提取事件输入的error标识来获取错误信息");
    //        //状态为可播放的情况下
    //    }else if(self.loadState==MPMovieLoadStatePlayable){
    //        [self.videoControl.indicatorView stopAnimating];
    //        NSLog(@"状态为可播放的情况下");
    //        //状态为缓冲几乎完成的情况，可以连续播放的状态
    //    }else if (self.loadState==MPMovieLoadStatePlaythroughOK){
    //        [self.videoControl.indicatorView stopAnimating];
    //        NSLog(@"状态为缓冲几乎完成的情况，可以连续播放的状态");
    //        //        if(!_timer)
    //        //        {
    //        //            _timer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(changeValue) userInfo:nil repeats:YES];
    //        //        }
    //        //        [_timer fire];
    //        //        [player play];
    //
    //        //状态为缓冲中
    //    }else if (self.loadState==MPMovieLoadStateStalled){
    //        NSLog(@"状态为缓冲中");
    //
    //                [self.videoControl.indicatorView startAnimating];
    //
    //
    //    }else {
    //
    //        NSLog(@"weizhi");
    //    }
    
    /* 事件处理模版
     MPMoviePlayerController *player = notification.object;
     MPMovieLoadState loadState = player.loadState;
     if(loadState & MPMovieLoadStateUnknown){ }
     if(loadState & MPMovieLoadStatePlayable)
     { //第一次加载，或者前后拖动完成之后 /
     }
     if(loadState & MPMovieLoadStatePlaythroughOK)
     { }
     if(loadState & MPMovieLoadStateStalled)
     { //网络不好，开始缓冲了 }
     */
}

- (void)onMPMoviePlayerReadyForDisplayDidChangeNotification
{
    
}

- (void)onMPMediaPlaybackIsPreparedToPlayDidChangeNotification
{
    
    //    [self.videoControl.indicatorView stopAnimating];
    
    //    [self.videoControl.indicatorView removeFromSuperview];
    
}
- (void)onMPMovieDurationAvailableNotification
{
    [self setProgressSliderMaxMinValues];
}

-(void)playButtonHidden{
    
    [self startAnimation];
    
    self.videoControl.pauseButton.hidden = NO;
    self.videoControl.pauseButton1.hidden = NO;
    self.videoControl.certerPauseButton.hidden=NO;
    self.videoControl.certerPlayButton.hidden=YES;
    self.videoControl.playButton.hidden = YES;
    self.videoControl.playButton1.hidden=YES;
    
}

-(void)pauseButtonHidden{
    
    [self stopAnimation];
    
    self.videoControl.playButton.hidden = NO;
    self.videoControl.certerPlayButton.hidden=NO;
    self.videoControl.playButton1.hidden=NO;
    
    self.videoControl.pauseButton.hidden = YES;
    self.videoControl.certerPauseButton.hidden=YES;
    self.videoControl.pauseButton1.hidden=YES;
    
    [self hiddenLoad];
    //    [self.videoControl.indicatorView stopAnimating];
    
}
-(void)play{

    [super play];
    
    [[NSUserDefaults standardUserDefaults]setObject:@"2" forKey:song_live_audio_UserDefaults_ControlNotification];
    
    [[NSUserDefaults standardUserDefaults]synchronize];
    

}
    
- (void)playButtonClick
{
    
    //    后台播放
    AVAudioSession *session = [AVAudioSession sharedInstance];
    [session setCategory:AVAudioSessionCategoryPlayback error:nil];
    [session setActive:YES error:nil];
    

    [[NSNotificationCenter defaultCenter] postNotificationName:@"closeMMPlayer" object:nil];
    [self play];
    
    
    
    [self playButtonHidden];
    if (self.isFrist==YES) {
    double totalTime = floor(self.duration);
//    NewsChildViewController* NCVC = (NewsChildViewController*)self.ChildVC;
//        if (NCVC.homeNewsList.Title.length>0&&NCVC.homeNewsList.CategoryId) {
//            ADBMediaSettings *mediaSettings = [ADBMobile mediaCreateSettingsWithName:NCVC.homeNewsList.Title length:totalTime playerName:@"audioPlayer" playerID:[NSString stringWithFormat:@"%ld",(long)NCVC.homeNewsList.CategoryId]];
//            
//            mediaSettings.milestones = @"25,50,75";
//            mediaSettings.segmentByMilestones = YES;
//            
//            mediaSettings.offsetMilestones = @"60,120";
//            mediaSettings.segmentByOffsetMilestones = YES;
//            
//            // seconds tracking - sends a hit every x seconds
//            mediaSettings.trackSeconds = 30; // sends a hit every 30 seconds
//            // open the video
//            [ADBMobile mediaOpenWithSettings:mediaSettings callback:nil];
//        }
    
    self.isFrist = NO;
    }
}

- (void)pauseButtonClick
{
    [self pause];
    [self pauseButtonHidden];
//    NewsInfoViewController* NIVC = (NewsInfoViewController*)self.ChildVC.parentViewController;
//    NIVC.newsInfoListScrollView.scrollEnabled = YES;
    
}

- (void)closeButtonClick
{
    [self dismiss];
}

//- (void)fullScreenButtonClick
//{
//    
//    [self stop];
//    
//    [self play];
//    
//    //    if ([self isPreparedToPlay]){
//    //
//    //        NSLog(@"刷新1");
//    //
//    //    }else{
//    //        NSLog(@"刷新2");
//    //
//    //
//    //    }
//    
//    
//    //    if (self.isFullscreenMode) {
//    //        return;
//    //    }
//    //    [self setDeviceOrientationLandscapeRight];
//    
//    
//}
- (void)shrinkScreenButtonClick
{
    
    //    [self stopAnimation];
    
    NSLog(@"刷新2");
    
    //    if (!self.isFullscreenMode) {
    //        return;
    //    }
    //
    //    [self backOrientationPortrait];
    
}

- (void)stopAnimation
{
//    [self.videoControl.animationView stopAnimating];
}


- (void)startAnimation
{
//    
//    NSMutableArray * imageArray= [NSMutableArray  arrayWithCapacity:6];
//    [imageArray addObject:[UIImage imageNamed:@"animation1.png"]];
//    [imageArray addObject:[UIImage imageNamed:@"animation2.png"]];
//    [imageArray addObject:[UIImage imageNamed:@"animation3.png"]];
//    
//    self.videoControl.animationView.animationImages = imageArray;
//    //循环次数  默认为0，无限循环
//    self.videoControl.animationView.animationRepeatCount = 0;
//    //动画执行时间
//    self.videoControl.animationView.animationDuration = 0.5;
//    //开始动画
//    [self.videoControl.animationView startAnimating];
    
}

#pragma mark -- 设备旋转监听 改变视频全屏状态显示方向 --
//监听设备旋转方向
//- (void)ListeningRotating{
//
//    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
//
//    [[NSNotificationCenter defaultCenter] addObserver:self
//                                             selector:@selector(onDeviceOrientationChange)
//                                                 name:UIDeviceOrientationDidChangeNotification
//                                               object:nil
//     ];
//
//}
//- (void)onDeviceOrientationChange{
//    UIDeviceOrientation orientation = [UIDevice currentDevice].orientation;
//    UIInterfaceOrientation interfaceOrientation = (UIInterfaceOrientation)orientation;
//    switch (interfaceOrientation) {
//            /**        case UIInterfaceOrientationUnknown:
//             NSLog(@"未知方向");
//             break;
//             */
//        case UIInterfaceOrientationPortraitUpsideDown:{
//            NSLog(@"第3个旋转方向---电池栏在下");
//            [self backOrientationPortrait];
//        }
//            break;
//        case UIInterfaceOrientationPortrait:{
//            NSLog(@"第0个旋转方向---电池栏在上");
//            [self backOrientationPortrait];
//        }
//            break;
//        case UIInterfaceOrientationLandscapeLeft:{
//            NSLog(@"第2个旋转方向---电池栏在右");
//
//            [self setDeviceOrientationLandscapeLeft];
//        }
//            break;
//        case UIInterfaceOrientationLandscapeRight:{
//
//            NSLog(@"第1个旋转方向---电池栏在左");
//
//            [self setDeviceOrientationLandscapeRight];
//
//        }
//            break;
//
//        default:
//            break;
//    }
//
//}
//返回小屏幕
- (void)backOrientationPortrait{
    if (!self.isFullscreenMode) {
        return;
    }
    [UIView animateWithDuration:0.3f animations:^{
        [self.view setTransform:CGAffineTransformIdentity];
        self.frame = self.originFrame;
        [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
    } completion:^(BOOL finished) {
        self.isFullscreenMode = NO;
//        self.videoControl.fullScreenButton.hidden = NO;
//        self.videoControl.fullScreenButton1.hidden = NO;
        
        self.videoControl.shrinkScreenButton.hidden = YES;
        self.videoControl.shrinkScreenButton1.hidden = YES;
        
//        if (self.willBackOrientationPortrait) {
//            self.willBackOrientationPortrait();
//        }
    }];
    
//    if (self.willBackOrientationPortraitAn) {
//        self.willBackOrientationPortraitAn();
//    }
    
}

//电池栏在左全屏
- (void)setDeviceOrientationLandscapeRight{
    
    //    if (self.integer==2) {
    //        self.originFrame = self.view.frame;
    //        CGFloat height = [[UIScreen mainScreen] bounds].size.width;
    //        CGFloat width = [[UIScreen mainScreen] bounds].size.height;
    //        CGRect frame = CGRectMake((height - width) / 2, (width - height) / 2, width, height);;
    //        [UIView animateWithDuration:0.3f animations:^{
    //            self.frame = frame;
    //            [self.view setTransform:CGAffineTransformMakeRotation(M_PI)];
    //        } completion:^(BOOL finished) {
    //            self.integer = 1;
    //            self.isFullscreenMode = YES;
    //            self.videoControl.fullScreenButton.hidden = YES;
    //            self.videoControl.shrinkScreenButton.hidden = NO;
    //        }];
    //    }
    if (self.isFullscreenMode) {
        return;
    }
    
    self.originFrame = self.view.frame;
    CGFloat height = [[UIScreen mainScreen] bounds].size.width;
    CGFloat width = [[UIScreen mainScreen] bounds].size.height;
    CGRect frame = CGRectMake((height - width) / 2, (width - height) / 2, width, height);;
    [UIView animateWithDuration:0.3f animations:^{
        self.frame = frame;
        [self.view setTransform:CGAffineTransformMakeRotation(M_PI_2)];
    } completion:^(BOOL finished) {
        self.isFullscreenMode = YES;
//        self.videoControl.fullScreenButton.hidden = YES;
//        self.videoControl.fullScreenButton1.hidden = YES;
        
        self.videoControl.shrinkScreenButton.hidden = NO;
        self.videoControl.shrinkScreenButton1.hidden = NO;
        
//        if (self.willChangeToFullscreenMode) {
//            self.willChangeToFullscreenMode();
//        }
    }];
    
//    if (self.willChangeToFullscreenModeAn) {
//        self.willChangeToFullscreenModeAn();
//    }
    
}
//电池栏在右全屏
- (void)setDeviceOrientationLandscapeLeft{
    
    //    if  (self.integer==1){
    //        self.originFrame = self.view.frame;
    //        CGFloat height = [[UIScreen mainScreen] bounds].size.width;
    //        CGFloat width = [[UIScreen mainScreen] bounds].size.height;
    //        CGRect frame = CGRectMake((height - width) / 2, (width - height) / 2, width, height);;
    //        [UIView animateWithDuration:0.3f animations:^{
    //            self.frame = frame;
    //            [self.view setTransform:CGAffineTransformMakeRotation(-M_PI)];
    //        } completion:^(BOOL finished) {
    //            self.integer = 2;
    //            self.isFullscreenMode = YES;
    //            self.videoControl.fullScreenButton.hidden = YES;
    //            self.videoControl.shrinkScreenButton.hidden = NO;
    //        }];
    //    }
    if (self.isFullscreenMode) {
        return;
    }
    self.originFrame = self.view.frame;
    CGFloat height = [[UIScreen mainScreen] bounds].size.width;
    CGFloat width = [[UIScreen mainScreen] bounds].size.height;
    CGRect frame = CGRectMake((height - width) / 2, (width - height) / 2, width, height);;
    [UIView animateWithDuration:0.3f animations:^{
        self.frame = frame;
        [self.view setTransform:CGAffineTransformMakeRotation(-M_PI_2)];
    } completion:^(BOOL finished) {
        self.isFullscreenMode = YES;
//        self.videoControl.fullScreenButton.hidden = YES;
//        self.videoControl.fullScreenButton1.hidden = YES;
        
        self.videoControl.shrinkScreenButton.hidden = NO;
        self.videoControl.shrinkScreenButton1.hidden = NO;
        
//        if (self.willChangeToFullscreenMode) {
//            self.willChangeToFullscreenMode();
//        }
    }];
    
//    if (self.willChangeToFullscreenModeAn) {
//        self.willChangeToFullscreenModeAn();
//    }
    
}

- (void)setProgressSliderMaxMinValues {
    CGFloat duration = self.duration;
    self.videoControl.progressSlider.minimumValue = 0.f;
    self.videoControl.progressSlider.maximumValue = duration;
}

- (void)progressSliderTouchBegan:(UISlider *)slider {
    [self pause];
    [self.videoControl cancelAutoFadeOutControlBar];
}

- (void)progressSliderTouchEnded:(UISlider *)slider {
    NSLog(@"progressSliderTouchEnded");
    
    [self setCurrentPlaybackTime:floor(slider.value)];
    [self play];
    [self.videoControl autoFadeOutControlBar];

}



- (void)progressSliderValueChanged:(UISlider *)slider {
    
    NSLog(@"progressSliderValueChanged");
    
    
    double currentTime = floor(slider.value);
    double totalTime = floor(self.duration);
    [self setTimeLabelValues:currentTime totalTime:totalTime];
    
}

- (void)monitorVideoPlayback
{
    double currentTime = floor(self.currentPlaybackTime);
    double totalTime = floor(self.duration);
    [self setTimeLabelValues:currentTime totalTime:totalTime];
    self.videoControl.progressSlider.value = ceil(currentTime);
}

- (void)setTimeLabelValues:(double)currentTime totalTime:(double)totalTime {
    double minutesElapsed = floor(currentTime / 60.0);
    double secondsElapsed = fmod(currentTime, 60.0);
    NSString *timeElapsedString = [NSString stringWithFormat:@"%02.0f:%02.0f", minutesElapsed, secondsElapsed];
    
    double minutesRemaining = floor(totalTime / 60.0);;
    double secondsRemaining = floor(fmod(totalTime, 60.0));;
    NSString *timeRmainingString = [NSString stringWithFormat:@"%02.0f:%02.0f", minutesRemaining, secondsRemaining];
    
    self.videoControl.timeLabel1.text = [NSString stringWithFormat:@"%@",timeRmainingString];
    self.videoControl.timeLabel2.text = [NSString stringWithFormat:@"%@",timeElapsedString];

}

- (void)startDurationTimer
{
    NSLog(@"startDuration");
    self.durationTimer = [NSTimer scheduledTimerWithTimeInterval:0.2 target:self selector:@selector(monitorVideoPlayback) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:self.durationTimer forMode:NSDefaultRunLoopMode];

}

- (void)stopDurationTimer
{
    [self.durationTimer invalidate];
}

- (void)fadeDismissControl
{
    [self.videoControl animateHide];
}

#pragma mark - Property

- (RadioVideoPlayerControlView *)videoControl
{
    if (!_videoControl) {
        _videoControl = [[RadioVideoPlayerControlView alloc] init];
    }
    return _videoControl;
}

- (UIView *)movieBackgroundView
{
    if (!_movieBackgroundView) {
        _movieBackgroundView = [UIView new];
        _movieBackgroundView.alpha = 0.0;
        _movieBackgroundView.backgroundColor = [UIColor whiteColor];
    }
    return _movieBackgroundView;
}

- (void)setFrame:(CGRect)frame
{
    [self.view setFrame:frame];
    [self.videoControl setFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
    [self.videoControl setNeedsLayout];
    [self.videoControl layoutIfNeeded];
}

#pragma mark - 取出视频图片
+ (UIImage*) thumbnailImageForVideo:(NSURL *)videoURL atTime:(NSTimeInterval)time
{
    AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:videoURL options:nil];
    NSParameterAssert(asset);
    AVAssetImageGenerator *assetImageGenerator = [[AVAssetImageGenerator alloc] initWithAsset:asset];
    assetImageGenerator.appliesPreferredTrackTransform = YES;
    assetImageGenerator.apertureMode = AVAssetImageGeneratorApertureModeEncodedPixels;
    
    CGImageRef thumbnailImageRef = NULL;
    CFTimeInterval thumbnailImageTime = time;
    NSError *thumbnailImageGenerationError = nil;
    thumbnailImageRef = [assetImageGenerator copyCGImageAtTime:CMTimeMake(thumbnailImageTime, 60) actualTime:NULL error:&thumbnailImageGenerationError];
    
    if (!thumbnailImageRef)
        NSLog(@"thumbnailImageGenerationError %@", thumbnailImageGenerationError);
    
    UIImage *thumbnailImage = thumbnailImageRef ? [[UIImage alloc] initWithCGImage:thumbnailImageRef] : nil;
    
    return thumbnailImage;
}


@end
