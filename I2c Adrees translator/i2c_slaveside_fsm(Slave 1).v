
`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 15.09.2025 16:03:21
// Design Name: 
// Module Name: i2c_slaveside_fsm
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////
module i2c_slaveside_fsm(
   inout wire  sda,
   inout wire  scl,
   output reg [7:0] data_in
    );
    
    localparam Address = 7'h48;
    
    reg[6:0] addr;
    reg rw_bit;
    reg[3:0] counter;
    reg[3:0] state;
    reg[7:0] data_in = 0;
    reg[7:0] data_out = 8'b11111111; // data to send 
    reg sda_out=1;
    reg write_enable = 0;          //sda_drive
    reg start = 0;
    
    assign sda = (write_enable &&(sda_out == 1'b0)) ? 1'b0 : 1'bz;
    //assign data_in = data_in_reg;
    always @(negedge sda)begin  //start condition
       if((start == 0)&&(scl == 1))begin
         start <= 1;
         counter<=6;
         state<= 0;
         write_enable <=0;    
       end 
    end
    
    always @(posedge sda) begin
        if (scl == 1) begin
           start <= 0;
           state <= 0;
           //i2c_scl <= 1;
           write_enable <=0;
        end
     end      
          always @(negedge scl)begin
             if(start == 1 )begin
            case(state)
               
                0:begin  //Read Address state 
                   addr[counter]<=sda;
                   if(counter == 0) begin 
                     state<=1;
                   end  else begin 
                    counter <= counter -1; 
                   end
                  end 
                  
                
                
                1:begin   //Read or Write  state
                  rw_bit<=sda;
                  state <= 2;
                  
                end
                
                2:begin //Senf ACK state
                   if(addr == Address) begin
                     sda_out<=0;
                     write_enable<=1;
                     counter<=7;
                     if(rw_bit == 0) state<= 3;
                     else state<= 4 ;
                   end
                 else begin
                   sda_out<=1;      //NACK
                   write_enable<=1;  
                   state <= 0;
                 end   
                end 
                
                3:begin  
                   data_in[counter]<=sda;
                   if(counter == 0) begin
                    state<= 5 ;
                   end else begin 
                   counter <= counter -1;
                end
                end
                4:begin 
                   if(counter == 0) begin
                    state<=6 ;
                   end else begin
                   counter <= counter -1;
                  end 
                end
                
                
                
                5:begin //state Data trasfer complete
                  sda_out<=0;
                  write_enable<=1;
                  state <= 7;
                end
                
                6:begin  //read complete
                  sda_out <=1;
                  write_enable <=1;
                  state <=7;
                  
                 end
                 
                7:begin
                    write_enable<=0;
                    state<=0;
                end    
                 
                     
                
                
                
             endcase 
          end
       end
       
       always @(negedge scl)begin
        case(state)
         // 0:begin
          //  write_enable<=0;
          //end
          
          //1:begin
          //  write_enable<=0;
         // end
          
          2:begin    //ack
            sda_out<=0;
            write_enable<=1;
          end
          
          3:begin
            write_enable<=0;
          end
          
          4:begin
             sda_out <= data_out[counter];
             write_enable<=1;
            if(data_out[counter] == 1'b0) write_enable <=1;
            else write_enable <=0;
          end
          
          5:begin
            sda_out<=0;
            write_enable<=0;
          end
          
          
        endcase
      end                
endmodule



