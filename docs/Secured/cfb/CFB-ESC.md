### Call for Bid: Project 2 - Electronic Speed Controller (ESC) Design

#### 1. Project Overview
- **Title**: Electronic Speed Controller Design for Unmanned Systems
- **Objective**: Develop a compact, efficient ESC to drive rover motors, integrated with Project 1’s Brain Controller.
- **Background**: Adds motor control to the ecosystem with a focus on affordability and durability.

#### 2. Scope of Work
- Design an STM32-based ESC with PWM output and CAN Bus communication.
- Support rover DC motors (12V-24V, 15A-40A range).
- Implement safety features (overcurrent, overheat protection).
- Integrate with Brain Controller via CAN Bus.
- Test on a rover over variable terrain.

#### 3. Requirements
- **Hardware**:
  - **MCU**: STM32F103C8T6 (Blue Pill, 72 MHz, CAN support, $3-$5).
  - **Power Stage**: IRF540N MOSFETs (100V, 33A, TO-220 package), 0.1Ω shunt resistor.
  - **BEC**: 5V/2A buck converter (e.g., MP1584EN module).
  - **Input**: 11.1V-22.2V LiPo (3S-5S, XT60 connector).
  - **Enclosure**: IP65-rated, 80x60x30mm ABS box (e.g., Hammond 1551KBK) with heat sink pad.
  - **Connectors**: JST-PH for CAN, XT60 for power, screw terminals for motor output.
  - **Sensors**: NTC 10k thermistor (e.g., Vishay NTCLE100E3103JB0) for temp monitoring.
- **Software**:
  - Firmware: PWM (1-8 kHz configurable), CAN Bus v2.0B (125 kbps default).
  - Config tool: Serial over USB for voltage/current tuning.
- **Performance**:
  - Efficiency: < 4% loss at 20A.
  - Response: < 8ms to commands.
  - Reliability: 150+ cycles at 50% duty.
- **Safety**:
  - Overcurrent shutdown (> 40A, < 80ms detection).
  - Thermal shutdown (> 80°C).
  - Fault codes via CAN.
- **Durability**: -5°C to 50°C, 4G vibration tolerance.

#### 4. Deliverables
- ESC prototype (PCB + firmware).
- Source code, schematics (KiCAD), BOM.
- Test report: Unit tests (motor response, safety triggers) and integration test (rover over 80m terrain).
- User guide: Installation, tuning, troubleshooting (PDF).

#### 5. Timeline
- **Duration**: 3 months (tightened for streamlined fab).
  - Week 1-4: Circuit design, procurement.
  - Week 5-8: PCB fab, firmware dev.
  - Week 9-12: Integration, outdoor testing.
- **Milestones**:
  - Month 1: PCB schematic done.
  - Month 2: ESC standalone functional.
  - Month 3: Integrated, field-tested.

#### 6. Budget
- **Estimated Cost**: $80-$150 (STM32F103 ~$5, IRF540N ~$10, PCB fab ~$30).
- **Bid Range**: $1,800-$3,200 (tightened labor: ~50-70 hours @ $30-$45/hr, plus materials).
- Funding covers materials, fab, and testing.

#### 7. Submission Guidelines
- **Deadline**: July 1, 2025.
- **Format**: PDF, max 10 pages.
- **Content**:
  - Team profile, ESC/embedded experience.
  - Technical approach (circuit, firmware).
  - Cost breakdown (labor, materials, fab).
  - Timeline with milestones.
  - References.
- **Submit to**: bids@yourdomain.com.

#### 8. Evaluation Criteria
- ESC design expertise (40%).
- Cost efficiency and hardware precision (30%).
- Timeline and testing rigor (20%).
- Safety/durability features (10%).

#### 9. Contact Information
- [Your name], Project Lead.
- Email: [Your email].
- Questions due by: June 15, 2025.