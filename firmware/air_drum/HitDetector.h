#pragma once
#include <Arduino.h>

enum class DetectionState {
  IDLE,
  SWINGING,
  IMPACT_TRACKING,
  COOLDOWN
};

class HitDetector {
public:
  void begin();
  bool update(float &peakOut, float &angleOut);

private:
  float filteredAx = 0, filteredAy = 0, filteredAz = 0;
  float currentYaw = 0; // Tracks rotation around Z axis (left/right)
  float peakVal = 0;
  
  unsigned long lastUpdateUs = 0;
  unsigned long lastSampleUs = 0;
  unsigned long windowStartUs = 0;
  unsigned long lastHitMs = 0;
  DetectionState state = DetectionState::IDLE;
};
