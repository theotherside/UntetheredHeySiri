//
//  AssistantController.h
//  UntetheredHeySiri
//
//  Created by Hamza Sood on 28/10/2014.
//  Copyright (c) 2014 Hamza Sood. All rights reserved.
//

@interface PSListController (AssistantControllerMethods)
- (NSNumber *)voiceTrigger:(PSSpecifier *)sender;
- (void)setVoiceTrigger:(NSNumber *)voiceTrigger forSpecifier:(PSSpecifier *)specifier;
@end