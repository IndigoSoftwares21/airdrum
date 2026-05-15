#pragma once
#include <Arduino.h>
#include <WiFi.h>
#include <WiFiUdp.h>
#include <ArduinoOTA.h>
#include <Preferences.h>
#include <WebServer.h>
#include <DNSServer.h>
#include <BLEDevice.h>
#include <BLEServer.h>
#include <BLEUtils.h>
#include <BLE2902.h>
#include "config.h"
#include "FeedbackManager.h"

// UUIDs for the AirDrum BLE Setup Service
#define BLE_SERVICE_UUID  "4fafc201-1fb5-459e-8fcc-c5c9c331914b"
#define BLE_CHAR_UUID     "beb5483e-36e1-4688-b7f5-ea07361b26a8"

class CommManager : public BLECharacteristicCallbacks {
public:
  void begin(FeedbackManager& feedback);
  void update();
  void sendHit(float peak, float angle, FeedbackManager& feedback);
  void sendLog(const char* msg);

  void nextKit();
  void prevKit();
  void toggleMode();
  int  getKit()  { return _kitIndex; }
  int  getMode() { return _modeIndex; }

  // BLE callback — called when Flutter writes credentials
  void onWrite(BLECharacteristic* pChar) override;

private:
  WiFiUDP    udp;
  WebServer  server{80};
  DNSServer  dnsServer;
  Preferences prefs;

  String _wifiSsid;
  String _wifiPass;
  String _hostIp;
  bool   _portalMode = false;
  int    _kitIndex   = 0;
  int    _modeIndex  = 0; // 0: DRUM, 1: PIANO

  void loadSettings();
  void saveSettings(String ssid, String pass, String ip);
  void connectWiFi(FeedbackManager& feedback);
  void startConfigPortal(FeedbackManager& feedback);
  void startBLE();
  void setupOTA();

  // WiFi portal handlers (fallback if BLE not available)
  void _startWebServer();
  void handleRoot();
  void handleSave();
  void handleStatus();
};
