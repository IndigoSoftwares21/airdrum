#include "config.h"
#include "IMUDriver.h"
#include "HitDetector.h"
#include "CommManager.h"
#include "FeedbackManager.h"

IMUDriver imu;
HitDetector hitDetector;
CommManager comms;
FeedbackManager feedback;

void setup() {
  Serial.begin(115200);
  delay(1500);

  feedback.begin();

  Serial.println("\n=== AIRDRUM SYSTEM START ===");

  imu.begin();
  hitDetector.begin();
  comms.begin(feedback);

  String readyLog = String(STICK_ID) + " AirDrum ready";
  comms.sendLog(readyLog.c_str());

  // Hold STANDBY (yellow) long enough to always be visible
  unsigned long standbyUntil = millis() + 2000;
  while (millis() < standbyUntil) {
    feedback.tick();
    delay(50);
  }
}

unsigned long lastHeartbeatTime = 0;

void loop() {
  float peak;
  float angle;

  if (hitDetector.update(peak, angle)) {
    comms.sendHit(peak, angle, feedback);
  }

  if (millis() - lastHeartbeatTime >= 1000) {
    lastHeartbeatTime = millis();
    comms.sendLog(STICK_ID " HEARTBEAT");
  }

  feedback.tick();
}
