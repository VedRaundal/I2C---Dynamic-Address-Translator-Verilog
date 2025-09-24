# I²C Translator System in Verilog

## Overview
This project implements an **I²C Translator System** in Verilog.  
The design allows communication between a master and multiple slave devices through an **Address Translator FSM**, which handles routing and address translation.

Key modules:
- **Master FSM** – Controls all I²C transfers and generates protocol sequences.
- **Address Translator FSM** – Captures master transactions, verifies addresses, and forwards valid ones to appropriate slaves.
- **Slave FSMs** – Respond to matching addresses, performing read/write operations.
- **Clock Divider** – Generates standard I²C clock frequencies (100 kHz / 400 kHz) from a high-speed system clock.
- **Top-Level Module** – Connects all submodules and manages signals.

---

## Module Details

### 🔹 Clock Divider
- Divides a high-frequency system clock into standard I²C frequencies.
- Operates with a **counter-based approach** to toggle SCL at the correct intervals.

**Formula:**

Examples:
- 100 MHz → 100 kHz ⇒ Divider = 500  
- 100 MHz → 400 kHz ⇒ Divider = 125  

**Fix Applied:**  
Original implementation produced incorrect timing. A counter-based solution was introduced for accurate frequency generation.

---

### 🔹 Master FSM
Simulates I²C protocol by generating the proper signal sequence.


**Key States:**
- `Idle` – Waits for transaction trigger  
- `START` – SDA low while SCL high  
- `Send Address` – Sends 7-bit slave address + R/W bit  
- `ACK Wait` – Waits for ACK/NACK from slave  
- `Read / Write` – Data transfer  
- `STOP` – SDA high while SCL high (end transaction)  



### 🔹 Address Translator FSM
- Intercepts addresses from the Master.  
- If match → sends ACK and forwards data to the correct slave.  
- If mismatch → generates NACK.  
- Acts as a **router + address translator** for multiple slaves.

---

### 🔹 Slave FSMs
- Compare received address with own configured address.  
- Respond with ACK if matched, NACK otherwise.  
- **Write Mode** → Receive and store data.  
- **Read Mode** → Place data on SDA for Master to sample.  

---

### 🔹 Open-Drain SDA Implementation
I²C requires SDA and SCL lines to be **open-drain**:
- Devices can **pull the line low**.  
- Lines float high (via pull-up resistors) when not driven low.  

**Fix Applied:**  
- Previous implementation mistakenly drove SDA high.  
- Updated with **tri-state logic** to avoid contention:

```verilog
assign sda = (write_enable && (sda_out == 1'b0)) ? 1'b0 : 1'bz;


├── src/
│   ├── i2c_master_fsm.v
│   ├── i2c_slave_fsm.v
│   ├── i2c_translator_fsm.v
│   ├── clock_divider.v
│   └── i2c_top.v
├── docs/
│   ├── Report/
│   └── README.md
└── testbench/
    └── tb_top.v
