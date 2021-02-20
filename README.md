# Voice

A push notification micro service with a RESTful API

supports two kinds of requests;

## voice/voice_to
Sends notification immediately to client.

look at test/data.json for example

## voice/voice_at
Sends notification at DateTime given in "alarm" to client.

look at test/alarm_data.json for example


This project is for private use intended, as to security, the private vapid key is never sent over any public network
and is only intended to be sent on localhost.
