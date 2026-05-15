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

  pinMode(BTN_NEXT_PIN, INPUT_PULLUP);
  pinMode(BTN_PREV_PIN, INPUT_PULLUP);
  pinMode(BTN_MODE_PIN, INPUT_PULLUP);

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

  // --- Button Polling ---
  static unsigned long lastBtnTime = 0;
  if (millis() - lastBtnTime > 200) { // 200ms debounce
    if (digitalRead(BTN_NEXT_PIN) == LOW) {
      comms.nextKit();
      lastBtnTime = millis();
    }
    else if (digitalRead(BTN_PREV_PIN) == LOW) {
      comms.prevKit();
      lastBtnTime = millis();
    }
    else if (digitalRead(BTN_MODE_PIN) == LOW) {
      comms.toggleMode();
      lastBtnTime = millis();
    }
  }

  comms.update(); // Keep OTA and WebServer alive
  feedback.tick();
}
