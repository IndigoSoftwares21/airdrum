#pragma once
#include <Arduino.h>

class CommManager {
public:
  void begin();
  void sendHit(float peak);
};
