# Air Drum Proto Board Wiring Plan (SLIM MODE)

**Board size:** 9 holes wide × 63 holes long  
**Power:** Supplied by Battery Board (5V + GND) connected directly to ESP32

---

## Components on Board

| Component | Purpose |
|---|---|
| ESP32-S3 Zero | Main MCU (Waveshare Pinout) |
| MPU-6050 module | IMU — gyro + accelerometer (I2C) |
| RGB LED (common cathode) | Status indicator |
| 3× 220Ω resistors | Current limiting for RGB LED |
| Vibration motor module | Haptic feedback |
| 3x Push Buttons | NEXT, PREV, MODE |

---

## ESP32-S3 Zero Pin Assignment (Waveshare)

### Left side (Col 2)
| Pin # | GPIO | Used For |
|---|---|---|
| 1 | 5V | Battery VCC (5V) |
| 2 | GND | Battery GND |
| 3 | 3V3 | unused |
| 4 | GP1 | Button NEXT |
| 5 | GP2 | Button PREV |
| 6 | GP3 | Vibration SIG |
| 7 | GP4 | LED Red |
| 8 | GP5 | LED Green |
| 9 | GP6 | LED Blue |

### Right side (Col 8)
| Pin # | GPIO | Used For |
|---|---|---|
| 1 | 43 | unused |
| 2 | 44 | unused |
| 3 | 13 | unused |
| 4 | 12 | unused |
| 5 | 11 | unused |
| 6 | 10 | unused |
| 7 | 9 | I2C SCL |
| 8 | 8 | I2C SDA |
| 9 | 7 | Button MODE |

---

## Board Zone Layout (Slim Mode)

```
Rows  1 – 9  : ESP32-S3 Zero (USB facing UP)
Rows 16 – 19 : MPU-6050 module
Rows 22 – 24 : Vibration motor module
Rows 27 – 32 : RGB LED + 3 resistors
Rows 40 – 43 : NEXT, PREV, MODE Buttons
```

**Power rails:**
- Column 1  (full length) = GND
- Column 9  (full length) = 3.3V (tapped from ESP32 3V3 pin)

---

## ASCII Layout Reference

```
Col:  1  2  3  4  5  6  7  8  9
      G  |  |  |  |  |  |  |  V
      N  |  |  |  |  |  |  |  C
      D  |  |  |  |  |  |  |  C

R1    G [5V]     (USB)    [TX] V
R2    G [GND]             [RX] V
R3    G [3V3]             [13] V
R4    G [GP1]             [12] V
R5    G [GP2]             [11] V
R6    G [GP3]             [10] V
R7    G [GP4]             [GP9]V (SCL)
R8    G [GP5]             [GP8]V (SDA)
R9    G [GP6]             [GP7]V (MODE)

R16      [MPU-6050]
         VCC─►col9  GND─►col1  SDA─►GP8  SCL─►GP9

R22      [Vibration Module]
         VCC─►col9  GND─►col1  SIG─►GP3

R27      [RGB LED]  R──[220Ω]──►GP4
         R G B C    G──[220Ω]──►GP5
               │    B──[220Ω]──►GP6
               └───►GND rail (col 1)

R40      [BTN N] [BTN P] [BTN M]
          GP1     GP2     GP7
```
