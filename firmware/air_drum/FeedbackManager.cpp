#include "FeedbackManager.h"

void FeedbackManager::begin() {
  pinMode(LED_R_PIN, OUTPUT);
  pinMode(LED_G_PIN, OUTPUT);
  pinMode(LED_B_PIN, OUTPUT);
  pinMode(VIBE_PIN, OUTPUT);
  digitalWrite(VIBE_PIN, LOW);
  _setRGB(false, false, false);
}

void FeedbackManager::setState(StickState state) {
  if (_state == StickState::HIT) return;
  _state = state;
  _blinkOn = false;
}

void FeedbackManager::onHit() {
  _state   = StickState::HIT;
  _hitEnd  = millis() + HIT_FLASH_MS;
  _vibeEnd = millis() + VIBE_PULSE_MS;
  _setRGB(false, false, true);
  _setVibe(true);
}

void FeedbackManager::tick() {
  unsigned long now = millis();

  if (_state == StickState::HIT && now >= _hitEnd) {
    _state = StickState::STANDBY;
    _blinkOn = false;
  }

  if (_vibeEnd > 0 && now >= _vibeEnd) {
    _setVibe(false);
    _vibeEnd = 0;
  }

  if ((_state == StickState::BOOTING || _state == StickState::STANDBY)
      && now - _lastBlink >= BLINK_MS) {
    _lastBlink = now;
    _blinkOn = !_blinkOn;
    
    if (_state == StickState::BOOTING) {
      _setRGB(_blinkOn, false, false); // Blinking Red
    } else {
      _setRGB(_blinkOn, _blinkOn, false); // Blinking Yellow
    }
  }
}

void FeedbackManager::_setRGB(bool r, bool g, bool b) {
  digitalWrite(LED_R_PIN, r ? HIGH : LOW);
  digitalWrite(LED_G_PIN, g ? HIGH : LOW);
  digitalWrite(LED_B_PIN, b ? HIGH : LOW);
}

void FeedbackManager::_setVibe(bool on) {
  digitalWrite(VIBE_PIN, on ? HIGH : LOW);
}
