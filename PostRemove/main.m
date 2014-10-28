//
//  main.m
//  PostRemove
//
//  Created by Hamza Sood on 28/10/2014.
//  Copyright (c) 2014 Hamza Sood. All rights reserved.
//

@import Foundation;

int main(int argc, const char * argv[]) {
    
    if (argc < 2 || strcmp(argv[1], "remove") != 0) {
        return 0;
    }
    
    CFPreferencesSetValue(CFSTR("Battery Power Allowed"), kCFBooleanFalse, CFSTR("com.apple.voicetrigger"), CFSTR("mobile"), kCFPreferencesCurrentHost);
    CFPreferencesSynchronize(CFSTR("com.apple.voicetrigger"), CFSTR("mobile"), kCFPreferencesCurrentHost);
    
    const char *cydia = getenv("CYDIA");
    if (cydia != NULL) {
        @autoreleasepool {
            FILE *fout = fdopen([[@(cydia) componentsSeparatedByString:@" "][0] intValue], "w");
            fprintf(fout, "finish:reboot\n");
            fclose(fout);
        }
    }
    
    return 0;
}
