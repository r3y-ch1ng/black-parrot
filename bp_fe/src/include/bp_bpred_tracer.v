
module bp_bpred_tracer
  import bp_common_pkg::*;
  import bp_common_aviary_pkg::*;
  import bp_common_rv64_pkg::*;
  #(parameter bp_params_e bp_params_p = e_bp_inv_cfg
  `declare_bp_proc_params(bp_params_p)

    , parameter trace_file_p = "branch_predict"
    )
   (  input                     clk_i
    , input                     reset_i
    , input                     is_br
    , input [vaddr_width_p-1:0] br_target                                  
    , input                     ovr_taken
    , input                     ovr_ntaken
    );

  string file_name;
  integer file;

  always_ff @(negedge reset_i) 
    begin
      file_name = $sformatf("%s.trace", trace_file_p);
      file = $fopen(file_name, "w");
    end

  always_ff @(negedge clk_i)
    if (is_br)
      begin
        $fwrite(file, " [br_target] = %x [ovr_taken] = %x [ovr_ntaken] = %x ", br_target, ovr_taken, ovr_ntaken);
        $fwrite(file, "\n");
      end

endmodule

