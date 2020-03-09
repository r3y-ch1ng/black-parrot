/*
 * bp_fe_bht.v
 * 
 * Branch History Table (BHT) records the information of the branch history, i.e.
 * branch taken or not taken. 
 * Each entry consists of 2 bit saturation counter. If the counter value is in
 * the positive regime, the BHT predicts "taken"; if the counter value is in the
 * negative regime, the BHT predicts "not taken". The implementation of BHT is
 * native to this design.
*/
module bp_fe_bht
 import bp_fe_pkg::*; 
 #(parameter bht_idx_width_p = "inv"

   , localparam els_lp             = 2**bht_idx_width_p
   , localparam saturation_size_lp = 2
   , localparam concat_idx_lp      = 2
   )
  (input                         clk_i
   , input                       reset_i
    
   , input                       w_v_i
   , input [bht_idx_width_p-1:0] idx_w_i
   , input                       correct_i
 
   , input                       r_v_i   
   , input [bht_idx_width_p-1:0] idx_r_i
   , output                      predict_o
   );

logic [els_lp-1:0][saturation_size_lp-1:0] mem;
logic [concat_idx_lp-1:0] branch_history;
logic [bht_idx_width_p-1:0] g_shared_idx_r;
logic [bht_idx_width_p-1:0] g_shared_idx_w;

assign g_shared_idx_r = {idx_r_i[(bht_idx_width_p-1) -: bht_idx_width_p-concat_idx_lp],branch_history};
assign g_shared_idx_w = {idx_w_i[(bht_idx_width_p-1) -: bht_idx_width_p-concat_idx_lp],branch_history}; 

assign predict_o = r_v_i ? mem[g_shared_idx_r][1] : 1'b0;

always_ff @(posedge clk_i) 
  if (reset_i) begin
    mem <= '{default:2'b01};
    branch_history <= '0;
  end
  else if (w_v_i) 
    begin
      branch_history <= (branch_history << 1) + correct_i; 
      //2-bit saturating counter(high_bit:prediction direction,low_bit:strong/weak prediction)
      case ({correct_i, mem[g_shared_idx_w][1], mem[g_shared_idx_w][0]})
        //wrong prediction
        3'b000: mem[g_shared_idx_w] <= {mem[g_shared_idx_w][1]^mem[g_shared_idx_w][0], 1'b1};//2'b01
        3'b001: mem[g_shared_idx_w] <= {mem[g_shared_idx_w][1]^mem[g_shared_idx_w][0], 1'b1};//2'b11
        3'b010: mem[g_shared_idx_w] <= {mem[g_shared_idx_w][1]^mem[g_shared_idx_w][0], 1'b1};//2'b11
        3'b011: mem[g_shared_idx_w] <= {mem[g_shared_idx_w][1]^mem[g_shared_idx_w][0], 1'b1};//2'b01
        //correct prediction
        3'b100: mem[g_shared_idx_w] <= mem[g_shared_idx_w];//2'b00
        3'b101: mem[g_shared_idx_w] <= {mem[g_shared_idx_w][1], ~mem[g_shared_idx_w][0]};//2'b00
        3'b110: mem[g_shared_idx_w] <= mem[g_shared_idx_w];//2'b10
        3'b111: mem[g_shared_idx_w] <= {mem[g_shared_idx_w][1], ~mem[g_shared_idx_w][0]};//2'b10
      endcase
    end

endmodule
