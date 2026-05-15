#pragma once
#include <Arduino.h>

#define LED_R_PIN  4
#define LED_G_PIN  5
#define LED_B_PIN  6

#define VIBE_PIN      3
#define VIBE_PWM_FREQ 1000
#define VIBE_PWM_RES  8
#define VIBE_STRENGTH 220
#define VIBE_PULSE_MS 30

#define HIT_FLASH_MS  80
#define BLINK_MS      250

enum class StickState {
  BOOTING,   // Blinking red  – no WiFi
  STANDBY,   // Blinking yellow – connected, ready
  HIT,       // Blue flash – returns to STANDBY after HIT_FLASH_MS
};

class FeedbackManager {
public:
  void begin();
  void setState(StickState state);
  void onHit();
  void tick();

private:
  StickState    _state     = StickState::BOOTING;
  unsigned long _hitEnd    = 0;
  unsigned long _vibeEnd   = 0;
  unsigned long _lastBlink = 0;
  bool          _blinkOn   = false;

  void _setRGB(bool r, bool g, bool b);
  void _setVibe(bool on);
};
