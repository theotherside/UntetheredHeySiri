//
//  main.m
//  PostRemove
//
//  Created by Hamza Sood on 28/10/2014.
//  Copyright (c) 2014 Hamza Sood. All rights reserved.
//

@import VoiceTrigger;

int main(int argc, const char * argv[]) {
    
    if (argc < 2 || strcmp(argv[1], "remove") != 0) {
        return 0;
    }
    
    @autoreleasepool {
        [[VTPreferences sharedPreferences]setVoiceTriggerEnabledWhenChargerDisconnected:NO];
        
        const char *cydia = getenv("CYDIA");
        if (cydia != NULL) {
            FILE *fout = fdopen([[@(cydia) componentsSeparatedByString:@" "][0] intValue], "w");
            fprintf(fout, "finish:reboot\n");
            fclose(fout);
        }
        
        return 0;
    }
}
