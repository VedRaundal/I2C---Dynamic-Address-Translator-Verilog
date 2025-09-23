`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 22.09.2025 19:16:47
// Design Name: 
// Module Name: i2c_transltor_top
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


module i2c_transltor_top(
    input wire ref_clk,
    input wire reset,
    input wire rw,
    input wire Slave_sel,
    
     //inout wire Slave1_sda,
     // inout wire Slave1_scl,
     // inout wire Slave2_sda,
      //inout wire Slave2_scl,
      
      output wire[7:0] recevied_data_slave1,
      output wire[7:0] recevied_data_slave2,
      output wire txn_done
      
    );
    
    wire i2c_clk;
    wire master_txn_done;
    wire translator_txn_done;
    
    tri1 bus_sda;   // master -- translator
    tri1 bus_scl;
    
    tri1 Slave1_sda;
    tri1 Slave1_scl;
    tri1 Slave2_sda;
    tri1 Slave2_scl;
    
    pullup(bus_sda);
    pullup(bus_scl);
    pullup(Slave1_sda);
    pullup(Slave1_scl);
    pullup(Slave2_sda);
    pullup(Slave2_scl);
    
    
    i2c_clk_divider unit_div(
       .reset(reset),
       .ref_clk(ref_clk),
       .i2c_clk(i2c_clk)
    );
    
    I2C_materside_fsm unit_master(
              .clk(i2c_clk),
              .reset(reset),
              .i2c_sda(bus_sda),
              .i2c_scl(bus_scl),
              .rw(rw),
              .Slave_sel(Slave_sel),
              .txn_done(master_txn_done)     
    );
    
    i2c_address_translator_fsm unit_tran(
              .clk(i2c_clk),
              .reset(reset),
              .master_sda(bus_sda),
              .master_scl(bus_scl),
              .rw(rw),
              .start_transaction(1'b0),
              .Slave_sel(Slave_sel),
              .Slave1_sda(Slave1_sda),
              .Slave1_scl(Slave1_scl),
              .Slave2_sda(Slave2_sda),
              .Slave2_scl(Slave2_scl),
              .txn_done(translator_txn_done) 
    
    );
    
    i2c_slaveside_fsm slave1(
             .sda(Slave1_sda),
             .scl(Slave1_scl),
             .data_in(recevied_data_slave1)
    );
    
    i2c_slave2_fsm slave2(
             .sda(Slave2_sda),
             .scl(Slave2_scl),
             .data_in(recevied_data_slave2)
               
    );
    
    assign txn_done = master_txn_done | translator_txn_done;
    
endmodule
