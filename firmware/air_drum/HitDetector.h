#pragma once
#include <Arduino.h>

enum class DetectionState {
  IDLE,
  TRACKING,
  COOLDOWN
};

class HitDetector {
public:
  void begin();
  bool update(float &peakOut);

private:
  int16_t pax = 0, pay = 0, paz = 0;
  float peakVal = 0;
  unsigned long lastSampleUs = 0;
  unsigned long windowStartUs = 0;
  unsigned long lastHitMs = 0;
  DetectionState state = DetectionState::IDLE;
};
