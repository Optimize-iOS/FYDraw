//
//  ViewController.m
//  FYCoreText
//
//  Created by JackJin on 2019/6/21.
//  Copyright © 2019 xuehu. All rights reserved.
//

#import "ViewController.h"
#import "FYDisplayView.h"
#import "FYEvolveDisplayView.h"

@interface ViewController ()

@property (nonatomic, strong) FYDisplayView *displayView;

@property (nonatomic, strong) FYEvolveDisplayView *evolveDisplayView;

@end

@implementation ViewController

#pragma mark - Public Methods


#pragma mark - Private Methods


#pragma mark - Life Cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initializedData];
    [self configureHierarchyView];
}


#pragma mark - Initialized Data

- (void)initializedData {
    FYFrameParserConfig *config = [[FYFrameParserConfig alloc] init];
    config.textColor = [UIColor redColor];
    config.width = self.evolveDisplayView.bounds.size.width;
    config.lineSpace = 1.0;
    config.fontSize = 13;
    
    NSString *content = @"这是对 Core Text 进行分装的实现图文混排初步控件 \n Holle World!";
    
    //Custom Attributes String
    NSDictionary *attribute = [FYFrameParser attributesWithConfig:config];
    NSMutableAttributedString *mutableAttribute = [[NSMutableAttributedString alloc] initWithString:content attributes:attribute];
    [mutableAttribute addAttribute:NSForegroundColorAttributeName value:[UIColor grayColor] range:NSMakeRange(0, content.length)];
    
    //Evolove Text
    //NSString *path = [[NSBundle mainBundle] pathForResource:@"EvolveComposeConetnt" ofType:@"json"];
    //FYCoreTextData *coreTextData = [FYFrameParser parseLocalTemplateFile:path config:config];
    //[FYFrameParser parseAttributeContent:mutableAttribute config:config];
    //[FYFrameParser parseContent:content config:config];
    
    //Evolve Image And Text
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"EvolveComposeImageContent" ofType:@"json"];
    FYCoreTextData *coreTextData = [FYFrameParser parseLocalImageTemplateFile:path config:config];
    
    self.evolveDisplayView.coreTextData = coreTextData;
}


#pragma mark - Configure Hierarchy View

- (void)configureHierarchyView {
    [self.view addSubview:self.displayView];
    
    [self.view addSubview:self.evolveDisplayView];
}


#pragma mark - Lazy Methods

- (FYDisplayView *)displayView {
    if (_displayView == nil) {
        _displayView = [[FYDisplayView alloc] init];
        _displayView.backgroundColor = [UIColor redColor];
        _displayView.frame = CGRectMake(0, 0, 150, 150);
        _displayView.center = CGPointMake(self.view.center.x, self.view.center.y - 95);;
    }
    return _displayView;
    
}

- (FYEvolveDisplayView *)evolveDisplayView {
    if(_evolveDisplayView == nil) {
        _evolveDisplayView = [[FYEvolveDisplayView alloc] init];
        _evolveDisplayView.backgroundColor = [UIColor blueColor];
        _evolveDisplayView.frame = CGRectMake(0, 0, Screen_Width, 300);
        _evolveDisplayView.center = CGPointMake(self.view.center.x, self.view.center.y + 105);
    }
    
    return _evolveDisplayView;
}


@end
