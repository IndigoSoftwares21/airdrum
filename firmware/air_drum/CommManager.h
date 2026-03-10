#pragma once
#include <Arduino.h>
#include <WiFi.h>
#include <WiFiUdp.h>
#include "config.h"

class CommManager {
public:
  void begin();
  void sendHit(float peak, float angle);
  void sendLog(const char* msg);
  
private:
  WiFiUDP udp;
  void connectWiFi();
};
