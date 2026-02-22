#pragma once
#include <Arduino.h>
#include <Wire.h>

class IMUDriver {
public:
  void begin();
  void readAccel(int16_t &ax, int16_t &ay, int16_t &az);
  void readGyro(int16_t &gx, int16_t &gy, int16_t &gz);
  void readAll(int16_t &ax, int16_t &ay, int16_t &az,
               int16_t &gx, int16_t &gy, int16_t &gz);

private:
  int16_t read16(uint8_t reg);
};
