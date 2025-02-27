### Bid Response: Project 2 - Electronic Speed Controller (ESC) Design

#### 1. Company/Team Profile
- **Name**: TechForge Robotics
- **Overview**: 4-person team with expertise in power electronics and embedded systems.
- **Relevant Experience**:
  - Custom ESC for 24V rover (2023), CAN Bus, secure firmware.
  - PWM controller for drone (2021), overcurrent protection.
- **Key Personnel**: Alex Carter (Lead), Priya Sharma (Hardware), Liam Nguyen (Testing).

#### 2. Technical Approach
We propose a secure, DDS-integrated ESC with enhanced safety.

- **Hardware Design**:
  - **MCU**: STM32F103C8T6 (Blue Pill, CAN 2.0B).
  - **Power Stage**: IRF540N MOSFETs (x4), 0.1Ω shunt (2512 SMD).
  - **BEC**: MP1584EN (5V/2A).
  - **Input**: 11.1V-22.2V LiPo (XT60).
  - **Enclosure**: Hammond 1551KBK (IP65, 30x30mm heat sink).
  - **Connectors**: JST-PH (CAN), screw terminals (motor), Vishay NTC 10k thermistor.
  - **PCB**: 2-layer, 60x40mm, KiCAD, JLCPCB (5 units).
  - **Proposal**: Add AES hardware accel (STM32 crypto lib, no cost).

- **Firmware Development**:
  - **PWM**: 1-8 kHz (TIM2/TIM3), default 4 kHz.
  - **CAN Bus**: 125 kbps, DDS-to-CAN bridge (motor commands, fault codes).
  - **Safety**: Overcurrent (> 40A, < 80ms), thermal (> 80°C), soft-start (500ms ramp).
  - **Cybersecurity**:
    - Encrypt CAN data with AES-128 (STM32 hardware accel).
    - Authenticate Brain Controller with pre-shared key (PSK).
  - **Proposal**: Add firmware signature check (SHA-256, ~2 hours).

- **Integration & Testing**:
  - Mount on 4WD rover (12V motors).
  - Unit tests: PWM (±5%), fault triggers (100%), efficiency (< 4% loss).
  - Field test: 80m terrain, 150+ cycles.

#### 3. Cost Breakdown
| **Item**                | **Description**                     | **Cost (USD)** |
|-------------------------|-------------------------------------|----------------|
| **Hardware**            |                                     |                |
| STM32F103C8T6           | MCU                                 | $5             |
| IRF540N (x4)            | MOSFETs                             | $8             |
| Shunt Resistor          | 0.1Ω, 1W                            | $2             |
| MP1584EN                | 5V/2A BEC                           | $3             |
| Hammond 1551KBK         | IP65 enclosure                      | $6             |
| Heat Sink Pad           | 30x30mm                             | $2             |
| LiPo + XT60             | 11.1V 2200mAh                       | $20            |
| NTC Thermistor          | 10k Vishay                          | $1             |
| Connectors/Wiring       | JST-PH, screw terminals             | $5             |
| PCB Fabrication         | 5 units, JLCPCB                     | $25            |
| **Subtotal**            |                                     | **$77**        |
| **Labor**               |                                     |                |
| Circuit Design          | 15 hours @ $40/hr                   | $600           |
| Firmware Dev            | 30 hours @ $40/hr (DDS bridge)      | $1,200         |
| Testing & Docs          | 15 hours @ $35/hr                   | $525           |
| **Subtotal**            | 60 hours total                      | **$2,325**     |
| **Total**               | Hardware + Labor                    | **$2,402**     |

- **Notes**: Labor upped to 60 hours for DDS/CAN bridge. Fits $1,800-$3,200.

#### 4. Timeline with Milestones
- **Duration**: 3 months (July 1 - September 30, 2025).
  - **Week 1-4**: Design PCB, procure parts.
    - *Milestone*: PCB in fab.
  - **Week 5-8**: Assemble, code firmware, test standalone.
    - *Milestone*: ESC drives motor, CAN secure.
  - **Week 9-12**: Integrate, field test (80m), document.
    - *Milestone*: Delivered, 150+ cycles.

#### 5. References
- **Rover ESC (2023)**: Secure CAN. Contact: Prof. Mark Lee, [University Email].
- **Drone Controller (2021)**: PWM safety. Contact: [Startup Email].

#### 6. Proposed Enhancements
- **AES Hardware**: Use STM32 crypto for CAN encryption (no cost, ~2 hours).
- **Firmware Signing**: SHA-256 signature check (no cost, ~2 hours).
- **LED Indicator**: 5mm red LED ($0.50, ~1 hour) for faults.

#### 7. Conclusion
TechForge delivers a secure ESC at $2,402, in 3 months, with DDS integration and cybersecurity, ready for GCS control.