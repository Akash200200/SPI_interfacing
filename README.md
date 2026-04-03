# SPI Master-Slave Communication System

A SystemVerilog implementation of a Serial Peripheral Interface (SPI) bus with one master controller and three slave devices, demonstrating full-duplex synchronous communication.

## Architecture

### System Overview
- **Clock**: 10 MHz (100 ns period)
- **Data Width**: 8-bit transfers
- **Topology**: 1 Master + 3 Slaves
- **Protocol**: MSB-first, synchronous on clock edges

### Components

#### `spi_master.sv`
Master controller that:
- Loads 8-bit data on `load` signal assertion
- Shifts data out on MOSI (Master Out, Slave In) while shifting in MISO (Master In, Slave Out)
- Counts 8 bits per transmission and asserts `done` flag upon completion
- Resets state when CS (Chip Select) goes inactive

#### `spi_slave.sv`
Slave interface that:
- Receives incoming data on MOSI into shift register
- Transmits response data on MISO (MSB-first)
- Loads response data at the start of each transmission (bit_count == 0)
- Responds to individual chip select lines (CS active-low)

#### `spi_top.sv`
Top-level wrapper instantiating:
- 1 master module
- 3 slave modules with fixed response data:
  - Slave 0: `0xA5`
  - Slave 1: `0x5A`
  - Slave 2: `0x55`
- Shared MOSI line; individual CS and MISO lines per slave

#### `spi_testbench.sv`
Comprehensive test suite executing four test cases:

| Test | Purpose | Expected Result |
|------|---------|-----------------|
| TEST 1 | Single transfer to Slave 0 (master sends `0xAA`) | Master receives `0xA5` |
| TEST 2 | Single transfer to Slave 1 (master sends `0x55`) | Master receives `0x5A` |
| TEST 3 | Single transfer to Slave 2 (master sends `0xFF`) | Master receives `0x55` |
| TEST 4 | Back-to-back transfers to Slave 0 (`0x12`, `0x34`) | Both receive `0xA5` |

## Technical Details

### Data Transfer Flow
1. Master asserts CS low to select target slave
2. Master asserts `load` to latch outgoing data
3. On each clock edge:
   - Master shifts out MSB of current byte
   - Slave shifts in bit on MOSI
   - Slave shifts out MSB of response data
   - Master shifts in bit from MISO
4. After 8 clock cycles, master asserts `done`
5. Master deasserts CS to complete transfer

### Implementation Notes
- Uses `always_ff` blocks for synchronous state management
- Bit counter (4-bit) tracks progress through 8-bit word
- Shift registers (`shift_reg_tx`, `shift_reg_rx`) handle parallel-to-serial conversion
- Full-duplex: simultaneous transmission and reception on shared clock
- Individual CS lines enable multi-slave operation

## Simulation
Run in ModelSim or compatible SystemVerilog simulator:
```
vlog spi_master.sv spi_slave.sv spi_top.sv spi_testbench.sv
vsim spi_testbench
run -all
```

## Test Results
Upon successful execution, simulator displays per-test pass/fail status and summary:
- All 4 tests passing confirms correct master-slave handshaking
- MOSI/MISO timing verification validates clock-edge synchronization
- Response integrity confirms data corruption-free full-duplex operation
