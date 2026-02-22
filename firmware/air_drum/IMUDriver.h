#pragma once
#include <Arduino.h>
#include <Wire.h>

class IMUDriver {
public:
  void begin();
  void readAccel(int16_t &ax, int16_t &ay, int16_t &az);

private:
  int16_t read16(uint8_t reg);
};
