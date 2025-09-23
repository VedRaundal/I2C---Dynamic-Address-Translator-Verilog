`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 22.09.2025 18:29:32
// Design Name: 
// Module Name: i2c_address_translator_fsm
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


module i2c_address_translator_fsm(

    input wire clk,
      input wire reset,
      input wire rw,  // 0 = write , 1= read
      input wire Slave_sel,
      input wire start_transaction,
      
      inout wire master_sda,
      inout wire master_scl,
      
      inout wire Slave1_sda,
      inout wire Slave1_scl,
      inout wire Slave2_sda,
      inout wire Slave2_scl,
      
      output reg txn_done //tranxtion done 
      
       
      
);
    //parameter Slave1_addr = 7'h50;
    //parameter Slave2_addr = 7'h60;
    reg [7:0] state;
    reg [6:0] received_addr;
    reg [7:0] count;
    reg [7:0] data_in;
    reg [7:0] data_out;
    reg rw_bit;
    
    reg master_sda_out = 1;
    reg master_sda_drive = 0;
    reg master_scl_out = 1;
    reg master_scl_drive = 0;
    
    reg target_device;
    reg start_detected = 0;
    
    
    assign master_scl = master_scl_drive ? master_scl_out : 1'bz;
    assign master_sda = (master_sda_drive && (master_sda_out == 1'b0)) ? 1'b0 :1'bz;
    
    
    
    always @(negedge master_sda or posedge reset)begin       // start 
       if(reset)begin
           start_detected <= 0;
           state <= 0;
           count <= 6;
           master_sda_drive <=0;
         end else if(master_scl == 1 && start_detected == 0)begin
           start_detected <=1;
           state <=0;
           count<=6;
           txn_done<=0;
           master_sda_drive <=0 ;
         end  
       end    
    
    always @(posedge master_sda or posedge reset) begin     //Stop
        if (reset) begin
           start_detected <= 0;
           state <= 0;
           count <= 6;
           txn_done <= 0; 
           master_sda_drive<=0;
        end else if(master_scl == 1)begin
           start_detected <=0;
           state <=0;
           count <= 6;
           txn_done <=0;
           master_sda_drive <=0;
         end  
      end
          
     always @(negedge master_scl)begin     
          if(reset)begin
              state<=0;
              master_sda_out <=1;
              master_sda_drive <=0;
              master_scl_out <=1;
              master_scl_drive <=0;
              txn_done<=0;
              received_addr<=7'h00;
              count<=7'd0;
              data_in<=8'd0;
              rw_bit<=0;
              target_device <=0;
              start_detected<=0;
             end
            else if(start_detected)begin  
           
          
          case(state)
               
                0:begin   //adress
                   received_addr[count]<=master_sda;
                   
                   
                   if (count == 0)
                     state <= 1;
                   else
                     count <=count -1;
                  
                end
                
                1:begin   //rw bit  
                   rw_bit <=master_sda;
                   state <= 2;
                 
                end
                
                2:begin //send ACK

                   if(received_addr == 7'h48)begin
                     master_sda_out<=0;
                     master_sda_drive <=1;
                     target_device <= Slave_sel;
                     count<=7;
                     if(rw_bit == 0)begin
                      state<=3;
                     end else begin
                      state <=4;
                     end
                      
                   end else begin 
                      master_sda_out<=1;
                      master_sda_drive<=1;
                      state<=0;
                    end  
                end
                
                3:begin //write 
                   data_in[count]<=master_sda;
                   if(count == 0)begin
                    state<=5;
                   end else begin
                    count <= count -1;
                   end
                  end     

                
                4:begin //read
                  if(count ==0 )begin
                    state<=6 ;
                   end else begin
                    count <= count -1 ;
                   end
                 end   

                5:begin //Send data complete
                   master_sda_out <=0;
                   master_sda_drive <=1;
                   txn_done <=1;
                   state<= 7;
                  end 

                6:begin //state Data read trasfer complete
                  master_sda_out <=1;
                  master_sda_drive<=1;
                  txn_done <=1;
                  state <= 7;
                end
                
                7:begin // complete 
                  //sda_out <= 1'b1;
                  master_sda_drive <= 0;
                  state <=0;
                 end

             endcase 
          end
       end
       
      always @(posedge master_scl) begin
         if(state == 4 && rw_bit==1)begin
         if(target_device == 0)begin
           master_sda_out<= Slave1_sda;
         end else begin
           master_sda_out <= Slave2_sda;
         end   
           master_sda_drive <=1;
            end
         end
endmodule



