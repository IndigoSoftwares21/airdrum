#pragma once
#include <Arduino.h>
#include <WiFi.h>
#include <WiFiUdp.h>
#include "config.h"
#include "FeedbackManager.h"

class CommManager {
public:
  void begin(FeedbackManager& feedback);
  void sendHit(float peak, float angle, FeedbackManager& feedback);
  void sendLog(const char* msg);
  
private:
  WiFiUDP udp;
  void connectWiFi(FeedbackManager& feedback);
};
