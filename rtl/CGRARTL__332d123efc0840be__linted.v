
typedef struct packed {
  logic [63:0] payload;
  logic [0:0] predicate;
} CGRAData_64_1__payload_64__predicate_1;

typedef struct packed {
  logic [5:0] ctrl;
  logic [0:0] predicate;
  logic [3:0][2:0] fu_in;
  logic [7:0][2:0] outport;
  logic [5:0][0:0] predicate_in;
  logic [5:0] out_routine;
} CGRAConfig_6_4_6_8_6__70c95bde83d8947c;

typedef struct packed {
  logic [0:0] predicate;
} CGRAData_1__predicate_1;


module NormalQueueCtrl__num_entries_2__dry_run_enable_True
(
  input  logic [0:0] clk ,
  input  logic [0:0] config_ini ,
  output logic [1:0] count ,
  input  logic [0:0] deq_en ,
  output logic [0:0] deq_valid ,
  input  logic [0:0] dry_run_done ,
  input  logic [0:0] enq_en ,
  output logic [0:0] enq_rdy ,
  output logic [0:0] raddr ,
  output logic [0:0] ren ,
  input  logic [0:0] reset ,
  input  logic [0:0] sync_dry_run ,
  output logic [0:0] waddr ,
  output logic [0:0] wen 
);
  logic [1:0] count_ini;
  logic [0:0] deq_xfer;
  logic [0:0] enq_xfer;
  logic [0:0] head;
  logic [0:0] head_ini;
  logic [0:0] tail;
  logic [0:0] tail_ini;

  
  always_comb begin : _lambda__s_tile_0__channel_0__queue_ctrl_deq_valid
    deq_valid = ( ~reset ) & ( count > 2'd0 );
  end

  
  always_comb begin : _lambda__s_tile_0__channel_0__queue_ctrl_deq_xfer
    deq_xfer = deq_en & deq_valid;
  end

  
  always_comb begin : _lambda__s_tile_0__channel_0__queue_ctrl_enq_rdy
    enq_rdy = ( ~reset ) & ( ( count + { { 1 { 1'b0 } }, enq_en } ) < 2'd2 );
  end

  
  always_comb begin : _lambda__s_tile_0__channel_0__queue_ctrl_enq_xfer
    enq_xfer = enq_en & enq_rdy;
  end

  
  always_ff @(posedge clk) begin : dry_run_reg
    if ( reset ) begin
      head_ini <= 1'd0;
      tail_ini <= 1'd0;
      count_ini <= 2'd0;
    end
    else if ( dry_run_done ) begin
      head_ini <= head;
      tail_ini <= tail;
      count_ini <= count;
    end
  end

  
  always_ff @(posedge clk) begin : sync
    if ( reset | config_ini ) begin
      head <= 1'd0;
      tail <= 1'd0;
      count <= 2'd0;
    end
    else if ( sync_dry_run & ( ~dry_run_done ) ) begin
      head <= head_ini;
      tail <= tail_ini;
      count <= count_ini;
    end
    else begin
      if ( deq_xfer ) begin
        head <= ( head < 1'd1 ) ? head + 1'd1 : 1'd0;
      end
      if ( enq_xfer ) begin
        tail <= ( tail < 1'd1 ) ? tail + 1'd1 : 1'd0;
      end
      if ( enq_xfer & ( ~deq_xfer ) ) begin
        count <= count + 2'd1;
      end
      if ( ( ~enq_xfer ) & deq_xfer ) begin
        count <= count - 2'd1;
      end
    end
  end

  assign wen = enq_xfer;
  assign ren = deq_xfer;
  assign waddr = tail;
  assign raddr = head;

endmodule



module NormalQueueDpath__667be9aa0698ac40
(
  input  logic [0:0] clk ,
  input  logic [0:0] config_ini ,
  output CGRAData_64_1__payload_64__predicate_1 deq_msg ,
  input  CGRAData_64_1__payload_64__predicate_1 enq_msg ,
  input  logic [0:0] raddr ,
  input  logic [0:0] ren ,
  input  logic [0:0] reset ,
  input  logic [0:0] waddr ,
  input  logic [0:0] wen 
);
  localparam logic [1:0] __const__num_entries_at_up_rf_write  = 2'd2;
  CGRAData_64_1__payload_64__predicate_1 regs [0:1];
  CGRAData_64_1__payload_64__predicate_1 regs_rdata;

  
  always_comb begin : reg_read
    if ( reset ) begin
      deq_msg = { 64'd0, 1'd0 };
    end
    else
      deq_msg = regs[raddr];
  end

  
  always_ff @(posedge clk) begin : up_rf_write
    if ( reset | config_ini ) begin
      for ( int unsigned i = 1'd0; i < 2'( __const__num_entries_at_up_rf_write ); i += 1'd1 )
        regs[1'(i)] <= { 64'd0, 1'd0 };
    end
    else if ( wen ) begin
      regs[waddr] <= enq_msg;
    end
  end

endmodule



module NormalQueue__89ec7419267774bb
(
  input  logic [0:0] clk ,
  input  logic [0:0] config_ini ,
  input  logic [0:0] deq_en ,
  output CGRAData_64_1__payload_64__predicate_1 deq_msg ,
  output logic [0:0] deq_valid ,
  input  logic [0:0] dry_run_done ,
  input  logic [0:0] enq_en ,
  input  CGRAData_64_1__payload_64__predicate_1 enq_msg ,
  output logic [0:0] enq_rdy ,
  input  logic [0:0] reset ,
  input  logic [0:0] sync_dry_run 
);

  logic [0:0] ctrl__clk;
  logic [0:0] ctrl__config_ini;
  logic [1:0] ctrl__count;
  logic [0:0] ctrl__deq_en;
  logic [0:0] ctrl__deq_valid;
  logic [0:0] ctrl__dry_run_done;
  logic [0:0] ctrl__enq_en;
  logic [0:0] ctrl__enq_rdy;
  logic [0:0] ctrl__raddr;
  logic [0:0] ctrl__ren;
  logic [0:0] ctrl__reset;
  logic [0:0] ctrl__sync_dry_run;
  logic [0:0] ctrl__waddr;
  logic [0:0] ctrl__wen;

  NormalQueueCtrl__num_entries_2__dry_run_enable_True ctrl
  (
    .clk( ctrl__clk ),
    .config_ini( ctrl__config_ini ),
    .count( ctrl__count ),
    .deq_en( ctrl__deq_en ),
    .deq_valid( ctrl__deq_valid ),
    .dry_run_done( ctrl__dry_run_done ),
    .enq_en( ctrl__enq_en ),
    .enq_rdy( ctrl__enq_rdy ),
    .raddr( ctrl__raddr ),
    .ren( ctrl__ren ),
    .reset( ctrl__reset ),
    .sync_dry_run( ctrl__sync_dry_run ),
    .waddr( ctrl__waddr ),
    .wen( ctrl__wen )
  );



  logic [0:0] dpath__clk;
  logic [0:0] dpath__config_ini;
  CGRAData_64_1__payload_64__predicate_1 dpath__deq_msg;
  CGRAData_64_1__payload_64__predicate_1 dpath__enq_msg;
  logic [0:0] dpath__raddr;
  logic [0:0] dpath__ren;
  logic [0:0] dpath__reset;
  logic [0:0] dpath__waddr;
  logic [0:0] dpath__wen;

  NormalQueueDpath__667be9aa0698ac40 dpath
  (
    .clk( dpath__clk ),
    .config_ini( dpath__config_ini ),
    .deq_msg( dpath__deq_msg ),
    .enq_msg( dpath__enq_msg ),
    .raddr( dpath__raddr ),
    .ren( dpath__ren ),
    .reset( dpath__reset ),
    .waddr( dpath__waddr ),
    .wen( dpath__wen )
  );


  assign ctrl__clk = clk;
  assign ctrl__reset = reset;
  assign dpath__clk = clk;
  assign dpath__reset = reset;
  assign dpath__config_ini = config_ini;
  assign ctrl__config_ini = config_ini;
  assign ctrl__dry_run_done = dry_run_done;
  assign ctrl__sync_dry_run = sync_dry_run;
  assign dpath__wen = ctrl__wen;
  assign dpath__ren = ctrl__ren;
  assign dpath__waddr = ctrl__waddr;
  assign dpath__raddr = ctrl__raddr;
  assign ctrl__enq_en = enq_en;
  assign enq_rdy = ctrl__enq_rdy;
  assign ctrl__deq_en = deq_en;
  assign deq_valid = ctrl__deq_valid;
  assign dpath__enq_msg = enq_msg;
  assign deq_msg = dpath__deq_msg;

endmodule



module ChannelRTL__511b7cda5540ec2e
(
  input  logic [0:0] clk ,
  input  logic [0:0] config_ini ,
  input  logic [0:0] dry_run_done ,
  input  logic [0:0] recv_en ,
  input  CGRAData_64_1__payload_64__predicate_1 recv_msg ,
  output logic [0:0] recv_rdy ,
  input  logic [0:0] reset ,
  input  logic [0:0] send_en ,
  output CGRAData_64_1__payload_64__predicate_1 send_msg ,
  output logic [0:0] send_valid ,
  input  logic [0:0] sync_dry_run 
);

  logic [0:0] queue__clk;
  logic [0:0] queue__config_ini;
  logic [0:0] queue__deq_en;
  CGRAData_64_1__payload_64__predicate_1 queue__deq_msg;
  logic [0:0] queue__deq_valid;
  logic [0:0] queue__dry_run_done;
  logic [0:0] queue__enq_en;
  CGRAData_64_1__payload_64__predicate_1 queue__enq_msg;
  logic [0:0] queue__enq_rdy;
  logic [0:0] queue__reset;
  logic [0:0] queue__sync_dry_run;

  NormalQueue__89ec7419267774bb queue
  (
    .clk( queue__clk ),
    .config_ini( queue__config_ini ),
    .deq_en( queue__deq_en ),
    .deq_msg( queue__deq_msg ),
    .deq_valid( queue__deq_valid ),
    .dry_run_done( queue__dry_run_done ),
    .enq_en( queue__enq_en ),
    .enq_msg( queue__enq_msg ),
    .enq_rdy( queue__enq_rdy ),
    .reset( queue__reset ),
    .sync_dry_run( queue__sync_dry_run )
  );


  assign queue__clk = clk;
  assign queue__reset = reset;
  assign queue__enq_en = recv_en;
  assign queue__enq_msg = recv_msg;
  assign recv_rdy = queue__enq_rdy;
  assign queue__deq_en = send_en;
  assign send_msg = queue__deq_msg;
  assign send_valid = queue__deq_valid;
  assign queue__config_ini = config_ini;
  assign queue__dry_run_done = dry_run_done;
  assign queue__sync_dry_run = sync_dry_run;

endmodule



module RegisterFile__8c50dafb5bf22f7b
(
  input  logic [0:0] clk ,
  input  logic [4:0] raddr [0:0],
  output logic [31:0] rdata [0:0],
  input  logic [0:0] reset ,
  input  logic [4:0] waddr [0:0],
  input  logic [31:0] wdata [0:0],
  input  logic [0:0] wen [0:0]
);
  localparam logic [0:0] __const__rd_ports_at_up_rf_read  = 1'd1;
  localparam logic [0:0] __const__wr_ports_at_up_rf_write  = 1'd1;
  logic [31:0] regs [0:31];

  
  always_comb begin : up_rf_read
    for ( int unsigned i = 1'd0; i < 1'( __const__rd_ports_at_up_rf_read ); i += 1'd1 )
      rdata[1'(i)] = regs[raddr[1'(i)]];
  end

  
  always_ff @(posedge clk) begin : up_rf_write
    for ( int unsigned i = 1'd0; i < 1'( __const__wr_ports_at_up_rf_write ); i += 1'd1 )
      if ( wen[1'(i)] ) begin
        regs[waddr[1'(i)]] <= wdata[1'(i)];
      end
  end

endmodule



module ConstQueueRTL__a158caae8f1a5180
(
  input  logic [0:0] clk ,
  input  logic [0:0] config_ini ,
  input  logic [0:0] dry_run_done ,
  input  logic [0:0] execution_ini ,
  input  logic [31:0] recv_const ,
  input  logic [0:0] recv_const_en ,
  input  logic [4:0] recv_const_waddr ,
  input  logic [0:0] reset ,
  input  logic [0:0] send_const_en ,
  output logic [31:0] send_const_msg 
);
  localparam logic [5:0] __const__const_mem_size_at_dry_run_th  = 6'd32;
  logic [5:0] data_counter;
  logic [5:0] data_counter_th;
  logic [5:0] data_counter_th_ini;

  logic [0:0] reg_file__clk;
  logic [4:0] reg_file__raddr [0:0];
  logic [31:0] reg_file__rdata [0:0];
  logic [0:0] reg_file__reset;
  logic [4:0] reg_file__waddr [0:0];
  logic [31:0] reg_file__wdata [0:0];
  logic [0:0] reg_file__wen [0:0];

  RegisterFile__8c50dafb5bf22f7b reg_file
  (
    .clk( reg_file__clk ),
    .raddr( reg_file__raddr ),
    .rdata( reg_file__rdata ),
    .reset( reg_file__reset ),
    .waddr( reg_file__waddr ),
    .wdata( reg_file__wdata ),
    .wen( reg_file__wen )
  );


  
  always_ff @(posedge clk) begin : dry_run_th
    if ( reset | config_ini ) begin
      data_counter_th <= 6'( __const__const_mem_size_at_dry_run_th ) + 6'd1;
    end
    else if ( dry_run_done ) begin
      data_counter_th <= data_counter;
    end
    else if ( execution_ini ) begin
      data_counter_th <= data_counter_th_ini;
    end
  end

  
  always_ff @(posedge clk) begin : dry_run_th_reg
    if ( reset | config_ini ) begin
      data_counter_th_ini <= 6'd0;
    end
    else if ( dry_run_done ) begin
      data_counter_th_ini <= data_counter;
    end
  end

  
  always_ff @(posedge clk) begin : update_raddr
    if ( reset | execution_ini ) begin
      data_counter <= 6'd0;
    end
    else if ( send_const_en ) begin
      if ( ( data_counter + 6'd1 ) == data_counter_th ) begin
        data_counter <= 6'd0;
      end
      else
        data_counter <= data_counter + 6'd1;
    end
  end

  assign reg_file__clk = clk;
  assign reg_file__reset = reset;
  assign reg_file__waddr[0] = recv_const_waddr;
  assign reg_file__wdata[0] = recv_const;
  assign reg_file__wen[0] = recv_const_en;
  assign reg_file__raddr[0] = data_counter[4:0];
  assign send_const_msg = reg_file__rdata[0];

endmodule



module CrossbarRTL__9e234a3e66000aaa
(
  input  logic [0:0] clk ,
  input  logic [2:0] recv_opt_msg_outport [0:7],
  input  logic [5:0] recv_opt_msg_predicate_in ,
  input  CGRAData_64_1__payload_64__predicate_1 recv_port_data [0:5],
  output logic [0:0] recv_port_fu_out_ack ,
  output logic [3:0] recv_port_mesh_in_ack ,
  input  logic [5:0] recv_port_valid ,
  input  logic [0:0] reset ,
  output logic [3:0] send_bypass_data_valid ,
  input  logic [3:0] send_bypass_port_ack ,
  output logic [3:0] send_bypass_req ,
  output CGRAData_64_1__payload_64__predicate_1 send_data_bypass [0:3],
  output CGRAData_64_1__payload_64__predicate_1 send_port_data [0:7],
  output logic [8:0] send_port_en ,
  input  logic [7:0] send_port_rdy ,
  output CGRAData_1__predicate_1 send_predicate ,
  input  logic [0:0] send_predicate_rdy ,
  input  logic [0:0] xbar_dry_run_ack ,
  input  logic [0:0] xbar_dry_run_begin ,
  input  logic [0:0] xbar_opt_enable ,
  input  logic [0:0] xbar_propagate_en ,
  output logic [0:0] xbar_propagate_rdy 
);
  localparam logic [1:0] __const__STAGE_NORMAL  = 2'd0;
  localparam logic [1:0] __const__STAGE_WAIT_FOR_NOC  = 2'd2;
  localparam logic [1:0] __const__STAGE_WAIT_FOR_FU  = 2'd3;
  localparam logic [1:0] __const__STAGE_WAIT_FOR_DST  = 2'd1;
  localparam logic [3:0] __const__num_xbar_outports_at_decode_process  = 4'd8;
  localparam logic [2:0] __const__num_xbar_inports_at_decode_process  = 3'd6;
  localparam logic [3:0] __const__num_xbar_outports_at_opt_propagate  = 4'd8;
  localparam logic [2:0] __const__num_xbar_inports_at_opt_propagate  = 3'd6;
  localparam logic [2:0] __const__num_connect_inports_at_opt_propagate  = 3'd4;
  localparam logic [2:0] __const__num_connect_outports_at_handshake_process  = 3'd4;
  localparam logic [2:0] __const__num_connect_inports_at_handshake_process  = 3'd4;
  localparam logic [3:0] __const__num_xbar_outports_at_handshake_process  = 4'd8;
  localparam logic [2:0] __const__num_xbar_inports_at_handshake_process  = 3'd6;
  localparam logic [3:0] __const__num_xbar_outports_at_data_routing  = 4'd8;
  localparam logic [2:0] __const__num_connect_inports_at_data_routing  = 3'd4;
  localparam logic [2:0] __const__num_connect_outports_at_data_routing  = 3'd4;
  localparam logic [2:0] __const__num_xbar_inports_at_data_routing  = 3'd6;
  localparam logic [3:0] __const__num_xbar_outports_at_xbar_propagate_sync  = 4'd8;
  logic [1:0] cur_stage;
  logic [0:0] fu_handshake_vector_fu_out_req_bypass_met;
  logic [1:0] fu_handshake_vector_fu_out_req_local_met;
  logic [3:0] fu_handshake_vector_mesh_in_recv_port_req_met;
  logic [1:0] fu_handshake_vector_send_bypass_data_valid_met [0:3];
  logic [8:0] fu_handshake_vector_send_port_req_nxt_met;
  logic [0:0] fu_handshake_vector_xbar_fu_out_req_met;
  logic [0:0] fu_handshake_vector_xbar_mesh_in_req_met;
  logic [1:0] nxt_stage;
  logic [5:0] recv_port_req;
  logic [8:0] send_port_rdy_vector;
  logic [8:0] send_port_req_fu_out;
  logic [8:0] send_port_req_mesh_in;
  logic [8:0] send_port_req_nxt;
  logic [0:0] xbar_fu_out_done;
  logic [0:0] xbar_fu_out_okay;
  logic [8:0] xbar_inport_sel [0:5];
  logic [8:0] xbar_inport_sel_nxt [0:5];
  logic [0:0] xbar_mesh_in_done;
  logic [0:0] xbar_mesh_in_okay;
  logic [0:0] xbar_nxt_out_ready;
  logic [5:0] xbar_outport_sel [0:8];
  logic [5:0] xbar_outport_sel_nxt [0:8];
  logic [6:0] xbar_outport_sel_nxt_decode [0:7];

  
  always_comb begin : data_routing
    for ( int unsigned i = 1'd0; i < 4'( __const__num_xbar_outports_at_data_routing ); i += 1'd1 )
      send_port_data[3'(i)] = { 64'd0, 1'd0 };
    for ( int unsigned i = 1'd0; i < 3'( __const__num_connect_inports_at_data_routing ); i += 1'd1 )
      send_data_bypass[2'(i)] = { 64'd0, 1'd0 };
    send_predicate = 1'd0;
    for ( int unsigned i = 1'd0; i < 3'( __const__num_connect_outports_at_data_routing ); i += 1'd1 ) begin
      for ( int unsigned j = 1'd0; j < 3'( __const__num_connect_inports_at_data_routing ); j += 1'd1 ) begin
        send_port_data[3'(i)].payload = send_port_data[3'(i)].payload | ( recv_port_data[3'(j)].payload & { { 63 { xbar_outport_sel[4'(i)][3'(j)] } }, xbar_outport_sel[4'(i)][3'(j)] } );
        send_port_data[3'(i)].predicate = send_port_data[3'(i)].predicate | ( recv_port_data[3'(j)].predicate & xbar_outport_sel[4'(i)][3'(j)] );
      end
      for ( int unsigned j = 3'( __const__num_connect_inports_at_data_routing ); j < 3'( __const__num_xbar_inports_at_data_routing ); j += 1'd1 ) begin
        send_data_bypass[2'(i)].payload = send_data_bypass[2'(i)].payload | ( recv_port_data[3'(j)].payload & { { 63 { xbar_outport_sel[4'(i)][3'(j)] } }, xbar_outport_sel[4'(i)][3'(j)] } );
        send_data_bypass[2'(i)].predicate = send_data_bypass[2'(i)].predicate | ( recv_port_data[3'(j)].predicate & xbar_outport_sel[4'(i)][3'(j)] );
      end
    end
    for ( int unsigned i = 3'( __const__num_connect_outports_at_data_routing ); i < 4'( __const__num_xbar_outports_at_data_routing ); i += 1'd1 )
      for ( int unsigned j = 1'd0; j < 3'( __const__num_xbar_inports_at_data_routing ); j += 1'd1 ) begin
        send_port_data[3'(i)].payload = send_port_data[3'(i)].payload | ( recv_port_data[3'(j)].payload & { { 63 { xbar_outport_sel[4'(i)][3'(j)] } }, xbar_outport_sel[4'(i)][3'(j)] } );
        send_port_data[3'(i)].predicate = send_port_data[3'(i)].predicate | ( recv_port_data[3'(j)].predicate & xbar_outport_sel[4'(i)][3'(j)] );
      end
    for ( int unsigned i = 1'd0; i < 3'( __const__num_xbar_inports_at_data_routing ); i += 1'd1 )
      send_predicate.predicate = send_predicate.predicate | ( recv_port_data[3'(i)].predicate & xbar_outport_sel[4'( __const__num_xbar_outports_at_data_routing )][3'(i)] );
  end

  
  always_comb begin : decode_process
    for ( int unsigned i = 1'd0; i < 4'( __const__num_xbar_outports_at_decode_process ); i += 1'd1 )
      xbar_outport_sel_nxt_decode[3'(i)] = 7'd0;
    for ( int unsigned i = 1'd0; i < 4'( __const__num_xbar_outports_at_decode_process ) + 4'd1; i += 1'd1 )
      xbar_outport_sel_nxt[4'(i)] = 6'd0;
    if ( xbar_opt_enable ) begin
      for ( int unsigned i = 1'd0; i < 4'( __const__num_xbar_outports_at_decode_process ); i += 1'd1 )
        if ( recv_opt_msg_outport[3'(i)] != 3'd0 ) begin
          xbar_outport_sel_nxt_decode[3'(i)][recv_opt_msg_outport[3'(i)]] = 1'd1;
        end
      for ( int unsigned i = 1'd0; i < 4'( __const__num_xbar_outports_at_decode_process ); i += 1'd1 )
        xbar_outport_sel_nxt[4'(i)] = xbar_outport_sel_nxt_decode[3'(i)][3'd6:3'd1];
      xbar_outport_sel_nxt[4'( __const__num_xbar_outports_at_decode_process )] = recv_opt_msg_predicate_in;
    end
  end

  
  always_comb begin : fsm_ctrl_signals
    xbar_mesh_in_done = 1'd0;
    xbar_fu_out_done = 1'd0;
    if ( cur_stage == 2'( __const__STAGE_WAIT_FOR_FU ) ) begin
      xbar_mesh_in_done = 1'd1;
    end
    if ( cur_stage == 2'( __const__STAGE_WAIT_FOR_NOC ) ) begin
      xbar_fu_out_done = 1'd1;
    end
    if ( cur_stage == 2'( __const__STAGE_WAIT_FOR_DST ) ) begin
      xbar_mesh_in_done = 1'd1;
      xbar_fu_out_done = 1'd1;
    end
  end

  
  always_comb begin : fsm_nxt_stage
    nxt_stage = cur_stage;
    if ( cur_stage == 2'( __const__STAGE_NORMAL ) ) begin
      if ( ( ~xbar_mesh_in_okay ) & xbar_fu_out_okay ) begin
        nxt_stage = 2'( __const__STAGE_WAIT_FOR_NOC );
      end
      if ( ( ~xbar_fu_out_okay ) & xbar_mesh_in_okay ) begin
        nxt_stage = 2'( __const__STAGE_WAIT_FOR_FU );
      end
      if ( ( xbar_mesh_in_okay & xbar_fu_out_okay ) & ( ~xbar_nxt_out_ready ) ) begin
        nxt_stage = 2'( __const__STAGE_WAIT_FOR_DST );
      end
    end
    if ( cur_stage == 2'( __const__STAGE_WAIT_FOR_NOC ) ) begin
      if ( xbar_mesh_in_okay ) begin
        if ( ~xbar_nxt_out_ready ) begin
          nxt_stage = 2'( __const__STAGE_WAIT_FOR_DST );
        end
        else
          nxt_stage = 2'( __const__STAGE_NORMAL );
      end
    end
    if ( cur_stage == 2'( __const__STAGE_WAIT_FOR_FU ) ) begin
      if ( xbar_fu_out_okay ) begin
        if ( ~xbar_nxt_out_ready ) begin
          nxt_stage = 2'( __const__STAGE_WAIT_FOR_DST );
        end
        else
          nxt_stage = 2'( __const__STAGE_NORMAL );
      end
    end
    if ( cur_stage == 2'( __const__STAGE_WAIT_FOR_DST ) ) begin
      if ( xbar_nxt_out_ready ) begin
        nxt_stage = 2'( __const__STAGE_NORMAL );
      end
    end
  end

  
  always_comb begin : handshake_process
    recv_port_req = 6'd0;
    send_port_req_mesh_in = 9'd0;
    send_port_req_fu_out = 9'd0;
    send_port_req_nxt = 9'd0;
    send_bypass_req = 4'd0;
    for ( int unsigned i = 1'd0; i < 3'( __const__num_connect_outports_at_handshake_process ); i += 1'd1 )
      send_port_req_nxt[4'(i)] = ( | xbar_outport_sel_nxt[4'(i)][3'd3:3'd0] );
    for ( int unsigned i = 3'( __const__num_connect_outports_at_handshake_process ); i < 4'( __const__num_xbar_outports_at_handshake_process ) + 4'd1; i += 1'd1 )
      send_port_req_nxt[4'(i)] = ( | xbar_outport_sel_nxt[4'(i)] );
    for ( int unsigned i = 1'd0; i < 3'( __const__num_xbar_inports_at_handshake_process ); i += 1'd1 )
      recv_port_req[3'(i)] = ( | xbar_inport_sel[3'(i)] );
    for ( int unsigned i = 1'd0; i < 4'( __const__num_xbar_outports_at_handshake_process ) + 4'd1; i += 1'd1 )
      send_port_req_mesh_in[4'(i)] = ( | xbar_outport_sel[4'(i)][3'd3:3'd0] );
    for ( int unsigned i = 3'( __const__num_connect_outports_at_handshake_process ); i < 4'( __const__num_xbar_outports_at_handshake_process ) + 4'd1; i += 1'd1 )
      send_port_req_fu_out[4'(i)] = ( | xbar_outport_sel[4'(i)][3'd5:3'( __const__num_connect_inports_at_handshake_process )] );
    for ( int unsigned i = 1'd0; i < 3'( __const__num_connect_outports_at_handshake_process ); i += 1'd1 ) begin
      send_bypass_req[2'(i)] = ( | xbar_outport_sel[4'(i)][3'd5:3'( __const__num_connect_inports_at_handshake_process )] );
      fu_handshake_vector_send_bypass_data_valid_met[2'(i)] = recv_port_valid[3'd5:3'( __const__num_connect_inports_at_handshake_process )] & xbar_outport_sel[4'(i)][3'd5:3'( __const__num_connect_inports_at_handshake_process )];
      send_bypass_data_valid[2'(i)] = ( | fu_handshake_vector_send_bypass_data_valid_met[2'(i)] );
    end
    fu_handshake_vector_send_port_req_nxt_met = send_port_req_nxt & ( ~send_port_rdy_vector );
    fu_handshake_vector_mesh_in_recv_port_req_met = recv_port_req[3'd3:3'd0] & ( ~recv_port_valid[3'd3:3'd0] );
    fu_handshake_vector_fu_out_req_local_met = recv_port_req[3'd5:3'( __const__num_connect_inports_at_handshake_process )] & ( ~recv_port_valid[3'd5:3'( __const__num_connect_inports_at_handshake_process )] );
    fu_handshake_vector_fu_out_req_bypass_met = send_bypass_req == send_bypass_port_ack;
    xbar_nxt_out_ready = ( ~( | fu_handshake_vector_send_port_req_nxt_met ) ) | xbar_dry_run_begin;
    xbar_mesh_in_okay = ( ~( | fu_handshake_vector_mesh_in_recv_port_req_met ) ) | xbar_dry_run_ack;
    xbar_fu_out_okay = ( ( ~( | fu_handshake_vector_fu_out_req_local_met ) ) & fu_handshake_vector_fu_out_req_bypass_met ) | xbar_dry_run_ack;
    fu_handshake_vector_xbar_fu_out_req_met = ( ~xbar_fu_out_done ) & xbar_fu_out_okay;
    fu_handshake_vector_xbar_mesh_in_req_met = ( ~xbar_mesh_in_done ) & xbar_mesh_in_okay;
    recv_port_mesh_in_ack = recv_port_req[3'd3:3'd0] & { { 3 { fu_handshake_vector_xbar_mesh_in_req_met[0] } }, fu_handshake_vector_xbar_mesh_in_req_met };
    recv_port_fu_out_ack = fu_handshake_vector_xbar_fu_out_req_met;
    send_port_en = ( send_port_req_mesh_in & { { 8 { fu_handshake_vector_xbar_mesh_in_req_met[0] } }, fu_handshake_vector_xbar_mesh_in_req_met } ) | ( send_port_req_fu_out & { { 8 { fu_handshake_vector_xbar_fu_out_req_met[0] } }, fu_handshake_vector_xbar_fu_out_req_met } );
    xbar_propagate_rdy = ( xbar_nxt_out_ready & ( xbar_mesh_in_done | xbar_mesh_in_okay ) ) & ( xbar_fu_out_done | xbar_fu_out_okay );
  end

  
  always_comb begin : opt_propagate
    for ( int unsigned i = 1'd0; i < 4'( __const__num_xbar_outports_at_opt_propagate ) + 4'd1; i += 1'd1 ) begin
      for ( int unsigned j = 1'd0; j < 3'( __const__num_xbar_inports_at_opt_propagate ); j += 1'd1 )
        xbar_inport_sel[3'(j)][4'(i)] = xbar_outport_sel[4'(i)][3'(j)];
      for ( int unsigned j = 1'd0; j < 3'( __const__num_connect_inports_at_opt_propagate ); j += 1'd1 )
        xbar_inport_sel_nxt[3'(j)][4'(i)] = xbar_outport_sel_nxt[4'(i)][3'(j)];
    end
  end

  
  always_ff @(posedge clk) begin : fsm_update
    if ( reset ) begin
      cur_stage <= 2'( __const__STAGE_NORMAL );
    end
    else
      cur_stage <= nxt_stage;
  end

  
  always_ff @(posedge clk) begin : xbar_propagate_sync
    if ( reset ) begin
      for ( int unsigned i = 1'd0; i < 4'( __const__num_xbar_outports_at_xbar_propagate_sync ) + 4'd1; i += 1'd1 )
        xbar_outport_sel[4'(i)] <= 6'd0;
    end
    else if ( xbar_propagate_en ) begin
      for ( int unsigned i = 1'd0; i < 4'( __const__num_xbar_outports_at_xbar_propagate_sync ) + 4'd1; i += 1'd1 )
        xbar_outport_sel[4'(i)] <= xbar_outport_sel_nxt[4'(i)];
    end
  end

  assign send_port_rdy_vector[0:0] = send_port_rdy[0:0];
  assign send_port_rdy_vector[1:1] = send_port_rdy[1:1];
  assign send_port_rdy_vector[2:2] = send_port_rdy[2:2];
  assign send_port_rdy_vector[3:3] = send_port_rdy[3:3];
  assign send_port_rdy_vector[4:4] = send_port_rdy[4:4];
  assign send_port_rdy_vector[5:5] = send_port_rdy[5:5];
  assign send_port_rdy_vector[6:6] = send_port_rdy[6:6];
  assign send_port_rdy_vector[7:7] = send_port_rdy[7:7];
  assign send_port_rdy_vector[8:8] = send_predicate_rdy;

endmodule



module RegisterFile__f54f54c28dab18db
(
  input  logic [0:0] clk ,
  input  logic [4:0] raddr [0:0],
  output CGRAConfig_6_4_6_8_6__70c95bde83d8947c rdata [0:0],
  input  logic [0:0] reset ,
  input  logic [4:0] waddr [0:0],
  input  CGRAConfig_6_4_6_8_6__70c95bde83d8947c wdata [0:0],
  input  logic [0:0] wen [0:0]
);
  localparam logic [0:0] __const__rd_ports_at_up_rf_read  = 1'd1;
  localparam logic [0:0] __const__wr_ports_at_up_rf_write  = 1'd1;
  CGRAConfig_6_4_6_8_6__70c95bde83d8947c regs [0:31];

  
  always_comb begin : up_rf_read
    for ( int unsigned i = 1'd0; i < 1'( __const__rd_ports_at_up_rf_read ); i += 1'd1 )
      rdata[1'(i)] = regs[raddr[1'(i)]];
  end

  
  always_ff @(posedge clk) begin : up_rf_write
    for ( int unsigned i = 1'd0; i < 1'( __const__wr_ports_at_up_rf_write ); i += 1'd1 )
      if ( wen[1'(i)] ) begin
        regs[waddr[1'(i)]] <= wdata[1'(i)];
      end
  end

endmodule



module CtrlMemRTL__a01c7414dc24348f
(
  input  logic [0:0] clk ,
  input  logic [5:0] cmd_counter_th ,
  input  logic [0:0] execution_ini ,
  input  logic [0:0] nxt_ctrl_en ,
  output CGRAConfig_6_4_6_8_6__70c95bde83d8947c recv_ctrl_msg ,
  input  logic [31:0] recv_ctrl_slice ,
  input  logic [0:0] recv_ctrl_slice_en ,
  input  logic [0:0] recv_ctrl_slice_idx ,
  input  logic [4:0] recv_waddr ,
  input  logic [0:0] recv_waddr_en ,
  input  logic [0:0] reset ,
  output CGRAConfig_6_4_6_8_6__70c95bde83d8947c send_ctrl_msg 
);
  localparam logic [1:0] __const__num_opt_slice_at_buffer_opt_slice  = 2'd2;
  logic [5:0] cmd_counter;
  logic [63:0] concat_ctrl_msg;
  logic [31:0] opt_slice_regs [0:1];

  logic [0:0] reg_file__clk;
  logic [4:0] reg_file__raddr [0:0];
  CGRAConfig_6_4_6_8_6__70c95bde83d8947c reg_file__rdata [0:0];
  logic [0:0] reg_file__reset;
  logic [4:0] reg_file__waddr [0:0];
  CGRAConfig_6_4_6_8_6__70c95bde83d8947c reg_file__wdata [0:0];
  logic [0:0] reg_file__wen [0:0];

  RegisterFile__f54f54c28dab18db reg_file
  (
    .clk( reg_file__clk ),
    .raddr( reg_file__raddr ),
    .rdata( reg_file__rdata ),
    .reset( reg_file__reset ),
    .waddr( reg_file__waddr ),
    .wdata( reg_file__wdata ),
    .wen( reg_file__wen )
  );


  
  always_ff @(posedge clk) begin : buffer_opt_slice
    if ( reset ) begin
      for ( int unsigned i = 1'd0; i < 2'( __const__num_opt_slice_at_buffer_opt_slice ); i += 1'd1 )
        opt_slice_regs[1'(i)] <= 32'd0;
    end
    else if ( recv_ctrl_slice_en ) begin
      opt_slice_regs[recv_ctrl_slice_idx] <= recv_ctrl_slice;
    end
  end

  
  always_ff @(posedge clk) begin : update_raddr
    if ( reset | execution_ini ) begin
      cmd_counter <= 6'd0;
    end
    else if ( nxt_ctrl_en ) begin
      if ( ( cmd_counter + 6'd1 ) == cmd_counter_th ) begin
        cmd_counter <= 6'd0;
      end
      else
        cmd_counter <= cmd_counter + 6'd1;
    end
  end

  assign reg_file__clk = clk;
  assign reg_file__reset = reset;
  assign concat_ctrl_msg[31:0] = opt_slice_regs[0];
  assign concat_ctrl_msg[63:32] = opt_slice_regs[1];
  assign recv_ctrl_msg = concat_ctrl_msg[54:0];
  assign reg_file__waddr[0] = recv_waddr;
  assign reg_file__wdata[0] = recv_ctrl_msg;
  assign reg_file__wen[0] = recv_waddr_en;
  assign reg_file__raddr[0] = cmd_counter[4:0];
  assign send_ctrl_msg = reg_file__rdata[0];

endmodule



module Demux__Type_Bits1__noutputs_2
(
  input  logic [0:0] clk ,
  input  logic [0:0] in_ ,
  output logic [0:0] out [0:1],
  input  logic [0:0] reset ,
  input  logic [0:0] sel 
);
  localparam logic [1:0] __const__noutputs_at_up_mux  = 2'd2;
  localparam logic [0:0] __const__default_value_at_up_mux  = 1'd0;

  
  always_comb begin : up_mux
    for ( int unsigned i = 1'd0; i < 2'( __const__noutputs_at_up_mux ); i += 1'd1 )
      out[1'(i)] = 1'( __const__default_value_at_up_mux );
    out[sel] = in_;
  end

endmodule



module AdderRTL__cad2bcaa3a8de18d
(
  input  logic [0:0] clk ,
  output logic [0:0] fu_fin_req ,
  input  logic [0:0] opt_launch_en ,
  output logic [0:0] opt_launch_rdy ,
  output logic [0:0] opt_launch_rdy_nxt ,
  input  logic [0:0] opt_pipeline_fin_en ,
  input  logic [0:0] opt_pipeline_fin_propagate_en ,
  input  logic [0:0] opt_pipeline_inter_en ,
  input  logic [0:0] opt_propagate_en ,
  input  logic [31:0] recv_const_msg ,
  output logic [0:0] recv_const_req ,
  input  logic [0:0] recv_opt_en ,
  input  logic [5:0] recv_opt_msg_ctrl ,
  input  logic [0:0] recv_predicate_en ,
  input  CGRAData_1__predicate_1 recv_predicate_msg ,
  input  logic [0:0] reset ,
  input logic [0:0] from_mem_rdata__en  ,
  input CGRAData_64_1__payload_64__predicate_1 from_mem_rdata__msg  ,
  output logic [0:0] from_mem_rdata__rdy  ,
  input logic [0:0] recv_in__en [0:3] ,
  input CGRAData_64_1__payload_64__predicate_1 recv_in__msg [0:3] ,
  output logic [0:0] recv_in__rdy [0:3] ,
  output logic [0:0] send_out__en [0:1] ,
  output CGRAData_64_1__payload_64__predicate_1 send_out__msg [0:1] ,
  input logic [0:0] send_out__rdy [0:1] ,
  output logic [0:0] to_mem_raddr__en  ,
  output logic [6:0] to_mem_raddr__msg  ,
  input logic [0:0] to_mem_raddr__rdy  ,
  output logic [0:0] to_mem_waddr__en  ,
  output logic [6:0] to_mem_waddr__msg  ,
  input logic [0:0] to_mem_waddr__rdy  ,
  output logic [0:0] to_mem_wdata__en  ,
  output CGRAData_64_1__payload_64__predicate_1 to_mem_wdata__msg  ,
  input logic [0:0] to_mem_wdata__rdy  
);
  localparam CGRAData_64_1__payload_64__predicate_1 const_zero  = { 64'd0, 1'd0 };
  localparam logic [0:0] __const__LOCAL_OPT_NAH  = 1'd0;
  localparam logic [5:0] __const__OPT_ADD  = 6'd2;
  localparam logic [0:0] __const__LOCAL_OPT_ADD  = 1'd1;
  localparam logic [5:0] __const__OPT_ADD_CONST  = 6'd25;
  localparam logic [1:0] __const__LOCAL_OPT_ADD_CONST  = 2'd2;
  localparam logic [5:0] __const__OPT_INC  = 6'd3;
  localparam logic [1:0] __const__LOCAL_OPT_INC  = 2'd3;
  localparam logic [5:0] __const__OPT_SUB  = 6'd4;
  localparam logic [2:0] __const__LOCAL_OPT_SUB  = 3'd4;
  localparam logic [5:0] __const__OPT_PAS  = 6'd31;
  localparam logic [2:0] __const__LOCAL_OPT_PAS  = 3'd5;
  localparam logic [1:0] __const__num_outports_at_opt_launch  = 2'd2;
  logic [0:0] latency;
  logic [0:0] launch_rdy;
  logic [0:0] launch_rdy_nxt;
  logic [2:0] local_opt_ctrl;
  logic [2:0] local_opt_ctrl_nxt;

  
  always_comb begin : opt_decode
    local_opt_ctrl_nxt = 3'( __const__LOCAL_OPT_NAH );
    recv_const_req = 1'd0;
    if ( recv_opt_en ) begin
      if ( recv_opt_msg_ctrl == 6'( __const__OPT_ADD ) ) begin
        local_opt_ctrl_nxt = 3'( __const__LOCAL_OPT_ADD );
      end
      if ( recv_opt_msg_ctrl == 6'( __const__OPT_ADD_CONST ) ) begin
        local_opt_ctrl_nxt = 3'( __const__LOCAL_OPT_ADD_CONST );
        recv_const_req = 1'd1;
      end
      if ( recv_opt_msg_ctrl == 6'( __const__OPT_INC ) ) begin
        local_opt_ctrl_nxt = 3'( __const__LOCAL_OPT_INC );
      end
      if ( recv_opt_msg_ctrl == 6'( __const__OPT_SUB ) ) begin
        local_opt_ctrl_nxt = 3'( __const__LOCAL_OPT_SUB );
      end
      if ( recv_opt_msg_ctrl == 6'( __const__OPT_PAS ) ) begin
        local_opt_ctrl_nxt = 3'( __const__LOCAL_OPT_PAS );
      end
    end
  end

  
  always_comb begin : opt_launch
    for ( int unsigned i = 1'd0; i < 2'( __const__num_outports_at_opt_launch ); i += 1'd1 ) begin
      send_out__msg[1'(i)] = { 64'd0, 1'd0 };
      send_out__en[1'(i)] = 1'd0;
    end
    launch_rdy = 1'd1;
    launch_rdy_nxt = 1'd1;
    if ( opt_launch_en ) begin
      if ( local_opt_ctrl == 3'( __const__LOCAL_OPT_ADD ) ) begin
        send_out__en[1'd0] = 1'd1;
        send_out__msg[1'd0].payload = recv_in__msg[2'd0].payload + recv_in__msg[2'd1].payload;
        send_out__msg[1'd0].predicate = recv_in__msg[2'd0].predicate & recv_in__msg[2'd1].predicate;
      end
      if ( local_opt_ctrl == 3'( __const__LOCAL_OPT_ADD_CONST ) ) begin
        send_out__en[1'd0] = 1'd1;
        send_out__msg[1'd0].payload = recv_in__msg[2'd0].payload + { { 32 { recv_const_msg[31] } }, recv_const_msg };
        send_out__msg[1'd0].predicate = recv_in__msg[2'd0].predicate;
      end
      if ( local_opt_ctrl == 3'( __const__LOCAL_OPT_INC ) ) begin
        send_out__en[1'd0] = 1'd1;
        send_out__msg[1'd0].payload = recv_in__msg[2'd0].payload + 64'd1;
        send_out__msg[1'd0].predicate = recv_in__msg[2'd0].predicate;
      end
      if ( local_opt_ctrl == 3'( __const__LOCAL_OPT_SUB ) ) begin
        send_out__en[1'd0] = 1'd1;
        send_out__msg[1'd0].payload = recv_in__msg[2'd0].payload - recv_in__msg[2'd1].payload;
        send_out__msg[1'd0].predicate = recv_in__msg[2'd0].predicate;
      end
      if ( recv_opt_msg_ctrl == 6'( __const__LOCAL_OPT_PAS ) ) begin
        send_out__en[1'd0] = 1'd1;
        send_out__msg[1'd0].payload = recv_in__msg[2'd0].payload;
        send_out__msg[1'd0].predicate = recv_in__msg[2'd0].predicate;
      end
      if ( recv_predicate_en == 1'd1 ) begin
        send_out__msg[1'd0].predicate = send_out__msg[1'd0].predicate & recv_predicate_msg.predicate;
      end
    end
  end

  
  always_comb begin : opt_pipeline
    fu_fin_req = 1'd0;
    opt_launch_rdy_nxt = 1'd1;
    opt_launch_rdy = 1'd1;
    if ( local_opt_ctrl_nxt != 3'( __const__LOCAL_OPT_NAH ) ) begin
      fu_fin_req = 1'd1;
      opt_launch_rdy_nxt = launch_rdy_nxt;
    end
    if ( local_opt_ctrl != 3'( __const__LOCAL_OPT_NAH ) ) begin
      opt_launch_rdy = launch_rdy;
    end
  end

  
  always_comb begin : update_mem
    to_mem_waddr__en = 1'd0;
    to_mem_wdata__en = 1'd0;
    to_mem_wdata__msg = const_zero;
    to_mem_waddr__msg = 7'd0;
    to_mem_raddr__msg = 7'd0;
    to_mem_raddr__en = 1'd0;
    from_mem_rdata__rdy = 1'd0;
  end

  
  always_ff @(posedge clk) begin : fu_propagate_sync
    if ( reset | ( ~opt_propagate_en ) ) begin
      local_opt_ctrl <= 3'( __const__LOCAL_OPT_NAH );
    end
    else
      local_opt_ctrl <= local_opt_ctrl_nxt;
  end

endmodule



module PhiRTL__cad2bcaa3a8de18d
(
  input  logic [0:0] clk ,
  output logic [0:0] fu_fin_req ,
  input  logic [0:0] opt_launch_en ,
  output logic [0:0] opt_launch_rdy ,
  output logic [0:0] opt_launch_rdy_nxt ,
  input  logic [0:0] opt_pipeline_fin_en ,
  input  logic [0:0] opt_pipeline_fin_propagate_en ,
  input  logic [0:0] opt_pipeline_inter_en ,
  input  logic [0:0] opt_propagate_en ,
  input  logic [31:0] recv_const_msg ,
  output logic [0:0] recv_const_req ,
  input  logic [0:0] recv_opt_en ,
  input  logic [5:0] recv_opt_msg_ctrl ,
  input  logic [0:0] recv_predicate_en ,
  input  CGRAData_1__predicate_1 recv_predicate_msg ,
  input  logic [0:0] reset ,
  input logic [0:0] from_mem_rdata__en  ,
  input CGRAData_64_1__payload_64__predicate_1 from_mem_rdata__msg  ,
  output logic [0:0] from_mem_rdata__rdy  ,
  input logic [0:0] recv_in__en [0:3] ,
  input CGRAData_64_1__payload_64__predicate_1 recv_in__msg [0:3] ,
  output logic [0:0] recv_in__rdy [0:3] ,
  output logic [0:0] send_out__en [0:1] ,
  output CGRAData_64_1__payload_64__predicate_1 send_out__msg [0:1] ,
  input logic [0:0] send_out__rdy [0:1] ,
  output logic [0:0] to_mem_raddr__en  ,
  output logic [6:0] to_mem_raddr__msg  ,
  input logic [0:0] to_mem_raddr__rdy  ,
  output logic [0:0] to_mem_waddr__en  ,
  output logic [6:0] to_mem_waddr__msg  ,
  input logic [0:0] to_mem_waddr__rdy  ,
  output logic [0:0] to_mem_wdata__en  ,
  output CGRAData_64_1__payload_64__predicate_1 to_mem_wdata__msg  ,
  input logic [0:0] to_mem_wdata__rdy  
);
  localparam CGRAData_64_1__payload_64__predicate_1 const_zero  = { 64'd0, 1'd0 };
  localparam logic [0:0] __const__LOCAL_OPT_NAH  = 1'd0;
  localparam logic [5:0] __const__OPT_PHI  = 6'd17;
  localparam logic [0:0] __const__LOCAL_OPT_PHI  = 1'd1;
  localparam logic [5:0] __const__OPT_PHI_CONST  = 6'd32;
  localparam logic [1:0] __const__LOCAL_OPT_PHI_CONST  = 2'd2;
  localparam logic [1:0] __const__num_outports_at_opt_launch  = 2'd2;
  logic [0:0] latency;
  logic [0:0] launch_rdy;
  logic [0:0] launch_rdy_nxt;
  logic [1:0] local_opt_ctrl;
  logic [1:0] local_opt_ctrl_nxt;

  
  always_comb begin : opt_decode
    local_opt_ctrl_nxt = 2'( __const__LOCAL_OPT_NAH );
    recv_const_req = 1'd0;
    if ( recv_opt_en ) begin
      if ( recv_opt_msg_ctrl == 6'( __const__OPT_PHI ) ) begin
        local_opt_ctrl_nxt = 2'( __const__LOCAL_OPT_PHI );
      end
      if ( recv_opt_msg_ctrl == 6'( __const__OPT_PHI_CONST ) ) begin
        local_opt_ctrl_nxt = 2'( __const__LOCAL_OPT_PHI_CONST );
        recv_const_req = 1'd1;
      end
    end
  end

  
  always_comb begin : opt_launch
    for ( int unsigned i = 1'd0; i < 2'( __const__num_outports_at_opt_launch ); i += 1'd1 ) begin
      send_out__msg[1'(i)] = { 64'd0, 1'd0 };
      send_out__en[1'(i)] = 1'd0;
    end
    launch_rdy = 1'd1;
    launch_rdy_nxt = 1'd1;
    if ( opt_launch_en ) begin
      if ( local_opt_ctrl == 2'( __const__LOCAL_OPT_PHI ) ) begin
        send_out__en[1'd0] = 1'd1;
        if ( recv_in__msg[2'd0].predicate == 1'd1 ) begin
          send_out__msg[1'd0].payload = recv_in__msg[2'd0].payload;
        end
        else if ( recv_in__msg[2'd1].predicate == 1'd1 ) begin
          send_out__msg[1'd0].payload = recv_in__msg[2'd1].payload;
        end
        else
          send_out__msg[1'd0].payload = recv_in__msg[2'd0].payload;
        send_out__msg[1'd0].predicate = recv_in__msg[2'd0].predicate | recv_in__msg[2'd1].predicate;
      end
      if ( local_opt_ctrl == 2'( __const__LOCAL_OPT_PHI_CONST ) ) begin
        send_out__en[1'd0] = 1'd1;
        if ( recv_in__msg[2'd0].predicate == 1'd1 ) begin
          send_out__msg[1'd0].payload = recv_in__msg[2'd0].payload;
        end
        else
          send_out__msg[1'd0].payload = { { 32 { recv_const_msg[31] } }, recv_const_msg };
        send_out__msg[1'd0].predicate = 1'd1;
      end
      if ( recv_predicate_en == 1'd1 ) begin
        send_out__msg[1'd0].predicate = send_out__msg[1'd0].predicate & recv_predicate_msg.predicate;
      end
    end
  end

  
  always_comb begin : opt_pipeline
    fu_fin_req = 1'd0;
    opt_launch_rdy_nxt = 1'd1;
    opt_launch_rdy = 1'd1;
    if ( local_opt_ctrl_nxt != 2'( __const__LOCAL_OPT_NAH ) ) begin
      fu_fin_req = 1'd1;
      opt_launch_rdy_nxt = launch_rdy_nxt;
    end
    if ( local_opt_ctrl != 2'( __const__LOCAL_OPT_NAH ) ) begin
      opt_launch_rdy = launch_rdy;
    end
  end

  
  always_comb begin : update_mem
    to_mem_waddr__en = 1'd0;
    to_mem_wdata__en = 1'd0;
    to_mem_wdata__msg = const_zero;
    to_mem_waddr__msg = 7'd0;
    to_mem_raddr__msg = 7'd0;
    to_mem_raddr__en = 1'd0;
    from_mem_rdata__rdy = 1'd0;
  end

  
  always_ff @(posedge clk) begin : fu_propagate_sync
    if ( reset | ( ~opt_propagate_en ) ) begin
      local_opt_ctrl <= 2'( __const__LOCAL_OPT_NAH );
    end
    else
      local_opt_ctrl <= local_opt_ctrl_nxt;
  end

endmodule



module CompRTL__cad2bcaa3a8de18d
(
  input  logic [0:0] clk ,
  output logic [0:0] fu_fin_req ,
  input  logic [0:0] opt_launch_en ,
  output logic [0:0] opt_launch_rdy ,
  output logic [0:0] opt_launch_rdy_nxt ,
  input  logic [0:0] opt_pipeline_fin_en ,
  input  logic [0:0] opt_pipeline_fin_propagate_en ,
  input  logic [0:0] opt_pipeline_inter_en ,
  input  logic [0:0] opt_propagate_en ,
  input  logic [31:0] recv_const_msg ,
  output logic [0:0] recv_const_req ,
  input  logic [0:0] recv_opt_en ,
  input  logic [5:0] recv_opt_msg_ctrl ,
  input  logic [0:0] recv_predicate_en ,
  input  CGRAData_1__predicate_1 recv_predicate_msg ,
  input  logic [0:0] reset ,
  input logic [0:0] from_mem_rdata__en  ,
  input CGRAData_64_1__payload_64__predicate_1 from_mem_rdata__msg  ,
  output logic [0:0] from_mem_rdata__rdy  ,
  input logic [0:0] recv_in__en [0:3] ,
  input CGRAData_64_1__payload_64__predicate_1 recv_in__msg [0:3] ,
  output logic [0:0] recv_in__rdy [0:3] ,
  output logic [0:0] send_out__en [0:1] ,
  output CGRAData_64_1__payload_64__predicate_1 send_out__msg [0:1] ,
  input logic [0:0] send_out__rdy [0:1] ,
  output logic [0:0] to_mem_raddr__en  ,
  output logic [6:0] to_mem_raddr__msg  ,
  input logic [0:0] to_mem_raddr__rdy  ,
  output logic [0:0] to_mem_waddr__en  ,
  output logic [6:0] to_mem_waddr__msg  ,
  input logic [0:0] to_mem_waddr__rdy  ,
  output logic [0:0] to_mem_wdata__en  ,
  output CGRAData_64_1__payload_64__predicate_1 to_mem_wdata__msg  ,
  input logic [0:0] to_mem_wdata__rdy  
);
  localparam CGRAData_64_1__payload_64__predicate_1 const_one  = { 64'd1, 1'd0 };
  localparam CGRAData_64_1__payload_64__predicate_1 const_zero  = { 64'd0, 1'd0 };
  localparam logic [0:0] __const__LOCAL_OPT_NAH  = 1'd0;
  localparam logic [5:0] __const__OPT_EQ  = 6'd14;
  localparam logic [0:0] __const__LOCAL_OPT_EQ  = 1'd1;
  localparam logic [5:0] __const__OPT_EQ_CONST  = 6'd33;
  localparam logic [1:0] __const__LOCAL_OPT_EQ_CONST  = 2'd2;
  localparam logic [5:0] __const__OPT_LE  = 6'd15;
  localparam logic [1:0] __const__LOCAL_OPT_LE  = 2'd3;
  localparam logic [1:0] __const__num_outports_at_opt_launch  = 2'd2;
  logic [0:0] latency;
  logic [0:0] launch_rdy;
  logic [0:0] launch_rdy_nxt;
  logic [1:0] local_opt_ctrl;
  logic [1:0] local_opt_ctrl_nxt;

  
  always_comb begin : opt_decode
    local_opt_ctrl_nxt = 2'( __const__LOCAL_OPT_NAH );
    recv_const_req = 1'd0;
    if ( recv_opt_en ) begin
      if ( recv_opt_msg_ctrl == 6'( __const__OPT_EQ ) ) begin
        local_opt_ctrl_nxt = 2'( __const__LOCAL_OPT_EQ );
      end
      if ( recv_opt_msg_ctrl == 6'( __const__OPT_EQ_CONST ) ) begin
        local_opt_ctrl_nxt = 2'( __const__LOCAL_OPT_EQ_CONST );
        recv_const_req = 1'd1;
      end
      if ( recv_opt_msg_ctrl == 6'( __const__OPT_LE ) ) begin
        local_opt_ctrl_nxt = 2'( __const__LOCAL_OPT_LE );
      end
    end
  end

  
  always_comb begin : opt_launch
    for ( int unsigned i = 1'd0; i < 2'( __const__num_outports_at_opt_launch ); i += 1'd1 ) begin
      send_out__msg[1'(i)] = { 64'd0, 1'd0 };
      send_out__en[1'(i)] = 1'd0;
    end
    launch_rdy = 1'd1;
    launch_rdy_nxt = 1'd1;
    if ( opt_launch_en ) begin
      if ( local_opt_ctrl == 2'( __const__LOCAL_OPT_EQ ) ) begin
        send_out__en[1'd0] = 1'd1;
        if ( recv_in__msg[2'd0].payload == recv_in__msg[2'd1].payload ) begin
          send_out__msg[1'd0] = const_one;
        end
        else
          send_out__msg[1'd0] = const_zero;
        send_out__msg[1'd0].predicate = recv_in__msg[2'd0].predicate & recv_in__msg[2'd1].predicate;
      end
      if ( local_opt_ctrl == 2'( __const__LOCAL_OPT_EQ_CONST ) ) begin
        send_out__en[1'd0] = 1'd1;
        if ( recv_in__msg[2'd0].payload == { { 32 { recv_const_msg[31] } }, recv_const_msg } ) begin
          send_out__msg[1'd0] = const_one;
        end
        else
          send_out__msg[1'd0] = const_zero;
        send_out__msg[1'd0].predicate = 1'd1;
      end
      if ( local_opt_ctrl == 2'( __const__LOCAL_OPT_LE ) ) begin
        send_out__en[1'd0] = 1'd1;
        if ( recv_in__msg[2'd0].payload <= recv_in__msg[2'd1].payload ) begin
          send_out__msg[1'd0] = const_one;
        end
        else
          send_out__msg[1'd0] = const_zero;
        send_out__msg[1'd0].predicate = recv_in__msg[2'd0].predicate & recv_in__msg[2'd1].predicate;
      end
      if ( recv_predicate_en == 1'd1 ) begin
        send_out__msg[1'd0].predicate = send_out__msg[1'd0].predicate & recv_predicate_msg.predicate;
      end
    end
  end

  
  always_comb begin : opt_pipeline
    fu_fin_req = 1'd0;
    opt_launch_rdy_nxt = 1'd1;
    opt_launch_rdy = 1'd1;
    if ( local_opt_ctrl_nxt != 2'( __const__LOCAL_OPT_NAH ) ) begin
      fu_fin_req = 1'd1;
      opt_launch_rdy_nxt = launch_rdy_nxt;
    end
    if ( local_opt_ctrl != 2'( __const__LOCAL_OPT_NAH ) ) begin
      opt_launch_rdy = launch_rdy;
    end
  end

  
  always_comb begin : update_mem
    to_mem_waddr__en = 1'd0;
    to_mem_wdata__en = 1'd0;
    to_mem_wdata__msg = const_zero;
    to_mem_waddr__msg = 7'd0;
    to_mem_raddr__msg = 7'd0;
    to_mem_raddr__en = 1'd0;
    from_mem_rdata__rdy = 1'd0;
  end

  
  always_ff @(posedge clk) begin : fu_propagate_sync
    if ( reset | ( ~opt_propagate_en ) ) begin
      local_opt_ctrl <= 2'( __const__LOCAL_OPT_NAH );
    end
    else
      local_opt_ctrl <= local_opt_ctrl_nxt;
  end

endmodule



module MulRTL__cad2bcaa3a8de18d
(
  input  logic [0:0] clk ,
  output logic [0:0] fu_fin_req ,
  input  logic [0:0] opt_launch_en ,
  output logic [0:0] opt_launch_rdy ,
  output logic [0:0] opt_launch_rdy_nxt ,
  input  logic [0:0] opt_pipeline_fin_en ,
  input  logic [0:0] opt_pipeline_fin_propagate_en ,
  input  logic [0:0] opt_pipeline_inter_en ,
  input  logic [0:0] opt_propagate_en ,
  input  logic [31:0] recv_const_msg ,
  output logic [0:0] recv_const_req ,
  input  logic [0:0] recv_opt_en ,
  input  logic [5:0] recv_opt_msg_ctrl ,
  input  logic [0:0] recv_predicate_en ,
  input  CGRAData_1__predicate_1 recv_predicate_msg ,
  input  logic [0:0] reset ,
  input logic [0:0] from_mem_rdata__en  ,
  input CGRAData_64_1__payload_64__predicate_1 from_mem_rdata__msg  ,
  output logic [0:0] from_mem_rdata__rdy  ,
  input logic [0:0] recv_in__en [0:3] ,
  input CGRAData_64_1__payload_64__predicate_1 recv_in__msg [0:3] ,
  output logic [0:0] recv_in__rdy [0:3] ,
  output logic [0:0] send_out__en [0:1] ,
  output CGRAData_64_1__payload_64__predicate_1 send_out__msg [0:1] ,
  input logic [0:0] send_out__rdy [0:1] ,
  output logic [0:0] to_mem_raddr__en  ,
  output logic [6:0] to_mem_raddr__msg  ,
  input logic [0:0] to_mem_raddr__rdy  ,
  output logic [0:0] to_mem_waddr__en  ,
  output logic [6:0] to_mem_waddr__msg  ,
  input logic [0:0] to_mem_waddr__rdy  ,
  output logic [0:0] to_mem_wdata__en  ,
  output CGRAData_64_1__payload_64__predicate_1 to_mem_wdata__msg  ,
  input logic [0:0] to_mem_wdata__rdy  
);
  localparam CGRAData_64_1__payload_64__predicate_1 const_zero  = { 64'd0, 1'd0 };
  localparam logic [0:0] __const__LOCAL_OPT_NAH  = 1'd0;
  localparam logic [5:0] __const__OPT_MUL  = 6'd7;
  localparam logic [0:0] __const__LOCAL_OPT_MUL  = 1'd1;
  localparam logic [5:0] __const__OPT_MUL_CONST  = 6'd29;
  localparam logic [1:0] __const__LOCAL_OPT_MUL_CONST  = 2'd2;
  localparam logic [5:0] __const__OPT_DIV  = 6'd26;
  localparam logic [1:0] __const__LOCAL_OPT_DIV  = 2'd3;
  localparam logic [1:0] __const__num_outports_at_opt_launch  = 2'd2;
  logic [0:0] latency;
  logic [0:0] launch_rdy;
  logic [0:0] launch_rdy_nxt;
  logic [1:0] local_opt_ctrl;
  logic [1:0] local_opt_ctrl_nxt;

  
  always_comb begin : opt_decode
    local_opt_ctrl_nxt = 2'( __const__LOCAL_OPT_NAH );
    recv_const_req = 1'd0;
    if ( recv_opt_en ) begin
      if ( recv_opt_msg_ctrl == 6'( __const__OPT_MUL ) ) begin
        local_opt_ctrl_nxt = 2'( __const__LOCAL_OPT_MUL );
      end
      if ( recv_opt_msg_ctrl == 6'( __const__OPT_MUL_CONST ) ) begin
        local_opt_ctrl_nxt = 2'( __const__LOCAL_OPT_MUL_CONST );
        recv_const_req = 1'd1;
      end
      if ( recv_opt_msg_ctrl == 6'( __const__OPT_DIV ) ) begin
        local_opt_ctrl_nxt = 2'( __const__LOCAL_OPT_DIV );
      end
    end
  end

  
  always_comb begin : opt_launch
    for ( int unsigned i = 1'd0; i < 2'( __const__num_outports_at_opt_launch ); i += 1'd1 ) begin
      send_out__msg[1'(i)] = { 64'd0, 1'd0 };
      send_out__en[1'(i)] = 1'd0;
    end
    launch_rdy = 1'd1;
    launch_rdy_nxt = 1'd1;
    if ( opt_launch_en ) begin
      if ( local_opt_ctrl == 2'( __const__LOCAL_OPT_MUL ) ) begin
        send_out__en[1'd0] = 1'd1;
        send_out__msg[1'd0].payload = recv_in__msg[2'd0].payload * recv_in__msg[2'd1].payload;
        send_out__msg[1'd0].predicate = recv_in__msg[2'd0].predicate & recv_in__msg[2'd1].predicate;
      end
      if ( local_opt_ctrl == 2'( __const__LOCAL_OPT_MUL_CONST ) ) begin
        send_out__en[1'd0] = 1'd1;
        send_out__msg[1'd0].payload = recv_in__msg[2'd0].payload * { { 32 { recv_const_msg[31] } }, recv_const_msg };
        send_out__msg[1'd0].predicate = recv_in__msg[2'd0].predicate;
      end
      if ( local_opt_ctrl == 2'( __const__LOCAL_OPT_DIV ) ) begin
        send_out__en[1'd0] = 1'd1;
        send_out__msg[1'd0].payload = recv_in__msg[2'd0].payload / recv_in__msg[2'd1].payload;
        send_out__msg[1'd0].predicate = recv_in__msg[2'd0].predicate & recv_in__msg[2'd1].predicate;
      end
      if ( recv_predicate_en == 1'd1 ) begin
        send_out__msg[1'd0].predicate = send_out__msg[1'd0].predicate & recv_predicate_msg.predicate;
      end
    end
  end

  
  always_comb begin : opt_pipeline
    fu_fin_req = 1'd0;
    opt_launch_rdy_nxt = 1'd1;
    opt_launch_rdy = 1'd1;
    if ( local_opt_ctrl_nxt != 2'( __const__LOCAL_OPT_NAH ) ) begin
      fu_fin_req = 1'd1;
      opt_launch_rdy_nxt = launch_rdy_nxt;
    end
    if ( local_opt_ctrl != 2'( __const__LOCAL_OPT_NAH ) ) begin
      opt_launch_rdy = launch_rdy;
    end
  end

  
  always_comb begin : update_mem
    to_mem_waddr__en = 1'd0;
    to_mem_wdata__en = 1'd0;
    to_mem_wdata__msg = const_zero;
    to_mem_waddr__msg = 7'd0;
    to_mem_raddr__msg = 7'd0;
    to_mem_raddr__en = 1'd0;
    from_mem_rdata__rdy = 1'd0;
  end

  
  always_ff @(posedge clk) begin : fu_propagate_sync
    if ( reset | ( ~opt_propagate_en ) ) begin
      local_opt_ctrl <= 2'( __const__LOCAL_OPT_NAH );
    end
    else
      local_opt_ctrl <= local_opt_ctrl_nxt;
  end

endmodule



module BranchRTL__cad2bcaa3a8de18d
(
  input  logic [0:0] clk ,
  output logic [0:0] fu_fin_req ,
  input  logic [0:0] opt_launch_en ,
  output logic [0:0] opt_launch_rdy ,
  output logic [0:0] opt_launch_rdy_nxt ,
  input  logic [0:0] opt_pipeline_fin_en ,
  input  logic [0:0] opt_pipeline_fin_propagate_en ,
  input  logic [0:0] opt_pipeline_inter_en ,
  input  logic [0:0] opt_propagate_en ,
  input  logic [31:0] recv_const_msg ,
  output logic [0:0] recv_const_req ,
  input  logic [0:0] recv_opt_en ,
  input  logic [5:0] recv_opt_msg_ctrl ,
  input  logic [0:0] recv_predicate_en ,
  input  CGRAData_1__predicate_1 recv_predicate_msg ,
  input  logic [0:0] reset ,
  input logic [0:0] from_mem_rdata__en  ,
  input CGRAData_64_1__payload_64__predicate_1 from_mem_rdata__msg  ,
  output logic [0:0] from_mem_rdata__rdy  ,
  input logic [0:0] recv_in__en [0:3] ,
  input CGRAData_64_1__payload_64__predicate_1 recv_in__msg [0:3] ,
  output logic [0:0] recv_in__rdy [0:3] ,
  output logic [0:0] send_out__en [0:1] ,
  output CGRAData_64_1__payload_64__predicate_1 send_out__msg [0:1] ,
  input logic [0:0] send_out__rdy [0:1] ,
  output logic [0:0] to_mem_raddr__en  ,
  output logic [6:0] to_mem_raddr__msg  ,
  input logic [0:0] to_mem_raddr__rdy  ,
  output logic [0:0] to_mem_waddr__en  ,
  output logic [6:0] to_mem_waddr__msg  ,
  input logic [0:0] to_mem_waddr__rdy  ,
  output logic [0:0] to_mem_wdata__en  ,
  output CGRAData_64_1__payload_64__predicate_1 to_mem_wdata__msg  ,
  input logic [0:0] to_mem_wdata__rdy  
);
  localparam CGRAData_64_1__payload_64__predicate_1 const_zero  = { 64'd0, 1'd0 };
  localparam logic [0:0] __const__LOCAL_OPT_NAH  = 1'd0;
  localparam logic [5:0] __const__OPT_BRH  = 6'd16;
  localparam logic [0:0] __const__LOCAL_OPT_BRH  = 1'd1;
  localparam logic [5:0] __const__OPT_BRH_START  = 6'd34;
  localparam logic [1:0] __const__LOCAL_OPT_BRH_START  = 2'd2;
  localparam logic [1:0] __const__num_outports_at_opt_launch  = 2'd2;
  logic [0:0] first;
  logic [0:0] latency;
  logic [0:0] launch_rdy;
  logic [0:0] launch_rdy_nxt;
  logic [1:0] local_opt_ctrl;
  logic [1:0] local_opt_ctrl_nxt;

  
  always_comb begin : opt_decode
    local_opt_ctrl_nxt = 2'( __const__LOCAL_OPT_NAH );
    recv_const_req = 1'd0;
    if ( recv_opt_en ) begin
      if ( recv_opt_msg_ctrl == 6'( __const__OPT_BRH ) ) begin
        local_opt_ctrl_nxt = 2'( __const__LOCAL_OPT_BRH );
      end
      if ( recv_opt_msg_ctrl == 6'( __const__OPT_BRH_START ) ) begin
        local_opt_ctrl_nxt = 2'( __const__LOCAL_OPT_BRH_START );
      end
    end
  end

  
  always_comb begin : opt_launch
    for ( int unsigned i = 1'd0; i < 2'( __const__num_outports_at_opt_launch ); i += 1'd1 ) begin
      send_out__msg[1'(i)] = { 64'd0, 1'd0 };
      send_out__en[1'(i)] = 1'd0;
    end
    launch_rdy = 1'd1;
    launch_rdy_nxt = 1'd1;
    if ( opt_launch_en ) begin
      if ( local_opt_ctrl == 2'( __const__LOCAL_OPT_BRH ) ) begin
        send_out__en[1'd0] = 1'd1;
        send_out__en[1'd1] = 1'd1;
        send_out__msg[1'd0] = { 64'd0, 1'd0 };
        send_out__msg[1'd1] = { 64'd0, 1'd0 };
        if ( recv_in__msg[2'd0].payload == 64'd0 ) begin
          send_out__msg[1'd0].predicate = 1'd1;
          send_out__msg[1'd1].predicate = 1'd0;
        end
        else begin
          send_out__msg[1'd0].predicate = 1'd0;
          send_out__msg[1'd1].predicate = 1'd1;
        end
      end
      if ( local_opt_ctrl == 2'( __const__LOCAL_OPT_BRH_START ) ) begin
        send_out__en[1'd0] = 1'd1;
        send_out__en[1'd1] = 1'd1;
        send_out__msg[1'd0] = { 64'd0, 1'd0 };
        send_out__msg[1'd1] = { 64'd0, 1'd0 };
        if ( first ) begin
          send_out__msg[1'd0].predicate = 1'd1;
          send_out__msg[1'd1].predicate = 1'd0;
        end
        else begin
          send_out__msg[1'd0].predicate = 1'd0;
          send_out__msg[1'd1].predicate = 1'd1;
        end
      end
      if ( recv_predicate_en == ( 1'd1 & ( local_opt_ctrl != 2'( __const__LOCAL_OPT_BRH_START ) ) ) ) begin
        send_out__msg[1'd0].predicate = send_out__msg[1'd0].predicate & recv_predicate_msg.predicate;
        send_out__msg[1'd1].predicate = send_out__msg[1'd1].predicate & recv_predicate_msg.predicate;
      end
    end
  end

  
  always_comb begin : opt_pipeline
    fu_fin_req = 1'd0;
    opt_launch_rdy_nxt = 1'd1;
    opt_launch_rdy = 1'd1;
    if ( local_opt_ctrl_nxt != 2'( __const__LOCAL_OPT_NAH ) ) begin
      fu_fin_req = 1'd1;
      opt_launch_rdy_nxt = launch_rdy_nxt;
    end
    if ( local_opt_ctrl != 2'( __const__LOCAL_OPT_NAH ) ) begin
      opt_launch_rdy = launch_rdy;
    end
  end

  
  always_comb begin : update_mem
    to_mem_waddr__en = 1'd0;
    to_mem_wdata__en = 1'd0;
    to_mem_wdata__msg = const_zero;
    to_mem_waddr__msg = 7'd0;
    to_mem_raddr__msg = 7'd0;
    to_mem_raddr__en = 1'd0;
    from_mem_rdata__rdy = 1'd0;
  end

  
  always_ff @(posedge clk) begin : br_start_once
    if ( reset ) begin
      first <= 1'd1;
    end
    else if ( ( local_opt_ctrl == 2'( __const__LOCAL_OPT_BRH_START ) ) & opt_launch_en ) begin
      first <= 1'd0;
    end
  end

  
  always_ff @(posedge clk) begin : fu_propagate_sync
    if ( reset | ( ~opt_propagate_en ) ) begin
      local_opt_ctrl <= 2'( __const__LOCAL_OPT_NAH );
    end
    else
      local_opt_ctrl <= local_opt_ctrl_nxt;
  end

endmodule





`ifndef CV32E40P_ALU
`define CV32E40P_ALU





package cv32e40p_pkg;


  parameter OPCODE_SYSTEM = 7'h73;
  parameter OPCODE_FENCE = 7'h0f;
  parameter OPCODE_OP = 7'h33;
  parameter OPCODE_OPIMM = 7'h13;
  parameter OPCODE_STORE = 7'h23;
  parameter OPCODE_LOAD = 7'h03;
  parameter OPCODE_BRANCH = 7'h63;
  parameter OPCODE_JALR = 7'h67;
  parameter OPCODE_JAL = 7'h6f;
  parameter OPCODE_AUIPC = 7'h17;
  parameter OPCODE_LUI = 7'h37;
  parameter OPCODE_OP_FP = 7'h53;
  parameter OPCODE_OP_FMADD = 7'h43;
  parameter OPCODE_OP_FNMADD = 7'h4f;
  parameter OPCODE_OP_FMSUB = 7'h47;
  parameter OPCODE_OP_FNMSUB = 7'h4b;
  parameter OPCODE_STORE_FP = 7'h27;
  parameter OPCODE_LOAD_FP = 7'h07;
  parameter OPCODE_AMO = 7'h2F;

  parameter OPCODE_CUSTOM_0 = 7'h0b;
  parameter OPCODE_CUSTOM_1 = 7'h2b;
  parameter OPCODE_CUSTOM_2 = 7'h5b;
  parameter OPCODE_CUSTOM_3 = 7'h7b;

  parameter REGC_S1 = 2'b10;
  parameter REGC_S4 = 2'b00;
  parameter REGC_RD = 2'b01;
  parameter REGC_ZERO = 2'b11;


  parameter ALU_OP_WIDTH = 7;

  typedef enum logic [ALU_OP_WIDTH-1:0] {

    ALU_ADD   = 7'b0011000,
    ALU_SUB   = 7'b0011001,
    ALU_ADDU  = 7'b0011010,
    ALU_SUBU  = 7'b0011011,
    ALU_ADDR  = 7'b0011100,
    ALU_SUBR  = 7'b0011101,
    ALU_ADDUR = 7'b0011110,
    ALU_SUBUR = 7'b0011111,

    ALU_XOR = 7'b0101111,
    ALU_OR  = 7'b0101110,
    ALU_AND = 7'b0010101,

    ALU_SRA = 7'b0100100,
    ALU_SRL = 7'b0100101,
    ALU_ROR = 7'b0100110,
    ALU_SLL = 7'b0100111,

    ALU_BEXT  = 7'b0101000,
    ALU_BEXTU = 7'b0101001,
    ALU_BINS  = 7'b0101010,
    ALU_BCLR  = 7'b0101011,
    ALU_BSET  = 7'b0101100,
    ALU_BREV  = 7'b1001001,

    ALU_FF1 = 7'b0110110,
    ALU_FL1 = 7'b0110111,
    ALU_CNT = 7'b0110100,
    ALU_CLB = 7'b0110101,

    ALU_EXTS = 7'b0111110,
    ALU_EXT  = 7'b0111111,

    ALU_LTS = 7'b0000000,
    ALU_LTU = 7'b0000001,
    ALU_LES = 7'b0000100,
    ALU_LEU = 7'b0000101,
    ALU_GTS = 7'b0001000,
    ALU_GTU = 7'b0001001,
    ALU_GES = 7'b0001010,
    ALU_GEU = 7'b0001011,
    ALU_EQ  = 7'b0001100,
    ALU_NE  = 7'b0001101,

    ALU_SLTS  = 7'b0000010,
    ALU_SLTU  = 7'b0000011,
    ALU_SLETS = 7'b0000110,
    ALU_SLETU = 7'b0000111,

    ALU_ABS   = 7'b0010100,
    ALU_CLIP  = 7'b0010110,
    ALU_CLIPU = 7'b0010111,

    ALU_INS = 7'b0101101,

    ALU_MIN  = 7'b0010000,
    ALU_MINU = 7'b0010001,
    ALU_MAX  = 7'b0010010,
    ALU_MAXU = 7'b0010011,

    ALU_DIVU = 7'b0110000,  // bit 0 is used for signed mode, bit 1 is used for remdiv
    ALU_DIV  = 7'b0110001,  // bit 0 is used for signed mode, bit 1 is used for remdiv
    ALU_REMU = 7'b0110010,  // bit 0 is used for signed mode, bit 1 is used for remdiv
    ALU_REM  = 7'b0110011,  // bit 0 is used for signed mode, bit 1 is used for remdiv

    ALU_SHUF  = 7'b0111010,
    ALU_SHUF2 = 7'b0111011,
    ALU_PCKLO = 7'b0111000,
    ALU_PCKHI = 7'b0111001

  } alu_opcode_e;

  parameter MUL_OP_WIDTH = 3;

  typedef enum logic [MUL_OP_WIDTH-1:0] {

    MUL_MAC32 = 3'b000,
    MUL_MSU32 = 3'b001,
    MUL_I     = 3'b010,
    MUL_IR    = 3'b011,
    MUL_DOT8  = 3'b100,
    MUL_DOT16 = 3'b101,
    MUL_H     = 3'b110

  } mul_opcode_e;

  parameter VEC_MODE32 = 2'b00;
  parameter VEC_MODE16 = 2'b10;
  parameter VEC_MODE8 = 2'b11;


  typedef enum logic [4:0] {
    RESET,
    BOOT_SET,
    SLEEP,
    WAIT_SLEEP,
    FIRST_FETCH,
    DECODE,
    IRQ_FLUSH_ELW,
    ELW_EXE,
    FLUSH_EX,
    FLUSH_WB,
    XRET_JUMP,
    DBG_TAKEN_ID,
    DBG_TAKEN_IF,
    DBG_FLUSH,
    DBG_WAIT_BRANCH,
    DECODE_HWLOOP
  } ctrl_state_e;


  parameter HAVERESET_INDEX = 0;
  parameter RUNNING_INDEX = 1;
  parameter HALTED_INDEX = 2;

  typedef enum logic [2:0] {
    HAVERESET = 3'b001,
    RUNNING   = 3'b010,
    HALTED    = 3'b100
  } debug_state_e;

  typedef enum logic {
    IDLE,
    BRANCH_WAIT
  } prefetch_state_e;

  typedef enum logic [2:0] {
    IDLE_MULT,
    STEP0,
    STEP1,
    STEP2,
    FINISH
  } mult_state_e;


  typedef enum logic [11:0] {


    CSR_USTATUS = 12'h000,  // Not included (PULP_SECURE = 0)

    CSR_FFLAGS = 12'h001,  // Included if FPU = 1
    CSR_FRM    = 12'h002,  // Included if FPU = 1
    CSR_FCSR   = 12'h003,  // Included if FPU = 1

    CSR_UTVEC = 12'h005,  // Not included (PULP_SECURE = 0)

    CSR_UEPC   = 12'h041,  // Not included (PULP_SECURE = 0)
    CSR_UCAUSE = 12'h042,  // Not included (PULP_SECURE = 0)


    CSR_LPSTART0 = 12'hCC0,  // Custom CSR. Included if PULP_HWLP = 1
    CSR_LPEND0   = 12'hCC1,  // Custom CSR. Included if PULP_HWLP = 1
    CSR_LPCOUNT0 = 12'hCC2,  // Custom CSR. Included if PULP_HWLP = 1
    CSR_LPSTART1 = 12'hCC4,  // Custom CSR. Included if PULP_HWLP = 1
    CSR_LPEND1   = 12'hCC5,  // Custom CSR. Included if PULP_HWLP = 1
    CSR_LPCOUNT1 = 12'hCC6,  // Custom CSR. Included if PULP_HWLP = 1

    CSR_UHARTID = 12'hCD0,  // Custom CSR. User Hart ID

    CSR_PRIVLV = 12'hCD1,  // Custom CSR. Privilege Level

    CSR_ZFINX = 12'hCD2,  // Custom CSR. ZFINX


    CSR_MSTATUS = 12'h300,
    CSR_MISA    = 12'h301,
    CSR_MIE     = 12'h304,
    CSR_MTVEC   = 12'h305,

    CSR_MCOUNTEREN    = 12'h306,
    CSR_MCOUNTINHIBIT = 12'h320,
    CSR_MHPMEVENT3    = 12'h323,
    CSR_MHPMEVENT4    = 12'h324,
    CSR_MHPMEVENT5    = 12'h325,
    CSR_MHPMEVENT6    = 12'h326,
    CSR_MHPMEVENT7    = 12'h327,
    CSR_MHPMEVENT8    = 12'h328,
    CSR_MHPMEVENT9    = 12'h329,
    CSR_MHPMEVENT10   = 12'h32A,
    CSR_MHPMEVENT11   = 12'h32B,
    CSR_MHPMEVENT12   = 12'h32C,
    CSR_MHPMEVENT13   = 12'h32D,
    CSR_MHPMEVENT14   = 12'h32E,
    CSR_MHPMEVENT15   = 12'h32F,
    CSR_MHPMEVENT16   = 12'h330,
    CSR_MHPMEVENT17   = 12'h331,
    CSR_MHPMEVENT18   = 12'h332,
    CSR_MHPMEVENT19   = 12'h333,
    CSR_MHPMEVENT20   = 12'h334,
    CSR_MHPMEVENT21   = 12'h335,
    CSR_MHPMEVENT22   = 12'h336,
    CSR_MHPMEVENT23   = 12'h337,
    CSR_MHPMEVENT24   = 12'h338,
    CSR_MHPMEVENT25   = 12'h339,
    CSR_MHPMEVENT26   = 12'h33A,
    CSR_MHPMEVENT27   = 12'h33B,
    CSR_MHPMEVENT28   = 12'h33C,
    CSR_MHPMEVENT29   = 12'h33D,
    CSR_MHPMEVENT30   = 12'h33E,
    CSR_MHPMEVENT31   = 12'h33F,

    CSR_MSCRATCH = 12'h340,
    CSR_MEPC     = 12'h341,
    CSR_MCAUSE   = 12'h342,
    CSR_MTVAL    = 12'h343,
    CSR_MIP      = 12'h344,

    CSR_PMPCFG0   = 12'h3A0,  // Not included (USE_PMP = 0)
    CSR_PMPCFG1   = 12'h3A1,  // Not included (USE_PMP = 0)
    CSR_PMPCFG2   = 12'h3A2,  // Not included (USE_PMP = 0)
    CSR_PMPCFG3   = 12'h3A3,  // Not included (USE_PMP = 0)
    CSR_PMPADDR0  = 12'h3B0,  // Not included (USE_PMP = 0)
    CSR_PMPADDR1  = 12'h3B1,  // Not included (USE_PMP = 0)
    CSR_PMPADDR2  = 12'h3B2,  // Not included (USE_PMP = 0)
    CSR_PMPADDR3  = 12'h3B3,  // Not included (USE_PMP = 0)
    CSR_PMPADDR4  = 12'h3B4,  // Not included (USE_PMP = 0)
    CSR_PMPADDR5  = 12'h3B5,  // Not included (USE_PMP = 0)
    CSR_PMPADDR6  = 12'h3B6,  // Not included (USE_PMP = 0)
    CSR_PMPADDR7  = 12'h3B7,  // Not included (USE_PMP = 0)
    CSR_PMPADDR8  = 12'h3B8,  // Not included (USE_PMP = 0)
    CSR_PMPADDR9  = 12'h3B9,  // Not included (USE_PMP = 0)
    CSR_PMPADDR10 = 12'h3BA,  // Not included (USE_PMP = 0)
    CSR_PMPADDR11 = 12'h3BB,  // Not included (USE_PMP = 0)
    CSR_PMPADDR12 = 12'h3BC,  // Not included (USE_PMP = 0)
    CSR_PMPADDR13 = 12'h3BD,  // Not included (USE_PMP = 0)
    CSR_PMPADDR14 = 12'h3BE,  // Not included (USE_PMP = 0)
    CSR_PMPADDR15 = 12'h3BF,  // Not included (USE_PMP = 0)

    CSR_TSELECT  = 12'h7A0,
    CSR_TDATA1   = 12'h7A1,
    CSR_TDATA2   = 12'h7A2,
    CSR_TDATA3   = 12'h7A3,
    CSR_TINFO    = 12'h7A4,
    CSR_MCONTEXT = 12'h7A8,
    CSR_SCONTEXT = 12'h7AA,

    CSR_DCSR = 12'h7B0,
    CSR_DPC  = 12'h7B1,

    CSR_DSCRATCH0 = 12'h7B2,
    CSR_DSCRATCH1 = 12'h7B3,

    CSR_MCYCLE        = 12'hB00,
    CSR_MINSTRET      = 12'hB02,
    CSR_MHPMCOUNTER3  = 12'hB03,
    CSR_MHPMCOUNTER4  = 12'hB04,
    CSR_MHPMCOUNTER5  = 12'hB05,
    CSR_MHPMCOUNTER6  = 12'hB06,
    CSR_MHPMCOUNTER7  = 12'hB07,
    CSR_MHPMCOUNTER8  = 12'hB08,
    CSR_MHPMCOUNTER9  = 12'hB09,
    CSR_MHPMCOUNTER10 = 12'hB0A,
    CSR_MHPMCOUNTER11 = 12'hB0B,
    CSR_MHPMCOUNTER12 = 12'hB0C,
    CSR_MHPMCOUNTER13 = 12'hB0D,
    CSR_MHPMCOUNTER14 = 12'hB0E,
    CSR_MHPMCOUNTER15 = 12'hB0F,
    CSR_MHPMCOUNTER16 = 12'hB10,
    CSR_MHPMCOUNTER17 = 12'hB11,
    CSR_MHPMCOUNTER18 = 12'hB12,
    CSR_MHPMCOUNTER19 = 12'hB13,
    CSR_MHPMCOUNTER20 = 12'hB14,
    CSR_MHPMCOUNTER21 = 12'hB15,
    CSR_MHPMCOUNTER22 = 12'hB16,
    CSR_MHPMCOUNTER23 = 12'hB17,
    CSR_MHPMCOUNTER24 = 12'hB18,
    CSR_MHPMCOUNTER25 = 12'hB19,
    CSR_MHPMCOUNTER26 = 12'hB1A,
    CSR_MHPMCOUNTER27 = 12'hB1B,
    CSR_MHPMCOUNTER28 = 12'hB1C,
    CSR_MHPMCOUNTER29 = 12'hB1D,
    CSR_MHPMCOUNTER30 = 12'hB1E,
    CSR_MHPMCOUNTER31 = 12'hB1F,

    CSR_MCYCLEH        = 12'hB80,
    CSR_MINSTRETH      = 12'hB82,
    CSR_MHPMCOUNTER3H  = 12'hB83,
    CSR_MHPMCOUNTER4H  = 12'hB84,
    CSR_MHPMCOUNTER5H  = 12'hB85,
    CSR_MHPMCOUNTER6H  = 12'hB86,
    CSR_MHPMCOUNTER7H  = 12'hB87,
    CSR_MHPMCOUNTER8H  = 12'hB88,
    CSR_MHPMCOUNTER9H  = 12'hB89,
    CSR_MHPMCOUNTER10H = 12'hB8A,
    CSR_MHPMCOUNTER11H = 12'hB8B,
    CSR_MHPMCOUNTER12H = 12'hB8C,
    CSR_MHPMCOUNTER13H = 12'hB8D,
    CSR_MHPMCOUNTER14H = 12'hB8E,
    CSR_MHPMCOUNTER15H = 12'hB8F,
    CSR_MHPMCOUNTER16H = 12'hB90,
    CSR_MHPMCOUNTER17H = 12'hB91,
    CSR_MHPMCOUNTER18H = 12'hB92,
    CSR_MHPMCOUNTER19H = 12'hB93,
    CSR_MHPMCOUNTER20H = 12'hB94,
    CSR_MHPMCOUNTER21H = 12'hB95,
    CSR_MHPMCOUNTER22H = 12'hB96,
    CSR_MHPMCOUNTER23H = 12'hB97,
    CSR_MHPMCOUNTER24H = 12'hB98,
    CSR_MHPMCOUNTER25H = 12'hB99,
    CSR_MHPMCOUNTER26H = 12'hB9A,
    CSR_MHPMCOUNTER27H = 12'hB9B,
    CSR_MHPMCOUNTER28H = 12'hB9C,
    CSR_MHPMCOUNTER29H = 12'hB9D,
    CSR_MHPMCOUNTER30H = 12'hB9E,
    CSR_MHPMCOUNTER31H = 12'hB9F,

    CSR_CYCLE        = 12'hC00,
    CSR_INSTRET      = 12'hC02,
    CSR_HPMCOUNTER3  = 12'hC03,
    CSR_HPMCOUNTER4  = 12'hC04,
    CSR_HPMCOUNTER5  = 12'hC05,
    CSR_HPMCOUNTER6  = 12'hC06,
    CSR_HPMCOUNTER7  = 12'hC07,
    CSR_HPMCOUNTER8  = 12'hC08,
    CSR_HPMCOUNTER9  = 12'hC09,
    CSR_HPMCOUNTER10 = 12'hC0A,
    CSR_HPMCOUNTER11 = 12'hC0B,
    CSR_HPMCOUNTER12 = 12'hC0C,
    CSR_HPMCOUNTER13 = 12'hC0D,
    CSR_HPMCOUNTER14 = 12'hC0E,
    CSR_HPMCOUNTER15 = 12'hC0F,
    CSR_HPMCOUNTER16 = 12'hC10,
    CSR_HPMCOUNTER17 = 12'hC11,
    CSR_HPMCOUNTER18 = 12'hC12,
    CSR_HPMCOUNTER19 = 12'hC13,
    CSR_HPMCOUNTER20 = 12'hC14,
    CSR_HPMCOUNTER21 = 12'hC15,
    CSR_HPMCOUNTER22 = 12'hC16,
    CSR_HPMCOUNTER23 = 12'hC17,
    CSR_HPMCOUNTER24 = 12'hC18,
    CSR_HPMCOUNTER25 = 12'hC19,
    CSR_HPMCOUNTER26 = 12'hC1A,
    CSR_HPMCOUNTER27 = 12'hC1B,
    CSR_HPMCOUNTER28 = 12'hC1C,
    CSR_HPMCOUNTER29 = 12'hC1D,
    CSR_HPMCOUNTER30 = 12'hC1E,
    CSR_HPMCOUNTER31 = 12'hC1F,

    CSR_CYCLEH        = 12'hC80,
    CSR_INSTRETH      = 12'hC82,
    CSR_HPMCOUNTER3H  = 12'hC83,
    CSR_HPMCOUNTER4H  = 12'hC84,
    CSR_HPMCOUNTER5H  = 12'hC85,
    CSR_HPMCOUNTER6H  = 12'hC86,
    CSR_HPMCOUNTER7H  = 12'hC87,
    CSR_HPMCOUNTER8H  = 12'hC88,
    CSR_HPMCOUNTER9H  = 12'hC89,
    CSR_HPMCOUNTER10H = 12'hC8A,
    CSR_HPMCOUNTER11H = 12'hC8B,
    CSR_HPMCOUNTER12H = 12'hC8C,
    CSR_HPMCOUNTER13H = 12'hC8D,
    CSR_HPMCOUNTER14H = 12'hC8E,
    CSR_HPMCOUNTER15H = 12'hC8F,
    CSR_HPMCOUNTER16H = 12'hC90,
    CSR_HPMCOUNTER17H = 12'hC91,
    CSR_HPMCOUNTER18H = 12'hC92,
    CSR_HPMCOUNTER19H = 12'hC93,
    CSR_HPMCOUNTER20H = 12'hC94,
    CSR_HPMCOUNTER21H = 12'hC95,
    CSR_HPMCOUNTER22H = 12'hC96,
    CSR_HPMCOUNTER23H = 12'hC97,
    CSR_HPMCOUNTER24H = 12'hC98,
    CSR_HPMCOUNTER25H = 12'hC99,
    CSR_HPMCOUNTER26H = 12'hC9A,
    CSR_HPMCOUNTER27H = 12'hC9B,
    CSR_HPMCOUNTER28H = 12'hC9C,
    CSR_HPMCOUNTER29H = 12'hC9D,
    CSR_HPMCOUNTER30H = 12'hC9E,
    CSR_HPMCOUNTER31H = 12'hC9F,

    CSR_MVENDORID = 12'hF11,
    CSR_MARCHID   = 12'hF12,
    CSR_MIMPID    = 12'hF13,
    CSR_MHARTID   = 12'hF14
  } csr_num_e;


  parameter CSR_OP_WIDTH = 2;

  typedef enum logic [CSR_OP_WIDTH-1:0] {
    CSR_OP_READ  = 2'b00,
    CSR_OP_WRITE = 2'b01,
    CSR_OP_SET   = 2'b10,
    CSR_OP_CLEAR = 2'b11
  } csr_opcode_e;

  parameter int unsigned CSR_MSIX_BIT = 3;
  parameter int unsigned CSR_MTIX_BIT = 7;
  parameter int unsigned CSR_MEIX_BIT = 11;
  parameter int unsigned CSR_MFIX_BIT_LOW = 16;
  parameter int unsigned CSR_MFIX_BIT_HIGH = 31;

  parameter SP_DVR0 = 16'h3000;
  parameter SP_DCR0 = 16'h3008;
  parameter SP_DMR1 = 16'h3010;
  parameter SP_DMR2 = 16'h3011;

  parameter SP_DVR_MSB = 8'h00;
  parameter SP_DCR_MSB = 8'h01;
  parameter SP_DMR_MSB = 8'h02;
  parameter SP_DSR_MSB = 8'h04;

  typedef enum logic [1:0] {
    PRIV_LVL_M = 2'b11,
    PRIV_LVL_H = 2'b10,
    PRIV_LVL_S = 2'b01,
    PRIV_LVL_U = 2'b00
  } PrivLvl_t;

  typedef struct packed {
    logic uie;
    logic mie;
    logic upie;
    logic mpie;
    PrivLvl_t mpp;
    logic mprv;
  } Status_t;

  typedef struct packed {
    logic [31:28] xdebugver;
    logic [27:16] zero2;
    logic ebreakm;
    logic zero1;
    logic ebreaks;
    logic ebreaku;
    logic stepie;
    logic stopcount;
    logic stoptime;
    logic [8:6] cause;
    logic zero0;
    logic mprven;
    logic nmip;
    logic step;
    PrivLvl_t prv;
  } Dcsr_t;

  typedef enum logic [1:0] {
    FS_OFF     = 2'b00,
    FS_INITIAL = 2'b01,
    FS_CLEAN   = 2'b10,
    FS_DIRTY   = 2'b11
  } FS_t;

  parameter MVENDORID_OFFSET = 7'h2;  // Final byte without parity bit
  parameter MVENDORID_BANK = 25'hC;  // Number of continuation codes

  parameter MARCHID = 32'h4;

  parameter MHPMCOUNTER_WIDTH = 64;


  parameter SEL_REGFILE = 2'b00;
  parameter SEL_FW_EX = 2'b01;
  parameter SEL_FW_WB = 2'b10;

  parameter OP_A_REGA_OR_FWD = 3'b000;
  parameter OP_A_CURRPC = 3'b001;
  parameter OP_A_IMM = 3'b010;
  parameter OP_A_REGB_OR_FWD = 3'b011;
  parameter OP_A_REGC_OR_FWD = 3'b100;

  parameter IMMA_Z = 1'b0;
  parameter IMMA_ZERO = 1'b1;

  parameter OP_B_REGB_OR_FWD = 3'b000;
  parameter OP_B_REGC_OR_FWD = 3'b001;
  parameter OP_B_IMM = 3'b010;
  parameter OP_B_REGA_OR_FWD = 3'b011;
  parameter OP_B_BMASK = 3'b100;

  parameter IMMB_I = 4'b0000;
  parameter IMMB_S = 4'b0001;
  parameter IMMB_U = 4'b0010;
  parameter IMMB_PCINCR = 4'b0011;
  parameter IMMB_S2 = 4'b0100;
  parameter IMMB_S3 = 4'b0101;
  parameter IMMB_VS = 4'b0110;
  parameter IMMB_VU = 4'b0111;
  parameter IMMB_SHUF = 4'b1000;
  parameter IMMB_CLIP = 4'b1001;
  parameter IMMB_BI = 4'b1011;

  parameter BMASK_A_ZERO = 1'b0;
  parameter BMASK_A_S3 = 1'b1;

  parameter BMASK_B_S2 = 2'b00;
  parameter BMASK_B_S3 = 2'b01;
  parameter BMASK_B_ZERO = 2'b10;
  parameter BMASK_B_ONE = 2'b11;

  parameter BMASK_A_REG = 1'b0;
  parameter BMASK_A_IMM = 1'b1;
  parameter BMASK_B_REG = 1'b0;
  parameter BMASK_B_IMM = 1'b1;


  parameter MIMM_ZERO = 1'b0;
  parameter MIMM_S3 = 1'b1;

  parameter OP_C_REGC_OR_FWD = 2'b00;
  parameter OP_C_REGB_OR_FWD = 2'b01;
  parameter OP_C_JT = 2'b10;

  parameter BRANCH_NONE = 2'b00;
  parameter BRANCH_JAL = 2'b01;
  parameter BRANCH_JALR = 2'b10;
  parameter BRANCH_COND = 2'b11;  // conditional branches

  parameter JT_JAL = 2'b01;
  parameter JT_JALR = 2'b10;
  parameter JT_COND = 2'b11;

  parameter AMO_LR = 5'b00010;
  parameter AMO_SC = 5'b00011;
  parameter AMO_SWAP = 5'b00001;
  parameter AMO_ADD = 5'b00000;
  parameter AMO_XOR = 5'b00100;
  parameter AMO_AND = 5'b01100;
  parameter AMO_OR = 5'b01000;
  parameter AMO_MIN = 5'b10000;
  parameter AMO_MAX = 5'b10100;
  parameter AMO_MINU = 5'b11000;
  parameter AMO_MAXU = 5'b11100;


  parameter PC_BOOT = 4'b0000;
  parameter PC_JUMP = 4'b0010;
  parameter PC_BRANCH = 4'b0011;
  parameter PC_EXCEPTION = 4'b0100;
  parameter PC_FENCEI = 4'b0001;
  parameter PC_MRET = 4'b0101;
  parameter PC_URET = 4'b0110;
  parameter PC_DRET = 4'b0111;
  parameter PC_HWLOOP = 4'b1000;

  parameter EXC_PC_EXCEPTION = 3'b000;
  parameter EXC_PC_IRQ = 3'b001;

  parameter EXC_PC_DBD = 3'b010;
  parameter EXC_PC_DBE = 3'b011;

  parameter EXC_CAUSE_INSTR_FAULT = 5'h01;
  parameter EXC_CAUSE_ILLEGAL_INSN = 5'h02;
  parameter EXC_CAUSE_BREAKPOINT = 5'h03;
  parameter EXC_CAUSE_LOAD_FAULT = 5'h05;
  parameter EXC_CAUSE_STORE_FAULT = 5'h07;
  parameter EXC_CAUSE_ECALL_UMODE = 5'h08;
  parameter EXC_CAUSE_ECALL_MMODE = 5'h0B;

  parameter IRQ_MASK = 32'hFFFF0888;

  parameter TRAP_MACHINE = 2'b00;
  parameter TRAP_USER = 2'b01;

  parameter DBG_CAUSE_NONE = 3'h0;
  parameter DBG_CAUSE_EBREAK = 3'h1;
  parameter DBG_CAUSE_TRIGGER = 3'h2;
  parameter DBG_CAUSE_HALTREQ = 3'h3;
  parameter DBG_CAUSE_STEP = 3'h4;
  parameter DBG_CAUSE_RSTHALTREQ = 3'h5;

  parameter DBG_SETS_W = 6;

  parameter DBG_SETS_IRQ = 5;
  parameter DBG_SETS_ECALL = 4;
  parameter DBG_SETS_EILL = 3;
  parameter DBG_SETS_ELSU = 2;
  parameter DBG_SETS_EBRK = 1;
  parameter DBG_SETS_SSTE = 0;

  parameter DBG_CAUSE_HALT = 6'h1F;

  typedef enum logic [3:0] {
    XDEBUGVER_NO     = 4'd0,  // no external debug support
    XDEBUGVER_STD    = 4'd4,  // external debug according to RISC-V debug spec
    XDEBUGVER_NONSTD = 4'd15  // debug not conforming to RISC-V debug spec
  } x_debug_ver_e;

  typedef enum logic [3:0] {
    TTYPE_MCONTROL = 4'h2,
    TTYPE_ICOUNT   = 4'h3,
    TTYPE_ITRIGGER = 4'h4,
    TTYPE_ETRIGGER = 4'h5
  } trigger_type_e;

  parameter bit C_RVF = 1'b1;  // Is F extension enabled
  parameter bit C_RVD = 1'b0;  // Is D extension enabled - NOT SUPPORTED CURRENTLY

  parameter bit C_XF16 = 1'b0;  // Is half-precision float extension (Xf16) enabled
  parameter bit C_XF16ALT = 1'b0; // Is alternative half-precision float extension (Xf16alt) enabled
  parameter bit C_XF8 = 1'b0;  // Is quarter-precision float extension (Xf8) enabled
  parameter bit C_XFVEC = 1'b0;  // Is vectorial float extension (Xfvec) enabled

  parameter int unsigned C_LAT_FP64 = 'd0;
  parameter int unsigned C_LAT_FP16 = 'd0;
  parameter int unsigned C_LAT_FP16ALT = 'd0;
  parameter int unsigned C_LAT_FP8 = 'd0;
  parameter int unsigned C_LAT_DIVSQRT = 'd1;  // divsqrt post-processing pipe


  parameter C_FLEN = C_RVD ? 64 :  // D ext.
  C_RVF ? 32 :  // F ext.
  C_XF16 ? 16 :  // Xf16 ext.
  C_XF16ALT ? 16 :  // Xf16alt ext.
  C_XF8 ? 8 :  // Xf8 ext.
  0;  // Unused in case of no FP

  parameter C_FFLAG = 5;
  parameter C_RM = 3;

endpackage


package cv32e40p_apu_core_pkg;

  parameter APU_NARGS_CPU = 3;
  parameter APU_WOP_CPU = 6;
  parameter APU_NDSFLAGS_CPU = 15;
  parameter APU_NUSFLAGS_CPU = 5;

endpackage  // cv32e40p_apu_core_pkg


package cv32e40p_fpu_pkg;



  localparam int unsigned NUM_FP_FORMATS = 5;  // change me to add formats
  localparam int unsigned FP_FORMAT_BITS = $clog2(NUM_FP_FORMATS);

  typedef enum logic [FP_FORMAT_BITS-1:0] {
    FP32    = 'd0,
    FP64    = 'd1,
    FP16    = 'd2,
    FP8     = 'd3,
    FP16ALT = 'd4
  } fp_format_e;


  localparam int unsigned NUM_INT_FORMATS = 4;  // change me to add formats
  localparam int unsigned INT_FORMAT_BITS = $clog2(NUM_INT_FORMATS);

  typedef enum logic [INT_FORMAT_BITS-1:0] {
    INT8,
    INT16,
    INT32,
    INT64
  } int_format_e;


  localparam int unsigned OP_BITS = 4;

  typedef enum logic [OP_BITS-1:0] {
    FMADD,
    FNMSUB,
    ADD,
    MUL,  // ADDMUL operation group
    DIV,
    SQRT,  // DIVSQRT operation group
    SGNJ,
    MINMAX,
    CMP,
    CLASSIFY,  // NONCOMP operation group
    F2F,
    F2I,
    I2F,
    CPKAB,
    CPKCD  // CONV operation group
  } operation_e;

endpackage


module cv32e40p_alu_div #(
    parameter C_WIDTH     = 32,
    parameter C_LOG_WIDTH = 6
) (
    input  logic                   Clk_CI,
    input  logic                   Rst_RBI,
    input  logic [    C_WIDTH-1:0] OpA_DI,
    input  logic [    C_WIDTH-1:0] OpB_DI,
    input  logic [C_LOG_WIDTH-1:0] OpBShift_DI,
    input  logic                   OpBIsZero_SI,
    input  logic                   OpBSign_SI,  // gate this to 0 in case of unsigned ops
    input  logic [            1:0] OpCode_SI,  // 0: udiv, 2: urem, 1: div, 3: rem
    input  logic                   InVld_SI,
    input  logic                   OutRdy_SI,
    output logic                   OutVld_SO,
    output logic [    C_WIDTH-1:0] Res_DO
);


  logic [C_WIDTH-1:0] ResReg_DP, ResReg_DN;
  logic [C_WIDTH-1:0] ResReg_DP_rev;
  logic [C_WIDTH-1:0] AReg_DP, AReg_DN;
  logic [C_WIDTH-1:0] BReg_DP, BReg_DN;

  logic RemSel_SN, RemSel_SP;
  logic CompInv_SN, CompInv_SP;
  logic ResInv_SN, ResInv_SP;

  logic [C_WIDTH-1:0] AddMux_D;
  logic [C_WIDTH-1:0] AddOut_D;
  logic [C_WIDTH-1:0] AddTmp_D;
  logic [C_WIDTH-1:0] BMux_D;
  logic [C_WIDTH-1:0] OutMux_D;

  logic [C_LOG_WIDTH-1:0] Cnt_DP, Cnt_DN;
  logic CntZero_S;

  logic ARegEn_S, BRegEn_S, ResRegEn_S, ABComp_S, PmSel_S, LoadEn_S;

  enum logic [1:0] {
    IDLE,
    DIVIDE,
    FINISH
  }
      State_SN, State_SP;



  assign PmSel_S  = LoadEn_S & ~(OpCode_SI[0] & (OpA_DI[$high(OpA_DI)] ^ OpBSign_SI));

  assign AddMux_D = (LoadEn_S) ? OpA_DI : BReg_DP;

  assign BMux_D   = (LoadEn_S) ? OpB_DI : {CompInv_SP, (BReg_DP[$high(BReg_DP):1])};

  genvar index;
  generate
    for (index = 0; index < C_WIDTH; index++) begin : gen_bit_swapping
      assign ResReg_DP_rev[index] = ResReg_DP[C_WIDTH-1-index];
    end
  endgenerate

  assign OutMux_D = (RemSel_SP) ? AReg_DP : ResReg_DP_rev;

  assign Res_DO = (ResInv_SP) ? -$signed(OutMux_D) : OutMux_D;

  assign ABComp_S    = ((AReg_DP == BReg_DP) | ((AReg_DP > BReg_DP) ^ CompInv_SP)) & ((|AReg_DP) | OpBIsZero_SI);

  assign AddTmp_D = (LoadEn_S) ? 0 : AReg_DP;
  assign AddOut_D = (PmSel_S) ? AddTmp_D + AddMux_D : AddTmp_D - $signed(AddMux_D);


  assign Cnt_DN = (LoadEn_S) ? OpBShift_DI : (~CntZero_S) ? Cnt_DP - 1 : Cnt_DP;

  assign CntZero_S = ~(|Cnt_DP);


  always_comb begin : p_fsm
    State_SN   = State_SP;

    OutVld_SO  = 1'b0;

    LoadEn_S   = 1'b0;

    ARegEn_S   = 1'b0;
    BRegEn_S   = 1'b0;
    ResRegEn_S = 1'b0;

    case (State_SP)
      IDLE: begin
        OutVld_SO = 1'b1;

        if (InVld_SI) begin
          OutVld_SO = 1'b0;
          ARegEn_S  = 1'b1;
          BRegEn_S  = 1'b1;
          LoadEn_S  = 1'b1;
          State_SN  = DIVIDE;
        end
      end
      DIVIDE: begin

        ARegEn_S   = ABComp_S;
        BRegEn_S   = 1'b1;
        ResRegEn_S = 1'b1;

        if (CntZero_S) begin
          State_SN = FINISH;
        end
      end
      FINISH: begin
        OutVld_SO = 1'b1;

        if (OutRdy_SI) begin
          State_SN = IDLE;
        end
      end
      default:  /* default */;
    endcase
  end



  assign RemSel_SN = (LoadEn_S) ? OpCode_SI[1] : RemSel_SP;
  assign CompInv_SN = (LoadEn_S) ? OpBSign_SI : CompInv_SP;
  assign ResInv_SN = (LoadEn_S) ? (~OpBIsZero_SI | OpCode_SI[1]) & OpCode_SI[0] & (OpA_DI[$high(
      OpA_DI
  )] ^ OpBSign_SI) : ResInv_SP;

  assign AReg_DN = (ARegEn_S) ? AddOut_D : AReg_DP;
  assign BReg_DN = (BRegEn_S) ? BMux_D : BReg_DP;
  assign ResReg_DN = (LoadEn_S) ? '0 : (ResRegEn_S) ? {
    ABComp_S, ResReg_DP[$high(ResReg_DP):1]
  } : ResReg_DP;

  always_ff @(posedge Clk_CI or posedge Rst_RBI) begin : p_regs
    if (Rst_RBI) begin
      State_SP   <= IDLE;
      AReg_DP    <= '0;
      BReg_DP    <= '0;
      ResReg_DP  <= '0;
      Cnt_DP     <= '0;
      RemSel_SP  <= 1'b0;
      CompInv_SP <= 1'b0;
      ResInv_SP  <= 1'b0;
    end else begin
      State_SP   <= State_SN;
      AReg_DP    <= AReg_DN;
      BReg_DP    <= BReg_DN;
      ResReg_DP  <= ResReg_DN;
      Cnt_DP     <= Cnt_DN;
      RemSel_SP  <= RemSel_SN;
      CompInv_SP <= CompInv_SN;
      ResInv_SP  <= ResInv_SN;
    end
  end


`ifdef CV32E40P_ASSERT_ON
  initial begin : p_assertions
    assert (C_LOG_WIDTH == $clog2(C_WIDTH + 1))
    else $error("C_LOG_WIDTH must be $clog2(C_WIDTH+1)");
  end
`endif

endmodule  // serDiv


module cv32e40p_ff_one #(
    parameter LEN = 32
) (
    input logic [LEN-1:0] in_i,

    output logic [$clog2(LEN)-1:0] first_one_o,
    output logic                   no_ones_o
);

  localparam NUM_LEVELS = $clog2(LEN);

  logic [          LEN-1:0][NUM_LEVELS-1:0] index_lut;
  logic [2**NUM_LEVELS-1:0]                 sel_nodes;
  logic [2**NUM_LEVELS-1:0][NUM_LEVELS-1:0] index_nodes;



  generate
    genvar j;
    for (j = 0; j < LEN; j++) begin : gen_index_lut
      assign index_lut[j] = $unsigned(j);
    end
  endgenerate

  generate
    genvar k;
    genvar l;
    genvar level;

    assign sel_nodes[2**NUM_LEVELS-1] = 1'b0;

    for (level = 0; level < NUM_LEVELS; level++) begin : gen_tree
      if (level < NUM_LEVELS - 1) begin : gen_non_root_level
        for (l = 0; l < 2 ** level; l++) begin : gen_node
          assign sel_nodes[2**level-1+l]   = sel_nodes[2**(level+1)-1+l*2] | sel_nodes[2**(level+1)-1+l*2+1];
          assign index_nodes[2**level-1+l] = (sel_nodes[2**(level+1)-1+l*2] == 1'b1) ?
                                           index_nodes[2**(level+1)-1+l*2] : index_nodes[2**(level+1)-1+l*2+1];
        end
      end
      if (level == NUM_LEVELS - 1) begin : gen_root_level
        for (k = 0; k < 2 ** level; k++) begin : gen_node
          if (k * 2 < LEN - 1) begin : gen_two
            assign sel_nodes[2**level-1+k] = in_i[k*2] | in_i[k*2+1];
            assign index_nodes[2**level-1+k] = (in_i[k*2] == 1'b1) ? index_lut[k*2] : index_lut[k*2+1];
          end
          if (k * 2 == LEN - 1) begin : gen_one
            assign sel_nodes[2**level-1+k]   = in_i[k*2];
            assign index_nodes[2**level-1+k] = index_lut[k*2];
          end
          if (k * 2 > LEN - 1) begin : gen_out_of_range
            assign sel_nodes[2**level-1+k]   = 1'b0;
            assign index_nodes[2**level-1+k] = '0;
          end
        end
      end
    end
  endgenerate


  assign first_one_o = index_nodes[0];
  assign no_ones_o   = ~sel_nodes[0];

endmodule


module cv32e40p_popcnt (
    input  logic [31:0] in_i,
    output logic [ 5:0] result_o
);

  logic [15:0][1:0] cnt_l1;
  logic [ 7:0][2:0] cnt_l2;
  logic [ 3:0][3:0] cnt_l3;
  logic [ 1:0][4:0] cnt_l4;

  genvar l, m, n, p;
  generate
    for (l = 0; l < 16; l++) begin : gen_cnt_l1
      assign cnt_l1[l] = {1'b0, in_i[2*l]} + {1'b0, in_i[2*l+1]};
    end
  endgenerate

  generate
    for (m = 0; m < 8; m++) begin : gen_cnt_l2
      assign cnt_l2[m] = {1'b0, cnt_l1[2*m]} + {1'b0, cnt_l1[2*m+1]};
    end
  endgenerate

  generate
    for (n = 0; n < 4; n++) begin : gen_cnt_l3
      assign cnt_l3[n] = {1'b0, cnt_l2[2*n]} + {1'b0, cnt_l2[2*n+1]};
    end
  endgenerate

  generate
    for (p = 0; p < 2; p++) begin : gen_cnt_l4
      assign cnt_l4[p] = {1'b0, cnt_l3[2*p]} + {1'b0, cnt_l3[2*p+1]};
    end
  endgenerate

  assign result_o = {1'b0, cnt_l4[0]} + {1'b0, cnt_l4[1]};

endmodule




module cv32e40p_alu
  import cv32e40p_pkg::*;
(
    input logic               clk,
    input logic               reset,
    input logic               enable_i,
    input alu_opcode_e        operator_i,
    input logic        [31:0] operand_a_i,
    input logic        [31:0] operand_b_i,
    input logic        [31:0] operand_c_i,

    input logic [1:0] vector_mode_i,
    input logic [4:0] bmask_a_i,
    input logic [4:0] bmask_b_i,
    input logic [1:0] imm_vec_ext_i,

    input logic       is_clpx_i,
    input logic       is_subrot_i,
    input logic [1:0] clpx_shift_i,

    output logic [31:0] result_o,
    output logic        comparison_result_o,

    output logic ready_o,
    input  logic ex_ready_i
);

  logic [31:0] operand_a_rev;
  logic [31:0] operand_a_neg;
  logic [31:0] operand_a_neg_rev;

  assign operand_a_neg = ~operand_a_i;

  generate
    genvar k;
    for (k = 0; k < 32; k++) begin : gen_operand_a_rev
      assign operand_a_rev[k] = operand_a_i[31-k];
    end
  endgenerate

  generate
    genvar m;
    for (m = 0; m < 32; m++) begin : gen_operand_a_neg_rev
      assign operand_a_neg_rev[m] = operand_a_neg[31-m];
    end
  endgenerate

  logic [31:0] operand_b_neg;

  assign operand_b_neg = ~operand_b_i;


  logic [ 5:0] div_shift;
  logic        div_valid;
  logic [31:0] bmask;


  logic        adder_op_b_negate;
  logic [31:0] adder_op_a, adder_op_b;
  logic [35:0] adder_in_a, adder_in_b;
  logic [31:0] adder_result;
  logic [36:0] adder_result_expanded;


  assign adder_op_b_negate = (operator_i == ALU_SUB) || (operator_i == ALU_SUBR) ||
                             (operator_i == ALU_SUBU) || (operator_i == ALU_SUBUR) || is_subrot_i;

  assign adder_op_a = (operator_i == ALU_ABS) ? operand_a_neg : (is_subrot_i ? {
    operand_b_i[15:0], operand_a_i[31:16]
  } : operand_a_i);

  assign adder_op_b = adder_op_b_negate ? (is_subrot_i ? ~{
    operand_a_i[15:0], operand_b_i[31:16]
  } : operand_b_neg) : operand_b_i;

  always_comb begin
    adder_in_a[0]     = 1'b1;
    adder_in_a[8:1]   = adder_op_a[7:0];
    adder_in_a[9]     = 1'b1;
    adder_in_a[17:10] = adder_op_a[15:8];
    adder_in_a[18]    = 1'b1;
    adder_in_a[26:19] = adder_op_a[23:16];
    adder_in_a[27]    = 1'b1;
    adder_in_a[35:28] = adder_op_a[31:24];

    adder_in_b[0]     = 1'b0;
    adder_in_b[8:1]   = adder_op_b[7:0];
    adder_in_b[9]     = 1'b0;
    adder_in_b[17:10] = adder_op_b[15:8];
    adder_in_b[18]    = 1'b0;
    adder_in_b[26:19] = adder_op_b[23:16];
    adder_in_b[27]    = 1'b0;
    adder_in_b[35:28] = adder_op_b[31:24];

    if (adder_op_b_negate || (operator_i == ALU_ABS || operator_i == ALU_CLIP)) begin
      adder_in_b[0] = 1'b1;

      case (vector_mode_i)
        VEC_MODE16: begin
          adder_in_b[18] = 1'b1;
        end

        VEC_MODE8: begin
          adder_in_b[9]  = 1'b1;
          adder_in_b[18] = 1'b1;
          adder_in_b[27] = 1'b1;
        end
      endcase

    end else begin
      case (vector_mode_i)
        VEC_MODE16: begin
          adder_in_a[18] = 1'b0;
        end

        VEC_MODE8: begin
          adder_in_a[9]  = 1'b0;
          adder_in_a[18] = 1'b0;
          adder_in_a[27] = 1'b0;
        end
      endcase
    end
  end

  assign adder_result_expanded = $signed(adder_in_a) + $signed(adder_in_b);
  assign adder_result = {
    adder_result_expanded[35:28],
    adder_result_expanded[26:19],
    adder_result_expanded[17:10],
    adder_result_expanded[8:1]
  };


  logic [31:0] adder_round_value;
  logic [31:0] adder_round_result;

  assign adder_round_value  = ((operator_i == ALU_ADDR) || (operator_i == ALU_SUBR) ||
                               (operator_i == ALU_ADDUR) || (operator_i == ALU_SUBUR)) ?
                                {
    1'b0, bmask[31:1]
  } : '0;
  assign adder_round_result = adder_result + adder_round_value;



  logic        shift_left;  // should we shift left
  logic        shift_use_round;
  logic        shift_arithmetic;

  logic [31:0] shift_amt_left;  // amount of shift, if to the left
  logic [31:0] shift_amt;  // amount of shift, to the right
  logic [31:0] shift_amt_int;  // amount of shift, used for the actual shifters
  logic [31:0] shift_amt_norm;  // amount of shift, used for normalization
  logic [31:0] shift_op_a;  // input of the shifter
  logic [31:0] shift_result;
  logic [31:0] shift_right_result;
  logic [31:0] shift_left_result;
  logic [15:0] clpx_shift_ex;

  assign shift_amt = div_valid ? div_shift : operand_b_i;

  always_comb begin
    case (vector_mode_i)
      VEC_MODE16: begin
        shift_amt_left[15:0]  = shift_amt[31:16];
        shift_amt_left[31:16] = shift_amt[15:0];
      end

      VEC_MODE8: begin
        shift_amt_left[7:0]   = shift_amt[31:24];
        shift_amt_left[15:8]  = shift_amt[23:16];
        shift_amt_left[23:16] = shift_amt[15:8];
        shift_amt_left[31:24] = shift_amt[7:0];
      end

      default: // VEC_MODE32
      begin
        shift_amt_left[31:0] = shift_amt[31:0];
      end
    endcase
  end

  assign shift_left = (operator_i == ALU_SLL) || (operator_i == ALU_BINS) ||
                      (operator_i == ALU_FL1) || (operator_i == ALU_CLB)  ||
                      (operator_i == ALU_DIV) || (operator_i == ALU_DIVU) ||
                      (operator_i == ALU_REM) || (operator_i == ALU_REMU) ||
                      (operator_i == ALU_BREV);

  assign shift_use_round = (operator_i == ALU_ADD)   || (operator_i == ALU_SUB)   ||
                           (operator_i == ALU_ADDR)  || (operator_i == ALU_SUBR)  ||
                           (operator_i == ALU_ADDU)  || (operator_i == ALU_SUBU)  ||
                           (operator_i == ALU_ADDUR) || (operator_i == ALU_SUBUR);

  assign shift_arithmetic = (operator_i == ALU_SRA)  || (operator_i == ALU_BEXT) ||
                            (operator_i == ALU_ADD)  || (operator_i == ALU_SUB)  ||
                            (operator_i == ALU_ADDR) || (operator_i == ALU_SUBR);

  assign shift_op_a    = shift_left ? operand_a_rev :
                          (shift_use_round ? adder_round_result : operand_a_i);
  assign shift_amt_int = shift_use_round ? shift_amt_norm :
                          (shift_left ? shift_amt_left : shift_amt);

  assign shift_amt_norm = is_clpx_i ? {clpx_shift_ex, clpx_shift_ex} : {4{3'b000, bmask_b_i}};

  assign clpx_shift_ex = $unsigned(clpx_shift_i);

  logic [63:0] shift_op_a_32;

  assign shift_op_a_32 = (operator_i == ALU_ROR) ? {
        shift_op_a, shift_op_a
      } : $signed(
          {{32{shift_arithmetic & shift_op_a[31]}}, shift_op_a}
      );

  always_comb begin
    case (vector_mode_i)
      VEC_MODE16: begin
        shift_right_result[31:16] = $signed(
            {shift_arithmetic & shift_op_a[31], shift_op_a[31:16]}
        ) >>> shift_amt_int[19:16];
        shift_right_result[15:0] = $signed(
            {shift_arithmetic & shift_op_a[15], shift_op_a[15:0]}
        ) >>> shift_amt_int[3:0];
      end

      VEC_MODE8: begin
        shift_right_result[31:24] = $signed(
            {shift_arithmetic & shift_op_a[31], shift_op_a[31:24]}
        ) >>> shift_amt_int[26:24];
        shift_right_result[23:16] = $signed(
            {shift_arithmetic & shift_op_a[23], shift_op_a[23:16]}
        ) >>> shift_amt_int[18:16];
        shift_right_result[15:8] = $signed(
            {shift_arithmetic & shift_op_a[15], shift_op_a[15:8]}
        ) >>> shift_amt_int[10:8];
        shift_right_result[7:0] = $signed(
            {shift_arithmetic & shift_op_a[7], shift_op_a[7:0]}
        ) >>> shift_amt_int[2:0];
      end

      default: // VEC_MODE32
      begin
        shift_right_result = shift_op_a_32 >> shift_amt_int[4:0];
      end
    endcase
    ;  // case (vec_mode_i)
  end

  genvar j;
  generate
    for (j = 0; j < 32; j++) begin : gen_shift_left_result
      assign shift_left_result[j] = shift_right_result[31-j];
    end
  endgenerate

  assign shift_result = shift_left ? shift_left_result : shift_right_result;



  logic [ 3:0] is_equal;
  logic [ 3:0] is_greater;  // handles both signed and unsigned forms

  logic [ 3:0] cmp_signed;
  logic [ 3:0] is_equal_vec;
  logic [ 3:0] is_greater_vec;
  logic [31:0] operand_b_eq;
  logic        is_equal_clip;


  always_comb begin
    operand_b_eq = operand_b_neg;
    if (operator_i == ALU_CLIPU) operand_b_eq = '0;
    else operand_b_eq = operand_b_neg;
  end
  assign is_equal_clip = operand_a_i == operand_b_eq;

  always_comb begin
    cmp_signed = 4'b0;

    unique case (operator_i)
      ALU_GTS,
      ALU_GES,
      ALU_LTS,
      ALU_LES,
      ALU_SLTS,
      ALU_SLETS,
      ALU_MIN,
      ALU_MAX,
      ALU_ABS,
      ALU_CLIP,
      ALU_CLIPU: begin
        case (vector_mode_i)
          VEC_MODE8:  cmp_signed[3:0] = 4'b1111;
          VEC_MODE16: cmp_signed[3:0] = 4'b1010;
          default:    cmp_signed[3:0] = 4'b1000;
        endcase
      end

      default: ;
    endcase
  end

  genvar i;
  generate
    for (i = 0; i < 4; i++) begin : gen_is_vec
      assign is_equal_vec[i] = (operand_a_i[8*i+7:8*i] == operand_b_i[8*i+7:i*8]);
      assign is_greater_vec[i] = $signed(
          {operand_a_i[8*i+7] & cmp_signed[i], operand_a_i[8*i+7:8*i]}
      ) > $signed(
          {operand_b_i[8*i+7] & cmp_signed[i], operand_b_i[8*i+7:i*8]}
      );
    end
  endgenerate

  always_comb begin
    is_equal[3:0] = {4{is_equal_vec[3] & is_equal_vec[2] & is_equal_vec[1] & is_equal_vec[0]}};
    is_greater[3:0] = {4{is_greater_vec[3] | (is_equal_vec[3] & (is_greater_vec[2]
                                            | (is_equal_vec[2] & (is_greater_vec[1]
                                             | (is_equal_vec[1] & (is_greater_vec[0]))))))}};

    case (vector_mode_i)
      VEC_MODE16: begin
        is_equal[1:0]   = {2{is_equal_vec[0] & is_equal_vec[1]}};
        is_equal[3:2]   = {2{is_equal_vec[2] & is_equal_vec[3]}};
        is_greater[1:0] = {2{is_greater_vec[1] | (is_equal_vec[1] & is_greater_vec[0])}};
        is_greater[3:2] = {2{is_greater_vec[3] | (is_equal_vec[3] & is_greater_vec[2])}};
      end

      VEC_MODE8: begin
        is_equal[3:0]   = is_equal_vec[3:0];
        is_greater[3:0] = is_greater_vec[3:0];
      end

      default: ;  // see default assignment
    endcase
  end

  logic [3:0] cmp_result;

  always_comb begin
    cmp_result = is_equal;
    unique case (operator_i)
      ALU_EQ:                                 cmp_result = is_equal;
      ALU_NE:                                 cmp_result = ~is_equal;
      ALU_GTS, ALU_GTU:                       cmp_result = is_greater;
      ALU_GES, ALU_GEU:                       cmp_result = is_greater | is_equal;
      ALU_LTS, ALU_SLTS, ALU_LTU, ALU_SLTU:   cmp_result = ~(is_greater | is_equal);
      ALU_SLETS, ALU_SLETU, ALU_LES, ALU_LEU: cmp_result = ~is_greater;
      default:                                ;
    endcase
  end

  assign comparison_result_o = cmp_result[3];


  logic [31:0] result_minmax;
  logic [ 3:0] sel_minmax;
  logic        do_min;
  logic [31:0] minmax_b;

  assign minmax_b = (operator_i == ALU_ABS) ? adder_result : operand_b_i;

  assign do_min   = (operator_i == ALU_MIN)  || (operator_i == ALU_MINU) ||
                    (operator_i == ALU_CLIP) || (operator_i == ALU_CLIPU);

  assign sel_minmax[3:0] = is_greater ^ {4{do_min}};

  assign result_minmax[31:24] = (sel_minmax[3] == 1'b1) ? operand_a_i[31:24] : minmax_b[31:24];
  assign result_minmax[23:16] = (sel_minmax[2] == 1'b1) ? operand_a_i[23:16] : minmax_b[23:16];
  assign result_minmax[15:8] = (sel_minmax[1] == 1'b1) ? operand_a_i[15:8] : minmax_b[15:8];
  assign result_minmax[7:0] = (sel_minmax[0] == 1'b1) ? operand_a_i[7:0] : minmax_b[7:0];

  logic [31:0] clip_result;  // result of clip and clip

  always_comb begin
    clip_result = result_minmax;
    if (operator_i == ALU_CLIPU) begin
      if (operand_a_i[31] || is_equal_clip) begin
        clip_result = '0;
      end else begin
        clip_result = result_minmax;
      end
    end else begin
      if (adder_result_expanded[36] || is_equal_clip) begin
        clip_result = operand_b_neg;
      end else begin
        clip_result = result_minmax;
      end
    end

  end


  logic [3:0][1:0] shuffle_byte_sel;  // select byte in register: 31:24, 23:16, 15:8, 7:0
  logic [3:0]      shuffle_reg_sel;  // select register: rD/rS2 or rS1
  logic [1:0]      shuffle_reg1_sel;  // select register rD or rS2 for next stage
  logic [1:0]      shuffle_reg0_sel;
  logic [3:0]      shuffle_through;

  logic [31:0] shuffle_r1, shuffle_r0;
  logic [31:0] shuffle_r1_in, shuffle_r0_in;
  logic [31:0] shuffle_result;
  logic [31:0] pack_result;


  always_comb begin
    shuffle_reg_sel  = '0;
    shuffle_reg1_sel = 2'b01;
    shuffle_reg0_sel = 2'b10;
    shuffle_through  = '1;

    unique case (operator_i)
      ALU_EXT, ALU_EXTS: begin
        if (operator_i == ALU_EXTS) shuffle_reg1_sel = 2'b11;

        if (vector_mode_i == VEC_MODE8) begin
          shuffle_reg_sel[3:1] = 3'b111;
          shuffle_reg_sel[0]   = 1'b0;
        end else begin
          shuffle_reg_sel[3:2] = 2'b11;
          shuffle_reg_sel[1:0] = 2'b00;
        end
      end

      ALU_PCKLO: begin
        shuffle_reg1_sel = 2'b00;

        if (vector_mode_i == VEC_MODE8) begin
          shuffle_through = 4'b0011;
          shuffle_reg_sel = 4'b0001;
        end else begin
          shuffle_reg_sel = 4'b0011;
        end
      end

      ALU_PCKHI: begin
        shuffle_reg1_sel = 2'b00;

        if (vector_mode_i == VEC_MODE8) begin
          shuffle_through = 4'b1100;
          shuffle_reg_sel = 4'b0100;
        end else begin
          shuffle_reg_sel = 4'b0011;
        end
      end

      ALU_SHUF2: begin
        unique case (vector_mode_i)
          VEC_MODE8: begin
            shuffle_reg_sel[3] = ~operand_b_i[26];
            shuffle_reg_sel[2] = ~operand_b_i[18];
            shuffle_reg_sel[1] = ~operand_b_i[10];
            shuffle_reg_sel[0] = ~operand_b_i[2];
          end

          VEC_MODE16: begin
            shuffle_reg_sel[3] = ~operand_b_i[17];
            shuffle_reg_sel[2] = ~operand_b_i[17];
            shuffle_reg_sel[1] = ~operand_b_i[1];
            shuffle_reg_sel[0] = ~operand_b_i[1];
          end
          default: ;
        endcase
      end

      ALU_INS: begin
        unique case (vector_mode_i)
          VEC_MODE8: begin
            shuffle_reg0_sel = 2'b00;
            unique case (imm_vec_ext_i)
              2'b00: begin
                shuffle_reg_sel[3:0] = 4'b1110;
              end
              2'b01: begin
                shuffle_reg_sel[3:0] = 4'b1101;
              end
              2'b10: begin
                shuffle_reg_sel[3:0] = 4'b1011;
              end
              2'b11: begin
                shuffle_reg_sel[3:0] = 4'b0111;
              end
            endcase
          end
          VEC_MODE16: begin
            shuffle_reg0_sel   = 2'b01;
            shuffle_reg_sel[3] = ~imm_vec_ext_i[0];
            shuffle_reg_sel[2] = ~imm_vec_ext_i[0];
            shuffle_reg_sel[1] = imm_vec_ext_i[0];
            shuffle_reg_sel[0] = imm_vec_ext_i[0];
          end
          default: ;
        endcase
      end

      default: ;
    endcase
  end

  always_comb begin
    shuffle_byte_sel = '0;

    unique case (operator_i)
      ALU_EXTS, ALU_EXT: begin
        unique case (vector_mode_i)
          VEC_MODE8: begin
            shuffle_byte_sel[3] = imm_vec_ext_i[1:0];
            shuffle_byte_sel[2] = imm_vec_ext_i[1:0];
            shuffle_byte_sel[1] = imm_vec_ext_i[1:0];
            shuffle_byte_sel[0] = imm_vec_ext_i[1:0];
          end

          VEC_MODE16: begin
            shuffle_byte_sel[3] = {imm_vec_ext_i[0], 1'b1};
            shuffle_byte_sel[2] = {imm_vec_ext_i[0], 1'b1};
            shuffle_byte_sel[1] = {imm_vec_ext_i[0], 1'b1};
            shuffle_byte_sel[0] = {imm_vec_ext_i[0], 1'b0};
          end

          default: ;
        endcase
      end

      ALU_PCKLO: begin
        unique case (vector_mode_i)
          VEC_MODE8: begin
            shuffle_byte_sel[3] = 2'b00;
            shuffle_byte_sel[2] = 2'b00;
            shuffle_byte_sel[1] = 2'b00;
            shuffle_byte_sel[0] = 2'b00;
          end

          VEC_MODE16: begin
            shuffle_byte_sel[3] = 2'b01;
            shuffle_byte_sel[2] = 2'b00;
            shuffle_byte_sel[1] = 2'b01;
            shuffle_byte_sel[0] = 2'b00;
          end

          default: ;
        endcase
      end

      ALU_PCKHI: begin
        unique case (vector_mode_i)
          VEC_MODE8: begin
            shuffle_byte_sel[3] = 2'b00;
            shuffle_byte_sel[2] = 2'b00;
            shuffle_byte_sel[1] = 2'b00;
            shuffle_byte_sel[0] = 2'b00;
          end

          VEC_MODE16: begin
            shuffle_byte_sel[3] = 2'b11;
            shuffle_byte_sel[2] = 2'b10;
            shuffle_byte_sel[1] = 2'b11;
            shuffle_byte_sel[0] = 2'b10;
          end

          default: ;
        endcase
      end

      ALU_SHUF2, ALU_SHUF: begin
        unique case (vector_mode_i)
          VEC_MODE8: begin
            shuffle_byte_sel[3] = operand_b_i[25:24];
            shuffle_byte_sel[2] = operand_b_i[17:16];
            shuffle_byte_sel[1] = operand_b_i[9:8];
            shuffle_byte_sel[0] = operand_b_i[1:0];
          end

          VEC_MODE16: begin
            shuffle_byte_sel[3] = {operand_b_i[16], 1'b1};
            shuffle_byte_sel[2] = {operand_b_i[16], 1'b0};
            shuffle_byte_sel[1] = {operand_b_i[0], 1'b1};
            shuffle_byte_sel[0] = {operand_b_i[0], 1'b0};
          end
          default: ;
        endcase
      end

      ALU_INS: begin
        shuffle_byte_sel[3] = 2'b11;
        shuffle_byte_sel[2] = 2'b10;
        shuffle_byte_sel[1] = 2'b01;
        shuffle_byte_sel[0] = 2'b00;
      end

      default: ;
    endcase
  end

  assign shuffle_r0_in = shuffle_reg0_sel[1] ?
                          operand_a_i :
                          (shuffle_reg0_sel[0] ? {2{operand_a_i[15:0]}} : {4{operand_a_i[7:0]}});

  assign shuffle_r1_in = shuffle_reg1_sel[1] ? {
    {8{operand_a_i[31]}}, {8{operand_a_i[23]}}, {8{operand_a_i[15]}}, {8{operand_a_i[7]}}
  } : (shuffle_reg1_sel[0] ? operand_c_i : operand_b_i);

  assign shuffle_r0[31:24] = shuffle_byte_sel[3][1] ?
                              (shuffle_byte_sel[3][0] ? shuffle_r0_in[31:24] : shuffle_r0_in[23:16]) :
                              (shuffle_byte_sel[3][0] ? shuffle_r0_in[15: 8] : shuffle_r0_in[ 7: 0]);
  assign shuffle_r0[23:16] = shuffle_byte_sel[2][1] ?
                              (shuffle_byte_sel[2][0] ? shuffle_r0_in[31:24] : shuffle_r0_in[23:16]) :
                              (shuffle_byte_sel[2][0] ? shuffle_r0_in[15: 8] : shuffle_r0_in[ 7: 0]);
  assign shuffle_r0[15: 8] = shuffle_byte_sel[1][1] ?
                              (shuffle_byte_sel[1][0] ? shuffle_r0_in[31:24] : shuffle_r0_in[23:16]) :
                              (shuffle_byte_sel[1][0] ? shuffle_r0_in[15: 8] : shuffle_r0_in[ 7: 0]);
  assign shuffle_r0[ 7: 0] = shuffle_byte_sel[0][1] ?
                              (shuffle_byte_sel[0][0] ? shuffle_r0_in[31:24] : shuffle_r0_in[23:16]) :
                              (shuffle_byte_sel[0][0] ? shuffle_r0_in[15: 8] : shuffle_r0_in[ 7: 0]);

  assign shuffle_r1[31:24] = shuffle_byte_sel[3][1] ?
                              (shuffle_byte_sel[3][0] ? shuffle_r1_in[31:24] : shuffle_r1_in[23:16]) :
                              (shuffle_byte_sel[3][0] ? shuffle_r1_in[15: 8] : shuffle_r1_in[ 7: 0]);
  assign shuffle_r1[23:16] = shuffle_byte_sel[2][1] ?
                              (shuffle_byte_sel[2][0] ? shuffle_r1_in[31:24] : shuffle_r1_in[23:16]) :
                              (shuffle_byte_sel[2][0] ? shuffle_r1_in[15: 8] : shuffle_r1_in[ 7: 0]);
  assign shuffle_r1[15: 8] = shuffle_byte_sel[1][1] ?
                              (shuffle_byte_sel[1][0] ? shuffle_r1_in[31:24] : shuffle_r1_in[23:16]) :
                              (shuffle_byte_sel[1][0] ? shuffle_r1_in[15: 8] : shuffle_r1_in[ 7: 0]);
  assign shuffle_r1[ 7: 0] = shuffle_byte_sel[0][1] ?
                              (shuffle_byte_sel[0][0] ? shuffle_r1_in[31:24] : shuffle_r1_in[23:16]) :
                              (shuffle_byte_sel[0][0] ? shuffle_r1_in[15: 8] : shuffle_r1_in[ 7: 0]);

  assign shuffle_result[31:24] = shuffle_reg_sel[3] ? shuffle_r1[31:24] : shuffle_r0[31:24];
  assign shuffle_result[23:16] = shuffle_reg_sel[2] ? shuffle_r1[23:16] : shuffle_r0[23:16];
  assign shuffle_result[15:8] = shuffle_reg_sel[1] ? shuffle_r1[15:8] : shuffle_r0[15:8];
  assign shuffle_result[7:0] = shuffle_reg_sel[0] ? shuffle_r1[7:0] : shuffle_r0[7:0];

  assign pack_result[31:24] = shuffle_through[3] ? shuffle_result[31:24] : operand_c_i[31:24];
  assign pack_result[23:16] = shuffle_through[2] ? shuffle_result[23:16] : operand_c_i[23:16];
  assign pack_result[15:8] = shuffle_through[1] ? shuffle_result[15:8] : operand_c_i[15:8];
  assign pack_result[7:0] = shuffle_through[0] ? shuffle_result[7:0] : operand_c_i[7:0];



  logic [31:0] ff_input;  // either op_a_i or its bit reversed version
  logic [ 5:0] cnt_result;  // population count
  logic [ 5:0] clb_result;  // count leading bits
  logic [ 4:0] ff1_result;  // holds the index of the first '1'
  logic        ff_no_one;  // if no ones are found
  logic [ 4:0] fl1_result;  // holds the index of the last '1'
  logic [ 5:0] bitop_result;  // result of all bitop operations muxed together

  cv32e40p_popcnt popcnt_i (
      .in_i    (operand_a_i),
      .result_o(cnt_result)
  );

  always_comb begin
    ff_input = '0;

    case (operator_i)
      ALU_FF1: ff_input = operand_a_i;

      ALU_DIVU, ALU_REMU, ALU_FL1: ff_input = operand_a_rev;

      ALU_DIV, ALU_REM, ALU_CLB: begin
        if (operand_a_i[31]) ff_input = operand_a_neg_rev;
        else ff_input = operand_a_rev;
      end
    endcase
  end

  cv32e40p_ff_one ff_one_i (
      .in_i       (ff_input),
      .first_one_o(ff1_result),
      .no_ones_o  (ff_no_one)
  );

  assign fl1_result = 5'd31 - ff1_result;
  assign clb_result = ff1_result - 5'd1;

  always_comb begin
    bitop_result = '0;
    case (operator_i)
      ALU_FF1: bitop_result = ff_no_one ? 6'd32 : {1'b0, ff1_result};
      ALU_FL1: bitop_result = ff_no_one ? 6'd32 : {1'b0, fl1_result};
      ALU_CNT: bitop_result = cnt_result;
      ALU_CLB: begin
        if (ff_no_one) begin
          if (operand_a_i[31]) bitop_result = 6'd31;
          else bitop_result = '0;
        end else begin
          bitop_result = clb_result;
        end
      end
      default: ;
    endcase
  end



  logic extract_is_signed;
  logic extract_sign;
  logic [31:0] bmask_first, bmask_inv;
  logic [31:0] bextins_and;
  logic [31:0] bextins_result, bclr_result, bset_result;


  assign bmask_first       = {32'hFFFFFFFE} << bmask_a_i;
  assign bmask             = (~bmask_first) << bmask_b_i;
  assign bmask_inv         = ~bmask;

  assign bextins_and       = (operator_i == ALU_BINS) ? operand_c_i : {32{extract_sign}};

  assign extract_is_signed = (operator_i == ALU_BEXT);
  assign extract_sign      = extract_is_signed & shift_result[bmask_a_i];

  assign bextins_result    = (bmask & shift_result) | (bextins_and & bmask_inv);

  assign bclr_result       = operand_a_i & bmask_inv;
  assign bset_result       = operand_a_i | bmask;


  logic [31:0] radix_2_rev;
  logic [31:0] radix_4_rev;
  logic [31:0] radix_8_rev;
  logic [31:0] reverse_result;
  logic [ 1:0] radix_mux_sel;

  assign radix_mux_sel = bmask_a_i[1:0];

  generate
    for (j = 0; j < 32; j++) begin : gen_radix_2_rev
      assign radix_2_rev[j] = shift_result[31-j];
    end
    for (j = 0; j < 16; j++) begin : gen_radix_4_rev
      assign radix_4_rev[2*j+1:2*j] = shift_result[31-j*2:31-j*2-1];
    end
    for (j = 0; j < 10; j++) begin : gen_radix_8_rev
      assign radix_8_rev[3*j+2:3*j] = shift_result[31-j*3:31-j*3-2];
    end
    assign radix_8_rev[31:30] = 2'b0;
  endgenerate

  always_comb begin
    reverse_result = '0;

    unique case (radix_mux_sel)
      2'b00: reverse_result = radix_2_rev;
      2'b01: reverse_result = radix_4_rev;
      2'b10: reverse_result = radix_8_rev;

      default: reverse_result = radix_2_rev;
    endcase
  end


  logic [31:0] result_div;
  logic        div_ready;
  logic        div_signed;
  logic        div_op_a_signed;
  logic [ 5:0] div_shift_int;

  assign div_signed = operator_i[0];

  assign div_op_a_signed = operand_a_i[31] & div_signed;

  assign div_shift_int = ff_no_one ? 6'd31 : clb_result;
  assign div_shift = div_shift_int + (div_op_a_signed ? 6'd0 : 6'd1);

  assign div_valid = enable_i & ((operator_i == ALU_DIV) || (operator_i == ALU_DIVU) ||
                     (operator_i == ALU_REM) || (operator_i == ALU_REMU));

  cv32e40p_alu_div alu_div_i (
      .Clk_CI (clk),
      .Rst_RBI(reset),

      .OpA_DI      (operand_b_i),
      .OpB_DI      (shift_left_result),
      .OpBShift_DI (div_shift),
      .OpBIsZero_SI((cnt_result == 0)),

      .OpBSign_SI(div_op_a_signed),
      .OpCode_SI (operator_i[1:0]),

      .Res_DO(result_div),

      .InVld_SI (div_valid),
      .OutRdy_SI(ex_ready_i),
      .OutVld_SO(div_ready)
  );


  always_comb begin
    result_o = '0;

    unique case (operator_i)
      ALU_AND: result_o = operand_a_i & operand_b_i;
      ALU_OR:  result_o = operand_a_i | operand_b_i;
      ALU_XOR: result_o = operand_a_i ^ operand_b_i;

      ALU_ADD, ALU_ADDR, ALU_ADDU, ALU_ADDUR,
      ALU_SUB, ALU_SUBR, ALU_SUBU, ALU_SUBUR,
      ALU_SLL,
      ALU_SRL, ALU_SRA,
      ALU_ROR:
      result_o = shift_result;

      ALU_BINS, ALU_BEXT, ALU_BEXTU: result_o = bextins_result;

      ALU_BCLR: result_o = bclr_result;
      ALU_BSET: result_o = bset_result;

      ALU_BREV: result_o = reverse_result;

      ALU_SHUF, ALU_SHUF2, ALU_PCKLO, ALU_PCKHI, ALU_EXT, ALU_EXTS, ALU_INS: result_o = pack_result;

      ALU_MIN, ALU_MINU, ALU_MAX, ALU_MAXU: result_o = result_minmax;

      ALU_ABS: result_o = is_clpx_i ? {adder_result[31:16], operand_a_i[15:0]} : result_minmax;

      ALU_CLIP, ALU_CLIPU: result_o = clip_result;

      ALU_EQ, ALU_NE, ALU_GTU, ALU_GEU, ALU_LTU, ALU_LEU, ALU_GTS, ALU_GES, ALU_LTS, ALU_LES: begin
        result_o[31:24] = {8{cmp_result[3]}};
        result_o[23:16] = {8{cmp_result[2]}};
        result_o[15:8]  = {8{cmp_result[1]}};
        result_o[7:0]   = {8{cmp_result[0]}};
      end
      ALU_SLTS, ALU_SLTU, ALU_SLETS, ALU_SLETU: result_o = {31'b0, comparison_result_o};

      ALU_FF1, ALU_FL1, ALU_CLB, ALU_CNT: result_o = {26'h0, bitop_result[5:0]};

      ALU_DIV, ALU_DIVU, ALU_REM, ALU_REMU: result_o = result_div;

      default: ;  // default case to suppress unique warning
    endcase
  end

  assign ready_o = div_ready;

endmodule

`endif /* CV32E40P_ALU */


`ifndef CV32E40P_ALU_NOPARAM
`define CV32E40P_ALU_NOPARAM

module CV32E40P_ALU_noparam
(
  input logic [5-1:0] bmask_a_i ,
  input logic [5-1:0] bmask_b_i ,
  input logic [1-1:0] clk ,
  input logic [2-1:0] clpx_shift_i ,
  output logic [1-1:0] comparison_result_o ,
  input logic [1-1:0] enable_i ,
  input logic [1-1:0] ex_ready_i ,
  input logic [2-1:0] imm_vec_ext_i ,
  input logic [1-1:0] is_clpx_i ,
  input logic [1-1:0] is_subrot_i ,
  input logic [32-1:0] operand_a_i ,
  input logic [32-1:0] operand_b_i ,
  input logic [32-1:0] operand_c_i ,
  input logic [7-1:0] operator_i ,
  output logic [1-1:0] ready_o ,
  input logic [1-1:0] reset ,
  output logic [32-1:0] result_o ,
  input logic [2-1:0] vector_mode_i 
);
  cv32e40p_alu
  #(
  ) v
  (
    .bmask_a_i( bmask_a_i ),
    .bmask_b_i( bmask_b_i ),
    .clk( clk ),
    .clpx_shift_i( clpx_shift_i ),
    .comparison_result_o( comparison_result_o ),
    .enable_i( enable_i ),
    .ex_ready_i( ex_ready_i ),
    .imm_vec_ext_i( imm_vec_ext_i ),
    .is_clpx_i( is_clpx_i ),
    .is_subrot_i( is_subrot_i ),
    .operand_a_i( operand_a_i ),
    .operand_b_i( operand_b_i ),
    .operand_c_i( operand_c_i ),
    .operator_i( operator_i ),
    .ready_o( ready_o ),
    .reset( reset ),
    .result_o( result_o ),
    .vector_mode_i( vector_mode_i )
  );
endmodule

`endif /* CV32E40P_ALU_NOPARAM */




module ALURTL__cad2bcaa3a8de18d
(
  input  logic [0:0] clk ,
  output logic [0:0] fu_fin_req ,
  input  logic [0:0] opt_launch_en ,
  output logic [0:0] opt_launch_rdy ,
  output logic [0:0] opt_launch_rdy_nxt ,
  input  logic [0:0] opt_pipeline_fin_en ,
  input  logic [0:0] opt_pipeline_fin_propagate_en ,
  input  logic [0:0] opt_pipeline_inter_en ,
  input  logic [0:0] opt_propagate_en ,
  input  logic [31:0] recv_const_msg ,
  output logic [0:0] recv_const_req ,
  input  logic [0:0] recv_opt_en ,
  input  logic [5:0] recv_opt_msg_ctrl ,
  input  logic [0:0] recv_predicate_en ,
  input  CGRAData_1__predicate_1 recv_predicate_msg ,
  input  logic [0:0] reset ,
  input logic [0:0] from_mem_rdata__en  ,
  input CGRAData_64_1__payload_64__predicate_1 from_mem_rdata__msg  ,
  output logic [0:0] from_mem_rdata__rdy  ,
  input logic [0:0] recv_in__en [0:3] ,
  input CGRAData_64_1__payload_64__predicate_1 recv_in__msg [0:3] ,
  output logic [0:0] recv_in__rdy [0:3] ,
  output logic [0:0] send_out__en [0:1] ,
  output CGRAData_64_1__payload_64__predicate_1 send_out__msg [0:1] ,
  input logic [0:0] send_out__rdy [0:1] ,
  output logic [0:0] to_mem_raddr__en  ,
  output logic [6:0] to_mem_raddr__msg  ,
  input logic [0:0] to_mem_raddr__rdy  ,
  output logic [0:0] to_mem_waddr__en  ,
  output logic [6:0] to_mem_waddr__msg  ,
  input logic [0:0] to_mem_waddr__rdy  ,
  output logic [0:0] to_mem_wdata__en  ,
  output CGRAData_64_1__payload_64__predicate_1 to_mem_wdata__msg  ,
  input logic [0:0] to_mem_wdata__rdy  
);
  localparam CGRAData_64_1__payload_64__predicate_1 const_zero  = { 64'd0, 1'd0 };
  localparam logic [0:0] __const__LOCAL_OPT_NAH  = 1'd0;
  localparam logic [5:0] __const__OPT_ADD  = 6'd2;
  localparam logic [0:0] __const__LOCAL_OPT_ADD  = 1'd1;
  localparam logic [5:0] __const__OPT_ADD_CONST  = 6'd25;
  localparam logic [1:0] __const__LOCAL_OPT_ADD_CONST  = 2'd2;
  localparam logic [5:0] __const__OPT_INC  = 6'd3;
  localparam logic [1:0] __const__LOCAL_OPT_INC  = 2'd3;
  localparam logic [5:0] __const__OPT_SUB  = 6'd4;
  localparam logic [2:0] __const__LOCAL_OPT_SUB  = 3'd4;
  localparam logic [5:0] __const__OPT_PAS  = 6'd31;
  localparam logic [2:0] __const__LOCAL_OPT_PAS  = 3'd5;
  localparam logic [1:0] __const__num_outports_at_opt_launch  = 2'd2;
  logic [0:0] latency;
  logic [0:0] launch_rdy;
  logic [0:0] launch_rdy_nxt;
  logic [2:0] local_opt_ctrl;
  logic [2:0] local_opt_ctrl_nxt;

  logic [4:0] alu_element_bmask_a_i [0:1];
  logic [4:0] alu_element_bmask_b_i [0:1];
  logic [0:0] alu_element_clk [0:1];
  logic [1:0] alu_element_clpx_shift_i [0:1];
  logic [0:0] alu_element_comparison_result_o [0:1];
  logic [0:0] alu_element_enable_i [0:1];
  logic [0:0] alu_element_ex_ready_i [0:1];
  logic [1:0] alu_element_imm_vec_ext_i [0:1];
  logic [0:0] alu_element_is_clpx_i [0:1];
  logic [0:0] alu_element_is_subrot_i [0:1];
  logic [31:0] alu_element_operand_a_i [0:1];
  logic [31:0] alu_element_operand_b_i [0:1];
  logic [31:0] alu_element_operand_c_i [0:1];
  logic [6:0] alu_element_operator_i [0:1];
  logic [0:0] alu_element_ready_o [0:1];
  logic [0:0] alu_element_reset [0:1];
  logic [31:0] alu_element_result_o [0:1];
  logic [1:0] alu_element_vector_mode_i [0:1];

  CV32E40P_ALU_noparam alu_element__0
  (
    .bmask_a_i( alu_element_bmask_a_i[0] ),
    .bmask_b_i( alu_element_bmask_b_i[0] ),
    .clk( alu_element_clk[0] ),
    .clpx_shift_i( alu_element_clpx_shift_i[0] ),
    .comparison_result_o( alu_element_comparison_result_o[0] ),
    .enable_i( alu_element_enable_i[0] ),
    .ex_ready_i( alu_element_ex_ready_i[0] ),
    .imm_vec_ext_i( alu_element_imm_vec_ext_i[0] ),
    .is_clpx_i( alu_element_is_clpx_i[0] ),
    .is_subrot_i( alu_element_is_subrot_i[0] ),
    .operand_a_i( alu_element_operand_a_i[0] ),
    .operand_b_i( alu_element_operand_b_i[0] ),
    .operand_c_i( alu_element_operand_c_i[0] ),
    .operator_i( alu_element_operator_i[0] ),
    .ready_o( alu_element_ready_o[0] ),
    .reset( alu_element_reset[0] ),
    .result_o( alu_element_result_o[0] ),
    .vector_mode_i( alu_element_vector_mode_i[0] )
  );

  CV32E40P_ALU_noparam alu_element__1
  (
    .bmask_a_i( alu_element_bmask_a_i[1] ),
    .bmask_b_i( alu_element_bmask_b_i[1] ),
    .clk( alu_element_clk[1] ),
    .clpx_shift_i( alu_element_clpx_shift_i[1] ),
    .comparison_result_o( alu_element_comparison_result_o[1] ),
    .enable_i( alu_element_enable_i[1] ),
    .ex_ready_i( alu_element_ex_ready_i[1] ),
    .imm_vec_ext_i( alu_element_imm_vec_ext_i[1] ),
    .is_clpx_i( alu_element_is_clpx_i[1] ),
    .is_subrot_i( alu_element_is_subrot_i[1] ),
    .operand_a_i( alu_element_operand_a_i[1] ),
    .operand_b_i( alu_element_operand_b_i[1] ),
    .operand_c_i( alu_element_operand_c_i[1] ),
    .operator_i( alu_element_operator_i[1] ),
    .ready_o( alu_element_ready_o[1] ),
    .reset( alu_element_reset[1] ),
    .result_o( alu_element_result_o[1] ),
    .vector_mode_i( alu_element_vector_mode_i[1] )
  );


  
  always_comb begin : opt_decode
    local_opt_ctrl_nxt = 3'( __const__LOCAL_OPT_NAH );
    recv_const_req = 1'd0;
    if ( recv_opt_en ) begin
      if ( recv_opt_msg_ctrl == 6'( __const__OPT_ADD ) ) begin
        local_opt_ctrl_nxt = 3'( __const__LOCAL_OPT_ADD );
      end
      if ( recv_opt_msg_ctrl == 6'( __const__OPT_ADD_CONST ) ) begin
        local_opt_ctrl_nxt = 3'( __const__LOCAL_OPT_ADD_CONST );
        recv_const_req = 1'd1;
      end
      if ( recv_opt_msg_ctrl == 6'( __const__OPT_INC ) ) begin
        local_opt_ctrl_nxt = 3'( __const__LOCAL_OPT_INC );
      end
      if ( recv_opt_msg_ctrl == 6'( __const__OPT_SUB ) ) begin
        local_opt_ctrl_nxt = 3'( __const__LOCAL_OPT_SUB );
      end
      if ( recv_opt_msg_ctrl == 6'( __const__OPT_PAS ) ) begin
        local_opt_ctrl_nxt = 3'( __const__LOCAL_OPT_PAS );
      end
    end
  end

  
  always_comb begin : opt_launch
    for ( int unsigned i = 1'd0; i < 2'( __const__num_outports_at_opt_launch ); i += 1'd1 ) begin
      send_out__msg[1'(i)] = { 64'd0, 1'd0 };
      send_out__en[1'(i)] = 1'd0;
    end
    launch_rdy = 1'd1;
    launch_rdy_nxt = 1'd1;
    if ( opt_launch_en ) begin
      if ( local_opt_ctrl == 3'( __const__LOCAL_OPT_ADD ) ) begin
        send_out__en[1'd0] = 1'd1;
        send_out__msg[1'd0].payload = recv_in__msg[2'd0].payload + recv_in__msg[2'd1].payload;
        send_out__msg[1'd0].predicate = recv_in__msg[2'd0].predicate & recv_in__msg[2'd1].predicate;
      end
      if ( local_opt_ctrl == 3'( __const__LOCAL_OPT_ADD_CONST ) ) begin
        send_out__en[1'd0] = 1'd1;
        send_out__msg[1'd0].payload = recv_in__msg[2'd0].payload + { { 32 { recv_const_msg[31] } }, recv_const_msg };
        send_out__msg[1'd0].predicate = recv_in__msg[2'd0].predicate;
      end
      if ( local_opt_ctrl == 3'( __const__LOCAL_OPT_INC ) ) begin
        send_out__en[1'd0] = 1'd1;
        send_out__msg[1'd0].payload = recv_in__msg[2'd0].payload + 64'd1;
        send_out__msg[1'd0].predicate = recv_in__msg[2'd0].predicate;
      end
      if ( local_opt_ctrl == 3'( __const__LOCAL_OPT_SUB ) ) begin
        send_out__en[1'd0] = 1'd1;
        send_out__msg[1'd0].payload = recv_in__msg[2'd0].payload - recv_in__msg[2'd1].payload;
        send_out__msg[1'd0].predicate = recv_in__msg[2'd0].predicate;
      end
      if ( recv_opt_msg_ctrl == 6'( __const__LOCAL_OPT_PAS ) ) begin
        send_out__en[1'd0] = 1'd1;
        send_out__msg[1'd0].payload = recv_in__msg[2'd0].payload;
        send_out__msg[1'd0].predicate = recv_in__msg[2'd0].predicate;
      end
      if ( recv_predicate_en == 1'd1 ) begin
        send_out__msg[1'd0].predicate = send_out__msg[1'd0].predicate & recv_predicate_msg.predicate;
      end
    end
  end

  
  always_comb begin : opt_pipeline
    fu_fin_req = 1'd0;
    opt_launch_rdy_nxt = 1'd1;
    opt_launch_rdy = 1'd1;
    if ( local_opt_ctrl_nxt != 3'( __const__LOCAL_OPT_NAH ) ) begin
      fu_fin_req = 1'd1;
      opt_launch_rdy_nxt = launch_rdy_nxt;
    end
    if ( local_opt_ctrl != 3'( __const__LOCAL_OPT_NAH ) ) begin
      opt_launch_rdy = launch_rdy;
    end
  end

  
  always_comb begin : update_mem
    to_mem_waddr__en = 1'd0;
    to_mem_wdata__en = 1'd0;
    to_mem_wdata__msg = const_zero;
    to_mem_waddr__msg = 7'd0;
    to_mem_raddr__msg = 7'd0;
    to_mem_raddr__en = 1'd0;
    from_mem_rdata__rdy = 1'd0;
  end

  
  always_ff @(posedge clk) begin : fu_propagate_sync
    if ( reset | ( ~opt_propagate_en ) ) begin
      local_opt_ctrl <= 3'( __const__LOCAL_OPT_NAH );
    end
    else
      local_opt_ctrl <= local_opt_ctrl_nxt;
  end

  assign alu_element_clk[0] = clk;
  assign alu_element_reset[0] = reset;
  assign alu_element_clk[1] = clk;
  assign alu_element_reset[1] = reset;

endmodule



module FlexibleFuRTL__91761f0c1c309163
(
  input  logic [0:0] clk ,
  input  logic [0:0] fu_dry_run_ack ,
  input  logic [0:0] fu_dry_run_begin ,
  input  logic [0:0] fu_execution_ini ,
  input  logic [0:0] fu_execution_valid ,
  input  logic [0:0] fu_opt_enable ,
  input  logic [0:0] fu_propagate_en ,
  output logic [0:0] fu_propagate_rdy ,
  output logic [0:0] recv_const_ack ,
  input  logic [31:0] recv_const_data ,
  input  logic [5:0] recv_opt_msg_ctrl ,
  input  logic [2:0] recv_opt_msg_fu_in [0:3],
  input  logic [5:0] recv_opt_msg_out_routine ,
  input  logic [0:0] recv_opt_msg_predicate ,
  output logic [3:0] recv_port_ack ,
  input  CGRAData_64_1__payload_64__predicate_1 recv_port_data [0:3],
  input  logic [3:0] recv_port_valid ,
  output logic [0:0] recv_predicate_ack ,
  input  CGRAData_1__predicate_1 recv_predicate_data ,
  input  logic [0:0] recv_predicate_valid ,
  input  logic [0:0] reset ,
  input  logic [0:0] send_port_ack ,
  output CGRAData_64_1__payload_64__predicate_1 send_port_data [0:1],
  output logic [1:0] send_port_valid ,
  input logic [0:0] from_mem_rdata__en [0:5] ,
  input CGRAData_64_1__payload_64__predicate_1 from_mem_rdata__msg [0:5] ,
  output logic [0:0] from_mem_rdata__rdy [0:5] ,
  output logic [0:0] to_mem_raddr__en [0:5] ,
  output logic [6:0] to_mem_raddr__msg [0:5] ,
  input logic [0:0] to_mem_raddr__rdy [0:5] ,
  output logic [0:0] to_mem_waddr__en [0:5] ,
  output logic [6:0] to_mem_waddr__msg [0:5] ,
  input logic [0:0] to_mem_waddr__rdy [0:5] ,
  output logic [0:0] to_mem_wdata__en [0:5] ,
  output CGRAData_64_1__payload_64__predicate_1 to_mem_wdata__msg [0:5] ,
  input logic [0:0] to_mem_wdata__rdy [0:5] 
);
  localparam logic [2:0] __const__num_xbar_outports_at_decode_process  = 3'd4;
  localparam logic [2:0] __const__num_xbar_inports_at_decode_process  = 3'd4;
  localparam logic [2:0] __const__num_xbar_outports_at_opt_propagate  = 3'd4;
  localparam logic [2:0] __const__num_xbar_inports_at_opt_propagate  = 3'd4;
  localparam logic [1:0] __const__STAGE_NORMAL  = 2'd0;
  localparam logic [1:0] __const__STAGE_WAIT_FOR_FU  = 2'd1;
  localparam logic [1:0] __const__STAGE_WAIT_FOR_NXT  = 2'd3;
  localparam logic [1:0] __const__num_outports_at_handshake_process  = 2'd2;
  localparam logic [2:0] __const__num_xbar_inports_at_handshake_process  = 3'd4;
  localparam logic [2:0] __const__fu_list_size_at_handshake_process  = 3'd6;
  localparam logic [2:0] __const__num_xbar_outports_at_fu_propagate_sync  = 3'd4;
  localparam logic [2:0] __const__num_xbar_outports_at_data_routing  = 3'd4;
  localparam logic [1:0] __const__num_outports_at_data_routing  = 2'd2;
  localparam logic [2:0] __const__num_xbar_inports_at_data_routing  = 3'd4;
  localparam logic [2:0] __const__fu_list_size_at_data_routing  = 3'd6;
  logic [1:0] cur_stage;
  logic [0:0] fu_fin_rdy_nxt;
  logic [5:0] fu_handshake_vector_fu_fin_req_met;
  logic [3:0] fu_handshake_vector_xbar_mesh_in_valid_met;
  logic [0:0] fu_launch_enable;
  logic [0:0] fu_launch_finish;
  logic [0:0] fu_launch_rdy;
  logic [0:0] fu_launch_rdy_nxt;
  logic [5:0] fu_launch_rdy_nxt_vector;
  logic [5:0] fu_launch_rdy_vector;
  logic [0:0] fu_mesh_in_done;
  logic [5:0] fu_out_routine;
  logic [5:0] fu_pipeline_fin_en;
  logic [5:0] fu_pipeline_fin_propagate_en;
  logic [5:0] fu_pipeline_fin_req;
  logic [0:0] fu_pipeline_fin_req_ack;
  logic [5:0] fu_pipeline_inter_en;
  logic [5:0] fu_recv_const_req_nxt_vector;
  logic [0:0] fu_send_out_done;
  logic [0:0] fu_send_out_finish;
  logic [0:0] fu_send_out_okay;
  logic [0:0] fu_send_out_valid;
  logic [5:0] fu_send_port_valid_vector [0:1];
  logic [3:0] fu_xbar_inport_sel [0:3];
  logic [0:0] fu_xbar_mesh_in_valid;
  logic [3:0] fu_xbar_outport_sel [0:3];
  logic [3:0] fu_xbar_outport_sel_nxt [0:3];
  logic [4:0] fu_xbar_outport_sel_nxt_decode [0:3];
  logic [0:0] fu_xbar_recv_const_req;
  logic [0:0] fu_xbar_recv_predicate_req;
  CGRAData_64_1__payload_64__predicate_1 fu_xbar_send_data [0:3];
  logic [1:0] nxt_stage;
  logic [0:0] recv_predicate_req_nxt;
  logic [3:0] xbar_recv_port_req;

  logic [0:0] fu__clk [0:5];
  logic [0:0] fu__fu_fin_req [0:5];
  logic [0:0] fu__opt_launch_en [0:5];
  logic [0:0] fu__opt_launch_rdy [0:5];
  logic [0:0] fu__opt_launch_rdy_nxt [0:5];
  logic [0:0] fu__opt_pipeline_fin_en [0:5];
  logic [0:0] fu__opt_pipeline_fin_propagate_en [0:5];
  logic [0:0] fu__opt_pipeline_inter_en [0:5];
  logic [0:0] fu__opt_propagate_en [0:5];
  logic [31:0] fu__recv_const_msg [0:5];
  logic [0:0] fu__recv_const_req [0:5];
  logic [0:0] fu__recv_opt_en [0:5];
  logic [5:0] fu__recv_opt_msg_ctrl [0:5];
  logic [0:0] fu__recv_predicate_en [0:5];
  CGRAData_1__predicate_1 fu__recv_predicate_msg [0:5];
  logic [0:0] fu__reset [0:5];
  logic [0:0] fu__from_mem_rdata__en [0:5];
  CGRAData_64_1__payload_64__predicate_1 fu__from_mem_rdata__msg [0:5];
  logic [0:0] fu__from_mem_rdata__rdy [0:5];
  logic [0:0] fu__recv_in__en [0:5][0:3];
  CGRAData_64_1__payload_64__predicate_1 fu__recv_in__msg [0:5][0:3];
  logic [0:0] fu__recv_in__rdy [0:5][0:3];
  logic [0:0] fu__send_out__en [0:5][0:1];
  CGRAData_64_1__payload_64__predicate_1 fu__send_out__msg [0:5][0:1];
  logic [0:0] fu__send_out__rdy [0:5][0:1];
  logic [0:0] fu__to_mem_raddr__en [0:5];
  logic [6:0] fu__to_mem_raddr__msg [0:5];
  logic [0:0] fu__to_mem_raddr__rdy [0:5];
  logic [0:0] fu__to_mem_waddr__en [0:5];
  logic [6:0] fu__to_mem_waddr__msg [0:5];
  logic [0:0] fu__to_mem_waddr__rdy [0:5];
  logic [0:0] fu__to_mem_wdata__en [0:5];
  CGRAData_64_1__payload_64__predicate_1 fu__to_mem_wdata__msg [0:5];
  logic [0:0] fu__to_mem_wdata__rdy [0:5];

  AdderRTL__cad2bcaa3a8de18d fu__0
  (
    .clk( fu__clk[0] ),
    .fu_fin_req( fu__fu_fin_req[0] ),
    .opt_launch_en( fu__opt_launch_en[0] ),
    .opt_launch_rdy( fu__opt_launch_rdy[0] ),
    .opt_launch_rdy_nxt( fu__opt_launch_rdy_nxt[0] ),
    .opt_pipeline_fin_en( fu__opt_pipeline_fin_en[0] ),
    .opt_pipeline_fin_propagate_en( fu__opt_pipeline_fin_propagate_en[0] ),
    .opt_pipeline_inter_en( fu__opt_pipeline_inter_en[0] ),
    .opt_propagate_en( fu__opt_propagate_en[0] ),
    .recv_const_msg( fu__recv_const_msg[0] ),
    .recv_const_req( fu__recv_const_req[0] ),
    .recv_opt_en( fu__recv_opt_en[0] ),
    .recv_opt_msg_ctrl( fu__recv_opt_msg_ctrl[0] ),
    .recv_predicate_en( fu__recv_predicate_en[0] ),
    .recv_predicate_msg( fu__recv_predicate_msg[0] ),
    .reset( fu__reset[0] ),
    .from_mem_rdata__en( fu__from_mem_rdata__en[0] ),
    .from_mem_rdata__msg( fu__from_mem_rdata__msg[0] ),
    .from_mem_rdata__rdy( fu__from_mem_rdata__rdy[0] ),
    .recv_in__en( fu__recv_in__en[0] ),
    .recv_in__msg( fu__recv_in__msg[0] ),
    .recv_in__rdy( fu__recv_in__rdy[0] ),
    .send_out__en( fu__send_out__en[0] ),
    .send_out__msg( fu__send_out__msg[0] ),
    .send_out__rdy( fu__send_out__rdy[0] ),
    .to_mem_raddr__en( fu__to_mem_raddr__en[0] ),
    .to_mem_raddr__msg( fu__to_mem_raddr__msg[0] ),
    .to_mem_raddr__rdy( fu__to_mem_raddr__rdy[0] ),
    .to_mem_waddr__en( fu__to_mem_waddr__en[0] ),
    .to_mem_waddr__msg( fu__to_mem_waddr__msg[0] ),
    .to_mem_waddr__rdy( fu__to_mem_waddr__rdy[0] ),
    .to_mem_wdata__en( fu__to_mem_wdata__en[0] ),
    .to_mem_wdata__msg( fu__to_mem_wdata__msg[0] ),
    .to_mem_wdata__rdy( fu__to_mem_wdata__rdy[0] )
  );

  PhiRTL__cad2bcaa3a8de18d fu__1
  (
    .clk( fu__clk[1] ),
    .fu_fin_req( fu__fu_fin_req[1] ),
    .opt_launch_en( fu__opt_launch_en[1] ),
    .opt_launch_rdy( fu__opt_launch_rdy[1] ),
    .opt_launch_rdy_nxt( fu__opt_launch_rdy_nxt[1] ),
    .opt_pipeline_fin_en( fu__opt_pipeline_fin_en[1] ),
    .opt_pipeline_fin_propagate_en( fu__opt_pipeline_fin_propagate_en[1] ),
    .opt_pipeline_inter_en( fu__opt_pipeline_inter_en[1] ),
    .opt_propagate_en( fu__opt_propagate_en[1] ),
    .recv_const_msg( fu__recv_const_msg[1] ),
    .recv_const_req( fu__recv_const_req[1] ),
    .recv_opt_en( fu__recv_opt_en[1] ),
    .recv_opt_msg_ctrl( fu__recv_opt_msg_ctrl[1] ),
    .recv_predicate_en( fu__recv_predicate_en[1] ),
    .recv_predicate_msg( fu__recv_predicate_msg[1] ),
    .reset( fu__reset[1] ),
    .from_mem_rdata__en( fu__from_mem_rdata__en[1] ),
    .from_mem_rdata__msg( fu__from_mem_rdata__msg[1] ),
    .from_mem_rdata__rdy( fu__from_mem_rdata__rdy[1] ),
    .recv_in__en( fu__recv_in__en[1] ),
    .recv_in__msg( fu__recv_in__msg[1] ),
    .recv_in__rdy( fu__recv_in__rdy[1] ),
    .send_out__en( fu__send_out__en[1] ),
    .send_out__msg( fu__send_out__msg[1] ),
    .send_out__rdy( fu__send_out__rdy[1] ),
    .to_mem_raddr__en( fu__to_mem_raddr__en[1] ),
    .to_mem_raddr__msg( fu__to_mem_raddr__msg[1] ),
    .to_mem_raddr__rdy( fu__to_mem_raddr__rdy[1] ),
    .to_mem_waddr__en( fu__to_mem_waddr__en[1] ),
    .to_mem_waddr__msg( fu__to_mem_waddr__msg[1] ),
    .to_mem_waddr__rdy( fu__to_mem_waddr__rdy[1] ),
    .to_mem_wdata__en( fu__to_mem_wdata__en[1] ),
    .to_mem_wdata__msg( fu__to_mem_wdata__msg[1] ),
    .to_mem_wdata__rdy( fu__to_mem_wdata__rdy[1] )
  );

  CompRTL__cad2bcaa3a8de18d fu__2
  (
    .clk( fu__clk[2] ),
    .fu_fin_req( fu__fu_fin_req[2] ),
    .opt_launch_en( fu__opt_launch_en[2] ),
    .opt_launch_rdy( fu__opt_launch_rdy[2] ),
    .opt_launch_rdy_nxt( fu__opt_launch_rdy_nxt[2] ),
    .opt_pipeline_fin_en( fu__opt_pipeline_fin_en[2] ),
    .opt_pipeline_fin_propagate_en( fu__opt_pipeline_fin_propagate_en[2] ),
    .opt_pipeline_inter_en( fu__opt_pipeline_inter_en[2] ),
    .opt_propagate_en( fu__opt_propagate_en[2] ),
    .recv_const_msg( fu__recv_const_msg[2] ),
    .recv_const_req( fu__recv_const_req[2] ),
    .recv_opt_en( fu__recv_opt_en[2] ),
    .recv_opt_msg_ctrl( fu__recv_opt_msg_ctrl[2] ),
    .recv_predicate_en( fu__recv_predicate_en[2] ),
    .recv_predicate_msg( fu__recv_predicate_msg[2] ),
    .reset( fu__reset[2] ),
    .from_mem_rdata__en( fu__from_mem_rdata__en[2] ),
    .from_mem_rdata__msg( fu__from_mem_rdata__msg[2] ),
    .from_mem_rdata__rdy( fu__from_mem_rdata__rdy[2] ),
    .recv_in__en( fu__recv_in__en[2] ),
    .recv_in__msg( fu__recv_in__msg[2] ),
    .recv_in__rdy( fu__recv_in__rdy[2] ),
    .send_out__en( fu__send_out__en[2] ),
    .send_out__msg( fu__send_out__msg[2] ),
    .send_out__rdy( fu__send_out__rdy[2] ),
    .to_mem_raddr__en( fu__to_mem_raddr__en[2] ),
    .to_mem_raddr__msg( fu__to_mem_raddr__msg[2] ),
    .to_mem_raddr__rdy( fu__to_mem_raddr__rdy[2] ),
    .to_mem_waddr__en( fu__to_mem_waddr__en[2] ),
    .to_mem_waddr__msg( fu__to_mem_waddr__msg[2] ),
    .to_mem_waddr__rdy( fu__to_mem_waddr__rdy[2] ),
    .to_mem_wdata__en( fu__to_mem_wdata__en[2] ),
    .to_mem_wdata__msg( fu__to_mem_wdata__msg[2] ),
    .to_mem_wdata__rdy( fu__to_mem_wdata__rdy[2] )
  );

  MulRTL__cad2bcaa3a8de18d fu__3
  (
    .clk( fu__clk[3] ),
    .fu_fin_req( fu__fu_fin_req[3] ),
    .opt_launch_en( fu__opt_launch_en[3] ),
    .opt_launch_rdy( fu__opt_launch_rdy[3] ),
    .opt_launch_rdy_nxt( fu__opt_launch_rdy_nxt[3] ),
    .opt_pipeline_fin_en( fu__opt_pipeline_fin_en[3] ),
    .opt_pipeline_fin_propagate_en( fu__opt_pipeline_fin_propagate_en[3] ),
    .opt_pipeline_inter_en( fu__opt_pipeline_inter_en[3] ),
    .opt_propagate_en( fu__opt_propagate_en[3] ),
    .recv_const_msg( fu__recv_const_msg[3] ),
    .recv_const_req( fu__recv_const_req[3] ),
    .recv_opt_en( fu__recv_opt_en[3] ),
    .recv_opt_msg_ctrl( fu__recv_opt_msg_ctrl[3] ),
    .recv_predicate_en( fu__recv_predicate_en[3] ),
    .recv_predicate_msg( fu__recv_predicate_msg[3] ),
    .reset( fu__reset[3] ),
    .from_mem_rdata__en( fu__from_mem_rdata__en[3] ),
    .from_mem_rdata__msg( fu__from_mem_rdata__msg[3] ),
    .from_mem_rdata__rdy( fu__from_mem_rdata__rdy[3] ),
    .recv_in__en( fu__recv_in__en[3] ),
    .recv_in__msg( fu__recv_in__msg[3] ),
    .recv_in__rdy( fu__recv_in__rdy[3] ),
    .send_out__en( fu__send_out__en[3] ),
    .send_out__msg( fu__send_out__msg[3] ),
    .send_out__rdy( fu__send_out__rdy[3] ),
    .to_mem_raddr__en( fu__to_mem_raddr__en[3] ),
    .to_mem_raddr__msg( fu__to_mem_raddr__msg[3] ),
    .to_mem_raddr__rdy( fu__to_mem_raddr__rdy[3] ),
    .to_mem_waddr__en( fu__to_mem_waddr__en[3] ),
    .to_mem_waddr__msg( fu__to_mem_waddr__msg[3] ),
    .to_mem_waddr__rdy( fu__to_mem_waddr__rdy[3] ),
    .to_mem_wdata__en( fu__to_mem_wdata__en[3] ),
    .to_mem_wdata__msg( fu__to_mem_wdata__msg[3] ),
    .to_mem_wdata__rdy( fu__to_mem_wdata__rdy[3] )
  );

  BranchRTL__cad2bcaa3a8de18d fu__4
  (
    .clk( fu__clk[4] ),
    .fu_fin_req( fu__fu_fin_req[4] ),
    .opt_launch_en( fu__opt_launch_en[4] ),
    .opt_launch_rdy( fu__opt_launch_rdy[4] ),
    .opt_launch_rdy_nxt( fu__opt_launch_rdy_nxt[4] ),
    .opt_pipeline_fin_en( fu__opt_pipeline_fin_en[4] ),
    .opt_pipeline_fin_propagate_en( fu__opt_pipeline_fin_propagate_en[4] ),
    .opt_pipeline_inter_en( fu__opt_pipeline_inter_en[4] ),
    .opt_propagate_en( fu__opt_propagate_en[4] ),
    .recv_const_msg( fu__recv_const_msg[4] ),
    .recv_const_req( fu__recv_const_req[4] ),
    .recv_opt_en( fu__recv_opt_en[4] ),
    .recv_opt_msg_ctrl( fu__recv_opt_msg_ctrl[4] ),
    .recv_predicate_en( fu__recv_predicate_en[4] ),
    .recv_predicate_msg( fu__recv_predicate_msg[4] ),
    .reset( fu__reset[4] ),
    .from_mem_rdata__en( fu__from_mem_rdata__en[4] ),
    .from_mem_rdata__msg( fu__from_mem_rdata__msg[4] ),
    .from_mem_rdata__rdy( fu__from_mem_rdata__rdy[4] ),
    .recv_in__en( fu__recv_in__en[4] ),
    .recv_in__msg( fu__recv_in__msg[4] ),
    .recv_in__rdy( fu__recv_in__rdy[4] ),
    .send_out__en( fu__send_out__en[4] ),
    .send_out__msg( fu__send_out__msg[4] ),
    .send_out__rdy( fu__send_out__rdy[4] ),
    .to_mem_raddr__en( fu__to_mem_raddr__en[4] ),
    .to_mem_raddr__msg( fu__to_mem_raddr__msg[4] ),
    .to_mem_raddr__rdy( fu__to_mem_raddr__rdy[4] ),
    .to_mem_waddr__en( fu__to_mem_waddr__en[4] ),
    .to_mem_waddr__msg( fu__to_mem_waddr__msg[4] ),
    .to_mem_waddr__rdy( fu__to_mem_waddr__rdy[4] ),
    .to_mem_wdata__en( fu__to_mem_wdata__en[4] ),
    .to_mem_wdata__msg( fu__to_mem_wdata__msg[4] ),
    .to_mem_wdata__rdy( fu__to_mem_wdata__rdy[4] )
  );

  ALURTL__cad2bcaa3a8de18d fu__5
  (
    .clk( fu__clk[5] ),
    .fu_fin_req( fu__fu_fin_req[5] ),
    .opt_launch_en( fu__opt_launch_en[5] ),
    .opt_launch_rdy( fu__opt_launch_rdy[5] ),
    .opt_launch_rdy_nxt( fu__opt_launch_rdy_nxt[5] ),
    .opt_pipeline_fin_en( fu__opt_pipeline_fin_en[5] ),
    .opt_pipeline_fin_propagate_en( fu__opt_pipeline_fin_propagate_en[5] ),
    .opt_pipeline_inter_en( fu__opt_pipeline_inter_en[5] ),
    .opt_propagate_en( fu__opt_propagate_en[5] ),
    .recv_const_msg( fu__recv_const_msg[5] ),
    .recv_const_req( fu__recv_const_req[5] ),
    .recv_opt_en( fu__recv_opt_en[5] ),
    .recv_opt_msg_ctrl( fu__recv_opt_msg_ctrl[5] ),
    .recv_predicate_en( fu__recv_predicate_en[5] ),
    .recv_predicate_msg( fu__recv_predicate_msg[5] ),
    .reset( fu__reset[5] ),
    .from_mem_rdata__en( fu__from_mem_rdata__en[5] ),
    .from_mem_rdata__msg( fu__from_mem_rdata__msg[5] ),
    .from_mem_rdata__rdy( fu__from_mem_rdata__rdy[5] ),
    .recv_in__en( fu__recv_in__en[5] ),
    .recv_in__msg( fu__recv_in__msg[5] ),
    .recv_in__rdy( fu__recv_in__rdy[5] ),
    .send_out__en( fu__send_out__en[5] ),
    .send_out__msg( fu__send_out__msg[5] ),
    .send_out__rdy( fu__send_out__rdy[5] ),
    .to_mem_raddr__en( fu__to_mem_raddr__en[5] ),
    .to_mem_raddr__msg( fu__to_mem_raddr__msg[5] ),
    .to_mem_raddr__rdy( fu__to_mem_raddr__rdy[5] ),
    .to_mem_waddr__en( fu__to_mem_waddr__en[5] ),
    .to_mem_waddr__msg( fu__to_mem_waddr__msg[5] ),
    .to_mem_waddr__rdy( fu__to_mem_waddr__rdy[5] ),
    .to_mem_wdata__en( fu__to_mem_wdata__en[5] ),
    .to_mem_wdata__msg( fu__to_mem_wdata__msg[5] ),
    .to_mem_wdata__rdy( fu__to_mem_wdata__rdy[5] )
  );


  
  always_comb begin : data_routing
    for ( int unsigned i = 1'd0; i < 3'( __const__num_xbar_outports_at_data_routing ); i += 1'd1 )
      fu_xbar_send_data[2'(i)] = { 64'd0, 1'd0 };
    for ( int unsigned i = 1'd0; i < 2'( __const__num_outports_at_data_routing ); i += 1'd1 )
      send_port_data[1'(i)] = { 64'd0, 1'd0 };
    if ( fu_launch_enable ) begin
      for ( int unsigned i = 1'd0; i < 3'( __const__num_xbar_outports_at_data_routing ); i += 1'd1 )
        for ( int unsigned j = 1'd0; j < 3'( __const__num_xbar_inports_at_data_routing ); j += 1'd1 ) begin
          fu_xbar_send_data[2'(i)].payload = fu_xbar_send_data[2'(i)].payload | ( recv_port_data[2'(j)].payload & { { 63 { fu_xbar_outport_sel[2'(i)][2'(j)] } }, fu_xbar_outport_sel[2'(i)][2'(j)] } );
          fu_xbar_send_data[2'(i)].predicate = fu_xbar_send_data[2'(i)].predicate | ( recv_port_data[2'(j)].predicate & fu_xbar_outport_sel[2'(i)][2'(j)] );
        end
    end
    if ( fu_send_out_valid ) begin
      for ( int unsigned i = 1'd0; i < 2'( __const__num_outports_at_data_routing ); i += 1'd1 )
        for ( int unsigned j = 1'd0; j < 3'( __const__fu_list_size_at_data_routing ); j += 1'd1 ) begin
          send_port_data[1'(i)].payload = send_port_data[1'(i)].payload | ( fu__send_out__msg[3'(j)][1'(i)].payload & { { 63 { fu_send_port_valid_vector[1'(i)][3'(j)] } }, fu_send_port_valid_vector[1'(i)][3'(j)] } );
          send_port_data[1'(i)].predicate = send_port_data[1'(i)].predicate | ( fu__send_out__msg[3'(j)][1'(i)].predicate & fu_send_port_valid_vector[1'(i)][3'(j)] );
        end
    end
  end

  
  always_comb begin : decode_process
    for ( int unsigned i = 1'd0; i < 3'( __const__num_xbar_outports_at_decode_process ); i += 1'd1 ) begin
      fu_xbar_outport_sel_nxt_decode[2'(i)] = 5'd0;
      fu_xbar_outport_sel_nxt[2'(i)] = 4'd0;
    end
    recv_predicate_req_nxt = 1'd0;
    if ( fu_opt_enable ) begin
      for ( int unsigned i = 1'd0; i < 3'( __const__num_xbar_outports_at_decode_process ); i += 1'd1 )
        if ( recv_opt_msg_fu_in[2'(i)] != 3'd0 ) begin
          fu_xbar_outport_sel_nxt_decode[2'(i)][recv_opt_msg_fu_in[2'(i)]] = 1'd1;
        end
      for ( int unsigned i = 1'd0; i < 3'( __const__num_xbar_outports_at_decode_process ); i += 1'd1 )
        fu_xbar_outport_sel_nxt[2'(i)] = fu_xbar_outport_sel_nxt_decode[2'(i)][3'd4:3'd1];
      if ( recv_opt_msg_predicate == 1'd1 ) begin
        recv_predicate_req_nxt = 1'd1;
      end
    end
  end

  
  always_comb begin : fsm_ctrl_signals
    fu_mesh_in_done = 1'd0;
    fu_send_out_done = 1'd0;
    if ( cur_stage == 2'( __const__STAGE_WAIT_FOR_FU ) ) begin
      fu_mesh_in_done = 1'd1;
    end
    if ( cur_stage == 2'( __const__STAGE_WAIT_FOR_NXT ) ) begin
      fu_mesh_in_done = 1'd1;
      fu_send_out_done = 1'd1;
    end
  end

  
  always_comb begin : fsm_nxt_stage
    nxt_stage = cur_stage;
    if ( cur_stage == 2'( __const__STAGE_NORMAL ) ) begin
      if ( fu_launch_enable & ( ~fu_send_out_okay ) ) begin
        nxt_stage = 2'( __const__STAGE_WAIT_FOR_FU );
      end
      if ( ( fu_launch_enable & fu_send_out_okay ) & ( ~fu_propagate_en ) ) begin
        nxt_stage = 2'( __const__STAGE_WAIT_FOR_NXT );
      end
    end
    if ( cur_stage == 2'( __const__STAGE_WAIT_FOR_FU ) ) begin
      if ( fu_send_out_okay ) begin
        if ( ~fu_propagate_en ) begin
          nxt_stage = 2'( __const__STAGE_WAIT_FOR_NXT );
        end
        else
          nxt_stage = 2'( __const__STAGE_NORMAL );
      end
    end
    if ( cur_stage == 2'( __const__STAGE_WAIT_FOR_NXT ) ) begin
      if ( fu_propagate_en ) begin
        nxt_stage = 2'( __const__STAGE_NORMAL );
      end
    end
  end

  
  always_comb begin : handshake_process
    for ( int unsigned port = 1'd0; port < 2'( __const__num_outports_at_handshake_process ); port += 1'd1 )
      fu_send_port_valid_vector[1'(port)] = 6'd0;
    for ( int unsigned i = 1'd0; i < 3'( __const__num_xbar_inports_at_handshake_process ); i += 1'd1 )
      xbar_recv_port_req[2'(i)] = ( | fu_xbar_inport_sel[2'(i)] );
    for ( int unsigned i = 1'd0; i < 3'( __const__fu_list_size_at_handshake_process ); i += 1'd1 )
      for ( int unsigned port = 1'd0; port < 2'( __const__num_outports_at_handshake_process ); port += 1'd1 )
        fu_send_port_valid_vector[1'(port)][3'(i)] = fu__send_out__en[3'(i)][1'(port)];
    for ( int unsigned i = 1'd0; i < 2'( __const__num_outports_at_handshake_process ); i += 1'd1 )
      send_port_valid[1'(i)] = ( | fu_send_port_valid_vector[1'(i)] ) & fu_send_out_valid;
    fu_handshake_vector_fu_fin_req_met = recv_opt_msg_out_routine & ( ~fu_pipeline_fin_req );
    fu_handshake_vector_xbar_mesh_in_valid_met = xbar_recv_port_req & ( ~recv_port_valid );
    fu_xbar_mesh_in_valid = ( ( ~( | fu_handshake_vector_xbar_mesh_in_valid_met ) ) & ( ( ~fu_xbar_recv_predicate_req ) | recv_predicate_valid ) ) | fu_dry_run_ack;
    fu_launch_rdy = ( & fu_launch_rdy_vector ) | fu_dry_run_ack;
    fu_launch_rdy_nxt = ( & fu_launch_rdy_nxt_vector ) | fu_dry_run_begin;
    fu_fin_rdy_nxt = ( ~( | fu_handshake_vector_fu_fin_req_met ) ) | fu_dry_run_begin;
    fu_send_out_okay = send_port_ack | fu_dry_run_ack;
    fu_send_out_finish = fu_send_out_okay | fu_send_out_done;
    fu_launch_finish = fu_launch_enable | fu_mesh_in_done;
    fu_launch_enable = ( fu_xbar_mesh_in_valid & ( ~fu_mesh_in_done ) ) & fu_launch_rdy;
    fu_send_out_valid = ( | fu_out_routine );
    fu_pipeline_inter_en = ~fu_pipeline_fin_req;
    fu_pipeline_fin_req_ack = fu_fin_rdy_nxt & fu_propagate_en;
    fu_pipeline_fin_propagate_en = fu_pipeline_fin_req & { { 5 { fu_pipeline_fin_req_ack[0] } }, fu_pipeline_fin_req_ack };
    fu_pipeline_fin_en = fu_out_routine & { { 5 { ~fu_send_out_finish[0] } }, ~fu_send_out_finish };
    recv_port_ack = xbar_recv_port_req & { { 3 { fu_launch_enable[0] } }, fu_launch_enable };
    recv_const_ack = fu_xbar_recv_const_req & fu_launch_enable;
    recv_predicate_ack = fu_xbar_recv_predicate_req & fu_launch_enable;
    fu_propagate_rdy = ( fu_send_out_finish & fu_launch_finish ) & fu_launch_rdy_nxt;
  end

  
  always_comb begin : opt_propagate
    for ( int unsigned i = 1'd0; i < 3'( __const__num_xbar_outports_at_opt_propagate ); i += 1'd1 )
      for ( int unsigned j = 1'd0; j < 3'( __const__num_xbar_inports_at_opt_propagate ); j += 1'd1 )
        fu_xbar_inport_sel[2'(j)][2'(i)] = fu_xbar_outport_sel[2'(i)][2'(j)];
  end

  
  always_ff @(posedge clk) begin : fsm_update
    if ( reset ) begin
      cur_stage <= 2'( __const__STAGE_NORMAL );
    end
    else
      cur_stage <= nxt_stage;
  end

  
  always_ff @(posedge clk) begin : fu_propagate_sync
    if ( reset ) begin
      fu_xbar_recv_const_req <= 1'd0;
      fu_xbar_recv_predicate_req <= 1'd0;
      for ( int unsigned i = 1'd0; i < 3'( __const__num_xbar_outports_at_fu_propagate_sync ); i += 1'd1 )
        fu_xbar_outport_sel[2'(i)] <= 4'd0;
      fu_out_routine <= 6'd0;
    end
    else if ( fu_propagate_en ) begin
      for ( int unsigned i = 1'd0; i < 3'( __const__num_xbar_outports_at_fu_propagate_sync ); i += 1'd1 )
        fu_xbar_outport_sel[2'(i)] <= fu_xbar_outport_sel_nxt[2'(i)];
      fu_xbar_recv_const_req <= ( | fu_recv_const_req_nxt_vector );
      fu_xbar_recv_predicate_req <= recv_predicate_req_nxt;
      fu_out_routine <= recv_opt_msg_out_routine;
    end
  end

  assign fu__clk[0] = clk;
  assign fu__reset[0] = reset;
  assign fu__clk[1] = clk;
  assign fu__reset[1] = reset;
  assign fu__clk[2] = clk;
  assign fu__reset[2] = reset;
  assign fu__clk[3] = clk;
  assign fu__reset[3] = reset;
  assign fu__clk[4] = clk;
  assign fu__reset[4] = reset;
  assign fu__clk[5] = clk;
  assign fu__reset[5] = reset;
  assign to_mem_raddr__en[0] = fu__to_mem_raddr__en[0];
  assign to_mem_raddr__msg[0] = fu__to_mem_raddr__msg[0];
  assign fu__to_mem_raddr__rdy[0] = to_mem_raddr__rdy[0];
  assign fu__from_mem_rdata__en[0] = from_mem_rdata__en[0];
  assign fu__from_mem_rdata__msg[0] = from_mem_rdata__msg[0];
  assign from_mem_rdata__rdy[0] = fu__from_mem_rdata__rdy[0];
  assign to_mem_waddr__en[0] = fu__to_mem_waddr__en[0];
  assign to_mem_waddr__msg[0] = fu__to_mem_waddr__msg[0];
  assign fu__to_mem_waddr__rdy[0] = to_mem_waddr__rdy[0];
  assign to_mem_wdata__en[0] = fu__to_mem_wdata__en[0];
  assign to_mem_wdata__msg[0] = fu__to_mem_wdata__msg[0];
  assign fu__to_mem_wdata__rdy[0] = to_mem_wdata__rdy[0];
  assign to_mem_raddr__en[1] = fu__to_mem_raddr__en[1];
  assign to_mem_raddr__msg[1] = fu__to_mem_raddr__msg[1];
  assign fu__to_mem_raddr__rdy[1] = to_mem_raddr__rdy[1];
  assign fu__from_mem_rdata__en[1] = from_mem_rdata__en[1];
  assign fu__from_mem_rdata__msg[1] = from_mem_rdata__msg[1];
  assign from_mem_rdata__rdy[1] = fu__from_mem_rdata__rdy[1];
  assign to_mem_waddr__en[1] = fu__to_mem_waddr__en[1];
  assign to_mem_waddr__msg[1] = fu__to_mem_waddr__msg[1];
  assign fu__to_mem_waddr__rdy[1] = to_mem_waddr__rdy[1];
  assign to_mem_wdata__en[1] = fu__to_mem_wdata__en[1];
  assign to_mem_wdata__msg[1] = fu__to_mem_wdata__msg[1];
  assign fu__to_mem_wdata__rdy[1] = to_mem_wdata__rdy[1];
  assign to_mem_raddr__en[2] = fu__to_mem_raddr__en[2];
  assign to_mem_raddr__msg[2] = fu__to_mem_raddr__msg[2];
  assign fu__to_mem_raddr__rdy[2] = to_mem_raddr__rdy[2];
  assign fu__from_mem_rdata__en[2] = from_mem_rdata__en[2];
  assign fu__from_mem_rdata__msg[2] = from_mem_rdata__msg[2];
  assign from_mem_rdata__rdy[2] = fu__from_mem_rdata__rdy[2];
  assign to_mem_waddr__en[2] = fu__to_mem_waddr__en[2];
  assign to_mem_waddr__msg[2] = fu__to_mem_waddr__msg[2];
  assign fu__to_mem_waddr__rdy[2] = to_mem_waddr__rdy[2];
  assign to_mem_wdata__en[2] = fu__to_mem_wdata__en[2];
  assign to_mem_wdata__msg[2] = fu__to_mem_wdata__msg[2];
  assign fu__to_mem_wdata__rdy[2] = to_mem_wdata__rdy[2];
  assign to_mem_raddr__en[3] = fu__to_mem_raddr__en[3];
  assign to_mem_raddr__msg[3] = fu__to_mem_raddr__msg[3];
  assign fu__to_mem_raddr__rdy[3] = to_mem_raddr__rdy[3];
  assign fu__from_mem_rdata__en[3] = from_mem_rdata__en[3];
  assign fu__from_mem_rdata__msg[3] = from_mem_rdata__msg[3];
  assign from_mem_rdata__rdy[3] = fu__from_mem_rdata__rdy[3];
  assign to_mem_waddr__en[3] = fu__to_mem_waddr__en[3];
  assign to_mem_waddr__msg[3] = fu__to_mem_waddr__msg[3];
  assign fu__to_mem_waddr__rdy[3] = to_mem_waddr__rdy[3];
  assign to_mem_wdata__en[3] = fu__to_mem_wdata__en[3];
  assign to_mem_wdata__msg[3] = fu__to_mem_wdata__msg[3];
  assign fu__to_mem_wdata__rdy[3] = to_mem_wdata__rdy[3];
  assign to_mem_raddr__en[4] = fu__to_mem_raddr__en[4];
  assign to_mem_raddr__msg[4] = fu__to_mem_raddr__msg[4];
  assign fu__to_mem_raddr__rdy[4] = to_mem_raddr__rdy[4];
  assign fu__from_mem_rdata__en[4] = from_mem_rdata__en[4];
  assign fu__from_mem_rdata__msg[4] = from_mem_rdata__msg[4];
  assign from_mem_rdata__rdy[4] = fu__from_mem_rdata__rdy[4];
  assign to_mem_waddr__en[4] = fu__to_mem_waddr__en[4];
  assign to_mem_waddr__msg[4] = fu__to_mem_waddr__msg[4];
  assign fu__to_mem_waddr__rdy[4] = to_mem_waddr__rdy[4];
  assign to_mem_wdata__en[4] = fu__to_mem_wdata__en[4];
  assign to_mem_wdata__msg[4] = fu__to_mem_wdata__msg[4];
  assign fu__to_mem_wdata__rdy[4] = to_mem_wdata__rdy[4];
  assign to_mem_raddr__en[5] = fu__to_mem_raddr__en[5];
  assign to_mem_raddr__msg[5] = fu__to_mem_raddr__msg[5];
  assign fu__to_mem_raddr__rdy[5] = to_mem_raddr__rdy[5];
  assign fu__from_mem_rdata__en[5] = from_mem_rdata__en[5];
  assign fu__from_mem_rdata__msg[5] = from_mem_rdata__msg[5];
  assign from_mem_rdata__rdy[5] = fu__from_mem_rdata__rdy[5];
  assign to_mem_waddr__en[5] = fu__to_mem_waddr__en[5];
  assign to_mem_waddr__msg[5] = fu__to_mem_waddr__msg[5];
  assign fu__to_mem_waddr__rdy[5] = to_mem_waddr__rdy[5];
  assign to_mem_wdata__en[5] = fu__to_mem_wdata__en[5];
  assign to_mem_wdata__msg[5] = fu__to_mem_wdata__msg[5];
  assign fu__to_mem_wdata__rdy[5] = to_mem_wdata__rdy[5];
  assign fu__recv_opt_msg_ctrl[0] = recv_opt_msg_ctrl;
  assign fu__recv_opt_en[0] = fu_opt_enable;
  assign fu_recv_const_req_nxt_vector[0:0] = fu__recv_const_req[0];
  assign fu_pipeline_fin_req[0:0] = fu__fu_fin_req[0];
  assign fu_launch_rdy_nxt_vector[0:0] = fu__opt_launch_rdy_nxt[0];
  assign fu_launch_rdy_vector[0:0] = fu__opt_launch_rdy[0];
  assign fu__opt_pipeline_inter_en[0] = fu_pipeline_inter_en[0:0];
  assign fu__opt_pipeline_fin_propagate_en[0] = fu_pipeline_fin_propagate_en[0:0];
  assign fu__opt_pipeline_fin_en[0] = fu_pipeline_fin_en[0:0];
  assign fu__recv_in__msg[0][0] = fu_xbar_send_data[0];
  assign fu__recv_in__msg[0][1] = fu_xbar_send_data[1];
  assign fu__recv_in__msg[0][2] = fu_xbar_send_data[2];
  assign fu__recv_in__msg[0][3] = fu_xbar_send_data[3];
  assign fu__recv_const_msg[0] = recv_const_data;
  assign fu__recv_predicate_msg[0] = recv_predicate_data;
  assign fu__opt_propagate_en[0] = fu_propagate_en;
  assign fu__opt_launch_en[0] = fu_launch_enable;
  assign fu__recv_predicate_en[0] = fu_xbar_recv_predicate_req;
  assign fu__recv_opt_msg_ctrl[1] = recv_opt_msg_ctrl;
  assign fu__recv_opt_en[1] = fu_opt_enable;
  assign fu_recv_const_req_nxt_vector[1:1] = fu__recv_const_req[1];
  assign fu_pipeline_fin_req[1:1] = fu__fu_fin_req[1];
  assign fu_launch_rdy_nxt_vector[1:1] = fu__opt_launch_rdy_nxt[1];
  assign fu_launch_rdy_vector[1:1] = fu__opt_launch_rdy[1];
  assign fu__opt_pipeline_inter_en[1] = fu_pipeline_inter_en[1:1];
  assign fu__opt_pipeline_fin_propagate_en[1] = fu_pipeline_fin_propagate_en[1:1];
  assign fu__opt_pipeline_fin_en[1] = fu_pipeline_fin_en[1:1];
  assign fu__recv_in__msg[1][0] = fu_xbar_send_data[0];
  assign fu__recv_in__msg[1][1] = fu_xbar_send_data[1];
  assign fu__recv_in__msg[1][2] = fu_xbar_send_data[2];
  assign fu__recv_in__msg[1][3] = fu_xbar_send_data[3];
  assign fu__recv_const_msg[1] = recv_const_data;
  assign fu__recv_predicate_msg[1] = recv_predicate_data;
  assign fu__opt_propagate_en[1] = fu_propagate_en;
  assign fu__opt_launch_en[1] = fu_launch_enable;
  assign fu__recv_predicate_en[1] = fu_xbar_recv_predicate_req;
  assign fu__recv_opt_msg_ctrl[2] = recv_opt_msg_ctrl;
  assign fu__recv_opt_en[2] = fu_opt_enable;
  assign fu_recv_const_req_nxt_vector[2:2] = fu__recv_const_req[2];
  assign fu_pipeline_fin_req[2:2] = fu__fu_fin_req[2];
  assign fu_launch_rdy_nxt_vector[2:2] = fu__opt_launch_rdy_nxt[2];
  assign fu_launch_rdy_vector[2:2] = fu__opt_launch_rdy[2];
  assign fu__opt_pipeline_inter_en[2] = fu_pipeline_inter_en[2:2];
  assign fu__opt_pipeline_fin_propagate_en[2] = fu_pipeline_fin_propagate_en[2:2];
  assign fu__opt_pipeline_fin_en[2] = fu_pipeline_fin_en[2:2];
  assign fu__recv_in__msg[2][0] = fu_xbar_send_data[0];
  assign fu__recv_in__msg[2][1] = fu_xbar_send_data[1];
  assign fu__recv_in__msg[2][2] = fu_xbar_send_data[2];
  assign fu__recv_in__msg[2][3] = fu_xbar_send_data[3];
  assign fu__recv_const_msg[2] = recv_const_data;
  assign fu__recv_predicate_msg[2] = recv_predicate_data;
  assign fu__opt_propagate_en[2] = fu_propagate_en;
  assign fu__opt_launch_en[2] = fu_launch_enable;
  assign fu__recv_predicate_en[2] = fu_xbar_recv_predicate_req;
  assign fu__recv_opt_msg_ctrl[3] = recv_opt_msg_ctrl;
  assign fu__recv_opt_en[3] = fu_opt_enable;
  assign fu_recv_const_req_nxt_vector[3:3] = fu__recv_const_req[3];
  assign fu_pipeline_fin_req[3:3] = fu__fu_fin_req[3];
  assign fu_launch_rdy_nxt_vector[3:3] = fu__opt_launch_rdy_nxt[3];
  assign fu_launch_rdy_vector[3:3] = fu__opt_launch_rdy[3];
  assign fu__opt_pipeline_inter_en[3] = fu_pipeline_inter_en[3:3];
  assign fu__opt_pipeline_fin_propagate_en[3] = fu_pipeline_fin_propagate_en[3:3];
  assign fu__opt_pipeline_fin_en[3] = fu_pipeline_fin_en[3:3];
  assign fu__recv_in__msg[3][0] = fu_xbar_send_data[0];
  assign fu__recv_in__msg[3][1] = fu_xbar_send_data[1];
  assign fu__recv_in__msg[3][2] = fu_xbar_send_data[2];
  assign fu__recv_in__msg[3][3] = fu_xbar_send_data[3];
  assign fu__recv_const_msg[3] = recv_const_data;
  assign fu__recv_predicate_msg[3] = recv_predicate_data;
  assign fu__opt_propagate_en[3] = fu_propagate_en;
  assign fu__opt_launch_en[3] = fu_launch_enable;
  assign fu__recv_predicate_en[3] = fu_xbar_recv_predicate_req;
  assign fu__recv_opt_msg_ctrl[4] = recv_opt_msg_ctrl;
  assign fu__recv_opt_en[4] = fu_opt_enable;
  assign fu_recv_const_req_nxt_vector[4:4] = fu__recv_const_req[4];
  assign fu_pipeline_fin_req[4:4] = fu__fu_fin_req[4];
  assign fu_launch_rdy_nxt_vector[4:4] = fu__opt_launch_rdy_nxt[4];
  assign fu_launch_rdy_vector[4:4] = fu__opt_launch_rdy[4];
  assign fu__opt_pipeline_inter_en[4] = fu_pipeline_inter_en[4:4];
  assign fu__opt_pipeline_fin_propagate_en[4] = fu_pipeline_fin_propagate_en[4:4];
  assign fu__opt_pipeline_fin_en[4] = fu_pipeline_fin_en[4:4];
  assign fu__recv_in__msg[4][0] = fu_xbar_send_data[0];
  assign fu__recv_in__msg[4][1] = fu_xbar_send_data[1];
  assign fu__recv_in__msg[4][2] = fu_xbar_send_data[2];
  assign fu__recv_in__msg[4][3] = fu_xbar_send_data[3];
  assign fu__recv_const_msg[4] = recv_const_data;
  assign fu__recv_predicate_msg[4] = recv_predicate_data;
  assign fu__opt_propagate_en[4] = fu_propagate_en;
  assign fu__opt_launch_en[4] = fu_launch_enable;
  assign fu__recv_predicate_en[4] = fu_xbar_recv_predicate_req;
  assign fu__recv_opt_msg_ctrl[5] = recv_opt_msg_ctrl;
  assign fu__recv_opt_en[5] = fu_opt_enable;
  assign fu_recv_const_req_nxt_vector[5:5] = fu__recv_const_req[5];
  assign fu_pipeline_fin_req[5:5] = fu__fu_fin_req[5];
  assign fu_launch_rdy_nxt_vector[5:5] = fu__opt_launch_rdy_nxt[5];
  assign fu_launch_rdy_vector[5:5] = fu__opt_launch_rdy[5];
  assign fu__opt_pipeline_inter_en[5] = fu_pipeline_inter_en[5:5];
  assign fu__opt_pipeline_fin_propagate_en[5] = fu_pipeline_fin_propagate_en[5:5];
  assign fu__opt_pipeline_fin_en[5] = fu_pipeline_fin_en[5:5];
  assign fu__recv_in__msg[5][0] = fu_xbar_send_data[0];
  assign fu__recv_in__msg[5][1] = fu_xbar_send_data[1];
  assign fu__recv_in__msg[5][2] = fu_xbar_send_data[2];
  assign fu__recv_in__msg[5][3] = fu_xbar_send_data[3];
  assign fu__recv_const_msg[5] = recv_const_data;
  assign fu__recv_predicate_msg[5] = recv_predicate_data;
  assign fu__opt_propagate_en[5] = fu_propagate_en;
  assign fu__opt_launch_en[5] = fu_launch_enable;
  assign fu__recv_predicate_en[5] = fu_xbar_recv_predicate_req;

endmodule



module Mux__Type_CGRAData_64_1__payload_64__predicate_1__ninputs_2
(
  input  logic [0:0] clk ,
  input  CGRAData_64_1__payload_64__predicate_1 in_ [0:1],
  output CGRAData_64_1__payload_64__predicate_1 out ,
  input  logic [0:0] reset ,
  input  logic [0:0] sel 
);

  
  always_comb begin : up_mux
    out = in_[sel];
  end

endmodule



module Mux__Type_Bits1__ninputs_2
(
  input  logic [0:0] clk ,
  input  logic [0:0] in_ [0:1],
  output logic [0:0] out ,
  input  logic [0:0] reset ,
  input  logic [0:0] sel 
);

  
  always_comb begin : up_mux
    out = in_[sel];
  end

endmodule



module NormalQueueDpath__43e370cfe3e82577
(
  input  logic [0:0] clk ,
  input  logic [0:0] config_ini ,
  output CGRAData_1__predicate_1 deq_msg ,
  input  CGRAData_1__predicate_1 enq_msg ,
  input  logic [0:0] raddr ,
  input  logic [0:0] ren ,
  input  logic [0:0] reset ,
  input  logic [0:0] waddr ,
  input  logic [0:0] wen 
);
  localparam logic [1:0] __const__num_entries_at_up_rf_write  = 2'd2;
  CGRAData_1__predicate_1 regs [0:1];
  CGRAData_1__predicate_1 regs_rdata;

  
  always_comb begin : reg_read
    if ( reset ) begin
      deq_msg = 1'd0;
    end
    else
      deq_msg = regs[raddr];
  end

  
  always_ff @(posedge clk) begin : up_rf_write
    if ( reset | config_ini ) begin
      for ( int unsigned i = 1'd0; i < 2'( __const__num_entries_at_up_rf_write ); i += 1'd1 )
        regs[1'(i)] <= 1'd0;
    end
    else if ( wen ) begin
      regs[waddr] <= enq_msg;
    end
  end

endmodule



module NormalQueue__3f9a19444e1f3cf6
(
  input  logic [0:0] clk ,
  input  logic [0:0] config_ini ,
  input  logic [0:0] deq_en ,
  output CGRAData_1__predicate_1 deq_msg ,
  output logic [0:0] deq_valid ,
  input  logic [0:0] dry_run_done ,
  input  logic [0:0] enq_en ,
  input  CGRAData_1__predicate_1 enq_msg ,
  output logic [0:0] enq_rdy ,
  input  logic [0:0] reset ,
  input  logic [0:0] sync_dry_run 
);

  logic [0:0] ctrl__clk;
  logic [0:0] ctrl__config_ini;
  logic [1:0] ctrl__count;
  logic [0:0] ctrl__deq_en;
  logic [0:0] ctrl__deq_valid;
  logic [0:0] ctrl__dry_run_done;
  logic [0:0] ctrl__enq_en;
  logic [0:0] ctrl__enq_rdy;
  logic [0:0] ctrl__raddr;
  logic [0:0] ctrl__ren;
  logic [0:0] ctrl__reset;
  logic [0:0] ctrl__sync_dry_run;
  logic [0:0] ctrl__waddr;
  logic [0:0] ctrl__wen;

  NormalQueueCtrl__num_entries_2__dry_run_enable_True ctrl
  (
    .clk( ctrl__clk ),
    .config_ini( ctrl__config_ini ),
    .count( ctrl__count ),
    .deq_en( ctrl__deq_en ),
    .deq_valid( ctrl__deq_valid ),
    .dry_run_done( ctrl__dry_run_done ),
    .enq_en( ctrl__enq_en ),
    .enq_rdy( ctrl__enq_rdy ),
    .raddr( ctrl__raddr ),
    .ren( ctrl__ren ),
    .reset( ctrl__reset ),
    .sync_dry_run( ctrl__sync_dry_run ),
    .waddr( ctrl__waddr ),
    .wen( ctrl__wen )
  );



  logic [0:0] dpath__clk;
  logic [0:0] dpath__config_ini;
  CGRAData_1__predicate_1 dpath__deq_msg;
  CGRAData_1__predicate_1 dpath__enq_msg;
  logic [0:0] dpath__raddr;
  logic [0:0] dpath__ren;
  logic [0:0] dpath__reset;
  logic [0:0] dpath__waddr;
  logic [0:0] dpath__wen;

  NormalQueueDpath__43e370cfe3e82577 dpath
  (
    .clk( dpath__clk ),
    .config_ini( dpath__config_ini ),
    .deq_msg( dpath__deq_msg ),
    .enq_msg( dpath__enq_msg ),
    .raddr( dpath__raddr ),
    .ren( dpath__ren ),
    .reset( dpath__reset ),
    .waddr( dpath__waddr ),
    .wen( dpath__wen )
  );


  assign ctrl__clk = clk;
  assign ctrl__reset = reset;
  assign dpath__clk = clk;
  assign dpath__reset = reset;
  assign dpath__config_ini = config_ini;
  assign ctrl__config_ini = config_ini;
  assign ctrl__dry_run_done = dry_run_done;
  assign ctrl__sync_dry_run = sync_dry_run;
  assign dpath__wen = ctrl__wen;
  assign dpath__ren = ctrl__ren;
  assign dpath__waddr = ctrl__waddr;
  assign dpath__raddr = ctrl__raddr;
  assign ctrl__enq_en = enq_en;
  assign enq_rdy = ctrl__enq_rdy;
  assign ctrl__deq_en = deq_en;
  assign deq_valid = ctrl__deq_valid;
  assign dpath__enq_msg = enq_msg;
  assign deq_msg = dpath__deq_msg;

endmodule



module ChannelRTL__da1c96117c8ab406
(
  input  logic [0:0] clk ,
  input  logic [0:0] config_ini ,
  input  logic [0:0] dry_run_done ,
  input  logic [0:0] recv_en ,
  input  CGRAData_1__predicate_1 recv_msg ,
  output logic [0:0] recv_rdy ,
  input  logic [0:0] reset ,
  input  logic [0:0] send_en ,
  output CGRAData_1__predicate_1 send_msg ,
  output logic [0:0] send_valid ,
  input  logic [0:0] sync_dry_run 
);

  logic [0:0] queue__clk;
  logic [0:0] queue__config_ini;
  logic [0:0] queue__deq_en;
  CGRAData_1__predicate_1 queue__deq_msg;
  logic [0:0] queue__deq_valid;
  logic [0:0] queue__dry_run_done;
  logic [0:0] queue__enq_en;
  CGRAData_1__predicate_1 queue__enq_msg;
  logic [0:0] queue__enq_rdy;
  logic [0:0] queue__reset;
  logic [0:0] queue__sync_dry_run;

  NormalQueue__3f9a19444e1f3cf6 queue
  (
    .clk( queue__clk ),
    .config_ini( queue__config_ini ),
    .deq_en( queue__deq_en ),
    .deq_msg( queue__deq_msg ),
    .deq_valid( queue__deq_valid ),
    .dry_run_done( queue__dry_run_done ),
    .enq_en( queue__enq_en ),
    .enq_msg( queue__enq_msg ),
    .enq_rdy( queue__enq_rdy ),
    .reset( queue__reset ),
    .sync_dry_run( queue__sync_dry_run )
  );


  assign queue__clk = clk;
  assign queue__reset = reset;
  assign queue__enq_en = recv_en;
  assign queue__enq_msg = recv_msg;
  assign recv_rdy = queue__enq_rdy;
  assign queue__deq_en = send_en;
  assign send_msg = queue__deq_msg;
  assign send_valid = queue__deq_valid;
  assign queue__config_ini = config_ini;
  assign queue__dry_run_done = dry_run_done;
  assign queue__sync_dry_run = sync_dry_run;

endmodule



module Mux__Type_CGRAConfig_6_4_6_8_6__70c95bde83d8947c__ninputs_2
(
  input  logic [0:0] clk ,
  input  CGRAConfig_6_4_6_8_6__70c95bde83d8947c in_ [0:1],
  output CGRAConfig_6_4_6_8_6__70c95bde83d8947c out ,
  input  logic [0:0] reset ,
  input  logic [0:0] sel 
);

  
  always_comb begin : up_mux
    out = in_[sel];
  end

endmodule



module TileRTL__4db54fb92d7fbf49
(
  input  logic [0:0] clk ,
  input  logic [5:0] config_cmd_counter_th ,
  input  logic [5:0] config_data_counter_th ,
  input  logic [0:0] ctrl_slice_idx ,
  input  logic [31:0] recv_const ,
  input  logic [0:0] recv_const_en ,
  input  logic [4:0] recv_const_waddr ,
  input  CGRAData_64_1__payload_64__predicate_1 recv_data [0:3],
  output logic [0:0] recv_data_ack [0:3],
  input  logic [0:0] recv_data_valid [0:3],
  input  logic [4:0] recv_opt_waddr ,
  input  logic [0:0] recv_opt_waddr_en ,
  input  logic [31:0] recv_wopt ,
  input  logic [0:0] recv_wopt_en ,
  input  logic [0:0] reset ,
  output CGRAData_64_1__payload_64__predicate_1 send_data [0:3],
  input  logic [0:0] send_data_ack [0:3],
  output logic [0:0] send_data_valid [0:3],
  input  logic [0:0] tile_config_ini_begin ,
  input  logic [0:0] tile_dry_run_ack ,
  input  logic [0:0] tile_dry_run_done ,
  input  logic [0:0] tile_execution_begin ,
  input  logic [0:0] tile_execution_ini_begin ,
  input  logic [0:0] tile_execution_valid ,
  output logic [0:0] tile_fu_propagate_rdy ,
  output logic [0:0] tile_xbar_propagate_rdy ,
  input logic [0:0] from_mem_rdata__en  ,
  input CGRAData_64_1__payload_64__predicate_1 from_mem_rdata__msg  ,
  output logic [0:0] from_mem_rdata__rdy  ,
  output logic [0:0] to_mem_raddr__en  ,
  output logic [6:0] to_mem_raddr__msg  ,
  input logic [0:0] to_mem_raddr__rdy  ,
  output logic [0:0] to_mem_waddr__en  ,
  output logic [6:0] to_mem_waddr__msg  ,
  input logic [0:0] to_mem_waddr__rdy  ,
  output logic [0:0] to_mem_wdata__en  ,
  output CGRAData_64_1__payload_64__predicate_1 to_mem_wdata__msg  ,
  input logic [0:0] to_mem_wdata__rdy  
);
  CGRAConfig_6_4_6_8_6__70c95bde83d8947c tile_ctrl_msg;
  logic [0:0] tile_dry_run_begin;
  logic [0:0] tile_opt_enable;
  logic [0:0] tile_propagate_en;

  logic [0:0] channel__clk [0:7];
  logic [0:0] channel__config_ini [0:7];
  logic [0:0] channel__dry_run_done [0:7];
  logic [0:0] channel__recv_en [0:7];
  CGRAData_64_1__payload_64__predicate_1 channel__recv_msg [0:7];
  logic [0:0] channel__recv_rdy [0:7];
  logic [0:0] channel__reset [0:7];
  logic [0:0] channel__send_en [0:7];
  CGRAData_64_1__payload_64__predicate_1 channel__send_msg [0:7];
  logic [0:0] channel__send_valid [0:7];
  logic [0:0] channel__sync_dry_run [0:7];

  ChannelRTL__511b7cda5540ec2e channel__0
  (
    .clk( channel__clk[0] ),
    .config_ini( channel__config_ini[0] ),
    .dry_run_done( channel__dry_run_done[0] ),
    .recv_en( channel__recv_en[0] ),
    .recv_msg( channel__recv_msg[0] ),
    .recv_rdy( channel__recv_rdy[0] ),
    .reset( channel__reset[0] ),
    .send_en( channel__send_en[0] ),
    .send_msg( channel__send_msg[0] ),
    .send_valid( channel__send_valid[0] ),
    .sync_dry_run( channel__sync_dry_run[0] )
  );

  ChannelRTL__511b7cda5540ec2e channel__1
  (
    .clk( channel__clk[1] ),
    .config_ini( channel__config_ini[1] ),
    .dry_run_done( channel__dry_run_done[1] ),
    .recv_en( channel__recv_en[1] ),
    .recv_msg( channel__recv_msg[1] ),
    .recv_rdy( channel__recv_rdy[1] ),
    .reset( channel__reset[1] ),
    .send_en( channel__send_en[1] ),
    .send_msg( channel__send_msg[1] ),
    .send_valid( channel__send_valid[1] ),
    .sync_dry_run( channel__sync_dry_run[1] )
  );

  ChannelRTL__511b7cda5540ec2e channel__2
  (
    .clk( channel__clk[2] ),
    .config_ini( channel__config_ini[2] ),
    .dry_run_done( channel__dry_run_done[2] ),
    .recv_en( channel__recv_en[2] ),
    .recv_msg( channel__recv_msg[2] ),
    .recv_rdy( channel__recv_rdy[2] ),
    .reset( channel__reset[2] ),
    .send_en( channel__send_en[2] ),
    .send_msg( channel__send_msg[2] ),
    .send_valid( channel__send_valid[2] ),
    .sync_dry_run( channel__sync_dry_run[2] )
  );

  ChannelRTL__511b7cda5540ec2e channel__3
  (
    .clk( channel__clk[3] ),
    .config_ini( channel__config_ini[3] ),
    .dry_run_done( channel__dry_run_done[3] ),
    .recv_en( channel__recv_en[3] ),
    .recv_msg( channel__recv_msg[3] ),
    .recv_rdy( channel__recv_rdy[3] ),
    .reset( channel__reset[3] ),
    .send_en( channel__send_en[3] ),
    .send_msg( channel__send_msg[3] ),
    .send_valid( channel__send_valid[3] ),
    .sync_dry_run( channel__sync_dry_run[3] )
  );

  ChannelRTL__511b7cda5540ec2e channel__4
  (
    .clk( channel__clk[4] ),
    .config_ini( channel__config_ini[4] ),
    .dry_run_done( channel__dry_run_done[4] ),
    .recv_en( channel__recv_en[4] ),
    .recv_msg( channel__recv_msg[4] ),
    .recv_rdy( channel__recv_rdy[4] ),
    .reset( channel__reset[4] ),
    .send_en( channel__send_en[4] ),
    .send_msg( channel__send_msg[4] ),
    .send_valid( channel__send_valid[4] ),
    .sync_dry_run( channel__sync_dry_run[4] )
  );

  ChannelRTL__511b7cda5540ec2e channel__5
  (
    .clk( channel__clk[5] ),
    .config_ini( channel__config_ini[5] ),
    .dry_run_done( channel__dry_run_done[5] ),
    .recv_en( channel__recv_en[5] ),
    .recv_msg( channel__recv_msg[5] ),
    .recv_rdy( channel__recv_rdy[5] ),
    .reset( channel__reset[5] ),
    .send_en( channel__send_en[5] ),
    .send_msg( channel__send_msg[5] ),
    .send_valid( channel__send_valid[5] ),
    .sync_dry_run( channel__sync_dry_run[5] )
  );

  ChannelRTL__511b7cda5540ec2e channel__6
  (
    .clk( channel__clk[6] ),
    .config_ini( channel__config_ini[6] ),
    .dry_run_done( channel__dry_run_done[6] ),
    .recv_en( channel__recv_en[6] ),
    .recv_msg( channel__recv_msg[6] ),
    .recv_rdy( channel__recv_rdy[6] ),
    .reset( channel__reset[6] ),
    .send_en( channel__send_en[6] ),
    .send_msg( channel__send_msg[6] ),
    .send_valid( channel__send_valid[6] ),
    .sync_dry_run( channel__sync_dry_run[6] )
  );

  ChannelRTL__511b7cda5540ec2e channel__7
  (
    .clk( channel__clk[7] ),
    .config_ini( channel__config_ini[7] ),
    .dry_run_done( channel__dry_run_done[7] ),
    .recv_en( channel__recv_en[7] ),
    .recv_msg( channel__recv_msg[7] ),
    .recv_rdy( channel__recv_rdy[7] ),
    .reset( channel__reset[7] ),
    .send_en( channel__send_en[7] ),
    .send_msg( channel__send_msg[7] ),
    .send_valid( channel__send_valid[7] ),
    .sync_dry_run( channel__sync_dry_run[7] )
  );



  logic [0:0] const_queue__clk;
  logic [0:0] const_queue__config_ini;
  logic [0:0] const_queue__dry_run_done;
  logic [0:0] const_queue__execution_ini;
  logic [31:0] const_queue__recv_const;
  logic [0:0] const_queue__recv_const_en;
  logic [4:0] const_queue__recv_const_waddr;
  logic [0:0] const_queue__reset;
  logic [0:0] const_queue__send_const_en;
  logic [31:0] const_queue__send_const_msg;

  ConstQueueRTL__a158caae8f1a5180 const_queue
  (
    .clk( const_queue__clk ),
    .config_ini( const_queue__config_ini ),
    .dry_run_done( const_queue__dry_run_done ),
    .execution_ini( const_queue__execution_ini ),
    .recv_const( const_queue__recv_const ),
    .recv_const_en( const_queue__recv_const_en ),
    .recv_const_waddr( const_queue__recv_const_waddr ),
    .reset( const_queue__reset ),
    .send_const_en( const_queue__send_const_en ),
    .send_const_msg( const_queue__send_const_msg )
  );



  logic [0:0] crossbar__clk;
  logic [2:0] crossbar__recv_opt_msg_outport [0:7];
  logic [5:0] crossbar__recv_opt_msg_predicate_in;
  CGRAData_64_1__payload_64__predicate_1 crossbar__recv_port_data [0:5];
  logic [0:0] crossbar__recv_port_fu_out_ack;
  logic [3:0] crossbar__recv_port_mesh_in_ack;
  logic [5:0] crossbar__recv_port_valid;
  logic [0:0] crossbar__reset;
  logic [3:0] crossbar__send_bypass_data_valid;
  logic [3:0] crossbar__send_bypass_port_ack;
  logic [3:0] crossbar__send_bypass_req;
  CGRAData_64_1__payload_64__predicate_1 crossbar__send_data_bypass [0:3];
  CGRAData_64_1__payload_64__predicate_1 crossbar__send_port_data [0:7];
  logic [8:0] crossbar__send_port_en;
  logic [7:0] crossbar__send_port_rdy;
  CGRAData_1__predicate_1 crossbar__send_predicate;
  logic [0:0] crossbar__send_predicate_rdy;
  logic [0:0] crossbar__xbar_dry_run_ack;
  logic [0:0] crossbar__xbar_dry_run_begin;
  logic [0:0] crossbar__xbar_opt_enable;
  logic [0:0] crossbar__xbar_propagate_en;
  logic [0:0] crossbar__xbar_propagate_rdy;

  CrossbarRTL__9e234a3e66000aaa crossbar
  (
    .clk( crossbar__clk ),
    .recv_opt_msg_outport( crossbar__recv_opt_msg_outport ),
    .recv_opt_msg_predicate_in( crossbar__recv_opt_msg_predicate_in ),
    .recv_port_data( crossbar__recv_port_data ),
    .recv_port_fu_out_ack( crossbar__recv_port_fu_out_ack ),
    .recv_port_mesh_in_ack( crossbar__recv_port_mesh_in_ack ),
    .recv_port_valid( crossbar__recv_port_valid ),
    .reset( crossbar__reset ),
    .send_bypass_data_valid( crossbar__send_bypass_data_valid ),
    .send_bypass_port_ack( crossbar__send_bypass_port_ack ),
    .send_bypass_req( crossbar__send_bypass_req ),
    .send_data_bypass( crossbar__send_data_bypass ),
    .send_port_data( crossbar__send_port_data ),
    .send_port_en( crossbar__send_port_en ),
    .send_port_rdy( crossbar__send_port_rdy ),
    .send_predicate( crossbar__send_predicate ),
    .send_predicate_rdy( crossbar__send_predicate_rdy ),
    .xbar_dry_run_ack( crossbar__xbar_dry_run_ack ),
    .xbar_dry_run_begin( crossbar__xbar_dry_run_begin ),
    .xbar_opt_enable( crossbar__xbar_opt_enable ),
    .xbar_propagate_en( crossbar__xbar_propagate_en ),
    .xbar_propagate_rdy( crossbar__xbar_propagate_rdy )
  );



  logic [0:0] ctrl_mem__clk;
  logic [5:0] ctrl_mem__cmd_counter_th;
  logic [0:0] ctrl_mem__execution_ini;
  logic [0:0] ctrl_mem__nxt_ctrl_en;
  CGRAConfig_6_4_6_8_6__70c95bde83d8947c ctrl_mem__recv_ctrl_msg;
  logic [31:0] ctrl_mem__recv_ctrl_slice;
  logic [0:0] ctrl_mem__recv_ctrl_slice_en;
  logic [0:0] ctrl_mem__recv_ctrl_slice_idx;
  logic [4:0] ctrl_mem__recv_waddr;
  logic [0:0] ctrl_mem__recv_waddr_en;
  logic [0:0] ctrl_mem__reset;
  CGRAConfig_6_4_6_8_6__70c95bde83d8947c ctrl_mem__send_ctrl_msg;

  CtrlMemRTL__a01c7414dc24348f ctrl_mem
  (
    .clk( ctrl_mem__clk ),
    .cmd_counter_th( ctrl_mem__cmd_counter_th ),
    .execution_ini( ctrl_mem__execution_ini ),
    .nxt_ctrl_en( ctrl_mem__nxt_ctrl_en ),
    .recv_ctrl_msg( ctrl_mem__recv_ctrl_msg ),
    .recv_ctrl_slice( ctrl_mem__recv_ctrl_slice ),
    .recv_ctrl_slice_en( ctrl_mem__recv_ctrl_slice_en ),
    .recv_ctrl_slice_idx( ctrl_mem__recv_ctrl_slice_idx ),
    .recv_waddr( ctrl_mem__recv_waddr ),
    .recv_waddr_en( ctrl_mem__recv_waddr_en ),
    .reset( ctrl_mem__reset ),
    .send_ctrl_msg( ctrl_mem__send_ctrl_msg )
  );



  logic [0:0] demux_bypass_ack__clk [0:3];
  logic [0:0] demux_bypass_ack__in_ [0:3];
  logic [0:0] demux_bypass_ack__out [0:3][0:1];
  logic [0:0] demux_bypass_ack__reset [0:3];
  logic [0:0] demux_bypass_ack__sel [0:3];

  Demux__Type_Bits1__noutputs_2 demux_bypass_ack__0
  (
    .clk( demux_bypass_ack__clk[0] ),
    .in_( demux_bypass_ack__in_[0] ),
    .out( demux_bypass_ack__out[0] ),
    .reset( demux_bypass_ack__reset[0] ),
    .sel( demux_bypass_ack__sel[0] )
  );

  Demux__Type_Bits1__noutputs_2 demux_bypass_ack__1
  (
    .clk( demux_bypass_ack__clk[1] ),
    .in_( demux_bypass_ack__in_[1] ),
    .out( demux_bypass_ack__out[1] ),
    .reset( demux_bypass_ack__reset[1] ),
    .sel( demux_bypass_ack__sel[1] )
  );

  Demux__Type_Bits1__noutputs_2 demux_bypass_ack__2
  (
    .clk( demux_bypass_ack__clk[2] ),
    .in_( demux_bypass_ack__in_[2] ),
    .out( demux_bypass_ack__out[2] ),
    .reset( demux_bypass_ack__reset[2] ),
    .sel( demux_bypass_ack__sel[2] )
  );

  Demux__Type_Bits1__noutputs_2 demux_bypass_ack__3
  (
    .clk( demux_bypass_ack__clk[3] ),
    .in_( demux_bypass_ack__in_[3] ),
    .out( demux_bypass_ack__out[3] ),
    .reset( demux_bypass_ack__reset[3] ),
    .sel( demux_bypass_ack__sel[3] )
  );



  logic [0:0] element__clk;
  logic [0:0] element__fu_dry_run_ack;
  logic [0:0] element__fu_dry_run_begin;
  logic [0:0] element__fu_execution_ini;
  logic [0:0] element__fu_execution_valid;
  logic [0:0] element__fu_opt_enable;
  logic [0:0] element__fu_propagate_en;
  logic [0:0] element__fu_propagate_rdy;
  logic [0:0] element__recv_const_ack;
  logic [31:0] element__recv_const_data;
  logic [5:0] element__recv_opt_msg_ctrl;
  logic [2:0] element__recv_opt_msg_fu_in [0:3];
  logic [5:0] element__recv_opt_msg_out_routine;
  logic [0:0] element__recv_opt_msg_predicate;
  logic [3:0] element__recv_port_ack;
  CGRAData_64_1__payload_64__predicate_1 element__recv_port_data [0:3];
  logic [3:0] element__recv_port_valid;
  logic [0:0] element__recv_predicate_ack;
  CGRAData_1__predicate_1 element__recv_predicate_data;
  logic [0:0] element__recv_predicate_valid;
  logic [0:0] element__reset;
  logic [0:0] element__send_port_ack;
  CGRAData_64_1__payload_64__predicate_1 element__send_port_data [0:1];
  logic [1:0] element__send_port_valid;
  logic [0:0] element__from_mem_rdata__en [0:5];
  CGRAData_64_1__payload_64__predicate_1 element__from_mem_rdata__msg [0:5];
  logic [0:0] element__from_mem_rdata__rdy [0:5];
  logic [0:0] element__to_mem_raddr__en [0:5];
  logic [6:0] element__to_mem_raddr__msg [0:5];
  logic [0:0] element__to_mem_raddr__rdy [0:5];
  logic [0:0] element__to_mem_waddr__en [0:5];
  logic [6:0] element__to_mem_waddr__msg [0:5];
  logic [0:0] element__to_mem_waddr__rdy [0:5];
  logic [0:0] element__to_mem_wdata__en [0:5];
  CGRAData_64_1__payload_64__predicate_1 element__to_mem_wdata__msg [0:5];
  logic [0:0] element__to_mem_wdata__rdy [0:5];

  FlexibleFuRTL__91761f0c1c309163 element
  (
    .clk( element__clk ),
    .fu_dry_run_ack( element__fu_dry_run_ack ),
    .fu_dry_run_begin( element__fu_dry_run_begin ),
    .fu_execution_ini( element__fu_execution_ini ),
    .fu_execution_valid( element__fu_execution_valid ),
    .fu_opt_enable( element__fu_opt_enable ),
    .fu_propagate_en( element__fu_propagate_en ),
    .fu_propagate_rdy( element__fu_propagate_rdy ),
    .recv_const_ack( element__recv_const_ack ),
    .recv_const_data( element__recv_const_data ),
    .recv_opt_msg_ctrl( element__recv_opt_msg_ctrl ),
    .recv_opt_msg_fu_in( element__recv_opt_msg_fu_in ),
    .recv_opt_msg_out_routine( element__recv_opt_msg_out_routine ),
    .recv_opt_msg_predicate( element__recv_opt_msg_predicate ),
    .recv_port_ack( element__recv_port_ack ),
    .recv_port_data( element__recv_port_data ),
    .recv_port_valid( element__recv_port_valid ),
    .recv_predicate_ack( element__recv_predicate_ack ),
    .recv_predicate_data( element__recv_predicate_data ),
    .recv_predicate_valid( element__recv_predicate_valid ),
    .reset( element__reset ),
    .send_port_ack( element__send_port_ack ),
    .send_port_data( element__send_port_data ),
    .send_port_valid( element__send_port_valid ),
    .from_mem_rdata__en( element__from_mem_rdata__en ),
    .from_mem_rdata__msg( element__from_mem_rdata__msg ),
    .from_mem_rdata__rdy( element__from_mem_rdata__rdy ),
    .to_mem_raddr__en( element__to_mem_raddr__en ),
    .to_mem_raddr__msg( element__to_mem_raddr__msg ),
    .to_mem_raddr__rdy( element__to_mem_raddr__rdy ),
    .to_mem_waddr__en( element__to_mem_waddr__en ),
    .to_mem_waddr__msg( element__to_mem_waddr__msg ),
    .to_mem_waddr__rdy( element__to_mem_waddr__rdy ),
    .to_mem_wdata__en( element__to_mem_wdata__en ),
    .to_mem_wdata__msg( element__to_mem_wdata__msg ),
    .to_mem_wdata__rdy( element__to_mem_wdata__rdy )
  );



  logic [0:0] mux_bypass_data__clk [0:3];
  CGRAData_64_1__payload_64__predicate_1 mux_bypass_data__in_ [0:3][0:1];
  CGRAData_64_1__payload_64__predicate_1 mux_bypass_data__out [0:3];
  logic [0:0] mux_bypass_data__reset [0:3];
  logic [0:0] mux_bypass_data__sel [0:3];

  Mux__Type_CGRAData_64_1__payload_64__predicate_1__ninputs_2 mux_bypass_data__0
  (
    .clk( mux_bypass_data__clk[0] ),
    .in_( mux_bypass_data__in_[0] ),
    .out( mux_bypass_data__out[0] ),
    .reset( mux_bypass_data__reset[0] ),
    .sel( mux_bypass_data__sel[0] )
  );

  Mux__Type_CGRAData_64_1__payload_64__predicate_1__ninputs_2 mux_bypass_data__1
  (
    .clk( mux_bypass_data__clk[1] ),
    .in_( mux_bypass_data__in_[1] ),
    .out( mux_bypass_data__out[1] ),
    .reset( mux_bypass_data__reset[1] ),
    .sel( mux_bypass_data__sel[1] )
  );

  Mux__Type_CGRAData_64_1__payload_64__predicate_1__ninputs_2 mux_bypass_data__2
  (
    .clk( mux_bypass_data__clk[2] ),
    .in_( mux_bypass_data__in_[2] ),
    .out( mux_bypass_data__out[2] ),
    .reset( mux_bypass_data__reset[2] ),
    .sel( mux_bypass_data__sel[2] )
  );

  Mux__Type_CGRAData_64_1__payload_64__predicate_1__ninputs_2 mux_bypass_data__3
  (
    .clk( mux_bypass_data__clk[3] ),
    .in_( mux_bypass_data__in_[3] ),
    .out( mux_bypass_data__out[3] ),
    .reset( mux_bypass_data__reset[3] ),
    .sel( mux_bypass_data__sel[3] )
  );



  logic [0:0] mux_bypass_valid__clk [0:3];
  logic [0:0] mux_bypass_valid__in_ [0:3][0:1];
  logic [0:0] mux_bypass_valid__out [0:3];
  logic [0:0] mux_bypass_valid__reset [0:3];
  logic [0:0] mux_bypass_valid__sel [0:3];

  Mux__Type_Bits1__ninputs_2 mux_bypass_valid__0
  (
    .clk( mux_bypass_valid__clk[0] ),
    .in_( mux_bypass_valid__in_[0] ),
    .out( mux_bypass_valid__out[0] ),
    .reset( mux_bypass_valid__reset[0] ),
    .sel( mux_bypass_valid__sel[0] )
  );

  Mux__Type_Bits1__ninputs_2 mux_bypass_valid__1
  (
    .clk( mux_bypass_valid__clk[1] ),
    .in_( mux_bypass_valid__in_[1] ),
    .out( mux_bypass_valid__out[1] ),
    .reset( mux_bypass_valid__reset[1] ),
    .sel( mux_bypass_valid__sel[1] )
  );

  Mux__Type_Bits1__ninputs_2 mux_bypass_valid__2
  (
    .clk( mux_bypass_valid__clk[2] ),
    .in_( mux_bypass_valid__in_[2] ),
    .out( mux_bypass_valid__out[2] ),
    .reset( mux_bypass_valid__reset[2] ),
    .sel( mux_bypass_valid__sel[2] )
  );

  Mux__Type_Bits1__ninputs_2 mux_bypass_valid__3
  (
    .clk( mux_bypass_valid__clk[3] ),
    .in_( mux_bypass_valid__in_[3] ),
    .out( mux_bypass_valid__out[3] ),
    .reset( mux_bypass_valid__reset[3] ),
    .sel( mux_bypass_valid__sel[3] )
  );



  logic [0:0] reg_predicate__clk;
  logic [0:0] reg_predicate__config_ini;
  logic [0:0] reg_predicate__dry_run_done;
  logic [0:0] reg_predicate__recv_en;
  CGRAData_1__predicate_1 reg_predicate__recv_msg;
  logic [0:0] reg_predicate__recv_rdy;
  logic [0:0] reg_predicate__reset;
  logic [0:0] reg_predicate__send_en;
  CGRAData_1__predicate_1 reg_predicate__send_msg;
  logic [0:0] reg_predicate__send_valid;
  logic [0:0] reg_predicate__sync_dry_run;

  ChannelRTL__da1c96117c8ab406 reg_predicate
  (
    .clk( reg_predicate__clk ),
    .config_ini( reg_predicate__config_ini ),
    .dry_run_done( reg_predicate__dry_run_done ),
    .recv_en( reg_predicate__recv_en ),
    .recv_msg( reg_predicate__recv_msg ),
    .recv_rdy( reg_predicate__recv_rdy ),
    .reset( reg_predicate__reset ),
    .send_en( reg_predicate__send_en ),
    .send_msg( reg_predicate__send_msg ),
    .send_valid( reg_predicate__send_valid ),
    .sync_dry_run( reg_predicate__sync_dry_run )
  );



  logic [0:0] tile_ctrl_mux__clk;
  CGRAConfig_6_4_6_8_6__70c95bde83d8947c tile_ctrl_mux__in_ [0:1];
  CGRAConfig_6_4_6_8_6__70c95bde83d8947c tile_ctrl_mux__out;
  logic [0:0] tile_ctrl_mux__reset;
  logic [0:0] tile_ctrl_mux__sel;

  Mux__Type_CGRAConfig_6_4_6_8_6__70c95bde83d8947c__ninputs_2 tile_ctrl_mux
  (
    .clk( tile_ctrl_mux__clk ),
    .in_( tile_ctrl_mux__in_ ),
    .out( tile_ctrl_mux__out ),
    .reset( tile_ctrl_mux__reset ),
    .sel( tile_ctrl_mux__sel )
  );


  
  always_comb begin : _lambda__s_tile_0__tile_opt_enable
    tile_opt_enable = tile_dry_run_begin | tile_execution_begin;
  end

  
  always_comb begin : _lambda__s_tile_0__tile_propagate_en
    tile_propagate_en = crossbar__xbar_propagate_rdy & element__fu_propagate_rdy;
  end

  assign element__clk = clk;
  assign element__reset = reset;
  assign const_queue__clk = clk;
  assign const_queue__reset = reset;
  assign crossbar__clk = clk;
  assign crossbar__reset = reset;
  assign tile_ctrl_mux__clk = clk;
  assign tile_ctrl_mux__reset = reset;
  assign ctrl_mem__clk = clk;
  assign ctrl_mem__reset = reset;
  assign channel__clk[0] = clk;
  assign channel__reset[0] = reset;
  assign channel__clk[1] = clk;
  assign channel__reset[1] = reset;
  assign channel__clk[2] = clk;
  assign channel__reset[2] = reset;
  assign channel__clk[3] = clk;
  assign channel__reset[3] = reset;
  assign channel__clk[4] = clk;
  assign channel__reset[4] = reset;
  assign channel__clk[5] = clk;
  assign channel__reset[5] = reset;
  assign channel__clk[6] = clk;
  assign channel__reset[6] = reset;
  assign channel__clk[7] = clk;
  assign channel__reset[7] = reset;
  assign reg_predicate__clk = clk;
  assign reg_predicate__reset = reset;
  assign mux_bypass_valid__clk[0] = clk;
  assign mux_bypass_valid__reset[0] = reset;
  assign mux_bypass_valid__clk[1] = clk;
  assign mux_bypass_valid__reset[1] = reset;
  assign mux_bypass_valid__clk[2] = clk;
  assign mux_bypass_valid__reset[2] = reset;
  assign mux_bypass_valid__clk[3] = clk;
  assign mux_bypass_valid__reset[3] = reset;
  assign demux_bypass_ack__clk[0] = clk;
  assign demux_bypass_ack__reset[0] = reset;
  assign demux_bypass_ack__clk[1] = clk;
  assign demux_bypass_ack__reset[1] = reset;
  assign demux_bypass_ack__clk[2] = clk;
  assign demux_bypass_ack__reset[2] = reset;
  assign demux_bypass_ack__clk[3] = clk;
  assign demux_bypass_ack__reset[3] = reset;
  assign mux_bypass_data__clk[0] = clk;
  assign mux_bypass_data__reset[0] = reset;
  assign mux_bypass_data__clk[1] = clk;
  assign mux_bypass_data__reset[1] = reset;
  assign mux_bypass_data__clk[2] = clk;
  assign mux_bypass_data__reset[2] = reset;
  assign mux_bypass_data__clk[3] = clk;
  assign mux_bypass_data__reset[3] = reset;
  assign tile_dry_run_begin = recv_opt_waddr_en;
  assign const_queue__config_ini = tile_config_ini_begin;
  assign const_queue__execution_ini = tile_execution_ini_begin;
  assign const_queue__dry_run_done = tile_dry_run_done;
  assign const_queue__recv_const = recv_const;
  assign const_queue__recv_const_en = recv_const_en;
  assign const_queue__recv_const_waddr = recv_const_waddr;
  assign ctrl_mem__recv_ctrl_slice_idx = ctrl_slice_idx;
  assign ctrl_mem__recv_waddr = recv_opt_waddr;
  assign ctrl_mem__recv_waddr_en = recv_opt_waddr_en;
  assign ctrl_mem__recv_ctrl_slice = recv_wopt;
  assign ctrl_mem__recv_ctrl_slice_en = recv_wopt_en;
  assign ctrl_mem__cmd_counter_th = config_cmd_counter_th;
  assign ctrl_mem__execution_ini = tile_execution_ini_begin;
  assign ctrl_mem__nxt_ctrl_en = tile_propagate_en;
  assign channel__config_ini[0] = tile_config_ini_begin;
  assign channel__dry_run_done[0] = tile_dry_run_done;
  assign channel__sync_dry_run[0] = tile_execution_ini_begin;
  assign channel__config_ini[1] = tile_config_ini_begin;
  assign channel__dry_run_done[1] = tile_dry_run_done;
  assign channel__sync_dry_run[1] = tile_execution_ini_begin;
  assign channel__config_ini[2] = tile_config_ini_begin;
  assign channel__dry_run_done[2] = tile_dry_run_done;
  assign channel__sync_dry_run[2] = tile_execution_ini_begin;
  assign channel__config_ini[3] = tile_config_ini_begin;
  assign channel__dry_run_done[3] = tile_dry_run_done;
  assign channel__sync_dry_run[3] = tile_execution_ini_begin;
  assign channel__config_ini[4] = tile_config_ini_begin;
  assign channel__dry_run_done[4] = tile_dry_run_done;
  assign channel__sync_dry_run[4] = tile_execution_ini_begin;
  assign channel__config_ini[5] = tile_config_ini_begin;
  assign channel__dry_run_done[5] = tile_dry_run_done;
  assign channel__sync_dry_run[5] = tile_execution_ini_begin;
  assign channel__config_ini[6] = tile_config_ini_begin;
  assign channel__dry_run_done[6] = tile_dry_run_done;
  assign channel__sync_dry_run[6] = tile_execution_ini_begin;
  assign channel__config_ini[7] = tile_config_ini_begin;
  assign channel__dry_run_done[7] = tile_dry_run_done;
  assign channel__sync_dry_run[7] = tile_execution_ini_begin;
  assign reg_predicate__config_ini = tile_config_ini_begin;
  assign reg_predicate__dry_run_done = tile_dry_run_done;
  assign reg_predicate__sync_dry_run = tile_execution_ini_begin;
  assign tile_ctrl_mux__in_[0] = ctrl_mem__send_ctrl_msg;
  assign tile_ctrl_mux__in_[1] = ctrl_mem__recv_ctrl_msg;
  assign tile_ctrl_msg = tile_ctrl_mux__out;
  assign tile_ctrl_mux__sel = tile_dry_run_begin;
  assign crossbar__recv_opt_msg_outport[0] = tile_ctrl_msg.outport[0];
  assign crossbar__recv_opt_msg_outport[1] = tile_ctrl_msg.outport[1];
  assign crossbar__recv_opt_msg_outport[2] = tile_ctrl_msg.outport[2];
  assign crossbar__recv_opt_msg_outport[3] = tile_ctrl_msg.outport[3];
  assign crossbar__recv_opt_msg_outport[4] = tile_ctrl_msg.outport[4];
  assign crossbar__recv_opt_msg_outport[5] = tile_ctrl_msg.outport[5];
  assign crossbar__recv_opt_msg_outport[6] = tile_ctrl_msg.outport[6];
  assign crossbar__recv_opt_msg_outport[7] = tile_ctrl_msg.outport[7];
  assign crossbar__recv_opt_msg_predicate_in[0:0] = tile_ctrl_msg.predicate_in[0];
  assign crossbar__recv_opt_msg_predicate_in[1:1] = tile_ctrl_msg.predicate_in[1];
  assign crossbar__recv_opt_msg_predicate_in[2:2] = tile_ctrl_msg.predicate_in[2];
  assign crossbar__recv_opt_msg_predicate_in[3:3] = tile_ctrl_msg.predicate_in[3];
  assign crossbar__recv_opt_msg_predicate_in[4:4] = tile_ctrl_msg.predicate_in[4];
  assign crossbar__recv_opt_msg_predicate_in[5:5] = tile_ctrl_msg.predicate_in[5];
  assign crossbar__xbar_opt_enable = tile_opt_enable;
  assign crossbar__xbar_dry_run_begin = tile_dry_run_begin;
  assign crossbar__xbar_dry_run_ack = tile_dry_run_ack;
  assign crossbar__xbar_propagate_en = tile_propagate_en;
  assign crossbar__recv_port_data[0] = recv_data[0];
  assign recv_data_ack[0] = crossbar__recv_port_mesh_in_ack[0:0];
  assign crossbar__recv_port_valid[0:0] = recv_data_valid[0];
  assign crossbar__recv_port_data[1] = recv_data[1];
  assign recv_data_ack[1] = crossbar__recv_port_mesh_in_ack[1:1];
  assign crossbar__recv_port_valid[1:1] = recv_data_valid[1];
  assign crossbar__recv_port_data[2] = recv_data[2];
  assign recv_data_ack[2] = crossbar__recv_port_mesh_in_ack[2:2];
  assign crossbar__recv_port_valid[2:2] = recv_data_valid[2];
  assign crossbar__recv_port_data[3] = recv_data[3];
  assign recv_data_ack[3] = crossbar__recv_port_mesh_in_ack[3:3];
  assign crossbar__recv_port_valid[3:3] = recv_data_valid[3];
  assign channel__recv_msg[0] = crossbar__send_port_data[0];
  assign channel__recv_en[0] = crossbar__send_port_en[0:0];
  assign crossbar__send_port_rdy[0:0] = channel__recv_rdy[0];
  assign channel__recv_msg[1] = crossbar__send_port_data[1];
  assign channel__recv_en[1] = crossbar__send_port_en[1:1];
  assign crossbar__send_port_rdy[1:1] = channel__recv_rdy[1];
  assign channel__recv_msg[2] = crossbar__send_port_data[2];
  assign channel__recv_en[2] = crossbar__send_port_en[2:2];
  assign crossbar__send_port_rdy[2:2] = channel__recv_rdy[2];
  assign channel__recv_msg[3] = crossbar__send_port_data[3];
  assign channel__recv_en[3] = crossbar__send_port_en[3:3];
  assign crossbar__send_port_rdy[3:3] = channel__recv_rdy[3];
  assign channel__recv_msg[4] = crossbar__send_port_data[4];
  assign channel__recv_en[4] = crossbar__send_port_en[4:4];
  assign crossbar__send_port_rdy[4:4] = channel__recv_rdy[4];
  assign channel__recv_msg[5] = crossbar__send_port_data[5];
  assign channel__recv_en[5] = crossbar__send_port_en[5:5];
  assign crossbar__send_port_rdy[5:5] = channel__recv_rdy[5];
  assign channel__recv_msg[6] = crossbar__send_port_data[6];
  assign channel__recv_en[6] = crossbar__send_port_en[6:6];
  assign crossbar__send_port_rdy[6:6] = channel__recv_rdy[6];
  assign channel__recv_msg[7] = crossbar__send_port_data[7];
  assign channel__recv_en[7] = crossbar__send_port_en[7:7];
  assign crossbar__send_port_rdy[7:7] = channel__recv_rdy[7];
  assign reg_predicate__recv_msg = crossbar__send_predicate;
  assign crossbar__send_predicate_rdy = reg_predicate__recv_rdy;
  assign reg_predicate__recv_en = crossbar__send_port_en[8:8];
  assign demux_bypass_ack__in_[0] = send_data_ack[0];
  assign channel__send_en[0] = demux_bypass_ack__out[0][0];
  assign crossbar__send_bypass_port_ack[0:0] = demux_bypass_ack__out[0][1];
  assign demux_bypass_ack__sel[0] = crossbar__send_bypass_req[0:0];
  assign mux_bypass_valid__in_[0][0] = channel__send_valid[0];
  assign mux_bypass_valid__in_[0][1] = crossbar__send_bypass_data_valid[0:0];
  assign send_data_valid[0] = mux_bypass_valid__out[0];
  assign mux_bypass_valid__sel[0] = crossbar__send_bypass_req[0:0];
  assign mux_bypass_data__in_[0][0] = channel__send_msg[0];
  assign mux_bypass_data__in_[0][1] = crossbar__send_data_bypass[0];
  assign send_data[0] = mux_bypass_data__out[0];
  assign mux_bypass_data__sel[0] = crossbar__send_bypass_req[0:0];
  assign demux_bypass_ack__in_[1] = send_data_ack[1];
  assign channel__send_en[1] = demux_bypass_ack__out[1][0];
  assign crossbar__send_bypass_port_ack[1:1] = demux_bypass_ack__out[1][1];
  assign demux_bypass_ack__sel[1] = crossbar__send_bypass_req[1:1];
  assign mux_bypass_valid__in_[1][0] = channel__send_valid[1];
  assign mux_bypass_valid__in_[1][1] = crossbar__send_bypass_data_valid[1:1];
  assign send_data_valid[1] = mux_bypass_valid__out[1];
  assign mux_bypass_valid__sel[1] = crossbar__send_bypass_req[1:1];
  assign mux_bypass_data__in_[1][0] = channel__send_msg[1];
  assign mux_bypass_data__in_[1][1] = crossbar__send_data_bypass[1];
  assign send_data[1] = mux_bypass_data__out[1];
  assign mux_bypass_data__sel[1] = crossbar__send_bypass_req[1:1];
  assign demux_bypass_ack__in_[2] = send_data_ack[2];
  assign channel__send_en[2] = demux_bypass_ack__out[2][0];
  assign crossbar__send_bypass_port_ack[2:2] = demux_bypass_ack__out[2][1];
  assign demux_bypass_ack__sel[2] = crossbar__send_bypass_req[2:2];
  assign mux_bypass_valid__in_[2][0] = channel__send_valid[2];
  assign mux_bypass_valid__in_[2][1] = crossbar__send_bypass_data_valid[2:2];
  assign send_data_valid[2] = mux_bypass_valid__out[2];
  assign mux_bypass_valid__sel[2] = crossbar__send_bypass_req[2:2];
  assign mux_bypass_data__in_[2][0] = channel__send_msg[2];
  assign mux_bypass_data__in_[2][1] = crossbar__send_data_bypass[2];
  assign send_data[2] = mux_bypass_data__out[2];
  assign mux_bypass_data__sel[2] = crossbar__send_bypass_req[2:2];
  assign demux_bypass_ack__in_[3] = send_data_ack[3];
  assign channel__send_en[3] = demux_bypass_ack__out[3][0];
  assign crossbar__send_bypass_port_ack[3:3] = demux_bypass_ack__out[3][1];
  assign demux_bypass_ack__sel[3] = crossbar__send_bypass_req[3:3];
  assign mux_bypass_valid__in_[3][0] = channel__send_valid[3];
  assign mux_bypass_valid__in_[3][1] = crossbar__send_bypass_data_valid[3:3];
  assign send_data_valid[3] = mux_bypass_valid__out[3];
  assign mux_bypass_valid__sel[3] = crossbar__send_bypass_req[3:3];
  assign mux_bypass_data__in_[3][0] = channel__send_msg[3];
  assign mux_bypass_data__in_[3][1] = crossbar__send_data_bypass[3];
  assign send_data[3] = mux_bypass_data__out[3];
  assign mux_bypass_data__sel[3] = crossbar__send_bypass_req[3:3];
  assign element__recv_opt_msg_ctrl = tile_ctrl_msg.ctrl;
  assign element__recv_opt_msg_predicate = tile_ctrl_msg.predicate;
  assign element__recv_opt_msg_out_routine = tile_ctrl_msg.out_routine;
  assign element__recv_opt_msg_fu_in[0] = tile_ctrl_msg.fu_in[0];
  assign element__recv_opt_msg_fu_in[1] = tile_ctrl_msg.fu_in[1];
  assign element__recv_opt_msg_fu_in[2] = tile_ctrl_msg.fu_in[2];
  assign element__recv_opt_msg_fu_in[3] = tile_ctrl_msg.fu_in[3];
  assign element__fu_execution_ini = tile_execution_ini_begin;
  assign element__fu_execution_valid = tile_execution_valid;
  assign element__fu_dry_run_begin = tile_dry_run_begin;
  assign element__fu_dry_run_ack = tile_dry_run_ack;
  assign element__fu_opt_enable = tile_opt_enable;
  assign element__fu_propagate_en = tile_propagate_en;
  assign element__recv_port_data[0] = channel__send_msg[4];
  assign element__recv_port_valid[0:0] = channel__send_valid[4];
  assign channel__send_en[4] = element__recv_port_ack[0:0];
  assign element__recv_port_data[1] = channel__send_msg[5];
  assign element__recv_port_valid[1:1] = channel__send_valid[5];
  assign channel__send_en[5] = element__recv_port_ack[1:1];
  assign element__recv_port_data[2] = channel__send_msg[6];
  assign element__recv_port_valid[2:2] = channel__send_valid[6];
  assign channel__send_en[6] = element__recv_port_ack[2:2];
  assign element__recv_port_data[3] = channel__send_msg[7];
  assign element__recv_port_valid[3:3] = channel__send_valid[7];
  assign channel__send_en[7] = element__recv_port_ack[3:3];
  assign element__recv_predicate_data = reg_predicate__send_msg;
  assign element__recv_predicate_valid = reg_predicate__send_valid;
  assign reg_predicate__send_en = element__recv_predicate_ack;
  assign element__recv_const_data = const_queue__send_const_msg;
  assign const_queue__send_const_en = element__recv_const_ack;
  assign crossbar__recv_port_data[4] = element__send_port_data[0];
  assign crossbar__recv_port_valid[4:4] = element__send_port_valid[0:0];
  assign crossbar__recv_port_data[5] = element__send_port_data[1];
  assign crossbar__recv_port_valid[5:5] = element__send_port_valid[1:1];
  assign element__send_port_ack = crossbar__recv_port_fu_out_ack;
  assign element__to_mem_raddr__rdy[0] = 1'd0;
  assign element__from_mem_rdata__en[0] = 1'd0;
  assign element__from_mem_rdata__msg[0] = { 64'd0, 1'd0 };
  assign element__to_mem_waddr__rdy[0] = 1'd0;
  assign element__to_mem_wdata__rdy[0] = 1'd0;
  assign element__to_mem_raddr__rdy[1] = 1'd0;
  assign element__from_mem_rdata__en[1] = 1'd0;
  assign element__from_mem_rdata__msg[1] = { 64'd0, 1'd0 };
  assign element__to_mem_waddr__rdy[1] = 1'd0;
  assign element__to_mem_wdata__rdy[1] = 1'd0;
  assign element__to_mem_raddr__rdy[2] = 1'd0;
  assign element__from_mem_rdata__en[2] = 1'd0;
  assign element__from_mem_rdata__msg[2] = { 64'd0, 1'd0 };
  assign element__to_mem_waddr__rdy[2] = 1'd0;
  assign element__to_mem_wdata__rdy[2] = 1'd0;
  assign element__to_mem_raddr__rdy[3] = 1'd0;
  assign element__from_mem_rdata__en[3] = 1'd0;
  assign element__from_mem_rdata__msg[3] = { 64'd0, 1'd0 };
  assign element__to_mem_waddr__rdy[3] = 1'd0;
  assign element__to_mem_wdata__rdy[3] = 1'd0;
  assign element__to_mem_raddr__rdy[4] = 1'd0;
  assign element__from_mem_rdata__en[4] = 1'd0;
  assign element__from_mem_rdata__msg[4] = { 64'd0, 1'd0 };
  assign element__to_mem_waddr__rdy[4] = 1'd0;
  assign element__to_mem_wdata__rdy[4] = 1'd0;
  assign element__to_mem_raddr__rdy[5] = 1'd0;
  assign element__from_mem_rdata__en[5] = 1'd0;
  assign element__from_mem_rdata__msg[5] = { 64'd0, 1'd0 };
  assign element__to_mem_waddr__rdy[5] = 1'd0;
  assign element__to_mem_wdata__rdy[5] = 1'd0;
  assign tile_xbar_propagate_rdy = crossbar__xbar_propagate_rdy;
  assign tile_fu_propagate_rdy = element__fu_propagate_rdy;

endmodule



module CGRARTL__332d123efc0840be
(
  output logic [31:0] cgra_csr_ro [0:3],
  input  logic [31:0] cgra_csr_rw [0:0],
  output logic [0:0] cgra_csr_rw_ack ,
  input  logic [0:0] cgra_csr_rw_valid ,
  input  logic clk ,
  input  logic [0:0] reset ,
  input logic [0:0] cgra_recv_ni_data__en [0:7] ,
  input logic [63:0] cgra_recv_ni_data__msg [0:7] ,
  output logic [0:0] cgra_recv_ni_data__rdy [0:7] ,
  output logic [0:0] cgra_send_ni_data__en [0:7] ,
  output logic [63:0] cgra_send_ni_data__msg [0:7] ,
  input logic [0:0] cgra_send_ni_data__rdy [0:7] 
);
  localparam logic [0:0] __const__i_at__lambda__s_cgra_recv_ni_data_0__rdy  = 1'd0;
  localparam logic [0:0] __const__i_at__lambda__s_cgra_recv_ni_data_1__rdy  = 1'd1;
  localparam logic [1:0] __const__i_at__lambda__s_cgra_recv_ni_data_2__rdy  = 2'd2;
  localparam logic [1:0] __const__i_at__lambda__s_cgra_recv_ni_data_3__rdy  = 2'd3;
  localparam logic [2:0] __const__i_at__lambda__s_cgra_recv_ni_data_4__rdy  = 3'd4;
  localparam logic [2:0] __const__i_at__lambda__s_cgra_recv_ni_data_5__rdy  = 3'd5;
  localparam logic [2:0] __const__i_at__lambda__s_cgra_recv_ni_data_6__rdy  = 3'd6;
  localparam logic [2:0] __const__i_at__lambda__s_cgra_recv_ni_data_7__rdy  = 3'd7;
  localparam logic [2:0] __const__STAGE_IDLE  = 3'd0;
  localparam logic [2:0] __const__STAGE_CONFIG_CTRLREG  = 3'd1;
  localparam logic [2:0] __const__STAGE_CONFIG_DATA  = 3'd2;
  localparam logic [2:0] __const__STAGE_CONFIG_CMD  = 3'd3;
  localparam logic [2:0] __const__STAGE_CONFIG_DONE  = 3'd4;
  localparam logic [2:0] __const__STAGE_COMP  = 3'd5;
  localparam logic [2:0] __const__STAGE_COMP_HALT  = 3'd6;
  logic [0:0] cgra_cmd_dry_run_begin;
  logic [0:0] cgra_computation_en;
  logic [0:0] cgra_config_cmd_begin;
  logic [5:0] cgra_config_cmd_counter_th;
  logic [0:0] cgra_config_cmd_done;
  logic [0:0] cgra_config_cmd_en;
  logic [0:0] cgra_config_cmd_wopt_done;
  logic [0:0] cgra_config_data_begin;
  logic [5:0] cgra_config_data_counter_th;
  logic [0:0] cgra_config_data_done;
  logic [0:0] cgra_config_data_en;
  logic [0:0] cgra_config_ini_begin;
  logic [0:0] cgra_config_ini_en;
  logic [31:0] cgra_cur_stage_info;
  logic [15:0] cgra_cycle_counter;
  logic [15:0] cgra_cycle_counter_th;
  logic [0:0] cgra_cycle_th_hit;
  logic [1:0] cgra_dmem_io_mode;
  logic [0:0] cgra_execution_begin;
  logic [0:0] cgra_execution_ini_begin;
  logic [0:0] cgra_execution_valid;
  logic [31:0] cgra_nxt_stage_info;
  logic [31:0] cgra_propagate_rdy_info;
  logic [511:0] cgra_recv_wi_data;
  logic [0:0] cgra_recv_wi_data_ack;
  logic [0:0] cgra_recv_wi_data_rdy;
  logic [0:0] cgra_recv_wi_data_valid;
  logic [0:0] cgra_restart_comp_en;
  logic [4:0] counter_config_cmd_addr;
  logic [0:0] counter_config_cmd_slice;
  logic [4:0] counter_config_data_addr;
  logic [2:0] cur_stage;
  logic [2:0] nxt_stage;
  logic [511:0] recv_wconst_flattened;
  logic [0:0] recv_wconst_flattened_en;
  logic [0:0] recv_wconst_flattened_rdy;
  logic [511:0] recv_wopt_sliced_flattened;
  logic [0:0] recv_wopt_sliced_flattened_en;
  logic [0:0] recv_wopt_sliced_flattened_rdy;
  logic [0:0] tile_dry_run_ack;
  logic [0:0] tile_dry_run_fin;
  logic [15:0] tile_fu_propagate_rdy_vector;
  logic [7:0] tile_recv_ni_data_ack;
  logic [7:0] tile_recv_ni_data_valid;
  logic [0:0] tile_recv_opt_waddr_en;
  logic [15:0] tile_xbar_propagate_rdy_vector;

  logic [0:0] tile__clk [0:15];
  logic [5:0] tile__config_cmd_counter_th [0:15];
  logic [5:0] tile__config_data_counter_th [0:15];
  logic [0:0] tile__ctrl_slice_idx [0:15];
  logic [31:0] tile__recv_const [0:15];
  logic [0:0] tile__recv_const_en [0:15];
  logic [4:0] tile__recv_const_waddr [0:15];
  CGRAData_64_1__payload_64__predicate_1 tile__recv_data [0:15][0:3];
  logic [0:0] tile__recv_data_ack [0:15][0:3];
  logic [0:0] tile__recv_data_valid [0:15][0:3];
  logic [4:0] tile__recv_opt_waddr [0:15];
  logic [0:0] tile__recv_opt_waddr_en [0:15];
  logic [31:0] tile__recv_wopt [0:15];
  logic [0:0] tile__recv_wopt_en [0:15];
  logic [0:0] tile__reset [0:15];
  CGRAData_64_1__payload_64__predicate_1 tile__send_data [0:15][0:3];
  logic [0:0] tile__send_data_ack [0:15][0:3];
  logic [0:0] tile__send_data_valid [0:15][0:3];
  logic [0:0] tile__tile_config_ini_begin [0:15];
  logic [0:0] tile__tile_dry_run_ack [0:15];
  logic [0:0] tile__tile_dry_run_done [0:15];
  logic [0:0] tile__tile_execution_begin [0:15];
  logic [0:0] tile__tile_execution_ini_begin [0:15];
  logic [0:0] tile__tile_execution_valid [0:15];
  logic [0:0] tile__tile_fu_propagate_rdy [0:15];
  logic [0:0] tile__tile_xbar_propagate_rdy [0:15];
  logic [0:0] tile__from_mem_rdata__en [0:15];
  CGRAData_64_1__payload_64__predicate_1 tile__from_mem_rdata__msg [0:15];
  logic [0:0] tile__from_mem_rdata__rdy [0:15];
  logic [0:0] tile__to_mem_raddr__en [0:15];
  logic [6:0] tile__to_mem_raddr__msg [0:15];
  logic [0:0] tile__to_mem_raddr__rdy [0:15];
  logic [0:0] tile__to_mem_waddr__en [0:15];
  logic [6:0] tile__to_mem_waddr__msg [0:15];
  logic [0:0] tile__to_mem_waddr__rdy [0:15];
  logic [0:0] tile__to_mem_wdata__en [0:15];
  CGRAData_64_1__payload_64__predicate_1 tile__to_mem_wdata__msg [0:15];
  logic [0:0] tile__to_mem_wdata__rdy [0:15];

  TileRTL__4db54fb92d7fbf49 tile__0
  (
    .clk( tile__clk[0] ),
    .config_cmd_counter_th( tile__config_cmd_counter_th[0] ),
    .config_data_counter_th( tile__config_data_counter_th[0] ),
    .ctrl_slice_idx( tile__ctrl_slice_idx[0] ),
    .recv_const( tile__recv_const[0] ),
    .recv_const_en( tile__recv_const_en[0] ),
    .recv_const_waddr( tile__recv_const_waddr[0] ),
    .recv_data( tile__recv_data[0] ),
    .recv_data_ack( tile__recv_data_ack[0] ),
    .recv_data_valid( tile__recv_data_valid[0] ),
    .recv_opt_waddr( tile__recv_opt_waddr[0] ),
    .recv_opt_waddr_en( tile__recv_opt_waddr_en[0] ),
    .recv_wopt( tile__recv_wopt[0] ),
    .recv_wopt_en( tile__recv_wopt_en[0] ),
    .reset( tile__reset[0] ),
    .send_data( tile__send_data[0] ),
    .send_data_ack( tile__send_data_ack[0] ),
    .send_data_valid( tile__send_data_valid[0] ),
    .tile_config_ini_begin( tile__tile_config_ini_begin[0] ),
    .tile_dry_run_ack( tile__tile_dry_run_ack[0] ),
    .tile_dry_run_done( tile__tile_dry_run_done[0] ),
    .tile_execution_begin( tile__tile_execution_begin[0] ),
    .tile_execution_ini_begin( tile__tile_execution_ini_begin[0] ),
    .tile_execution_valid( tile__tile_execution_valid[0] ),
    .tile_fu_propagate_rdy( tile__tile_fu_propagate_rdy[0] ),
    .tile_xbar_propagate_rdy( tile__tile_xbar_propagate_rdy[0] ),
    .from_mem_rdata__en( tile__from_mem_rdata__en[0] ),
    .from_mem_rdata__msg( tile__from_mem_rdata__msg[0] ),
    .from_mem_rdata__rdy( tile__from_mem_rdata__rdy[0] ),
    .to_mem_raddr__en( tile__to_mem_raddr__en[0] ),
    .to_mem_raddr__msg( tile__to_mem_raddr__msg[0] ),
    .to_mem_raddr__rdy( tile__to_mem_raddr__rdy[0] ),
    .to_mem_waddr__en( tile__to_mem_waddr__en[0] ),
    .to_mem_waddr__msg( tile__to_mem_waddr__msg[0] ),
    .to_mem_waddr__rdy( tile__to_mem_waddr__rdy[0] ),
    .to_mem_wdata__en( tile__to_mem_wdata__en[0] ),
    .to_mem_wdata__msg( tile__to_mem_wdata__msg[0] ),
    .to_mem_wdata__rdy( tile__to_mem_wdata__rdy[0] )
  );

  TileRTL__4db54fb92d7fbf49 tile__1
  (
    .clk( tile__clk[1] ),
    .config_cmd_counter_th( tile__config_cmd_counter_th[1] ),
    .config_data_counter_th( tile__config_data_counter_th[1] ),
    .ctrl_slice_idx( tile__ctrl_slice_idx[1] ),
    .recv_const( tile__recv_const[1] ),
    .recv_const_en( tile__recv_const_en[1] ),
    .recv_const_waddr( tile__recv_const_waddr[1] ),
    .recv_data( tile__recv_data[1] ),
    .recv_data_ack( tile__recv_data_ack[1] ),
    .recv_data_valid( tile__recv_data_valid[1] ),
    .recv_opt_waddr( tile__recv_opt_waddr[1] ),
    .recv_opt_waddr_en( tile__recv_opt_waddr_en[1] ),
    .recv_wopt( tile__recv_wopt[1] ),
    .recv_wopt_en( tile__recv_wopt_en[1] ),
    .reset( tile__reset[1] ),
    .send_data( tile__send_data[1] ),
    .send_data_ack( tile__send_data_ack[1] ),
    .send_data_valid( tile__send_data_valid[1] ),
    .tile_config_ini_begin( tile__tile_config_ini_begin[1] ),
    .tile_dry_run_ack( tile__tile_dry_run_ack[1] ),
    .tile_dry_run_done( tile__tile_dry_run_done[1] ),
    .tile_execution_begin( tile__tile_execution_begin[1] ),
    .tile_execution_ini_begin( tile__tile_execution_ini_begin[1] ),
    .tile_execution_valid( tile__tile_execution_valid[1] ),
    .tile_fu_propagate_rdy( tile__tile_fu_propagate_rdy[1] ),
    .tile_xbar_propagate_rdy( tile__tile_xbar_propagate_rdy[1] ),
    .from_mem_rdata__en( tile__from_mem_rdata__en[1] ),
    .from_mem_rdata__msg( tile__from_mem_rdata__msg[1] ),
    .from_mem_rdata__rdy( tile__from_mem_rdata__rdy[1] ),
    .to_mem_raddr__en( tile__to_mem_raddr__en[1] ),
    .to_mem_raddr__msg( tile__to_mem_raddr__msg[1] ),
    .to_mem_raddr__rdy( tile__to_mem_raddr__rdy[1] ),
    .to_mem_waddr__en( tile__to_mem_waddr__en[1] ),
    .to_mem_waddr__msg( tile__to_mem_waddr__msg[1] ),
    .to_mem_waddr__rdy( tile__to_mem_waddr__rdy[1] ),
    .to_mem_wdata__en( tile__to_mem_wdata__en[1] ),
    .to_mem_wdata__msg( tile__to_mem_wdata__msg[1] ),
    .to_mem_wdata__rdy( tile__to_mem_wdata__rdy[1] )
  );

  TileRTL__4db54fb92d7fbf49 tile__2
  (
    .clk( tile__clk[2] ),
    .config_cmd_counter_th( tile__config_cmd_counter_th[2] ),
    .config_data_counter_th( tile__config_data_counter_th[2] ),
    .ctrl_slice_idx( tile__ctrl_slice_idx[2] ),
    .recv_const( tile__recv_const[2] ),
    .recv_const_en( tile__recv_const_en[2] ),
    .recv_const_waddr( tile__recv_const_waddr[2] ),
    .recv_data( tile__recv_data[2] ),
    .recv_data_ack( tile__recv_data_ack[2] ),
    .recv_data_valid( tile__recv_data_valid[2] ),
    .recv_opt_waddr( tile__recv_opt_waddr[2] ),
    .recv_opt_waddr_en( tile__recv_opt_waddr_en[2] ),
    .recv_wopt( tile__recv_wopt[2] ),
    .recv_wopt_en( tile__recv_wopt_en[2] ),
    .reset( tile__reset[2] ),
    .send_data( tile__send_data[2] ),
    .send_data_ack( tile__send_data_ack[2] ),
    .send_data_valid( tile__send_data_valid[2] ),
    .tile_config_ini_begin( tile__tile_config_ini_begin[2] ),
    .tile_dry_run_ack( tile__tile_dry_run_ack[2] ),
    .tile_dry_run_done( tile__tile_dry_run_done[2] ),
    .tile_execution_begin( tile__tile_execution_begin[2] ),
    .tile_execution_ini_begin( tile__tile_execution_ini_begin[2] ),
    .tile_execution_valid( tile__tile_execution_valid[2] ),
    .tile_fu_propagate_rdy( tile__tile_fu_propagate_rdy[2] ),
    .tile_xbar_propagate_rdy( tile__tile_xbar_propagate_rdy[2] ),
    .from_mem_rdata__en( tile__from_mem_rdata__en[2] ),
    .from_mem_rdata__msg( tile__from_mem_rdata__msg[2] ),
    .from_mem_rdata__rdy( tile__from_mem_rdata__rdy[2] ),
    .to_mem_raddr__en( tile__to_mem_raddr__en[2] ),
    .to_mem_raddr__msg( tile__to_mem_raddr__msg[2] ),
    .to_mem_raddr__rdy( tile__to_mem_raddr__rdy[2] ),
    .to_mem_waddr__en( tile__to_mem_waddr__en[2] ),
    .to_mem_waddr__msg( tile__to_mem_waddr__msg[2] ),
    .to_mem_waddr__rdy( tile__to_mem_waddr__rdy[2] ),
    .to_mem_wdata__en( tile__to_mem_wdata__en[2] ),
    .to_mem_wdata__msg( tile__to_mem_wdata__msg[2] ),
    .to_mem_wdata__rdy( tile__to_mem_wdata__rdy[2] )
  );

  TileRTL__4db54fb92d7fbf49 tile__3
  (
    .clk( tile__clk[3] ),
    .config_cmd_counter_th( tile__config_cmd_counter_th[3] ),
    .config_data_counter_th( tile__config_data_counter_th[3] ),
    .ctrl_slice_idx( tile__ctrl_slice_idx[3] ),
    .recv_const( tile__recv_const[3] ),
    .recv_const_en( tile__recv_const_en[3] ),
    .recv_const_waddr( tile__recv_const_waddr[3] ),
    .recv_data( tile__recv_data[3] ),
    .recv_data_ack( tile__recv_data_ack[3] ),
    .recv_data_valid( tile__recv_data_valid[3] ),
    .recv_opt_waddr( tile__recv_opt_waddr[3] ),
    .recv_opt_waddr_en( tile__recv_opt_waddr_en[3] ),
    .recv_wopt( tile__recv_wopt[3] ),
    .recv_wopt_en( tile__recv_wopt_en[3] ),
    .reset( tile__reset[3] ),
    .send_data( tile__send_data[3] ),
    .send_data_ack( tile__send_data_ack[3] ),
    .send_data_valid( tile__send_data_valid[3] ),
    .tile_config_ini_begin( tile__tile_config_ini_begin[3] ),
    .tile_dry_run_ack( tile__tile_dry_run_ack[3] ),
    .tile_dry_run_done( tile__tile_dry_run_done[3] ),
    .tile_execution_begin( tile__tile_execution_begin[3] ),
    .tile_execution_ini_begin( tile__tile_execution_ini_begin[3] ),
    .tile_execution_valid( tile__tile_execution_valid[3] ),
    .tile_fu_propagate_rdy( tile__tile_fu_propagate_rdy[3] ),
    .tile_xbar_propagate_rdy( tile__tile_xbar_propagate_rdy[3] ),
    .from_mem_rdata__en( tile__from_mem_rdata__en[3] ),
    .from_mem_rdata__msg( tile__from_mem_rdata__msg[3] ),
    .from_mem_rdata__rdy( tile__from_mem_rdata__rdy[3] ),
    .to_mem_raddr__en( tile__to_mem_raddr__en[3] ),
    .to_mem_raddr__msg( tile__to_mem_raddr__msg[3] ),
    .to_mem_raddr__rdy( tile__to_mem_raddr__rdy[3] ),
    .to_mem_waddr__en( tile__to_mem_waddr__en[3] ),
    .to_mem_waddr__msg( tile__to_mem_waddr__msg[3] ),
    .to_mem_waddr__rdy( tile__to_mem_waddr__rdy[3] ),
    .to_mem_wdata__en( tile__to_mem_wdata__en[3] ),
    .to_mem_wdata__msg( tile__to_mem_wdata__msg[3] ),
    .to_mem_wdata__rdy( tile__to_mem_wdata__rdy[3] )
  );

  TileRTL__4db54fb92d7fbf49 tile__4
  (
    .clk( tile__clk[4] ),
    .config_cmd_counter_th( tile__config_cmd_counter_th[4] ),
    .config_data_counter_th( tile__config_data_counter_th[4] ),
    .ctrl_slice_idx( tile__ctrl_slice_idx[4] ),
    .recv_const( tile__recv_const[4] ),
    .recv_const_en( tile__recv_const_en[4] ),
    .recv_const_waddr( tile__recv_const_waddr[4] ),
    .recv_data( tile__recv_data[4] ),
    .recv_data_ack( tile__recv_data_ack[4] ),
    .recv_data_valid( tile__recv_data_valid[4] ),
    .recv_opt_waddr( tile__recv_opt_waddr[4] ),
    .recv_opt_waddr_en( tile__recv_opt_waddr_en[4] ),
    .recv_wopt( tile__recv_wopt[4] ),
    .recv_wopt_en( tile__recv_wopt_en[4] ),
    .reset( tile__reset[4] ),
    .send_data( tile__send_data[4] ),
    .send_data_ack( tile__send_data_ack[4] ),
    .send_data_valid( tile__send_data_valid[4] ),
    .tile_config_ini_begin( tile__tile_config_ini_begin[4] ),
    .tile_dry_run_ack( tile__tile_dry_run_ack[4] ),
    .tile_dry_run_done( tile__tile_dry_run_done[4] ),
    .tile_execution_begin( tile__tile_execution_begin[4] ),
    .tile_execution_ini_begin( tile__tile_execution_ini_begin[4] ),
    .tile_execution_valid( tile__tile_execution_valid[4] ),
    .tile_fu_propagate_rdy( tile__tile_fu_propagate_rdy[4] ),
    .tile_xbar_propagate_rdy( tile__tile_xbar_propagate_rdy[4] ),
    .from_mem_rdata__en( tile__from_mem_rdata__en[4] ),
    .from_mem_rdata__msg( tile__from_mem_rdata__msg[4] ),
    .from_mem_rdata__rdy( tile__from_mem_rdata__rdy[4] ),
    .to_mem_raddr__en( tile__to_mem_raddr__en[4] ),
    .to_mem_raddr__msg( tile__to_mem_raddr__msg[4] ),
    .to_mem_raddr__rdy( tile__to_mem_raddr__rdy[4] ),
    .to_mem_waddr__en( tile__to_mem_waddr__en[4] ),
    .to_mem_waddr__msg( tile__to_mem_waddr__msg[4] ),
    .to_mem_waddr__rdy( tile__to_mem_waddr__rdy[4] ),
    .to_mem_wdata__en( tile__to_mem_wdata__en[4] ),
    .to_mem_wdata__msg( tile__to_mem_wdata__msg[4] ),
    .to_mem_wdata__rdy( tile__to_mem_wdata__rdy[4] )
  );

  TileRTL__4db54fb92d7fbf49 tile__5
  (
    .clk( tile__clk[5] ),
    .config_cmd_counter_th( tile__config_cmd_counter_th[5] ),
    .config_data_counter_th( tile__config_data_counter_th[5] ),
    .ctrl_slice_idx( tile__ctrl_slice_idx[5] ),
    .recv_const( tile__recv_const[5] ),
    .recv_const_en( tile__recv_const_en[5] ),
    .recv_const_waddr( tile__recv_const_waddr[5] ),
    .recv_data( tile__recv_data[5] ),
    .recv_data_ack( tile__recv_data_ack[5] ),
    .recv_data_valid( tile__recv_data_valid[5] ),
    .recv_opt_waddr( tile__recv_opt_waddr[5] ),
    .recv_opt_waddr_en( tile__recv_opt_waddr_en[5] ),
    .recv_wopt( tile__recv_wopt[5] ),
    .recv_wopt_en( tile__recv_wopt_en[5] ),
    .reset( tile__reset[5] ),
    .send_data( tile__send_data[5] ),
    .send_data_ack( tile__send_data_ack[5] ),
    .send_data_valid( tile__send_data_valid[5] ),
    .tile_config_ini_begin( tile__tile_config_ini_begin[5] ),
    .tile_dry_run_ack( tile__tile_dry_run_ack[5] ),
    .tile_dry_run_done( tile__tile_dry_run_done[5] ),
    .tile_execution_begin( tile__tile_execution_begin[5] ),
    .tile_execution_ini_begin( tile__tile_execution_ini_begin[5] ),
    .tile_execution_valid( tile__tile_execution_valid[5] ),
    .tile_fu_propagate_rdy( tile__tile_fu_propagate_rdy[5] ),
    .tile_xbar_propagate_rdy( tile__tile_xbar_propagate_rdy[5] ),
    .from_mem_rdata__en( tile__from_mem_rdata__en[5] ),
    .from_mem_rdata__msg( tile__from_mem_rdata__msg[5] ),
    .from_mem_rdata__rdy( tile__from_mem_rdata__rdy[5] ),
    .to_mem_raddr__en( tile__to_mem_raddr__en[5] ),
    .to_mem_raddr__msg( tile__to_mem_raddr__msg[5] ),
    .to_mem_raddr__rdy( tile__to_mem_raddr__rdy[5] ),
    .to_mem_waddr__en( tile__to_mem_waddr__en[5] ),
    .to_mem_waddr__msg( tile__to_mem_waddr__msg[5] ),
    .to_mem_waddr__rdy( tile__to_mem_waddr__rdy[5] ),
    .to_mem_wdata__en( tile__to_mem_wdata__en[5] ),
    .to_mem_wdata__msg( tile__to_mem_wdata__msg[5] ),
    .to_mem_wdata__rdy( tile__to_mem_wdata__rdy[5] )
  );

  TileRTL__4db54fb92d7fbf49 tile__6
  (
    .clk( tile__clk[6] ),
    .config_cmd_counter_th( tile__config_cmd_counter_th[6] ),
    .config_data_counter_th( tile__config_data_counter_th[6] ),
    .ctrl_slice_idx( tile__ctrl_slice_idx[6] ),
    .recv_const( tile__recv_const[6] ),
    .recv_const_en( tile__recv_const_en[6] ),
    .recv_const_waddr( tile__recv_const_waddr[6] ),
    .recv_data( tile__recv_data[6] ),
    .recv_data_ack( tile__recv_data_ack[6] ),
    .recv_data_valid( tile__recv_data_valid[6] ),
    .recv_opt_waddr( tile__recv_opt_waddr[6] ),
    .recv_opt_waddr_en( tile__recv_opt_waddr_en[6] ),
    .recv_wopt( tile__recv_wopt[6] ),
    .recv_wopt_en( tile__recv_wopt_en[6] ),
    .reset( tile__reset[6] ),
    .send_data( tile__send_data[6] ),
    .send_data_ack( tile__send_data_ack[6] ),
    .send_data_valid( tile__send_data_valid[6] ),
    .tile_config_ini_begin( tile__tile_config_ini_begin[6] ),
    .tile_dry_run_ack( tile__tile_dry_run_ack[6] ),
    .tile_dry_run_done( tile__tile_dry_run_done[6] ),
    .tile_execution_begin( tile__tile_execution_begin[6] ),
    .tile_execution_ini_begin( tile__tile_execution_ini_begin[6] ),
    .tile_execution_valid( tile__tile_execution_valid[6] ),
    .tile_fu_propagate_rdy( tile__tile_fu_propagate_rdy[6] ),
    .tile_xbar_propagate_rdy( tile__tile_xbar_propagate_rdy[6] ),
    .from_mem_rdata__en( tile__from_mem_rdata__en[6] ),
    .from_mem_rdata__msg( tile__from_mem_rdata__msg[6] ),
    .from_mem_rdata__rdy( tile__from_mem_rdata__rdy[6] ),
    .to_mem_raddr__en( tile__to_mem_raddr__en[6] ),
    .to_mem_raddr__msg( tile__to_mem_raddr__msg[6] ),
    .to_mem_raddr__rdy( tile__to_mem_raddr__rdy[6] ),
    .to_mem_waddr__en( tile__to_mem_waddr__en[6] ),
    .to_mem_waddr__msg( tile__to_mem_waddr__msg[6] ),
    .to_mem_waddr__rdy( tile__to_mem_waddr__rdy[6] ),
    .to_mem_wdata__en( tile__to_mem_wdata__en[6] ),
    .to_mem_wdata__msg( tile__to_mem_wdata__msg[6] ),
    .to_mem_wdata__rdy( tile__to_mem_wdata__rdy[6] )
  );

  TileRTL__4db54fb92d7fbf49 tile__7
  (
    .clk( tile__clk[7] ),
    .config_cmd_counter_th( tile__config_cmd_counter_th[7] ),
    .config_data_counter_th( tile__config_data_counter_th[7] ),
    .ctrl_slice_idx( tile__ctrl_slice_idx[7] ),
    .recv_const( tile__recv_const[7] ),
    .recv_const_en( tile__recv_const_en[7] ),
    .recv_const_waddr( tile__recv_const_waddr[7] ),
    .recv_data( tile__recv_data[7] ),
    .recv_data_ack( tile__recv_data_ack[7] ),
    .recv_data_valid( tile__recv_data_valid[7] ),
    .recv_opt_waddr( tile__recv_opt_waddr[7] ),
    .recv_opt_waddr_en( tile__recv_opt_waddr_en[7] ),
    .recv_wopt( tile__recv_wopt[7] ),
    .recv_wopt_en( tile__recv_wopt_en[7] ),
    .reset( tile__reset[7] ),
    .send_data( tile__send_data[7] ),
    .send_data_ack( tile__send_data_ack[7] ),
    .send_data_valid( tile__send_data_valid[7] ),
    .tile_config_ini_begin( tile__tile_config_ini_begin[7] ),
    .tile_dry_run_ack( tile__tile_dry_run_ack[7] ),
    .tile_dry_run_done( tile__tile_dry_run_done[7] ),
    .tile_execution_begin( tile__tile_execution_begin[7] ),
    .tile_execution_ini_begin( tile__tile_execution_ini_begin[7] ),
    .tile_execution_valid( tile__tile_execution_valid[7] ),
    .tile_fu_propagate_rdy( tile__tile_fu_propagate_rdy[7] ),
    .tile_xbar_propagate_rdy( tile__tile_xbar_propagate_rdy[7] ),
    .from_mem_rdata__en( tile__from_mem_rdata__en[7] ),
    .from_mem_rdata__msg( tile__from_mem_rdata__msg[7] ),
    .from_mem_rdata__rdy( tile__from_mem_rdata__rdy[7] ),
    .to_mem_raddr__en( tile__to_mem_raddr__en[7] ),
    .to_mem_raddr__msg( tile__to_mem_raddr__msg[7] ),
    .to_mem_raddr__rdy( tile__to_mem_raddr__rdy[7] ),
    .to_mem_waddr__en( tile__to_mem_waddr__en[7] ),
    .to_mem_waddr__msg( tile__to_mem_waddr__msg[7] ),
    .to_mem_waddr__rdy( tile__to_mem_waddr__rdy[7] ),
    .to_mem_wdata__en( tile__to_mem_wdata__en[7] ),
    .to_mem_wdata__msg( tile__to_mem_wdata__msg[7] ),
    .to_mem_wdata__rdy( tile__to_mem_wdata__rdy[7] )
  );

  TileRTL__4db54fb92d7fbf49 tile__8
  (
    .clk( tile__clk[8] ),
    .config_cmd_counter_th( tile__config_cmd_counter_th[8] ),
    .config_data_counter_th( tile__config_data_counter_th[8] ),
    .ctrl_slice_idx( tile__ctrl_slice_idx[8] ),
    .recv_const( tile__recv_const[8] ),
    .recv_const_en( tile__recv_const_en[8] ),
    .recv_const_waddr( tile__recv_const_waddr[8] ),
    .recv_data( tile__recv_data[8] ),
    .recv_data_ack( tile__recv_data_ack[8] ),
    .recv_data_valid( tile__recv_data_valid[8] ),
    .recv_opt_waddr( tile__recv_opt_waddr[8] ),
    .recv_opt_waddr_en( tile__recv_opt_waddr_en[8] ),
    .recv_wopt( tile__recv_wopt[8] ),
    .recv_wopt_en( tile__recv_wopt_en[8] ),
    .reset( tile__reset[8] ),
    .send_data( tile__send_data[8] ),
    .send_data_ack( tile__send_data_ack[8] ),
    .send_data_valid( tile__send_data_valid[8] ),
    .tile_config_ini_begin( tile__tile_config_ini_begin[8] ),
    .tile_dry_run_ack( tile__tile_dry_run_ack[8] ),
    .tile_dry_run_done( tile__tile_dry_run_done[8] ),
    .tile_execution_begin( tile__tile_execution_begin[8] ),
    .tile_execution_ini_begin( tile__tile_execution_ini_begin[8] ),
    .tile_execution_valid( tile__tile_execution_valid[8] ),
    .tile_fu_propagate_rdy( tile__tile_fu_propagate_rdy[8] ),
    .tile_xbar_propagate_rdy( tile__tile_xbar_propagate_rdy[8] ),
    .from_mem_rdata__en( tile__from_mem_rdata__en[8] ),
    .from_mem_rdata__msg( tile__from_mem_rdata__msg[8] ),
    .from_mem_rdata__rdy( tile__from_mem_rdata__rdy[8] ),
    .to_mem_raddr__en( tile__to_mem_raddr__en[8] ),
    .to_mem_raddr__msg( tile__to_mem_raddr__msg[8] ),
    .to_mem_raddr__rdy( tile__to_mem_raddr__rdy[8] ),
    .to_mem_waddr__en( tile__to_mem_waddr__en[8] ),
    .to_mem_waddr__msg( tile__to_mem_waddr__msg[8] ),
    .to_mem_waddr__rdy( tile__to_mem_waddr__rdy[8] ),
    .to_mem_wdata__en( tile__to_mem_wdata__en[8] ),
    .to_mem_wdata__msg( tile__to_mem_wdata__msg[8] ),
    .to_mem_wdata__rdy( tile__to_mem_wdata__rdy[8] )
  );

  TileRTL__4db54fb92d7fbf49 tile__9
  (
    .clk( tile__clk[9] ),
    .config_cmd_counter_th( tile__config_cmd_counter_th[9] ),
    .config_data_counter_th( tile__config_data_counter_th[9] ),
    .ctrl_slice_idx( tile__ctrl_slice_idx[9] ),
    .recv_const( tile__recv_const[9] ),
    .recv_const_en( tile__recv_const_en[9] ),
    .recv_const_waddr( tile__recv_const_waddr[9] ),
    .recv_data( tile__recv_data[9] ),
    .recv_data_ack( tile__recv_data_ack[9] ),
    .recv_data_valid( tile__recv_data_valid[9] ),
    .recv_opt_waddr( tile__recv_opt_waddr[9] ),
    .recv_opt_waddr_en( tile__recv_opt_waddr_en[9] ),
    .recv_wopt( tile__recv_wopt[9] ),
    .recv_wopt_en( tile__recv_wopt_en[9] ),
    .reset( tile__reset[9] ),
    .send_data( tile__send_data[9] ),
    .send_data_ack( tile__send_data_ack[9] ),
    .send_data_valid( tile__send_data_valid[9] ),
    .tile_config_ini_begin( tile__tile_config_ini_begin[9] ),
    .tile_dry_run_ack( tile__tile_dry_run_ack[9] ),
    .tile_dry_run_done( tile__tile_dry_run_done[9] ),
    .tile_execution_begin( tile__tile_execution_begin[9] ),
    .tile_execution_ini_begin( tile__tile_execution_ini_begin[9] ),
    .tile_execution_valid( tile__tile_execution_valid[9] ),
    .tile_fu_propagate_rdy( tile__tile_fu_propagate_rdy[9] ),
    .tile_xbar_propagate_rdy( tile__tile_xbar_propagate_rdy[9] ),
    .from_mem_rdata__en( tile__from_mem_rdata__en[9] ),
    .from_mem_rdata__msg( tile__from_mem_rdata__msg[9] ),
    .from_mem_rdata__rdy( tile__from_mem_rdata__rdy[9] ),
    .to_mem_raddr__en( tile__to_mem_raddr__en[9] ),
    .to_mem_raddr__msg( tile__to_mem_raddr__msg[9] ),
    .to_mem_raddr__rdy( tile__to_mem_raddr__rdy[9] ),
    .to_mem_waddr__en( tile__to_mem_waddr__en[9] ),
    .to_mem_waddr__msg( tile__to_mem_waddr__msg[9] ),
    .to_mem_waddr__rdy( tile__to_mem_waddr__rdy[9] ),
    .to_mem_wdata__en( tile__to_mem_wdata__en[9] ),
    .to_mem_wdata__msg( tile__to_mem_wdata__msg[9] ),
    .to_mem_wdata__rdy( tile__to_mem_wdata__rdy[9] )
  );

  TileRTL__4db54fb92d7fbf49 tile__10
  (
    .clk( tile__clk[10] ),
    .config_cmd_counter_th( tile__config_cmd_counter_th[10] ),
    .config_data_counter_th( tile__config_data_counter_th[10] ),
    .ctrl_slice_idx( tile__ctrl_slice_idx[10] ),
    .recv_const( tile__recv_const[10] ),
    .recv_const_en( tile__recv_const_en[10] ),
    .recv_const_waddr( tile__recv_const_waddr[10] ),
    .recv_data( tile__recv_data[10] ),
    .recv_data_ack( tile__recv_data_ack[10] ),
    .recv_data_valid( tile__recv_data_valid[10] ),
    .recv_opt_waddr( tile__recv_opt_waddr[10] ),
    .recv_opt_waddr_en( tile__recv_opt_waddr_en[10] ),
    .recv_wopt( tile__recv_wopt[10] ),
    .recv_wopt_en( tile__recv_wopt_en[10] ),
    .reset( tile__reset[10] ),
    .send_data( tile__send_data[10] ),
    .send_data_ack( tile__send_data_ack[10] ),
    .send_data_valid( tile__send_data_valid[10] ),
    .tile_config_ini_begin( tile__tile_config_ini_begin[10] ),
    .tile_dry_run_ack( tile__tile_dry_run_ack[10] ),
    .tile_dry_run_done( tile__tile_dry_run_done[10] ),
    .tile_execution_begin( tile__tile_execution_begin[10] ),
    .tile_execution_ini_begin( tile__tile_execution_ini_begin[10] ),
    .tile_execution_valid( tile__tile_execution_valid[10] ),
    .tile_fu_propagate_rdy( tile__tile_fu_propagate_rdy[10] ),
    .tile_xbar_propagate_rdy( tile__tile_xbar_propagate_rdy[10] ),
    .from_mem_rdata__en( tile__from_mem_rdata__en[10] ),
    .from_mem_rdata__msg( tile__from_mem_rdata__msg[10] ),
    .from_mem_rdata__rdy( tile__from_mem_rdata__rdy[10] ),
    .to_mem_raddr__en( tile__to_mem_raddr__en[10] ),
    .to_mem_raddr__msg( tile__to_mem_raddr__msg[10] ),
    .to_mem_raddr__rdy( tile__to_mem_raddr__rdy[10] ),
    .to_mem_waddr__en( tile__to_mem_waddr__en[10] ),
    .to_mem_waddr__msg( tile__to_mem_waddr__msg[10] ),
    .to_mem_waddr__rdy( tile__to_mem_waddr__rdy[10] ),
    .to_mem_wdata__en( tile__to_mem_wdata__en[10] ),
    .to_mem_wdata__msg( tile__to_mem_wdata__msg[10] ),
    .to_mem_wdata__rdy( tile__to_mem_wdata__rdy[10] )
  );

  TileRTL__4db54fb92d7fbf49 tile__11
  (
    .clk( tile__clk[11] ),
    .config_cmd_counter_th( tile__config_cmd_counter_th[11] ),
    .config_data_counter_th( tile__config_data_counter_th[11] ),
    .ctrl_slice_idx( tile__ctrl_slice_idx[11] ),
    .recv_const( tile__recv_const[11] ),
    .recv_const_en( tile__recv_const_en[11] ),
    .recv_const_waddr( tile__recv_const_waddr[11] ),
    .recv_data( tile__recv_data[11] ),
    .recv_data_ack( tile__recv_data_ack[11] ),
    .recv_data_valid( tile__recv_data_valid[11] ),
    .recv_opt_waddr( tile__recv_opt_waddr[11] ),
    .recv_opt_waddr_en( tile__recv_opt_waddr_en[11] ),
    .recv_wopt( tile__recv_wopt[11] ),
    .recv_wopt_en( tile__recv_wopt_en[11] ),
    .reset( tile__reset[11] ),
    .send_data( tile__send_data[11] ),
    .send_data_ack( tile__send_data_ack[11] ),
    .send_data_valid( tile__send_data_valid[11] ),
    .tile_config_ini_begin( tile__tile_config_ini_begin[11] ),
    .tile_dry_run_ack( tile__tile_dry_run_ack[11] ),
    .tile_dry_run_done( tile__tile_dry_run_done[11] ),
    .tile_execution_begin( tile__tile_execution_begin[11] ),
    .tile_execution_ini_begin( tile__tile_execution_ini_begin[11] ),
    .tile_execution_valid( tile__tile_execution_valid[11] ),
    .tile_fu_propagate_rdy( tile__tile_fu_propagate_rdy[11] ),
    .tile_xbar_propagate_rdy( tile__tile_xbar_propagate_rdy[11] ),
    .from_mem_rdata__en( tile__from_mem_rdata__en[11] ),
    .from_mem_rdata__msg( tile__from_mem_rdata__msg[11] ),
    .from_mem_rdata__rdy( tile__from_mem_rdata__rdy[11] ),
    .to_mem_raddr__en( tile__to_mem_raddr__en[11] ),
    .to_mem_raddr__msg( tile__to_mem_raddr__msg[11] ),
    .to_mem_raddr__rdy( tile__to_mem_raddr__rdy[11] ),
    .to_mem_waddr__en( tile__to_mem_waddr__en[11] ),
    .to_mem_waddr__msg( tile__to_mem_waddr__msg[11] ),
    .to_mem_waddr__rdy( tile__to_mem_waddr__rdy[11] ),
    .to_mem_wdata__en( tile__to_mem_wdata__en[11] ),
    .to_mem_wdata__msg( tile__to_mem_wdata__msg[11] ),
    .to_mem_wdata__rdy( tile__to_mem_wdata__rdy[11] )
  );

  TileRTL__4db54fb92d7fbf49 tile__12
  (
    .clk( tile__clk[12] ),
    .config_cmd_counter_th( tile__config_cmd_counter_th[12] ),
    .config_data_counter_th( tile__config_data_counter_th[12] ),
    .ctrl_slice_idx( tile__ctrl_slice_idx[12] ),
    .recv_const( tile__recv_const[12] ),
    .recv_const_en( tile__recv_const_en[12] ),
    .recv_const_waddr( tile__recv_const_waddr[12] ),
    .recv_data( tile__recv_data[12] ),
    .recv_data_ack( tile__recv_data_ack[12] ),
    .recv_data_valid( tile__recv_data_valid[12] ),
    .recv_opt_waddr( tile__recv_opt_waddr[12] ),
    .recv_opt_waddr_en( tile__recv_opt_waddr_en[12] ),
    .recv_wopt( tile__recv_wopt[12] ),
    .recv_wopt_en( tile__recv_wopt_en[12] ),
    .reset( tile__reset[12] ),
    .send_data( tile__send_data[12] ),
    .send_data_ack( tile__send_data_ack[12] ),
    .send_data_valid( tile__send_data_valid[12] ),
    .tile_config_ini_begin( tile__tile_config_ini_begin[12] ),
    .tile_dry_run_ack( tile__tile_dry_run_ack[12] ),
    .tile_dry_run_done( tile__tile_dry_run_done[12] ),
    .tile_execution_begin( tile__tile_execution_begin[12] ),
    .tile_execution_ini_begin( tile__tile_execution_ini_begin[12] ),
    .tile_execution_valid( tile__tile_execution_valid[12] ),
    .tile_fu_propagate_rdy( tile__tile_fu_propagate_rdy[12] ),
    .tile_xbar_propagate_rdy( tile__tile_xbar_propagate_rdy[12] ),
    .from_mem_rdata__en( tile__from_mem_rdata__en[12] ),
    .from_mem_rdata__msg( tile__from_mem_rdata__msg[12] ),
    .from_mem_rdata__rdy( tile__from_mem_rdata__rdy[12] ),
    .to_mem_raddr__en( tile__to_mem_raddr__en[12] ),
    .to_mem_raddr__msg( tile__to_mem_raddr__msg[12] ),
    .to_mem_raddr__rdy( tile__to_mem_raddr__rdy[12] ),
    .to_mem_waddr__en( tile__to_mem_waddr__en[12] ),
    .to_mem_waddr__msg( tile__to_mem_waddr__msg[12] ),
    .to_mem_waddr__rdy( tile__to_mem_waddr__rdy[12] ),
    .to_mem_wdata__en( tile__to_mem_wdata__en[12] ),
    .to_mem_wdata__msg( tile__to_mem_wdata__msg[12] ),
    .to_mem_wdata__rdy( tile__to_mem_wdata__rdy[12] )
  );

  TileRTL__4db54fb92d7fbf49 tile__13
  (
    .clk( tile__clk[13] ),
    .config_cmd_counter_th( tile__config_cmd_counter_th[13] ),
    .config_data_counter_th( tile__config_data_counter_th[13] ),
    .ctrl_slice_idx( tile__ctrl_slice_idx[13] ),
    .recv_const( tile__recv_const[13] ),
    .recv_const_en( tile__recv_const_en[13] ),
    .recv_const_waddr( tile__recv_const_waddr[13] ),
    .recv_data( tile__recv_data[13] ),
    .recv_data_ack( tile__recv_data_ack[13] ),
    .recv_data_valid( tile__recv_data_valid[13] ),
    .recv_opt_waddr( tile__recv_opt_waddr[13] ),
    .recv_opt_waddr_en( tile__recv_opt_waddr_en[13] ),
    .recv_wopt( tile__recv_wopt[13] ),
    .recv_wopt_en( tile__recv_wopt_en[13] ),
    .reset( tile__reset[13] ),
    .send_data( tile__send_data[13] ),
    .send_data_ack( tile__send_data_ack[13] ),
    .send_data_valid( tile__send_data_valid[13] ),
    .tile_config_ini_begin( tile__tile_config_ini_begin[13] ),
    .tile_dry_run_ack( tile__tile_dry_run_ack[13] ),
    .tile_dry_run_done( tile__tile_dry_run_done[13] ),
    .tile_execution_begin( tile__tile_execution_begin[13] ),
    .tile_execution_ini_begin( tile__tile_execution_ini_begin[13] ),
    .tile_execution_valid( tile__tile_execution_valid[13] ),
    .tile_fu_propagate_rdy( tile__tile_fu_propagate_rdy[13] ),
    .tile_xbar_propagate_rdy( tile__tile_xbar_propagate_rdy[13] ),
    .from_mem_rdata__en( tile__from_mem_rdata__en[13] ),
    .from_mem_rdata__msg( tile__from_mem_rdata__msg[13] ),
    .from_mem_rdata__rdy( tile__from_mem_rdata__rdy[13] ),
    .to_mem_raddr__en( tile__to_mem_raddr__en[13] ),
    .to_mem_raddr__msg( tile__to_mem_raddr__msg[13] ),
    .to_mem_raddr__rdy( tile__to_mem_raddr__rdy[13] ),
    .to_mem_waddr__en( tile__to_mem_waddr__en[13] ),
    .to_mem_waddr__msg( tile__to_mem_waddr__msg[13] ),
    .to_mem_waddr__rdy( tile__to_mem_waddr__rdy[13] ),
    .to_mem_wdata__en( tile__to_mem_wdata__en[13] ),
    .to_mem_wdata__msg( tile__to_mem_wdata__msg[13] ),
    .to_mem_wdata__rdy( tile__to_mem_wdata__rdy[13] )
  );

  TileRTL__4db54fb92d7fbf49 tile__14
  (
    .clk( tile__clk[14] ),
    .config_cmd_counter_th( tile__config_cmd_counter_th[14] ),
    .config_data_counter_th( tile__config_data_counter_th[14] ),
    .ctrl_slice_idx( tile__ctrl_slice_idx[14] ),
    .recv_const( tile__recv_const[14] ),
    .recv_const_en( tile__recv_const_en[14] ),
    .recv_const_waddr( tile__recv_const_waddr[14] ),
    .recv_data( tile__recv_data[14] ),
    .recv_data_ack( tile__recv_data_ack[14] ),
    .recv_data_valid( tile__recv_data_valid[14] ),
    .recv_opt_waddr( tile__recv_opt_waddr[14] ),
    .recv_opt_waddr_en( tile__recv_opt_waddr_en[14] ),
    .recv_wopt( tile__recv_wopt[14] ),
    .recv_wopt_en( tile__recv_wopt_en[14] ),
    .reset( tile__reset[14] ),
    .send_data( tile__send_data[14] ),
    .send_data_ack( tile__send_data_ack[14] ),
    .send_data_valid( tile__send_data_valid[14] ),
    .tile_config_ini_begin( tile__tile_config_ini_begin[14] ),
    .tile_dry_run_ack( tile__tile_dry_run_ack[14] ),
    .tile_dry_run_done( tile__tile_dry_run_done[14] ),
    .tile_execution_begin( tile__tile_execution_begin[14] ),
    .tile_execution_ini_begin( tile__tile_execution_ini_begin[14] ),
    .tile_execution_valid( tile__tile_execution_valid[14] ),
    .tile_fu_propagate_rdy( tile__tile_fu_propagate_rdy[14] ),
    .tile_xbar_propagate_rdy( tile__tile_xbar_propagate_rdy[14] ),
    .from_mem_rdata__en( tile__from_mem_rdata__en[14] ),
    .from_mem_rdata__msg( tile__from_mem_rdata__msg[14] ),
    .from_mem_rdata__rdy( tile__from_mem_rdata__rdy[14] ),
    .to_mem_raddr__en( tile__to_mem_raddr__en[14] ),
    .to_mem_raddr__msg( tile__to_mem_raddr__msg[14] ),
    .to_mem_raddr__rdy( tile__to_mem_raddr__rdy[14] ),
    .to_mem_waddr__en( tile__to_mem_waddr__en[14] ),
    .to_mem_waddr__msg( tile__to_mem_waddr__msg[14] ),
    .to_mem_waddr__rdy( tile__to_mem_waddr__rdy[14] ),
    .to_mem_wdata__en( tile__to_mem_wdata__en[14] ),
    .to_mem_wdata__msg( tile__to_mem_wdata__msg[14] ),
    .to_mem_wdata__rdy( tile__to_mem_wdata__rdy[14] )
  );

  TileRTL__4db54fb92d7fbf49 tile__15
  (
    .clk( tile__clk[15] ),
    .config_cmd_counter_th( tile__config_cmd_counter_th[15] ),
    .config_data_counter_th( tile__config_data_counter_th[15] ),
    .ctrl_slice_idx( tile__ctrl_slice_idx[15] ),
    .recv_const( tile__recv_const[15] ),
    .recv_const_en( tile__recv_const_en[15] ),
    .recv_const_waddr( tile__recv_const_waddr[15] ),
    .recv_data( tile__recv_data[15] ),
    .recv_data_ack( tile__recv_data_ack[15] ),
    .recv_data_valid( tile__recv_data_valid[15] ),
    .recv_opt_waddr( tile__recv_opt_waddr[15] ),
    .recv_opt_waddr_en( tile__recv_opt_waddr_en[15] ),
    .recv_wopt( tile__recv_wopt[15] ),
    .recv_wopt_en( tile__recv_wopt_en[15] ),
    .reset( tile__reset[15] ),
    .send_data( tile__send_data[15] ),
    .send_data_ack( tile__send_data_ack[15] ),
    .send_data_valid( tile__send_data_valid[15] ),
    .tile_config_ini_begin( tile__tile_config_ini_begin[15] ),
    .tile_dry_run_ack( tile__tile_dry_run_ack[15] ),
    .tile_dry_run_done( tile__tile_dry_run_done[15] ),
    .tile_execution_begin( tile__tile_execution_begin[15] ),
    .tile_execution_ini_begin( tile__tile_execution_ini_begin[15] ),
    .tile_execution_valid( tile__tile_execution_valid[15] ),
    .tile_fu_propagate_rdy( tile__tile_fu_propagate_rdy[15] ),
    .tile_xbar_propagate_rdy( tile__tile_xbar_propagate_rdy[15] ),
    .from_mem_rdata__en( tile__from_mem_rdata__en[15] ),
    .from_mem_rdata__msg( tile__from_mem_rdata__msg[15] ),
    .from_mem_rdata__rdy( tile__from_mem_rdata__rdy[15] ),
    .to_mem_raddr__en( tile__to_mem_raddr__en[15] ),
    .to_mem_raddr__msg( tile__to_mem_raddr__msg[15] ),
    .to_mem_raddr__rdy( tile__to_mem_raddr__rdy[15] ),
    .to_mem_waddr__en( tile__to_mem_waddr__en[15] ),
    .to_mem_waddr__msg( tile__to_mem_waddr__msg[15] ),
    .to_mem_waddr__rdy( tile__to_mem_waddr__rdy[15] ),
    .to_mem_wdata__en( tile__to_mem_wdata__en[15] ),
    .to_mem_wdata__msg( tile__to_mem_wdata__msg[15] ),
    .to_mem_wdata__rdy( tile__to_mem_wdata__rdy[15] )
  );


  
  always_comb begin : _lambda__s_cgra_config_cmd_done
    cgra_config_cmd_done = cgra_config_cmd_wopt_done & tile_dry_run_fin;
  end

  
  always_comb begin : _lambda__s_cgra_config_cmd_wopt_done
    cgra_config_cmd_wopt_done = 6'( counter_config_cmd_addr ) == cgra_config_cmd_counter_th;
  end

  
  always_comb begin : _lambda__s_cgra_config_data_done
    cgra_config_data_done = 6'( counter_config_data_addr ) == cgra_config_data_counter_th;
  end

  
  always_comb begin : _lambda__s_cgra_csr_ro_0_
    cgra_csr_ro[2'd0] = { { 31 { 1'b0 } }, cgra_cycle_th_hit };
  end

  
  always_comb begin : _lambda__s_cgra_cur_stage_info
    cgra_cur_stage_info = { { 29 { 1'b0 } }, cur_stage };
  end

  
  always_comb begin : _lambda__s_cgra_nxt_stage_info
    cgra_nxt_stage_info = { { 29 { 1'b0 } }, nxt_stage };
  end

  
  always_comb begin : _lambda__s_cgra_propagate_rdy_info
    cgra_propagate_rdy_info = { tile_xbar_propagate_rdy_vector, tile_fu_propagate_rdy_vector };
  end

  
  always_comb begin : _lambda__s_cgra_recv_ni_data_0__rdy
    cgra_recv_ni_data__rdy[3'd0] = ( tile_recv_ni_data_ack[3'( __const__i_at__lambda__s_cgra_recv_ni_data_0__rdy )] & cgra_execution_valid ) | cgra_recv_wi_data_ack;
  end

  
  always_comb begin : _lambda__s_cgra_recv_ni_data_1__rdy
    cgra_recv_ni_data__rdy[3'd1] = ( tile_recv_ni_data_ack[3'( __const__i_at__lambda__s_cgra_recv_ni_data_1__rdy )] & cgra_execution_valid ) | cgra_recv_wi_data_ack;
  end

  
  always_comb begin : _lambda__s_cgra_recv_ni_data_2__rdy
    cgra_recv_ni_data__rdy[3'd2] = ( tile_recv_ni_data_ack[3'( __const__i_at__lambda__s_cgra_recv_ni_data_2__rdy )] & cgra_execution_valid ) | cgra_recv_wi_data_ack;
  end

  
  always_comb begin : _lambda__s_cgra_recv_ni_data_3__rdy
    cgra_recv_ni_data__rdy[3'd3] = ( tile_recv_ni_data_ack[3'( __const__i_at__lambda__s_cgra_recv_ni_data_3__rdy )] & cgra_execution_valid ) | cgra_recv_wi_data_ack;
  end

  
  always_comb begin : _lambda__s_cgra_recv_ni_data_4__rdy
    cgra_recv_ni_data__rdy[3'd4] = ( tile_recv_ni_data_ack[3'( __const__i_at__lambda__s_cgra_recv_ni_data_4__rdy )] & cgra_execution_valid ) | cgra_recv_wi_data_ack;
  end

  
  always_comb begin : _lambda__s_cgra_recv_ni_data_5__rdy
    cgra_recv_ni_data__rdy[3'd5] = ( tile_recv_ni_data_ack[3'( __const__i_at__lambda__s_cgra_recv_ni_data_5__rdy )] & cgra_execution_valid ) | cgra_recv_wi_data_ack;
  end

  
  always_comb begin : _lambda__s_cgra_recv_ni_data_6__rdy
    cgra_recv_ni_data__rdy[3'd6] = ( tile_recv_ni_data_ack[3'( __const__i_at__lambda__s_cgra_recv_ni_data_6__rdy )] & cgra_execution_valid ) | cgra_recv_wi_data_ack;
  end

  
  always_comb begin : _lambda__s_cgra_recv_ni_data_7__rdy
    cgra_recv_ni_data__rdy[3'd7] = ( tile_recv_ni_data_ack[3'( __const__i_at__lambda__s_cgra_recv_ni_data_7__rdy )] & cgra_execution_valid ) | cgra_recv_wi_data_ack;
  end

  
  always_comb begin : _lambda__s_cgra_recv_wi_data_ack
    cgra_recv_wi_data_ack = cgra_recv_wi_data_rdy & cgra_recv_wi_data_valid;
  end

  
  always_comb begin : _lambda__s_cgra_recv_wi_data_rdy
    cgra_recv_wi_data_rdy = recv_wopt_sliced_flattened_rdy | recv_wconst_flattened_rdy;
  end

  
  always_comb begin : _lambda__s_cgra_recv_wi_data_valid
    cgra_recv_wi_data_valid = ( & tile_recv_ni_data_valid );
  end

  
  always_comb begin : _lambda__s_recv_wconst_flattened_en
    recv_wconst_flattened_en = cgra_recv_wi_data_ack & cgra_config_data_begin;
  end

  
  always_comb begin : _lambda__s_recv_wopt_sliced_flattened_en
    recv_wopt_sliced_flattened_en = cgra_recv_wi_data_ack & cgra_config_cmd_begin;
  end

  
  always_comb begin : _lambda__s_tile_recv_opt_waddr_en
    tile_recv_opt_waddr_en = cgra_cmd_dry_run_begin & cgra_config_cmd_begin;
  end

  
  always_comb begin : fsm_ctrl_signals
    cgra_config_ini_begin = 1'd0;
    cgra_csr_rw_ack = 1'd0;
    cgra_config_data_begin = 1'd0;
    cgra_config_cmd_begin = 1'd0;
    cgra_execution_begin = 1'd0;
    cgra_execution_ini_begin = 1'd0;
    cgra_execution_valid = 1'd0;
    if ( nxt_stage == 3'( __const__STAGE_CONFIG_CTRLREG ) ) begin
      cgra_config_ini_begin = 1'd1;
    end
    if ( nxt_stage == 3'( __const__STAGE_CONFIG_DATA ) ) begin
      cgra_config_data_begin = 1'd1;
    end
    if ( nxt_stage == 3'( __const__STAGE_CONFIG_CMD ) ) begin
      cgra_config_cmd_begin = 1'd1;
    end
    if ( nxt_stage == 3'( __const__STAGE_CONFIG_DONE ) ) begin
      cgra_execution_ini_begin = 1'd1;
    end
    if ( ( nxt_stage == 3'( __const__STAGE_COMP ) ) | ( cur_stage == 3'( __const__STAGE_COMP ) ) ) begin
      cgra_execution_begin = 1'd1;
    end
    if ( ( cur_stage == 3'( __const__STAGE_CONFIG_CTRLREG ) ) | ( cur_stage == 3'( __const__STAGE_CONFIG_DONE ) ) ) begin
      cgra_csr_rw_ack = cgra_csr_rw_valid;
    end
  end

  
  always_comb begin : fsm_nxt_stage
    nxt_stage = cur_stage;
    if ( cur_stage == 3'( __const__STAGE_IDLE ) ) begin
      if ( cgra_config_ini_en ) begin
        nxt_stage = 3'( __const__STAGE_CONFIG_CTRLREG );
      end
    end
    if ( cur_stage == 3'( __const__STAGE_CONFIG_CTRLREG ) ) begin
      if ( cgra_csr_rw_valid ) begin
        if ( cgra_config_data_en ) begin
          nxt_stage = 3'( __const__STAGE_CONFIG_DATA );
        end
        else if ( cgra_config_cmd_en ) begin
          nxt_stage = 3'( __const__STAGE_CONFIG_CMD );
        end
      end
    end
    if ( cur_stage == 3'( __const__STAGE_CONFIG_DATA ) ) begin
      if ( cgra_config_data_done ) begin
        if ( cgra_config_cmd_en ) begin
          nxt_stage = 3'( __const__STAGE_CONFIG_CMD );
        end
        else
          nxt_stage = 3'( __const__STAGE_CONFIG_DONE );
      end
    end
    if ( cur_stage == 3'( __const__STAGE_CONFIG_CMD ) ) begin
      if ( cgra_config_cmd_done ) begin
        nxt_stage = 3'( __const__STAGE_CONFIG_DONE );
      end
    end
    if ( cur_stage == 3'( __const__STAGE_CONFIG_DONE ) ) begin
      if ( cgra_computation_en ) begin
        nxt_stage = 3'( __const__STAGE_COMP );
      end
    end
    if ( cur_stage == 3'( __const__STAGE_COMP ) ) begin
      if ( cgra_cycle_th_hit | ( ~cgra_computation_en ) ) begin
        nxt_stage = 3'( __const__STAGE_COMP_HALT );
      end
    end
    if ( cur_stage == 3'( __const__STAGE_COMP_HALT ) ) begin
      if ( ( ~cgra_cycle_th_hit ) & cgra_computation_en ) begin
        nxt_stage = 3'( __const__STAGE_COMP );
      end
      else if ( cgra_restart_comp_en ) begin
        nxt_stage = 3'( __const__STAGE_IDLE );
      end
    end
  end

  
  always_ff @(posedge clk) begin : counter_comp
    if ( reset | cgra_config_ini_begin ) begin
      cgra_cycle_counter <= 16'd0;
      cgra_cycle_th_hit <= 1'd0;
    end
    else if ( cgra_execution_begin ) begin
      if ( ( cgra_cycle_counter + 16'd1 ) == cgra_cycle_counter_th ) begin
        cgra_cycle_th_hit <= 1'd1;
      end
      else
        cgra_cycle_counter <= cgra_cycle_counter + 16'd1;
    end
  end

  
  always_ff @(posedge clk) begin : counter_ctrl_config_cmd
    if ( reset | ( ~cgra_config_cmd_begin ) ) begin
      counter_config_cmd_slice <= 1'd0;
    end
    else if ( recv_wopt_sliced_flattened_en & ( ~cgra_config_cmd_wopt_done ) ) begin
      if ( counter_config_cmd_slice == 1'd1 ) begin
        counter_config_cmd_slice <= 1'd0;
      end
      else
        counter_config_cmd_slice <= counter_config_cmd_slice + 1'd1;
    end
  end

  
  always_ff @(posedge clk) begin : counter_ctrl_config_dry_run
    if ( reset | ( ~cgra_config_cmd_begin ) ) begin
      cgra_cmd_dry_run_begin <= 1'd0;
    end
    else
      cgra_cmd_dry_run_begin <= counter_config_cmd_slice == 1'd1;
  end

  
  always_ff @(posedge clk) begin : dry_run_process
    if ( reset ) begin
      tile_dry_run_ack <= 1'd0;
      tile_dry_run_fin <= 1'd0;
    end
    else begin
      tile_dry_run_ack <= tile_recv_opt_waddr_en;
      tile_dry_run_fin <= tile_dry_run_ack;
    end
  end

  
  always_ff @(posedge clk) begin : fsm_update
    if ( reset ) begin
      cur_stage <= 3'( __const__STAGE_IDLE );
    end
    else
      cur_stage <= nxt_stage;
  end

  
  always_ff @(posedge clk) begin : stage_ctrl_config_cmd
    if ( reset | ( ~cgra_config_cmd_begin ) ) begin
      counter_config_cmd_addr <= 5'd0;
    end
    else if ( cgra_cmd_dry_run_begin & ( ~cgra_config_cmd_wopt_done ) ) begin
      counter_config_cmd_addr <= counter_config_cmd_addr + 5'd1;
    end
  end

  
  always_ff @(posedge clk) begin : stage_ctrl_config_data
    if ( reset | ( ~cgra_config_data_begin ) ) begin
      counter_config_data_addr <= 5'd0;
    end
    else if ( recv_wconst_flattened_en & ( ~cgra_config_data_done ) ) begin
      counter_config_data_addr <= counter_config_data_addr + 5'd1;
    end
  end

  
  always_ff @(posedge clk) begin : stage_ctrl_config_ini
    if ( reset ) begin
      cgra_cycle_counter_th <= 16'd0;
      cgra_config_data_counter_th <= 6'd0;
      cgra_config_cmd_counter_th <= 6'd0;
    end
    else if ( cgra_config_ini_begin ) begin
      cgra_cycle_counter_th <= cgra_csr_rw[1'd0][5'd15:5'd0];
      cgra_config_data_counter_th <= 6'( cgra_csr_rw[1'd0][5'd20:5'd16] );
      cgra_config_cmd_counter_th <= 6'( cgra_csr_rw[1'd0][5'd25:5'd21] );
    end
  end

  assign cgra_recv_wi_data[63:0] = cgra_recv_ni_data__msg[0];
  assign tile_recv_ni_data_valid[0:0] = cgra_recv_ni_data__en[0];
  assign cgra_recv_wi_data[127:64] = cgra_recv_ni_data__msg[1];
  assign tile_recv_ni_data_valid[1:1] = cgra_recv_ni_data__en[1];
  assign cgra_recv_wi_data[191:128] = cgra_recv_ni_data__msg[2];
  assign tile_recv_ni_data_valid[2:2] = cgra_recv_ni_data__en[2];
  assign cgra_recv_wi_data[255:192] = cgra_recv_ni_data__msg[3];
  assign tile_recv_ni_data_valid[3:3] = cgra_recv_ni_data__en[3];
  assign cgra_recv_wi_data[319:256] = cgra_recv_ni_data__msg[4];
  assign tile_recv_ni_data_valid[4:4] = cgra_recv_ni_data__en[4];
  assign cgra_recv_wi_data[383:320] = cgra_recv_ni_data__msg[5];
  assign tile_recv_ni_data_valid[5:5] = cgra_recv_ni_data__en[5];
  assign cgra_recv_wi_data[447:384] = cgra_recv_ni_data__msg[6];
  assign tile_recv_ni_data_valid[6:6] = cgra_recv_ni_data__en[6];
  assign cgra_recv_wi_data[511:448] = cgra_recv_ni_data__msg[7];
  assign tile_recv_ni_data_valid[7:7] = cgra_recv_ni_data__en[7];
  assign recv_wopt_sliced_flattened = cgra_recv_wi_data;
  assign recv_wconst_flattened = cgra_recv_wi_data;
  assign tile__clk[0] = clk;
  assign tile__reset[0] = reset;
  assign tile__clk[1] = clk;
  assign tile__reset[1] = reset;
  assign tile__clk[2] = clk;
  assign tile__reset[2] = reset;
  assign tile__clk[3] = clk;
  assign tile__reset[3] = reset;
  assign tile__clk[4] = clk;
  assign tile__reset[4] = reset;
  assign tile__clk[5] = clk;
  assign tile__reset[5] = reset;
  assign tile__clk[6] = clk;
  assign tile__reset[6] = reset;
  assign tile__clk[7] = clk;
  assign tile__reset[7] = reset;
  assign tile__clk[8] = clk;
  assign tile__reset[8] = reset;
  assign tile__clk[9] = clk;
  assign tile__reset[9] = reset;
  assign tile__clk[10] = clk;
  assign tile__reset[10] = reset;
  assign tile__clk[11] = clk;
  assign tile__reset[11] = reset;
  assign tile__clk[12] = clk;
  assign tile__reset[12] = reset;
  assign tile__clk[13] = clk;
  assign tile__reset[13] = reset;
  assign tile__clk[14] = clk;
  assign tile__reset[14] = reset;
  assign tile__clk[15] = clk;
  assign tile__reset[15] = reset;
  assign cgra_csr_ro[1] = cgra_cur_stage_info;
  assign cgra_csr_ro[2] = cgra_nxt_stage_info;
  assign cgra_csr_ro[3] = cgra_propagate_rdy_info;
  assign cgra_config_ini_en = cgra_csr_rw[0][30:30];
  assign cgra_restart_comp_en = cgra_csr_rw[0][29:29];
  assign cgra_config_data_en = cgra_csr_rw[0][28:28];
  assign cgra_config_cmd_en = cgra_csr_rw[0][27:27];
  assign cgra_computation_en = cgra_csr_rw[0][26:26];
  assign recv_wconst_flattened_rdy = cgra_config_data_begin;
  assign recv_wopt_sliced_flattened_rdy = cgra_config_cmd_begin;
  assign tile__tile_config_ini_begin[0] = cgra_config_ini_begin;
  assign tile__tile_execution_ini_begin[0] = cgra_execution_ini_begin;
  assign tile__tile_execution_begin[0] = cgra_execution_begin;
  assign tile__tile_execution_valid[0] = cgra_execution_valid;
  assign tile__tile_dry_run_ack[0] = tile_dry_run_ack;
  assign tile__tile_dry_run_done[0] = cgra_config_cmd_done;
  assign tile__config_cmd_counter_th[0] = cgra_config_cmd_counter_th;
  assign tile__config_data_counter_th[0] = cgra_config_data_counter_th;
  assign tile__tile_config_ini_begin[1] = cgra_config_ini_begin;
  assign tile__tile_execution_ini_begin[1] = cgra_execution_ini_begin;
  assign tile__tile_execution_begin[1] = cgra_execution_begin;
  assign tile__tile_execution_valid[1] = cgra_execution_valid;
  assign tile__tile_dry_run_ack[1] = tile_dry_run_ack;
  assign tile__tile_dry_run_done[1] = cgra_config_cmd_done;
  assign tile__config_cmd_counter_th[1] = cgra_config_cmd_counter_th;
  assign tile__config_data_counter_th[1] = cgra_config_data_counter_th;
  assign tile__tile_config_ini_begin[2] = cgra_config_ini_begin;
  assign tile__tile_execution_ini_begin[2] = cgra_execution_ini_begin;
  assign tile__tile_execution_begin[2] = cgra_execution_begin;
  assign tile__tile_execution_valid[2] = cgra_execution_valid;
  assign tile__tile_dry_run_ack[2] = tile_dry_run_ack;
  assign tile__tile_dry_run_done[2] = cgra_config_cmd_done;
  assign tile__config_cmd_counter_th[2] = cgra_config_cmd_counter_th;
  assign tile__config_data_counter_th[2] = cgra_config_data_counter_th;
  assign tile__tile_config_ini_begin[3] = cgra_config_ini_begin;
  assign tile__tile_execution_ini_begin[3] = cgra_execution_ini_begin;
  assign tile__tile_execution_begin[3] = cgra_execution_begin;
  assign tile__tile_execution_valid[3] = cgra_execution_valid;
  assign tile__tile_dry_run_ack[3] = tile_dry_run_ack;
  assign tile__tile_dry_run_done[3] = cgra_config_cmd_done;
  assign tile__config_cmd_counter_th[3] = cgra_config_cmd_counter_th;
  assign tile__config_data_counter_th[3] = cgra_config_data_counter_th;
  assign tile__tile_config_ini_begin[4] = cgra_config_ini_begin;
  assign tile__tile_execution_ini_begin[4] = cgra_execution_ini_begin;
  assign tile__tile_execution_begin[4] = cgra_execution_begin;
  assign tile__tile_execution_valid[4] = cgra_execution_valid;
  assign tile__tile_dry_run_ack[4] = tile_dry_run_ack;
  assign tile__tile_dry_run_done[4] = cgra_config_cmd_done;
  assign tile__config_cmd_counter_th[4] = cgra_config_cmd_counter_th;
  assign tile__config_data_counter_th[4] = cgra_config_data_counter_th;
  assign tile__tile_config_ini_begin[5] = cgra_config_ini_begin;
  assign tile__tile_execution_ini_begin[5] = cgra_execution_ini_begin;
  assign tile__tile_execution_begin[5] = cgra_execution_begin;
  assign tile__tile_execution_valid[5] = cgra_execution_valid;
  assign tile__tile_dry_run_ack[5] = tile_dry_run_ack;
  assign tile__tile_dry_run_done[5] = cgra_config_cmd_done;
  assign tile__config_cmd_counter_th[5] = cgra_config_cmd_counter_th;
  assign tile__config_data_counter_th[5] = cgra_config_data_counter_th;
  assign tile__tile_config_ini_begin[6] = cgra_config_ini_begin;
  assign tile__tile_execution_ini_begin[6] = cgra_execution_ini_begin;
  assign tile__tile_execution_begin[6] = cgra_execution_begin;
  assign tile__tile_execution_valid[6] = cgra_execution_valid;
  assign tile__tile_dry_run_ack[6] = tile_dry_run_ack;
  assign tile__tile_dry_run_done[6] = cgra_config_cmd_done;
  assign tile__config_cmd_counter_th[6] = cgra_config_cmd_counter_th;
  assign tile__config_data_counter_th[6] = cgra_config_data_counter_th;
  assign tile__tile_config_ini_begin[7] = cgra_config_ini_begin;
  assign tile__tile_execution_ini_begin[7] = cgra_execution_ini_begin;
  assign tile__tile_execution_begin[7] = cgra_execution_begin;
  assign tile__tile_execution_valid[7] = cgra_execution_valid;
  assign tile__tile_dry_run_ack[7] = tile_dry_run_ack;
  assign tile__tile_dry_run_done[7] = cgra_config_cmd_done;
  assign tile__config_cmd_counter_th[7] = cgra_config_cmd_counter_th;
  assign tile__config_data_counter_th[7] = cgra_config_data_counter_th;
  assign tile__tile_config_ini_begin[8] = cgra_config_ini_begin;
  assign tile__tile_execution_ini_begin[8] = cgra_execution_ini_begin;
  assign tile__tile_execution_begin[8] = cgra_execution_begin;
  assign tile__tile_execution_valid[8] = cgra_execution_valid;
  assign tile__tile_dry_run_ack[8] = tile_dry_run_ack;
  assign tile__tile_dry_run_done[8] = cgra_config_cmd_done;
  assign tile__config_cmd_counter_th[8] = cgra_config_cmd_counter_th;
  assign tile__config_data_counter_th[8] = cgra_config_data_counter_th;
  assign tile__tile_config_ini_begin[9] = cgra_config_ini_begin;
  assign tile__tile_execution_ini_begin[9] = cgra_execution_ini_begin;
  assign tile__tile_execution_begin[9] = cgra_execution_begin;
  assign tile__tile_execution_valid[9] = cgra_execution_valid;
  assign tile__tile_dry_run_ack[9] = tile_dry_run_ack;
  assign tile__tile_dry_run_done[9] = cgra_config_cmd_done;
  assign tile__config_cmd_counter_th[9] = cgra_config_cmd_counter_th;
  assign tile__config_data_counter_th[9] = cgra_config_data_counter_th;
  assign tile__tile_config_ini_begin[10] = cgra_config_ini_begin;
  assign tile__tile_execution_ini_begin[10] = cgra_execution_ini_begin;
  assign tile__tile_execution_begin[10] = cgra_execution_begin;
  assign tile__tile_execution_valid[10] = cgra_execution_valid;
  assign tile__tile_dry_run_ack[10] = tile_dry_run_ack;
  assign tile__tile_dry_run_done[10] = cgra_config_cmd_done;
  assign tile__config_cmd_counter_th[10] = cgra_config_cmd_counter_th;
  assign tile__config_data_counter_th[10] = cgra_config_data_counter_th;
  assign tile__tile_config_ini_begin[11] = cgra_config_ini_begin;
  assign tile__tile_execution_ini_begin[11] = cgra_execution_ini_begin;
  assign tile__tile_execution_begin[11] = cgra_execution_begin;
  assign tile__tile_execution_valid[11] = cgra_execution_valid;
  assign tile__tile_dry_run_ack[11] = tile_dry_run_ack;
  assign tile__tile_dry_run_done[11] = cgra_config_cmd_done;
  assign tile__config_cmd_counter_th[11] = cgra_config_cmd_counter_th;
  assign tile__config_data_counter_th[11] = cgra_config_data_counter_th;
  assign tile__tile_config_ini_begin[12] = cgra_config_ini_begin;
  assign tile__tile_execution_ini_begin[12] = cgra_execution_ini_begin;
  assign tile__tile_execution_begin[12] = cgra_execution_begin;
  assign tile__tile_execution_valid[12] = cgra_execution_valid;
  assign tile__tile_dry_run_ack[12] = tile_dry_run_ack;
  assign tile__tile_dry_run_done[12] = cgra_config_cmd_done;
  assign tile__config_cmd_counter_th[12] = cgra_config_cmd_counter_th;
  assign tile__config_data_counter_th[12] = cgra_config_data_counter_th;
  assign tile__tile_config_ini_begin[13] = cgra_config_ini_begin;
  assign tile__tile_execution_ini_begin[13] = cgra_execution_ini_begin;
  assign tile__tile_execution_begin[13] = cgra_execution_begin;
  assign tile__tile_execution_valid[13] = cgra_execution_valid;
  assign tile__tile_dry_run_ack[13] = tile_dry_run_ack;
  assign tile__tile_dry_run_done[13] = cgra_config_cmd_done;
  assign tile__config_cmd_counter_th[13] = cgra_config_cmd_counter_th;
  assign tile__config_data_counter_th[13] = cgra_config_data_counter_th;
  assign tile__tile_config_ini_begin[14] = cgra_config_ini_begin;
  assign tile__tile_execution_ini_begin[14] = cgra_execution_ini_begin;
  assign tile__tile_execution_begin[14] = cgra_execution_begin;
  assign tile__tile_execution_valid[14] = cgra_execution_valid;
  assign tile__tile_dry_run_ack[14] = tile_dry_run_ack;
  assign tile__tile_dry_run_done[14] = cgra_config_cmd_done;
  assign tile__config_cmd_counter_th[14] = cgra_config_cmd_counter_th;
  assign tile__config_data_counter_th[14] = cgra_config_data_counter_th;
  assign tile__tile_config_ini_begin[15] = cgra_config_ini_begin;
  assign tile__tile_execution_ini_begin[15] = cgra_execution_ini_begin;
  assign tile__tile_execution_begin[15] = cgra_execution_begin;
  assign tile__tile_execution_valid[15] = cgra_execution_valid;
  assign tile__tile_dry_run_ack[15] = tile_dry_run_ack;
  assign tile__tile_dry_run_done[15] = cgra_config_cmd_done;
  assign tile__config_cmd_counter_th[15] = cgra_config_cmd_counter_th;
  assign tile__config_data_counter_th[15] = cgra_config_data_counter_th;
  assign tile__ctrl_slice_idx[0] = counter_config_cmd_slice;
  assign tile__recv_opt_waddr[0] = counter_config_cmd_addr;
  assign tile__recv_opt_waddr_en[0] = tile_recv_opt_waddr_en;
  assign tile__recv_wopt[0] = recv_wopt_sliced_flattened[31:0];
  assign tile__recv_wopt_en[0] = recv_wopt_sliced_flattened_en;
  assign tile__recv_const_waddr[0] = counter_config_data_addr;
  assign tile__recv_const[0] = recv_wconst_flattened[31:0];
  assign tile__recv_const_en[0] = recv_wconst_flattened_en;
  assign tile__recv_data[4][1] = tile__send_data[0][0];
  assign tile__recv_data_valid[4][1] = tile__send_data_valid[0][0];
  assign tile__send_data_ack[0][0] = tile__recv_data_ack[4][1];
  assign tile__recv_data[1][2] = tile__send_data[0][3];
  assign tile__recv_data_valid[1][2] = tile__send_data_valid[0][3];
  assign tile__send_data_ack[0][3] = tile__recv_data_ack[1][2];
  assign tile__send_data_ack[0][1] = cgra_send_ni_data__rdy[4];
  assign cgra_send_ni_data__en[4] = tile__send_data_valid[0][1];
  assign cgra_send_ni_data__msg[4] = tile__send_data[0][1].payload;
  assign tile__recv_data_valid[0][1] = 1'd0;
  assign tile__recv_data[0][1] = { 64'd0, 1'd0 };
  assign tile__send_data_ack[0][2] = 1'd0;
  assign tile_recv_ni_data_ack[0:0] = tile__recv_data_ack[0][2];
  assign tile__recv_data_valid[0][2] = cgra_recv_ni_data__en[0];
  assign tile__recv_data[0][2].payload = cgra_recv_ni_data__msg[0];
  assign tile__recv_data[0][2].predicate = 1'd0;
  assign tile__to_mem_raddr__rdy[0] = 1'd0;
  assign tile__from_mem_rdata__en[0] = 1'd0;
  assign tile__from_mem_rdata__msg[0] = { 64'd0, 1'd0 };
  assign tile__to_mem_waddr__rdy[0] = 1'd0;
  assign tile__to_mem_wdata__rdy[0] = 1'd0;
  assign tile__ctrl_slice_idx[1] = counter_config_cmd_slice;
  assign tile__recv_opt_waddr[1] = counter_config_cmd_addr;
  assign tile__recv_opt_waddr_en[1] = tile_recv_opt_waddr_en;
  assign tile__recv_wopt[1] = recv_wopt_sliced_flattened[63:32];
  assign tile__recv_wopt_en[1] = recv_wopt_sliced_flattened_en;
  assign tile__recv_const_waddr[1] = counter_config_data_addr;
  assign tile__recv_const[1] = recv_wconst_flattened[63:32];
  assign tile__recv_const_en[1] = recv_wconst_flattened_en;
  assign tile__recv_data[5][1] = tile__send_data[1][0];
  assign tile__recv_data_valid[5][1] = tile__send_data_valid[1][0];
  assign tile__send_data_ack[1][0] = tile__recv_data_ack[5][1];
  assign tile__recv_data[0][3] = tile__send_data[1][2];
  assign tile__recv_data_valid[0][3] = tile__send_data_valid[1][2];
  assign tile__send_data_ack[1][2] = tile__recv_data_ack[0][3];
  assign tile__recv_data[2][2] = tile__send_data[1][3];
  assign tile__recv_data_valid[2][2] = tile__send_data_valid[1][3];
  assign tile__send_data_ack[1][3] = tile__recv_data_ack[2][2];
  assign tile__send_data_ack[1][1] = cgra_send_ni_data__rdy[5];
  assign cgra_send_ni_data__en[5] = tile__send_data_valid[1][1];
  assign cgra_send_ni_data__msg[5] = tile__send_data[1][1].payload;
  assign tile__recv_data_valid[1][1] = 1'd0;
  assign tile__recv_data[1][1] = { 64'd0, 1'd0 };
  assign tile__to_mem_raddr__rdy[1] = 1'd0;
  assign tile__from_mem_rdata__en[1] = 1'd0;
  assign tile__from_mem_rdata__msg[1] = { 64'd0, 1'd0 };
  assign tile__to_mem_waddr__rdy[1] = 1'd0;
  assign tile__to_mem_wdata__rdy[1] = 1'd0;
  assign tile__ctrl_slice_idx[2] = counter_config_cmd_slice;
  assign tile__recv_opt_waddr[2] = counter_config_cmd_addr;
  assign tile__recv_opt_waddr_en[2] = tile_recv_opt_waddr_en;
  assign tile__recv_wopt[2] = recv_wopt_sliced_flattened[95:64];
  assign tile__recv_wopt_en[2] = recv_wopt_sliced_flattened_en;
  assign tile__recv_const_waddr[2] = counter_config_data_addr;
  assign tile__recv_const[2] = recv_wconst_flattened[95:64];
  assign tile__recv_const_en[2] = recv_wconst_flattened_en;
  assign tile__recv_data[6][1] = tile__send_data[2][0];
  assign tile__recv_data_valid[6][1] = tile__send_data_valid[2][0];
  assign tile__send_data_ack[2][0] = tile__recv_data_ack[6][1];
  assign tile__recv_data[1][3] = tile__send_data[2][2];
  assign tile__recv_data_valid[1][3] = tile__send_data_valid[2][2];
  assign tile__send_data_ack[2][2] = tile__recv_data_ack[1][3];
  assign tile__recv_data[3][2] = tile__send_data[2][3];
  assign tile__recv_data_valid[3][2] = tile__send_data_valid[2][3];
  assign tile__send_data_ack[2][3] = tile__recv_data_ack[3][2];
  assign tile__send_data_ack[2][1] = cgra_send_ni_data__rdy[6];
  assign cgra_send_ni_data__en[6] = tile__send_data_valid[2][1];
  assign cgra_send_ni_data__msg[6] = tile__send_data[2][1].payload;
  assign tile__recv_data_valid[2][1] = 1'd0;
  assign tile__recv_data[2][1] = { 64'd0, 1'd0 };
  assign tile__to_mem_raddr__rdy[2] = 1'd0;
  assign tile__from_mem_rdata__en[2] = 1'd0;
  assign tile__from_mem_rdata__msg[2] = { 64'd0, 1'd0 };
  assign tile__to_mem_waddr__rdy[2] = 1'd0;
  assign tile__to_mem_wdata__rdy[2] = 1'd0;
  assign tile__ctrl_slice_idx[3] = counter_config_cmd_slice;
  assign tile__recv_opt_waddr[3] = counter_config_cmd_addr;
  assign tile__recv_opt_waddr_en[3] = tile_recv_opt_waddr_en;
  assign tile__recv_wopt[3] = recv_wopt_sliced_flattened[127:96];
  assign tile__recv_wopt_en[3] = recv_wopt_sliced_flattened_en;
  assign tile__recv_const_waddr[3] = counter_config_data_addr;
  assign tile__recv_const[3] = recv_wconst_flattened[127:96];
  assign tile__recv_const_en[3] = recv_wconst_flattened_en;
  assign tile__recv_data[7][1] = tile__send_data[3][0];
  assign tile__recv_data_valid[7][1] = tile__send_data_valid[3][0];
  assign tile__send_data_ack[3][0] = tile__recv_data_ack[7][1];
  assign tile__recv_data[2][3] = tile__send_data[3][2];
  assign tile__recv_data_valid[2][3] = tile__send_data_valid[3][2];
  assign tile__send_data_ack[3][2] = tile__recv_data_ack[2][3];
  assign tile__send_data_ack[3][1] = cgra_send_ni_data__rdy[7];
  assign cgra_send_ni_data__en[7] = tile__send_data_valid[3][1];
  assign cgra_send_ni_data__msg[7] = tile__send_data[3][1].payload;
  assign tile__recv_data_valid[3][1] = 1'd0;
  assign tile__recv_data[3][1] = { 64'd0, 1'd0 };
  assign tile__send_data_ack[3][3] = cgra_send_ni_data__rdy[0];
  assign cgra_send_ni_data__en[0] = tile__send_data_valid[3][3];
  assign cgra_send_ni_data__msg[0] = tile__send_data[3][3].payload;
  assign tile__recv_data_valid[3][3] = 1'd0;
  assign tile__recv_data[3][3] = { 64'd0, 1'd0 };
  assign tile__to_mem_raddr__rdy[3] = 1'd0;
  assign tile__from_mem_rdata__en[3] = 1'd0;
  assign tile__from_mem_rdata__msg[3] = { 64'd0, 1'd0 };
  assign tile__to_mem_waddr__rdy[3] = 1'd0;
  assign tile__to_mem_wdata__rdy[3] = 1'd0;
  assign tile__ctrl_slice_idx[4] = counter_config_cmd_slice;
  assign tile__recv_opt_waddr[4] = counter_config_cmd_addr;
  assign tile__recv_opt_waddr_en[4] = tile_recv_opt_waddr_en;
  assign tile__recv_wopt[4] = recv_wopt_sliced_flattened[159:128];
  assign tile__recv_wopt_en[4] = recv_wopt_sliced_flattened_en;
  assign tile__recv_const_waddr[4] = counter_config_data_addr;
  assign tile__recv_const[4] = recv_wconst_flattened[159:128];
  assign tile__recv_const_en[4] = recv_wconst_flattened_en;
  assign tile__recv_data[0][0] = tile__send_data[4][1];
  assign tile__recv_data_valid[0][0] = tile__send_data_valid[4][1];
  assign tile__send_data_ack[4][1] = tile__recv_data_ack[0][0];
  assign tile__recv_data[8][1] = tile__send_data[4][0];
  assign tile__recv_data_valid[8][1] = tile__send_data_valid[4][0];
  assign tile__send_data_ack[4][0] = tile__recv_data_ack[8][1];
  assign tile__recv_data[5][2] = tile__send_data[4][3];
  assign tile__recv_data_valid[5][2] = tile__send_data_valid[4][3];
  assign tile__send_data_ack[4][3] = tile__recv_data_ack[5][2];
  assign tile__send_data_ack[4][2] = 1'd0;
  assign tile_recv_ni_data_ack[1:1] = tile__recv_data_ack[4][2];
  assign tile__recv_data_valid[4][2] = cgra_recv_ni_data__en[1];
  assign tile__recv_data[4][2].payload = cgra_recv_ni_data__msg[1];
  assign tile__recv_data[4][2].predicate = 1'd0;
  assign tile__to_mem_raddr__rdy[4] = 1'd0;
  assign tile__from_mem_rdata__en[4] = 1'd0;
  assign tile__from_mem_rdata__msg[4] = { 64'd0, 1'd0 };
  assign tile__to_mem_waddr__rdy[4] = 1'd0;
  assign tile__to_mem_wdata__rdy[4] = 1'd0;
  assign tile__ctrl_slice_idx[5] = counter_config_cmd_slice;
  assign tile__recv_opt_waddr[5] = counter_config_cmd_addr;
  assign tile__recv_opt_waddr_en[5] = tile_recv_opt_waddr_en;
  assign tile__recv_wopt[5] = recv_wopt_sliced_flattened[191:160];
  assign tile__recv_wopt_en[5] = recv_wopt_sliced_flattened_en;
  assign tile__recv_const_waddr[5] = counter_config_data_addr;
  assign tile__recv_const[5] = recv_wconst_flattened[191:160];
  assign tile__recv_const_en[5] = recv_wconst_flattened_en;
  assign tile__recv_data[1][0] = tile__send_data[5][1];
  assign tile__recv_data_valid[1][0] = tile__send_data_valid[5][1];
  assign tile__send_data_ack[5][1] = tile__recv_data_ack[1][0];
  assign tile__recv_data[9][1] = tile__send_data[5][0];
  assign tile__recv_data_valid[9][1] = tile__send_data_valid[5][0];
  assign tile__send_data_ack[5][0] = tile__recv_data_ack[9][1];
  assign tile__recv_data[4][3] = tile__send_data[5][2];
  assign tile__recv_data_valid[4][3] = tile__send_data_valid[5][2];
  assign tile__send_data_ack[5][2] = tile__recv_data_ack[4][3];
  assign tile__recv_data[6][2] = tile__send_data[5][3];
  assign tile__recv_data_valid[6][2] = tile__send_data_valid[5][3];
  assign tile__send_data_ack[5][3] = tile__recv_data_ack[6][2];
  assign tile__to_mem_raddr__rdy[5] = 1'd0;
  assign tile__from_mem_rdata__en[5] = 1'd0;
  assign tile__from_mem_rdata__msg[5] = { 64'd0, 1'd0 };
  assign tile__to_mem_waddr__rdy[5] = 1'd0;
  assign tile__to_mem_wdata__rdy[5] = 1'd0;
  assign tile__ctrl_slice_idx[6] = counter_config_cmd_slice;
  assign tile__recv_opt_waddr[6] = counter_config_cmd_addr;
  assign tile__recv_opt_waddr_en[6] = tile_recv_opt_waddr_en;
  assign tile__recv_wopt[6] = recv_wopt_sliced_flattened[223:192];
  assign tile__recv_wopt_en[6] = recv_wopt_sliced_flattened_en;
  assign tile__recv_const_waddr[6] = counter_config_data_addr;
  assign tile__recv_const[6] = recv_wconst_flattened[223:192];
  assign tile__recv_const_en[6] = recv_wconst_flattened_en;
  assign tile__recv_data[2][0] = tile__send_data[6][1];
  assign tile__recv_data_valid[2][0] = tile__send_data_valid[6][1];
  assign tile__send_data_ack[6][1] = tile__recv_data_ack[2][0];
  assign tile__recv_data[10][1] = tile__send_data[6][0];
  assign tile__recv_data_valid[10][1] = tile__send_data_valid[6][0];
  assign tile__send_data_ack[6][0] = tile__recv_data_ack[10][1];
  assign tile__recv_data[5][3] = tile__send_data[6][2];
  assign tile__recv_data_valid[5][3] = tile__send_data_valid[6][2];
  assign tile__send_data_ack[6][2] = tile__recv_data_ack[5][3];
  assign tile__recv_data[7][2] = tile__send_data[6][3];
  assign tile__recv_data_valid[7][2] = tile__send_data_valid[6][3];
  assign tile__send_data_ack[6][3] = tile__recv_data_ack[7][2];
  assign tile__to_mem_raddr__rdy[6] = 1'd0;
  assign tile__from_mem_rdata__en[6] = 1'd0;
  assign tile__from_mem_rdata__msg[6] = { 64'd0, 1'd0 };
  assign tile__to_mem_waddr__rdy[6] = 1'd0;
  assign tile__to_mem_wdata__rdy[6] = 1'd0;
  assign tile__ctrl_slice_idx[7] = counter_config_cmd_slice;
  assign tile__recv_opt_waddr[7] = counter_config_cmd_addr;
  assign tile__recv_opt_waddr_en[7] = tile_recv_opt_waddr_en;
  assign tile__recv_wopt[7] = recv_wopt_sliced_flattened[255:224];
  assign tile__recv_wopt_en[7] = recv_wopt_sliced_flattened_en;
  assign tile__recv_const_waddr[7] = counter_config_data_addr;
  assign tile__recv_const[7] = recv_wconst_flattened[255:224];
  assign tile__recv_const_en[7] = recv_wconst_flattened_en;
  assign tile__recv_data[3][0] = tile__send_data[7][1];
  assign tile__recv_data_valid[3][0] = tile__send_data_valid[7][1];
  assign tile__send_data_ack[7][1] = tile__recv_data_ack[3][0];
  assign tile__recv_data[11][1] = tile__send_data[7][0];
  assign tile__recv_data_valid[11][1] = tile__send_data_valid[7][0];
  assign tile__send_data_ack[7][0] = tile__recv_data_ack[11][1];
  assign tile__recv_data[6][3] = tile__send_data[7][2];
  assign tile__recv_data_valid[6][3] = tile__send_data_valid[7][2];
  assign tile__send_data_ack[7][2] = tile__recv_data_ack[6][3];
  assign tile__send_data_ack[7][3] = cgra_send_ni_data__rdy[1];
  assign cgra_send_ni_data__en[1] = tile__send_data_valid[7][3];
  assign cgra_send_ni_data__msg[1] = tile__send_data[7][3].payload;
  assign tile__recv_data_valid[7][3] = 1'd0;
  assign tile__recv_data[7][3] = { 64'd0, 1'd0 };
  assign tile__to_mem_raddr__rdy[7] = 1'd0;
  assign tile__from_mem_rdata__en[7] = 1'd0;
  assign tile__from_mem_rdata__msg[7] = { 64'd0, 1'd0 };
  assign tile__to_mem_waddr__rdy[7] = 1'd0;
  assign tile__to_mem_wdata__rdy[7] = 1'd0;
  assign tile__ctrl_slice_idx[8] = counter_config_cmd_slice;
  assign tile__recv_opt_waddr[8] = counter_config_cmd_addr;
  assign tile__recv_opt_waddr_en[8] = tile_recv_opt_waddr_en;
  assign tile__recv_wopt[8] = recv_wopt_sliced_flattened[287:256];
  assign tile__recv_wopt_en[8] = recv_wopt_sliced_flattened_en;
  assign tile__recv_const_waddr[8] = counter_config_data_addr;
  assign tile__recv_const[8] = recv_wconst_flattened[287:256];
  assign tile__recv_const_en[8] = recv_wconst_flattened_en;
  assign tile__recv_data[4][0] = tile__send_data[8][1];
  assign tile__recv_data_valid[4][0] = tile__send_data_valid[8][1];
  assign tile__send_data_ack[8][1] = tile__recv_data_ack[4][0];
  assign tile__recv_data[12][1] = tile__send_data[8][0];
  assign tile__recv_data_valid[12][1] = tile__send_data_valid[8][0];
  assign tile__send_data_ack[8][0] = tile__recv_data_ack[12][1];
  assign tile__recv_data[9][2] = tile__send_data[8][3];
  assign tile__recv_data_valid[9][2] = tile__send_data_valid[8][3];
  assign tile__send_data_ack[8][3] = tile__recv_data_ack[9][2];
  assign tile__send_data_ack[8][2] = 1'd0;
  assign tile_recv_ni_data_ack[2:2] = tile__recv_data_ack[8][2];
  assign tile__recv_data_valid[8][2] = cgra_recv_ni_data__en[2];
  assign tile__recv_data[8][2].payload = cgra_recv_ni_data__msg[2];
  assign tile__recv_data[8][2].predicate = 1'd0;
  assign tile__to_mem_raddr__rdy[8] = 1'd0;
  assign tile__from_mem_rdata__en[8] = 1'd0;
  assign tile__from_mem_rdata__msg[8] = { 64'd0, 1'd0 };
  assign tile__to_mem_waddr__rdy[8] = 1'd0;
  assign tile__to_mem_wdata__rdy[8] = 1'd0;
  assign tile__ctrl_slice_idx[9] = counter_config_cmd_slice;
  assign tile__recv_opt_waddr[9] = counter_config_cmd_addr;
  assign tile__recv_opt_waddr_en[9] = tile_recv_opt_waddr_en;
  assign tile__recv_wopt[9] = recv_wopt_sliced_flattened[319:288];
  assign tile__recv_wopt_en[9] = recv_wopt_sliced_flattened_en;
  assign tile__recv_const_waddr[9] = counter_config_data_addr;
  assign tile__recv_const[9] = recv_wconst_flattened[319:288];
  assign tile__recv_const_en[9] = recv_wconst_flattened_en;
  assign tile__recv_data[5][0] = tile__send_data[9][1];
  assign tile__recv_data_valid[5][0] = tile__send_data_valid[9][1];
  assign tile__send_data_ack[9][1] = tile__recv_data_ack[5][0];
  assign tile__recv_data[13][1] = tile__send_data[9][0];
  assign tile__recv_data_valid[13][1] = tile__send_data_valid[9][0];
  assign tile__send_data_ack[9][0] = tile__recv_data_ack[13][1];
  assign tile__recv_data[8][3] = tile__send_data[9][2];
  assign tile__recv_data_valid[8][3] = tile__send_data_valid[9][2];
  assign tile__send_data_ack[9][2] = tile__recv_data_ack[8][3];
  assign tile__recv_data[10][2] = tile__send_data[9][3];
  assign tile__recv_data_valid[10][2] = tile__send_data_valid[9][3];
  assign tile__send_data_ack[9][3] = tile__recv_data_ack[10][2];
  assign tile__to_mem_raddr__rdy[9] = 1'd0;
  assign tile__from_mem_rdata__en[9] = 1'd0;
  assign tile__from_mem_rdata__msg[9] = { 64'd0, 1'd0 };
  assign tile__to_mem_waddr__rdy[9] = 1'd0;
  assign tile__to_mem_wdata__rdy[9] = 1'd0;
  assign tile__ctrl_slice_idx[10] = counter_config_cmd_slice;
  assign tile__recv_opt_waddr[10] = counter_config_cmd_addr;
  assign tile__recv_opt_waddr_en[10] = tile_recv_opt_waddr_en;
  assign tile__recv_wopt[10] = recv_wopt_sliced_flattened[351:320];
  assign tile__recv_wopt_en[10] = recv_wopt_sliced_flattened_en;
  assign tile__recv_const_waddr[10] = counter_config_data_addr;
  assign tile__recv_const[10] = recv_wconst_flattened[351:320];
  assign tile__recv_const_en[10] = recv_wconst_flattened_en;
  assign tile__recv_data[6][0] = tile__send_data[10][1];
  assign tile__recv_data_valid[6][0] = tile__send_data_valid[10][1];
  assign tile__send_data_ack[10][1] = tile__recv_data_ack[6][0];
  assign tile__recv_data[14][1] = tile__send_data[10][0];
  assign tile__recv_data_valid[14][1] = tile__send_data_valid[10][0];
  assign tile__send_data_ack[10][0] = tile__recv_data_ack[14][1];
  assign tile__recv_data[9][3] = tile__send_data[10][2];
  assign tile__recv_data_valid[9][3] = tile__send_data_valid[10][2];
  assign tile__send_data_ack[10][2] = tile__recv_data_ack[9][3];
  assign tile__recv_data[11][2] = tile__send_data[10][3];
  assign tile__recv_data_valid[11][2] = tile__send_data_valid[10][3];
  assign tile__send_data_ack[10][3] = tile__recv_data_ack[11][2];
  assign tile__to_mem_raddr__rdy[10] = 1'd0;
  assign tile__from_mem_rdata__en[10] = 1'd0;
  assign tile__from_mem_rdata__msg[10] = { 64'd0, 1'd0 };
  assign tile__to_mem_waddr__rdy[10] = 1'd0;
  assign tile__to_mem_wdata__rdy[10] = 1'd0;
  assign tile__ctrl_slice_idx[11] = counter_config_cmd_slice;
  assign tile__recv_opt_waddr[11] = counter_config_cmd_addr;
  assign tile__recv_opt_waddr_en[11] = tile_recv_opt_waddr_en;
  assign tile__recv_wopt[11] = recv_wopt_sliced_flattened[383:352];
  assign tile__recv_wopt_en[11] = recv_wopt_sliced_flattened_en;
  assign tile__recv_const_waddr[11] = counter_config_data_addr;
  assign tile__recv_const[11] = recv_wconst_flattened[383:352];
  assign tile__recv_const_en[11] = recv_wconst_flattened_en;
  assign tile__recv_data[7][0] = tile__send_data[11][1];
  assign tile__recv_data_valid[7][0] = tile__send_data_valid[11][1];
  assign tile__send_data_ack[11][1] = tile__recv_data_ack[7][0];
  assign tile__recv_data[15][1] = tile__send_data[11][0];
  assign tile__recv_data_valid[15][1] = tile__send_data_valid[11][0];
  assign tile__send_data_ack[11][0] = tile__recv_data_ack[15][1];
  assign tile__recv_data[10][3] = tile__send_data[11][2];
  assign tile__recv_data_valid[10][3] = tile__send_data_valid[11][2];
  assign tile__send_data_ack[11][2] = tile__recv_data_ack[10][3];
  assign tile__send_data_ack[11][3] = cgra_send_ni_data__rdy[2];
  assign cgra_send_ni_data__en[2] = tile__send_data_valid[11][3];
  assign cgra_send_ni_data__msg[2] = tile__send_data[11][3].payload;
  assign tile__recv_data_valid[11][3] = 1'd0;
  assign tile__recv_data[11][3] = { 64'd0, 1'd0 };
  assign tile__to_mem_raddr__rdy[11] = 1'd0;
  assign tile__from_mem_rdata__en[11] = 1'd0;
  assign tile__from_mem_rdata__msg[11] = { 64'd0, 1'd0 };
  assign tile__to_mem_waddr__rdy[11] = 1'd0;
  assign tile__to_mem_wdata__rdy[11] = 1'd0;
  assign tile__ctrl_slice_idx[12] = counter_config_cmd_slice;
  assign tile__recv_opt_waddr[12] = counter_config_cmd_addr;
  assign tile__recv_opt_waddr_en[12] = tile_recv_opt_waddr_en;
  assign tile__recv_wopt[12] = recv_wopt_sliced_flattened[415:384];
  assign tile__recv_wopt_en[12] = recv_wopt_sliced_flattened_en;
  assign tile__recv_const_waddr[12] = counter_config_data_addr;
  assign tile__recv_const[12] = recv_wconst_flattened[415:384];
  assign tile__recv_const_en[12] = recv_wconst_flattened_en;
  assign tile__recv_data[8][0] = tile__send_data[12][1];
  assign tile__recv_data_valid[8][0] = tile__send_data_valid[12][1];
  assign tile__send_data_ack[12][1] = tile__recv_data_ack[8][0];
  assign tile__recv_data[13][2] = tile__send_data[12][3];
  assign tile__recv_data_valid[13][2] = tile__send_data_valid[12][3];
  assign tile__send_data_ack[12][3] = tile__recv_data_ack[13][2];
  assign tile__send_data_ack[12][0] = 1'd0;
  assign tile_recv_ni_data_ack[4:4] = tile__recv_data_ack[12][0];
  assign tile__recv_data_valid[12][0] = cgra_recv_ni_data__en[4];
  assign tile__recv_data[12][0].payload = cgra_recv_ni_data__msg[4];
  assign tile__recv_data[12][0].predicate = 1'd0;
  assign tile__send_data_ack[12][2] = 1'd0;
  assign tile_recv_ni_data_ack[3:3] = tile__recv_data_ack[12][2];
  assign tile__recv_data_valid[12][2] = cgra_recv_ni_data__en[3];
  assign tile__recv_data[12][2].payload = cgra_recv_ni_data__msg[3];
  assign tile__recv_data[12][2].predicate = 1'd0;
  assign tile__to_mem_raddr__rdy[12] = 1'd0;
  assign tile__from_mem_rdata__en[12] = 1'd0;
  assign tile__from_mem_rdata__msg[12] = { 64'd0, 1'd0 };
  assign tile__to_mem_waddr__rdy[12] = 1'd0;
  assign tile__to_mem_wdata__rdy[12] = 1'd0;
  assign tile__ctrl_slice_idx[13] = counter_config_cmd_slice;
  assign tile__recv_opt_waddr[13] = counter_config_cmd_addr;
  assign tile__recv_opt_waddr_en[13] = tile_recv_opt_waddr_en;
  assign tile__recv_wopt[13] = recv_wopt_sliced_flattened[447:416];
  assign tile__recv_wopt_en[13] = recv_wopt_sliced_flattened_en;
  assign tile__recv_const_waddr[13] = counter_config_data_addr;
  assign tile__recv_const[13] = recv_wconst_flattened[447:416];
  assign tile__recv_const_en[13] = recv_wconst_flattened_en;
  assign tile__recv_data[9][0] = tile__send_data[13][1];
  assign tile__recv_data_valid[9][0] = tile__send_data_valid[13][1];
  assign tile__send_data_ack[13][1] = tile__recv_data_ack[9][0];
  assign tile__recv_data[12][3] = tile__send_data[13][2];
  assign tile__recv_data_valid[12][3] = tile__send_data_valid[13][2];
  assign tile__send_data_ack[13][2] = tile__recv_data_ack[12][3];
  assign tile__recv_data[14][2] = tile__send_data[13][3];
  assign tile__recv_data_valid[14][2] = tile__send_data_valid[13][3];
  assign tile__send_data_ack[13][3] = tile__recv_data_ack[14][2];
  assign tile__send_data_ack[13][0] = 1'd0;
  assign tile_recv_ni_data_ack[5:5] = tile__recv_data_ack[13][0];
  assign tile__recv_data_valid[13][0] = cgra_recv_ni_data__en[5];
  assign tile__recv_data[13][0].payload = cgra_recv_ni_data__msg[5];
  assign tile__recv_data[13][0].predicate = 1'd0;
  assign tile__to_mem_raddr__rdy[13] = 1'd0;
  assign tile__from_mem_rdata__en[13] = 1'd0;
  assign tile__from_mem_rdata__msg[13] = { 64'd0, 1'd0 };
  assign tile__to_mem_waddr__rdy[13] = 1'd0;
  assign tile__to_mem_wdata__rdy[13] = 1'd0;
  assign tile__ctrl_slice_idx[14] = counter_config_cmd_slice;
  assign tile__recv_opt_waddr[14] = counter_config_cmd_addr;
  assign tile__recv_opt_waddr_en[14] = tile_recv_opt_waddr_en;
  assign tile__recv_wopt[14] = recv_wopt_sliced_flattened[479:448];
  assign tile__recv_wopt_en[14] = recv_wopt_sliced_flattened_en;
  assign tile__recv_const_waddr[14] = counter_config_data_addr;
  assign tile__recv_const[14] = recv_wconst_flattened[479:448];
  assign tile__recv_const_en[14] = recv_wconst_flattened_en;
  assign tile__recv_data[10][0] = tile__send_data[14][1];
  assign tile__recv_data_valid[10][0] = tile__send_data_valid[14][1];
  assign tile__send_data_ack[14][1] = tile__recv_data_ack[10][0];
  assign tile__recv_data[13][3] = tile__send_data[14][2];
  assign tile__recv_data_valid[13][3] = tile__send_data_valid[14][2];
  assign tile__send_data_ack[14][2] = tile__recv_data_ack[13][3];
  assign tile__recv_data[15][2] = tile__send_data[14][3];
  assign tile__recv_data_valid[15][2] = tile__send_data_valid[14][3];
  assign tile__send_data_ack[14][3] = tile__recv_data_ack[15][2];
  assign tile__send_data_ack[14][0] = 1'd0;
  assign tile_recv_ni_data_ack[6:6] = tile__recv_data_ack[14][0];
  assign tile__recv_data_valid[14][0] = cgra_recv_ni_data__en[6];
  assign tile__recv_data[14][0].payload = cgra_recv_ni_data__msg[6];
  assign tile__recv_data[14][0].predicate = 1'd0;
  assign tile__to_mem_raddr__rdy[14] = 1'd0;
  assign tile__from_mem_rdata__en[14] = 1'd0;
  assign tile__from_mem_rdata__msg[14] = { 64'd0, 1'd0 };
  assign tile__to_mem_waddr__rdy[14] = 1'd0;
  assign tile__to_mem_wdata__rdy[14] = 1'd0;
  assign tile__ctrl_slice_idx[15] = counter_config_cmd_slice;
  assign tile__recv_opt_waddr[15] = counter_config_cmd_addr;
  assign tile__recv_opt_waddr_en[15] = tile_recv_opt_waddr_en;
  assign tile__recv_wopt[15] = recv_wopt_sliced_flattened[511:480];
  assign tile__recv_wopt_en[15] = recv_wopt_sliced_flattened_en;
  assign tile__recv_const_waddr[15] = counter_config_data_addr;
  assign tile__recv_const[15] = recv_wconst_flattened[511:480];
  assign tile__recv_const_en[15] = recv_wconst_flattened_en;
  assign tile__recv_data[11][0] = tile__send_data[15][1];
  assign tile__recv_data_valid[11][0] = tile__send_data_valid[15][1];
  assign tile__send_data_ack[15][1] = tile__recv_data_ack[11][0];
  assign tile__recv_data[14][3] = tile__send_data[15][2];
  assign tile__recv_data_valid[14][3] = tile__send_data_valid[15][2];
  assign tile__send_data_ack[15][2] = tile__recv_data_ack[14][3];
  assign tile__send_data_ack[15][0] = 1'd0;
  assign tile_recv_ni_data_ack[7:7] = tile__recv_data_ack[15][0];
  assign tile__recv_data_valid[15][0] = cgra_recv_ni_data__en[7];
  assign tile__recv_data[15][0].payload = cgra_recv_ni_data__msg[7];
  assign tile__recv_data[15][0].predicate = 1'd0;
  assign tile__send_data_ack[15][3] = cgra_send_ni_data__rdy[3];
  assign cgra_send_ni_data__en[3] = tile__send_data_valid[15][3];
  assign cgra_send_ni_data__msg[3] = tile__send_data[15][3].payload;
  assign tile__recv_data_valid[15][3] = 1'd0;
  assign tile__recv_data[15][3] = { 64'd0, 1'd0 };
  assign tile__to_mem_raddr__rdy[15] = 1'd0;
  assign tile__from_mem_rdata__en[15] = 1'd0;
  assign tile__from_mem_rdata__msg[15] = { 64'd0, 1'd0 };
  assign tile__to_mem_waddr__rdy[15] = 1'd0;
  assign tile__to_mem_wdata__rdy[15] = 1'd0;
  assign tile_xbar_propagate_rdy_vector[0:0] = tile__tile_xbar_propagate_rdy[0];
  assign tile_fu_propagate_rdy_vector[0:0] = tile__tile_fu_propagate_rdy[0];
  assign tile_xbar_propagate_rdy_vector[1:1] = tile__tile_xbar_propagate_rdy[1];
  assign tile_fu_propagate_rdy_vector[1:1] = tile__tile_fu_propagate_rdy[1];
  assign tile_xbar_propagate_rdy_vector[2:2] = tile__tile_xbar_propagate_rdy[2];
  assign tile_fu_propagate_rdy_vector[2:2] = tile__tile_fu_propagate_rdy[2];
  assign tile_xbar_propagate_rdy_vector[3:3] = tile__tile_xbar_propagate_rdy[3];
  assign tile_fu_propagate_rdy_vector[3:3] = tile__tile_fu_propagate_rdy[3];
  assign tile_xbar_propagate_rdy_vector[4:4] = tile__tile_xbar_propagate_rdy[4];
  assign tile_fu_propagate_rdy_vector[4:4] = tile__tile_fu_propagate_rdy[4];
  assign tile_xbar_propagate_rdy_vector[5:5] = tile__tile_xbar_propagate_rdy[5];
  assign tile_fu_propagate_rdy_vector[5:5] = tile__tile_fu_propagate_rdy[5];
  assign tile_xbar_propagate_rdy_vector[6:6] = tile__tile_xbar_propagate_rdy[6];
  assign tile_fu_propagate_rdy_vector[6:6] = tile__tile_fu_propagate_rdy[6];
  assign tile_xbar_propagate_rdy_vector[7:7] = tile__tile_xbar_propagate_rdy[7];
  assign tile_fu_propagate_rdy_vector[7:7] = tile__tile_fu_propagate_rdy[7];
  assign tile_xbar_propagate_rdy_vector[8:8] = tile__tile_xbar_propagate_rdy[8];
  assign tile_fu_propagate_rdy_vector[8:8] = tile__tile_fu_propagate_rdy[8];
  assign tile_xbar_propagate_rdy_vector[9:9] = tile__tile_xbar_propagate_rdy[9];
  assign tile_fu_propagate_rdy_vector[9:9] = tile__tile_fu_propagate_rdy[9];
  assign tile_xbar_propagate_rdy_vector[10:10] = tile__tile_xbar_propagate_rdy[10];
  assign tile_fu_propagate_rdy_vector[10:10] = tile__tile_fu_propagate_rdy[10];
  assign tile_xbar_propagate_rdy_vector[11:11] = tile__tile_xbar_propagate_rdy[11];
  assign tile_fu_propagate_rdy_vector[11:11] = tile__tile_fu_propagate_rdy[11];
  assign tile_xbar_propagate_rdy_vector[12:12] = tile__tile_xbar_propagate_rdy[12];
  assign tile_fu_propagate_rdy_vector[12:12] = tile__tile_fu_propagate_rdy[12];
  assign tile_xbar_propagate_rdy_vector[13:13] = tile__tile_xbar_propagate_rdy[13];
  assign tile_fu_propagate_rdy_vector[13:13] = tile__tile_fu_propagate_rdy[13];
  assign tile_xbar_propagate_rdy_vector[14:14] = tile__tile_xbar_propagate_rdy[14];
  assign tile_fu_propagate_rdy_vector[14:14] = tile__tile_fu_propagate_rdy[14];
  assign tile_xbar_propagate_rdy_vector[15:15] = tile__tile_xbar_propagate_rdy[15];
  assign tile_fu_propagate_rdy_vector[15:15] = tile__tile_fu_propagate_rdy[15];

endmodule
