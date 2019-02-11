//
//  DropboxParserWrapper.m
//  JSONBenchmarks
//
//  Created by Iaroslav Spirin on 1/28/19.
//  Copyright © 2019 Mountain Viewer. All rights reserved.
//

#import "json11.hpp"
#import "DropboxParserWrapper.h"
#import "jsmn.h"

using namespace json11;

@implementation DropboxParserWrapper

- (id)initWith:(NSString *)jsonString {
    self = [super init];
    
    if (!self) {
        return nil;
    }
    
    self.jsonString = jsonString;
    return self;
}
    
- (struct Car*)parse {
    std::string inputString([self.jsonString cStringUsingEncoding:NSUTF8StringEncoding]);
    std::string errorString;
    
    Json result = Json::parse(inputString, errorString);
    Json::object carsJSON = result.object_items();
    std::vector<Json> cars = carsJSON["cars"].array_items();
    
    struct Car* rawCars = (struct Car*)malloc(cars.size() * sizeof(struct Car));
    
    for (int index = 0; index < cars.size(); ++index) {
        Json::object carJSON = cars[index].object_items();
        
        struct Car car;
        car.modelID = carJSON["model_id"].string_value().c_str();
        car.number = carJSON["number"].string_value().c_str();
        
        std::vector<Json> filters = carJSON["filters"].array_items();
        car.filters = create_array((int)filters.size());
        for (int jndex = 0; jndex < filters.size(); ++jndex) {
            car.filters[jndex] = filters[jndex].int_value();
        }
        
        std::vector<Json> sf = carJSON["sf"].array_items();
        car.sf = create_array((int)sf.size());
        for (int jndex = 0; jndex < sf.size(); ++jndex) {
            car.sf[jndex] = sf[jndex].int_value();
        }
        
        std::vector<Json> patches = carJSON["patches"].array_items();
        car.patches = create_array((int)patches.size());
        for (int jndex = 0; jndex < patches.size(); ++jndex) {
            car.patches[jndex] = patches[jndex].int_value();
        }
        
        Json::object location = carJSON["location"].object_items();
        car.location.lat = location["lat"].number_value();
        car.location.lon = location["lon"].number_value();
        car.location.course = location["course"].int_value();
        
        Json::object telematics = carJSON["telematics"].object_items();
        car.telematics.fuelLevel = location["fuelLevel"].int_value();
        car.telematics.fuelDistance = location["fuelDistance"].int_value();
        
        rawCars[index] = car;
    }
    
    return rawCars;
}
    
@end

static int jsoneq(const char *json, jsmntok_t *tok, const char *s) {
    if (tok->type == JSMN_STRING && (int) strlen(s) == tok->end - tok->start &&
        strncmp(json + tok->start, s, tok->end - tok->start) == 0) {
        return 0;
    }
    return -1;
}

static int parse_int(const char *json, jsmntok_t *token) {
    int len = token->end - token->start;
    char number[len];
    memcpy(number, &json[token->start], len);
    number[len] = '\0';
    
    int value = strtol(number, NULL, 10);
    return value;
}

static double parse_double(const char *json, jsmntok_t *token) {
    int len = token->end - token->start;
    char number[len];
    memcpy(number, &json[token->start], len);
    number[len] = '\0';
    
    double value = strtod(number, NULL);
    return value;
}

@implementation JSMNParser

static jsmntok_t tokens[100000];

- (id)initWith:(NSString *)jsonString {
    self = [super init];
    
    if (!self) {
        return nil;
    }
    
    self.jsonString = jsonString;
    return self;
}

- (struct Car*)parseJSON {
    jsmn_parser parser;
    
    const char *JSON_STRING = [self.jsonString cStringUsingEncoding:NSUTF8StringEncoding];
    
    jsmn_init(&parser);
    int num_tokens = jsmn_parse(&parser, JSON_STRING, strlen(JSON_STRING), tokens, 100000);
    
    jsmntok_t *car_array = &tokens[2];
    struct Car *cars = (struct Car *)malloc(car_array->size * sizeof(Car));
    
    /* Loop over all keys of the root object */
    for (int i = 3, car_index = 0; i < num_tokens; ++i, ++car_index) {
        jsmntok_t *car_object = &tokens[i];
        Car car;
        
        /* Loop over all keys tokens in a car object */
        int j = 0;
        for (int item_id = 0; item_id < car_object->size; ++item_id, ++j) {
            jsmntok_t *field = &tokens[i + j + 1];
            
            if (jsoneq(JSON_STRING, field, "number") == 0) {
                jsmntok_t *number_token = &tokens[i + j + 2];
                
                int len = number_token->end - number_token->start;
                char* number = (char*)malloc((len + 1) * sizeof(char));
                memcpy(number, &JSON_STRING[number_token->start], len);
                number[len] = '\0';
                
                car.number = number;
                ++j;
            } else if (jsoneq(JSON_STRING, field, "location") == 0) {
                jsmntok_t *location_token = &tokens[i + j + 2];
                
                for (int k = 0; k < 2 * location_token->size; ++k) {
                    jsmntok_t *location_detail_token = &tokens[i + j + k + 3];
                    
                    if (jsoneq(JSON_STRING, location_detail_token, "lat") == 0) {
                        car.location.lat = parse_double(JSON_STRING, &tokens[i + j + k + 4]);
                        ++k;
                    } else if (jsoneq(JSON_STRING, location_detail_token, "course") == 0) {
                        car.location.course = parse_int(JSON_STRING, &tokens[i + j + k + 4]);
                        ++k;
                    } else if (jsoneq(JSON_STRING, location_detail_token, "lon") == 0) {
                        car.location.lon = parse_double(JSON_STRING, &tokens[i + j + k + 4]);
                        ++k;
                    }
                }
                
                j += 2 * location_token->size + 1;
            } else if (jsoneq(JSON_STRING, field, "filters") == 0) {
                jsmntok_t *filters_token = &tokens[i + j + 2];
        
                int* filters = (int*)malloc(filters_token->size * sizeof(int));
                
                for (int k = 0; k < filters_token->size; ++k) {
                    filters[k] = parse_int(JSON_STRING, &tokens[i + j + k + 3]);
                }
                
                car.filters = filters;
                
                j += filters_token->size + 1;
            } else if (jsoneq(JSON_STRING, field, "sf") == 0) {
                jsmntok_t *sf_token = &tokens[i + j + 2];
                
                int* sf = (int*)malloc(sf_token->size * sizeof(int));
                
                for (int k = 0; k < sf_token->size; ++k) {
                    sf[k] = parse_int(JSON_STRING, &tokens[i + j + k + 3]);
                }
                
                car.sf = sf;
                
                j += sf_token->size + 1;
            } else if (jsoneq(JSON_STRING, field, "model_id") == 0) {
                jsmntok_t *model_id_token = &tokens[i + j + 2];
                
                int len = model_id_token->end - model_id_token->start;
                char* model_id = (char*)malloc((len + 1) * sizeof(char));
                memcpy(model_id, &JSON_STRING[model_id_token->start], len);
                model_id[len] = '\0';
                
                car.modelID = model_id;
                ++j;
            } else if (jsoneq(JSON_STRING, field, "telematics") == 0) {
                jsmntok_t *telematics_token = &tokens[i + j + 2];
                
                for (int k = 0; k < 2 * telematics_token->size; ++k) {
                    jsmntok_t *telematics_detail_token = &tokens[i + j + k + 3];
                    
                    if (jsoneq(JSON_STRING, telematics_detail_token, "fuel_distance") == 0) {
                        car.telematics.fuelDistance = parse_int(JSON_STRING, &tokens[i + j + k + 4]);
                        ++k;
                    } else if (jsoneq(JSON_STRING, telematics_detail_token, "fuel_level") == 0) {
                        car.telematics.fuelLevel = parse_int(JSON_STRING, &tokens[i + j + k + 4]);
                        ++k;
                    }
                }
                
                j += 2 * telematics_token->size + 1;
            } else if (jsoneq(JSON_STRING, field, "patches") == 0) {
                jsmntok_t *patches_token = &tokens[i + j + 2];
                
                int* patches = (int*)malloc(patches_token->size * sizeof(int));
                
                for (int k = 0; k < patches_token->size; ++k) {
                    patches[k] = parse_int(JSON_STRING, &tokens[i + j + k + 3]);
                }
                
                car.patches = patches;
                
                j += patches_token->size + 1;
            }
        }
        
        i += j;
        cars[car_index] = car;
    }
    
    return cars;
}

@end
