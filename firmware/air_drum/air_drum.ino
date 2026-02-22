#include "config.h"
#include "IMUDriver.h"
#include "HitDetector.h"
#include "CommManager.h"

IMUDriver imu;
HitDetector hitDetector;
CommManager comms;

void setup() {
  Serial.begin(115200);
  delay(1500);

  Serial.println("\n=== AIRDRUM SYSTEM START ===");

  imu.begin();
  hitDetector.begin();
  comms.begin();

  Serial.println("🥁 AirDrum ready");
}

void loop() {
  float peak;

  if (hitDetector.update(peak)) {
    Serial.print("🥁 HIT REGISTERED | peak=");
    Serial.println(peak, 0);

    comms.sendHit(peak);
  }
}
