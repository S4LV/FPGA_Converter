/*
 * "Hello World" example.
 *
 * This example prints 'Hello from Nios II' to the STDOUT stream. It runs on
 * the Nios II 'standard', 'full_featured', 'fast', and 'low_cost' example
 * designs. It runs with or without the MicroC/OS-II RTOS and requires a STDOUT
 * device in your system's hardware.
 * The memory footprint of this hosted application is ~69 kbytes by default
 * using the standard reference design.
 *
 * For a reduced footprint version of this template, and an explanation of how
 * to reduce the memory footprint for a given application, see the
 * "small_hello_world" template.
 *
 */

#include <system.h>
#include "io.h"
# include "sys/alt_stdio.h"
#include "sys/alt_irq.h"
# include "altera_avalon_pio_regs.h"
# include "altera_avalon_timer_regs.h"

#define IRESETVAL 0 //Change the values if your register map is different thanhere
#define RESET_COMMAND 0
#define START_COMMAND 1
#define STOP_COMMAND 2
#define EN_IRQ_COMMAND 3
#define DIS_IRQ_COMMAND 4
#define CLR_END_CYCLE_COMMAND 5

#define COUNTER_REG_ADDR 0
#define COMMAND_REG_ADDR 1
#define STATUS_REG_ADDR 2
#define ARBITVAL 0X0000FFFF



#define DIRECTION_REG_ADDR 0
#define INPUT_PORT_REG_ADDR 1
#define OUTPUT_PORT_REG_ADDR 2
#define SET_REG_ADDR 3
#define CLR_REG_ADDR 4
#define IRQ_REG_ADDR 5
#define CLR_END_CYCLE_ADDR 6

#define MODE_ALL_OUTPUT 0xFF
#define MODE_ALL_INPUT 0X00
#define ALL_IRQ_EN 0XFF
#define ALL_IRQ_CLR 0xFF


static void isr_library_timer(void* context);
static void my_isr_custom_timer(void* context);
static void isr_parallel_port_responsive(void* context);
int flag;
int snap;


//3.2 Logic Analyzer measurement


void responsive_parallel()
{
	void *POINT_NULL;
	int k;
	 alt_ic_isr_register(CUSTOM_PIO_0_IRQ_INTERRUPT_CONTROLLER_ID,4,isr_parallel_port_responsive, POINT_NULL,POINT_NULL);
	 IOWR_8DIRECT(CUSTOM_PIO_0_BASE,DIRECTION_REG_ADDR,MODE_ALL_OUTPUT);
	 IOWR_8DIRECT(CUSTOM_PIO_0_BASE,DIRECTION_REG_ADDR,MODE_ALL_OUTPUT); //Selected as output
	 IOWR_8DIRECT(CUSTOM_PIO_0_BASE,OUTPUT_PORT_REG_ADDR,0x00);
	 IOWR_8DIRECT(CUSTOM_PIO_0_BASE,IRQ_REG_ADDR,ALL_IRQ_EN);//Enable IRQ on each bit
	while(1)
	{
	 IOWR_8DIRECT(CUSTOM_PIO_0_BASE,OUTPUT_PORT_REG_ADDR,0x01); //Bit1 is SET st IRQ
	}
}

static void isr_parallel_port_responsive(void* context)
{
 IOWR_8DIRECT(CUSTOM_PIO_0_BASE,OUTPUT_PORT_REG_ADDR,0);
 IOWR_8DIRECT(CUSTOM_PIO_0_BASE,CLR_END_CYCLE_ADDR,ALL_IRQ_CLR); //CLEAR IRQ
}

static void isr_parallel_port_recovery(void* context);
void recovery_parallel()
{
	void *POINT_NULL;
	int k;
	 alt_ic_isr_register(CUSTOM_PIO_0_IRQ_INTERRUPT_CONTROLLER_ID,4,isr_parallel_port_recovery, POINT_NULL,POINT_NULL);
//	 IOWR_8DIRECT(CUSTOM_PIO_0_BASE,DIRECTION_REG_ADDR,MODE_ALL_OUTPUT);
	 IOWR_8DIRECT(CUSTOM_PIO_0_BASE,DIRECTION_REG_ADDR,MODE_ALL_OUTPUT); //Selected as output
	 IOWR_8DIRECT(CUSTOM_PIO_0_BASE,OUTPUT_PORT_REG_ADDR,0x01);
	 IOWR_8DIRECT(CUSTOM_PIO_0_BASE,IRQ_REG_ADDR,ALL_IRQ_EN);//Enable IRQ on each bit
	while(1)
	{
	 IOWR_8DIRECT(CUSTOM_PIO_0_BASE,OUTPUT_PORT_REG_ADDR,0x00); //Bit0 is SET st IRQ
	}
}

static void isr_parallel_port_recovery(void* context)
{
 IOWR_8DIRECT(CUSTOM_PIO_0_BASE,OUTPUT_PORT_REG_ADDR,0x01);
 IOWR_8DIRECT(CUSTOM_PIO_0_BASE,CLR_END_CYCLE_ADDR,ALL_IRQ_CLR); //CLEAR IRQ
}


void analysis_setting_parallel_port()
{

	 IOWR_8DIRECT(CUSTOM_PIO_0_BASE,OUTPUT_PORT_REG_ADDR,MODE_ALL_OUTPUT);
	 //Select Parport as output
	 IOWR_8DIRECT(CUSTOM_PIO_0_BASE,OUTPUT_PORT_REG_ADDR,0x00);
	 while(1)
	 {
		 IOWR_8DIRECT(CUSTOM_PIO_0_BASE,OUTPUT_PORT_REG_ADDR,0x01);
		 IOWR_8DIRECT(CUSTOM_PIO_0_BASE,OUTPUT_PORT_REG_ADDR,0x00);
		 IOWR_8DIRECT(CUSTOM_PIO_0_BASE,OUTPUT_PORT_REG_ADDR,0x01);
		 IOWR_8DIRECT(CUSTOM_PIO_0_BASE,OUTPUT_PORT_REG_ADDR,0x00);
	 }

}
static void isr_latency_parallel(void* context);

void measure_latency_parallel()
{


	void *POINT_NULL;
	int k;
	 alt_ic_isr_register(CUSTOM_PIO_0_IRQ_INTERRUPT_CONTROLLER_ID,4,isr_latency_parallel, POINT_NULL,POINT_NULL);
	 IOWR_8DIRECT(CUSTOM_PIO_0_BASE,DIRECTION_REG_ADDR,MODE_ALL_OUTPUT);
	 IOWR_8DIRECT(CUSTOM_PIO_0_BASE,DIRECTION_REG_ADDR,MODE_ALL_OUTPUT); //Selected as output
	 IOWR_8DIRECT(CUSTOM_PIO_0_BASE,OUTPUT_PORT_REG_ADDR,0x00);
	 IOWR_8DIRECT(CUSTOM_PIO_0_BASE,IRQ_REG_ADDR,ALL_IRQ_EN);//Enable IRQ on each bit
	while(1)
	{
	 IOWR_8DIRECT(CUSTOM_PIO_0_BASE,OUTPUT_PORT_REG_ADDR,0x01); //Bit1 is SET st IRQ
	}


}


static void isr_latency_parallel(void* context)
{
 IOWR_8DIRECT(CUSTOM_PIO_0_BASE,CLR_END_CYCLE_ADDR,ALL_IRQ_CLR); //CLEAR IRQ
}
int main()
{

//	test_parallel_port();
//	responsive_parallel();
//	recovery_parallel();
	measure_latency_parallel();

  return 0;
}
