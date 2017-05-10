//
//  KrVideoPlayerController.h
//  KrVideoPlayerPlus
//
//  Created by JiaHaiyang on 15/6/19.
//  Copyright (c) 2015年 JiaHaiyang. All rights reserved.
//

#import <UIKit/UIKit.h>
//#import "NewsInfoViewController.h"
@import MediaPlayer;

@interface RadioVideoPlayerController : MPMoviePlayerController
/** video.view 消失 */
//@property (nonatomic, copy)void(^dimissCompleteBlock)(void);
//
///** 进入最小化状态 动画*/
//@property (nonatomic, copy)void(^willBackOrientationPortrait)(void);
///** 进入全屏状态 动画*/
//@property (nonatomic, copy)void(^willChangeToFullscreenMode)(void);
//
///** 进入最小化状态 */
//@property(nonatomic,copy)void(^willBackOrientationPortraitAn)(void);
//
///** 进入全屏状态 */
//@property (nonatomic, copy)void(^willChangeToFullscreenModeAn)(void);

@property (nonatomic, assign) CGRect frame;
@property (nonatomic, strong) UIViewController* ChildVC;
- (instancetype)initWithFrame:(CGRect)frame;
- (void)showInWindow;
- (void)dismiss;
-(void)play;
/**
 *  获取视频截图
 */
+ (UIImage*) thumbnailImageForVideo:(NSURL *)videoURL atTime:(NSTimeInterval)time;

-(void)setTitleLabled:(NSString *)text;
@end
