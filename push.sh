#!/bin/bash
APPUUID=fddb5fd2-85af-45a6-b828-9efaa66f019c
APPKEY=25eb569a-750a-4c3f-9e7b-75be9097dd2b
DEVICEID=c6ad081d-751b-4427-8ed4-aecd26c456e9
#RESPONSE_DATA_JSON=response_data_delete_all.json
RESPONSE_DATA_JSON=response_data_complex.json
#RESPONSE_DATA_JSON=response_data_one_item.json


UPDATE_JSON=`jq '.|tostring' < ${RESPONSE_DATA_JSON}`

http -v -a ${APPUUID}:${APPKEY} http://them-pirates.cfapps.io/v1/push <<HTTPBODY
  {"message":
    {"body":"hello rob and anisha!",
      "custom":
        {"ios":
          {"content-available":true,
           "extra":{
             "pivotal.push.geofence_update_available":true,
             "pivotal.push.geofence_update_json":${UPDATE_JSON}
           }
          }
        }
    },
    "target":{"devices":["${DEVICEID}"]}
  }
HTTPBODY
