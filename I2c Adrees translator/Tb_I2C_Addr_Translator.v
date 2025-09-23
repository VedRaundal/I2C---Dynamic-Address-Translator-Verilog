`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12.09.2025 23:48:42
// Design Name: 
// Module Name: Tb_I2C_Addr_Translator
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
module Tb_I2C_Addr_Translator;
  reg clk;
  reg reset;
  reg rw;
  reg Slave_sel;
  wire txn_done;
  wire [7:0] slave1_data,slave2_data;
  //wire i2c_sda;
  //wire i2c_scl;
  //wire i2c_clk;
  //wire txn_done;
  //pullup(i2c_sda);
  //pullup(i2c_scl);
  
   i2c_transltor_top dut(
          .ref_clk(clk),
          .reset(reset),
          .rw(rw),
          .Slave_sel(Slave_sel),
          .txn_done(txn_done),
          .recevied_data_slave1(slave1_data),
          .recevied_data_slave2(slave2_data)
   
   );  
  
  
  //i2c_clk_divider  instance_name (
  //             .reset(reset),
  //             .ref_clk(clk),
   //            .i2c_clk(i2c_clk)  
 // );
 // I2C_materside_fsm uut(
      //        .clk(i2c_clk),
      //        .reset(reset),
       //       .i2c_sda(i2c_sda),
       //       .i2c_scl(i2c_scl),
       //       .rw(rw),
        //      .Slave_sel(Slave_sel),
        //      .txn_done(txn_done)
              
              
              
              
  //);
 // i2c_slaveside_fsm slave1(
            //   .sda(i2c_sda),
            //   .scl(i2c_scl),
          //     .data_in(slave1_data)
 // );
  //i2c_slave2_fsm slave2(
           //    .sda(i2c_sda),    
            //   .scl(i2c_scl),
            //   .data_in(slave2_data)
 // );
  //wire [7:0] slave1_data,slave2_data;
  initial begin
   clk=0;
   forever begin
      clk = #5 ~clk;
      end
  end
  initial begin
    reset = 1;
    rw = 0;
    Slave_sel = 0;     
    #20000;
    
    reset = 0;
    
    
    rw = 0;
    Slave_sel = 0;
    @(posedge txn_done);
    
   // #50000;
    
    rw= 1;
    Slave_sel = 0;
    @(posedge txn_done);
    //#50000;
    
    rw = 0;
    Slave_sel = 1;
    @(posedge txn_done);
    //#50000;
    
    rw = 1;
    Slave_sel = 1;
    @(posedge txn_done);
    //#50000;
    

    #10000000;
    $finish;
  end
  
endmodule
