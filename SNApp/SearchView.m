//
//  SearchView.m
//  SNApp
//
//  Created by JG on 7/5/15.
//  Copyright (c) 2015 JG. All rights reserved.
//

#import "SearchView.h"

@interface SearchView ()
@end

@implementation SearchView

-(instancetype)initWithFrame:(CGRect)frame{
    if (self=[super initWithFrame:frame]) {
        //Table view
        _tableView = [[UITableView alloc]initWithFrame:CGRectZero];
        _tableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
        [self addSubview:_tableView];
        
        //Background table view
        UILabel* backgroundView = [[UILabel alloc] initWithFrame:CGRectMake(0, 4, frame.size.width, [UIFont systemFontOfSize:16].lineHeight)];
        backgroundView.numberOfLines = 1;
        backgroundView.text = NSLocalizedString(@"search.search-bar.Does not found match", nil);
        backgroundView.textAlignment = NSTextAlignmentCenter;
        backgroundView.textColor = [UIColor blackColor];
        backgroundView.font = [UIFont systemFontOfSize:16];
        
        UIView* view = [[UIView alloc] initWithFrame:_tableView.bounds];
        [view addSubview:backgroundView];
        _tableView.backgroundView = view;
        _tableView.backgroundView.alpha = 0;
    }
    return self;
}
-(void)layoutSubviews{
    [super layoutSubviews];
    [self.tableView setFrame:[self _tableViewFrame]];
    [self.tableView.backgroundView setFrame:CGRectMake(0, 4, self.tableView.bounds.size.width, [UIFont systemFontOfSize:16].lineHeight)];
}
-(CGRect)_tableViewFrame{
    return CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height);
}
@end
