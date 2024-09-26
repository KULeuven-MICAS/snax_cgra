
typedef struct packed {
  logic [63:0] payload;
  logic [7:0] predicate;
} CGRAData_64_8__payload_64__predicate_8;

typedef struct packed {
  logic [8:0] ctrl;
  logic [0:0] predicate;
  logic [3:0][2:0] fu_in;
  logic [7:0][2:0] outport;
  logic [5:0][0:0] predicate_in;
  logic [1:0] out_routine;
  logic [1:0] vec_mode;
  logic [1:0] signed_mode;
  logic [4:0] bmask;
} CGRAConfig_9_4_6_8_2__cebbeedc2b62cdce;

typedef struct packed {
  logic [7:0] predicate;
} CGRAData_8__predicate_8;


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



module NormalQueueDpath__7f3406ec6084c93f
(
  input  logic [0:0] clk ,
  input  logic [0:0] config_ini ,
  output CGRAData_64_8__payload_64__predicate_8 deq_msg ,
  input  CGRAData_64_8__payload_64__predicate_8 enq_msg ,
  input  logic [0:0] raddr ,
  input  logic [0:0] ren ,
  input  logic [0:0] reset ,
  input  logic [0:0] waddr ,
  input  logic [0:0] wen 
);
  localparam logic [1:0] __const__num_entries_at_up_rf_write  = 2'd2;
  CGRAData_64_8__payload_64__predicate_8 regs [0:1];
  CGRAData_64_8__payload_64__predicate_8 regs_rdata;

  
  always_comb begin : reg_read
    if ( reset ) begin
      deq_msg = { 64'd0, 8'd0 };
    end
    else
      deq_msg = regs[raddr];
  end

  
  always_ff @(posedge clk) begin : up_rf_write
    if ( reset | config_ini ) begin
      for ( int unsigned i = 1'd0; i < 2'( __const__num_entries_at_up_rf_write ); i += 1'd1 )
        regs[1'(i)] <= { 64'd0, 8'd0 };
    end
    else if ( wen ) begin
      regs[waddr] <= enq_msg;
    end
  end

endmodule



module NormalQueue__8b984c0a30829017
(
  input  logic [0:0] clk ,
  input  logic [0:0] config_ini ,
  input  logic [0:0] deq_en ,
  output CGRAData_64_8__payload_64__predicate_8 deq_msg ,
  output logic [0:0] deq_valid ,
  input  logic [0:0] dry_run_done ,
  input  logic [0:0] enq_en ,
  input  CGRAData_64_8__payload_64__predicate_8 enq_msg ,
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
  CGRAData_64_8__payload_64__predicate_8 dpath__deq_msg;
  CGRAData_64_8__payload_64__predicate_8 dpath__enq_msg;
  logic [0:0] dpath__raddr;
  logic [0:0] dpath__ren;
  logic [0:0] dpath__reset;
  logic [0:0] dpath__waddr;
  logic [0:0] dpath__wen;

  NormalQueueDpath__7f3406ec6084c93f dpath
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



module ChannelRTL__719f99a07587cea0
(
  input  logic [0:0] clk ,
  input  logic [0:0] config_ini ,
  input  logic [0:0] dry_run_done ,
  input  logic [0:0] recv_en ,
  input  CGRAData_64_8__payload_64__predicate_8 recv_msg ,
  output logic [0:0] recv_rdy ,
  input  logic [0:0] reset ,
  input  logic [0:0] send_en ,
  output CGRAData_64_8__payload_64__predicate_8 send_msg ,
  output logic [0:0] send_valid ,
  input  logic [0:0] sync_dry_run 
);

  logic [0:0] queue__clk;
  logic [0:0] queue__config_ini;
  logic [0:0] queue__deq_en;
  CGRAData_64_8__payload_64__predicate_8 queue__deq_msg;
  logic [0:0] queue__deq_valid;
  logic [0:0] queue__dry_run_done;
  logic [0:0] queue__enq_en;
  CGRAData_64_8__payload_64__predicate_8 queue__enq_msg;
  logic [0:0] queue__enq_rdy;
  logic [0:0] queue__reset;
  logic [0:0] queue__sync_dry_run;

  NormalQueue__8b984c0a30829017 queue
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



module ConstQueueRTL__93536ce3c6007a21
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



  logic [0:0] reg_file_lut__clk;
  logic [4:0] reg_file_lut__raddr [0:0];
  logic [31:0] reg_file_lut__rdata [0:0];
  logic [0:0] reg_file_lut__reset;
  logic [4:0] reg_file_lut__waddr [0:0];
  logic [31:0] reg_file_lut__wdata [0:0];
  logic [0:0] reg_file_lut__wen [0:0];

  RegisterFile__8c50dafb5bf22f7b reg_file_lut
  (
    .clk( reg_file_lut__clk ),
    .raddr( reg_file_lut__raddr ),
    .rdata( reg_file_lut__rdata ),
    .reset( reg_file_lut__reset ),
    .waddr( reg_file_lut__waddr ),
    .wdata( reg_file_lut__wdata ),
    .wen( reg_file_lut__wen )
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
  assign reg_file_lut__clk = clk;
  assign reg_file_lut__reset = reset;
  assign reg_file_lut__waddr[0] = recv_const_waddr;
  assign reg_file_lut__wdata[0] = recv_const;
  assign reg_file_lut__wen[0] = recv_const_en;
  assign reg_file__raddr[0] = data_counter[4:0];
  assign send_const_msg = reg_file__rdata[0];

endmodule



module CrossbarRTL__735efd555417ee9b
(
  input  logic [0:0] clk ,
  input  logic [2:0] recv_opt_msg_outport [0:7],
  input  logic [5:0] recv_opt_msg_predicate_in ,
  input  CGRAData_64_8__payload_64__predicate_8 recv_port_data [0:5],
  output logic [0:0] recv_port_fu_out_ack ,
  output logic [3:0] recv_port_mesh_in_ack ,
  input  logic [5:0] recv_port_valid ,
  input  logic [0:0] reset ,
  output logic [3:0] send_bypass_data_valid ,
  input  logic [3:0] send_bypass_port_ack ,
  output logic [3:0] send_bypass_req ,
  output CGRAData_64_8__payload_64__predicate_8 send_data_bypass [0:3],
  output CGRAData_64_8__payload_64__predicate_8 send_port_data [0:7],
  output logic [8:0] send_port_en ,
  input  logic [7:0] send_port_rdy ,
  output CGRAData_8__predicate_8 send_predicate ,
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
      send_port_data[3'(i)] = { 64'd0, 8'd0 };
    for ( int unsigned i = 1'd0; i < 3'( __const__num_connect_inports_at_data_routing ); i += 1'd1 )
      send_data_bypass[2'(i)] = { 64'd0, 8'd0 };
    send_predicate = 8'd0;
    for ( int unsigned i = 1'd0; i < 3'( __const__num_connect_outports_at_data_routing ); i += 1'd1 ) begin
      for ( int unsigned j = 1'd0; j < 3'( __const__num_connect_inports_at_data_routing ); j += 1'd1 ) begin
        send_port_data[3'(i)].payload = send_port_data[3'(i)].payload | ( recv_port_data[3'(j)].payload & { { 63 { xbar_outport_sel[4'(i)][3'(j)] } }, xbar_outport_sel[4'(i)][3'(j)] } );
        send_port_data[3'(i)].predicate = send_port_data[3'(i)].predicate | ( recv_port_data[3'(j)].predicate & { { 7 { xbar_outport_sel[4'(i)][3'(j)] } }, xbar_outport_sel[4'(i)][3'(j)] } );
      end
      for ( int unsigned j = 3'( __const__num_connect_inports_at_data_routing ); j < 3'( __const__num_xbar_inports_at_data_routing ); j += 1'd1 ) begin
        send_data_bypass[2'(i)].payload = send_data_bypass[2'(i)].payload | ( recv_port_data[3'(j)].payload & { { 63 { xbar_outport_sel[4'(i)][3'(j)] } }, xbar_outport_sel[4'(i)][3'(j)] } );
        send_data_bypass[2'(i)].predicate = send_data_bypass[2'(i)].predicate | ( recv_port_data[3'(j)].predicate & { { 7 { xbar_outport_sel[4'(i)][3'(j)] } }, xbar_outport_sel[4'(i)][3'(j)] } );
      end
    end
    for ( int unsigned i = 3'( __const__num_connect_outports_at_data_routing ); i < 4'( __const__num_xbar_outports_at_data_routing ); i += 1'd1 )
      for ( int unsigned j = 1'd0; j < 3'( __const__num_xbar_inports_at_data_routing ); j += 1'd1 ) begin
        send_port_data[3'(i)].payload = send_port_data[3'(i)].payload | ( recv_port_data[3'(j)].payload & { { 63 { xbar_outport_sel[4'(i)][3'(j)] } }, xbar_outport_sel[4'(i)][3'(j)] } );
        send_port_data[3'(i)].predicate = send_port_data[3'(i)].predicate | ( recv_port_data[3'(j)].predicate & { { 7 { xbar_outport_sel[4'(i)][3'(j)] } }, xbar_outport_sel[4'(i)][3'(j)] } );
      end
    for ( int unsigned i = 1'd0; i < 3'( __const__num_xbar_inports_at_data_routing ); i += 1'd1 )
      send_predicate.predicate = send_predicate.predicate | ( recv_port_data[3'(i)].predicate & { { 7 { xbar_outport_sel[4'( __const__num_xbar_outports_at_data_routing )][3'(i)] } }, xbar_outport_sel[4'( __const__num_xbar_outports_at_data_routing )][3'(i)] } );
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



module RegisterFile__461320654393e206
(
  input  logic [0:0] clk ,
  input  logic [4:0] raddr [0:0],
  output CGRAConfig_9_4_6_8_2__cebbeedc2b62cdce rdata [0:0],
  input  logic [0:0] reset ,
  input  logic [4:0] waddr [0:0],
  input  CGRAConfig_9_4_6_8_2__cebbeedc2b62cdce wdata [0:0],
  input  logic [0:0] wen [0:0]
);
  localparam logic [0:0] __const__rd_ports_at_up_rf_read  = 1'd1;
  localparam logic [0:0] __const__wr_ports_at_up_rf_write  = 1'd1;
  CGRAConfig_9_4_6_8_2__cebbeedc2b62cdce regs [0:31];

  
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



module CtrlMemRTL__7aace320cc2a8fb7
(
  input  logic [0:0] clk ,
  input  logic [5:0] cmd_counter_th ,
  input  logic [0:0] execution_ini ,
  input  logic [0:0] nxt_ctrl_en ,
  output CGRAConfig_9_4_6_8_2__cebbeedc2b62cdce recv_ctrl_msg ,
  input  logic [31:0] recv_ctrl_slice ,
  input  logic [0:0] recv_ctrl_slice_en ,
  input  logic [0:0] recv_ctrl_slice_idx ,
  input  logic [4:0] recv_waddr ,
  input  logic [0:0] recv_waddr_en ,
  input  logic [0:0] reset ,
  output CGRAConfig_9_4_6_8_2__cebbeedc2b62cdce send_ctrl_msg 
);
  localparam logic [1:0] __const__num_opt_slice_at_buffer_opt_slice  = 2'd2;
  logic [5:0] cmd_counter;
  logic [63:0] concat_ctrl_msg;
  logic [31:0] opt_slice_regs [0:1];

  logic [0:0] reg_file__clk;
  logic [4:0] reg_file__raddr [0:0];
  CGRAConfig_9_4_6_8_2__cebbeedc2b62cdce reg_file__rdata [0:0];
  logic [0:0] reg_file__reset;
  logic [4:0] reg_file__waddr [0:0];
  CGRAConfig_9_4_6_8_2__cebbeedc2b62cdce reg_file__wdata [0:0];
  logic [0:0] reg_file__wen [0:0];

  RegisterFile__461320654393e206 reg_file
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
  assign recv_ctrl_msg = concat_ctrl_msg[62:0];
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





`ifndef CV32E40P_ALU
`define CV32E40P_ALU







module cv32e40p_alu_nodiv #(
  parameter ALU_OP_WIDTH = 7
)
(
    input logic               clk,
    input logic               reset,
    input logic               enable_i,
    input logic [ALU_OP_WIDTH-1:0] operator_i,
    input logic        [31:0] operand_a_i,
    input logic        [31:0] operand_b_i,

    input logic [1:0] vector_mode_i,
    input logic [4:0] bmask_b_i,

    input logic       is_clpx_i,
    input logic       is_subrot_i,
    input logic [1:0] clpx_shift_i,

    output logic [31:0] result_o,

    output logic out_ready_o,
    output logic ex_ready_o,
    input  logic ex_ready_i
);

  localparam ALU_ADD   = 7'b0011000;
  localparam ALU_SUB   = 7'b0011001;
  localparam ALU_ADDU  = 7'b0011010;
  localparam ALU_SUBU  = 7'b0011011;
  localparam ALU_ADDR  = 7'b0011100;
  localparam ALU_SUBR  = 7'b0011101;
  localparam ALU_ADDUR = 7'b0011110;
  localparam ALU_SUBUR = 7'b0011111;

  localparam ALU_XOR = 7'b0101111;
  localparam ALU_OR  = 7'b0101110;
  localparam ALU_AND = 7'b0010101;

  localparam ALU_SRA = 7'b0100100;
  localparam ALU_SRL = 7'b0100101;
  localparam ALU_ROR = 7'b0100110;
  localparam ALU_SLL = 7'b0100111;

  localparam ALU_BEXT  = 7'b0101000;
  localparam ALU_BEXTU = 7'b0101001;
  localparam ALU_BINS  = 7'b0101010;
  localparam ALU_BCLR  = 7'b0101011;
  localparam ALU_BSET  = 7'b0101100;
  localparam ALU_BREV  = 7'b1001001;

  localparam ALU_FF1 = 7'b0110110;
  localparam ALU_FL1 = 7'b0110111;
  localparam ALU_CNT = 7'b0110100;
  localparam ALU_CLB = 7'b0110101;

  localparam ALU_EXTS = 7'b0111110;
  localparam ALU_EXT  = 7'b0111111;

  localparam ALU_LTS = 7'b0000000;
  localparam ALU_LTU = 7'b0000001;
  localparam ALU_LES = 7'b0000100;
  localparam ALU_LEU = 7'b0000101;
  localparam ALU_GTS = 7'b0001000;
  localparam ALU_GTU = 7'b0001001;
  localparam ALU_GES = 7'b0001010;
  localparam ALU_GEU = 7'b0001011;
  localparam ALU_EQ  = 7'b0001100;
  localparam ALU_NE  = 7'b0001101;

  localparam ALU_SLTS  = 7'b0000010;
  localparam ALU_SLTU  = 7'b0000011;
  localparam ALU_SLETS = 7'b0000110;
  localparam ALU_SLETU = 7'b0000111;

  localparam ALU_ABS   = 7'b0010100;
  localparam ALU_CLIP  = 7'b0010110;
  localparam ALU_CLIPU = 7'b0010111;

  localparam ALU_INS = 7'b0101101;

  localparam ALU_MIN  = 7'b0010000;
  localparam ALU_MINU = 7'b0010001;
  localparam ALU_MAX  = 7'b0010010;
  localparam ALU_MAXU = 7'b0010011;

  localparam ALU_DIVU = 7'b0110000;  // bit 0 is used for signed mode, bit 1 is used for remdiv
  localparam ALU_DIV  = 7'b0110001;  // bit 0 is used for signed mode, bit 1 is used for remdiv
  localparam ALU_REMU = 7'b0110010;  // bit 0 is used for signed mode, bit 1 is used for remdiv
  localparam ALU_REM  = 7'b0110011;  // bit 0 is used for signed mode, bit 1 is used for remdiv

  localparam ALU_SHUF  = 7'b0111010;
  localparam ALU_SHUF2 = 7'b0111011;
  localparam ALU_PCKLO = 7'b0111000;
  localparam ALU_PCKHI = 7'b0111001;

  localparam VEC_MODE32 = 2'b00;
  localparam VEC_MODE16 = 2'b10;
  localparam VEC_MODE8 = 2'b11;


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

  assign adder_round_result = adder_result;



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

  assign shift_amt = operand_b_i;

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





      ALU_MIN, ALU_MINU, ALU_MAX, ALU_MAXU: result_o = result_minmax;

      ALU_ABS: result_o = is_clpx_i ? {adder_result[31:16], operand_a_i[15:0]} : result_minmax;


      ALU_EQ, ALU_NE, ALU_GTU, ALU_GEU, ALU_LTU, ALU_LEU, ALU_GTS, ALU_GES, ALU_LTS, ALU_LES: begin
        result_o[31:24] = {8{cmp_result[3]}};
        result_o[23:16] = {8{cmp_result[2]}};
        result_o[15:8]  = {8{cmp_result[1]}};
        result_o[7:0]   = {8{cmp_result[0]}};
      end
      ALU_SLTS, ALU_SLTU, ALU_SLETS, ALU_SLETU: result_o = {31'b0, cmp_result[3]};



      default: ;  // default case to suppress unique warning
    endcase
  end

  assign out_ready_o = enable_i;
  assign ex_ready_o = ~out_ready_o | ex_ready_i;

endmodule

`endif /* CV32E40P_ALU */


`ifndef CV32E40P_ALU_NOPARAM
`define CV32E40P_ALU_NOPARAM

module CV32E40P_ALU_noparam
(
  input logic [5-1:0] bmask_b_i ,
  input logic [1-1:0] clk ,
  input logic [2-1:0] clpx_shift_i ,
  input logic [1-1:0] enable_i ,
  input logic [1-1:0] ex_ready_i ,
  output logic [1-1:0] ex_ready_o ,
  input logic [1-1:0] is_clpx_i ,
  input logic [1-1:0] is_subrot_i ,
  input logic [32-1:0] operand_a_i ,
  input logic [32-1:0] operand_b_i ,
  input logic [7-1:0] operator_i ,
  output logic [1-1:0] out_ready_o ,
  input logic [1-1:0] reset ,
  output logic [32-1:0] result_o ,
  input logic [2-1:0] vector_mode_i 
);
  cv32e40p_alu_nodiv
  #(
  ) v
  (
    .bmask_b_i( bmask_b_i ),
    .clk( clk ),
    .clpx_shift_i( clpx_shift_i ),
    .enable_i( enable_i ),
    .ex_ready_i( ex_ready_i ),
    .ex_ready_o( ex_ready_o ),
    .is_clpx_i( is_clpx_i ),
    .is_subrot_i( is_subrot_i ),
    .operand_a_i( operand_a_i ),
    .operand_b_i( operand_b_i ),
    .operator_i( operator_i ),
    .out_ready_o( out_ready_o ),
    .reset( reset ),
    .result_o( result_o ),
    .vector_mode_i( vector_mode_i )
  );
endmodule

`endif /* CV32E40P_ALU_NOPARAM */




module ALURTL__74c75ceffe42760d
(
  input  logic [4:0] bmask_b_i ,
  input  logic [0:0] clk ,
  input  logic [6:0] ex_operator_i ,
  input  logic [0:0] input_valid_i ,
  input  CGRAData_64_8__payload_64__predicate_8 operand_a_i ,
  input  CGRAData_64_8__payload_64__predicate_8 operand_b_i ,
  input  logic [0:0] opt_launch_en_i ,
  output logic [0:0] opt_launch_rdy_o ,
  input  logic [0:0] output_rdy_i ,
  input  logic [0:0] recv_predicate_en ,
  input  CGRAData_8__predicate_8 recv_predicate_msg ,
  input  logic [0:0] reset ,
  input  logic [1:0] vector_mode_i ,
  output logic [0:0] send_out__en [0:1] ,
  output CGRAData_64_8__payload_64__predicate_8 send_out__msg [0:1] ,
  input logic [0:0] send_out__rdy [0:1] 
);
  logic [0:0] alu_enable;
  logic [0:0] alu_ex_ready;
  logic [1:0] alu_ex_ready_o_vector;
  logic [1:0] alu_out_ready_o_vector;
  CGRAData_64_8__payload_64__predicate_8 result_o_vector;

  logic [4:0] alu_element_bmask_b_i [0:1];
  logic [0:0] alu_element_clk [0:1];
  logic [1:0] alu_element_clpx_shift_i [0:1];
  logic [0:0] alu_element_enable_i [0:1];
  logic [0:0] alu_element_ex_ready_i [0:1];
  logic [0:0] alu_element_ex_ready_o [0:1];
  logic [0:0] alu_element_is_clpx_i [0:1];
  logic [0:0] alu_element_is_subrot_i [0:1];
  logic [31:0] alu_element_operand_a_i [0:1];
  logic [31:0] alu_element_operand_b_i [0:1];
  logic [6:0] alu_element_operator_i [0:1];
  logic [0:0] alu_element_out_ready_o [0:1];
  logic [0:0] alu_element_reset [0:1];
  logic [31:0] alu_element_result_o [0:1];
  logic [1:0] alu_element_vector_mode_i [0:1];

  CV32E40P_ALU_noparam alu_element__0
  (
    .bmask_b_i( alu_element_bmask_b_i[0] ),
    .clk( alu_element_clk[0] ),
    .clpx_shift_i( alu_element_clpx_shift_i[0] ),
    .enable_i( alu_element_enable_i[0] ),
    .ex_ready_i( alu_element_ex_ready_i[0] ),
    .ex_ready_o( alu_element_ex_ready_o[0] ),
    .is_clpx_i( alu_element_is_clpx_i[0] ),
    .is_subrot_i( alu_element_is_subrot_i[0] ),
    .operand_a_i( alu_element_operand_a_i[0] ),
    .operand_b_i( alu_element_operand_b_i[0] ),
    .operator_i( alu_element_operator_i[0] ),
    .out_ready_o( alu_element_out_ready_o[0] ),
    .reset( alu_element_reset[0] ),
    .result_o( alu_element_result_o[0] ),
    .vector_mode_i( alu_element_vector_mode_i[0] )
  );

  CV32E40P_ALU_noparam alu_element__1
  (
    .bmask_b_i( alu_element_bmask_b_i[1] ),
    .clk( alu_element_clk[1] ),
    .clpx_shift_i( alu_element_clpx_shift_i[1] ),
    .enable_i( alu_element_enable_i[1] ),
    .ex_ready_i( alu_element_ex_ready_i[1] ),
    .ex_ready_o( alu_element_ex_ready_o[1] ),
    .is_clpx_i( alu_element_is_clpx_i[1] ),
    .is_subrot_i( alu_element_is_subrot_i[1] ),
    .operand_a_i( alu_element_operand_a_i[1] ),
    .operand_b_i( alu_element_operand_b_i[1] ),
    .operator_i( alu_element_operator_i[1] ),
    .out_ready_o( alu_element_out_ready_o[1] ),
    .reset( alu_element_reset[1] ),
    .result_o( alu_element_result_o[1] ),
    .vector_mode_i( alu_element_vector_mode_i[1] )
  );


  
  always_comb begin : _lambda__s_tile_0__element_fu_0_alu_enable
    alu_enable = opt_launch_en_i & input_valid_i;
  end

  
  always_comb begin : _lambda__s_tile_0__element_fu_0_opt_launch_rdy_o
    opt_launch_rdy_o = ( & alu_ex_ready_o_vector );
  end

  
  always_comb begin : _lambda__s_tile_0__element_fu_0_send_out_0__en
    send_out__en[1'd0] = ( & alu_out_ready_o_vector );
  end

  
  always_comb begin : predicate_handling
    result_o_vector.predicate = 8'd0;
    if ( alu_enable ) begin
      result_o_vector.predicate = ( operand_a_i.predicate & operand_b_i.predicate ) & ( { { 7 { ~recv_predicate_en[0] } }, ~recv_predicate_en } | recv_predicate_msg.predicate );
    end
  end

  assign alu_element_clk[0] = clk;
  assign alu_element_reset[0] = reset;
  assign alu_element_clk[1] = clk;
  assign alu_element_reset[1] = reset;
  assign alu_element_enable_i[0] = alu_enable;
  assign alu_element_operator_i[0] = ex_operator_i;
  assign alu_element_vector_mode_i[0] = vector_mode_i;
  assign alu_element_bmask_b_i[0] = bmask_b_i;
  assign alu_element_is_clpx_i[0] = 1'd0;
  assign alu_element_is_subrot_i[0] = 1'd0;
  assign alu_element_clpx_shift_i[0] = 2'd0;
  assign alu_ex_ready_o_vector[0:0] = alu_element_ex_ready_o[0];
  assign alu_out_ready_o_vector[0:0] = alu_element_out_ready_o[0];
  assign alu_element_operand_a_i[0] = operand_a_i.payload[31:0];
  assign alu_element_operand_b_i[0] = operand_b_i.payload[31:0];
  assign result_o_vector.payload[31:0] = alu_element_result_o[0];
  assign alu_element_ex_ready_i[0] = output_rdy_i;
  assign alu_element_enable_i[1] = alu_enable;
  assign alu_element_operator_i[1] = ex_operator_i;
  assign alu_element_vector_mode_i[1] = vector_mode_i;
  assign alu_element_bmask_b_i[1] = bmask_b_i;
  assign alu_element_is_clpx_i[1] = 1'd0;
  assign alu_element_is_subrot_i[1] = 1'd0;
  assign alu_element_clpx_shift_i[1] = 2'd0;
  assign alu_ex_ready_o_vector[1:1] = alu_element_ex_ready_o[1];
  assign alu_out_ready_o_vector[1:1] = alu_element_out_ready_o[1];
  assign alu_element_operand_a_i[1] = operand_a_i.payload[63:32];
  assign alu_element_operand_b_i[1] = operand_b_i.payload[63:32];
  assign result_o_vector.payload[63:32] = alu_element_result_o[1];
  assign alu_element_ex_ready_i[1] = output_rdy_i;
  assign send_out__msg[0] = result_o_vector;
  assign send_out__msg[1] = { 64'd0, 8'd0 };
  assign send_out__en[1] = 1'd0;

endmodule





`ifndef CV32E40P_MUL
`define CV32E40P_MUL







typedef enum logic [2:0] {
    IDLE_MULT,
    STEP0,
    STEP1,
    STEP2,
    FINISH
  } mult_state_e;

module cv32e40p_mult 
(
    input logic clk,
    input logic reset,

    input logic        enable_i,
    input logic [3:0] operator_i,

    input logic       short_subword_i,
    input logic [1:0] short_signed_i,

    input logic [31:0] op_a_i,
    input logic [31:0] op_b_i,
    input logic [31:0] op_c_i,

    input logic [4:0] r_imm_i,
    input logic [4:0] imm_i,

    input logic [ 1:0] dot_signed_i,
    input logic [31:0] dot_op_a_i,
    input logic [31:0] dot_op_b_i,
    input logic [31:0] dot_op_c_i,
    input logic        is_clpx_i,
    input logic [ 1:0] clpx_shift_i,
    input logic        clpx_img_i,

    output logic [31:0] result_o,

    output logic multicycle_o,
    output logic mulh_active_o,
    input  logic ex_ready_i,
    output logic out_ready_o,
    output logic ex_ready_o
);

  localparam MUL_MAC32 = 4'b0000; // for basic mul, it is op_c_i == 0;
  localparam MUL_MSU32 = 4'b0001;
  localparam MUL_I     = 4'b0010;
  localparam MUL_IR    = 4'b0011; // the only rounding;
  localparam MUL_DOT8  = 4'b0100;
  localparam MUL_DOT16 = 4'b0101;
  localparam MUL_H     = 4'b0110;
  
  localparam MUL_MAC8  = 4'b1100;
  localparam MUL_MAC16 = 4'b1101;
  localparam MUL_DOT32 = 4'b1110;


  logic [16:0] short_op_a;
  logic [16:0] short_op_b;
  logic [32:0] short_op_c;
  logic [33:0] short_mul;
  logic [33:0] short_mac;
  logic [31:0] round_tmp;
  logic [31:0] int_round;
  logic [33:0] short_result;

  logic        short_mac_msb1;
  logic        short_mac_msb0;

  logic [ 4:0] short_imm;
  logic [ 1:0] short_subword;
  logic [ 1:0] short_signed;
  logic        short_shift_arith;
  logic [ 4:0] mulh_imm;
  logic [ 1:0] mulh_subword;
  logic [ 1:0] mulh_signed;
  logic        mulh_shift_arith;
  logic        mulh_carry_q;
  logic        mulh_save;
  logic        mulh_clearcarry;
  logic        mulh_ready;

  mult_state_e mulh_CS, mulh_NS;

  assign round_tmp = (r_imm_i == '0)? '0: (32'h00000001) << r_imm_i;
  assign int_round = {1'b0, round_tmp[31:1]};

  assign short_op_a[15:0] = short_subword[0] ? op_a_i[31:16] : op_a_i[15:0];
  assign short_op_b[15:0] = short_subword[1] ? op_b_i[31:16] : op_b_i[15:0];

  assign short_op_a[16] = short_signed[0] & short_op_a[15];
  assign short_op_b[16] = short_signed[1] & short_op_b[15];

  assign short_op_c = mulh_active_o ? $signed({mulh_carry_q, op_c_i}) : $signed(op_c_i);

  assign short_mul = $signed(short_op_a) * $signed(short_op_b);
  assign short_mac = $signed(short_op_c) + $signed(short_mul) + $signed(int_round);

  assign short_result = $signed(
      {short_shift_arith & short_mac_msb1, short_shift_arith & short_mac_msb0, short_mac[31:0]}
  ) >>> short_imm;

  assign short_imm = mulh_active_o ? mulh_imm : imm_i;
  assign short_subword = mulh_active_o ? mulh_subword : {2{short_subword_i}};
  assign short_signed = mulh_active_o ? mulh_signed : short_signed_i;
  assign short_shift_arith = mulh_active_o ? mulh_shift_arith : short_signed_i[0];

  assign short_mac_msb1 = mulh_active_o ? short_mac[33] : short_mac[31];
  assign short_mac_msb0 = mulh_active_o ? short_mac[32] : short_mac[31];


  always_comb begin
    mulh_NS          = mulh_CS;
    mulh_imm         = 5'd0;
    mulh_subword     = 2'b00;
    mulh_signed      = 2'b00;
    mulh_shift_arith = 1'b0;
    mulh_ready       = 1'b0;
    mulh_active_o    = 1'b1;
    mulh_save        = 1'b0;
    mulh_clearcarry  = 1'b0;
    multicycle_o     = 1'b0;

    out_ready_o      = 1'b0;

    case (mulh_CS)
      IDLE_MULT: begin
        mulh_active_o = 1'b0;
        mulh_ready    = 1'b1;
        mulh_save     = 1'b0;
        if ((operator_i == MUL_H) && enable_i) begin
          mulh_ready = 1'b0;
          mulh_NS    = STEP0;
        end
        out_ready_o  = (operator_i != MUL_H) && enable_i;
      end

      STEP0: begin
        multicycle_o  = 1'b1;
        mulh_imm      = 5'd16;
        mulh_active_o = 1'b1;
        mulh_save     = 1'b0;
        mulh_NS       = STEP1;
      end

      STEP1: begin
        multicycle_o     = 1'b1;
        mulh_signed      = {short_signed_i[1], 1'b0};
        mulh_subword     = 2'b10;
        mulh_save        = 1'b1;
        mulh_shift_arith = 1'b1;
        mulh_NS          = STEP2;
      end

      STEP2: begin
        multicycle_o     = 1'b1;
        mulh_signed      = {1'b0, short_signed_i[0]};
        mulh_subword     = 2'b01;
        mulh_imm         = 5'd16;
        mulh_save        = 1'b1;
        mulh_clearcarry  = 1'b1;
        mulh_shift_arith = 1'b1;
        mulh_NS          = FINISH;
      end

      FINISH: begin
        mulh_signed  = short_signed_i;
        mulh_subword = 2'b11;
        mulh_ready   = 1'b1;
        out_ready_o  = 1'b1;
        if (ex_ready_i) mulh_NS = IDLE_MULT;
      end
    endcase
  end

  always_ff @(posedge clk, posedge reset) begin
    if (reset) begin
      mulh_CS      <= IDLE_MULT;
      mulh_carry_q <= 1'b0;
    end else begin
      mulh_CS <= mulh_NS;

      if (mulh_save) mulh_carry_q <= ~mulh_clearcarry & short_mac[32];
      else if (ex_ready_i)  // clear carry when we are going to the next instruction
        mulh_carry_q <= 1'b0;
    end
  end

  logic [31:0] int_op_a_msu;
  logic [31:0] int_op_b_msu;
  logic [31:0] int_result;

  logic        int_is_msu;

  assign int_is_msu = (operator_i == MUL_MSU32);

  assign int_op_a_msu = op_a_i ^ {32{int_is_msu}};
  assign int_op_b_msu = op_b_i & {32{int_is_msu}};

  assign int_result = ($signed(
      op_c_i
  ) + $signed(
      int_op_b_msu
  ) + $signed(
      int_op_a_msu
  ) * $signed(
      op_b_i
  ) + $signed(
      int_round
  )) >>> imm_i;


  logic [31:0] dot_char_result;
  logic [32:0] dot_short_result;
  logic [31:0] accumulator;
  logic [15:0] clpx_shift_result;
  logic [3:0][8:0] dot_char_op_a;
  logic [3:0][8:0] dot_char_op_b;
  logic [3:0][17:0] dot_char_mul;

  logic [3:0][17:0] dot_char_mac;
  logic [1:0][33:0] dot_short_mac;
  logic [31:0] mac_char_result;
  logic [31:0] mac_short_result;

  logic [1:0][16:0] dot_short_op_a;
  logic [1:0][16:0] dot_short_op_b;
  logic [1:0][33:0] dot_short_mul;
  logic      [16:0] dot_short_op_a_1_neg; //to compute -rA[31:16]*rB[31:16] -> (!rA[31:16] + 1)*rB[31:16] = !rA[31:16]*rB[31:16] + rB[31:16]
  logic [31:0] dot_short_op_b_ext;

  assign dot_char_op_a[0] = {dot_signed_i[0] & dot_op_a_i[7], dot_op_a_i[7:0]};
  assign dot_char_op_a[1] = {dot_signed_i[0] & dot_op_a_i[15], dot_op_a_i[15:8]};
  assign dot_char_op_a[2] = {dot_signed_i[0] & dot_op_a_i[23], dot_op_a_i[23:16]};
  assign dot_char_op_a[3] = {dot_signed_i[0] & dot_op_a_i[31], dot_op_a_i[31:24]};

  assign dot_char_op_b[0] = {dot_signed_i[1] & dot_op_b_i[7], dot_op_b_i[7:0]};
  assign dot_char_op_b[1] = {dot_signed_i[1] & dot_op_b_i[15], dot_op_b_i[15:8]};
  assign dot_char_op_b[2] = {dot_signed_i[1] & dot_op_b_i[23], dot_op_b_i[23:16]};
  assign dot_char_op_b[3] = {dot_signed_i[1] & dot_op_b_i[31], dot_op_b_i[31:24]};

  assign dot_char_mul[0] = $signed(dot_char_op_a[0]) * $signed(dot_char_op_b[0]);
  assign dot_char_mul[1] = $signed(dot_char_op_a[1]) * $signed(dot_char_op_b[1]);
  assign dot_char_mul[2] = $signed(dot_char_op_a[2]) * $signed(dot_char_op_b[2]);
  assign dot_char_mul[3] = $signed(dot_char_op_a[3]) * $signed(dot_char_op_b[3]);

  assign dot_char_result = ($signed(
      dot_char_mul[0]
  ) + $signed(
      dot_char_mul[1]
  ) + $signed(
      dot_char_mul[2]
  ) + $signed(
      dot_char_mul[3]
  ) + $signed(
      dot_op_c_i
  ) + $signed(
      int_round
  )) >>> imm_i;

  assign dot_short_op_a[0] = {dot_signed_i[0] & dot_op_a_i[15], dot_op_a_i[15:0]};
  assign dot_short_op_a[1] = {dot_signed_i[0] & dot_op_a_i[31], dot_op_a_i[31:16]};
  assign dot_short_op_a_1_neg = dot_short_op_a[1] ^ {17{(is_clpx_i & ~clpx_img_i)}}; //negates whether clpx_img_i is 0 or 1, only REAL PART needs to be negated

  assign dot_short_op_b[0] = (is_clpx_i & clpx_img_i) ? {
    dot_signed_i[1] & dot_op_b_i[31], dot_op_b_i[31:16]
  } : {
    dot_signed_i[1] & dot_op_b_i[15], dot_op_b_i[15:0]
  };
  assign dot_short_op_b[1] = (is_clpx_i & clpx_img_i) ? {
    dot_signed_i[1] & dot_op_b_i[15], dot_op_b_i[15:0]
  } : {
    dot_signed_i[1] & dot_op_b_i[31], dot_op_b_i[31:16]
  };

  assign dot_short_mul[0] = $signed(dot_short_op_a[0]) * $signed(dot_short_op_b[0]);
  assign dot_short_mul[1] = $signed(dot_short_op_a_1_neg) * $signed(dot_short_op_b[1]);

  assign dot_short_op_b_ext = $signed(dot_short_op_b[1]);
  assign accumulator = is_clpx_i ? dot_short_op_b_ext & {32{~clpx_img_i}} : $signed(dot_op_c_i);

  assign dot_short_result = ($signed(
      dot_short_mul[0][31:0]
  ) + $signed(
      dot_short_mul[1][31:0]
  ) + $signed(
      accumulator
  )) >>> imm_i;
  assign clpx_shift_result = $signed(dot_short_result[31:15]) >>> clpx_shift_i;

  assign dot_char_mac[0] = ($signed(dot_char_mul[0]) + $signed({dot_op_c_i[7], dot_op_c_i[7:0]}) + $signed({1'b0, int_round[15:0]})) >>> imm_i[3:0];
  assign dot_char_mac[1] = ($signed(dot_char_mul[1]) + $signed({dot_op_c_i[15], dot_op_c_i[15:8]}) + $signed({1'b0, int_round[15:0]})) >>> imm_i[3:0];
  assign dot_char_mac[2] = ($signed(dot_char_mul[2]) + $signed({dot_op_c_i[23], dot_op_c_i[23:16]}) + $signed({1'b0, int_round[15:0]})) >>> imm_i[3:0];
  assign dot_char_mac[3] = ($signed(dot_char_mul[3]) + $signed({dot_op_c_i[31], dot_op_c_i[31:24]}) + $signed({1'b0, int_round[15:0]})) >>> imm_i[3:0];
  assign mac_char_result = {
    dot_char_mac[3][7:0],
    dot_char_mac[2][7:0],
    dot_char_mac[1][7:0],
    dot_char_mac[0][7:0]
  };

  assign dot_short_mac[0] = ($signed(dot_short_mul[0]) + $signed({dot_op_c_i[15], dot_op_c_i[15:0]}) + $signed({1'b0, int_round})) >>> imm_i;
  assign dot_short_mac[1] = ($signed(dot_short_mul[1]) + $signed({dot_op_c_i[31], dot_op_c_i[31:16]}) + $signed({1'b0, int_round})) >>> imm_i;
  assign mac_short_result = {
    dot_short_mac[1][15:0],
    dot_short_mac[0][15:0]
  };


  always_comb begin
    result_o = '0;

    unique case (operator_i)
      MUL_MAC32, MUL_MSU32: result_o = int_result[31:0];

      MUL_I, MUL_IR, MUL_H: result_o = short_result[31:0];

      MUL_DOT8: result_o = dot_char_result[31:0];
      MUL_DOT16: begin
        if (is_clpx_i) begin
          if (clpx_img_i) begin
            result_o[31:16] = clpx_shift_result;
            result_o[15:0]  = dot_op_c_i[15:0];
          end else begin
            result_o[15:0]  = clpx_shift_result;
            result_o[31:16] = dot_op_c_i[31:16];
          end
        end else begin
          result_o = dot_short_result[31:0];
        end
      end
      MUL_MAC8: result_o = mac_char_result;
      MUL_MAC16: result_o = mac_short_result;
      default: ;  // default case to suppress unique warning
    endcase
  end


  assign ex_ready_o = ~out_ready_o | ex_ready_i;


`ifdef CV32E40P_ASSERT_ON
  assert property (
    @(posedge clk) ((mulh_CS == FINISH) && (operator_i == MUL_H) && (short_signed_i == 2'b11))
    |->
    (result_o == (($signed(
      {{32{op_a_i[31]}}, op_a_i}
  ) * $signed(
      {{32{op_b_i[31]}}, op_b_i}
  )) >>> 32)));

  assert property (
    @(posedge clk) ((mulh_CS == FINISH) && (operator_i == MUL_H) && (short_signed_i == 2'b01))
    |->
    (result_o == (($signed(
      {{32{op_a_i[31]}}, op_a_i}
  ) * {
    32'b0, op_b_i
  }) >> 32)));

  assert property (
    @(posedge clk) ((mulh_CS == FINISH) && (operator_i == MUL_H) && (short_signed_i == 2'b00))
    |->
    (result_o == (({
    32'b0, op_a_i
  } * {
    32'b0, op_b_i
  }) >> 32)));
`endif
endmodule

`endif /* CV32E40P_MUL */


`ifndef CV32E40P_MUL_NOPARAM
`define CV32E40P_MUL_NOPARAM

module CV32E40P_MUL_noparam
(
  input logic [1-1:0] clk ,
  input logic [1-1:0] clpx_img_i ,
  input logic [2-1:0] clpx_shift_i ,
  input logic [32-1:0] dot_op_a_i ,
  input logic [32-1:0] dot_op_b_i ,
  input logic [32-1:0] dot_op_c_i ,
  input logic [2-1:0] dot_signed_i ,
  input logic [1-1:0] enable_i ,
  input logic [1-1:0] ex_ready_i ,
  output logic [1-1:0] ex_ready_o ,
  input logic [5-1:0] imm_i ,
  input logic [1-1:0] is_clpx_i ,
  output logic [1-1:0] mulh_active_o ,
  output logic [1-1:0] multicycle_o ,
  input logic [32-1:0] op_a_i ,
  input logic [32-1:0] op_b_i ,
  input logic [32-1:0] op_c_i ,
  input logic [4-1:0] operator_i ,
  output logic [1-1:0] out_ready_o ,
  input logic [5-1:0] r_imm_i ,
  input logic [1-1:0] reset ,
  output logic [32-1:0] result_o ,
  input logic [2-1:0] short_signed_i ,
  input logic [1-1:0] short_subword_i 
);
  cv32e40p_mult
  #(
  ) v
  (
    .clk( clk ),
    .clpx_img_i( clpx_img_i ),
    .clpx_shift_i( clpx_shift_i ),
    .dot_op_a_i( dot_op_a_i ),
    .dot_op_b_i( dot_op_b_i ),
    .dot_op_c_i( dot_op_c_i ),
    .dot_signed_i( dot_signed_i ),
    .enable_i( enable_i ),
    .ex_ready_i( ex_ready_i ),
    .ex_ready_o( ex_ready_o ),
    .imm_i( imm_i ),
    .is_clpx_i( is_clpx_i ),
    .mulh_active_o( mulh_active_o ),
    .multicycle_o( multicycle_o ),
    .op_a_i( op_a_i ),
    .op_b_i( op_b_i ),
    .op_c_i( op_c_i ),
    .operator_i( operator_i ),
    .out_ready_o( out_ready_o ),
    .r_imm_i( r_imm_i ),
    .reset( reset ),
    .result_o( result_o ),
    .short_signed_i( short_signed_i ),
    .short_subword_i( short_subword_i )
  );
endmodule

`endif /* CV32E40P_MUL_NOPARAM */




module MULRTL__74c75ceffe42760d
(
  input  logic [0:0] clk ,
  input  logic [1:0] ex_operand_signed_i ,
  input  logic [3:0] ex_operator_i ,
  input  logic [4:0] imm_i ,
  input  logic [0:0] input_valid_i ,
  input  CGRAData_64_8__payload_64__predicate_8 operand_a_i ,
  input  CGRAData_64_8__payload_64__predicate_8 operand_b_i ,
  input  CGRAData_64_8__payload_64__predicate_8 operand_c_i ,
  input  logic [0:0] opt_launch_en_i ,
  output logic [0:0] opt_launch_rdy_o ,
  input  logic [0:0] output_rdy_i ,
  input  logic [4:0] r_imm_i ,
  input  logic [0:0] recv_predicate_en ,
  input  CGRAData_8__predicate_8 recv_predicate_msg ,
  input  logic [0:0] reset ,
  input  logic [1:0] vector_mode_i ,
  output logic [0:0] send_out__en [0:1] ,
  output CGRAData_64_8__payload_64__predicate_8 send_out__msg [0:1] ,
  input logic [0:0] send_out__rdy [0:1] 
);
  logic [0:0] mul_enable;
  logic [0:0] mul_ex_ready;
  logic [1:0] mul_ex_ready_o_vector;
  logic [1:0] mul_out_ready_o_vector;
  CGRAData_64_8__payload_64__predicate_8 result_o_vector;

  logic [0:0] mul_element_clk [0:1];
  logic [0:0] mul_element_clpx_img_i [0:1];
  logic [1:0] mul_element_clpx_shift_i [0:1];
  logic [31:0] mul_element_dot_op_a_i [0:1];
  logic [31:0] mul_element_dot_op_b_i [0:1];
  logic [31:0] mul_element_dot_op_c_i [0:1];
  logic [1:0] mul_element_dot_signed_i [0:1];
  logic [0:0] mul_element_enable_i [0:1];
  logic [0:0] mul_element_ex_ready_i [0:1];
  logic [0:0] mul_element_ex_ready_o [0:1];
  logic [4:0] mul_element_imm_i [0:1];
  logic [0:0] mul_element_is_clpx_i [0:1];
  logic [0:0] mul_element_mulh_active_o [0:1];
  logic [0:0] mul_element_multicycle_o [0:1];
  logic [31:0] mul_element_op_a_i [0:1];
  logic [31:0] mul_element_op_b_i [0:1];
  logic [31:0] mul_element_op_c_i [0:1];
  logic [3:0] mul_element_operator_i [0:1];
  logic [0:0] mul_element_out_ready_o [0:1];
  logic [4:0] mul_element_r_imm_i [0:1];
  logic [0:0] mul_element_reset [0:1];
  logic [31:0] mul_element_result_o [0:1];
  logic [1:0] mul_element_short_signed_i [0:1];
  logic [0:0] mul_element_short_subword_i [0:1];

  CV32E40P_MUL_noparam mul_element__0
  (
    .clk( mul_element_clk[0] ),
    .clpx_img_i( mul_element_clpx_img_i[0] ),
    .clpx_shift_i( mul_element_clpx_shift_i[0] ),
    .dot_op_a_i( mul_element_dot_op_a_i[0] ),
    .dot_op_b_i( mul_element_dot_op_b_i[0] ),
    .dot_op_c_i( mul_element_dot_op_c_i[0] ),
    .dot_signed_i( mul_element_dot_signed_i[0] ),
    .enable_i( mul_element_enable_i[0] ),
    .ex_ready_i( mul_element_ex_ready_i[0] ),
    .ex_ready_o( mul_element_ex_ready_o[0] ),
    .imm_i( mul_element_imm_i[0] ),
    .is_clpx_i( mul_element_is_clpx_i[0] ),
    .mulh_active_o( mul_element_mulh_active_o[0] ),
    .multicycle_o( mul_element_multicycle_o[0] ),
    .op_a_i( mul_element_op_a_i[0] ),
    .op_b_i( mul_element_op_b_i[0] ),
    .op_c_i( mul_element_op_c_i[0] ),
    .operator_i( mul_element_operator_i[0] ),
    .out_ready_o( mul_element_out_ready_o[0] ),
    .r_imm_i( mul_element_r_imm_i[0] ),
    .reset( mul_element_reset[0] ),
    .result_o( mul_element_result_o[0] ),
    .short_signed_i( mul_element_short_signed_i[0] ),
    .short_subword_i( mul_element_short_subword_i[0] )
  );

  CV32E40P_MUL_noparam mul_element__1
  (
    .clk( mul_element_clk[1] ),
    .clpx_img_i( mul_element_clpx_img_i[1] ),
    .clpx_shift_i( mul_element_clpx_shift_i[1] ),
    .dot_op_a_i( mul_element_dot_op_a_i[1] ),
    .dot_op_b_i( mul_element_dot_op_b_i[1] ),
    .dot_op_c_i( mul_element_dot_op_c_i[1] ),
    .dot_signed_i( mul_element_dot_signed_i[1] ),
    .enable_i( mul_element_enable_i[1] ),
    .ex_ready_i( mul_element_ex_ready_i[1] ),
    .ex_ready_o( mul_element_ex_ready_o[1] ),
    .imm_i( mul_element_imm_i[1] ),
    .is_clpx_i( mul_element_is_clpx_i[1] ),
    .mulh_active_o( mul_element_mulh_active_o[1] ),
    .multicycle_o( mul_element_multicycle_o[1] ),
    .op_a_i( mul_element_op_a_i[1] ),
    .op_b_i( mul_element_op_b_i[1] ),
    .op_c_i( mul_element_op_c_i[1] ),
    .operator_i( mul_element_operator_i[1] ),
    .out_ready_o( mul_element_out_ready_o[1] ),
    .r_imm_i( mul_element_r_imm_i[1] ),
    .reset( mul_element_reset[1] ),
    .result_o( mul_element_result_o[1] ),
    .short_signed_i( mul_element_short_signed_i[1] ),
    .short_subword_i( mul_element_short_subword_i[1] )
  );


  
  always_comb begin : _lambda__s_tile_0__element_fu_1_mul_enable
    mul_enable = opt_launch_en_i & input_valid_i;
  end

  
  always_comb begin : _lambda__s_tile_0__element_fu_1_opt_launch_rdy_o
    opt_launch_rdy_o = ( & mul_ex_ready_o_vector );
  end

  
  always_comb begin : _lambda__s_tile_0__element_fu_1_send_out_0__en
    send_out__en[1'd0] = ( & mul_out_ready_o_vector );
  end

  
  always_comb begin : predicate_handling
    result_o_vector.predicate = 8'd0;
    if ( mul_enable ) begin
      result_o_vector.predicate = ( ( operand_a_i.predicate & operand_b_i.predicate ) & operand_c_i.predicate ) & ( { { 7 { ~recv_predicate_en[0] } }, ~recv_predicate_en } | recv_predicate_msg.predicate );
    end
  end

  assign mul_element_clk[0] = clk;
  assign mul_element_reset[0] = reset;
  assign mul_element_clk[1] = clk;
  assign mul_element_reset[1] = reset;
  assign mul_element_enable_i[0] = mul_enable;
  assign mul_element_operator_i[0] = ex_operator_i;
  assign mul_element_short_subword_i[0] = 1'd0;
  assign mul_element_r_imm_i[0] = r_imm_i;
  assign mul_element_imm_i[0] = imm_i;
  assign mul_element_is_clpx_i[0] = 1'd0;
  assign mul_element_clpx_img_i[0] = 1'd0;
  assign mul_element_clpx_shift_i[0] = 2'd0;
  assign mul_element_short_signed_i[0] = ex_operand_signed_i;
  assign mul_element_dot_signed_i[0] = ex_operand_signed_i;
  assign mul_ex_ready_o_vector[0:0] = mul_element_ex_ready_o[0];
  assign mul_out_ready_o_vector[0:0] = mul_element_out_ready_o[0];
  assign mul_element_op_a_i[0] = operand_a_i.payload[31:0];
  assign mul_element_op_b_i[0] = operand_b_i.payload[31:0];
  assign mul_element_op_c_i[0] = operand_c_i.payload[31:0];
  assign mul_element_dot_op_a_i[0] = operand_a_i.payload[31:0];
  assign mul_element_dot_op_b_i[0] = operand_b_i.payload[31:0];
  assign mul_element_dot_op_c_i[0] = operand_c_i.payload[31:0];
  assign result_o_vector.payload[31:0] = mul_element_result_o[0];
  assign mul_element_ex_ready_i[0] = output_rdy_i;
  assign mul_element_enable_i[1] = mul_enable;
  assign mul_element_operator_i[1] = ex_operator_i;
  assign mul_element_short_subword_i[1] = 1'd0;
  assign mul_element_r_imm_i[1] = r_imm_i;
  assign mul_element_imm_i[1] = imm_i;
  assign mul_element_is_clpx_i[1] = 1'd0;
  assign mul_element_clpx_img_i[1] = 1'd0;
  assign mul_element_clpx_shift_i[1] = 2'd0;
  assign mul_element_short_signed_i[1] = ex_operand_signed_i;
  assign mul_element_dot_signed_i[1] = ex_operand_signed_i;
  assign mul_ex_ready_o_vector[1:1] = mul_element_ex_ready_o[1];
  assign mul_out_ready_o_vector[1:1] = mul_element_out_ready_o[1];
  assign mul_element_op_a_i[1] = operand_a_i.payload[63:32];
  assign mul_element_op_b_i[1] = operand_b_i.payload[63:32];
  assign mul_element_op_c_i[1] = operand_c_i.payload[63:32];
  assign mul_element_dot_op_a_i[1] = operand_a_i.payload[63:32];
  assign mul_element_dot_op_b_i[1] = operand_b_i.payload[63:32];
  assign mul_element_dot_op_c_i[1] = operand_c_i.payload[63:32];
  assign result_o_vector.payload[63:32] = mul_element_result_o[1];
  assign mul_element_ex_ready_i[1] = output_rdy_i;
  assign send_out__msg[0] = result_o_vector;
  assign send_out__msg[1] = { 64'd0, 8'd0 };
  assign send_out__en[1] = 1'd0;

endmodule





`ifndef COREV_DECODERRTL
`define COREV_DECODERRTL





module cgra_fu_decoder
(
    input logic [1:0]          cgra_signed_mode_i,
    input logic [1:0]          cgra_vec_mode_i,
    input logic [4:0]          cgra_bmask_i,
    input logic [8:0]        id_operator_i, 

    output logic [6:0] id_alu_operator_o,
    output logic [4:0] id_alu_bmask_o,
    output logic             id_alu_enable_o,
    output logic [3:0] id_mult_operator_o,
    output logic [4:0] id_mult_bmask_o,
    output logic             id_mult_enable_o,

    output logic             id_const_enable_o,
    output logic             id_operand_b_sel_o,
    output logic [1:0]       id_operand_c_sel_o,
    output logic             id_operand_b_repl_o,
    output logic             id_operand_c_repl_o
);

  localparam ALU_ADD   = 7'b0011000;
  localparam ALU_SUB   = 7'b0011001;
  localparam ALU_ADDU  = 7'b0011010;
  localparam ALU_SUBU  = 7'b0011011;
  localparam ALU_ADDR  = 7'b0011100;
  localparam ALU_SUBR  = 7'b0011101;
  localparam ALU_ADDUR = 7'b0011110;
  localparam ALU_SUBUR = 7'b0011111;

  localparam ALU_XOR = 7'b0101111;
  localparam ALU_OR  = 7'b0101110;
  localparam ALU_AND = 7'b0010101;

  localparam ALU_SRA = 7'b0100100;
  localparam ALU_SRL = 7'b0100101;
  localparam ALU_ROR = 7'b0100110;
  localparam ALU_SLL = 7'b0100111;

  localparam ALU_BEXT  = 7'b0101000;
  localparam ALU_BEXTU = 7'b0101001;
  localparam ALU_BINS  = 7'b0101010;
  localparam ALU_BCLR  = 7'b0101011;
  localparam ALU_BSET  = 7'b0101100;
  localparam ALU_BREV  = 7'b1001001;

  localparam ALU_FF1 = 7'b0110110;
  localparam ALU_FL1 = 7'b0110111;
  localparam ALU_CNT = 7'b0110100;
  localparam ALU_CLB = 7'b0110101;

  localparam ALU_EXTS = 7'b0111110;
  localparam ALU_EXT  = 7'b0111111;

  localparam ALU_LTS = 7'b0000000;
  localparam ALU_LTU = 7'b0000001;
  localparam ALU_LES = 7'b0000100;
  localparam ALU_LEU = 7'b0000101;
  localparam ALU_GTS = 7'b0001000;
  localparam ALU_GTU = 7'b0001001;
  localparam ALU_GES = 7'b0001010;
  localparam ALU_GEU = 7'b0001011;
  localparam ALU_EQ  = 7'b0001100;
  localparam ALU_NE  = 7'b0001101;

  localparam ALU_SLTS  = 7'b0000010;
  localparam ALU_SLTU  = 7'b0000011;
  localparam ALU_SLETS = 7'b0000110;
  localparam ALU_SLETU = 7'b0000111;

  localparam ALU_ABS   = 7'b0010100;
  localparam ALU_CLIP  = 7'b0010110;
  localparam ALU_CLIPU = 7'b0010111;

  localparam ALU_INS = 7'b0101101;

  localparam ALU_MIN  = 7'b0010000;
  localparam ALU_MINU = 7'b0010001;
  localparam ALU_MAX  = 7'b0010010;
  localparam ALU_MAXU = 7'b0010011;

  localparam ALU_DIVU = 7'b0110000;  // bit 0 is used for signed mode, bit 1 is used for remdiv
  localparam ALU_DIV  = 7'b0110001;  // bit 0 is used for signed mode, bit 1 is used for remdiv
  localparam ALU_REMU = 7'b0110010;  // bit 0 is used for signed mode, bit 1 is used for remdiv
  localparam ALU_REM  = 7'b0110011;  // bit 0 is used for signed mode, bit 1 is used for remdiv

  localparam ALU_SHUF  = 7'b0111010;
  localparam ALU_SHUF2 = 7'b0111011;
  localparam ALU_PCKLO = 7'b0111000;
  localparam ALU_PCKHI = 7'b0111001;

  localparam OPT_ADD = 5'd1;
  localparam OPT_SUB = 5'd2;
  localparam OPT_MUL = 5'd3;
  localparam OPT_SLL = 5'd4;
  localparam OPT_SRL = 5'd5;
  localparam OPT_SRA = 5'd6;
  localparam OPT_DIV = 5'd7;
  localparam OPT_MIN = 5'd8;
  localparam OPT_MAX = 5'd9;
  localparam OPT_ABS = 5'd10;
  localparam OPT_MAC = 5'd11; 
  localparam OPT_MAC_CONST = 5'd12;

  localparam OPT_FADD = 5'd13;
  localparam OPT_FSUB = 5'd14;
  localparam OPT_FMUL = 5'd15;
  localparam OPT_FDIV = 5'd16;

  localparam OPT_DOT = 5'd17;
  localparam OPT_RADD = 5'd18;

  localparam OPT_XOR = 5'd21;
  localparam OPT_OR = 5'd22;
  localparam OPT_AND = 5'd23;

  localparam MUL_MAC32 = 4'b0000; // for basic mul, it is op_c_i == 0;
  localparam MUL_MSU32 = 4'b0001;
  localparam MUL_I     = 4'b0010;
  localparam MUL_DOT8  = 4'b0100;
  localparam MUL_DOT16 = 4'b0101;
  localparam MUL_H     = 4'b0110;
  
  localparam MUL_MAC8  = 4'b1100;
  localparam MUL_MAC16 = 4'b1101;
  localparam MUL_DOT32 = 4'b1110;

  localparam VEC_MODE32 = 2'b00;
  localparam VEC_MODE16 = 2'b10;
  localparam VEC_MODE8 = 2'b11;

  always_comb begin : alu_instruction_decoder
    id_alu_operator_o = ALU_ADDU;
    id_alu_enable_o = 1'b1;

    unique case (id_operator_i[4:0])
      OPT_ADD: begin
        unique case ({id_operator_i[7], cgra_signed_mode_i[0]})
          {1'b0, 1'b0}: id_alu_operator_o = ALU_ADDU;
          {1'b1, 1'b0}: id_alu_operator_o = ALU_ADDUR;
          {1'b0, 1'b1}: id_alu_operator_o = ALU_ADD;
          {1'b1, 1'b1}: id_alu_operator_o = ALU_ADDR;
        endcase
      end

      OPT_SUB: begin
        unique case ({id_operator_i[7], cgra_signed_mode_i[0]})
          {1'b0, 1'b0}: id_alu_operator_o = ALU_SUBU;
          {1'b1, 1'b0}: id_alu_operator_o = ALU_SUBUR;
          {1'b0, 1'b1}: id_alu_operator_o = ALU_SUB;
          {1'b1, 1'b1}: id_alu_operator_o = ALU_SUBR;
        endcase
      end

      OPT_SLL: id_alu_operator_o = ALU_SLL;
      OPT_SRL: id_alu_operator_o = ALU_SRL;
      OPT_SRA: id_alu_operator_o = ALU_SRA;

      OPT_XOR: id_alu_operator_o = ALU_XOR;
      OPT_OR: id_alu_operator_o = ALU_OR;
      OPT_AND: id_alu_operator_o = ALU_AND;

      OPT_ABS: id_alu_operator_o = ALU_ABS;
      OPT_MIN: begin
        unique case (cgra_signed_mode_i[0])
          1'b0: id_alu_operator_o = ALU_MINU;
          1'b1: id_alu_operator_o = ALU_MIN;
        endcase
      end
      OPT_MAX: begin
        unique case (cgra_signed_mode_i[0])
          1'b0: id_alu_operator_o = ALU_MAXU;
          1'b1: id_alu_operator_o = ALU_MAX;
        endcase
      end
      default: id_alu_enable_o = 1'b0;
    endcase
  end

  always_comb begin : mult_instruction_decoder
    id_mult_operator_o = MUL_MAC32;
    id_mult_enable_o = 1'b1;
    unique case (id_operator_i[4:0])
      OPT_MUL: begin
        unique case (cgra_vec_mode_i)
          VEC_MODE8: id_mult_operator_o = MUL_MAC8;
          VEC_MODE16: id_mult_operator_o = MUL_MAC16;
          default: id_mult_operator_o = MUL_MAC32;
        endcase
      end
      OPT_MAC: begin
        unique case (cgra_vec_mode_i)
          VEC_MODE8: id_mult_operator_o = MUL_MAC8;
          VEC_MODE16: id_mult_operator_o = MUL_MAC16;
          default: id_mult_operator_o = MUL_MAC32;
        endcase
      end
      OPT_MAC_CONST: begin
        unique case (cgra_vec_mode_i)
          VEC_MODE8: id_mult_operator_o = MUL_MAC8;
          VEC_MODE16: id_mult_operator_o = MUL_MAC16;
          default: id_mult_operator_o = MUL_MAC32;
        endcase
      end
      OPT_DOT: begin
        unique case (cgra_vec_mode_i)
          VEC_MODE8: id_mult_operator_o = MUL_DOT8;
          VEC_MODE16: id_mult_operator_o = MUL_DOT16;
          default: id_mult_operator_o = MUL_DOT32;
        endcase
      end
      default: id_mult_enable_o = 1'b0;
    endcase
  end

  assign id_operand_b_sel_o = (id_operator_i[4:0] == OPT_MAC_CONST) ? (~id_operator_i[5]) : id_operator_i[5];

  always_comb begin : const_mux_selector_c
    id_operand_c_sel_o = 2'b00;

    unique case (id_operator_i[4:0])
      OPT_MUL: id_operand_c_sel_o = 2'b10;
      OPT_MAC_CONST: id_operand_c_sel_o = {1'b0, id_operator_i[5]};
    endcase    
  end

  always_comb begin : scalar_repl_selector
    id_operand_b_repl_o = 1'b0;
    id_operand_c_repl_o = 1'b0;

    if (id_operator_i[4:0] == OPT_MAC_CONST) begin
      id_operand_c_repl_o = id_operator_i[6];
    end else begin
      id_operand_b_repl_o = id_operator_i[6];
    end
    
  end

  always_comb begin : norm_bmask
    id_alu_bmask_o = 5'b0;

    unique case (id_operator_i[4:0])
      OPT_ADD: id_alu_bmask_o = id_operator_i[7]? 5'd2 : 5'd0;
      OPT_SUB: id_alu_bmask_o = id_operator_i[7]? 5'd2 : 5'd0;

    endcase
    
  end

  assign id_const_enable_o = id_operator_i[5] || (id_operator_i[4:0] == OPT_MAC_CONST);


endmodule
`endif /* COREV_DECODERRTL */


`ifndef COREV_DECODERRTL_NOPARAM
`define COREV_DECODERRTL_NOPARAM

module CoreV_DecoderRTL_noparam
(
  input logic reset,
  input logic clk,
  input logic [5-1:0] cgra_bmask_i ,
  input logic [2-1:0] cgra_signed_mode_i ,
  input logic [2-1:0] cgra_vec_mode_i ,
  output logic [5-1:0] id_alu_bmask_o ,
  output logic [1-1:0] id_alu_enable_o ,
  output logic [7-1:0] id_alu_operator_o ,
  output logic [1-1:0] id_const_enable_o ,
  output logic [5-1:0] id_mult_bmask_o ,
  output logic [1-1:0] id_mult_enable_o ,
  output logic [4-1:0] id_mult_operator_o ,
  output logic [1-1:0] id_operand_b_repl_o ,
  output logic [1-1:0] id_operand_b_sel_o ,
  output logic [1-1:0] id_operand_c_repl_o ,
  output logic [2-1:0] id_operand_c_sel_o ,
  input logic [9-1:0] id_operator_i 
);
  cgra_fu_decoder
  #(
  ) v
  (
    .cgra_bmask_i( cgra_bmask_i ),
    .cgra_signed_mode_i( cgra_signed_mode_i ),
    .cgra_vec_mode_i( cgra_vec_mode_i ),
    .id_alu_bmask_o( id_alu_bmask_o ),
    .id_alu_enable_o( id_alu_enable_o ),
    .id_alu_operator_o( id_alu_operator_o ),
    .id_const_enable_o( id_const_enable_o ),
    .id_mult_bmask_o( id_mult_bmask_o ),
    .id_mult_enable_o( id_mult_enable_o ),
    .id_mult_operator_o( id_mult_operator_o ),
    .id_operand_b_repl_o( id_operand_b_repl_o ),
    .id_operand_b_sel_o( id_operand_b_sel_o ),
    .id_operand_c_repl_o( id_operand_c_repl_o ),
    .id_operand_c_sel_o( id_operand_c_sel_o ),
    .id_operator_i( id_operator_i )
  );
endmodule

`endif /* COREV_DECODERRTL_NOPARAM */






`ifndef COREV_OPRANDMUXRTL
`define COREV_OPRANDMUXRTL





module cgra_fu_oprand_mux
(
    input logic              ex_operand_b_sel,
    input logic [1:0]        ex_operand_c_sel,
    input logic              ex_operand_b_repl,
    input logic              ex_operand_c_repl,
    input logic [1:0]          cgra_vec_mode_i,
    input logic [63:0]          ex_operand_b_i,
    input logic [63:0]          ex_operand_c_i,

    input logic [7:0]          ex_operand_b_pred_i,
    input logic [7:0]          ex_operand_c_pred_i,

    input logic [31:0]          ex_constant_i,

    output logic [63:0]          ex_operand_b_o,
    output logic [63:0]          ex_operand_c_o,

    output logic [7:0]          ex_operand_b_pred_o,
    output logic [7:0]          ex_operand_c_pred_o
);
  localparam VEC_MODE32 = 2'b00;
  localparam VEC_MODE16 = 2'b10;
  localparam VEC_MODE8 = 2'b11;
  
  logic [63:0]          operand_b_mux_o;
  logic [63:0]          operand_c_mux_o;

  logic [7:0]          operand_b_mux_pred_o;
  logic [7:0]          operand_c_mux_pred_o;

  always_comb begin : operand_mux_b

    unique case (ex_operand_b_sel)
      1'b0: begin
        operand_b_mux_o = ex_operand_b_i;
        operand_b_mux_pred_o = ex_operand_b_pred_i;
      end
      1'b1: begin
        operand_b_mux_o = {ex_constant_i, ex_constant_i};
        operand_b_mux_pred_o = {8{1'b1}};
      end 
    endcase
  end

  always_comb begin : operand_mux_c
    unique case (ex_operand_c_sel)
      2'b01: begin
        operand_c_mux_o = {ex_constant_i, ex_constant_i};
        operand_c_mux_pred_o = {8{1'b1}};
      end 
      2'b10: begin
        operand_c_mux_o = '0;
        operand_c_mux_pred_o = {8{1'b1}};
      end 
      default: begin
        operand_c_mux_o = ex_operand_c_i;
        operand_c_mux_pred_o = ex_operand_c_pred_i;
      end 
    endcase
  end

  always_comb begin : operand_repl_b
    ex_operand_b_o = operand_b_mux_o; 
    ex_operand_b_pred_o = operand_b_mux_pred_o;
    if (ex_operand_b_repl) begin
      unique case (cgra_vec_mode_i)
        VEC_MODE8: begin
          ex_operand_b_o = {8{operand_b_mux_o[7:0]}};
          ex_operand_b_pred_o = {8{operand_b_mux_pred_o[0]}};
        end 
        VEC_MODE16: begin
          ex_operand_b_o = {4{operand_b_mux_o[15:0]}};
          ex_operand_b_pred_o = {4{operand_b_mux_pred_o[1:0]}};
        end 
        default: begin
          ex_operand_b_o = {2{operand_b_mux_o[31:0]}};
          ex_operand_b_pred_o = {2{operand_b_mux_pred_o[3:0]}};
        end 
      endcase
    end
  end

  always_comb begin : operand_repl_c
    ex_operand_c_o = operand_c_mux_o; 
    ex_operand_c_pred_o = operand_c_mux_pred_o;
    if (ex_operand_c_repl) begin
      unique case (cgra_vec_mode_i)
        VEC_MODE8: begin
          ex_operand_c_o = {8{operand_c_mux_o[7:0]}};
          ex_operand_c_pred_o = {8{operand_c_mux_pred_o[0]}};
        end 
        VEC_MODE16: begin
          ex_operand_c_o = {4{operand_c_mux_o[15:0]}};
          ex_operand_c_pred_o = {4{operand_c_mux_pred_o[1:0]}};
        end 
        default: begin
          ex_operand_c_o = {2{operand_c_mux_o[31:0]}};
          ex_operand_c_pred_o = {2{operand_c_mux_pred_o[3:0]}};
        end 
      endcase
    end
  end

endmodule
`endif /* COREV_OPRANDMUXRTL */


`ifndef COREV_OPRANDMUXRTL_NOPARAM
`define COREV_OPRANDMUXRTL_NOPARAM

module CoreV_OprandMuxRTL_noparam
(
  input logic reset,
  input logic clk,
  input logic [2-1:0] cgra_vec_mode_i ,
  input logic [32-1:0] ex_constant_i ,
  input logic [64-1:0] ex_operand_b_i ,
  output logic [64-1:0] ex_operand_b_o ,
  input logic [8-1:0] ex_operand_b_pred_i ,
  output logic [8-1:0] ex_operand_b_pred_o ,
  input logic [1-1:0] ex_operand_b_repl ,
  input logic [1-1:0] ex_operand_b_sel ,
  input logic [64-1:0] ex_operand_c_i ,
  output logic [64-1:0] ex_operand_c_o ,
  input logic [8-1:0] ex_operand_c_pred_i ,
  output logic [8-1:0] ex_operand_c_pred_o ,
  input logic [1-1:0] ex_operand_c_repl ,
  input logic [2-1:0] ex_operand_c_sel 
);
  cgra_fu_oprand_mux
  #(
  ) v
  (
    .cgra_vec_mode_i( cgra_vec_mode_i ),
    .ex_constant_i( ex_constant_i ),
    .ex_operand_b_i( ex_operand_b_i ),
    .ex_operand_b_o( ex_operand_b_o ),
    .ex_operand_b_pred_i( ex_operand_b_pred_i ),
    .ex_operand_b_pred_o( ex_operand_b_pred_o ),
    .ex_operand_b_repl( ex_operand_b_repl ),
    .ex_operand_b_sel( ex_operand_b_sel ),
    .ex_operand_c_i( ex_operand_c_i ),
    .ex_operand_c_o( ex_operand_c_o ),
    .ex_operand_c_pred_i( ex_operand_c_pred_i ),
    .ex_operand_c_pred_o( ex_operand_c_pred_o ),
    .ex_operand_c_repl( ex_operand_c_repl ),
    .ex_operand_c_sel( ex_operand_c_sel )
  );
endmodule

`endif /* COREV_OPRANDMUXRTL_NOPARAM */




module CGRAFURTL__cb9d7ba75ff8e27e
(
  input  logic [4:0] cgra_bmask_i ,
  input  logic [1:0] cgra_signed_mode_i ,
  input  logic [1:0] cgra_vec_mode_i ,
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
  input  logic [8:0] recv_opt_msg_ctrl ,
  input  logic [2:0] recv_opt_msg_fu_in [0:3],
  input  logic [1:0] recv_opt_msg_out_routine ,
  input  logic [0:0] recv_opt_msg_predicate ,
  output logic [3:0] recv_port_ack ,
  input  CGRAData_64_8__payload_64__predicate_8 recv_port_data [0:3],
  input  logic [3:0] recv_port_valid ,
  output logic [0:0] recv_predicate_ack ,
  input  CGRAData_8__predicate_8 recv_predicate_data ,
  input  logic [0:0] recv_predicate_valid ,
  input  logic [0:0] reset ,
  input  logic [0:0] send_port_ack ,
  output CGRAData_64_8__payload_64__predicate_8 send_port_data [0:1],
  output logic [1:0] send_port_valid 
);
  localparam logic [1:0] __const__STAGE_NORMAL  = 2'd0;
  localparam logic [1:0] __const__STAGE_WAIT_FOR_FU  = 2'd1;
  localparam logic [1:0] __const__STAGE_WAIT_FOR_NXT  = 2'd3;
  localparam logic [2:0] __const__num_xbar_outports_at_decode_process  = 3'd4;
  localparam logic [2:0] __const__num_xbar_inports_at_decode_process  = 3'd4;
  localparam logic [2:0] __const__num_xbar_outports_at_opt_propagate  = 3'd4;
  localparam logic [2:0] __const__num_xbar_inports_at_opt_propagate  = 3'd4;
  localparam logic [1:0] __const__num_outports_at_handshake_process  = 2'd2;
  localparam logic [2:0] __const__num_xbar_inports_at_handshake_process  = 3'd4;
  localparam logic [2:0] __const__num_xbar_outports_at_fu_propagate_sync  = 3'd4;
  localparam logic [2:0] __const__num_xbar_outports_at_data_routing  = 3'd4;
  localparam logic [1:0] __const__num_outports_at_data_routing  = 2'd2;
  localparam logic [2:0] __const__num_xbar_inports_at_data_routing  = 3'd4;
  logic [1:0] cur_stage;
  logic [4:0] ex_alu_bmask;
  logic [0:0] ex_alu_enable;
  logic [6:0] ex_alu_operator;
  logic [4:0] ex_mult_bmask;
  logic [0:0] ex_mult_enable;
  logic [3:0] ex_mult_operator;
  logic [0:0] ex_operand_b_repl;
  logic [0:0] ex_operand_b_sel;
  logic [0:0] ex_operand_c_repl;
  logic [1:0] ex_operand_c_sel;
  logic [1:0] ex_signed_mode;
  logic [1:0] ex_vec_mode;
  logic [3:0] fu_handshake_vector_xbar_mesh_in_valid_met;
  logic [0:0] fu_launch_ack;
  logic [0:0] fu_launch_done;
  logic [1:0] fu_launch_en_vector;
  logic [0:0] fu_launch_finish;
  logic [1:0] fu_launch_rdy_vector;
  logic [1:0] fu_out_routine;
  logic [0:0] fu_recv_const_req_nxt;
  logic [0:0] fu_send_out_ack;
  logic [0:0] fu_send_out_done;
  logic [0:0] fu_send_out_finish;
  logic [1:0] fu_send_port_valid_vector [0:1];
  logic [3:0] fu_xbar_inport_sel [0:3];
  logic [0:0] fu_xbar_mesh_in_valid;
  logic [3:0] fu_xbar_outport_sel [0:3];
  logic [3:0] fu_xbar_outport_sel_nxt [0:3];
  logic [4:0] fu_xbar_outport_sel_nxt_decode [0:3];
  logic [0:0] fu_xbar_recv_const_req;
  logic [0:0] fu_xbar_recv_predicate_req;
  CGRAData_64_8__payload_64__predicate_8 fu_xbar_send_data [0:3];
  logic [4:0] id_alu_bmask;
  logic [0:0] id_alu_enable;
  logic [6:0] id_alu_operator;
  logic [4:0] id_mult_bmask;
  logic [0:0] id_mult_enable;
  logic [3:0] id_mult_operator;
  logic [0:0] id_operand_b_repl;
  logic [0:0] id_operand_b_sel;
  logic [0:0] id_operand_c_repl;
  logic [1:0] id_operand_c_sel;
  logic [1:0] nxt_stage;
  logic [0:0] recv_predicate_req_nxt;
  logic [3:0] xbar_recv_port_req;

  logic [4:0] fu_0__bmask_b_i;
  logic [0:0] fu_0__clk;
  logic [6:0] fu_0__ex_operator_i;
  logic [0:0] fu_0__input_valid_i;
  CGRAData_64_8__payload_64__predicate_8 fu_0__operand_a_i;
  CGRAData_64_8__payload_64__predicate_8 fu_0__operand_b_i;
  logic [0:0] fu_0__opt_launch_en_i;
  logic [0:0] fu_0__opt_launch_rdy_o;
  logic [0:0] fu_0__output_rdy_i;
  logic [0:0] fu_0__recv_predicate_en;
  CGRAData_8__predicate_8 fu_0__recv_predicate_msg;
  logic [0:0] fu_0__reset;
  logic [1:0] fu_0__vector_mode_i;
  logic [0:0] fu_0__send_out__en [0:1];
  CGRAData_64_8__payload_64__predicate_8 fu_0__send_out__msg [0:1];
  logic [0:0] fu_0__send_out__rdy [0:1];

  ALURTL__74c75ceffe42760d fu_0
  (
    .bmask_b_i( fu_0__bmask_b_i ),
    .clk( fu_0__clk ),
    .ex_operator_i( fu_0__ex_operator_i ),
    .input_valid_i( fu_0__input_valid_i ),
    .operand_a_i( fu_0__operand_a_i ),
    .operand_b_i( fu_0__operand_b_i ),
    .opt_launch_en_i( fu_0__opt_launch_en_i ),
    .opt_launch_rdy_o( fu_0__opt_launch_rdy_o ),
    .output_rdy_i( fu_0__output_rdy_i ),
    .recv_predicate_en( fu_0__recv_predicate_en ),
    .recv_predicate_msg( fu_0__recv_predicate_msg ),
    .reset( fu_0__reset ),
    .vector_mode_i( fu_0__vector_mode_i ),
    .send_out__en( fu_0__send_out__en ),
    .send_out__msg( fu_0__send_out__msg ),
    .send_out__rdy( fu_0__send_out__rdy )
  );



  logic [0:0] fu_1__clk;
  logic [1:0] fu_1__ex_operand_signed_i;
  logic [3:0] fu_1__ex_operator_i;
  logic [4:0] fu_1__imm_i;
  logic [0:0] fu_1__input_valid_i;
  CGRAData_64_8__payload_64__predicate_8 fu_1__operand_a_i;
  CGRAData_64_8__payload_64__predicate_8 fu_1__operand_b_i;
  CGRAData_64_8__payload_64__predicate_8 fu_1__operand_c_i;
  logic [0:0] fu_1__opt_launch_en_i;
  logic [0:0] fu_1__opt_launch_rdy_o;
  logic [0:0] fu_1__output_rdy_i;
  logic [4:0] fu_1__r_imm_i;
  logic [0:0] fu_1__recv_predicate_en;
  CGRAData_8__predicate_8 fu_1__recv_predicate_msg;
  logic [0:0] fu_1__reset;
  logic [1:0] fu_1__vector_mode_i;
  logic [0:0] fu_1__send_out__en [0:1];
  CGRAData_64_8__payload_64__predicate_8 fu_1__send_out__msg [0:1];
  logic [0:0] fu_1__send_out__rdy [0:1];

  MULRTL__74c75ceffe42760d fu_1
  (
    .clk( fu_1__clk ),
    .ex_operand_signed_i( fu_1__ex_operand_signed_i ),
    .ex_operator_i( fu_1__ex_operator_i ),
    .imm_i( fu_1__imm_i ),
    .input_valid_i( fu_1__input_valid_i ),
    .operand_a_i( fu_1__operand_a_i ),
    .operand_b_i( fu_1__operand_b_i ),
    .operand_c_i( fu_1__operand_c_i ),
    .opt_launch_en_i( fu_1__opt_launch_en_i ),
    .opt_launch_rdy_o( fu_1__opt_launch_rdy_o ),
    .output_rdy_i( fu_1__output_rdy_i ),
    .r_imm_i( fu_1__r_imm_i ),
    .recv_predicate_en( fu_1__recv_predicate_en ),
    .recv_predicate_msg( fu_1__recv_predicate_msg ),
    .reset( fu_1__reset ),
    .vector_mode_i( fu_1__vector_mode_i ),
    .send_out__en( fu_1__send_out__en ),
    .send_out__msg( fu_1__send_out__msg ),
    .send_out__rdy( fu_1__send_out__rdy )
  );



  logic [4:0] fu_decoder_cgra_bmask_i;
  logic [1:0] fu_decoder_cgra_signed_mode_i;
  logic [1:0] fu_decoder_cgra_vec_mode_i;
  logic [0:0] fu_decoder_clk;
  logic [4:0] fu_decoder_id_alu_bmask_o;
  logic [0:0] fu_decoder_id_alu_enable_o;
  logic [6:0] fu_decoder_id_alu_operator_o;
  logic [0:0] fu_decoder_id_const_enable_o;
  logic [4:0] fu_decoder_id_mult_bmask_o;
  logic [0:0] fu_decoder_id_mult_enable_o;
  logic [3:0] fu_decoder_id_mult_operator_o;
  logic [0:0] fu_decoder_id_operand_b_repl_o;
  logic [0:0] fu_decoder_id_operand_b_sel_o;
  logic [0:0] fu_decoder_id_operand_c_repl_o;
  logic [1:0] fu_decoder_id_operand_c_sel_o;
  logic [8:0] fu_decoder_id_operator_i;
  logic [0:0] fu_decoder_reset;

  CoreV_DecoderRTL_noparam fu_decoder
  (
    .cgra_bmask_i( fu_decoder_cgra_bmask_i ),
    .cgra_signed_mode_i( fu_decoder_cgra_signed_mode_i ),
    .cgra_vec_mode_i( fu_decoder_cgra_vec_mode_i ),
    .clk( fu_decoder_clk ),
    .id_alu_bmask_o( fu_decoder_id_alu_bmask_o ),
    .id_alu_enable_o( fu_decoder_id_alu_enable_o ),
    .id_alu_operator_o( fu_decoder_id_alu_operator_o ),
    .id_const_enable_o( fu_decoder_id_const_enable_o ),
    .id_mult_bmask_o( fu_decoder_id_mult_bmask_o ),
    .id_mult_enable_o( fu_decoder_id_mult_enable_o ),
    .id_mult_operator_o( fu_decoder_id_mult_operator_o ),
    .id_operand_b_repl_o( fu_decoder_id_operand_b_repl_o ),
    .id_operand_b_sel_o( fu_decoder_id_operand_b_sel_o ),
    .id_operand_c_repl_o( fu_decoder_id_operand_c_repl_o ),
    .id_operand_c_sel_o( fu_decoder_id_operand_c_sel_o ),
    .id_operator_i( fu_decoder_id_operator_i ),
    .reset( fu_decoder_reset )
  );



  logic [1:0] fu_operand_mux_cgra_vec_mode_i;
  logic [0:0] fu_operand_mux_clk;
  logic [31:0] fu_operand_mux_ex_constant_i;
  logic [63:0] fu_operand_mux_ex_operand_b_i;
  logic [63:0] fu_operand_mux_ex_operand_b_o;
  logic [7:0] fu_operand_mux_ex_operand_b_pred_i;
  logic [7:0] fu_operand_mux_ex_operand_b_pred_o;
  logic [0:0] fu_operand_mux_ex_operand_b_repl;
  logic [0:0] fu_operand_mux_ex_operand_b_sel;
  logic [63:0] fu_operand_mux_ex_operand_c_i;
  logic [63:0] fu_operand_mux_ex_operand_c_o;
  logic [7:0] fu_operand_mux_ex_operand_c_pred_i;
  logic [7:0] fu_operand_mux_ex_operand_c_pred_o;
  logic [0:0] fu_operand_mux_ex_operand_c_repl;
  logic [1:0] fu_operand_mux_ex_operand_c_sel;
  logic [0:0] fu_operand_mux_reset;

  CoreV_OprandMuxRTL_noparam fu_operand_mux
  (
    .cgra_vec_mode_i( fu_operand_mux_cgra_vec_mode_i ),
    .clk( fu_operand_mux_clk ),
    .ex_constant_i( fu_operand_mux_ex_constant_i ),
    .ex_operand_b_i( fu_operand_mux_ex_operand_b_i ),
    .ex_operand_b_o( fu_operand_mux_ex_operand_b_o ),
    .ex_operand_b_pred_i( fu_operand_mux_ex_operand_b_pred_i ),
    .ex_operand_b_pred_o( fu_operand_mux_ex_operand_b_pred_o ),
    .ex_operand_b_repl( fu_operand_mux_ex_operand_b_repl ),
    .ex_operand_b_sel( fu_operand_mux_ex_operand_b_sel ),
    .ex_operand_c_i( fu_operand_mux_ex_operand_c_i ),
    .ex_operand_c_o( fu_operand_mux_ex_operand_c_o ),
    .ex_operand_c_pred_i( fu_operand_mux_ex_operand_c_pred_i ),
    .ex_operand_c_pred_o( fu_operand_mux_ex_operand_c_pred_o ),
    .ex_operand_c_repl( fu_operand_mux_ex_operand_c_repl ),
    .ex_operand_c_sel( fu_operand_mux_ex_operand_c_sel ),
    .reset( fu_operand_mux_reset )
  );


  
  always_comb begin : _lambda__s_tile_0__element_fu_0_opt_launch_en_i
    fu_0__opt_launch_en_i = fu_launch_en_vector[1'd0] & ( ~fu_launch_done );
  end

  
  always_comb begin : _lambda__s_tile_0__element_fu_0_output_rdy_i
    fu_0__output_rdy_i = send_port_ack & fu_out_routine[1'd0];
  end

  
  always_comb begin : _lambda__s_tile_0__element_fu_1_opt_launch_en_i
    fu_1__opt_launch_en_i = fu_launch_en_vector[1'd1] & ( ~fu_launch_done );
  end

  
  always_comb begin : _lambda__s_tile_0__element_fu_1_output_rdy_i
    fu_1__output_rdy_i = send_port_ack & fu_out_routine[1'd1];
  end

  
  always_comb begin : _lambda__s_tile_0__element_fu_decoder_id_operator_i
    fu_decoder_id_operator_i = recv_opt_msg_ctrl & { { 8 { fu_opt_enable[0] } }, fu_opt_enable };
  end

  
  always_comb begin : data_routing
    for ( int unsigned i = 1'd0; i < 3'( __const__num_xbar_outports_at_data_routing ); i += 1'd1 )
      fu_xbar_send_data[2'(i)] = { 64'd0, 8'd0 };
    for ( int unsigned i = 1'd0; i < 2'( __const__num_outports_at_data_routing ); i += 1'd1 )
      send_port_data[1'(i)] = { 64'd0, 8'd0 };
    if ( fu_xbar_mesh_in_valid & ( ~fu_launch_done ) ) begin
      for ( int unsigned i = 1'd0; i < 3'( __const__num_xbar_outports_at_data_routing ); i += 1'd1 )
        for ( int unsigned j = 1'd0; j < 3'( __const__num_xbar_inports_at_data_routing ); j += 1'd1 ) begin
          fu_xbar_send_data[2'(i)].payload = fu_xbar_send_data[2'(i)].payload | ( recv_port_data[2'(j)].payload & { { 63 { fu_xbar_outport_sel[2'(i)][2'(j)] } }, fu_xbar_outport_sel[2'(i)][2'(j)] } );
          fu_xbar_send_data[2'(i)].predicate = fu_xbar_send_data[2'(i)].predicate | ( recv_port_data[2'(j)].predicate & { { 7 { fu_xbar_outport_sel[2'(i)][2'(j)] } }, fu_xbar_outport_sel[2'(i)][2'(j)] } );
        end
    end
    for ( int unsigned i = 1'd0; i < 2'( __const__num_outports_at_data_routing ); i += 1'd1 ) begin
      send_port_data[1'(i)].payload = send_port_data[1'(i)].payload | ( fu_0__send_out__msg[1'(i)].payload & { { 63 { fu_send_port_valid_vector[1'(i)][1'd0] } }, fu_send_port_valid_vector[1'(i)][1'd0] } );
      send_port_data[1'(i)].predicate = send_port_data[1'(i)].predicate | ( fu_0__send_out__msg[1'(i)].predicate & { { 7 { fu_send_port_valid_vector[1'(i)][1'd0] } }, fu_send_port_valid_vector[1'(i)][1'd0] } );
      send_port_data[1'(i)].payload = send_port_data[1'(i)].payload | ( fu_1__send_out__msg[1'(i)].payload & { { 63 { fu_send_port_valid_vector[1'(i)][1'd1] } }, fu_send_port_valid_vector[1'(i)][1'd1] } );
      send_port_data[1'(i)].predicate = send_port_data[1'(i)].predicate | ( fu_1__send_out__msg[1'(i)].predicate & { { 7 { fu_send_port_valid_vector[1'(i)][1'd1] } }, fu_send_port_valid_vector[1'(i)][1'd1] } );
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
    fu_launch_done = 1'd0;
    fu_send_out_done = 1'd0;
    if ( cur_stage == 2'( __const__STAGE_WAIT_FOR_FU ) ) begin
      fu_launch_done = 1'd1;
    end
    if ( cur_stage == 2'( __const__STAGE_WAIT_FOR_NXT ) ) begin
      fu_launch_done = 1'd1;
      fu_send_out_done = 1'd1;
    end
  end

  
  always_comb begin : fsm_nxt_stage
    nxt_stage = cur_stage;
    if ( cur_stage == 2'( __const__STAGE_NORMAL ) ) begin
      if ( fu_launch_ack & ( ~fu_send_out_ack ) ) begin
        nxt_stage = 2'( __const__STAGE_WAIT_FOR_FU );
      end
      if ( ( fu_launch_ack & fu_send_out_ack ) & ( ~fu_propagate_en ) ) begin
        nxt_stage = 2'( __const__STAGE_WAIT_FOR_NXT );
      end
    end
    if ( cur_stage == 2'( __const__STAGE_WAIT_FOR_FU ) ) begin
      if ( fu_send_out_ack ) begin
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
      fu_send_port_valid_vector[1'(port)] = 2'd0;
    for ( int unsigned i = 1'd0; i < 3'( __const__num_xbar_inports_at_handshake_process ); i += 1'd1 )
      xbar_recv_port_req[2'(i)] = ( | fu_xbar_inport_sel[2'(i)] );
    for ( int unsigned port = 1'd0; port < 2'( __const__num_outports_at_handshake_process ); port += 1'd1 ) begin
      fu_send_port_valid_vector[1'(port)][1'd0] = fu_0__send_out__en[1'(port)] & fu_out_routine[1'd0];
      fu_send_port_valid_vector[1'(port)][1'd1] = fu_1__send_out__en[1'(port)] & fu_out_routine[1'd1];
    end
    for ( int unsigned i = 1'd0; i < 2'( __const__num_outports_at_handshake_process ); i += 1'd1 )
      send_port_valid[1'(i)] = ( | fu_send_port_valid_vector[1'(i)] );
    fu_handshake_vector_xbar_mesh_in_valid_met = xbar_recv_port_req & ( ~recv_port_valid );
    fu_xbar_mesh_in_valid = ( ( ~( | fu_handshake_vector_xbar_mesh_in_valid_met ) ) & ( ( ~fu_xbar_recv_predicate_req ) | recv_predicate_valid ) ) | fu_dry_run_ack;
    fu_launch_ack = ( & fu_launch_rdy_vector ) & ( ~fu_launch_done );
    fu_launch_finish = fu_launch_ack | fu_launch_done;
    fu_send_out_ack = ( ~( & fu_out_routine ) ) | send_port_ack;
    fu_send_out_finish = fu_send_out_ack | fu_send_out_done;
    recv_port_ack = xbar_recv_port_req & { { 3 { fu_launch_ack[0] } }, fu_launch_ack };
    recv_const_ack = fu_xbar_recv_const_req & fu_launch_ack;
    recv_predicate_ack = fu_xbar_recv_predicate_req & fu_launch_ack;
    fu_propagate_rdy = fu_launch_finish & fu_send_out_finish;
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
      fu_out_routine <= 2'd0;
      ex_alu_operator <= 7'd0;
      ex_alu_bmask <= 5'd0;
      ex_alu_enable <= 1'd0;
      ex_operand_b_sel <= 1'd0;
      ex_operand_c_sel <= 2'd0;
      ex_operand_b_repl <= 1'd0;
      ex_operand_c_repl <= 1'd0;
      ex_mult_operator <= 4'd0;
      ex_mult_bmask <= 5'd0;
      ex_mult_enable <= 1'd0;
      ex_signed_mode <= 2'd0;
      ex_vec_mode <= 2'd0;
    end
    else if ( fu_propagate_en ) begin
      for ( int unsigned i = 1'd0; i < 3'( __const__num_xbar_outports_at_fu_propagate_sync ); i += 1'd1 )
        fu_xbar_outport_sel[2'(i)] <= fu_xbar_outport_sel_nxt[2'(i)];
      fu_xbar_recv_const_req <= fu_recv_const_req_nxt;
      fu_xbar_recv_predicate_req <= recv_predicate_req_nxt;
      fu_out_routine <= recv_opt_msg_out_routine;
      ex_alu_operator <= id_alu_operator;
      ex_alu_bmask <= id_alu_bmask;
      ex_alu_enable <= id_alu_enable;
      ex_operand_b_sel <= id_operand_b_sel;
      ex_operand_c_sel <= id_operand_c_sel;
      ex_operand_b_repl <= id_operand_b_repl;
      ex_operand_c_repl <= id_operand_c_repl;
      ex_mult_operator <= id_mult_operator;
      ex_mult_bmask <= id_mult_bmask;
      ex_mult_enable <= id_mult_enable;
      ex_signed_mode <= cgra_signed_mode_i;
      ex_vec_mode <= cgra_vec_mode_i;
    end
  end

  assign fu_0__clk = clk;
  assign fu_0__reset = reset;
  assign fu_1__clk = clk;
  assign fu_1__reset = reset;
  assign fu_decoder_clk = clk;
  assign fu_decoder_reset = reset;
  assign fu_operand_mux_clk = clk;
  assign fu_operand_mux_reset = reset;
  assign fu_decoder_cgra_signed_mode_i = cgra_signed_mode_i;
  assign fu_decoder_cgra_vec_mode_i = cgra_vec_mode_i;
  assign fu_decoder_cgra_bmask_i = cgra_bmask_i;
  assign fu_recv_const_req_nxt = fu_decoder_id_const_enable_o;
  assign id_alu_operator = fu_decoder_id_alu_operator_o;
  assign id_alu_bmask = fu_decoder_id_alu_bmask_o;
  assign id_operand_b_sel = fu_decoder_id_operand_b_sel_o;
  assign id_operand_c_sel = fu_decoder_id_operand_c_sel_o;
  assign id_operand_b_repl = fu_decoder_id_operand_b_repl_o;
  assign id_operand_c_repl = fu_decoder_id_operand_c_repl_o;
  assign id_mult_operator = fu_decoder_id_mult_operator_o;
  assign id_mult_bmask = fu_decoder_id_mult_bmask_o;
  assign id_mult_enable = fu_decoder_id_mult_enable_o;
  assign fu_launch_en_vector[0:0] = ex_alu_enable;
  assign fu_launch_en_vector[1:1] = ex_mult_enable;
  assign fu_operand_mux_cgra_vec_mode_i = cgra_vec_mode_i;
  assign fu_operand_mux_ex_operand_b_sel = ex_operand_b_sel;
  assign fu_operand_mux_ex_operand_c_sel = ex_operand_c_sel;
  assign fu_operand_mux_ex_operand_b_repl = ex_operand_b_repl;
  assign fu_operand_mux_ex_operand_c_repl = ex_operand_c_repl;
  assign fu_operand_mux_ex_operand_b_i = fu_xbar_send_data[1].payload;
  assign fu_operand_mux_ex_operand_c_i = fu_xbar_send_data[2].payload;
  assign fu_operand_mux_ex_operand_b_pred_i = fu_xbar_send_data[1].predicate;
  assign fu_operand_mux_ex_operand_c_pred_i = fu_xbar_send_data[2].predicate;
  assign fu_operand_mux_ex_constant_i = recv_const_data;
  assign fu_0__recv_predicate_msg = recv_predicate_data;
  assign fu_0__recv_predicate_en = fu_xbar_recv_predicate_req;
  assign fu_0__input_valid_i = fu_xbar_mesh_in_valid;
  assign fu_0__vector_mode_i = ex_vec_mode;
  assign fu_launch_rdy_vector[0:0] = fu_0__opt_launch_rdy_o;
  assign fu_1__recv_predicate_msg = recv_predicate_data;
  assign fu_1__recv_predicate_en = fu_xbar_recv_predicate_req;
  assign fu_1__input_valid_i = fu_xbar_mesh_in_valid;
  assign fu_1__vector_mode_i = ex_vec_mode;
  assign fu_launch_rdy_vector[1:1] = fu_1__opt_launch_rdy_o;
  assign fu_0__ex_operator_i = ex_alu_operator;
  assign fu_0__operand_a_i = fu_xbar_send_data[0];
  assign fu_0__operand_b_i.payload = fu_operand_mux_ex_operand_b_o;
  assign fu_0__operand_b_i.predicate = fu_operand_mux_ex_operand_b_pred_o;
  assign fu_0__bmask_b_i = ex_alu_bmask;
  assign fu_1__ex_operator_i = ex_mult_operator;
  assign fu_1__operand_a_i = fu_xbar_send_data[0];
  assign fu_1__operand_b_i.payload = fu_operand_mux_ex_operand_b_o;
  assign fu_1__operand_b_i.predicate = fu_operand_mux_ex_operand_b_pred_o;
  assign fu_1__operand_c_i.payload = fu_operand_mux_ex_operand_c_o;
  assign fu_1__operand_c_i.predicate = fu_operand_mux_ex_operand_c_pred_o;
  assign fu_1__r_imm_i = ex_alu_bmask;
  assign fu_1__imm_i = ex_alu_bmask;
  assign fu_1__ex_operand_signed_i = ex_signed_mode;

endmodule



module Mux__Type_CGRAData_64_8__payload_64__predicate_8__ninputs_2
(
  input  logic [0:0] clk ,
  input  CGRAData_64_8__payload_64__predicate_8 in_ [0:1],
  output CGRAData_64_8__payload_64__predicate_8 out ,
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



module NormalQueueDpath__78653061d6c86e67
(
  input  logic [0:0] clk ,
  input  logic [0:0] config_ini ,
  output CGRAData_8__predicate_8 deq_msg ,
  input  CGRAData_8__predicate_8 enq_msg ,
  input  logic [0:0] raddr ,
  input  logic [0:0] ren ,
  input  logic [0:0] reset ,
  input  logic [0:0] waddr ,
  input  logic [0:0] wen 
);
  localparam logic [1:0] __const__num_entries_at_up_rf_write  = 2'd2;
  CGRAData_8__predicate_8 regs [0:1];
  CGRAData_8__predicate_8 regs_rdata;

  
  always_comb begin : reg_read
    if ( reset ) begin
      deq_msg = 8'd0;
    end
    else
      deq_msg = regs[raddr];
  end

  
  always_ff @(posedge clk) begin : up_rf_write
    if ( reset | config_ini ) begin
      for ( int unsigned i = 1'd0; i < 2'( __const__num_entries_at_up_rf_write ); i += 1'd1 )
        regs[1'(i)] <= 8'd0;
    end
    else if ( wen ) begin
      regs[waddr] <= enq_msg;
    end
  end

endmodule



module NormalQueue__e085cf096285f66d
(
  input  logic [0:0] clk ,
  input  logic [0:0] config_ini ,
  input  logic [0:0] deq_en ,
  output CGRAData_8__predicate_8 deq_msg ,
  output logic [0:0] deq_valid ,
  input  logic [0:0] dry_run_done ,
  input  logic [0:0] enq_en ,
  input  CGRAData_8__predicate_8 enq_msg ,
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
  CGRAData_8__predicate_8 dpath__deq_msg;
  CGRAData_8__predicate_8 dpath__enq_msg;
  logic [0:0] dpath__raddr;
  logic [0:0] dpath__ren;
  logic [0:0] dpath__reset;
  logic [0:0] dpath__waddr;
  logic [0:0] dpath__wen;

  NormalQueueDpath__78653061d6c86e67 dpath
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



module ChannelRTL__cd9fb5c905a4d671
(
  input  logic [0:0] clk ,
  input  logic [0:0] config_ini ,
  input  logic [0:0] dry_run_done ,
  input  logic [0:0] recv_en ,
  input  CGRAData_8__predicate_8 recv_msg ,
  output logic [0:0] recv_rdy ,
  input  logic [0:0] reset ,
  input  logic [0:0] send_en ,
  output CGRAData_8__predicate_8 send_msg ,
  output logic [0:0] send_valid ,
  input  logic [0:0] sync_dry_run 
);

  logic [0:0] queue__clk;
  logic [0:0] queue__config_ini;
  logic [0:0] queue__deq_en;
  CGRAData_8__predicate_8 queue__deq_msg;
  logic [0:0] queue__deq_valid;
  logic [0:0] queue__dry_run_done;
  logic [0:0] queue__enq_en;
  CGRAData_8__predicate_8 queue__enq_msg;
  logic [0:0] queue__enq_rdy;
  logic [0:0] queue__reset;
  logic [0:0] queue__sync_dry_run;

  NormalQueue__e085cf096285f66d queue
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



module Mux__Type_CGRAConfig_9_4_6_8_2__cebbeedc2b62cdce__ninputs_2
(
  input  logic [0:0] clk ,
  input  CGRAConfig_9_4_6_8_2__cebbeedc2b62cdce in_ [0:1],
  output CGRAConfig_9_4_6_8_2__cebbeedc2b62cdce out ,
  input  logic [0:0] reset ,
  input  logic [0:0] sel 
);

  
  always_comb begin : up_mux
    out = in_[sel];
  end

endmodule



module TileRTL__abec5b90cb577887
(
  input  logic [0:0] clk ,
  input  logic [5:0] config_cmd_counter_th ,
  input  logic [5:0] config_data_counter_th ,
  input  logic [0:0] ctrl_slice_idx ,
  input  logic [31:0] recv_const ,
  input  logic [0:0] recv_const_en ,
  input  logic [4:0] recv_const_waddr ,
  input  CGRAData_64_8__payload_64__predicate_8 recv_data [0:3],
  output logic [0:0] recv_data_ack [0:3],
  input  logic [0:0] recv_data_valid [0:3],
  input  logic [4:0] recv_opt_waddr ,
  input  logic [0:0] recv_opt_waddr_en ,
  input  logic [31:0] recv_wopt ,
  input  logic [0:0] recv_wopt_en ,
  input  logic [0:0] reset ,
  output CGRAData_64_8__payload_64__predicate_8 send_data [0:3],
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
  input CGRAData_64_8__payload_64__predicate_8 from_mem_rdata__msg  ,
  output logic [0:0] from_mem_rdata__rdy  ,
  output logic [0:0] to_mem_raddr__en  ,
  output logic [6:0] to_mem_raddr__msg  ,
  input logic [0:0] to_mem_raddr__rdy  ,
  output logic [0:0] to_mem_waddr__en  ,
  output logic [6:0] to_mem_waddr__msg  ,
  input logic [0:0] to_mem_waddr__rdy  ,
  output logic [0:0] to_mem_wdata__en  ,
  output CGRAData_64_8__payload_64__predicate_8 to_mem_wdata__msg  ,
  input logic [0:0] to_mem_wdata__rdy  
);
  CGRAConfig_9_4_6_8_2__cebbeedc2b62cdce tile_ctrl_msg;
  logic [0:0] tile_dry_run_begin;
  logic [0:0] tile_opt_enable;
  logic [0:0] tile_propagate_en;

  logic [0:0] channel__clk [0:7];
  logic [0:0] channel__config_ini [0:7];
  logic [0:0] channel__dry_run_done [0:7];
  logic [0:0] channel__recv_en [0:7];
  CGRAData_64_8__payload_64__predicate_8 channel__recv_msg [0:7];
  logic [0:0] channel__recv_rdy [0:7];
  logic [0:0] channel__reset [0:7];
  logic [0:0] channel__send_en [0:7];
  CGRAData_64_8__payload_64__predicate_8 channel__send_msg [0:7];
  logic [0:0] channel__send_valid [0:7];
  logic [0:0] channel__sync_dry_run [0:7];

  ChannelRTL__719f99a07587cea0 channel__0
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

  ChannelRTL__719f99a07587cea0 channel__1
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

  ChannelRTL__719f99a07587cea0 channel__2
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

  ChannelRTL__719f99a07587cea0 channel__3
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

  ChannelRTL__719f99a07587cea0 channel__4
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

  ChannelRTL__719f99a07587cea0 channel__5
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

  ChannelRTL__719f99a07587cea0 channel__6
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

  ChannelRTL__719f99a07587cea0 channel__7
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

  ConstQueueRTL__93536ce3c6007a21 const_queue
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
  CGRAData_64_8__payload_64__predicate_8 crossbar__recv_port_data [0:5];
  logic [0:0] crossbar__recv_port_fu_out_ack;
  logic [3:0] crossbar__recv_port_mesh_in_ack;
  logic [5:0] crossbar__recv_port_valid;
  logic [0:0] crossbar__reset;
  logic [3:0] crossbar__send_bypass_data_valid;
  logic [3:0] crossbar__send_bypass_port_ack;
  logic [3:0] crossbar__send_bypass_req;
  CGRAData_64_8__payload_64__predicate_8 crossbar__send_data_bypass [0:3];
  CGRAData_64_8__payload_64__predicate_8 crossbar__send_port_data [0:7];
  logic [8:0] crossbar__send_port_en;
  logic [7:0] crossbar__send_port_rdy;
  CGRAData_8__predicate_8 crossbar__send_predicate;
  logic [0:0] crossbar__send_predicate_rdy;
  logic [0:0] crossbar__xbar_dry_run_ack;
  logic [0:0] crossbar__xbar_dry_run_begin;
  logic [0:0] crossbar__xbar_opt_enable;
  logic [0:0] crossbar__xbar_propagate_en;
  logic [0:0] crossbar__xbar_propagate_rdy;

  CrossbarRTL__735efd555417ee9b crossbar
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
  CGRAConfig_9_4_6_8_2__cebbeedc2b62cdce ctrl_mem__recv_ctrl_msg;
  logic [31:0] ctrl_mem__recv_ctrl_slice;
  logic [0:0] ctrl_mem__recv_ctrl_slice_en;
  logic [0:0] ctrl_mem__recv_ctrl_slice_idx;
  logic [4:0] ctrl_mem__recv_waddr;
  logic [0:0] ctrl_mem__recv_waddr_en;
  logic [0:0] ctrl_mem__reset;
  CGRAConfig_9_4_6_8_2__cebbeedc2b62cdce ctrl_mem__send_ctrl_msg;

  CtrlMemRTL__7aace320cc2a8fb7 ctrl_mem
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



  logic [4:0] element__cgra_bmask_i;
  logic [1:0] element__cgra_signed_mode_i;
  logic [1:0] element__cgra_vec_mode_i;
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
  logic [8:0] element__recv_opt_msg_ctrl;
  logic [2:0] element__recv_opt_msg_fu_in [0:3];
  logic [1:0] element__recv_opt_msg_out_routine;
  logic [0:0] element__recv_opt_msg_predicate;
  logic [3:0] element__recv_port_ack;
  CGRAData_64_8__payload_64__predicate_8 element__recv_port_data [0:3];
  logic [3:0] element__recv_port_valid;
  logic [0:0] element__recv_predicate_ack;
  CGRAData_8__predicate_8 element__recv_predicate_data;
  logic [0:0] element__recv_predicate_valid;
  logic [0:0] element__reset;
  logic [0:0] element__send_port_ack;
  CGRAData_64_8__payload_64__predicate_8 element__send_port_data [0:1];
  logic [1:0] element__send_port_valid;

  CGRAFURTL__cb9d7ba75ff8e27e element
  (
    .cgra_bmask_i( element__cgra_bmask_i ),
    .cgra_signed_mode_i( element__cgra_signed_mode_i ),
    .cgra_vec_mode_i( element__cgra_vec_mode_i ),
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
    .send_port_valid( element__send_port_valid )
  );



  logic [0:0] mux_bypass_data__clk [0:3];
  CGRAData_64_8__payload_64__predicate_8 mux_bypass_data__in_ [0:3][0:1];
  CGRAData_64_8__payload_64__predicate_8 mux_bypass_data__out [0:3];
  logic [0:0] mux_bypass_data__reset [0:3];
  logic [0:0] mux_bypass_data__sel [0:3];

  Mux__Type_CGRAData_64_8__payload_64__predicate_8__ninputs_2 mux_bypass_data__0
  (
    .clk( mux_bypass_data__clk[0] ),
    .in_( mux_bypass_data__in_[0] ),
    .out( mux_bypass_data__out[0] ),
    .reset( mux_bypass_data__reset[0] ),
    .sel( mux_bypass_data__sel[0] )
  );

  Mux__Type_CGRAData_64_8__payload_64__predicate_8__ninputs_2 mux_bypass_data__1
  (
    .clk( mux_bypass_data__clk[1] ),
    .in_( mux_bypass_data__in_[1] ),
    .out( mux_bypass_data__out[1] ),
    .reset( mux_bypass_data__reset[1] ),
    .sel( mux_bypass_data__sel[1] )
  );

  Mux__Type_CGRAData_64_8__payload_64__predicate_8__ninputs_2 mux_bypass_data__2
  (
    .clk( mux_bypass_data__clk[2] ),
    .in_( mux_bypass_data__in_[2] ),
    .out( mux_bypass_data__out[2] ),
    .reset( mux_bypass_data__reset[2] ),
    .sel( mux_bypass_data__sel[2] )
  );

  Mux__Type_CGRAData_64_8__payload_64__predicate_8__ninputs_2 mux_bypass_data__3
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
  CGRAData_8__predicate_8 reg_predicate__recv_msg;
  logic [0:0] reg_predicate__recv_rdy;
  logic [0:0] reg_predicate__reset;
  logic [0:0] reg_predicate__send_en;
  CGRAData_8__predicate_8 reg_predicate__send_msg;
  logic [0:0] reg_predicate__send_valid;
  logic [0:0] reg_predicate__sync_dry_run;

  ChannelRTL__cd9fb5c905a4d671 reg_predicate
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
  CGRAConfig_9_4_6_8_2__cebbeedc2b62cdce tile_ctrl_mux__in_ [0:1];
  CGRAConfig_9_4_6_8_2__cebbeedc2b62cdce tile_ctrl_mux__out;
  logic [0:0] tile_ctrl_mux__reset;
  logic [0:0] tile_ctrl_mux__sel;

  Mux__Type_CGRAConfig_9_4_6_8_2__cebbeedc2b62cdce__ninputs_2 tile_ctrl_mux
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
  assign element__cgra_vec_mode_i = tile_ctrl_msg.vec_mode;
  assign element__cgra_bmask_i = tile_ctrl_msg.bmask;
  assign element__cgra_signed_mode_i = tile_ctrl_msg.signed_mode;
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
  assign tile_xbar_propagate_rdy = crossbar__xbar_propagate_rdy;
  assign tile_fu_propagate_rdy = element__fu_propagate_rdy;

endmodule



module CGRARTL__top
(
  output logic [31:0] cgra_csr_ro [0:3],
  input  logic [31:0] cgra_csr_rw [0:0],
  output logic [0:0] cgra_csr_rw_ack ,
  input  logic [0:0] cgra_csr_rw_valid ,
  input  logic [0:0] clk ,
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
  CGRAData_64_8__payload_64__predicate_8 tile__recv_data [0:15][0:3];
  logic [0:0] tile__recv_data_ack [0:15][0:3];
  logic [0:0] tile__recv_data_valid [0:15][0:3];
  logic [4:0] tile__recv_opt_waddr [0:15];
  logic [0:0] tile__recv_opt_waddr_en [0:15];
  logic [31:0] tile__recv_wopt [0:15];
  logic [0:0] tile__recv_wopt_en [0:15];
  logic [0:0] tile__reset [0:15];
  CGRAData_64_8__payload_64__predicate_8 tile__send_data [0:15][0:3];
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
  CGRAData_64_8__payload_64__predicate_8 tile__from_mem_rdata__msg [0:15];
  logic [0:0] tile__from_mem_rdata__rdy [0:15];
  logic [0:0] tile__to_mem_raddr__en [0:15];
  logic [6:0] tile__to_mem_raddr__msg [0:15];
  logic [0:0] tile__to_mem_raddr__rdy [0:15];
  logic [0:0] tile__to_mem_waddr__en [0:15];
  logic [6:0] tile__to_mem_waddr__msg [0:15];
  logic [0:0] tile__to_mem_waddr__rdy [0:15];
  logic [0:0] tile__to_mem_wdata__en [0:15];
  CGRAData_64_8__payload_64__predicate_8 tile__to_mem_wdata__msg [0:15];
  logic [0:0] tile__to_mem_wdata__rdy [0:15];

  TileRTL__abec5b90cb577887 tile__0
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

  TileRTL__abec5b90cb577887 tile__1
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

  TileRTL__abec5b90cb577887 tile__2
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

  TileRTL__abec5b90cb577887 tile__3
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

  TileRTL__abec5b90cb577887 tile__4
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

  TileRTL__abec5b90cb577887 tile__5
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

  TileRTL__abec5b90cb577887 tile__6
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

  TileRTL__abec5b90cb577887 tile__7
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

  TileRTL__abec5b90cb577887 tile__8
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

  TileRTL__abec5b90cb577887 tile__9
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

  TileRTL__abec5b90cb577887 tile__10
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

  TileRTL__abec5b90cb577887 tile__11
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

  TileRTL__abec5b90cb577887 tile__12
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

  TileRTL__abec5b90cb577887 tile__13
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

  TileRTL__abec5b90cb577887 tile__14
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

  TileRTL__abec5b90cb577887 tile__15
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
  assign tile__recv_data[0][1] = { 64'd0, 8'd0 };
  assign tile__send_data_ack[0][2] = 1'd0;
  assign tile_recv_ni_data_ack[0:0] = tile__recv_data_ack[0][2];
  assign tile__recv_data_valid[0][2] = cgra_recv_ni_data__en[0];
  assign tile__recv_data[0][2].payload = cgra_recv_ni_data__msg[0];
  assign tile__recv_data[0][2].predicate = 8'd0;
  assign tile__to_mem_raddr__rdy[0] = 1'd0;
  assign tile__from_mem_rdata__en[0] = 1'd0;
  assign tile__from_mem_rdata__msg[0] = { 64'd0, 8'd0 };
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
  assign tile__recv_data[1][1] = { 64'd0, 8'd0 };
  assign tile__to_mem_raddr__rdy[1] = 1'd0;
  assign tile__from_mem_rdata__en[1] = 1'd0;
  assign tile__from_mem_rdata__msg[1] = { 64'd0, 8'd0 };
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
  assign tile__recv_data[2][1] = { 64'd0, 8'd0 };
  assign tile__to_mem_raddr__rdy[2] = 1'd0;
  assign tile__from_mem_rdata__en[2] = 1'd0;
  assign tile__from_mem_rdata__msg[2] = { 64'd0, 8'd0 };
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
  assign tile__recv_data[3][1] = { 64'd0, 8'd0 };
  assign tile__send_data_ack[3][3] = cgra_send_ni_data__rdy[0];
  assign cgra_send_ni_data__en[0] = tile__send_data_valid[3][3];
  assign cgra_send_ni_data__msg[0] = tile__send_data[3][3].payload;
  assign tile__recv_data_valid[3][3] = 1'd0;
  assign tile__recv_data[3][3] = { 64'd0, 8'd0 };
  assign tile__to_mem_raddr__rdy[3] = 1'd0;
  assign tile__from_mem_rdata__en[3] = 1'd0;
  assign tile__from_mem_rdata__msg[3] = { 64'd0, 8'd0 };
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
  assign tile__recv_data[4][2].predicate = 8'd0;
  assign tile__to_mem_raddr__rdy[4] = 1'd0;
  assign tile__from_mem_rdata__en[4] = 1'd0;
  assign tile__from_mem_rdata__msg[4] = { 64'd0, 8'd0 };
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
  assign tile__from_mem_rdata__msg[5] = { 64'd0, 8'd0 };
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
  assign tile__from_mem_rdata__msg[6] = { 64'd0, 8'd0 };
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
  assign tile__recv_data[7][3] = { 64'd0, 8'd0 };
  assign tile__to_mem_raddr__rdy[7] = 1'd0;
  assign tile__from_mem_rdata__en[7] = 1'd0;
  assign tile__from_mem_rdata__msg[7] = { 64'd0, 8'd0 };
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
  assign tile__recv_data[8][2].predicate = 8'd0;
  assign tile__to_mem_raddr__rdy[8] = 1'd0;
  assign tile__from_mem_rdata__en[8] = 1'd0;
  assign tile__from_mem_rdata__msg[8] = { 64'd0, 8'd0 };
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
  assign tile__from_mem_rdata__msg[9] = { 64'd0, 8'd0 };
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
  assign tile__from_mem_rdata__msg[10] = { 64'd0, 8'd0 };
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
  assign tile__recv_data[11][3] = { 64'd0, 8'd0 };
  assign tile__to_mem_raddr__rdy[11] = 1'd0;
  assign tile__from_mem_rdata__en[11] = 1'd0;
  assign tile__from_mem_rdata__msg[11] = { 64'd0, 8'd0 };
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
  assign tile__recv_data[12][0].predicate = 8'd0;
  assign tile__send_data_ack[12][2] = 1'd0;
  assign tile_recv_ni_data_ack[3:3] = tile__recv_data_ack[12][2];
  assign tile__recv_data_valid[12][2] = cgra_recv_ni_data__en[3];
  assign tile__recv_data[12][2].payload = cgra_recv_ni_data__msg[3];
  assign tile__recv_data[12][2].predicate = 8'd0;
  assign tile__to_mem_raddr__rdy[12] = 1'd0;
  assign tile__from_mem_rdata__en[12] = 1'd0;
  assign tile__from_mem_rdata__msg[12] = { 64'd0, 8'd0 };
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
  assign tile__recv_data[13][0].predicate = 8'd0;
  assign tile__to_mem_raddr__rdy[13] = 1'd0;
  assign tile__from_mem_rdata__en[13] = 1'd0;
  assign tile__from_mem_rdata__msg[13] = { 64'd0, 8'd0 };
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
  assign tile__recv_data[14][0].predicate = 8'd0;
  assign tile__to_mem_raddr__rdy[14] = 1'd0;
  assign tile__from_mem_rdata__en[14] = 1'd0;
  assign tile__from_mem_rdata__msg[14] = { 64'd0, 8'd0 };
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
  assign tile__recv_data[15][0].predicate = 8'd0;
  assign tile__send_data_ack[15][3] = cgra_send_ni_data__rdy[3];
  assign cgra_send_ni_data__en[3] = tile__send_data_valid[15][3];
  assign cgra_send_ni_data__msg[3] = tile__send_data[15][3].payload;
  assign tile__recv_data_valid[15][3] = 1'd0;
  assign tile__recv_data[15][3] = { 64'd0, 8'd0 };
  assign tile__to_mem_raddr__rdy[15] = 1'd0;
  assign tile__from_mem_rdata__en[15] = 1'd0;
  assign tile__from_mem_rdata__msg[15] = { 64'd0, 8'd0 };
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
