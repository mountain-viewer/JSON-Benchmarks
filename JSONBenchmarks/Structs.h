//
//  Structs.h
//  JSONBenchmarks
//
//  Created by Iaroslav Spirin on 1/28/19.
//  Copyright © 2019 Mountain Viewer. All rights reserved.
//

#ifndef Structs_h
#define Structs_h

#include <stdlib.h>

struct Location {
    float lat;
    int course;
    float lon;
};

struct Telematics {
    int fuelDistance;
    int fuelLevel;
};

struct Car {
    struct Location location;
    struct Telematics telematics;
    const char *modelID;
    const char *number;
    int *sf;
    int *filters;
    int *patches;
};

int* create_array(int size) {
    int* array = (int *)malloc(size * sizeof(int));
    return array;
}

void delete_array(int* array) {
    free(array);
}

#endif /* Structs_h */
