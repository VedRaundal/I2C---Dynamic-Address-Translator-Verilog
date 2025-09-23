`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Module Name: I2C_materside_fsm
// Description:
// Master FSM driving I2C bus signals with tri-state outputs:
//  - sda_out, sda_drive control SDA line
//  - scl_out, scl_drive control SCL line
// State machine controls I2C write/read transactions
//////////////////////////////////////////////////////////////////////////////////
module I2C_materside_fsm(
    input wire clk,
      input wire reset,
      input wire rw,  // 0 = write , 1= read
      input wire Slave_sel,
      inout wire i2c_sda,
      inout wire i2c_scl,
      output reg txn_done //tranxtion done 
      
       
      
);
    //parameter Slave1_addr = 7'h50;
    //parameter Slave2_addr = 7'h60;
    reg [7:0] state;
    reg [6:0] Addr;
    reg [7:0] count;
    reg [7:0] data_in;
    reg [7:0] data_out;
    
    
    reg i2c_scl_enable = 0;
    reg sda_out = 1;
    reg sda_drive = 0;
    
    
    assign i2c_scl = (i2c_scl_enable == 0) ? 1 : ~clk;
    assign i2c_sda = (sda_drive && (sda_out == 1'b0)) ? 1'b0 :1'bz;
    
    
    
    always @(negedge clk or posedge reset)begin
       if(reset == 1)begin
         i2c_scl_enable <= 0;
       end else begin
         if((state == 0) || (state == 1) || (state == 7)) begin
           i2c_scl_enable <= 0;
         end 
         else  
           i2c_scl_enable <= 1;
         end
       
    end
    
    always @(negedge clk or posedge reset) begin
        if (reset == 1) begin
           state <= 0;
           sda_out<=1;
           sda_drive<=0;
           txn_done <=0;
           //i2c_scl <= 1;
           Addr <= 7'h48;  //for address 0x50
           count <= 8'd0;
           data_out <= 8'haa;
           data_in <= 8'd0;
           
           
          end
          else begin
           
          
          case(state)
               
                0:begin  //ideal state 
                   sda_out <= 1;
                   sda_drive<=0;
                   txn_done<=0;
                   
                   
                   //if (Slave_sel == 0)
                     Addr<=7'h48;
                   //else
                    // Addr<=7'h60;
                   state <= 1;
                  
                end
                
                1:begin   //start state
                
                  
                     
                  sda_out<= 1'b0;
                  sda_drive<=1;
                  state <= 2;
                  count<=6;
                end
                
                2:begin //msb address state
                  
                   sda_out <= Addr[count]; 
                   sda_drive<=1;
                  
                   
                   
                   if(count ==0)state <= 3;
                   else count <=count -1 ;
                end
                
                3:begin //read and write 
                  
                  
                   sda_out <= rw;   
                   sda_drive <=1;
                   state <=4;
                end
                
                4:begin //state ACK
                   //i2c_sda <= 1;
                   sda_drive<=0;
                   if(rw == 0)begin
                     state <= 5;
                     count <=7;
                   end else begin
                     count <=7;
                     state <=7;
                   end
                end
                5:begin //Send data state
                 //if(rw == 0)begin
                   
                     sda_out<=data_out[count];
                     sda_drive<=1;
                   
                     
                   if(count == 0) state<= 6;
                  else count <= count - 1 ;
                end 
                //else begin
                     
                   //sda_out <= 0;
                  // sda_drive <=0 ;    // slave will pull sda to high
                  // data_in[count] <= i2c_sda;
                   //if(count == 0) state <= 6;
                   //else count <= count - 1;
                 //end   
                //end     
                
                6:begin //state Data trasfer complete
                  //state <= 7;
                  sda_drive<=0;
                  txn_done <=1;
                  state <= 9;
                end
                
                7:begin //State read data 
                  //sda_out <= 1'b1;
                  sda_drive <= 0;
                  if(count == 0) state <=8 ;
                  else count <= count -1;
                  
                  //state<= 0;
                end
                
                8:begin   // read ACk
                   sda_out <=0;
                   sda_drive <=1;
                   txn_done<=1;
                   state <= 9;
                end
                 9:begin
                   state <=10;
                 end
                 10:begin
                    sda_out<=1;
                    sda_drive<=0;
                    state <=0;
                 end   
                      
                 
                   
             endcase 
          end
       end
       
      always @(posedge i2c_scl) begin
         if(state == 7 && rw==1)begin
           data_in[count] <= i2c_sda;
            end
         end
endmodule

