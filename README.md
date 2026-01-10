# Real-Time-Spike-Detection-Hardware-Software-Co-Design-for-Edge-Devices
A lightweight hardware–software co-designed spike detector for real-time streaming sensor data. The design uses a running mean–based algorithm to detect abrupt anomalies caused by noise or transient faults. Implemented on an FPGA for low-latency, deterministic operation with low resource utilization, suitable for edge and embedded systems.


In recent years, edge computing has become important in many areas such as industrial automation and health monitoring. These systems depend on continuous streams of real-time sensor data to make critical decisions. Such data may often affected by abrupt spikes which are short-lived and irregular. These can lead to degraded system performance. Although Machine learning(ML) approches can detect such spikes, but they typically involve high resource utilization, high power consumption making them unsuitable for deployment on resource constrains edge platforms. Apart from machine learning, there are also traditional methods like Z-score, MAD (median absolute deviation), moving averages, and LMS filters used for detecting spikes in data. However many of these need complex calculations or have to store a lot of past data, which can slow things down or make them harder to run on simple hardware. 

To overcome these limitations, our work presents a lightweight spike detection strategy using a running mean approach that analyzes each incoming data point in real time, without relying on floating-point operations or large memory buffers. The design follows a hardware–software co-design model, where the main detection task is handled by a dedicated hardware unit, while a software layer takes care of control logic and data flow. This structure delivers a fast, power-efficient solution that is ideal for running in real-time on FPGAs at the edge. 


# Welford’s Algorithm for Running Mean

In real-time and streaming data systems, computing the mean incrementally is essential for tasks such as anomaly detection, noise suppression, and adaptive thresholding. Storing all past samples or recomputing the mean from scratch is impractical in hardware-constrained systems. Therefore, an efficient running mean algorithm is required.

## Running Mean Definition

For a sequence of samples, the mean after processing N samples is defined as:

μᵢ = (1 / Nᵢ) · Σ(xₖ),  k = 1 to Nᵢ

where:
- xₖ is the input sample
- Nᵢ is the current sample count

## Welford’s Algorithm

To efficiently compute the running mean in hardware, this design uses **Welford’s algorithm**, which is numerically stable and well-suited for fixed-point arithmetic. Instead of accumulating large sums, the algorithm maintains a shifting origin and a bounded residual.

### Update Equations

The running mean is updated using the following steps:


Pᵢ′ = Pᵢ₋₁ + (xᵢ − mᵢ₋₁)

Δm = [Pᵢ′ / Nᵢ]

mᵢ = mᵢ₋₁ + Δm

Pᵢ = Pᵢ′ − Nᵢ · Δm

### Parameters

- xᵢ   : Current input sample  
- mᵢ  : Integer-shifted mean  
- Pᵢ  : Corrected residual sum  
- Nᵢ  : Sample count  
- [] : Floor operation enforcing integer division  

The intermediate partial sum P_i' accumulates the deviation from the current origin.  
The shift delta_m keeps the origin close to the true mean, preventing large numerical growth.

## Mean Approximation

The running mean can be approximated as:

μᵢ = mᵢ + (Pᵢ / Nᵢ)

This representation separates the mean into:
- An integer component (mᵢ)
- A fractional correction term (Pᵢ / Nᵢ)

The fractional term remains bounded within ±0.5, ensuring numerical stability and preventing overflow.

## Hardware Advantages

- Uses only integer arithmetic  
- Avoids large accumulators  
- Numerically stable for long data streams  
- Suitable for low-power FPGA and ASIC implementations  

This makes Welford’s algorithm ideal for real-time, streaming hardware designs.

# Division by Next Power-of-Two Operator

Division is one of the most expensive arithmetic operations in digital hardware. Conventional division algorithms such as restoring, non-restoring, and SRT division require complex control logic, iterative subtraction, and long critical paths, especially for large data widths.

In many embedded, signal processing, and edge computing applications, exact division is not always required. Approximate division with bounded error is often sufficient and enables significant hardware savings.

## Power-of-Two Approximation

An efficient alternative to conventional division is to approximate the divisor using the nearest power-of-two. This reduces the division operation to a simple right-shift, which is significantly faster and more resource-efficient in hardware.

A / B ≈ A >> k,  where 2^k ≈ B


## Hardware Implementation

The division-by-power-of-two operator is implemented using:
- Priority encoders to detect the leading one position
- Shift-add logic to approximate the quotient
- Simple combinational logic without iterative loops

This approach avoids:
- Iterative subtraction
- Complex quotient selection logic
- Long combinational paths



<img width="417" height="357" alt="image" src="https://github.com/user-attachments/assets/6ac4c4c2-779b-4c0d-a008-5ad5eb6ff8ce" />


## Advantages

- Very low LUT and FF utilization  
- Short critical path  
- Deterministic latency  
- Well-suited for FPGA-based streaming systems  

## Use Case in This Project

In the running mean computation, division is required to calculate the mean shift term. Using a power-of-two approximation significantly reduces hardware complexity while maintaining sufficient accuracy for real-time anomaly detection and signal monitoring applications.

This makes the operator ideal for low-power, resource-constrained FPGA designs.



