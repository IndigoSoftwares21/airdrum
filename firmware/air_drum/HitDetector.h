#pragma once
#include <Arduino.h>

class HitDetector {
public:
  void begin();
  bool update(float &peakOut);

private:
  int16_t pax = 0, pay = 0, paz = 0;
  unsigned long lastHitMs = 0;
};
