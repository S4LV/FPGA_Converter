module top_level_verilog
	(
		////////////////////	Clock Input	 	////////////////////	 
		CLOCK_50,						//	50 MHz
		CLOCK_50_2,						//	50 MHz
		////////////////////	Push Button		////////////////////
		ORG_BUTTON,						//	Pushbutton[2:0]
		////////////////////	DPDT Switch		////////////////////
		SW								//	Toggle Switch[9:0]
		);
		
		input			CLOCK_50;				//	50 MHz
input			CLOCK_50_2;				//	50 MHz
////////////////////////	Push Button		////////////////////////
input	[2:0]	ORG_BUTTON;				//	Pushbutton[2:0]
////////////////////////	DPDT Switch		////////////////////////
input	[9:0]	SW;						//	Toggle Switch[9:0]

    DEO_SALVA u0 (
        .clk_clk       (CLOCK_50),       //   clk.clk
        .reset_reset_n (SW[0])  // reset.reset_n
    );
	 
	 
endmodule