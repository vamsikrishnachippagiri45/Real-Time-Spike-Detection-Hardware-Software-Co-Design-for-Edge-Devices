#include <stdio.h>
#include "platform.h"
#include "xil_printf.h"
#include "xparameters.h"
#include "xaxidma.h"
#include "xil_cache.h"
#include "glitch_data.h"

#define DMA_DEV_ID      XPAR_AXIDMA_0_DEVICE_ID
#define DDR_BASE_ADDR   XPAR_DDR_MEM_BASEADDR
#define TX_BUFFER_BASE  (DDR_BASE_ADDR + 0x01000000)
#define RX_BUFFER_BASE  (DDR_BASE_ADDR + 0x02000000)

#define NUM_SAMPLES     1024

XAxiDma AxiDma;
int init_dma()
{
    XAxiDma_Config *CfgPtr;
    int Status;

    CfgPtr = XAxiDma_LookupConfig(DMA_DEV_ID);
    if (!CfgPtr) {
        xil_printf("No DMA config found\r\n");
        return XST_FAILURE;
    }

    Status = XAxiDma_CfgInitialize(&AxiDma, CfgPtr);
    if (Status != XST_SUCCESS) {
        xil_printf("DMA init failed\r\n");
        return XST_FAILURE;
    }

    if (XAxiDma_HasSg(&AxiDma)) {
        xil_printf("DMA configured in SG mode\r\n");
        return XST_FAILURE;
    }

    return XST_SUCCESS;
}



int main()
{
    int Status;
    int i;

    init_platform();
    xil_printf("Glitch / Spike Detection Test\r\n");

    /* Initialize DMA */
    Status = init_dma();
    if (Status != XST_SUCCESS) {
        xil_printf("DMA init error\r\n");
        return XST_FAILURE;
    }

    u32 *TxBuffer = (u32 *)TX_BUFFER_BASE;
    u32 *RxBuffer = (u32 *)RX_BUFFER_BASE;
    
    for (int i = 0; i < NUM_SAMPLES; i++) {
        TxBuffer[i] = glitch_data[i];
        RxBuffer[i] = 0;
    }

    /* Flush cache */
    Xil_DCacheFlushRange((UINTPTR)TxBuffer, NUM_SAMPLES * sizeof(u32));
    Xil_DCacheFlushRange((UINTPTR)RxBuffer, NUM_SAMPLES * sizeof(u32));

    /* Start RX first */
    XAxiDma_SimpleTransfer(&AxiDma,
                           (UINTPTR)RxBuffer,
                           NUM_SAMPLES * sizeof(u32),
                           XAXIDMA_DEVICE_TO_DMA);

    /* Start TX */
    XAxiDma_SimpleTransfer(&AxiDma,
                           (UINTPTR)TxBuffer,
                           NUM_SAMPLES * sizeof(u32),
                           XAXIDMA_DMA_TO_DEVICE);

    /* Wait for completion */
    while (XAxiDma_Busy(&AxiDma, XAXIDMA_DMA_TO_DEVICE));
    while (XAxiDma_Busy(&AxiDma, XAXIDMA_DEVICE_TO_DMA));

    xil_printf("DMA transfer completed\r\n");

    /* Invalidate cache before reading */
    Xil_DCacheInvalidateRange((UINTPTR)RxBuffer, NUM_SAMPLES * sizeof(u32));

    /* Print first few outputs */
    for (i = 0; i < 10; i++) {
        xil_printf("Output[%d] = %d\r\n", i, RxBuffer[i]);
    }

    cleanup_platform();
    return 0;
}
