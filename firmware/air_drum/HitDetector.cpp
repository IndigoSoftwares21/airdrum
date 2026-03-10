#include "HitDetector.h"
#include "IMUDriver.h"
#include "config.h"
#include <Arduino.h>

extern IMUDriver imu;

void HitDetector::begin() {
  state = DetectionState::IDLE;
  lastSampleUs = micros();
  filteredAx = 0;
  filteredAy = 0;
  filteredAz = 0;
  currentYaw = 0;
}

bool HitDetector::update(float &peakOut, float &angleOut) {
  unsigned long nowUs = micros();
  unsigned long nowMs = millis();
  
  // Throttle to 2kHz sample limit to leave CPU time for UDP and I2C (500us interval)
  if (nowUs - lastSampleUs < 500) {
    return false;
  }
  float dt = (nowUs - lastSampleUs) / 1000000.0f;
  lastSampleUs = nowUs;

  int16_t ax, ay, az, gx, gy, gz;
  imu.readAll(ax, ay, az, gx, gy, gz);

  // Convert to physical units: 8G scale (4096 LSB/G), 1000 DPS scale (32.8 LSB/DPS)
  float rawAccelX = ax / 4096.0f;
  float rawAccelY = ay / 4096.0f;
  float rawAccelZ = az / 4096.0f;
  
  float rawGyroX = gx / 32.8f;
  float rawGyroY = gy / 32.8f;
  float rawGyroZ = gz / 32.8f;

  // 1. Exponential Moving Average Low-Pass Filter
  if (filteredAx == 0 && filteredAy == 0 && filteredAz == 0) {
    // Seed the filter on first read with raw values
    filteredAx = rawAccelX;
    filteredAy = rawAccelY;
    filteredAz = rawAccelZ;
  } else {
    filteredAx = filteredAx * (1.0f - LPF_ALPHA) + rawAccelX * LPF_ALPHA;
    filteredAy = filteredAy * (1.0f - LPF_ALPHA) + rawAccelY * LPF_ALPHA;
    filteredAz = filteredAz * (1.0f - LPF_ALPHA) + rawAccelZ * LPF_ALPHA;
  }

  // Track Yaw (Heading) for the Piano slice mapping
  // We use a small deadzone to stop resting drift
  if (abs(rawGyroZ) > 1.5f) {
    // Invert if necessary, typical rotation maps straight addition
    currentYaw += rawGyroZ * dt;
  }
  
  // 2. Physics Model
  // Magnitude of the filtered acceleration vector (always ~1.0G at rest)
  float totalAccel = sqrt(filteredAx*filteredAx + filteredAy*filteredAy + filteredAz*filteredAz);
  float dynamicAccel = abs(totalAccel - 1.0f); // Strip gravity out

  // Magnitude of the gyro vector
  float gyroMag = sqrt(rawGyroX*rawGyroX + rawGyroY*rawGyroY + rawGyroZ*rawGyroZ);

  // 3. State Machine
  switch (state) {
    case DetectionState::IDLE:
      // Look for a fast swing motion (pre-impact)
      if (gyroMag > SWING_GYRO_GATE) {
        state = DetectionState::SWINGING;
        windowStartUs = nowUs;
      }
      break;

    case DetectionState::SWINGING:
      // In swing, we expect a sudden acceleration spike when arriving at impact
      if (dynamicAccel > IMPACT_ACCEL_GATE) {
        state = DetectionState::IMPACT_TRACKING;
        windowStartUs = nowUs;
        peakVal = dynamicAccel;
      } 
      // Timeout if they swung but missed / didn't stop hard enough
      else if ((nowUs - windowStartUs) / 1000 > 250) {
        state = DetectionState::IDLE;
      }
      break;

    case DetectionState::IMPACT_TRACKING:
      // Track the hardest point of the hit during a small 25ms window
      if (dynamicAccel > peakVal) {
        peakVal = dynamicAccel;
      }
      
      if ((nowUs - windowStartUs) / 1000 >= PEAK_WINDOW_MS) {
        // We found the peak of the impact!
        // We output a "MIDI-friendly" 0-127 integer mapped from the G-forces
        // Minimum hit (IMPACT_ACCEL_GATE) maps to low velocity, e.g. 2.5G -> ~30
        // Huge hit maps to ~127
        float rawVelocity = (peakVal / IMPACT_ACCEL_GATE) * 40.0f; 
        if (rawVelocity > 127.0f) rawVelocity = 127.0f;
        
        peakOut = rawVelocity;
        angleOut = currentYaw; // Lock the angle at the exact moment of peak impact
        lastHitMs = nowMs;
        state = DetectionState::COOLDOWN;
        return true;
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
