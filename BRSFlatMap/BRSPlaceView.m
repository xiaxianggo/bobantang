//
//  BBTPlaceView.m
//  bobantang
//
//  Created by Xia Xiang on 9/7/14.
//  Copyright (c) 2014 Xia Xiang. All rights reserved.
//

#import "BRSPlaceView.h"

@interface BRSPlaceView() <UIGestureRecognizerDelegate>
@property (nonatomic) CGFloat dismissY;
@property (nonatomic) CGFloat smallModeY;
@property (nonatomic) CGFloat bigModeY;
@property (nonatomic) BOOL isBigMode;
@property (nonatomic) BOOL allowBigMode;

@end

@implementation BRSPlaceView

- (id)init
{
    NSArray *views = [[NSBundle mainBundle] loadNibNamed:@"BRSPlaceView" owner:nil options:nil];
    id mainView = [views firstObject];
    return mainView;
}

- (void)awakeFromNib
{
    [self setupGestures];
   
}

- (void)setupGestures
{
    CGRect appFrame = [[UIScreen mainScreen] applicationFrame];
    CGFloat smallModeHeight = 30.0f;
    CGFloat bigModeHeight = 233.0f;
    self.dismissY = appFrame.size.height - 23.0f;
    self.smallModeY = appFrame.size.height - smallModeHeight;
    self.bigModeY = appFrame.size.height - bigModeHeight + 10.0f;
    self.allowBigMode = YES;
    
    UIPanGestureRecognizer *panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self
                                                                                           action:@selector(handlePanGesture:)];
    panGestureRecognizer.delegate = self;
    [self.header addGestureRecognizer:panGestureRecognizer];
    
    UISwipeGestureRecognizer *swipeGestureRecognizerUp = [[UISwipeGestureRecognizer alloc] initWithTarget:self
                                                                                                   action:@selector(handleSwipe:)];
    swipeGestureRecognizerUp.direction = UISwipeGestureRecognizerDirectionUp;
    swipeGestureRecognizerUp.delegate = self;
    [swipeGestureRecognizerUp requireGestureRecognizerToFail:panGestureRecognizer];
    [self.header addGestureRecognizer:swipeGestureRecognizerUp];
    
    UISwipeGestureRecognizer *swipeGestureRecognizerDown = [[UISwipeGestureRecognizer alloc] initWithTarget:self
                                                                                                     action:@selector(handleSwipe:)];
    swipeGestureRecognizerDown.direction = UISwipeGestureRecognizerDirectionDown;
    swipeGestureRecognizerDown.delegate = self;
    [swipeGestureRecognizerDown requireGestureRecognizerToFail:panGestureRecognizer];
    [self.header addGestureRecognizer:swipeGestureRecognizerDown];
}

//TODO: dirty code
- (void)handlePanGesture:(UIPanGestureRecognizer *)recognizer
{
    CGFloat currentY = self.frame.origin.y;
    if (recognizer.state == UIGestureRecognizerStateChanged) {
        CGPoint translation = [recognizer translationInView:self];
        if (translation.y <= 0.0f) { //pan up
            if (currentY < self.bigModeY || !self.allowBigMode) {
                return;
            }
        }
        
        CGFloat targetY = self.center.y + translation.y;
        self.center = CGPointMake(self.center.x, targetY);
        [recognizer setTranslation:CGPointMake(0, 0) inView:self];
        
    } else if (recognizer.state == UIGestureRecognizerStateEnded) {
        if (currentY > self.dismissY) {
            [self.delegate needDisapperaWithPlaceView:self];
            return;
        }
        if (self.isBigMode) {
            if (currentY > self.bigModeY + 30.0f) {
                [self changeToSmallMode];
            } else {
                [self changeToBigMode];
            }
        } else {
            if (currentY < self.smallModeY - 20.0f) {
                [self changeToBigMode];
            } else {
                [self changeToSmallMode];
            }
        }
    }
}

- (void)handleSwipe:(UISwipeGestureRecognizer *)recognizer
{
    //springNSLog(@"swipe%@",recognizer);
    if (recognizer.state == UIGestureRecognizerStateEnded) {
        if (recognizer.direction == UISwipeGestureRecognizerDirectionDown) {
            NSLog(@"swipe down");
            if (self.isBigMode) {
                [self changeToSmallMode];
            } else {
                [self.delegate needDisapperaWithPlaceView:self];
            }
        } else if (recognizer.direction == UISwipeGestureRecognizerDirectionUp) {
            [self changeToBigMode];
            NSLog(@"swipe up");
        }
    }
}

- (void)performSpringAnimation
{
    CGFloat targetY = self.isBigMode ? self.bigModeY : self.smallModeY;
    CGFloat delta = fabsf(self.frame.origin.y - targetY);
    CGFloat factor = delta / self.frame.size.height;
    CGFloat duration = 0.8f * factor;
    CGFloat velocity = 0.5f * factor;
    
    [UIView animateWithDuration:duration
                          delay:0.0f
         usingSpringWithDamping:0.7f
          initialSpringVelocity:velocity
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^() {
                         CGRect frame = self.frame;
                         frame.origin.y = targetY;
                         self.frame = frame;
                         
                     }
                     completion:^(BOOL finised) {
                         if (self.isBigMode) {
                             [self.delegate didEnterBigModeWithPlaceView:self];
                             self.dragIndicator.image = [UIImage imageNamed:@"dragIndocatorDown"];
                         } else {
                             [self.delegate didEnterSmallModeWithPlaceView:self];
                             self.dragIndicator.image = [UIImage imageNamed:@"dragIndocatorUp"];
                         }
                     }];
}

- (void)changeToSmallMode
{
    self.isBigMode = NO;
    [self performSpringAnimation];
    NSLog(@"to small");
    
}

- (void)changeToBigMode
{
    if (self.allowBigMode) {
        self.isBigMode = YES;
        [self performSpringAnimation];
        NSLog(@"to big");
    }
}

- (void)disableBigMode
{
    if (self.isBigMode) {
        [self changeToSmallMode];
    }
    self.allowBigMode = NO;
    self.dragIndicator.hidden = YES;
}

- (void)enableBigMode
{
    self.allowBigMode = YES;
    self.dragIndicator.hidden = NO;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return YES;
}


@end
