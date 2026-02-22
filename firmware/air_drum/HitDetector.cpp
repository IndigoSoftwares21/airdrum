#include "HitDetector.h"
#include "IMUDriver.h"
#include "config.h"
#include <Arduino.h>

extern IMUDriver imu;

void HitDetector::begin() {
  state = DetectionState::IDLE;
  lastSampleUs = micros();
}

bool HitDetector::update(float &peakOut) {
  unsigned long nowUs = micros();
  unsigned long nowMs = millis();
  
  // High frequency sampling (1kHz)
  if (nowUs - lastSampleUs < 1000) {
    return false;
  }
  lastSampleUs = nowUs;

  int16_t ax, ay, az, gx, gy, gz;
  imu.readAll(ax, ay, az, gx, gy, gz);

  // Jerk (change in acceleration) is best for detecting the "impact" of a mid-air stop
  int16_t dx = ax - pax;
  int16_t dy = ay - pay;
  int16_t dz = az - paz;
  
  pax = ax;
  pay = ay;
  paz = az;

  float jerkMag = sqrt((float)dx*dx + (float)dy*dy + (float)dz*dz);
  float gyroMag = sqrt((float)gx*gx + (float)gy*gy + (float)gz*gz);

  switch (state) {
    case DetectionState::IDLE:
      // Trigger when we see a sharp change in movement (jerk) while swinging (gyro)
      if (jerkMag > IMPACT_GATE && gyroMag > GYRO_GATE) {
        state = DetectionState::TRACKING;
        windowStartUs = nowUs;
        peakVal = jerkMag;
      }
      break;

    case DetectionState::TRACKING:
      if (jerkMag > peakVal) {
        peakVal = jerkMag;
      }
      
      if ((nowUs - windowStartUs) / 1000 >= PEAK_WINDOW_MS) {
        if (peakVal >= PEAK_MIN) {
          peakOut = peakVal;
          lastHitMs = nowMs;
          state = DetectionState::COOLDOWN;
          return true;
        } else {
          state = DetectionState::IDLE;
        }
      }
      break;

    case DetectionState::COOLDOWN:
      if (nowMs - lastHitMs >= HIT_COOLDOWN_MS) {
        state = DetectionState::IDLE;
      }
      break;
  }

  return false;
}
