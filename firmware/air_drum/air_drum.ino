#include "config.h"
#include "IMUDriver.h"
#include "HitDetector.h"
#include "CommManager.h"

IMUDriver imu;
HitDetector hitDetector;
CommManager comms;

void setup() {
  Serial.begin(115200);
  while (!Serial) delay(10);
  delay(1500);

  Serial.println("\n=== AIRDRUM SYSTEM START ===");

  imu.begin();
  hitDetector.begin();
  comms.begin(); // Setup network and UDP

  String startLog = String(STICK_ID) + " === AIRDRUM SYSTEM START ===";
  comms.sendLog(startLog.c_str());

  Serial.println("🥁 AirDrum ready");
  String readyLog = String(STICK_ID) + " 🥁 AirDrum ready";
  comms.sendLog(readyLog.c_str());
}

unsigned long lastHeartbeatTime = 0;

void loop() {
  float peak;
  float angle;

  if (hitDetector.update(peak, angle)) {
    comms.sendHit(peak, angle);
  }

  if (millis() - lastHeartbeatTime >= 1000) {
    lastHeartbeatTime = millis();
    comms.sendLog(STICK_ID " HEARTBEAT");
  }
}
