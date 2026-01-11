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

