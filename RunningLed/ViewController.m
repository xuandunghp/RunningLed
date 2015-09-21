//
//  ViewController.m
//  RunningLed
//
//  Created by Dzung Tran on 9/20/15.
//  Copyright © 2015 Dzung. All rights reserved.
//

#import "ViewController.h"

#define MIN_TAG_NUMBER 100

typedef enum _Directions {
    LEFT_DIRECTION = 1,
    UP_DIRECTION = 2,
    RIGHT_DIRECTION = 3,
    DOWN_DIRECTION = 4
} Directions;

@interface ViewController ()

@end

@implementation ViewController
{
    CGFloat _margin;
    CGFloat _ballDiameter;
    CGFloat _screenWidth;
    CGFloat _screenHeight;
    int _numberOfBallsPerRow;
    int _numberOfBallsPerColumn;
    CGFloat _distanceBetweenTwoLeds;
    int _tagNumber;
    NSTimer* _timer;
    
    int _activeLedX;
    int _activeLedY;
    int _direction;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    _margin = 40.0;
    _ballDiameter = 24.0;
    _screenWidth = self.view.bounds.size.width;
    _screenHeight = self.view.bounds.size.height;
    _numberOfBallsPerRow = 8;
    _distanceBetweenTwoLeds = (_screenWidth - _margin * 2) / (_numberOfBallsPerRow - 1);
    _numberOfBallsPerColumn = ((_screenHeight - _margin * 2) / _distanceBetweenTwoLeds) + 1;
    _tagNumber = MIN_TAG_NUMBER;

    [self drawGridOfBalls];
    [self startHorizontalZigZagRunningLed];
}

- (void)drawGridOfBalls {
    for (int i = 0; i < _numberOfBallsPerColumn; i++) {
        [self drawRowOfBalls: _numberOfBallsPerRow
                    distance: _distanceBetweenTwoLeds
                         AtY: _margin + i * _distanceBetweenTwoLeds];
    }
}

- (void)drawRowOfBalls: (int) numberOfBalls
              distance: (CGFloat) distance
                   AtY: (CGFloat) y
{
    for (int i = 0; i < numberOfBalls; i++) {
        [self placeGreyBallAtX: _margin + i * distance andY: y];
    }
}

- (void) placeGreyBallAtX: (CGFloat)x
                    andY: (CGFloat)y
{
    UIImageView* ball = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"grey"]];
    ball.center = CGPointMake(x, y);
    ball.tag = _tagNumber++;
    [self.view addSubview:ball];
}

- (void) startHorizontalZigZagRunningLed {
    [self initHorizontalZigZagRunningLed];
    
    _timer = [NSTimer scheduledTimerWithTimeInterval:0.2 target:self selector:@selector(moveHorizontalZigZag) userInfo:nil repeats:true];
}

- (void) initHorizontalZigZagRunningLed {
    _activeLedX = 0;
    _activeLedY = 0;
    _direction = RIGHT_DIRECTION;
    [self turnONLedAtX:_activeLedX AndY:_activeLedY];
}

- (void) moveHorizontalZigZag {
    switch (_direction) {
        case LEFT_DIRECTION:
            if (![self moveLeft]) {
                [self moveDown];
                _direction = RIGHT_DIRECTION;
            }
            break;
            
        case RIGHT_DIRECTION:
            if (![self moveRight]) {
                if ([self moveDown]) {
                    _direction = LEFT_DIRECTION;
                }
                else {
                    [self turnOFFLedAtX:_activeLedX AndY:_activeLedY];
                    [self initHorizontalZigZagRunningLed];
                }
            }
            break;
            
        default:
            break;
    }
}

- (bool) moveRight {
    if (_activeLedX > _numberOfBallsPerRow - 2) return false;
    
    [self turnOFFLedAtX: _activeLedX AndY: _activeLedY];
    _activeLedX += 1;
    [self turnONLedAtX: _activeLedX AndY: _activeLedY];
    
    return true;
}

- (bool) moveLeft {
    if (_activeLedX < 1) return false;

    [self turnOFFLedAtX: _activeLedX AndY: _activeLedY];
    _activeLedX -= 1;
    [self turnONLedAtX: _activeLedX AndY: _activeLedY];
    
    return true;
}

- (bool) moveUp {
    if (_activeLedY < 1) return false;
    
    [self turnOFFLedAtX: _activeLedX AndY: _activeLedY];
    _activeLedY -= 1;
    [self turnONLedAtX: _activeLedX AndY: _activeLedY];
    
    return true;
}

- (bool) moveDown {
    if (_activeLedY > _numberOfBallsPerColumn - 2) return false;
    
    [self turnOFFLedAtX: _activeLedX AndY: _activeLedY];
    _activeLedY += 1;
    [self turnONLedAtX: _activeLedX AndY: _activeLedY];
    
    return true;
}


- (void) turnONLedAtX: (int)x AndY: (int)y {
    [self setImageOfLedAtX:x AndY:y toImage:@"green"];
}

- (void) turnOFFLedAtX: (int)x AndY: (int)y {
    [self setImageOfLedAtX:x AndY:y toImage:@"grey"];
}

- (void) setImageOfLedAtX: (int)x AndY: (int)y toImage: (NSString*)img {
    int tag = [self getTagOfLedAtX:x AndY:y];
    UIView* view = [self.view viewWithTag: tag];
    if (view && [view isMemberOfClass: [UIImageView class]]) {
        UIImageView* ball = (UIImageView*) view;
        ball.image = [UIImage imageNamed:img];
    }
}

- (int) getTagOfLedAtX: (int)x AndY: (int)y {
    return x + y * _numberOfBallsPerRow + MIN_TAG_NUMBER;
}

@end
