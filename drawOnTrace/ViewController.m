//
//  ViewController.m
//  drawOnTrace
//
//  Created by Michael Roebuck on 9/7/16.
//  Copyright © 2016 Michael Roebuck. All rights reserved.
//

#import "ViewController.h"
#import "UIImage+TextDrawing.h"
#import "UIView+Extras.h"

@interface ViewController () <UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextField *textField;

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (nonatomic, copy) NSString * text;
@property (strong, nonatomic) UIFont * font;
@property (strong, nonatomic) NSMutableArray * mutableArray;
@property (weak, nonatomic) IBOutlet UIView *layerView;

@end

@implementation ViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    self.mutableArray = @[].mutableCopy;
    
    self.text = self.textField.text;
    
    self.font = [UIFont fontWithName:@"Helvetica"  size:32];
}

- (void) touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    
    self.mutableArray = @[].mutableCopy;
    
}

- (void) touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    
    UITouch *touch = [[event allTouches] anyObject];
    CGPoint pt = [touch locationInView:self.view];

    if(CGRectContainsPoint(self.imageView.frame, pt)) {
        CGPoint converted = [self.view convertPoint:pt toView:self.imageView];
        [self.mutableArray addObject:[NSValue valueWithCGPoint:converted]];
        
        NSLog(@"%s: new pt=(%3.2f, %3.2f) converted=(%3.2f, %3.2f)", __PRETTY_FUNCTION__, pt.x, pt.y,
              converted.x, converted.y);
    }
}

- (void) touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    
}

- (void) touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    
    [self drawText:self.text];
}

#pragma mark - UITextFieldDelegate Protocol

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

#pragma mark - Event Actions

- (IBAction)onTextChanged:(id)sender {
    
    UITextField * textField = sender;
    self.text = textField.text;
    [self drawText:self.text];
}

- (void) drawText:(NSString *)text {
    
    NSMutableArray * pointsToUse = @[].mutableCopy;
    
    if(self.text.length < self.mutableArray.count) {
        
        NSString * textWithPadding = [NSString stringWithFormat:@" %@ ", text];
        
        for(NSInteger i = 0; i < textWithPadding.length; i++) {
            CGFloat percent = ((CGFloat)i/(CGFloat)textWithPadding.length);
            NSInteger index = (NSInteger)(percent * (CGFloat)self.mutableArray.count);
            [pointsToUse addObject:self.mutableArray[index]];
            
            NSValue * nextValue = self.mutableArray[index];
            CGPoint pt = [nextValue CGPointValue];
            NSLog(@"%s: total=[%ld] percent=[%3.2f] index=[%ld] pt=(%3.2f, %3.2f)", __PRETTY_FUNCTION__, self.mutableArray.count, percent, index, pt.x, pt.y);
        }
        
        [self.layerView.layer removeAllAnimations];
        
        while(self.layerView.layer.sublayers.count > 0) {
            CALayer * layer = self.layerView.layer.sublayers.lastObject;
            [layer removeFromSuperlayer];
        }
        
        [self.layerView layerTextOnLine:textWithPadding
                             size:self.imageView.frame.size
                             font:self.font
                                degrees:0
                             textPoints:pointsToUse
                             bezierPoints:self.mutableArray];

//        [self.layerView layerText:textWithPadding
//                             size:self.imageView.frame.size
//                             font:self.font
//                          degrees:0
//                           points:mutableArray];

//        [self drawTextOnCurve:self.text
//                         size:self.imageView.frame.size
//                         font:self.font
//                      degrees:0
//                       points:mutableArray.copy];
    }
}

- (void) drawTextOnCurve:(NSString *)str
                         size:(CGSize)size
                         font:(UIFont *)font
                      degrees:(CGFloat)degrees
                       points:(NSArray *)points {
    
    UIImage * image = [UIImage drawTextOnCurve:str
                                          size:size
                                          font:font
                                       degrees:degrees
                                        points:points];
    
    self.imageView.image = image;
    self.imageView.contentMode = UIViewContentModeScaleAspectFit;
}

@end
