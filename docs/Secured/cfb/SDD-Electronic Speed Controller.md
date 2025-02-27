### Project 2: Electronic Speed Controller (ESC) Design
**Focus**: Build a custom, configurable ESC to drive motors across unmanned systems, integrated with the Brain Controller.

#### SDD Outline
1. **Introduction**
   - Purpose: Create a universal ESC for motor control in unmanned systems.
   - Scope: Focus on rover motors initially, expandable to UAVs/hexapods.
   - Objectives: Efficient power delivery, safety features, and Brain Controller compatibility.

2. **System Overview**
   - Description: A microcontroller-based ESC with PWM output and power management.
   - Use Case: Precise speed control for a rover’s DC motors.

3. **System Architecture**
   - Components: MCU (e.g., STM32), MOSFETs, current sensors.
   - Interactions: Brain Controller → ESC (via CAN Bus) → motors.
   - Diagram: ESC circuit with Brain Controller link.

4. **Functional Requirements**
   - Support 12V-24V input, 10A-50A output.
   - Accept PWM/CAN commands from Brain Controller.
   - Provide overcurrent/overheat protection.

5. **Technical Specifications**
   - Hardware: STM32F4, LiPo battery input, BEC for 5V output.
   - Software: Firmware for PWM generation, CAN Bus comms.
   - Performance: < 5% power loss, 1 kHz PWM frequency.

6. **Design Considerations**
   - Communication: CAN Bus for reliability.
   - Power: Voltage regulation, BMS integration.
   - Safety: Shutdown on fault detection.
   - Scalability: Configurable firmware for different motors.

7. **Implementation Plan**
   - Phase 1 (1-2 months): Circuit design, PCB prototyping.
   - Phase 2 (1 month): Firmware dev, integration with Brain Controller.

8. **Testing and Validation**
   - Unit tests: Motor response, fault protection.
   - Integration test: Rover moves under Brain Controller commands.

9. **Constraints and Risks**
   - Cost: ~$50-$150 (components, PCB fab).
   - Risk: Heat dissipation; mitigated with heat sinks.

**Deliverable**: A working ESC prototype driving rover motors, controlled by the Brain Controller.

**Why Second?**: Builds on the Brain Controller’s command output, adding motor control before full system integration with GCS.
### Project 2: Electronic Speed Controller (ESC) Design
**Focus**: Build a custom, configurable ESC to drive motors across unmanned systems, integrated with the Brain Controller.

#### SDD Outline
1. **Introduction**
   - Purpose: Create a universal ESC for motor control in unmanned systems.
   - Scope: Focus on rover motors initially, expandable to UAVs/hexapods.
   - Objectives: Efficient power delivery, safety features, and Brain Controller compatibility.

2. **System Overview**
   - Description: A microcontroller-based ESC with PWM output and power management.
   - Use Case: Precise speed control for a rover’s DC motors.

3. **System Architecture**
   - Components: MCU (e.g., STM32), MOSFETs, current sensors.
   - Interactions: Brain Controller → ESC (via CAN Bus) → motors.
   - Diagram: ESC circuit with Brain Controller link.

4. **Functional Requirements**
   - Support 12V-24V input, 10A-50A output.
   - Accept PWM/CAN commands from Brain Controller.
   - Provide overcurrent/overheat protection.

5. **Technical Specifications**
   - Hardware: STM32F4, LiPo battery input, BEC for 5V output.
   - Software: Firmware for PWM generation, CAN Bus comms.
   - Performance: < 5% power loss, 1 kHz PWM frequency.

6. **Design Considerations**
   - Communication: CAN Bus for reliability.
   - Power: Voltage regulation, BMS integration.
   - Safety: Shutdown on fault detection.
   - Scalability: Configurable firmware for different motors.

7. **Implementation Plan**
   - Phase 1 (1-2 months): Circuit design, PCB prototyping.
   - Phase 2 (1 month): Firmware dev, integration with Brain Controller.

8. **Testing and Validation**
   - Unit tests: Motor response, fault protection.
   - Integration test: Rover moves under Brain Controller commands.

9. **Constraints and Risks**
   - Cost: ~$50-$150 (components, PCB fab).
   - Risk: Heat dissipation; mitigated with heat sinks.

**Deliverable**: A working ESC prototype driving rover motors, controlled by the Brain Controller.

**Why Second?**: Builds on the Brain Controller’s command output, adding motor control before full system integration with GCS.
