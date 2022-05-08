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

#include <stdio.h>
#include "altera_avalon_uart_regs.h"
#include "sys/alt_stdio.h"
#include "system.h"
#include <string.h>


#define STATUS_REG_ADDR 0
#define CTRL_REG_ADDR 1
#define SEQ_ADDR_REG_ADDR 2
#define SEQ_DATA_REG_ADDR 3
#define SEQ_SIZE_REG_ADDR 4
#define CLK_DIV_CNT_REG_ADDR 5

void control_set(int data, int offset)
{
	IOWR(MYIP_0_BASE, offset, data);
}



int main()
{
  printf("Hello from Nios II!\n");
  int i;
  int x = 0;
  char xd;
  char readStr[17];
  int y = 1;
  char *cmd_ptr = "1234xd";
  char *p;
  char temporary[1];
  char buffer[] = { '1','2','3','4','x','d'};
  char CMD1[1];
  char CMD2[8];
  char CMD3[7];
  int index = 0;
  int commandNumber = 0;
  int command2Number = 0;
  int command3Number = 0;
  alt_u8 status;
  IOWR_ALTERA_AVALON_UART_CONTROL(UART_0_BASE,0x0);
  	IOWR_ALTERA_AVALON_UART_STATUS(UART_0_BASE,0x0);


  	//test_convertation
  	char testcmd1[1] = {'1',};
  	char testcmd3[8] = {'0','1','2','3','4','5','6','7'};
  	char testcmd2[6] = {'0','0','0','1','2','5'};

  	int convertion1 =  testcmd1[0] - '0';

	int convertion2 = atoi(testcmd2);
	 int tick_num = 0;
	 int idle_flag= 0 ;
int j;
	//convertion 3 is not possible, too big

	//long convertion3 = strtoul(testcmd3);
  while(1)
  {


	    status= IORD_ALTERA_AVALON_UART_STATUS(UART_0_BASE) & 128;
	    //status = status & 128;
		  if(x>16)
		  {
			  x = 0;
			  commandNumber = 0;
			  command2Number = 0;
			  command3Number = 0;
			  for(index=0; index<17; index++)
			  {
				  if(readStr[index] == 'n')
				  {
					  commandNumber++;
					  index++;
				  }
				  switch(commandNumber)
				  {
				  case 0:
					  CMD1[0] = readStr[index];
					  break;
				  case 1:
					  CMD2[command2Number++] = readStr[index];
					  break;
				  case 2:
					  CMD3[command3Number++] = readStr[index];
					  break;
				  }
			  }
			  CMD3[6]='\0';
			  tick_num= atoi(CMD3);// max 125 min 208333
			  idle_flag= CMD1[0]- '0';// flag idle


			  if(idle_flag == 1)
			  {
				  control_set(0, CTRL_REG_ADDR);
				  //sequence
				control_set(0,SEQ_ADDR_REG_ADDR);
				control_set(8,SEQ_SIZE_REG_ADDR);
				for (j=0;j<8;j++){
					control_set((CMD2[j]- '0'),SEQ_DATA_REG_ADDR);
			  }
				//ticks number

				control_set(tick_num,CLK_DIV_CNT_REG_ADDR);
				int testingStatus = IORD(MYIP_0_BASE,STATUS_REG_ADDR);
				int testingWriteTicks = IORD(MYIP_0_BASE, CLK_DIV_CNT_REG_ADDR);
				int testingSeqSize = IORD(MYIP_0_BASE, SEQ_SIZE_REG_ADDR);
				int testingSeqAddr = IORD(MYIP_0_BASE, SEQ_ADDR_REG_ADDR);
				int testingSeqCtlr = IORD(MYIP_0_BASE, CTRL_REG_ADDR);


				// control_set(0, SEQ_ADDR_REG_ADDR);
/*				 for (j=0; j<8;j++)
				 {
					 control_set(j, SEQ_ADDR_REG_ADDR);
					 int numberBit = IORD(MYIP_0_BASE, SEQ_DATA_REG_ADDR);

					 int xd = 0;
				 }
*/
				//start
				control_set(1, CTRL_REG_ADDR);
				 testingSeqCtlr = IORD(MYIP_0_BASE, CTRL_REG_ADDR);
				testingStatus = IORD(MYIP_0_BASE,STATUS_REG_ADDR);
				int xd = 0;
			  }
			  else{
				  control_set(0, CTRL_REG_ADDR);
			  }
			  command3Number = 0;//only for debuggin






		  }
		if((status)==ALTERA_AVALON_UART_STATUS_RRDY_MSK	){	// check if reception ready{


			readStr[x]=IORD_ALTERA_AVALON_UART_RXDATA(UART_0_BASE);
			status= IORD_ALTERA_AVALON_UART_STATUS(UART_0_BASE) & 128;			//update status register
			if(readStr[x] != '\r')
			{
				//readStr[x]=IORD_ALTERA_AVALON_UART_RXDATA(UART_0_BASE);//receive character
				//status= IORD_ALTERA_AVALON_UART_STATUS(UART_0_BASE) & 128;			//update status register
				x++;
			}
			}


  }

  return 0;
}
