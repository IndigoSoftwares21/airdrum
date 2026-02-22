#include "HitDetector.h"
#include "IMUDriver.h"
#include "config.h"
#include <Arduino.h>

extern IMUDriver imu;

void HitDetector::begin() {
  // nothing needed
}

bool HitDetector::update(float &peakOut) {
  int16_t ax, ay, az;
  imu.readAccel(ax, ay, az);

  int16_t dx = ax - pax;
  int16_t dy = ay - pay;
  int16_t dz = az - paz;

  pax = ax;
  pay = ay;
  paz = az;

  float deltaMag = sqrt(
    (float)dx * dx +
    (float)dy * dy +
    (float)dz * dz
  );

  unsigned long nowMs = millis();

  if (deltaMag > IMPACT_GATE &&
      (nowMs - lastHitMs) > HIT_COOLDOWN_MS) {

    unsigned long startUs = micros();
    float peak = deltaMag;

    while (micros() - startUs < PEAK_WINDOW_US) {
      imu.readAccel(ax, ay, az);

      dx = ax - pax;
      dy = ay - pay;
      dz = az - paz;

      pax = ax;
      pay = ay;
      paz = az;

      float d = sqrt(
        (float)dx * dx +
        (float)dy * dy +
        (float)dz * dz
      );

      if (d > peak) peak = d;
    }

    if (peak >= PEAK_MIN) {
      peakOut = peak;
      lastHitMs = nowMs;
      return true;
    }
  }

  return false;
}
