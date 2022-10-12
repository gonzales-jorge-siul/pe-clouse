//
//  SearchView.h
//  SNApp
//
//  Created by Force Close on 7/5/15.
//  Copyright (c) 2015 Force Close. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SearchView : UIView
@property(nonatomic,strong)UITableView* tableView;
@property(nonatomic,strong)UISearchBar* searchBar;
@property(nonatomic,strong)UIButton* backButton;
@end
