#include "CommManager.h"

void CommManager::begin() {
  connectWiFi();
}

void CommManager::connectWiFi() {
  Serial.print("Connecting to WiFi");
  WiFi.begin(WIFI_SSID, WIFI_PASS);
  while (WiFi.status() != WL_CONNECTED) {
    delay(500);
    Serial.print(".");
  }
  Serial.println("\nWiFi connected.");
  Serial.print("IP address: ");
  Serial.println(WiFi.localIP());
  
  udp.begin(UDP_PORT);
  Serial.println("UDP log forwarder started.");
}

void CommManager::sendLog(const char* msg) {
  if (WiFi.status() == WL_CONNECTED) {
    udp.beginPacket(HOST_IP, UDP_PORT);
    udp.print(msg);
    udp.endPacket();
  }
}

void CommManager::sendHit(float peak) {
  Serial.print("[COMMS] HIT peak=");
  Serial.println(peak, 0);

  String str = String(STICK_ID) + " [COMMS] HIT peak=" + String(peak, 0);
  sendLog(str.c_str());
}
