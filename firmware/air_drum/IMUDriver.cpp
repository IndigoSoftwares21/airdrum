#include "IMUDriver.h"
#include "config.h"
#include <Arduino.h>
#include <Wire.h>

void IMUDriver::begin() {
  Wire.begin(SDA_PIN, SCL_PIN);
  Wire.setClock(50000);
  delay(300);

  // Wake IMU
  Wire.beginTransmission(MPU_ADDR);
  Wire.write(0x6B);
  Wire.write(0x00);
  Wire.endTransmission();
  delay(100);
}

int16_t IMUDriver::read16(uint8_t reg) {
  Wire.beginTransmission(MPU_ADDR);
  Wire.write(reg);
  Wire.endTransmission(false);
  Wire.requestFrom(MPU_ADDR, 2);
  return (Wire.read() << 8) | Wire.read();
}

void IMUDriver::readAccel(int16_t &ax, int16_t &ay, int16_t &az) {
  ax = read16(0x3B);
  ay = read16(0x3D);
  az = read16(0x3F);
}
