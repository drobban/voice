# Voice

A push notification micro service with a RESTful API

supports the following requests;

## put voice/voice_to
Sends notification immediately to client.

look at test/data.json for example

## put voice/voice_at
Sends notification at DateTime given in "alarm" to client.

look at test/alarm_data.json for example

## get voice/
Request returns a list of :reference's. Each reference is to a scheduled alarm.

## delete voice/:reference
Request to delete scheduled notification event with B64 encoded reference string representation.

*This project is intended for private use. Regarding security, the private vapid key is never to be sent over any public network and is only to be sent on localhost.*
