/*
 Copyright 2017 Aram Sargsyan
 
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 
 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.
 */

#import "SharePresentingViewController.h"
#import "ShareViewController.h"

@interface SharePresentingViewController ()

@end

@implementation SharePresentingViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    ShareViewController *shareViewController = [[ShareViewController alloc] init];
    shareViewController.shareExtensionContext = self.extensionContext;
    
    shareViewController.providesPresentationContextTransitionStyle = YES;
    shareViewController.definesPresentationContext = YES;
    shareViewController.modalPresentationStyle = UIModalPresentationOverFullScreen;
    shareViewController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    
    [self presentViewController:shareViewController animated:YES completion:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
