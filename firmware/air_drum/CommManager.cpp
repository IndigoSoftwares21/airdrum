#include "CommManager.h"

void CommManager::begin(FeedbackManager& feedback) {
  connectWiFi(feedback);
}

void CommManager::connectWiFi(FeedbackManager& feedback) {
  feedback.setState(StickState::BOOTING);
  Serial.print("Connecting to WiFi");
  WiFi.begin(WIFI_SSID, WIFI_PASS);
  while (WiFi.status() != WL_CONNECTED) {
    feedback.tick(); // Keep LED blinking while we block on WiFi
    delay(100);
    Serial.print(".");
  }
  Serial.println("\nWiFi connected.");
  Serial.print("IP address: ");
  Serial.println(WiFi.localIP());

  udp.begin(UDP_PORT);
  feedback.setState(StickState::STANDBY);
}

void CommManager::sendLog(const char* msg) {
  if (WiFi.status() == WL_CONNECTED) {
    udp.beginPacket(HOST_IP, UDP_PORT);
    udp.print(msg);
    udp.endPacket();
  }
}

void CommManager::sendHit(float peak, float angle, FeedbackManager& feedback) {
  Serial.print("HIT peak=");
  Serial.print(peak, 0);
  Serial.print(" angle=");
  Serial.println(angle, 0);
  String str = String(STICK_ID) + " HIT peak=" + String(peak, 0) + " angle=" + String(angle, 0);
  sendLog(str.c_str());
  feedback.onHit();
}
