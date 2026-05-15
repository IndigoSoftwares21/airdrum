#include "CommManager.h"

// ── Lifecycle ────────────────────────────────────────────────────────────────

void CommManager::begin(FeedbackManager& feedback) {
  loadSettings();
  startBLE();          // Always advertise for easy re-config
  connectWiFi(feedback);
  setupOTA();
}

void CommManager::update() {
  ArduinoOTA.handle();
  if (_portalMode) {
    dnsServer.processNextRequest();
  }
  server.handleClient();
}

// ── Persistent Settings ──────────────────────────────────────────────────────

void CommManager::loadSettings() {
  prefs.begin("airdrum", true);
  _wifiSsid = prefs.getString("ssid", WIFI_SSID);
  _wifiPass = prefs.getString("pass", WIFI_PASS);
  _hostIp   = prefs.getString("host", HOST_IP);
  prefs.end();
}

void CommManager::saveSettings(String ssid, String pass, String ip) {
  prefs.begin("airdrum", false);
  prefs.putString("ssid", ssid);
  prefs.putString("pass", pass);
  prefs.putString("host", ip);
  prefs.end();
  _wifiSsid = ssid;
  _wifiPass = pass;
  _hostIp   = ip;
}

// ── BLE Setup Service ────────────────────────────────────────────────────────

void CommManager::startBLE() {
  String devName = "AirDrum-";
  devName += String(STICK_ID);
  devName.replace("[", "");
  devName.replace("]", "");

  BLEDevice::init(devName.c_str());
  BLEServer*         pServer = BLEDevice::createServer();
  BLEService*        pSvc    = pServer->createService(BLE_SERVICE_UUID);
  BLECharacteristic* pChar   = pSvc->createCharacteristic(
                                  BLE_CHAR_UUID,
                                  BLECharacteristic::PROPERTY_WRITE |
                                  BLECharacteristic::PROPERTY_READ
                                );
  pChar->setCallbacks(this);
  pSvc->start();

  BLEAdvertising* pAdv = BLEDevice::getAdvertising();
  pAdv->addServiceUUID(BLE_SERVICE_UUID);
  pAdv->setScanResponse(true);
  pAdv->setMinPreferred(0x06);
  pAdv->setMinPreferred(0x12);
  BLEDevice::startAdvertising();

  Serial.println("BLE ready: " + devName);
}

// Called by Flutter when it writes credentials over BLE
// Payload format: "ssid,password,hostIp"
void CommManager::onWrite(BLECharacteristic* pChar) {
  String data = pChar->getValue();   // Arduino String — no std::string needed
  if (data.length() == 0) return;

  int c1 = data.indexOf(',');
  int c2 = data.lastIndexOf(',');
  if (c1 < 0 || c2 < 0 || c1 == c2) {
    Serial.println("BLE: bad payload: " + data);
    return;
  }

  String ssid = data.substring(0, c1);
  String pass = data.substring(c1 + 1, c2);
  String ip   = data.substring(c2 + 1);

  Serial.println("BLE config received — SSID: " + ssid + "  IP: " + ip);
  saveSettings(ssid, pass, ip);
  delay(500);
  ESP.restart();
}

// ── WiFi Connection ──────────────────────────────────────────────────────────

void CommManager::connectWiFi(FeedbackManager& feedback) {
  feedback.setState(StickState::BOOTING);
  Serial.print("Connecting to WiFi: ");
  Serial.println(_wifiSsid);

  WiFi.begin(_wifiSsid.c_str(), _wifiPass.c_str());

  unsigned long t0 = millis();
  while (WiFi.status() != WL_CONNECTED && millis() - t0 < 10000) {
    feedback.tick();
    delay(100);
    Serial.print(".");
  }

  if (WiFi.status() == WL_CONNECTED) {
    String ip = WiFi.localIP().toString();
    Serial.println("\nWiFi connected — IP: " + ip);
    udp.begin(UDP_PORT);
    feedback.setState(StickState::STANDBY);
    _portalMode = false;
    _startWebServer(); // Config portal also reachable on home network
  } else {
    Serial.println("\nWiFi failed — starting portal.");
    startConfigPortal(feedback);
  }
}

// ── WiFi Config Portal (fallback) ────────────────────────────────────────────

void CommManager::startConfigPortal(FeedbackManager& feedback) {
  _portalMode = true;
  WiFi.mode(WIFI_AP);

  String apName = "AirDrum-";
  apName += String(STICK_ID);
  apName.replace("[", "");
  apName.replace("]", "");
  WiFi.softAP(apName.c_str());

  dnsServer.start(53, "*", WiFi.softAPIP());
  _startWebServer();

  Serial.println("Portal AP: " + apName + "  IP: " + WiFi.softAPIP().toString());
}

void CommManager::_startWebServer() {
  server.on("/", [this]() { handleRoot(); });
  server.on("/save", HTTP_POST, [this]() { handleSave(); });
  server.on("/status", [this]() { handleStatus(); });
  server.onNotFound([this]() { handleRoot(); });
  server.begin();
}

void CommManager::handleRoot() {
  server.send(200, "text/html",
    "<html><head><meta name='viewport' content='width=device-width,initial-scale=1'>"
    "<style>*{box-sizing:border-box}body{font-family:system-ui;background:#0f172a;color:#fff;padding:32px}"
    "input{display:block;width:100%;padding:12px;margin:8px 0 16px;background:#1e293b;"
    "border:1px solid #334155;border-radius:8px;color:#fff;font-size:16px}"
    "button{width:100%;padding:14px;background:#3b82f6;border:0;border-radius:8px;color:#fff;font-size:16px}"
    "</style></head><body>"
    "<h2>🥁 AirDrum Setup — " STICK_ID "</h2>"
    "<form method='POST' action='/save'>"
    "WiFi Name<input name='ssid'>"
    "Password<input name='pass' type='password'>"
    "Computer IP<input name='ip'>"
    "<button>Save &amp; Connect</button></form></body></html>"
  );
}

void CommManager::handleSave() {
  String s = server.arg("ssid");
  String p = server.arg("pass");
  String i = server.arg("ip");
  if (s.length() == 0 || i.length() == 0) {
    server.send(400, "text/plain", "SSID and IP required.");
    return;
  }
  saveSettings(s, p, i);
  server.send(200, "application/json", "{\"ok\":true}");
  delay(1500);
  ESP.restart();
}

void CommManager::handleStatus() {
  server.sendHeader("Access-Control-Allow-Origin", "*");
  server.send(200, "application/json",
    "{\"device\":\"" + String(STICK_ID) + "\",\"ready\":true,"
    "\"ip\":\"" + WiFi.localIP().toString() + "\"}"
  );
}

// ── OTA ──────────────────────────────────────────────────────────────────────

void CommManager::setupOTA() {
  if (_portalMode) return;
  String hostname = "AirDrum-";
  hostname += String(STICK_ID);
  hostname.replace("[", "");
  hostname.replace("]", "");
  ArduinoOTA.setHostname(hostname.c_str());
  ArduinoOTA.begin();
}

// ── UDP Messaging ─────────────────────────────────────────────────────────────

void CommManager::sendLog(const char* msg) {
  if (WiFi.status() == WL_CONNECTED) {
    udp.beginPacket(_hostIp.c_str(), UDP_PORT);
    udp.print(msg);
    udp.endPacket();
  }
}

void CommManager::sendHit(float peak, float angle, FeedbackManager& feedback) {
  String str = String(STICK_ID) + " HIT kit=" + String(_kitIndex) + " mode=" + String(_modeIndex) + " peak=" + String(peak, 0) + " angle=" + String(angle, 0);
  sendLog(str.c_str());
  feedback.onHit();
}

void CommManager::nextKit() {
  _kitIndex++;
  if (_kitIndex > 9) _kitIndex = 0; // Support up to 10 kits
  String msg = String(STICK_ID) + " KIT_CHANGE=" + String(_kitIndex);
  sendLog(msg.c_str());
}

void CommManager::prevKit() {
  _kitIndex--;
  if (_kitIndex < 0) _kitIndex = 9;
  String msg = String(STICK_ID) + " KIT_CHANGE=" + String(_kitIndex);
  sendLog(msg.c_str());
}

void CommManager::toggleMode() {
  _modeIndex = (_modeIndex == 0) ? 1 : 0;
  String msg = String(STICK_ID) + " MODE_CHANGE=" + String(_modeIndex);
  sendLog(msg.c_str());
}
