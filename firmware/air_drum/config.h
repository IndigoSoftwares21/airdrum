#pragma once

// I2C Pins
#define SDA_PIN 9
#define SCL_PIN 10
#define MPU_ADDR 0x68

// Airdrum Tuning (8g / 1000dps range)
#define LPF_ALPHA 0.4             // Low-pass filter smoothing factor (0.0 to 1.0)
#define SWING_GYRO_GATE 150.0     // Min gyro magnitude (deg/s) for a swing
#define IMPACT_ACCEL_GATE 2.5     // Min dynamic acceleration (g's) for impact
#define PEAK_WINDOW_MS 25         // Time to wait for the maximum deceleration
#define HIT_COOLDOWN_MS 120       // Prevent double triggers

// Networking & UDP
#define WIFI_SSID "ORJIUDE"
#define WIFI_PASS "orjiudeCom"
#define HOST_IP "192.168.0.104"  // User configurable Desktop IP
#define UDP_PORT 8000
#define STICK_ID "[LEFT]"        // Network identity prefix ([LEFT] or [RIGHT])
