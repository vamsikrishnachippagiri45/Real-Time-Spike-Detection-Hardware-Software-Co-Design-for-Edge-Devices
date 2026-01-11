# Proposed design

The design can be implemented in two stages:1) Anomaly flag generation logic 2) Running mean calculation 

## Anomaly flag generation logic
In this stage, each incoming data sample is compared with the current running mean to identify abrupt deviations. The input sample, obtained from the input register, is first subtracted from the running mean value. The absolute difference is then compared with a user-defined threshold. If the difference exceeds the threshold, the sample is classified as an anomaly or spike. The resulting decision is encoded as a binary flag and stored in a spike register. The flag also acts as the select signal for a multiplexer. If a spike is detected the anomalous input is replaced with the running mean to suppress the outlier. Otherwise the original sample is passed to the next processing stage.

## Running mean calculation
The input sample from the previous stage is first stored in a register labeled X\_reg. Simultaneously, the current mean value computed up to the previous sample is held in M\_reg, while the partial sum is stored in P\_reg and the total number of samples processed is maintained in N\_reg. According to Welford’s algorithm, the updated partial sum is calculated by adding the difference between the new sample and the previous mean to the partial sum. This difference forms one of the inputs to the division unit, while the other input is the current value in N\_reg. The division yields two outputs: the shift in the mean, denoted as $\Delta m$, and the updated partial sum, denoted as $PR$. The mean is then updated by adding $\Delta m$ to the previous value, and the corrected partial sum $PR$ is stored back after accounting for the origin shift introduced by the new sample. The updated mean is passed to Mean\_reg for use in the next cycle. Simultaneously, the anomaly detection result is passed directly to the spike register for output. The resulting mean is of integer accuracy, providing a hardware-efficient approximation of the true mean. 

## Implementation Strategies for Mean Feedback
To manage the trade-off between operating frequency and detection accuracy, two different timing strategies for mean update propagation can be considered:

### Delayed Mean Feedback (Pipeline-Friendly Design)
In this method, the updated mean is first stored in the output register (mean\_reg) and made available to the anomaly detection logic in the next cycle, It is shown as path I of Figure. This causes the comparison to use the mean corresponding to the penultimate sample (i.e., the sample from two clock cycles prior). While this introduces one-sample latency in anomaly detection, it shortens the critical path, thereby supporting a higher clock frequency and better overall throughput.

### Immediate Mean Feedback (Cycle-Accurate Design)
Here, the updated mean is directly used for anomaly detection within the same clock cycle before being stored in mean\_reg, it is shown as path II of Figure. This allows comparison against the most recent (previous) sample, ensuring more accurate spike detection. However, the critical path includes both mean computation and anomaly detection logic, leading to increased delay and potentially reducing the maximum operating frequency.


![Block_Diagram](https://github.com/user-attachments/assets/e418ce61-9e67-4951-b5d4-5ec8154b423a)

# Implementation 

## Hardware
The proposed design is implemented on a Zynq SoC platform. A 32-bit general-purpose (GP) interface is utilized by the processing system (PS) as a master to access components within the programmable logic (PL). This enables the PS to interact with PL-based peripherals as memory-mapped modules, as illustrated. The PS communicates with the DMA controller through a High-Performance (HP) port, enabling efficient access to and from DDR memory\cite{5}. The custom Spike detection IP is implemented in the Programmable Logic (PL) and is connected to the DMA using an AXI-Stream interface, allowing continuous streaming of input data. The IP processes one input sample per clock cycle, making it suitable for real-time streaming scenarios. The spike detection output, generated for each input sample, is transmitted back to the DDR memory via the AXI-Stream interface through the DMA controller.

## Software
The software tools used in this implementation are Vivado and SDK(software development kit).

### Vivado
The hardware design is written in Verilog and packaged as a custom IP using the AXI-Stream interface. This IP is then integrated into a block design that includes peripherals such as the Zynq Processing System and the DMA controller. This integration ensures seamless data transfer between PL and PS.

### SDK
After exporting the hardware design as a Hardware Description File (HDF), the software application is developed in C. The processing system is programmed to configure the DMA controller, initiate transfers, and manage memory-mapped communication. Input data is stored in DDR memory by the PS, and after processing by the custom IP, the output is transferred via DMA to DDR Memory.

### Co-design
In this system, the hardware and software work together to perform anomaly detection efficiently. The programmable logic (PL) runs a custom IP that processes one input sample per cycle. The processing system (PS) handles control and manages data transfer using DMA. This co-design supports real-time streaming with low latency and efficient resource utilization.




# Experimental Results

For validation, a sinusoidal waveform with abrupt positive and negative spikes inserted at random intervals is used as the input, as shown in Figure. This signal is streamed into the spike detection system implemented on the FPGA. The real-time running mean, computed by the hardware IP, is shown in Figure. Due to its lightweight implementation, the IP can be repurposed as a general-purpose running mean engine for various real-time streaming data processing tasks in edge computing environments. The detection output, which flags time instances where the signal exceeds a predefined dynamic threshold, is illustrated in Figure, demonstrating accurate identification of abrupt anomalies. The detection accuracy depends on the choice of threshold, which can be tuned based on the expected signal dynamics and noise characteristics. 

The design is implemented on the ZedBoard Zynq Evaluation Kit (XC7Z020CLG484-1), and all reported resource metrics are based on synthesis results for this platform.

From Table, it can be observed that the proposed architecture particularly the immediate mean feedback variant achieves significantly lower hardware utilization and latency, making it highly suitable for low-power spike detection at the edge. On the other hand, the delayed mean feedback variant demonstrates lower critical path delay and supports higher maximum operating frequency, making it more suitable for higher throughput applications where latency is less critical.










