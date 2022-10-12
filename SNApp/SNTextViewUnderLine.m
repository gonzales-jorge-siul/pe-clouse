//
//  SNTextViewUnderLine.m
//  SNApp
//
//  Created by JG on 7/17/15.
//  Copyright (c) 2015 JG. All rights reserved.
//

#import "SNTextViewUnderLine.h"
#import "UIColor+SNColors.h"

@interface SNTextViewUnderLine ()<UITextViewDelegate>

@property(nonatomic,strong)UITextView* textView;
@property(nonatomic,strong)UILabel* placeholderView;
@property(nonatomic,strong)UILabel* counterView;
@property(nonatomic,strong)UIView* bottomLineView;

@property(nonatomic,strong)NSNumber* numberOfLines;
@end

@implementation SNTextViewUnderLine
#pragma mark - Life cycle

-(instancetype)initWithFrame:(CGRect)frame{
    self= [super initWithFrame:frame];
    if (self) {
        _placeholder = @"";
        _maximumLetters =@100;
        _font = [UIFont systemFontOfSize:16.0];
        _numberOfLines = @1;
        
        _textView = [[UITextView alloc] initWithFrame:CGRectMake(LEFT_MARGIN_CC, UPPER_MARGIN_CC, frame.size.width, _font.lineHeight)];
        _textView.clipsToBounds = YES;
        _textView.delegate = self;
        _textView.font = _font;
        _textView.textColor = [UIColor blackColor];
        _textView.tintColor = [UIColor appMainColor];
        _textView.alwaysBounceVertical = NO;
        _textView.bounces = NO;
        
        [self addSubview:_textView];
        
        _placeholderView = [[UILabel alloc] initWithFrame:CGRectZero];
        _placeholderView.numberOfLines = 1;
        _placeholderView.textColor = [UIColor grayColor];
        _placeholderView.font = _font;
        _placeholderView.textAlignment = NSTextAlignmentLeft;
        [self addSubview:_placeholderView];
        
        _counterView = [[UILabel alloc] initWithFrame:CGRectZero];
        _counterView.text = [NSString stringWithFormat:@"0/%@",_maximumLetters];
        _counterView.textAlignment = NSTextAlignmentRight;
        _counterView.font = [UIFont systemFontOfSize:12.0];
        _counterView.textColor = [UIColor grayColor];
        _counterView.numberOfLines = 1;
        [self addSubview:_counterView];
        
        _bottomLineView = [[UILabel alloc] initWithFrame:CGRectZero];
        _bottomLineView.backgroundColor = [UIColor appMainColor];
        [self addSubview:_bottomLineView];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textChanged:) name:UITextViewTextDidChangeNotification object:nil];
    }
    return self;
}


-(void)layoutSubviews{
    [super layoutSubviews];
    
    self.textView.frame =[self _textViewFrame];
    CGPoint bottomOffset = CGPointMake(0, self.textView.contentSize.height - self.textView.bounds.size.height);
    [self.textView setContentOffset:bottomOffset animated:YES];
    self.frame = [self _selfFrame];
    //NSLog(@"self frame : %f",self.bounds.size.height);
    self.placeholderView.frame = [self _placeholderViewFrame];
    self.bottomLineView.frame = [self _bottomLineViewFrame];
    self.counterView.frame = [self _counterViewFrame];
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Constants

//Bottom line
CGFloat const HEIGHT_BOTTOM_LINE_CC = 1.0;
//CGFloat const UPPER_MARGIN_BOTTOM_LINE_CC = 4.0;

//Margin
CGFloat const LEFT_MARGIN_CC= 0.0;
CGFloat const UPPER_MARGIN_CC = 0.0;

#pragma mark - Helpers layout

-(CGRect)_selfFrame{
    CGFloat height = self.textView.bounds.size.height + self.counterView.font.lineHeight + HEIGHT_BOTTOM_LINE_CC + UPPER_MARGIN_CC;
    return CGRectMake(self.frame.origin.x, self.frame.origin.y, self.bounds.size.width, height>30?height:30);
}

-(CGRect)_textViewFrame{
    return CGRectMake(LEFT_MARGIN_CC, UPPER_MARGIN_CC, self.bounds.size.width -2*LEFT_MARGIN_CC, [self.textView contentSize].height);
}

-(CGSize)_textSize{
    
    CGSize textSize = [self.textView contentSize];
    CGFloat maxHeight = self.bounds.size.height - self.counterView.font.lineHeight - HEIGHT_BOTTOM_LINE_CC ;
    
    if ([self.text isEqualToString:@""]) {
        textSize.height = self.textView.font.lineHeight+17;
    }
    textSize.height = MIN(textSize.height , maxHeight);
    return textSize;
}

-(CGRect)_placeholderViewFrame{
    return CGRectMake(LEFT_MARGIN_CC+8.5, UPPER_MARGIN_CC+8.5, self.bounds.size.width - 2*LEFT_MARGIN_CC, self.placeholderView.font.lineHeight);
}

-(CGRect)_bottomLineViewFrame{
    return CGRectMake(LEFT_MARGIN_CC,[self.textView contentSize].height - 4 , self.bounds.size.width -2*LEFT_MARGIN_CC, HEIGHT_BOTTOM_LINE_CC);
}

-(CGRect)_counterViewFrame{
    return CGRectMake(LEFT_MARGIN_CC, [self.textView contentSize].height + HEIGHT_BOTTOM_LINE_CC, self.bounds.size.width - 2*LEFT_MARGIN_CC , self.counterView.font.lineHeight);
}
-(NSInteger)_textNumberOfLines{
    CGSize textSize = [self.textView contentSize];
    
    CGFloat numberOfLines = textSize.height/[self.textView.font lineHeight];
    
    int redondeo = (int)(numberOfLines);
    
    if (numberOfLines>=(int)(numberOfLines) + 0.5) {
        redondeo++;
    }
    
    return redondeo;
}

#pragma mark - Text view delegate

-(void)textViewDidChange:(UITextView *)textView{
    [self textChanged:nil];
}

#pragma mark - Actions

- (void)textChanged:(NSNotification *)notification
{
    if([[self placeholder] length] == 0)
    {
        return;
    }
    
    if([[self text] length] == 0)    {
        [[self placeholderView] setAlpha:1];
    }else{
        if([[self text] length]== 1 || [[self text] length] == 2){
            [self deleteBlankSpaces];
        }
        [[self placeholderView] setAlpha:0];
        if ([[self text] length]>=[self.maximumLetters integerValue]) {
            self.textView.text =[[self.textView text] substringToIndex:[self.maximumLetters integerValue]];
        }
    }
    
    int newNumberOflines = (int)[self _textNumberOfLines];
    if (newNumberOflines!=[self.numberOfLines intValue]) {
        self.numberOfLines =@(newNumberOflines);
        self.textView.frame =[self _textViewFrame]; 
        [self setFrame:[self _selfFrame]];
        [self setNeedsLayout];
        [self.superview.superview setNeedsLayout];
    }
    
    self.counterView.text = [NSString  stringWithFormat:@"%lu/%@",(unsigned long)[self.text length],[self  maximumLetters]];
}

-(BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    NSRange rangeOfString = [text rangeOfString:@"\n"];
    if (rangeOfString.length > 0) {
        NSString* newText =[text stringByReplacingOccurrencesOfString:@"\n" withString:@" "];
        self.textView.text = [NSString stringWithFormat:@"%@ %@", self.text, newText];
        [self textChanged:nil];
        return NO;
    }
    return YES;
}
#pragma mark - Custom accessors

-(NSString *)text{
    return self.textView.text;
}

-(void)setPlaceholder:(NSString *)placeholder{
    _placeholder = placeholder;
    
    self.placeholderView.text = [self placeholder];
}

-(void)setMaximumLetters:(NSNumber *)maximumLetters{
    _maximumLetters = maximumLetters;
    
    self.counterView.text = [NSString  stringWithFormat:@"%lu/%@",(unsigned long)[self.text length],[self  maximumLetters]];
}

-(void)setFont:(UIFont *)font{
    _font = font;
    
    self.textView.font = [self font];
    self.placeholderView.font = [self font];
    [self setNeedsLayout];
}

#pragma mark - Override

-(BOOL)resignFirstResponder{
    if(self.textView.isFirstResponder){
        [self.textView resignFirstResponder];
    }
    return [super resignFirstResponder];
}

#pragma mark - Helpers

-(void)deleteBlankSpaces{
    NSString *rawString = [self text];
    NSCharacterSet *whitespace = [NSCharacterSet whitespaceAndNewlineCharacterSet];
    NSString *trimmed = [rawString stringByTrimmingCharactersInSet:whitespace];
    if ([trimmed length]==0) {
        self.textView.text = @"";
    }
}

@end
