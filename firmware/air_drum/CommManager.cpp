#include "CommManager.h"

void CommManager::begin() {
  // BLE / WiFi later
}

void CommManager::sendHit(float peak) {
  Serial.print("[COMMS] HIT peak=");
  Serial.println(peak, 0);
}
