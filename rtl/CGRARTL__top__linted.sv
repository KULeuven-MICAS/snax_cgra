
typedef struct packed {
  logic [63:0] payload;
  logic [0:0] predicate;
} CGRAData_64_1__payload_64__predicate_1;

typedef struct packed {
  logic [9:0] ctrl;
  logic [0:0] predicate;
  logic [2:0][2:0] fu_in;
  logic [8:0][2:0] outport;
  logic [3:0] fu_in_nupd;
  logic [2:0] out_routine;
  logic [1:0] vec_mode;
  logic [1:0] signed_mode;
  logic [5:0] o_imm_bmask;
} CGRAConfig_10_3_6_8_3__877613aa0dfe8ae0;

typedef struct packed {
  logic [0:0] predicate;
} CGRAData_1__predicate_1;


module LookUpTableRTL__3312552a84abe6da
(
  input  logic [0:0] clk ,
  input  logic [511:0] recv_lut_data ,
  input  logic [1:0] recv_raddr [0:15],
  input  logic [1:0] recv_waddr ,
  input  logic [0:0] recv_waddr_en ,
  input  logic [0:0] reset ,
  output logic [127:0] send_lut_b [0:15],
  output logic [127:0] send_lut_k [0:15],
  output logic [127:0] send_lut_p [0:15]
);
  localparam logic [2:0] __const__lut_type_at_lut_write  = 3'd4;
  localparam logic [1:0] __const__lut_array_depth_at_lut_write  = 2'd3;
  localparam logic [2:0] __const__width_at_lut_read  = 3'd4;
  localparam logic [2:0] __const__height_at_lut_read  = 3'd4;
  logic [127:0] recv_lut_data_unit [0:3];
  logic [127:0] reg_file [0:3][0:2];

  
  always_comb begin : lut_read
    for ( int unsigned i = 1'd0; i < 3'( __const__width_at_lut_read ) * 3'( __const__height_at_lut_read ); i += 1'd1 ) begin
      send_lut_k[4'(i)] = reg_file[recv_raddr[4'(i)]][2'd0];
      send_lut_b[4'(i)] = reg_file[recv_raddr[4'(i)]][2'd1];
      send_lut_p[4'(i)] = reg_file[recv_raddr[4'(i)]][2'd2];
    end
  end

  
  always_ff @(posedge clk) begin : lut_write
    if ( reset ) begin
      for ( int unsigned i = 1'd0; i < 3'( __const__lut_type_at_lut_write ); i += 1'd1 )
        for ( int unsigned j = 1'd0; j < 2'( __const__lut_array_depth_at_lut_write ); j += 1'd1 )
          reg_file[2'(i)][2'(j)] <= 128'd0;
    end
    else if ( recv_waddr_en ) begin
      for ( int unsigned i = 1'd0; i < 3'( __const__lut_type_at_lut_write ); i += 1'd1 )
        reg_file[2'(i)][recv_waddr] <= recv_lut_data_unit[2'(i)];
    end
  end

  assign recv_lut_data_unit[0] = recv_lut_data[127:0];
  assign recv_lut_data_unit[1] = recv_lut_data[255:128];
  assign recv_lut_data_unit[2] = recv_lut_data[383:256];
  assign recv_lut_data_unit[3] = recv_lut_data[511:384];

endmodule



module NormalQueueCtrl__num_entries_2__dry_run_enable_True
(
  input  logic [0:0] clk ,
  input  logic [0:0] dry_run_ack ,
  input  logic [0:0] dry_run_done ,
  input  logic [0:0] local_reset_ctrl ,
  input  logic [0:0] local_reset_stage ,
  output logic [0:0] raddr ,
  input  logic [0:0] recv_en_i ,
  output logic [0:0] recv_rdy_o ,
  output logic [0:0] ren ,
  input  logic [0:0] reset ,
  input  logic [0:0] send_en_i ,
  output logic [0:0] send_valid_o ,
  input  logic [0:0] sync_dry_run ,
  output logic [0:0] waddr ,
  output logic [0:0] wen 
);
  logic [1:0] count;
  logic [0:0] count_en;
  logic [1:0] count_ini;
  logic [1:0] count_nxt;
  logic [0:0] deq_valid;
  logic [0:0] deq_valid_en;
  logic [0:0] deq_valid_nxt;
  logic [0:0] deq_xfer;
  logic [0:0] enq_rdy;
  logic [0:0] enq_rdy_en;
  logic [0:0] enq_rdy_nxt;
  logic [0:0] enq_xfer;
  logic [0:0] head;
  logic [0:0] head_ini;
  logic [0:0] tail;
  logic [0:0] tail_ini;

  
  always_comb begin : _lambda__s_tile_0__channel_a_0__queue_ctrl_send_valid_o
    send_valid_o = deq_valid | dry_run_ack;
  end

  
  always_comb begin : async_update
    enq_xfer = recv_en_i & enq_rdy;
    deq_xfer = send_en_i & deq_valid;
    count_en = enq_xfer ^ deq_xfer;
    enq_rdy_en = deq_xfer | enq_rdy;
    deq_valid_en = enq_xfer | deq_valid;
    count_nxt = count;
    if ( enq_xfer & ( ~deq_xfer ) ) begin
      count_nxt = count + 2'd1;
    end
    if ( ( ~enq_xfer ) & deq_xfer ) begin
      count_nxt = count - 2'd1;
    end
    enq_rdy_nxt = count_nxt < 2'd2;
    deq_valid_nxt = count_nxt > 2'd0;
  end

  
  always_ff @(posedge clk) begin : dry_run_reg
    if ( reset | local_reset_ctrl ) begin
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

  
  always_ff @(posedge clk) begin : sync_ctrl
    if ( reset | local_reset_stage ) begin
      enq_rdy <= 1'd1;
      deq_valid <= 1'd0;
    end
    else begin
      if ( enq_rdy_en ) begin
        enq_rdy <= enq_rdy_nxt;
      end
      if ( deq_valid_en ) begin
        deq_valid <= deq_valid_nxt;
      end
    end
  end

  
  always_ff @(posedge clk) begin : sync_reg
    if ( reset | local_reset_stage ) begin
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
      if ( count_en ) begin
        count <= count_nxt;
      end
    end
  end

  assign wen = enq_xfer;
  assign ren = deq_xfer;
  assign waddr = tail;
  assign raddr = head;
  assign recv_rdy_o = enq_rdy;

endmodule



module NormalQueueDpath__667be9aa0698ac40
(
  input  logic [0:0] clk ,
  output CGRAData_64_1__payload_64__predicate_1 deq_msg ,
  input  CGRAData_64_1__payload_64__predicate_1 enq_msg ,
  input  logic [0:0] local_reset_data ,
  input  logic [0:0] raddr ,
  input  logic [0:0] ren ,
  input  logic [0:0] reset ,
  input  logic [0:0] waddr ,
  input  logic [0:0] wen 
);
  localparam CGRAData_64_1__payload_64__predicate_1 default_value  = { 64'd0, 1'd1 };
  localparam logic [1:0] __const__num_entries_at_up_rf_write  = 2'd2;
  CGRAData_64_1__payload_64__predicate_1 regs [0:1];
  CGRAData_64_1__payload_64__predicate_1 regs_rdata;

  
  always_comb begin : _lambda__s_tile_0__channel_a_0__queue_dpath_deq_msg
    deq_msg = regs[raddr];
  end

  
  always_ff @(posedge clk) begin : up_rf_write
    if ( reset | local_reset_data ) begin
      for ( int unsigned i = 1'd0; i < 2'( __const__num_entries_at_up_rf_write ); i += 1'd1 )
        regs[1'(i)] <= default_value;
    end
    else if ( wen ) begin
      regs[waddr] <= enq_msg;
    end
  end

endmodule



module NormalQueue__89ec7419267774bb
(
  input  logic [0:0] clk ,
  input  logic [0:0] dry_run_ack ,
  input  logic [0:0] dry_run_done ,
  input  logic [0:0] local_reset_b ,
  input  logic [0:0] local_reset_c ,
  input  logic [0:0] recv_en_i ,
  input  CGRAData_64_1__payload_64__predicate_1 recv_msg ,
  output logic [0:0] recv_rdy_o ,
  input  logic [0:0] reset ,
  input  logic [0:0] send_en_i ,
  output CGRAData_64_1__payload_64__predicate_1 send_msg ,
  output logic [0:0] send_valid_o ,
  input  logic [0:0] sync_dry_run 
);

  logic [0:0] ctrl__clk;
  logic [0:0] ctrl__dry_run_ack;
  logic [0:0] ctrl__dry_run_done;
  logic [0:0] ctrl__local_reset_ctrl;
  logic [0:0] ctrl__local_reset_stage;
  logic [0:0] ctrl__raddr;
  logic [0:0] ctrl__recv_en_i;
  logic [0:0] ctrl__recv_rdy_o;
  logic [0:0] ctrl__ren;
  logic [0:0] ctrl__reset;
  logic [0:0] ctrl__send_en_i;
  logic [0:0] ctrl__send_valid_o;
  logic [0:0] ctrl__sync_dry_run;
  logic [0:0] ctrl__waddr;
  logic [0:0] ctrl__wen;

  NormalQueueCtrl__num_entries_2__dry_run_enable_True ctrl
  (
    .clk( ctrl__clk ),
    .dry_run_ack( ctrl__dry_run_ack ),
    .dry_run_done( ctrl__dry_run_done ),
    .local_reset_ctrl( ctrl__local_reset_ctrl ),
    .local_reset_stage( ctrl__local_reset_stage ),
    .raddr( ctrl__raddr ),
    .recv_en_i( ctrl__recv_en_i ),
    .recv_rdy_o( ctrl__recv_rdy_o ),
    .ren( ctrl__ren ),
    .reset( ctrl__reset ),
    .send_en_i( ctrl__send_en_i ),
    .send_valid_o( ctrl__send_valid_o ),
    .sync_dry_run( ctrl__sync_dry_run ),
    .waddr( ctrl__waddr ),
    .wen( ctrl__wen )
  );



  logic [0:0] dpath__clk;
  CGRAData_64_1__payload_64__predicate_1 dpath__deq_msg;
  CGRAData_64_1__payload_64__predicate_1 dpath__enq_msg;
  logic [0:0] dpath__local_reset_data;
  logic [0:0] dpath__raddr;
  logic [0:0] dpath__ren;
  logic [0:0] dpath__reset;
  logic [0:0] dpath__waddr;
  logic [0:0] dpath__wen;

  NormalQueueDpath__667be9aa0698ac40 dpath
  (
    .clk( dpath__clk ),
    .deq_msg( dpath__deq_msg ),
    .enq_msg( dpath__enq_msg ),
    .local_reset_data( dpath__local_reset_data ),
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
  assign dpath__local_reset_data = local_reset_b;
  assign ctrl__local_reset_stage = local_reset_b;
  assign ctrl__local_reset_ctrl = local_reset_c;
  assign ctrl__dry_run_ack = dry_run_ack;
  assign ctrl__dry_run_done = dry_run_done;
  assign ctrl__sync_dry_run = sync_dry_run;
  assign dpath__wen = ctrl__wen;
  assign dpath__ren = ctrl__ren;
  assign dpath__waddr = ctrl__waddr;
  assign dpath__raddr = ctrl__raddr;
  assign ctrl__recv_en_i = recv_en_i;
  assign recv_rdy_o = ctrl__recv_rdy_o;
  assign ctrl__send_en_i = send_en_i;
  assign send_valid_o = ctrl__send_valid_o;
  assign dpath__enq_msg = recv_msg;
  assign send_msg = dpath__deq_msg;

endmodule



module ChannelRTL__511b7cda5540ec2e
(
  input  logic [0:0] clk ,
  input  logic [0:0] dry_run_ack ,
  input  logic [0:0] dry_run_done ,
  input  logic [0:0] local_reset_b ,
  input  logic [0:0] local_reset_c ,
  input  logic [0:0] recv_en_i ,
  input  CGRAData_64_1__payload_64__predicate_1 recv_msg ,
  output logic [0:0] recv_rdy_o ,
  input  logic [0:0] reset ,
  input  logic [0:0] send_en_i ,
  output CGRAData_64_1__payload_64__predicate_1 send_msg ,
  output logic [0:0] send_valid_o ,
  input  logic [0:0] sync_dry_run 
);

  logic [0:0] queue__clk;
  logic [0:0] queue__dry_run_ack;
  logic [0:0] queue__dry_run_done;
  logic [0:0] queue__local_reset_b;
  logic [0:0] queue__local_reset_c;
  logic [0:0] queue__recv_en_i;
  CGRAData_64_1__payload_64__predicate_1 queue__recv_msg;
  logic [0:0] queue__recv_rdy_o;
  logic [0:0] queue__reset;
  logic [0:0] queue__send_en_i;
  CGRAData_64_1__payload_64__predicate_1 queue__send_msg;
  logic [0:0] queue__send_valid_o;
  logic [0:0] queue__sync_dry_run;

  NormalQueue__89ec7419267774bb queue
  (
    .clk( queue__clk ),
    .dry_run_ack( queue__dry_run_ack ),
    .dry_run_done( queue__dry_run_done ),
    .local_reset_b( queue__local_reset_b ),
    .local_reset_c( queue__local_reset_c ),
    .recv_en_i( queue__recv_en_i ),
    .recv_msg( queue__recv_msg ),
    .recv_rdy_o( queue__recv_rdy_o ),
    .reset( queue__reset ),
    .send_en_i( queue__send_en_i ),
    .send_msg( queue__send_msg ),
    .send_valid_o( queue__send_valid_o ),
    .sync_dry_run( queue__sync_dry_run )
  );


  assign queue__clk = clk;
  assign queue__reset = reset;
  assign queue__recv_en_i = recv_en_i;
  assign queue__recv_msg = recv_msg;
  assign recv_rdy_o = queue__recv_rdy_o;
  assign queue__send_en_i = send_en_i;
  assign send_msg = queue__send_msg;
  assign send_valid_o = queue__send_valid_o;
  assign queue__local_reset_b = local_reset_b;
  assign queue__local_reset_c = local_reset_c;
  assign queue__dry_run_ack = dry_run_ack;
  assign queue__dry_run_done = dry_run_done;
  assign queue__sync_dry_run = sync_dry_run;

endmodule



module NormalQueueCtrl__num_entries_4__dry_run_enable_True
(
  input  logic [0:0] clk ,
  input  logic [0:0] dry_run_ack ,
  input  logic [0:0] dry_run_done ,
  input  logic [0:0] local_reset_ctrl ,
  input  logic [0:0] local_reset_stage ,
  output logic [1:0] raddr ,
  input  logic [0:0] recv_en_i ,
  output logic [0:0] recv_rdy_o ,
  output logic [0:0] ren ,
  input  logic [0:0] reset ,
  input  logic [0:0] send_en_i ,
  output logic [0:0] send_valid_o ,
  input  logic [0:0] sync_dry_run ,
  output logic [1:0] waddr ,
  output logic [0:0] wen 
);
  logic [2:0] count;
  logic [0:0] count_en;
  logic [2:0] count_ini;
  logic [2:0] count_nxt;
  logic [0:0] deq_valid;
  logic [0:0] deq_valid_en;
  logic [0:0] deq_valid_nxt;
  logic [0:0] deq_xfer;
  logic [0:0] enq_rdy;
  logic [0:0] enq_rdy_en;
  logic [0:0] enq_rdy_nxt;
  logic [0:0] enq_xfer;
  logic [1:0] head;
  logic [1:0] head_ini;
  logic [1:0] tail;
  logic [1:0] tail_ini;

  
  always_comb begin : _lambda__s_tile_0__channel_b_0__queue_ctrl_send_valid_o
    send_valid_o = deq_valid | dry_run_ack;
  end

  
  always_comb begin : async_update
    enq_xfer = recv_en_i & enq_rdy;
    deq_xfer = send_en_i & deq_valid;
    count_en = enq_xfer ^ deq_xfer;
    enq_rdy_en = deq_xfer | enq_rdy;
    deq_valid_en = enq_xfer | deq_valid;
    count_nxt = count;
    if ( enq_xfer & ( ~deq_xfer ) ) begin
      count_nxt = count + 3'd1;
    end
    if ( ( ~enq_xfer ) & deq_xfer ) begin
      count_nxt = count - 3'd1;
    end
    enq_rdy_nxt = count_nxt < 3'd4;
    deq_valid_nxt = count_nxt > 3'd0;
  end

  
  always_ff @(posedge clk) begin : dry_run_reg
    if ( reset | local_reset_ctrl ) begin
      head_ini <= 2'd0;
      tail_ini <= 2'd0;
      count_ini <= 3'd0;
    end
    else if ( dry_run_done ) begin
      head_ini <= head;
      tail_ini <= tail;
      count_ini <= count;
    end
  end

  
  always_ff @(posedge clk) begin : sync_ctrl
    if ( reset | local_reset_stage ) begin
      enq_rdy <= 1'd1;
      deq_valid <= 1'd0;
    end
    else begin
      if ( enq_rdy_en ) begin
        enq_rdy <= enq_rdy_nxt;
      end
      if ( deq_valid_en ) begin
        deq_valid <= deq_valid_nxt;
      end
    end
  end

  
  always_ff @(posedge clk) begin : sync_reg
    if ( reset | local_reset_stage ) begin
      head <= 2'd0;
      tail <= 2'd0;
      count <= 3'd0;
    end
    else if ( sync_dry_run & ( ~dry_run_done ) ) begin
      head <= head_ini;
      tail <= tail_ini;
      count <= count_ini;
    end
    else begin
      if ( deq_xfer ) begin
        head <= ( head < 2'd3 ) ? head + 2'd1 : 2'd0;
      end
      if ( enq_xfer ) begin
        tail <= ( tail < 2'd3 ) ? tail + 2'd1 : 2'd0;
      end
      if ( count_en ) begin
        count <= count_nxt;
      end
    end
  end

  assign wen = enq_xfer;
  assign ren = deq_xfer;
  assign waddr = tail;
  assign raddr = head;
  assign recv_rdy_o = enq_rdy;

endmodule



module NormalQueueDpath__87869422fafcf71b
(
  input  logic [0:0] clk ,
  output CGRAData_64_1__payload_64__predicate_1 deq_msg ,
  input  CGRAData_64_1__payload_64__predicate_1 enq_msg ,
  input  logic [0:0] local_reset_data ,
  input  logic [1:0] raddr ,
  input  logic [0:0] ren ,
  input  logic [0:0] reset ,
  input  logic [1:0] waddr ,
  input  logic [0:0] wen 
);
  localparam CGRAData_64_1__payload_64__predicate_1 default_value  = { 64'd0, 1'd1 };
  localparam logic [2:0] __const__num_entries_at_up_rf_write  = 3'd4;
  CGRAData_64_1__payload_64__predicate_1 regs [0:3];
  CGRAData_64_1__payload_64__predicate_1 regs_rdata;

  
  always_comb begin : _lambda__s_tile_0__channel_b_0__queue_dpath_deq_msg
    deq_msg = regs[raddr];
  end

  
  always_ff @(posedge clk) begin : up_rf_write
    if ( reset | local_reset_data ) begin
      for ( int unsigned i = 1'd0; i < 3'( __const__num_entries_at_up_rf_write ); i += 1'd1 )
        regs[2'(i)] <= default_value;
    end
    else if ( wen ) begin
      regs[waddr] <= enq_msg;
    end
  end

endmodule



module NormalQueue__5c02d1f477f539e6
(
  input  logic [0:0] clk ,
  input  logic [0:0] dry_run_ack ,
  input  logic [0:0] dry_run_done ,
  input  logic [0:0] local_reset_b ,
  input  logic [0:0] local_reset_c ,
  input  logic [0:0] recv_en_i ,
  input  CGRAData_64_1__payload_64__predicate_1 recv_msg ,
  output logic [0:0] recv_rdy_o ,
  input  logic [0:0] reset ,
  input  logic [0:0] send_en_i ,
  output CGRAData_64_1__payload_64__predicate_1 send_msg ,
  output logic [0:0] send_valid_o ,
  input  logic [0:0] sync_dry_run 
);

  logic [0:0] ctrl__clk;
  logic [0:0] ctrl__dry_run_ack;
  logic [0:0] ctrl__dry_run_done;
  logic [0:0] ctrl__local_reset_ctrl;
  logic [0:0] ctrl__local_reset_stage;
  logic [1:0] ctrl__raddr;
  logic [0:0] ctrl__recv_en_i;
  logic [0:0] ctrl__recv_rdy_o;
  logic [0:0] ctrl__ren;
  logic [0:0] ctrl__reset;
  logic [0:0] ctrl__send_en_i;
  logic [0:0] ctrl__send_valid_o;
  logic [0:0] ctrl__sync_dry_run;
  logic [1:0] ctrl__waddr;
  logic [0:0] ctrl__wen;

  NormalQueueCtrl__num_entries_4__dry_run_enable_True ctrl
  (
    .clk( ctrl__clk ),
    .dry_run_ack( ctrl__dry_run_ack ),
    .dry_run_done( ctrl__dry_run_done ),
    .local_reset_ctrl( ctrl__local_reset_ctrl ),
    .local_reset_stage( ctrl__local_reset_stage ),
    .raddr( ctrl__raddr ),
    .recv_en_i( ctrl__recv_en_i ),
    .recv_rdy_o( ctrl__recv_rdy_o ),
    .ren( ctrl__ren ),
    .reset( ctrl__reset ),
    .send_en_i( ctrl__send_en_i ),
    .send_valid_o( ctrl__send_valid_o ),
    .sync_dry_run( ctrl__sync_dry_run ),
    .waddr( ctrl__waddr ),
    .wen( ctrl__wen )
  );



  logic [0:0] dpath__clk;
  CGRAData_64_1__payload_64__predicate_1 dpath__deq_msg;
  CGRAData_64_1__payload_64__predicate_1 dpath__enq_msg;
  logic [0:0] dpath__local_reset_data;
  logic [1:0] dpath__raddr;
  logic [0:0] dpath__ren;
  logic [0:0] dpath__reset;
  logic [1:0] dpath__waddr;
  logic [0:0] dpath__wen;

  NormalQueueDpath__87869422fafcf71b dpath
  (
    .clk( dpath__clk ),
    .deq_msg( dpath__deq_msg ),
    .enq_msg( dpath__enq_msg ),
    .local_reset_data( dpath__local_reset_data ),
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
  assign dpath__local_reset_data = local_reset_b;
  assign ctrl__local_reset_stage = local_reset_b;
  assign ctrl__local_reset_ctrl = local_reset_c;
  assign ctrl__dry_run_ack = dry_run_ack;
  assign ctrl__dry_run_done = dry_run_done;
  assign ctrl__sync_dry_run = sync_dry_run;
  assign dpath__wen = ctrl__wen;
  assign dpath__ren = ctrl__ren;
  assign dpath__waddr = ctrl__waddr;
  assign dpath__raddr = ctrl__raddr;
  assign ctrl__recv_en_i = recv_en_i;
  assign recv_rdy_o = ctrl__recv_rdy_o;
  assign ctrl__send_en_i = send_en_i;
  assign send_valid_o = ctrl__send_valid_o;
  assign dpath__enq_msg = recv_msg;
  assign send_msg = dpath__deq_msg;

endmodule



module ChannelRTL__1f55b6dac6c8e5a7
(
  input  logic [0:0] clk ,
  input  logic [0:0] dry_run_ack ,
  input  logic [0:0] dry_run_done ,
  input  logic [0:0] local_reset_b ,
  input  logic [0:0] local_reset_c ,
  input  logic [0:0] recv_en_i ,
  input  CGRAData_64_1__payload_64__predicate_1 recv_msg ,
  output logic [0:0] recv_rdy_o ,
  input  logic [0:0] reset ,
  input  logic [0:0] send_en_i ,
  output CGRAData_64_1__payload_64__predicate_1 send_msg ,
  output logic [0:0] send_valid_o ,
  input  logic [0:0] sync_dry_run 
);

  logic [0:0] queue__clk;
  logic [0:0] queue__dry_run_ack;
  logic [0:0] queue__dry_run_done;
  logic [0:0] queue__local_reset_b;
  logic [0:0] queue__local_reset_c;
  logic [0:0] queue__recv_en_i;
  CGRAData_64_1__payload_64__predicate_1 queue__recv_msg;
  logic [0:0] queue__recv_rdy_o;
  logic [0:0] queue__reset;
  logic [0:0] queue__send_en_i;
  CGRAData_64_1__payload_64__predicate_1 queue__send_msg;
  logic [0:0] queue__send_valid_o;
  logic [0:0] queue__sync_dry_run;

  NormalQueue__5c02d1f477f539e6 queue
  (
    .clk( queue__clk ),
    .dry_run_ack( queue__dry_run_ack ),
    .dry_run_done( queue__dry_run_done ),
    .local_reset_b( queue__local_reset_b ),
    .local_reset_c( queue__local_reset_c ),
    .recv_en_i( queue__recv_en_i ),
    .recv_msg( queue__recv_msg ),
    .recv_rdy_o( queue__recv_rdy_o ),
    .reset( queue__reset ),
    .send_en_i( queue__send_en_i ),
    .send_msg( queue__send_msg ),
    .send_valid_o( queue__send_valid_o ),
    .sync_dry_run( queue__sync_dry_run )
  );


  assign queue__clk = clk;
  assign queue__reset = reset;
  assign queue__recv_en_i = recv_en_i;
  assign queue__recv_msg = recv_msg;
  assign recv_rdy_o = queue__recv_rdy_o;
  assign queue__send_en_i = send_en_i;
  assign send_msg = queue__send_msg;
  assign send_valid_o = queue__send_valid_o;
  assign queue__local_reset_b = local_reset_b;
  assign queue__local_reset_c = local_reset_c;
  assign queue__dry_run_ack = dry_run_ack;
  assign queue__dry_run_done = dry_run_done;
  assign queue__sync_dry_run = sync_dry_run;

endmodule



module RegisterFile__ccf149455065416f
(
  input  logic [0:0] clk ,
  input  logic [3:0] raddr [0:0],
  output logic [31:0] rdata [0:0],
  input  logic [0:0] reset ,
  input  logic [3:0] waddr [0:0],
  input  logic [31:0] wdata [0:0],
  input  logic [0:0] wen [0:0]
);
  localparam logic [0:0] __const__rd_ports_at_up_rf_read  = 1'd1;
  localparam logic [0:0] __const__wr_ports_at_up_rf_write  = 1'd1;
  logic [31:0] regs [0:15];

  
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



module ConstQueueRTL__a54094f779e9bc58
(
  input  logic [0:0] clk ,
  input  logic [4:0] data_counter_base ,
  input  logic [4:0] data_counter_th ,
  input  logic [0:0] dry_run_done ,
  input  logic [0:0] execution_ini ,
  input  logic [31:0] recv_const ,
  input  logic [0:0] recv_const_en ,
  input  logic [3:0] recv_const_waddr ,
  input  logic [0:0] reset ,
  input  logic [0:0] send_const_en ,
  output logic [31:0] send_const_msg 
);
  logic [4:0] data_counter;
  logic [4:0] data_counter_biased;
  logic [4:0] data_counter_biased_nxt;
  logic [4:0] data_counter_nxt;

  logic [0:0] reg_file__clk;
  logic [3:0] reg_file__raddr [0:0];
  logic [31:0] reg_file__rdata [0:0];
  logic [0:0] reg_file__reset;
  logic [3:0] reg_file__waddr [0:0];
  logic [31:0] reg_file__wdata [0:0];
  logic [0:0] reg_file__wen [0:0];

  RegisterFile__ccf149455065416f reg_file
  (
    .clk( reg_file__clk ),
    .raddr( reg_file__raddr ),
    .rdata( reg_file__rdata ),
    .reset( reg_file__reset ),
    .waddr( reg_file__waddr ),
    .wdata( reg_file__wdata ),
    .wen( reg_file__wen )
  );


  
  always_comb begin : _lambda__s_tile_0__const_queue_data_counter_biased
    data_counter_biased = data_counter + data_counter_base;
  end

  
  always_comb begin : _lambda__s_tile_0__const_queue_data_counter_biased_nxt
    data_counter_biased_nxt = ( data_counter_base == data_counter_th ) ? data_counter_base : data_counter_biased + 5'd1;
  end

  
  always_comb begin : _lambda__s_tile_0__const_queue_data_counter_nxt
    data_counter_nxt = ( data_counter_base == data_counter_th ) ? 5'd0 : data_counter + 5'd1;
  end

  
  always_ff @(posedge clk) begin : update_raddr
    if ( reset | execution_ini ) begin
      data_counter <= 5'd0;
    end
    else if ( send_const_en ) begin
      data_counter <= ( data_counter_biased_nxt == data_counter_th ) ? 5'd0 : data_counter_nxt;
    end
  end

  assign reg_file__clk = clk;
  assign reg_file__reset = reset;
  assign reg_file__waddr[0] = recv_const_waddr;
  assign reg_file__wdata[0] = recv_const;
  assign reg_file__wen[0] = recv_const_en;
  assign reg_file__raddr[0] = data_counter_biased[3:0];
  assign send_const_msg = reg_file__rdata[0];

endmodule



module CrossbarRTL__549e61f8d5b6eb92
(
  output logic [3:0] bp_port_en ,
  input  logic [3:0] bp_port_rdy ,
  output logic [3:0] bp_port_sel ,
  input  logic [0:0] clk ,
  input  logic [0:0] exe_fsafe_en ,
  input  logic [0:0] execution_ini ,
  input  logic [2:0] recv_opt_msg_outport [0:8],
  input  CGRAData_64_1__payload_64__predicate_1 recv_port_data [0:5],
  input  logic [5:0] recv_port_en ,
  output logic [5:0] recv_port_rdy ,
  input  logic [0:0] reset ,
  output CGRAData_64_1__payload_64__predicate_1 send_bp_data [0:3],
  output CGRAData_64_1__payload_64__predicate_1 send_port_data [0:7],
  output logic [7:0] send_port_en ,
  input  logic [7:0] send_port_rdy ,
  output CGRAData_1__predicate_1 send_predicate ,
  output logic [0:0] send_predicate_en ,
  input  logic [0:0] send_predicate_rdy ,
  input  logic [0:0] xbar_opt_enable ,
  input  logic [0:0] xbar_propagate_en ,
  output logic [0:0] xbar_propagate_rdy 
);
  localparam logic [3:0] __const__num_xbar_outports_at_decode_process  = 4'd8;
  localparam logic [2:0] __const__num_xbar_inports_at_decode_process  = 3'd6;
  localparam logic [3:0] __const__num_xbar_outports_at_opt_propagate  = 4'd8;
  localparam logic [2:0] __const__num_xbar_inports_at_opt_propagate  = 3'd6;
  localparam logic [2:0] __const__num_xbar_inports_at_handshake_process  = 3'd6;
  localparam logic [2:0] __const__num_connect_inports_at_handshake_process  = 3'd4;
  localparam logic [3:0] __const__num_xbar_outports_at_handshake_process  = 4'd8;
  localparam logic [2:0] __const__num_connect_outports_at_handshake_process  = 3'd4;
  localparam logic [3:0] __const__num_xbar_outports_at_data_routing  = 4'd8;
  localparam logic [2:0] __const__num_connect_inports_at_data_routing  = 3'd4;
  localparam logic [2:0] __const__num_connect_outports_at_data_routing  = 3'd4;
  localparam logic [2:0] __const__num_xbar_inports_at_data_routing  = 3'd6;
  localparam logic [3:0] __const__num_xbar_outports_at_xbar_propagate_sync  = 4'd8;
  logic [8:0] bp_downstream_rdy;
  logic [3:0] bp_outport_flag;
  logic [1:0] bp_outport_s [0:3];
  logic [3:0] bp_port_req;
  logic [3:0] bp_port_req_nxt;
  logic [8:0] lc_downstream_rdy;
  logic [5:0] recv_port_req;
  logic [5:0] xbar_done_flag;
  logic [5:0] xbar_done_flag_nxt;
  logic [8:0] xbar_inport_rdy [0:5];
  logic [8:0] xbar_inport_sel [0:5];
  logic [5:0] xbar_inport_xfer;
  logic [5:0] xbar_outport_en [0:8];
  logic [5:0] xbar_outport_sel [0:8];
  logic [5:0] xbar_outport_sel_nxt [0:8];
  logic [6:0] xbar_outport_sel_nxt_decode [0:8];
  logic [5:0] xbar_xfer_flag;

  
  always_comb begin : data_routing
    for ( int unsigned i = 1'd0; i < 4'( __const__num_xbar_outports_at_data_routing ); i += 1'd1 )
      send_port_data[3'(i)] = { 64'd0, 1'd0 };
    for ( int unsigned i = 1'd0; i < 3'( __const__num_connect_inports_at_data_routing ); i += 1'd1 )
      send_bp_data[2'(i)] = { 64'd0, 1'd0 };
    send_predicate = 1'd0;
    for ( int unsigned i = 1'd0; i < 3'( __const__num_connect_outports_at_data_routing ); i += 1'd1 ) begin
      for ( int unsigned j = 1'd0; j < 3'( __const__num_connect_inports_at_data_routing ); j += 1'd1 ) begin
        send_port_data[3'(i)].payload = send_port_data[3'(i)].payload | ( recv_port_data[3'(j)].payload & { { 63 { xbar_outport_sel[4'(i)][3'(j)] } }, xbar_outport_sel[4'(i)][3'(j)] } );
        send_port_data[3'(i)].predicate = send_port_data[3'(i)].predicate | ( recv_port_data[3'(j)].predicate & xbar_outport_sel[4'(i)][3'(j)] );
      end
      for ( int unsigned j = 3'( __const__num_connect_inports_at_data_routing ); j < 3'( __const__num_xbar_inports_at_data_routing ); j += 1'd1 ) begin
        send_bp_data[2'(i)].payload = send_bp_data[2'(i)].payload | ( recv_port_data[3'(j)].payload & { { 63 { xbar_outport_sel[4'(i)][3'(j)] } }, xbar_outport_sel[4'(i)][3'(j)] } );
        send_bp_data[2'(i)].predicate = send_bp_data[2'(i)].predicate | ( recv_port_data[3'(j)].predicate & xbar_outport_sel[4'(i)][3'(j)] );
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
    for ( int unsigned i = 1'd0; i < 4'( __const__num_xbar_outports_at_decode_process ) + 4'd1; i += 1'd1 )
      xbar_outport_sel_nxt_decode[4'(i)] = 7'd0;
    for ( int unsigned i = 1'd0; i < 4'( __const__num_xbar_outports_at_decode_process ) + 4'd1; i += 1'd1 )
      xbar_outport_sel_nxt[4'(i)] = 6'd0;
    if ( xbar_opt_enable ) begin
      for ( int unsigned i = 1'd0; i < 4'( __const__num_xbar_outports_at_decode_process ) + 4'd1; i += 1'd1 )
        if ( recv_opt_msg_outport[4'(i)] != 3'd0 ) begin
          xbar_outport_sel_nxt_decode[4'(i)][recv_opt_msg_outport[4'(i)]] = 1'd1;
        end
      for ( int unsigned i = 1'd0; i < 4'( __const__num_xbar_outports_at_decode_process ) + 4'd1; i += 1'd1 )
        xbar_outport_sel_nxt[4'(i)] = xbar_outport_sel_nxt_decode[4'(i)][3'd6:3'd1];
    end
  end

  
  always_comb begin : handshake_process
    for ( int unsigned i = 1'd0; i < 3'( __const__num_xbar_inports_at_handshake_process ); i += 1'd1 )
      recv_port_req[3'(i)] = ( | xbar_inport_sel[3'(i)] );
    for ( int unsigned i = 1'd0; i < 3'( __const__num_connect_inports_at_handshake_process ); i += 1'd1 )
      xbar_inport_rdy[3'(i)] = xbar_inport_sel[3'(i)] & ( ~lc_downstream_rdy );
    for ( int unsigned i = 3'( __const__num_connect_inports_at_handshake_process ); i < 3'( __const__num_xbar_inports_at_handshake_process ); i += 1'd1 )
      xbar_inport_rdy[3'(i)] = xbar_inport_sel[3'(i)] & ( ~bp_downstream_rdy );
    for ( int unsigned i = 1'd0; i < 3'( __const__num_xbar_inports_at_handshake_process ); i += 1'd1 )
      recv_port_rdy[3'(i)] = ( ( ~( | xbar_inport_rdy[3'(i)] ) ) & recv_port_req[3'(i)] ) & ( ~xbar_done_flag[3'(i)] );
    xbar_inport_xfer = ( ( recv_port_en | { { 5 { exe_fsafe_en[0] } }, exe_fsafe_en } ) & recv_port_rdy ) & ( ~xbar_done_flag );
    for ( int unsigned i = 1'd0; i < 4'( __const__num_xbar_outports_at_handshake_process ) + 4'd1; i += 1'd1 )
      xbar_outport_en[4'(i)] = xbar_inport_xfer & xbar_outport_sel[4'(i)];
    for ( int unsigned i = 1'd0; i < 3'( __const__num_connect_outports_at_handshake_process ); i += 1'd1 )
      send_port_en[3'(i)] = ( | xbar_outport_en[4'(i)][3'd3:3'd0] );
    for ( int unsigned i = 1'd0; i < 3'( __const__num_connect_outports_at_handshake_process ); i += 1'd1 )
      bp_port_en[2'(i)] = ( | xbar_outport_en[4'(i)][3'd5:3'( __const__num_connect_inports_at_handshake_process )] );
    for ( int unsigned i = 3'( __const__num_connect_outports_at_handshake_process ); i < 4'( __const__num_xbar_outports_at_handshake_process ); i += 1'd1 )
      send_port_en[3'(i)] = ( | xbar_outport_en[4'(i)] );
    send_predicate_en = ( | xbar_outport_en[4'( __const__num_xbar_outports_at_handshake_process )] );
    for ( int unsigned i = 1'd0; i < 3'( __const__num_connect_outports_at_handshake_process ); i += 1'd1 ) begin
      bp_port_req[2'(i)] = ( | xbar_outport_sel[4'(i)][3'd5:3'( __const__num_connect_inports_at_handshake_process )] );
      bp_port_req_nxt[2'(i)] = ( | xbar_outport_sel_nxt[4'(i)][3'd5:3'( __const__num_connect_inports_at_handshake_process )] );
    end
    for ( int unsigned i = 1'd0; i < 3'( __const__num_connect_outports_at_handshake_process ); i += 1'd1 ) begin
      bp_outport_s[2'(i)] = xbar_outport_sel[4'(i)][3'd5:3'( __const__num_connect_inports_at_handshake_process )] & ( ~xbar_done_flag[3'd5:3'( __const__num_connect_inports_at_handshake_process )] );
      bp_outport_flag[2'(i)] = ~( | bp_outport_s[2'(i)] );
    end
    for ( int unsigned i = 1'd0; i < 3'( __const__num_connect_outports_at_handshake_process ); i += 1'd1 )
      bp_port_sel[2'(i)] = ( bp_outport_flag[2'(i)] & bp_port_req_nxt[2'(i)] ) | ( ( ~bp_outport_flag[2'(i)] ) & bp_port_req[2'(i)] );
    xbar_xfer_flag = ( ~recv_port_req ) | xbar_inport_xfer;
    xbar_done_flag_nxt = xbar_done_flag | xbar_xfer_flag;
    xbar_propagate_rdy = ( & xbar_done_flag_nxt );
  end

  
  always_comb begin : opt_propagate
    for ( int unsigned i = 1'd0; i < 4'( __const__num_xbar_outports_at_opt_propagate ) + 4'd1; i += 1'd1 )
      for ( int unsigned j = 1'd0; j < 3'( __const__num_xbar_inports_at_opt_propagate ); j += 1'd1 )
        xbar_inport_sel[3'(j)][4'(i)] = xbar_outport_sel[4'(i)][3'(j)];
  end

  
  always_ff @(posedge clk) begin : fsm_update
    if ( reset ) begin
      xbar_done_flag <= 6'd0;
    end
    else if ( xbar_propagate_en ) begin
      xbar_done_flag <= 6'd0;
    end
    else
      xbar_done_flag <= xbar_done_flag_nxt;
  end

  
  always_ff @(posedge clk) begin : xbar_propagate_sync
    if ( reset | execution_ini ) begin
      for ( int unsigned i = 1'd0; i < 4'( __const__num_xbar_outports_at_xbar_propagate_sync ) + 4'd1; i += 1'd1 )
        xbar_outport_sel[4'(i)] <= 6'd0;
    end
    else if ( xbar_propagate_en ) begin
      for ( int unsigned i = 1'd0; i < 4'( __const__num_xbar_outports_at_xbar_propagate_sync ) + 4'd1; i += 1'd1 )
        xbar_outport_sel[4'(i)] <= xbar_outport_sel_nxt[4'(i)];
    end
  end

  assign lc_downstream_rdy[0:0] = send_port_rdy[0:0];
  assign lc_downstream_rdy[1:1] = send_port_rdy[1:1];
  assign lc_downstream_rdy[2:2] = send_port_rdy[2:2];
  assign lc_downstream_rdy[3:3] = send_port_rdy[3:3];
  assign lc_downstream_rdy[4:4] = send_port_rdy[4:4];
  assign lc_downstream_rdy[5:5] = send_port_rdy[5:5];
  assign lc_downstream_rdy[6:6] = send_port_rdy[6:6];
  assign lc_downstream_rdy[7:7] = send_port_rdy[7:7];
  assign lc_downstream_rdy[8:8] = send_predicate_rdy;
  assign bp_downstream_rdy[0:0] = bp_port_rdy[0:0];
  assign bp_downstream_rdy[1:1] = bp_port_rdy[1:1];
  assign bp_downstream_rdy[2:2] = bp_port_rdy[2:2];
  assign bp_downstream_rdy[3:3] = bp_port_rdy[3:3];
  assign bp_downstream_rdy[4:4] = send_port_rdy[4:4];
  assign bp_downstream_rdy[5:5] = send_port_rdy[5:5];
  assign bp_downstream_rdy[6:6] = send_port_rdy[6:6];
  assign bp_downstream_rdy[7:7] = send_port_rdy[7:7];
  assign bp_downstream_rdy[8:8] = send_predicate_rdy;

endmodule



module RegisterFile__13f9e636e63c631c
(
  input  logic [0:0] clk ,
  input  logic [3:0] raddr [0:0],
  output CGRAConfig_10_3_6_8_3__877613aa0dfe8ae0 rdata [0:0],
  input  logic [0:0] reset ,
  input  logic [3:0] waddr [0:0],
  input  CGRAConfig_10_3_6_8_3__877613aa0dfe8ae0 wdata [0:0],
  input  logic [0:0] wen [0:0]
);
  localparam logic [0:0] __const__rd_ports_at_up_rf_read  = 1'd1;
  localparam logic [0:0] __const__wr_ports_at_up_rf_write  = 1'd1;
  CGRAConfig_10_3_6_8_3__877613aa0dfe8ae0 regs [0:15];

  
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



module CtrlMemRTL__d3d31847de3fc702
(
  input  logic [0:0] clk ,
  input  logic [4:0] cmd_counter_base ,
  input  logic [4:0] cmd_counter_th ,
  input  logic [0:0] cmd_el_mode_en ,
  output logic [0:0] cmd_iter_th_hit_nxt ,
  input  logic [31:0] cmd_iter_th_info ,
  input  logic [0:0] execution_ini ,
  input  logic [0:0] nxt_ctrl_en ,
  input  logic [0:0] re_execution_ini ,
  output CGRAConfig_10_3_6_8_3__877613aa0dfe8ae0 recv_ctrl_msg ,
  input  logic [31:0] recv_ctrl_slice ,
  input  logic [0:0] recv_ctrl_slice_en ,
  input  logic [0:0] recv_ctrl_slice_idx ,
  input  logic [3:0] recv_waddr ,
  input  logic [0:0] recv_waddr_en ,
  input  logic [0:0] reset ,
  output CGRAConfig_10_3_6_8_3__877613aa0dfe8ae0 send_ctrl_msg 
);
  localparam logic [1:0] __const__num_opt_slice_at_buffer_opt_slice  = 2'd2;
  logic [4:0] cmd_counter;
  logic [4:0] cmd_counter_biased;
  logic [4:0] cmd_counter_biased_nxt;
  logic [4:0] cmd_counter_nxt;
  logic [26:0] cmd_iter_counter;
  logic [26:0] cmd_iter_counter_nxt;
  logic [26:0] cmd_iter_counter_th;
  logic [63:0] concat_ctrl_msg;
  logic [0:0] global_iter_hit_nxt;
  logic [4:0] iter_counter;
  logic [4:0] iter_counter_nxt;
  logic [4:0] iter_counter_th;
  logic [0:0] local_iter_hit_nxt;
  logic [31:0] opt_slice_regs [0:1];

  logic [0:0] reg_file__clk;
  logic [3:0] reg_file__raddr [0:0];
  CGRAConfig_10_3_6_8_3__877613aa0dfe8ae0 reg_file__rdata [0:0];
  logic [0:0] reg_file__reset;
  logic [3:0] reg_file__waddr [0:0];
  CGRAConfig_10_3_6_8_3__877613aa0dfe8ae0 reg_file__wdata [0:0];
  logic [0:0] reg_file__wen [0:0];

  RegisterFile__13f9e636e63c631c reg_file
  (
    .clk( reg_file__clk ),
    .raddr( reg_file__raddr ),
    .rdata( reg_file__rdata ),
    .reset( reg_file__reset ),
    .waddr( reg_file__waddr ),
    .wdata( reg_file__wdata ),
    .wen( reg_file__wen )
  );


  
  always_comb begin : _lambda__s_tile_0__ctrl_mem_cmd_counter_biased
    cmd_counter_biased = cmd_counter + cmd_counter_base;
  end

  
  always_comb begin : _lambda__s_tile_0__ctrl_mem_cmd_counter_biased_nxt
    cmd_counter_biased_nxt = cmd_counter_biased + 5'd1;
  end

  
  always_comb begin : _lambda__s_tile_0__ctrl_mem_cmd_counter_nxt
    cmd_counter_nxt = cmd_counter + 5'd1;
  end

  
  always_comb begin : _lambda__s_tile_0__ctrl_mem_cmd_iter_counter_nxt
    cmd_iter_counter_nxt = cmd_iter_counter + 27'd1;
  end

  
  always_comb begin : _lambda__s_tile_0__ctrl_mem_cmd_iter_th_hit_nxt
    cmd_iter_th_hit_nxt = ( cmd_iter_counter_nxt == cmd_iter_counter_th ) & global_iter_hit_nxt;
  end

  
  always_comb begin : _lambda__s_tile_0__ctrl_mem_global_iter_hit_nxt
    global_iter_hit_nxt = ( ( ~cmd_el_mode_en ) & ( iter_counter_nxt == iter_counter_th ) ) | ( cmd_el_mode_en & local_iter_hit_nxt );
  end

  
  always_comb begin : _lambda__s_tile_0__ctrl_mem_iter_counter_nxt
    iter_counter_nxt = iter_counter + 5'd1;
  end

  
  always_comb begin : _lambda__s_tile_0__ctrl_mem_local_iter_hit_nxt
    local_iter_hit_nxt = cmd_counter_biased_nxt == cmd_counter_th;
  end

  
  always_ff @(posedge clk) begin : buffer_opt_slice
    if ( reset ) begin
      for ( int unsigned i = 1'd0; i < 2'( __const__num_opt_slice_at_buffer_opt_slice ); i += 1'd1 )
        opt_slice_regs[1'(i)] <= 32'd0;
    end
    else if ( recv_ctrl_slice_en ) begin
      opt_slice_regs[recv_ctrl_slice_idx] <= recv_ctrl_slice;
    end
  end

  
  always_ff @(posedge clk) begin : update_iter
    if ( ( reset | execution_ini ) | ( nxt_ctrl_en & cmd_iter_th_hit_nxt ) ) begin
      cmd_iter_counter <= 27'd0;
    end
    else if ( nxt_ctrl_en & global_iter_hit_nxt ) begin
      cmd_iter_counter <= cmd_iter_counter_nxt;
    end
  end

  
  always_ff @(posedge clk) begin : update_raddr
    if ( reset | execution_ini ) begin
      cmd_counter <= 5'd0;
      iter_counter <= 5'd0;
    end
    else if ( nxt_ctrl_en ) begin
      cmd_counter <= local_iter_hit_nxt ? 5'd0 : cmd_counter_nxt;
      iter_counter <= global_iter_hit_nxt ? 5'd0 : iter_counter_nxt;
    end
  end

  assign reg_file__clk = clk;
  assign reg_file__reset = reset;
  assign concat_ctrl_msg[31:0] = opt_slice_regs[0];
  assign concat_ctrl_msg[63:32] = opt_slice_regs[1];
  assign recv_ctrl_msg = concat_ctrl_msg[63:0];
  assign reg_file__waddr[0] = recv_waddr;
  assign reg_file__wdata[0] = recv_ctrl_msg;
  assign reg_file__wen[0] = recv_waddr_en;
  assign iter_counter_th = cmd_iter_th_info[4:0];
  assign cmd_iter_counter_th = cmd_iter_th_info[31:5];
  assign reg_file__raddr[0] = cmd_counter_biased[3:0];
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





`ifndef VEC_ALU
`define VEC_ALU





module vec_alu #(
	parameter ALU_OP_WIDTH    = 7,
	parameter D_WIDTH = 64
)
(
    input logic               clk,
    input logic               reset,
    input logic [2:0] alu_ext_mode_i,
    input logic [ALU_OP_WIDTH-1:0] operator_i,
    input logic        [D_WIDTH-1:0] operand_a_i,
    input logic        [D_WIDTH-1:0] operand_b_i,
    input logic        [D_WIDTH-1:0] operand_c_i,

    input logic [2:0] op_signed_i,
	input logic round_en_i,

	input logic         predicate_a_i,
    input logic         predicate_b_i,
    input logic         predicate_c_i,
    input logic         op_predicate_i,

    input logic [1:0] vector_mode_i,
    input logic [5:0] o_imm_i,

    input logic       operator_ext_en_i,

    output logic [63:0] result_o [2],
	output logic result_predicate_o [2],

	output logic out_en_o,
	input logic out_rdy_i,
    output logic ex_rdy_o,
    input  logic ex_en_i
);
	localparam ATOM_WIDTH = 8;
	localparam NUM_SLICES = 8;
	localparam NUM_STAGES_L2 = $clog2(NUM_SLICES/2);
	localparam NUM_STAGES_L1 = $clog2(NUM_SLICES);
	
	localparam VEC_MODE32 = 2'b00;
	localparam VEC_MODE16 = 2'b10;
	localparam VEC_MODE8 = 2'b11;


	localparam ALU_ADD = 7'b0011000;
	localparam ALU_SUB = 7'b0011001;
	localparam ALU_XOR = 7'b0101111;
	localparam ALU_OR = 7'b0101110;
	localparam ALU_AND = 7'b0010101;
	localparam ALU_SRA = 7'b0100100;
	localparam ALU_SRL = 7'b0100101;
	localparam ALU_SLL = 7'b0100111;
	localparam ALU_ABS = 7'b0010100;
	localparam ALU_GT = 7'b0001000;
	localparam ALU_GE = 7'b0001010;
	localparam ALU_EQ  = 7'b0001100;
	localparam ALU_MAX  = 7'b0010010;
	localparam ALU_MIN  = 7'b0010000;

	localparam ALU_PHI  = 7'b0111001;
	localparam ALU_SHUF  = 7'b0111010;

	localparam ALU_RADD = 7'b0110000;















	assign ex_rdy_o = out_rdy_i;
	assign out_en_o = ex_en_i;

	genvar i, j, k, l;

	logic [7:0] op_signed_mask;
	always_comb begin : signed_bits_mask
      unique case (vector_mode_i)
        VEC_MODE32: op_signed_mask = 8'b10001000;
        VEC_MODE16: op_signed_mask = 8'b10101010;
        VEC_MODE8: op_signed_mask = 8'b11111111;
        default: op_signed_mask = 8'b10000000;
      endcase
    end

	logic is_subrot_i, is_br_cond_i, is_tny_cond_i;

	logic [ATOM_WIDTH+2:0] l1_op_a [NUM_SLICES];
	logic [ATOM_WIDTH+2:0] l1_op_b [NUM_SLICES];
	logic [2*ATOM_WIDTH+5:0] l2_op_a [NUM_SLICES/2];
	logic [2*ATOM_WIDTH+5:0] l2_op_b [NUM_SLICES/2];
	logic [4*ATOM_WIDTH+11:0] l3_op_a [NUM_SLICES/4];
	logic [4*ATOM_WIDTH+11:0] l3_op_b [NUM_SLICES/4];

	logic [8*ATOM_WIDTH+23:0] op_a_ext, op_b_ext, op_a_ext_rev, op_a_ext_neg, op_b_ext_neg;

	generate
		for (i = 0; i<NUM_SLICES; i++) begin
			assign l1_op_a[i] = $signed({op_signed_i[0] & operand_a_i[(i+1)*ATOM_WIDTH-1], operand_a_i[i*ATOM_WIDTH+:ATOM_WIDTH]});
			assign l1_op_b[i] = $signed({op_signed_i[1] & operand_b_i[(i+1)*ATOM_WIDTH-1], operand_b_i[i*ATOM_WIDTH+:ATOM_WIDTH]});
		end

		for (i = 0; i<NUM_SLICES/2; i++) begin
			assign l2_op_a[i] = $signed({op_signed_i[0] & operand_a_i[(i+1)*2*ATOM_WIDTH-1], operand_a_i[i*2*ATOM_WIDTH+:2*ATOM_WIDTH]});
			assign l2_op_b[i] = $signed({op_signed_i[1] & operand_b_i[(i+1)*2*ATOM_WIDTH-1], operand_b_i[i*2*ATOM_WIDTH+:2*ATOM_WIDTH]});
		end

		for (i = 0; i<NUM_SLICES/4; i++) begin
			assign l3_op_a[i] = $signed({op_signed_i[0] & operand_a_i[(i+1)*4*ATOM_WIDTH-1], operand_a_i[i*4*ATOM_WIDTH+:4*ATOM_WIDTH]});
			assign l3_op_b[i] = $signed({op_signed_i[1] & operand_b_i[(i+1)*4*ATOM_WIDTH-1], operand_b_i[i*4*ATOM_WIDTH+:4*ATOM_WIDTH]});
		end
	endgenerate

	always_comb begin : gen_ext_op
		unique case (vector_mode_i)
			VEC_MODE8: begin
				for (int i = 0; i<NUM_SLICES; i++) begin
					op_a_ext[i*(ATOM_WIDTH+3)+:ATOM_WIDTH+3] = l1_op_a[i];
					op_b_ext[i*(ATOM_WIDTH+3)+:ATOM_WIDTH+3] = l1_op_b[i];
				end
			end
			VEC_MODE16: begin
				for (int i = 0; i<NUM_SLICES/2; i++) begin
					op_a_ext[i*2*(ATOM_WIDTH+3)+:2*(ATOM_WIDTH+3)] = l2_op_a[i];
					op_b_ext[i*2*(ATOM_WIDTH+3)+:2*(ATOM_WIDTH+3)] = l2_op_b[i];
				end
			end
			VEC_MODE32: begin
				for (int i = 0; i<NUM_SLICES/4; i++) begin
					op_a_ext[i*4*(ATOM_WIDTH+3)+:4*(ATOM_WIDTH+3)] = l3_op_a[i];
					op_b_ext[i*4*(ATOM_WIDTH+3)+:4*(ATOM_WIDTH+3)] = l3_op_b[i];
				end
			end
			default: begin
				op_a_ext = $signed({op_signed_i[0] & operand_a_i[D_WIDTH-1], operand_a_i});
				op_b_ext = $signed({op_signed_i[1] & operand_b_i[D_WIDTH-1], operand_b_i});
			end	
		endcase
	end



	assign op_a_ext_neg = ~op_a_ext;
	assign op_b_ext_neg = ~op_b_ext;

	generate
		for (k = 0; k < 8*ATOM_WIDTH+24; k++) begin : gen_op_a_ext_rev
			assign op_a_ext_rev[k] = op_a_ext[8*ATOM_WIDTH+23-k];
		end
	endgenerate



	logic        adder_op_b_negate;
	logic [8*ATOM_WIDTH+23:0] adder_op_a, adder_op_b;
	logic [8*ATOM_WIDTH+31:0] adder_in_a, adder_in_b;
	logic [8*ATOM_WIDTH+32:0] adder_result_expanded_tmp, adder_result_expanded;
	logic [8*ATOM_WIDTH+23:0] adder_result, adder_result_rev;
	
	logic [2*ATOM_WIDTH+7:0] radder_in_a_l2_tmp, radder_in_b_l2_tmp, radder_in_a_l2, radder_in_b_l2;
	logic [2*ATOM_WIDTH+8:0] radder_result_l2;
	logic [ATOM_WIDTH+3:0] radder_in_a_l1, radder_in_b_l1;
	logic [ATOM_WIDTH+4:0] radder_result_l1;
	logic [4*ATOM_WIDTH+11:0] radder_in_fin_l3;
	logic [2*ATOM_WIDTH+5:0] radder_in_fin_l2;
	logic [D_WIDTH-1:0] radder_in_fin, radder_result;
	logic [D_WIDTH+2:0] radder_result_tmp;

	logic [D_WIDTH-1:0] bmask_tmp, bmask_seed;
	logic [8*ATOM_WIDTH+23:0] adder_op_round;
	logic [8*ATOM_WIDTH+31:0] adder_in_round, adder_in_round_bmask;

	assign bmask_seed = 'b1 <<< o_imm_i[4:0];
    assign bmask_tmp = {1'b0, bmask_seed[D_WIDTH-1:1]};

	always_comb begin : gen_ext_round
		unique case (vector_mode_i)
			VEC_MODE8: begin
				for (int i = 0; i<NUM_SLICES; i++) begin
					adder_op_round[i*(ATOM_WIDTH+3)+:ATOM_WIDTH+3] = bmask_tmp[0+:(ATOM_WIDTH+3)];
				end
			end
			VEC_MODE16: begin
				for (int i = 0; i<NUM_SLICES/2; i++) begin
					adder_op_round[i*2*(ATOM_WIDTH+3)+:2*(ATOM_WIDTH+3)] = bmask_tmp[0+:2*(ATOM_WIDTH+3)];
				end
			end
			VEC_MODE32: begin
				for (int i = 0; i<NUM_SLICES/4; i++) begin
					adder_op_round[i*4*(ATOM_WIDTH+3)+:4*(ATOM_WIDTH+3)] = bmask_tmp[0+:4*(ATOM_WIDTH+3)];
				end
			end
			default: begin
				adder_op_round = bmask_tmp;
			end	
		endcase
	end

	assign is_subrot_i = (operator_i == ALU_SUB) && operator_ext_en_i;

	assign adder_op_b_negate = (operator_i == ALU_SUB) || is_subrot_i;

	assign adder_op_a = (operator_i == ALU_ABS) ? op_a_ext_neg : (is_subrot_i ? ( (vector_mode_i == VEC_MODE8) ? {
		op_b_ext[76:66], op_a_ext[87:77], op_b_ext[54:44], op_a_ext[65:55], 
		op_b_ext[32:22], op_a_ext[43:33], op_b_ext[10:0], op_a_ext[21:11]
	} : ( (vector_mode_i == VEC_MODE16 ) ? {
		op_b_ext[65:44], op_a_ext[87:66], op_b_ext[21:0], op_a_ext[43:22]
	} : {
		op_b_ext[43:0], op_a_ext[87:44]
	} ) ) : ((operator_i == ALU_RADD) ? {{(4*ATOM_WIDTH+12){1'b0}}, op_a_ext[0+:4*ATOM_WIDTH+12]} : op_a_ext));

	assign adder_op_b = adder_op_b_negate ? (is_subrot_i ? ( (vector_mode_i == VEC_MODE8) ? ~{
		op_a_ext[76:66], op_b_ext[87:77], op_a_ext[54:44], op_b_ext[65:55], 
		op_a_ext[32:22], op_b_ext[43:33], op_a_ext[10:0], op_b_ext[21:11]
	} : ( (vector_mode_i == VEC_MODE16 ) ? ~{
		op_a_ext[65:44], op_b_ext[87:66], op_a_ext[21:0], op_b_ext[43:22]
	} : ~{
		op_a_ext[43:0], op_b_ext[87:44]
	} ) ) : op_b_ext_neg) : ((operator_i == ALU_RADD) ? {{(4*ATOM_WIDTH+12){1'b0}}, op_a_ext[4*ATOM_WIDTH+12+:4*ATOM_WIDTH+12]} : op_b_ext);

	generate
		for (i = 0; i < NUM_SLICES; i++) begin
			assign adder_in_a[i*(ATOM_WIDTH+4)+1+:ATOM_WIDTH+3] = adder_op_a[i*(ATOM_WIDTH+3)+:ATOM_WIDTH+3];
			assign adder_in_a[i*(ATOM_WIDTH+4)] = (adder_op_b_negate || (operator_i == ALU_ABS )) ? 1'b1 : ~op_signed_mask[7-i%8];
		end
	endgenerate

	generate
		for (i = 0; i < NUM_SLICES; i++) begin
			assign adder_in_b[i*(ATOM_WIDTH+4)+1+:ATOM_WIDTH+3] = adder_op_b[i*(ATOM_WIDTH+3)+:ATOM_WIDTH+3];
			assign adder_in_b[i*(ATOM_WIDTH+4)] = (adder_op_b_negate || (operator_i == ALU_ABS )) ? op_signed_mask[7-i%8] : 1'b0;
		end
	endgenerate

	generate
		for (i = 0; i < NUM_SLICES; i++) begin
			assign adder_in_round[i*(ATOM_WIDTH+4)+1+:ATOM_WIDTH+3] = adder_result_expanded_tmp[i*(ATOM_WIDTH+4)+1+:ATOM_WIDTH+3];
			assign adder_in_round[i*(ATOM_WIDTH+4)] = ~op_signed_mask[7-i%8];
			assign adder_in_round_bmask[i*(ATOM_WIDTH+4)+1+:ATOM_WIDTH+3] = (round_en_i && ~o_imm_i[5]) ? adder_op_round[i*(ATOM_WIDTH+3)+:ATOM_WIDTH+3] : '0;
			assign adder_in_round_bmask[i*(ATOM_WIDTH+4)] = 1'b0;
		end
	endgenerate

	generate
		for (i = 0; i < NUM_SLICES/4; i++) begin
			assign radder_in_a_l2_tmp[i*(ATOM_WIDTH+4)+1+:ATOM_WIDTH+3] = adder_result_expanded_tmp[i*(ATOM_WIDTH+4)+1+:ATOM_WIDTH+3];
			assign radder_in_a_l2_tmp[i*(ATOM_WIDTH+4)] = ~op_signed_mask[7-i%8];
			assign radder_in_b_l2_tmp[i*(ATOM_WIDTH+4)+1+:ATOM_WIDTH+3] = adder_result_expanded_tmp[(i+NUM_SLICES/4)*(ATOM_WIDTH+4)+1+:ATOM_WIDTH+3];
			assign radder_in_b_l2_tmp[i*(ATOM_WIDTH+4)] = 1'b0;
		end
	endgenerate

	assign radder_in_a_l2 = (operator_i == ALU_RADD) ? radder_in_a_l2_tmp : '0;
	assign radder_in_b_l2 = (operator_i == ALU_RADD) ? radder_in_b_l2_tmp : '0;

	assign radder_in_a_l1 = (operator_i == ALU_RADD) ? $signed(radder_result_l2[1+:ATOM_WIDTH+3]) : '0;
	assign radder_in_b_l1 = (operator_i == ALU_RADD) ? $signed(radder_result_l2[ATOM_WIDTH+5+:ATOM_WIDTH+3]) : '0;

	generate
		for (i=0; i<NUM_SLICES/2; i++) begin
			assign radder_in_fin_l3[i*(ATOM_WIDTH+3)+:ATOM_WIDTH+3] = adder_result_expanded_tmp[i*(ATOM_WIDTH+4)+1+:ATOM_WIDTH+3];
		end
	endgenerate

	generate
		for (i=0; i<NUM_SLICES/4; i++) begin
			assign radder_in_fin_l2[i*(ATOM_WIDTH+3)+:ATOM_WIDTH+3] = radder_result_l2[i*(ATOM_WIDTH+4)+1+:ATOM_WIDTH+3];
		end
	endgenerate

	always_comb begin
		radder_in_fin = '0;
		if (operator_i == ALU_RADD) begin
			unique case (vector_mode_i)
				VEC_MODE32: radder_in_fin = $signed(radder_in_fin_l3);
				VEC_MODE16: radder_in_fin = $signed(radder_in_fin_l2);
				VEC_MODE8: radder_in_fin = $signed(radder_result_l1);
				default: ;
			endcase
		end
	end

	assign adder_result_expanded_tmp = $signed(adder_in_a) + $signed(adder_in_b);
	assign adder_result_expanded = $signed(adder_in_round) + $signed(adder_in_round_bmask);
	
	assign radder_result_l2 = $signed(radder_in_a_l2) + $signed(radder_in_b_l2);
	assign radder_result_l1 = $signed(radder_in_a_l1) + $signed(radder_in_b_l1);
	assign radder_result_tmp = $signed($signed(radder_in_fin) + $signed({op_signed_i[1] & operand_b_i[D_WIDTH-1], operand_b_i}) + $signed(bmask_tmp)) >>> o_imm_i[4:0];
	assign radder_result = radder_result_tmp[0+:D_WIDTH];
	
	generate
		for (i = 0; i < NUM_SLICES; i++) begin
			assign adder_result[i*(ATOM_WIDTH+3)+:ATOM_WIDTH+3] = adder_result_expanded[i*(ATOM_WIDTH+4)+1+:ATOM_WIDTH+3];
		end
	endgenerate

	generate
		for (k = 0; k < 8*ATOM_WIDTH+24; k++) begin 
			assign adder_result_rev[k] = adder_result[8*ATOM_WIDTH+23-k];
		end
	endgenerate


	logic        shift_left;  // should we shift left
	logic        shift_use_round;
	logic        shift_arithmetic_op, shift_arithmetic;



	logic [D_WIDTH-1:0] shift_amt_left; 
	logic [D_WIDTH-1:0] shift_amt;  
	logic [D_WIDTH-1:0] shift_amt_int; 
	logic [D_WIDTH-1:0] shift_amt_norm;  
	logic [8*ATOM_WIDTH+23:0] shift_op_a;  
	logic [8*ATOM_WIDTH+23:0] shift_right_result_tmp, shift_left_result_tmp;
	logic [D_WIDTH-1:0] shift_right_result, shift_left_result, shift_result;

	assign shift_left = (operator_i == ALU_SLL) || (shift_use_round && o_imm_i[5]);

	assign shift_use_round = round_en_i;
	
	assign shift_arithmetic_op = (operator_i == ALU_SRA) ||
								(operator_i == ALU_ADD)  || (operator_i == ALU_SUB);
	assign shift_arithmetic = shift_arithmetic_op && ~(shift_use_round && o_imm_i[5]);

	assign shift_amt = operand_b_i;

	always_comb begin : gen_shift_amt
		case (vector_mode_i)
			VEC_MODE8: begin
				for (int i = 0; i < NUM_SLICES; i++) begin
					shift_amt_norm[i*ATOM_WIDTH+:ATOM_WIDTH] = o_imm_i[2:0];
					shift_amt_left[i*ATOM_WIDTH+:ATOM_WIDTH] = shift_use_round ? shift_amt_norm[(NUM_SLICES-1-i)*ATOM_WIDTH+:ATOM_WIDTH] : shift_amt[(NUM_SLICES-1-i)*ATOM_WIDTH+:ATOM_WIDTH];
				end
			end
			VEC_MODE16: begin
				for (int i = 0; i < NUM_SLICES/2; i++) begin
					shift_amt_norm[i*2*ATOM_WIDTH+:2*ATOM_WIDTH] = o_imm_i[3:0];
					shift_amt_left[i*2*ATOM_WIDTH+:2*ATOM_WIDTH] = shift_use_round ? shift_amt_norm[(NUM_SLICES/2-1-i)*2*ATOM_WIDTH+:2*ATOM_WIDTH] : shift_amt[(NUM_SLICES/2-1-i)*2*ATOM_WIDTH+:2*ATOM_WIDTH];
				end
			end
			VEC_MODE32: begin
				for (int i = 0; i < NUM_SLICES/4; i++) begin
					shift_amt_norm[i*4*ATOM_WIDTH+:4*ATOM_WIDTH] = o_imm_i[4:0];
					shift_amt_left[i*4*ATOM_WIDTH+:4*ATOM_WIDTH] = shift_use_round ? shift_amt_norm[(NUM_SLICES/4-1-i)*4*ATOM_WIDTH+:4*ATOM_WIDTH] : shift_amt[(NUM_SLICES/4-1-i)*4*ATOM_WIDTH+:4*ATOM_WIDTH];
				end
			end 
			default: begin
				shift_amt_norm = o_imm_i[4:0];
				shift_amt_left = shift_use_round ? shift_amt_norm : shift_amt;
			end
		endcase
	end

	assign shift_op_a    = shift_left ? (shift_use_round ? adder_result_rev : op_a_ext_rev) :
							(shift_use_round ? adder_result : op_a_ext);
	assign shift_amt_int = shift_left ? shift_amt_left : (shift_use_round ? shift_amt_norm : shift_amt);


	logic [16*ATOM_WIDTH+47:0] shift_op_a_ext;

	assign shift_op_a_ext = $signed(
			{{(8*ATOM_WIDTH+24){shift_arithmetic & shift_op_a[8*ATOM_WIDTH+23]}}, shift_op_a}
		);

	always_comb begin
		case (vector_mode_i)
			VEC_MODE8: begin
				for (int i = 0; i < NUM_SLICES; i++) begin
					shift_right_result_tmp[i*(ATOM_WIDTH+3)+:ATOM_WIDTH+3] = $signed(
						{shift_arithmetic & shift_op_a[(i+1)*(ATOM_WIDTH+3)-1], shift_op_a[i*(ATOM_WIDTH+3)+:ATOM_WIDTH+3]}
					) >>> shift_amt_int[i*ATOM_WIDTH+:2];
				end
			end
			VEC_MODE16: begin
				for (int i = 0; i < NUM_SLICES/2; i++) begin
					shift_right_result_tmp[i*2*(ATOM_WIDTH+3)+:2*(ATOM_WIDTH+3)] = $signed(
						{shift_arithmetic & shift_op_a[(i+1)*2*(ATOM_WIDTH+3)-1], shift_op_a[i*2*(ATOM_WIDTH+3)+:2*(ATOM_WIDTH+3)]}
					) >>> shift_amt_int[i*2*ATOM_WIDTH+:3];
				end
			end
			VEC_MODE32: begin
				for (int i = 0; i < NUM_SLICES/4; i++) begin
					shift_right_result_tmp[i*4*(ATOM_WIDTH+3)+:4*(ATOM_WIDTH+3)] = $signed(
						{shift_arithmetic & shift_op_a[(i+1)*4*(ATOM_WIDTH+3)-1], shift_op_a[i*4*(ATOM_WIDTH+3)+:4*(ATOM_WIDTH+3)]}
					) >>> shift_amt_int[i*4*ATOM_WIDTH+:4];
				end
			end
			default: begin
				shift_right_result_tmp = shift_op_a_ext >> shift_amt_int[4:0];
			end
		endcase
	end

	generate
		for (j = 0; j < 8*ATOM_WIDTH+24; j++) begin : gen_shift_left_result
			assign shift_left_result_tmp[j] = shift_right_result_tmp[8*ATOM_WIDTH+23-j];
		end
	endgenerate

	generate
		for (i = 0; i < NUM_SLICES; i++) begin
			assign shift_right_result[i*ATOM_WIDTH+:ATOM_WIDTH] = shift_right_result_tmp[i*(ATOM_WIDTH+3)+:ATOM_WIDTH];
			assign shift_left_result[i*ATOM_WIDTH+:ATOM_WIDTH] = shift_left_result_tmp[i*(ATOM_WIDTH+3)+:ATOM_WIDTH];
		end
	endgenerate

	assign shift_result = shift_left ? shift_left_result : shift_right_result;

	

	logic [ 7:0] is_equal;
	logic [ 7:0] is_greater;  // handles both signed and unsigned forms

	logic [ 7:0] cmp_signed;
	logic [ 7:0] is_equal_vec;
	logic [ 7:0] is_greater_vec;



	always_comb begin
		cmp_signed = '0;

		unique case (operator_i)
		ALU_GT,
		ALU_GE,
		ALU_MIN,
		ALU_MAX,
		ALU_ABS: begin
			cmp_signed = op_signed_mask;
		end
		default: cmp_signed = 8'b00000000;
		endcase
	end

	
	generate
		for (i = 0; i < NUM_SLICES; i++) begin : gen_is_vec
			assign is_equal_vec[i] = (l1_op_a[i] == l1_op_b[i]);
			assign is_greater_vec[i] = ($signed(l1_op_a[i]) > $signed(l1_op_b[i]));
		end
	endgenerate

	always_comb begin
		is_equal[7:0] = {8{is_equal_vec[7] & is_equal_vec[6] & is_equal_vec[5] & is_equal_vec[4] & is_equal_vec[3] & is_equal_vec[2] & is_equal_vec[1] & is_equal_vec[0]}};
		is_greater[7:0] = {8{is_greater_vec[7] | (is_equal_vec[7] & (is_greater_vec[6]
													| (is_equal_vec[6] & (is_greater_vec[5]
													| (is_equal_vec[5] & (is_greater_vec[4]
													| (is_equal_vec[4] & (is_greater_vec[3]
													| (is_equal_vec[3] & (is_greater_vec[2]
													| (is_equal_vec[2] & (is_greater_vec[1]
													| (is_equal_vec[1] & (is_greater_vec[0]))))))))))))))}};
		case (vector_mode_i)
			VEC_MODE32: begin
				is_equal[3:0] = {4{is_equal_vec[3] & is_equal_vec[2] & is_equal_vec[1] & is_equal_vec[0]}};
				is_greater[3:0] = {4{is_greater_vec[3] | (is_equal_vec[3] & (is_greater_vec[2]
														| (is_equal_vec[2] & (is_greater_vec[1]
														| (is_equal_vec[1] & (is_greater_vec[0]))))))}};
				is_equal[7:4] = {4{is_equal_vec[7] & is_equal_vec[6] & is_equal_vec[5] & is_equal_vec[4]}};
				is_greater[7:4] = {4{is_greater_vec[7] | (is_equal_vec[7] & (is_greater_vec[6]
														| (is_equal_vec[6] & (is_greater_vec[5]
														| (is_equal_vec[5] & (is_greater_vec[4]))))))}};
			end

			
			VEC_MODE16: begin
				is_equal[1:0]   = {2{is_equal_vec[0] & is_equal_vec[1]}};
				is_equal[3:2]   = {2{is_equal_vec[2] & is_equal_vec[3]}};
				is_greater[1:0] = {2{is_greater_vec[1] | (is_equal_vec[1] & is_greater_vec[0])}};
				is_greater[3:2] = {2{is_greater_vec[3] | (is_equal_vec[3] & is_greater_vec[2])}};
				is_equal[5:4]   = {2{is_equal_vec[4] & is_equal_vec[5]}};
				is_equal[7:6]   = {2{is_equal_vec[6] & is_equal_vec[7]}};
				is_greater[5:4] = {2{is_greater_vec[5] | (is_equal_vec[5] & is_greater_vec[4])}};
				is_greater[7:6] = {2{is_greater_vec[7] | (is_equal_vec[7] & is_greater_vec[6])}};
			end

			VEC_MODE8: begin
				is_equal[7:0]   = is_equal_vec[7:0];
				is_greater[7:0] = is_greater_vec[7:0];
			end

			default: ;  
		endcase
	end

	logic [7:0] cmp_result;

	always_comb begin
		cmp_result = is_equal;
		unique case (operator_i)
		ALU_EQ:                                 cmp_result = is_equal;
		ALU_GT:                       cmp_result = is_greater;
		ALU_GE:                       cmp_result = is_greater | is_equal;
		default:                                ;
		endcase
	end



	logic [ 7:0] sel_minmax;
	logic        do_min;
	logic [D_WIDTH-1:0] minmax_b, result_minmax;

	generate
		for (i=0; i<NUM_SLICES; i++) begin
			assign minmax_b[i*ATOM_WIDTH+:ATOM_WIDTH] = (operator_i == ALU_ABS) ? adder_result[i*(ATOM_WIDTH+3)+:ATOM_WIDTH] : operand_b_i[i*ATOM_WIDTH+:ATOM_WIDTH];
		end
	endgenerate

	assign do_min   = (operator_i == ALU_MIN);

	assign sel_minmax[7:0] = is_greater ^ {8{do_min}};

	generate
		for (i=0; i<NUM_SLICES; i++) begin
			assign result_minmax[i*ATOM_WIDTH+:ATOM_WIDTH] = (sel_minmax[i] == 1'b1) ? operand_a_i[i*ATOM_WIDTH+:ATOM_WIDTH] : minmax_b[i*ATOM_WIDTH+:ATOM_WIDTH];
		end
	endgenerate


	logic [D_WIDTH-1:0] result_phi;
	logic [7:0] phi_sel;

	assign is_br_cond_i = ((operator_i == ALU_EQ) || (operator_i == ALU_GT) || (operator_i == ALU_GE)) & operator_ext_en_i;
	assign is_tny_cond_i = (operator_i == ALU_PHI) & operator_ext_en_i;

	generate
		genvar p;
		for (p = 0; p < NUM_SLICES; p++) begin : gen_phi
			assign phi_sel[p] = is_tny_cond_i ? operand_c_i[p] : predicate_a_i;
			assign result_phi[p*ATOM_WIDTH+:ATOM_WIDTH] = phi_sel[p] ? operand_a_i[p*ATOM_WIDTH+:ATOM_WIDTH] : operand_b_i[p*ATOM_WIDTH+:ATOM_WIDTH];
		end
	endgenerate

	assign result_predicate_o[0] = is_br_cond_i ? cmp_result[0] : ( (operator_i == ALU_PHI) ? (predicate_a_i | predicate_b_i) : (predicate_a_i & predicate_b_i & op_predicate_i) );
	assign result_predicate_o[1] = is_br_cond_i ? ~cmp_result[0] : (predicate_a_i & predicate_b_i & op_predicate_i);


	logic [63:0] result_shuf[2];
	always_comb begin 
		result_shuf[0] = operand_a_i;
		result_shuf[1] = operand_b_i;
		unique case(vector_mode_i)
			VEC_MODE32: begin
				unique case (alu_ext_mode_i)
					3'd0: begin
						for (int i = 0; i < NUM_SLICES/8; i++) begin
							result_shuf[0][i*8*ATOM_WIDTH+:8*ATOM_WIDTH] = {operand_b_i[(2*i+1)*4*ATOM_WIDTH+:4*ATOM_WIDTH], operand_a_i[(2*i+1)*4*ATOM_WIDTH+:4*ATOM_WIDTH]};
							result_shuf[1][i*8*ATOM_WIDTH+:8*ATOM_WIDTH] = {operand_b_i[2*i*4*ATOM_WIDTH+:4*ATOM_WIDTH], operand_a_i[2*i*4*ATOM_WIDTH+:4*ATOM_WIDTH]};
						end
					end
					3'd1: begin
						for (int i = 0; i < NUM_SLICES/8; i++) begin
							result_shuf[0][i*8*ATOM_WIDTH+:8*ATOM_WIDTH] = {operand_a_i[2*i*4*ATOM_WIDTH+:4*ATOM_WIDTH], operand_b_i[2*i*4*ATOM_WIDTH+:4*ATOM_WIDTH]};
							result_shuf[1][i*8*ATOM_WIDTH+:8*ATOM_WIDTH] = {operand_a_i[(2*i+1)*4*ATOM_WIDTH+:4*ATOM_WIDTH], operand_b_i[(2*i+1)*4*ATOM_WIDTH+:4*ATOM_WIDTH]};
						end
					end
					3'd2: begin
						for (int i = 0; i < NUM_SLICES/8; i++) begin
							result_shuf[0][i*8*ATOM_WIDTH+:8*ATOM_WIDTH] = {operand_a_i[(2*i+1)*4*ATOM_WIDTH+:4*ATOM_WIDTH], operand_b_i[(2*i+1)*4*ATOM_WIDTH+:4*ATOM_WIDTH]};
							result_shuf[1][i*8*ATOM_WIDTH+:8*ATOM_WIDTH] = {operand_a_i[2*i*4*ATOM_WIDTH+:4*ATOM_WIDTH], operand_b_i[2*i*4*ATOM_WIDTH+:4*ATOM_WIDTH]};
						end
					end
					3'd3: begin
						for (int i = 0; i < NUM_SLICES/8; i++) begin
							result_shuf[0][i*8*ATOM_WIDTH+:8*ATOM_WIDTH] = {operand_b_i[2*i*4*ATOM_WIDTH+:4*ATOM_WIDTH], operand_a_i[2*i*4*ATOM_WIDTH+:4*ATOM_WIDTH]};
							result_shuf[1][i*8*ATOM_WIDTH+:8*ATOM_WIDTH] = {operand_b_i[(2*i+1)*4*ATOM_WIDTH+:4*ATOM_WIDTH], operand_a_i[(2*i+1)*4*ATOM_WIDTH+:4*ATOM_WIDTH]};
						end
					end
					3'd4: begin
						for (int i = 0; i < NUM_SLICES/8; i++) begin
							result_shuf[0][i*8*ATOM_WIDTH+:8*ATOM_WIDTH] = {operand_a_i[(2*i+1)*4*ATOM_WIDTH+:4*ATOM_WIDTH], operand_b_i[2*i*4*ATOM_WIDTH+:4*ATOM_WIDTH]};
							result_shuf[1][i*8*ATOM_WIDTH+:8*ATOM_WIDTH] = {operand_b_i[(2*i+1)*4*ATOM_WIDTH+:4*ATOM_WIDTH], operand_a_i[2*i*4*ATOM_WIDTH+:4*ATOM_WIDTH]};
						end
					end
					3'd5: begin
						for (int i = 0; i < NUM_SLICES/8; i++) begin
							result_shuf[0][i*8*ATOM_WIDTH+:8*ATOM_WIDTH] = {operand_b_i[(2*i+1)*4*ATOM_WIDTH+:4*ATOM_WIDTH], operand_a_i[2*i*4*ATOM_WIDTH+:4*ATOM_WIDTH]};
							result_shuf[1][i*8*ATOM_WIDTH+:8*ATOM_WIDTH] = {operand_a_i[(2*i+1)*4*ATOM_WIDTH+:4*ATOM_WIDTH], operand_b_i[2*i*4*ATOM_WIDTH+:4*ATOM_WIDTH]};
						end
					end
					3'd6: begin
						for (int i = 0; i < NUM_SLICES/8; i++) begin
							result_shuf[0][i*8*ATOM_WIDTH+:8*ATOM_WIDTH] = {32'b0, operand_a_i[2*i*4*ATOM_WIDTH+:4*ATOM_WIDTH]};
							result_shuf[1][i*8*ATOM_WIDTH+:8*ATOM_WIDTH] = {32'b0, operand_b_i[2*i*4*ATOM_WIDTH+:4*ATOM_WIDTH]};
						end
					end
					3'd7: begin
						for (int i = 0; i < NUM_SLICES/8; i++) begin
							result_shuf[0][i*8*ATOM_WIDTH+:8*ATOM_WIDTH] = {32'b0, operand_a_i[(2*i+1)*4*ATOM_WIDTH+:4*ATOM_WIDTH]};
							result_shuf[1][i*8*ATOM_WIDTH+:8*ATOM_WIDTH] = {32'b0, operand_b_i[(2*i+1)*4*ATOM_WIDTH+:4*ATOM_WIDTH]};
						end
					end
					default: ;
				endcase
			end
			VEC_MODE16: begin
				unique case (alu_ext_mode_i)
					3'd0: begin
						for (int i = 0; i < NUM_SLICES/4; i++) begin
							result_shuf[0][i*4*ATOM_WIDTH+:4*ATOM_WIDTH] = {operand_b_i[(2*i+1)*2*ATOM_WIDTH+:2*ATOM_WIDTH], operand_a_i[(2*i+1)*2*ATOM_WIDTH+:2*ATOM_WIDTH]};
							result_shuf[1][i*4*ATOM_WIDTH+:4*ATOM_WIDTH] = {operand_b_i[2*i*2*ATOM_WIDTH+:2*ATOM_WIDTH], operand_a_i[2*i*2*ATOM_WIDTH+:2*ATOM_WIDTH]};
						end
					end
					3'd1: begin
						for (int i = 0; i < NUM_SLICES/4; i++) begin
							result_shuf[0][i*4*ATOM_WIDTH+:4*ATOM_WIDTH] = {operand_a_i[2*i*2*ATOM_WIDTH+:2*ATOM_WIDTH], operand_b_i[2*i*2*ATOM_WIDTH+:2*ATOM_WIDTH]};
							result_shuf[1][i*4*ATOM_WIDTH+:4*ATOM_WIDTH] = {operand_a_i[(2*i+1)*2*ATOM_WIDTH+:2*ATOM_WIDTH], operand_b_i[(2*i+1)*2*ATOM_WIDTH+:2*ATOM_WIDTH]};
						end
					end
					3'd2: begin
						for (int i = 0; i < NUM_SLICES/4; i++) begin
							result_shuf[0][i*4*ATOM_WIDTH+:4*ATOM_WIDTH] = {operand_a_i[(2*i+1)*2*ATOM_WIDTH+:2*ATOM_WIDTH], operand_b_i[(2*i+1)*2*ATOM_WIDTH+:2*ATOM_WIDTH]};
							result_shuf[1][i*4*ATOM_WIDTH+:4*ATOM_WIDTH] = {operand_a_i[2*i*2*ATOM_WIDTH+:2*ATOM_WIDTH], operand_b_i[2*i*2*ATOM_WIDTH+:2*ATOM_WIDTH]};
						end
					end
					3'd3: begin
						for (int i = 0; i < NUM_SLICES/4; i++) begin
							result_shuf[0][i*4*ATOM_WIDTH+:4*ATOM_WIDTH] = {operand_b_i[2*i*2*ATOM_WIDTH+:2*ATOM_WIDTH], operand_a_i[2*i*2*ATOM_WIDTH+:2*ATOM_WIDTH]};
							result_shuf[1][i*4*ATOM_WIDTH+:4*ATOM_WIDTH] = {operand_b_i[(2*i+1)*2*ATOM_WIDTH+:2*ATOM_WIDTH], operand_a_i[(2*i+1)*2*ATOM_WIDTH+:2*ATOM_WIDTH]};
						end
					end
					3'd4: begin
						for (int i = 0; i < NUM_SLICES/4; i++) begin
							result_shuf[0][i*4*ATOM_WIDTH+:4*ATOM_WIDTH] = {operand_a_i[(2*i+1)*2*ATOM_WIDTH+:2*ATOM_WIDTH], operand_b_i[2*i*2*ATOM_WIDTH+:2*ATOM_WIDTH]};
							result_shuf[1][i*4*ATOM_WIDTH+:4*ATOM_WIDTH] = {operand_b_i[(2*i+1)*2*ATOM_WIDTH+:2*ATOM_WIDTH], operand_a_i[2*i*2*ATOM_WIDTH+:2*ATOM_WIDTH]};
						end
					end
					3'd5: begin
						for (int i = 0; i < NUM_SLICES/4; i++) begin
							result_shuf[0][i*4*ATOM_WIDTH+:4*ATOM_WIDTH] = {operand_b_i[(2*i+1)*2*ATOM_WIDTH+:2*ATOM_WIDTH], operand_a_i[2*i*2*ATOM_WIDTH+:2*ATOM_WIDTH]};
							result_shuf[1][i*4*ATOM_WIDTH+:4*ATOM_WIDTH] = {operand_a_i[(2*i+1)*2*ATOM_WIDTH+:2*ATOM_WIDTH], operand_b_i[2*i*2*ATOM_WIDTH+:2*ATOM_WIDTH]};
						end
					end
					3'd6: begin
						for (int i = 0; i < NUM_SLICES/4; i++) begin
							result_shuf[0][i*4*ATOM_WIDTH+:4*ATOM_WIDTH] = {32'b0, operand_a_i[2*i*2*ATOM_WIDTH+:2*ATOM_WIDTH]};
							result_shuf[1][i*4*ATOM_WIDTH+:4*ATOM_WIDTH] = {32'b0, operand_b_i[2*i*2*ATOM_WIDTH+:2*ATOM_WIDTH]};
						end
					end
					3'd7: begin
						for (int i = 0; i < NUM_SLICES/4; i++) begin
							result_shuf[0][i*4*ATOM_WIDTH+:4*ATOM_WIDTH] = {32'b0, operand_a_i[(2*i+1)*2*ATOM_WIDTH+:2*ATOM_WIDTH]};
							result_shuf[1][i*4*ATOM_WIDTH+:4*ATOM_WIDTH] = {32'b0, operand_b_i[(2*i+1)*2*ATOM_WIDTH+:2*ATOM_WIDTH]};
						end
					end
					default: ;
				endcase
			end
			VEC_MODE8: begin
				unique case (alu_ext_mode_i)
					3'd0: begin
						for (int i = 0; i < NUM_SLICES/2; i++) begin
							result_shuf[0][i*2*ATOM_WIDTH+:2*ATOM_WIDTH] = {operand_b_i[(2*i+1)*ATOM_WIDTH+:ATOM_WIDTH], operand_a_i[(2*i+1)*ATOM_WIDTH+:ATOM_WIDTH]};
							result_shuf[1][i*2*ATOM_WIDTH+:2*ATOM_WIDTH] = {operand_b_i[2*i*ATOM_WIDTH+:ATOM_WIDTH], operand_a_i[2*i*ATOM_WIDTH+:ATOM_WIDTH]};
						end
					end
					3'd1: begin
						for (int i = 0; i < NUM_SLICES/2; i++) begin
							result_shuf[0][i*2*ATOM_WIDTH+:2*ATOM_WIDTH] = {operand_a_i[2*i*ATOM_WIDTH+:ATOM_WIDTH], operand_b_i[2*i*ATOM_WIDTH+:ATOM_WIDTH]};
							result_shuf[1][i*2*ATOM_WIDTH+:2*ATOM_WIDTH] = {operand_a_i[(2*i+1)*ATOM_WIDTH+:ATOM_WIDTH], operand_b_i[(2*i+1)*ATOM_WIDTH+:ATOM_WIDTH]};
						end
					end
					3'd2: begin
						for (int i = 0; i < NUM_SLICES/2; i++) begin
							result_shuf[0][i*2*ATOM_WIDTH+:2*ATOM_WIDTH] = {operand_a_i[(2*i+1)*ATOM_WIDTH+:ATOM_WIDTH], operand_b_i[(2*i+1)*ATOM_WIDTH+:ATOM_WIDTH]};
							result_shuf[1][i*2*ATOM_WIDTH+:2*ATOM_WIDTH] = {operand_a_i[2*i*ATOM_WIDTH+:ATOM_WIDTH], operand_b_i[2*i*ATOM_WIDTH+:ATOM_WIDTH]};
						end
					end
					3'd3: begin
						for (int i = 0; i < NUM_SLICES/2; i++) begin
							result_shuf[0][i*2*ATOM_WIDTH+:2*ATOM_WIDTH] = {operand_b_i[2*i*ATOM_WIDTH+:ATOM_WIDTH], operand_a_i[2*i*ATOM_WIDTH+:ATOM_WIDTH]};
							result_shuf[1][i*2*ATOM_WIDTH+:2*ATOM_WIDTH] = {operand_b_i[(2*i+1)*ATOM_WIDTH+:ATOM_WIDTH], operand_a_i[(2*i+1)*ATOM_WIDTH+:ATOM_WIDTH]};
						end
					end
					3'd4: begin
						for (int i = 0; i < NUM_SLICES/2; i++) begin
							result_shuf[0][i*2*ATOM_WIDTH+:2*ATOM_WIDTH] = {operand_a_i[(2*i+1)*ATOM_WIDTH+:ATOM_WIDTH], operand_b_i[2*i*ATOM_WIDTH+:ATOM_WIDTH]};
							result_shuf[1][i*2*ATOM_WIDTH+:2*ATOM_WIDTH] = {operand_b_i[(2*i+1)*ATOM_WIDTH+:ATOM_WIDTH], operand_a_i[2*i*ATOM_WIDTH+:ATOM_WIDTH]};
						end
					end
					3'd5: begin
						for (int i = 0; i < NUM_SLICES/2; i++) begin
							result_shuf[0][i*2*ATOM_WIDTH+:2*ATOM_WIDTH] = {operand_b_i[(2*i+1)*ATOM_WIDTH+:ATOM_WIDTH], operand_a_i[2*i*ATOM_WIDTH+:ATOM_WIDTH]};
							result_shuf[1][i*2*ATOM_WIDTH+:2*ATOM_WIDTH] = {operand_a_i[(2*i+1)*ATOM_WIDTH+:ATOM_WIDTH], operand_b_i[2*i*ATOM_WIDTH+:ATOM_WIDTH]};
						end
					end
					3'd6: begin
						for (int i = 0; i < NUM_SLICES/2; i++) begin
							result_shuf[0][i*2*ATOM_WIDTH+:2*ATOM_WIDTH] = {32'b0, operand_a_i[2*i*ATOM_WIDTH+:ATOM_WIDTH]};
							result_shuf[1][i*2*ATOM_WIDTH+:2*ATOM_WIDTH] = {32'b0, operand_b_i[2*i*ATOM_WIDTH+:ATOM_WIDTH]};
						end
					end
					3'd7: begin
						for (int i = 0; i < NUM_SLICES/2; i++) begin
							result_shuf[0][i*2*ATOM_WIDTH+:2*ATOM_WIDTH] = {32'b0, operand_a_i[(2*i+1)*ATOM_WIDTH+:ATOM_WIDTH]};
							result_shuf[1][i*2*ATOM_WIDTH+:2*ATOM_WIDTH] = {32'b0, operand_b_i[(2*i+1)*ATOM_WIDTH+:ATOM_WIDTH]};
						end
					end
					default: ;
				endcase
			end
			default: ;
		endcase
	end


  always_comb begin
    result_o[0] = '0;
    result_o[1] = '0;

    unique case (operator_i)
      ALU_AND: result_o[0] = operand_a_i & operand_b_i;
      ALU_OR:  result_o[0] = operand_a_i | operand_b_i;
      ALU_XOR: result_o[0] = operand_a_i ^ operand_b_i;

	  ALU_ADD, 
      ALU_SUB, 
      ALU_SLL,
      ALU_SRL, 
	  ALU_SRA:
      	result_o[0] = shift_result;

	  ALU_RADD: result_o[0] = radder_result;





      ALU_MIN, ALU_MAX: result_o[0] = result_minmax;

      ALU_ABS: result_o[0] = result_minmax;


      ALU_EQ, 
      ALU_GT, 
      ALU_GE: begin
        result_o[0] = cmp_result;
      end

      ALU_PHI: result_o[0] = result_phi;


	  ALU_SHUF: begin
		result_o[0] = result_shuf[0];
		result_o[1] = result_shuf[1];
	  end

      default: ;  // default case to suppress unique warning
    endcase
  end


endmodule

`endif /* VEC_ALU */


`ifndef VEC_ALU_NOPARAM
`define VEC_ALU_NOPARAM

module VEC_ALU_noparam
(
  input logic [3-1:0] alu_ext_mode_i ,
  input logic [1-1:0] clk ,
  input logic [1-1:0] ex_en_i ,
  output logic [1-1:0] ex_rdy_o ,
  input logic [6-1:0] o_imm_i ,
  input logic [1-1:0] op_predicate_i ,
  input logic [3-1:0] op_signed_i ,
  input logic [64-1:0] operand_a_i ,
  input logic [64-1:0] operand_b_i ,
  input logic [64-1:0] operand_c_i ,
  input logic [1-1:0] operator_ext_en_i ,
  input logic [7-1:0] operator_i ,
  output logic [1-1:0] out_en_o ,
  input logic [1-1:0] out_rdy_i ,
  input logic [1-1:0] predicate_a_i ,
  input logic [1-1:0] predicate_b_i ,
  input logic [1-1:0] predicate_c_i ,
  input logic [1-1:0] reset ,
  output logic [64-1:0] result_o [0:1],
  output logic [1-1:0] result_predicate_o [0:1],
  input logic [1-1:0] round_en_i ,
  input logic [2-1:0] vector_mode_i 
);
  vec_alu
  #(
  ) v
  (
    .alu_ext_mode_i( alu_ext_mode_i ),
    .clk( clk ),
    .ex_en_i( ex_en_i ),
    .ex_rdy_o( ex_rdy_o ),
    .o_imm_i( o_imm_i ),
    .op_predicate_i( op_predicate_i ),
    .op_signed_i( op_signed_i ),
    .operand_a_i( operand_a_i ),
    .operand_b_i( operand_b_i ),
    .operand_c_i( operand_c_i ),
    .operator_ext_en_i( operator_ext_en_i ),
    .operator_i( operator_i ),
    .out_en_o( out_en_o ),
    .out_rdy_i( out_rdy_i ),
    .predicate_a_i( predicate_a_i ),
    .predicate_b_i( predicate_b_i ),
    .predicate_c_i( predicate_c_i ),
    .reset( reset ),
    .result_o( result_o ),
    .result_predicate_o( result_predicate_o ),
    .round_en_i( round_en_i ),
    .vector_mode_i( vector_mode_i )
  );
endmodule

`endif /* VEC_ALU_NOPARAM */




module ALURTL__e9baeef75836042d
(
  input  logic [5:0] bmask_b_i ,
  input  logic [0:0] clk ,
  input  logic [2:0] ex_alu_ext_mode_i ,
  input  logic [2:0] ex_operand_signed_i ,
  input  logic [6:0] ex_operator_i ,
  input  logic [0:0] ex_round_enable_i ,
  input  CGRAData_64_1__payload_64__predicate_1 operand_a_i ,
  input  CGRAData_64_1__payload_64__predicate_1 operand_b_i ,
  input  CGRAData_64_1__payload_64__predicate_1 operand_c_i ,
  input  logic [0:0] operator_ext_en_i ,
  input  logic [0:0] opt_launch_en_i ,
  output logic [0:0] opt_launch_rdy_o ,
  input  logic [0:0] output_rdy_i ,
  input  logic [0:0] recv_predicate_en ,
  input  CGRAData_1__predicate_1 recv_predicate_msg ,
  input  logic [0:0] reset ,
  input  logic [1:0] vector_mode_i ,
  output logic [0:0] send_out__en [0:1] ,
  output CGRAData_64_1__payload_64__predicate_1 send_out__msg [0:1] ,
  input logic [0:0] send_out__rdy [0:1] 
);
  logic [0:0] alu_enable;
  logic [63:0] alu_operand_a;
  logic [63:0] alu_operand_b;
  logic [63:0] alu_operand_c;
  logic [0:0] alu_predicate_a;
  logic [0:0] alu_predicate_b;
  logic [0:0] alu_predicate_c;
  logic [0:0] op_predicate_i;
  CGRAData_64_1__payload_64__predicate_1 result_o_vector [0:1];

  logic [2:0] alu_element_alu_ext_mode_i;
  logic [0:0] alu_element_clk;
  logic [0:0] alu_element_ex_en_i;
  logic [0:0] alu_element_ex_rdy_o;
  logic [5:0] alu_element_o_imm_i;
  logic [0:0] alu_element_op_predicate_i;
  logic [2:0] alu_element_op_signed_i;
  logic [63:0] alu_element_operand_a_i;
  logic [63:0] alu_element_operand_b_i;
  logic [63:0] alu_element_operand_c_i;
  logic [0:0] alu_element_operator_ext_en_i;
  logic [6:0] alu_element_operator_i;
  logic [0:0] alu_element_out_en_o;
  logic [0:0] alu_element_out_rdy_i;
  logic [0:0] alu_element_predicate_a_i;
  logic [0:0] alu_element_predicate_b_i;
  logic [0:0] alu_element_predicate_c_i;
  logic [0:0] alu_element_reset;
  logic [63:0] alu_element_result_o [0:1];
  logic [0:0] alu_element_result_predicate_o [0:1];
  logic [0:0] alu_element_round_en_i;
  logic [1:0] alu_element_vector_mode_i;

  VEC_ALU_noparam alu_element
  (
    .alu_ext_mode_i( alu_element_alu_ext_mode_i ),
    .clk( alu_element_clk ),
    .ex_en_i( alu_element_ex_en_i ),
    .ex_rdy_o( alu_element_ex_rdy_o ),
    .o_imm_i( alu_element_o_imm_i ),
    .op_predicate_i( alu_element_op_predicate_i ),
    .op_signed_i( alu_element_op_signed_i ),
    .operand_a_i( alu_element_operand_a_i ),
    .operand_b_i( alu_element_operand_b_i ),
    .operand_c_i( alu_element_operand_c_i ),
    .operator_ext_en_i( alu_element_operator_ext_en_i ),
    .operator_i( alu_element_operator_i ),
    .out_en_o( alu_element_out_en_o ),
    .out_rdy_i( alu_element_out_rdy_i ),
    .predicate_a_i( alu_element_predicate_a_i ),
    .predicate_b_i( alu_element_predicate_b_i ),
    .predicate_c_i( alu_element_predicate_c_i ),
    .reset( alu_element_reset ),
    .result_o( alu_element_result_o ),
    .result_predicate_o( alu_element_result_predicate_o ),
    .round_en_i( alu_element_round_en_i ),
    .vector_mode_i( alu_element_vector_mode_i )
  );


  
  always_comb begin : _lambda__s_tile_0__element_fu_0_alu_operand_a
    alu_operand_a = alu_enable ? operand_a_i.payload : 64'd0;
  end

  
  always_comb begin : _lambda__s_tile_0__element_fu_0_alu_operand_b
    alu_operand_b = alu_enable ? operand_b_i.payload : 64'd0;
  end

  
  always_comb begin : _lambda__s_tile_0__element_fu_0_alu_operand_c
    alu_operand_c = alu_enable ? operand_c_i.payload : 64'd0;
  end

  
  always_comb begin : _lambda__s_tile_0__element_fu_0_alu_predicate_a
    alu_predicate_a = alu_enable ? operand_a_i.predicate : 1'd0;
  end

  
  always_comb begin : _lambda__s_tile_0__element_fu_0_alu_predicate_b
    alu_predicate_b = alu_enable ? operand_b_i.predicate : 1'd0;
  end

  
  always_comb begin : _lambda__s_tile_0__element_fu_0_alu_predicate_c
    alu_predicate_c = alu_enable ? operand_c_i.predicate : 1'd0;
  end

  
  always_comb begin : _lambda__s_tile_0__element_fu_0_op_predicate_i
    op_predicate_i = ( ~recv_predicate_en | recv_predicate_msg.predicate ) & alu_enable;
  end

  assign alu_element_clk = clk;
  assign alu_element_reset = reset;
  assign alu_enable = opt_launch_en_i;
  assign opt_launch_rdy_o = alu_element_ex_rdy_o;
  assign alu_element_ex_en_i = alu_enable;
  assign alu_element_out_rdy_i = output_rdy_i;
  assign alu_element_alu_ext_mode_i = ex_alu_ext_mode_i;
  assign alu_element_vector_mode_i = vector_mode_i;
  assign alu_element_operator_i = ex_operator_i;
  assign alu_element_op_signed_i = ex_operand_signed_i;
  assign alu_element_round_en_i = ex_round_enable_i;
  assign alu_element_operator_ext_en_i = operator_ext_en_i;
  assign alu_element_o_imm_i = bmask_b_i;
  assign alu_element_operand_a_i = alu_operand_a;
  assign alu_element_operand_b_i = alu_operand_b;
  assign alu_element_operand_c_i = alu_operand_c;
  assign alu_element_predicate_a_i = alu_predicate_a;
  assign alu_element_predicate_b_i = alu_predicate_b;
  assign alu_element_predicate_c_i = alu_predicate_c;
  assign alu_element_op_predicate_i = op_predicate_i;
  assign result_o_vector[0].payload = alu_element_result_o[0];
  assign result_o_vector[0].predicate = alu_element_result_predicate_o[0];
  assign result_o_vector[1].payload = alu_element_result_o[1];
  assign result_o_vector[1].predicate = alu_element_result_predicate_o[1];
  assign send_out__msg[0] = result_o_vector[0];
  assign send_out__en[0] = alu_element_out_en_o;
  assign send_out__msg[1] = result_o_vector[1];
  assign send_out__en[1] = alu_element_out_en_o;

endmodule





`ifndef VEC_MUL
`define VEC_MUL





module vec_mult #(
	parameter D_WIDTH         = 64,
	parameter Q_WIDTH         = 32,
	parameter ATOM_WIDTH      = 8,
	parameter MAX_ITER        = 2048,
  parameter PIPELINE_STAGES = 3
)
(
    input logic clk,
    input logic reset,
    input logic fu_local_reset_stage,
    input logic fu_local_reset_ctrl,
    input logic fu_local_reset_data,
    input logic fu_dry_run_done,
    input logic fu_sync_dry_run,

    input logic [1:0] vector_mode_i,
    input logic [1:0] operator_i,

    input logic [2:0] op_signed_i,
    input logic round_en_i,
    input logic operator_ext_en_i,
    input logic [$clog2(Q_WIDTH):0] o_imm_i,

    input logic [D_WIDTH-1:0] op_a_i,
    input logic [D_WIDTH-1:0] op_b_i,
    input logic [D_WIDTH-1:0] op_c_i,


    output logic [D_WIDTH-1:0] result_o [2], // todo

    input logic op_predicate_i,
    output logic result_predicate_o,

    output logic mul_is_ff_cc_rdy_o,
    output logic out_en_o,
    input logic out_rdy_i,
    output logic ex_rdy_o,
    input  logic ex_en_i
);
    localparam NUM_SLICES = D_WIDTH/ATOM_WIDTH;
    localparam NUM_STAGES_L2 = $clog2(NUM_SLICES/2);
    localparam NUM_STAGES_L1 = $clog2(NUM_SLICES);



    localparam VEC_MODE32 = 2'b00;
    localparam VEC_MODE16 = 2'b10;
    localparam VEC_MODE8 = 2'b11;

    localparam MUL_MAC = 2'b00;
    localparam MUL_DOT = 2'b01;
    localparam MUL_CMAC = 2'b10;
    localparam MUL_CDOT = 2'b11;


    logic [3:0] op_signed_mask, op_signed_mask_s1, op_signed_mask_s2;

    logic [ATOM_WIDTH:0] char_op_a [NUM_SLICES];
    logic [ATOM_WIDTH:0] char_op_a_rev [NUM_SLICES];
    logic [ATOM_WIDTH:0] char_op_b [NUM_SLICES];

    logic [ATOM_WIDTH:0] char_op_a_h [NUM_SLICES];
    logic [ATOM_WIDTH:0] char_op_a_rev_h [NUM_SLICES];
    logic [ATOM_WIDTH:0] char_op_b_h [NUM_SLICES];

    logic [2*ATOM_WIDTH+1:0] out_tmp [NUM_SLICES];
    logic [2*ATOM_WIDTH+1:0] out_tmp_rev [NUM_SLICES];

    logic [2*ATOM_WIDTH+1:0] out_tmp_h [NUM_SLICES];
    logic [2*ATOM_WIDTH+1:0] out_tmp_rev_h [NUM_SLICES];

    logic is_cplx, is_cplx_s1, is_cplx_s2;
    logic is_ff_cc_s0, is_ff_rdy_s0;
    logic is_ff_cc_s1, is_ff_rdy_s1;
    logic l2_p_en_s0, l3_p_en_s0;
    logic l1_p_en_s1, l2_p_en_s1, l3_p_en_s1;

    logic [D_WIDTH-1:0] accumulator_s1;
    logic [1:0] operator_s1, operator_s2;
    logic op_signed_c_s1;
    logic dot_ext_en_i, dot_ext_en_s1;
    logic round_en_s1;
    logic [1:0] vector_mode_s1, vector_mode_s2;
    logic [$clog2(Q_WIDTH):0] o_shift_imm_s1, o_shift_imm_s2;

    logic [2*ATOM_WIDTH+1:0] mac_in_a_s0 [NUM_SLICES];
    logic [2*ATOM_WIDTH+1:0] mac_in_b_tmp_s0 [NUM_SLICES];
    logic [2*ATOM_WIDTH+1:0] mac_in_b_s0 [NUM_SLICES];
    logic [2*ATOM_WIDTH+4:0] mac_l1_acc_s1_tmp [NUM_SLICES];
    logic [2*ATOM_WIDTH+4:0] mac_l1_acc_s1 [NUM_SLICES];
    logic [2*ATOM_WIDTH+1:0] dot_l1_out_s0 [NUM_SLICES/2];
    logic [2*ATOM_WIDTH+1:0] dot_l1_out_s1 [NUM_SLICES/2];
    logic [2*ATOM_WIDTH+4:0] dot_l1_out_ext_s1 [NUM_SLICES/2];

    logic [2*ATOM_WIDTH+1:0] mac_l2_p_s0 [NUM_SLICES];
    logic [2*ATOM_WIDTH+1:0] mac_l2_cr_s0 [NUM_SLICES];
    logic [2*ATOM_WIDTH+1:0] mac_l2_cr_s1 [NUM_SLICES];
    logic [2*ATOM_WIDTH+4:0] mac_l2_cr_ext_s1 [NUM_SLICES];
    logic [2*ATOM_WIDTH+1:0] mac_l2_ci_s0 [NUM_SLICES];
    logic [2*ATOM_WIDTH+1:0] mac_l2_ci_s1 [NUM_SLICES];
    logic [2*ATOM_WIDTH+4:0] mac_l2_ci_ext_s1 [NUM_SLICES];
    logic [2*ATOM_WIDTH+1:0] mac_l2_cr_result_s1_tmp [NUM_SLICES];
    logic [2*ATOM_WIDTH+1:0] mac_l2_ci_result_s1_tmp [NUM_SLICES];
    logic [4*ATOM_WIDTH+1:0] mac_l2_out_s0 [NUM_SLICES/2];
    logic [4*ATOM_WIDTH+1:0] mac_l2_out_s1 [NUM_SLICES/2];
    logic [4*ATOM_WIDTH+1:0] mac_l2_out_h_s0 [NUM_SLICES/2];
    logic [4*ATOM_WIDTH+1:0] mac_l2_out_h_s1 [NUM_SLICES/2];
    logic [4*ATOM_WIDTH+9:0] mac_l2_out_ext_s1 [NUM_SLICES/2];
    logic [4*ATOM_WIDTH+9:0] mac_l2_acc_s1_tmp [NUM_SLICES/2];
    logic [4*ATOM_WIDTH+9:0] mac_l2_acc_s1 [NUM_SLICES/2];
    logic [4*ATOM_WIDTH+9:0] mac_l2_acc_s2 [NUM_SLICES/2];


    logic [4*ATOM_WIDTH+1:0] mac_l3_p_s1 [NUM_SLICES/4];
    logic [4*ATOM_WIDTH+1:0] mac_l3_cr_s1 [NUM_SLICES/2];
    logic [4*ATOM_WIDTH+9:0] mac_l3_cr_ext_s1 [NUM_SLICES/2];
    logic [4*ATOM_WIDTH+1:0] mac_l3_ci_s1 [NUM_SLICES/2];
    logic [4*ATOM_WIDTH+9:0] mac_l3_ci_ext_s1 [NUM_SLICES/2];
    logic [4*ATOM_WIDTH+1:0] mac_l3_cr_result_s1_tmp [NUM_SLICES/2];
    logic [4*ATOM_WIDTH+1:0] mac_l3_ci_result_s1_tmp [NUM_SLICES/2];
    logic [8*ATOM_WIDTH+1:0] mac_l3_out_s1 [NUM_SLICES/4];
    logic [8*ATOM_WIDTH+19:0] mac_l3_out_ext_s1 [NUM_SLICES/4];
    logic [8*ATOM_WIDTH+19:0] mac_l3_acc_s1_tmp [NUM_SLICES/4];
    logic [8*ATOM_WIDTH+19:0] mac_l3_acc_s1 [NUM_SLICES/4];
    logic [8*ATOM_WIDTH+19:0] mac_l3_acc_s2 [NUM_SLICES/4];
    logic [8*ATOM_WIDTH+19:0] dot_l3_acc_s1, dot_l3_acc_cr_s1, dot_l3_acc_ci_s1;
    logic [8*ATOM_WIDTH+19:0] dot_l3_acc_out_s1 [NUM_SLICES/4];
    logic [8*ATOM_WIDTH+19:0] dot_l3_acc_out_s2 [NUM_SLICES/4];

    logic [16*ATOM_WIDTH+47:0] acc_0_out_s1, acc_0_out_s2;
    logic [8*ATOM_WIDTH+23:0] acc_1_in_a_s1, acc_1_in_b_s1, acc_1_out_s1;
    logic [8*ATOM_WIDTH+23:0] acc_2_in_a_s1, acc_2_in_b_s1, acc_2_out_s1;
    logic [4*ATOM_WIDTH+11:0] acc_3_in_a_s1, acc_3_in_b_s1, acc_3_out_s1;
    logic [2*ATOM_WIDTH+5:0] acc_4_in_a_s1, acc_4_in_b_s1, acc_4_out_s1;
    logic [2*ATOM_WIDTH+17:0] acc_5_in_a_s1, acc_5_in_b_s1, acc_5_out_s1;
    logic [4*ATOM_WIDTH+11:0] acc_6_in_a_s1, acc_6_in_b_s1, acc_6_out_s1;
    logic [4*ATOM_WIDTH+11:0] acc_7_in_a_s1, acc_7_in_b_s1, acc_7_out_s1;
    logic [4*ATOM_WIDTH+11:0] acc_8_in_a_s1, acc_8_in_b_s1, acc_8_out_s1;

    logic [2*ATOM_WIDTH+2:0] l1_result_s0_tmp [NUM_SLICES];    
    logic [2*ATOM_WIDTH+4:0] l1_result_s1_tmp [NUM_SLICES];    
    logic [2*ATOM_WIDTH+4:0] l1_result_s1_q [NUM_SLICES];    
    logic [2*ATOM_WIDTH+4:0] l1_result_j_s1_tmp [NUM_SLICES];    
    logic [2*ATOM_WIDTH+4:0] l1_result_j_s1_q [NUM_SLICES];    
    logic [4*ATOM_WIDTH+9:0] l2_result_s1_tmp [NUM_SLICES/2];    
    logic [4*ATOM_WIDTH+9:0] l2_result_s1_q [NUM_SLICES/2];    
    logic [4*ATOM_WIDTH+9:0] l2_result_j_s1_tmp [NUM_SLICES/2];    
    logic [4*ATOM_WIDTH+9:0] l2_result_j_s1_q [NUM_SLICES/2];  
    logic [8*ATOM_WIDTH+19:0] l3_result_s1_tmp [NUM_SLICES/4];    
    logic [8*ATOM_WIDTH+19:0] l3_result_s1_q [NUM_SLICES/4];  

    logic [D_WIDTH-1:0] l1_result_s0;
    logic [D_WIDTH-1:0] l1_dot_ext_result_s1;
    logic [D_WIDTH-1:0] l1_result_s1, l1_result_c_s1;
    logic [D_WIDTH-1:0] l2_result_s1, l2_result_c_s1;
    logic [D_WIDTH-1:0] l3_result_s1;

    logic [4*ATOM_WIDTH+9:0] acc_s1_fw[4];
    logic [4*ATOM_WIDTH+9:0] acc_fw_s2[2];
    logic [4*ATOM_WIDTH+9:0] acc_fw_s2_h[2];
    logic [8*ATOM_WIDTH+19:0] acc_1_9_in_a_s2_tmp, acc_1_9_in_b_s2_tmp;
    logic [8*ATOM_WIDTH+35:0] acc_1_9_in_a_s2, acc_1_9_in_b_s2;
    logic [4*ATOM_WIDTH+9:0] acc_3_9_in_a_s2_tmp, acc_3_9_in_b_s2_tmp;
    logic [4*ATOM_WIDTH+17:0] acc_3_9_in_a_s2, acc_3_9_in_b_s2;
    logic [4*ATOM_WIDTH+9:0] acc_6_9_in_a_s2_tmp, acc_6_9_in_b_s2_tmp;
    logic [4*ATOM_WIDTH+17:0] acc_6_9_in_a_s2, acc_6_9_in_b_s2; 
    logic [8*ATOM_WIDTH+39:0] acc_9_in_a_s2, acc_9_in_b_s2, acc_9_out_s2;
    logic [4*ATOM_WIDTH+9:0] acc_8_10_in_a_s2_tmp, acc_8_10_in_b_s2_tmp;
    logic [4*ATOM_WIDTH+33:0] acc_8_10_in_a_s2, acc_8_10_in_b_s2;
    logic [4*ATOM_WIDTH+35:0] acc_10_in_a_s2, acc_10_in_b_s2, acc_10_out_s2;
    logic [4*ATOM_WIDTH+9:0] acc_7_11_in_a_s2_tmp, acc_7_11_in_b_s2_tmp;
    logic [4*ATOM_WIDTH+33:0] acc_7_11_in_a_s2, acc_7_11_in_b_s2;
    logic [4*ATOM_WIDTH+35:0] acc_11_in_a_s2, acc_11_in_b_s2, acc_11_out_s2;

    logic [2*ATOM_WIDTH+16:0] l1_result_s2_tmp [2];    
    logic [2*ATOM_WIDTH+16:0] l1_result_s2_q [2];    
    logic [2*ATOM_WIDTH+16:0] l1_result_j_s2_tmp [2];    
    logic [2*ATOM_WIDTH+16:0] l1_result_j_s2_q [2];    
    logic [4*ATOM_WIDTH+33:0] l2_result_s2_tmp [2];    
    logic [4*ATOM_WIDTH+33:0] l2_result_s2_q [2];    
    logic [4*ATOM_WIDTH+33:0] l2_result_j_s2_tmp [2];    
    logic [4*ATOM_WIDTH+33:0] l2_result_j_s2_q [2];  
    logic [8*ATOM_WIDTH+35:0] l3_result_s2_tmp;    
    logic [8*ATOM_WIDTH+35:0] l3_result_s2_q;  

    logic [D_WIDTH-1:0] l1_result_s2, l1_result_c_s2;
    logic [D_WIDTH-1:0] l2_result_s2, l2_result_c_s2;
    logic [D_WIDTH-1:0] l3_result_s2;




    logic op_predicate_s1, op_predicate_s2;

    genvar i, j, k, l, m, n;

    logic recv_en[PIPELINE_STAGES-1];
    logic recv_rdy[PIPELINE_STAGES-1];
    logic send_en[PIPELINE_STAGES-1];
    logic send_rdy[PIPELINE_STAGES-1];
    logic busy[PIPELINE_STAGES-1];

    logic busy_ini[PIPELINE_STAGES-1];
    logic operator_s1_ini, vector_mode_s1_ini;
    logic operator_s2_ini, vector_mode_s2_ini;

    always_ff @( posedge clk ) begin : pipeline_sync
      if ( reset | fu_local_reset_stage ) begin
        for (int i = 0; i < PIPELINE_STAGES - 1; i++) begin
          busy[i] <= 0;
        end
      end
      else if ( fu_sync_dry_run & ~fu_dry_run_done ) begin
        for (int i = 0; i < PIPELINE_STAGES - 1; i++) begin
          busy[i] <= busy_ini[i];
        end
      end 
      else begin
        for (int i = 0; i < PIPELINE_STAGES - 1; i++) begin
          busy[i] <= recv_rdy[i] ? recv_en[i] : busy[i];
        end
      end
    end

    always_ff @( posedge clk ) begin
      if ( reset | fu_local_reset_ctrl ) begin
        for (int i = 0; i < PIPELINE_STAGES - 1; i++) begin
          busy_ini[i] <= 0;
        end
        operator_s1_ini <= 0;
        vector_mode_s1_ini <= 0;
        operator_s2_ini <= 0;
        vector_mode_s2_ini <= 0;
      end
      else if ( fu_dry_run_done ) begin
        for (int i = 0; i < PIPELINE_STAGES - 1; i++) begin
          busy_ini[i] <= busy[i];
        end
        operator_s1_ini <= operator_s1;
        vector_mode_s1_ini <= vector_mode_s1;
        operator_s2_ini <= operator_s2;
        vector_mode_s2_ini <= vector_mode_s2;
      end
    end

    generate
      for (i=0; i < PIPELINE_STAGES-1; i++) begin: pipeline_async
        assign recv_rdy[i] = ~(send_en[i] & ~send_rdy[i]);
        assign send_en[i] = busy[i];
      end
    endgenerate

    assign is_ff_cc_s0 = (operator_i == MUL_MAC && vector_mode_i == VEC_MODE8);
    assign is_ff_cc_s1 = (operator_s1 == MUL_DOT && vector_mode_s1 == VEC_MODE8) || operator_s1 == MUL_MAC || operator_s1 == MUL_CMAC;
    assign is_ff_rdy_s0 = is_ff_cc_s0 & ~( busy[0] | busy[1] );
    assign is_ff_rdy_s1 = is_ff_cc_s1 & ~busy[1];


    assign recv_en[0] = is_ff_cc_s0 ? 1'b0 : ex_en_i;
    assign recv_en[1] = is_ff_cc_s1 ? 1'b0 : send_en[0];
    assign send_rdy[1] = ((is_ff_cc_s0 & is_ff_rdy_s0) | (is_ff_cc_s1 & is_ff_rdy_s1)) ? 1'b0 : out_rdy_i;
    assign send_rdy[0] = (is_ff_cc_s0 & is_ff_rdy_s0) ? 1'b0 : ( is_ff_cc_s1 ? out_rdy_i & is_ff_rdy_s1 : recv_rdy[1] );
    assign ex_rdy_o = is_ff_cc_s0 ? out_rdy_i & is_ff_rdy_s0 : recv_rdy[0];
    assign out_en_o = (is_ff_cc_s0 & is_ff_rdy_s0) ? ex_en_i : ( (is_ff_cc_s1 & is_ff_rdy_s1) ? send_en[0] : send_en[1] );

    assign mul_is_ff_cc_rdy_o = is_ff_rdy_s0;

    always_comb begin : signed_bits_mask
      unique case (vector_mode_i)
        VEC_MODE32: op_signed_mask = is_cplx ? 4'b1010 : 4'b1000;
        VEC_MODE16: op_signed_mask = is_cplx ? 4'b1111 : 4'b1010;
        VEC_MODE8: op_signed_mask = 4'b1111;
        default: op_signed_mask = '0;
      endcase
    end

    always_comb begin
      unique case (operator_i)
        MUL_MAC, MUL_DOT: is_cplx = 1'b0;
        MUL_CMAC, MUL_CDOT: is_cplx = 1'b1; 
        default: is_cplx = 1'b0;
      endcase
    end

    assign l2_p_en_s0 = (vector_mode_i == VEC_MODE32) || (vector_mode_i == VEC_MODE16);
    assign l3_p_en_s0 = (vector_mode_i == VEC_MODE32);

    always_comb begin : partial_mul_operand
      for (int i = 0; i < NUM_SLICES; i++) begin
        char_op_a[i] = {op_signed_mask[i%4] & op_signed_i[0] & op_a_i[(i+1)*ATOM_WIDTH-1], op_a_i[i*ATOM_WIDTH+:ATOM_WIDTH]};
        char_op_b[i] = {op_signed_mask[i%4] & op_signed_i[1] & op_b_i[(i+1)*ATOM_WIDTH-1], op_b_i[i*ATOM_WIDTH+:ATOM_WIDTH]};
      end
    end

    always_comb begin : partial_mul_operand_rev
      for (int i = 0; i < NUM_SLICES/2; i++) begin
        char_op_a_rev[i*2] = l2_p_en_s0 ? char_op_a[i*2+1] : '0;
        char_op_a_rev[i*2+1] = l2_p_en_s0 ? char_op_a[i*2] : '0;
      end
    end

    always_comb begin : partial_mul_operand_rev_h
      for (int i = 0; i < NUM_SLICES/4; i++) begin
        char_op_a_h[i*4] = l3_p_en_s0 ? char_op_a[i*4+2] : '0;
        char_op_a_h[i*4+1] = l3_p_en_s0 ? char_op_a[i*4+3] : '0;
        char_op_a_h[i*4+2] = l3_p_en_s0 ? char_op_a[i*4] : '0;
        char_op_a_h[i*4+3] = l3_p_en_s0 ? char_op_a[i*4+1] : '0;
        char_op_a_rev_h[i*4] = l3_p_en_s0 ? char_op_a[i*4+3] : '0;
        char_op_a_rev_h[i*4+1] = l3_p_en_s0 ? char_op_a[i*4+2] : '0;
        char_op_a_rev_h[i*4+2] = l3_p_en_s0 ? char_op_a[i*4+1] : '0;
        char_op_a_rev_h[i*4+3] = l3_p_en_s0 ? char_op_a[i*4] : '0;
        char_op_b_h[i*4] = l3_p_en_s0 ? char_op_b[i*4] : '0;
        char_op_b_h[i*4+1] = l3_p_en_s0 ? char_op_b[i*4+1] : '0;
        char_op_b_h[i*4+2] = l3_p_en_s0 ? char_op_b[i*4+2] : '0;
        char_op_b_h[i*4+3] = l3_p_en_s0 ? char_op_b[i*4+3] : '0;
      end
    end

    generate
      for (i=0; i < NUM_SLICES; i++) begin: gen_l1_mult
        assign out_tmp[i] = $signed(char_op_a[i]) * $signed(char_op_b[i]);
        assign out_tmp_rev[i] = $signed(char_op_a_rev[i]) * $signed(char_op_b[i]);
        assign out_tmp_h[i] = $signed(char_op_a_h[i]) * $signed(char_op_b_h[i]);
        assign out_tmp_rev_h[i] = $signed(char_op_a_rev_h[i]) * $signed(char_op_b_h[i]);
      end
    endgenerate

    assign dot_ext_en_i = ((operator_i == MUL_DOT) || (operator_i == MUL_CDOT)) && operator_ext_en_i;

    generate
      for (l=0; l < NUM_SLICES/2; l++) begin: gen_l2_op
        assign mac_l2_p_s0[l] = l2_p_en_s0 ? $signed(out_tmp_rev[2*l+1]) + $signed(out_tmp_rev[2*l]) : '0;
        assign mac_l2_p_s0[l+NUM_SLICES/2] = l2_p_en_s0 ? $signed(out_tmp_rev_h[2*l+1]) + $signed(out_tmp_rev_h[2*l]) : '0; 
        assign mac_l2_cr_s0[l] = l2_p_en_s0 ? $signed(out_tmp[2*l+1]) - $signed(out_tmp[2*l]) : '0;
        assign mac_l2_cr_s0[l+NUM_SLICES/2] = l2_p_en_s0 ? $signed(out_tmp[2*l+1]) + $signed(out_tmp[2*l]) : '0;
        assign mac_l2_ci_s0[l] = l2_p_en_s0 ? mac_l2_p_s0[l] : '0;
        assign mac_l2_ci_s0[l+NUM_SLICES/2] = l2_p_en_s0 ? $signed(out_tmp_rev[2*l+1]) - $signed(out_tmp_rev[2*l]) : '0;
        assign mac_l2_out_s0[l] = l2_p_en_s0 ? {out_tmp[2*l+1], out_tmp[2*l][0+:ATOM_WIDTH*2]} + {{ATOM_WIDTH{mac_l2_p_s0[l][2*ATOM_WIDTH+1]}}, mac_l2_p_s0[l], {ATOM_WIDTH{1'b0}}} : '0;
        assign mac_l2_out_h_s0[l] = l3_p_en_s0 ? {out_tmp_h[2*l+1], out_tmp_h[2*l][0+:ATOM_WIDTH*2]} + {{ATOM_WIDTH{mac_l2_p_s0[l+NUM_SLICES/2][2*ATOM_WIDTH+1]}}, mac_l2_p_s0[l+NUM_SLICES/2], {ATOM_WIDTH{1'b0}}} : '0;
      end
    endgenerate

    generate
      for (i = 0; i < NUM_SLICES; i++) begin
        assign mac_in_a_s0[i] = (operator_i == MUL_MAC && vector_mode_i == VEC_MODE8) ? $signed(out_tmp[i]) : '0;
        assign mac_in_b_tmp_s0[i] = (operator_i == MUL_MAC && vector_mode_i == VEC_MODE8) ? $signed({{(ATOM_WIDTH*2){op_signed_i[2] & op_c_i[(i+1)*ATOM_WIDTH-1]}}, op_c_i[i*ATOM_WIDTH+:ATOM_WIDTH], round_en_i} <<< o_imm_i[0+:$clog2(ATOM_WIDTH*2)]) : '0;
        assign mac_in_b_s0[i] = $signed(mac_in_b_tmp_s0[i][2*ATOM_WIDTH+1:1]);
      end
    endgenerate

    generate
      for (i = 0; i < NUM_SLICES; i++) begin
        assign l1_result_s0_tmp[i] = $signed($signed(mac_in_a_s0[i]) + $signed(mac_in_b_s0[i])) >>> o_imm_i[0+:$clog2(ATOM_WIDTH*2)];
        assign l1_result_s0[i*ATOM_WIDTH+:ATOM_WIDTH] = l1_result_s0_tmp[i][0+:ATOM_WIDTH];
      end
    endgenerate
      
    generate
      for (i = 0; i < NUM_SLICES/2; i++) begin
        assign dot_l1_out_s0[i] = (operator_i == MUL_DOT && vector_mode_i == VEC_MODE8) ? $signed(out_tmp[i*2]) + $signed(out_tmp[i*2+1]) : '0;
      end
    endgenerate


    always_comb begin 
      unique case ({vector_mode_s1, is_cplx_s1})
        {VEC_MODE32, 1'b0}: begin
          op_signed_mask_s1 = 4'b1000;
          l3_p_en_s1 = 1'b1;
        end
        {VEC_MODE16, 1'b0}, {VEC_MODE32, 1'b1}: begin
          op_signed_mask_s1 = 4'b1010;
          l2_p_en_s1 = 1'b1;
        end 
        {VEC_MODE8, 1'b0}, {VEC_MODE16, 1'b1}: begin
          op_signed_mask_s1 = 4'b1111;
          l1_p_en_s1 = 1'b1;
        end 
        default: begin
          op_signed_mask_s1 = '0;
          l1_p_en_s1 = 1'b0;
          l2_p_en_s1 = 1'b0;
          l3_p_en_s1 = 1'b0;
        end
      endcase
    end

    always_comb begin
      unique case (operator_s1)
        MUL_MAC, MUL_DOT: is_cplx_s1 = 1'b0;
        MUL_CMAC, MUL_CDOT: is_cplx_s1 = 1'b1; 
        default: is_cplx_s1 = 1'b0;
      endcase
    end


    generate
      for (i=0; i < NUM_SLICES; i++) begin: gen_l1_acc_s1
        assign mac_l1_acc_s1_tmp[i] = l1_p_en_s1 ? $signed({{(ATOM_WIDTH*2){op_signed_c_s1 & accumulator_s1[(i+1)*ATOM_WIDTH-1]}}, accumulator_s1[i*ATOM_WIDTH+:ATOM_WIDTH], round_en_s1} <<< o_shift_imm_s1[0+:$clog2(ATOM_WIDTH*2)]) : '0;
        assign mac_l1_acc_s1[i] = $signed(mac_l1_acc_s1_tmp[i][2*ATOM_WIDTH+4:1]);
      end
      
      for (i=0; i < NUM_SLICES/2; i++) begin: gen_l2_acc_s1
        assign mac_l2_acc_s1_tmp[i] = l2_p_en_s1 ? $signed({{(ATOM_WIDTH*4){op_signed_c_s1 & accumulator_s1[(i+1)*ATOM_WIDTH*2-1]}}, accumulator_s1[i*ATOM_WIDTH*2+:ATOM_WIDTH*2], round_en_s1} <<< o_shift_imm_s1[0+:$clog2(ATOM_WIDTH*4)]) : '0;
        assign mac_l2_acc_s1[i] = $signed(mac_l2_acc_s1_tmp[i][4*ATOM_WIDTH+9:1]);
      end

      for (i=0; i < NUM_SLICES/4; i++) begin: gen_l3_acc_s1
        assign mac_l3_acc_s1_tmp[i] = l3_p_en_s1 ? $signed({{(ATOM_WIDTH*8){op_signed_c_s1 & accumulator_s1[(i+1)*ATOM_WIDTH*4-1]}}, accumulator_s1[i*ATOM_WIDTH*4+:ATOM_WIDTH*4], round_en_s1} <<< o_shift_imm_s1[0+:$clog2(ATOM_WIDTH*8)]) : '0;
        assign mac_l3_acc_s1[i] = $signed(mac_l3_acc_s1_tmp[i][8*ATOM_WIDTH+19:1]);
      end
    endgenerate

    assign dot_l3_acc_s1 = $signed({op_signed_c_s1 & accumulator_s1[D_WIDTH-1], accumulator_s1});
    assign dot_l3_acc_cr_s1 = $signed({op_signed_c_s1 & accumulator_s1[D_WIDTH-1], accumulator_s1[D_WIDTH/2+:D_WIDTH/2]});
    assign dot_l3_acc_ci_s1 = $signed({op_signed_c_s1 & accumulator_s1[D_WIDTH/2-1], accumulator_s1[0+:D_WIDTH/2]});
    

    generate
      for (i = 0; i < NUM_SLICES/2; i++) begin
        assign dot_l1_out_ext_s1[i] = $signed(dot_l1_out_s1[i]);
        assign mac_l2_out_ext_s1[i] = $signed(mac_l2_out_s1[i]);
      end
      for (i = 0; i < NUM_SLICES; i++) begin
        assign mac_l2_ci_ext_s1[i] = $signed(mac_l2_ci_s1[i]);
        assign mac_l2_cr_ext_s1[i] = $signed(mac_l2_cr_s1[i]);
      end
    endgenerate

    generate
        for (l=0; l < NUM_SLICES/4; l++) begin: gen_l3_op
          assign mac_l3_p_s1[l] = $signed(mac_l2_out_h_s1[2*l+1]) + $signed(mac_l2_out_h_s1[2*l]);
          assign mac_l3_cr_s1[l] = $signed(mac_l2_out_s1[2*l+1]) - $signed(mac_l2_out_s1[2*l]);
          assign mac_l3_cr_s1[l+NUM_SLICES/4] = $signed(mac_l2_out_s1[2*l+1]) + $signed(mac_l2_out_s1[2*l]);
          assign mac_l3_ci_s1[l] = mac_l3_p_s1[l];
          assign mac_l3_ci_s1[l+NUM_SLICES/4] = $signed(mac_l2_out_h_s1[2*l+1]) - $signed(mac_l2_out_h_s1[2*l]);
          assign mac_l3_out_s1[l] = {mac_l2_out_s1[2*l+1], mac_l2_out_s1[2*l][0+:ATOM_WIDTH*4]} + {{(ATOM_WIDTH*2){mac_l3_p_s1[l][4*ATOM_WIDTH]}}, mac_l3_p_s1[l], {(2*ATOM_WIDTH){1'b0}}};

          assign mac_l3_out_ext_s1[l] = $signed(mac_l3_out_s1[l]);
        end
        for (l=0; l < NUM_SLICES/2; l++) begin: gen_l3_c_op
          assign mac_l3_ci_ext_s1[l] = $signed(mac_l3_ci_s1[l]);
          assign mac_l3_cr_ext_s1[l] = $signed(mac_l3_cr_s1[l]);
        end
    endgenerate

    always_comb begin : gen_acc_0_op
      acc_0_out_s1 = '0;
      
      unique case ({vector_mode_s1, is_cplx_s1})
        {VEC_MODE8, 1'b0}, {VEC_MODE16, 1'b1}: begin
          for (int i=0; i<NUM_SLICES; i++) begin
            acc_0_out_s1[i*(2*ATOM_WIDTH+6)+:(2*ATOM_WIDTH+5)] = mac_l1_acc_s1[i]; 
          end
        end
        {VEC_MODE16, 1'b0}, {VEC_MODE32, 1'b1}: begin
          for (int i=0; i<NUM_SLICES; i++) begin
            acc_0_out_s1[i*(2*ATOM_WIDTH+6)+:(2*ATOM_WIDTH+5)] = mac_l2_acc_s1[i/2][i%2*(2*ATOM_WIDTH+5)+:(2*ATOM_WIDTH+5)]; 
          end
        end
        {VEC_MODE32, 1'b0}: begin
          for (int i=0; i<NUM_SLICES; i++) begin
            acc_0_out_s1[i*(2*ATOM_WIDTH+6)+:(2*ATOM_WIDTH+5)] = mac_l3_acc_s1[i/4][i%4*(2*ATOM_WIDTH+5)+:(2*ATOM_WIDTH+5)]; 
          end
        end
        default: ;
      endcase
    end

    always_comb begin: gen_dot_acc_op
      for(int i=0; i<NUM_SLICES/4; i++) begin
        dot_l3_acc_out_s1[i] = 0;
      end
      
      if (dot_ext_en_s1) begin
        for (int i=0; i<NUM_SLICES/2; i++) begin
          dot_l3_acc_out_s1[0][i*(2*ATOM_WIDTH+5)+:(2*ATOM_WIDTH+5)] = (operator_s1 == MUL_DOT) ? dot_l3_acc_s1[i%4*(2*ATOM_WIDTH+5)+:(2*ATOM_WIDTH+5)] : dot_l3_acc_ci_s1[i%4*(2*ATOM_WIDTH+5)+:(2*ATOM_WIDTH+5)]; 
        end
        for (int i=0; i<NUM_SLICES/2; i++) begin
          dot_l3_acc_out_s1[1][i*(2*ATOM_WIDTH+5)+:(2*ATOM_WIDTH+5)] = (operator_s1 == MUL_DOT) ? '0 : dot_l3_acc_cr_s1[i%4*(2*ATOM_WIDTH+5)+:(2*ATOM_WIDTH+5)]; 
        end
      end
      else begin
        unique case ({vector_mode_s1, is_cplx_s1})
          {VEC_MODE8, 1'b0}: begin
            dot_l3_acc_out_s1[0] = $signed(mac_l1_acc_s1[0]);
          end
          {VEC_MODE16, 1'b0}: begin
            dot_l3_acc_out_s1[0] = $signed(mac_l2_acc_s1[0]);
          end
          {VEC_MODE16, 1'b1}: begin
            dot_l3_acc_out_s1[0] = $signed(mac_l1_acc_s1[0]);
            dot_l3_acc_out_s1[1] = $signed(mac_l1_acc_s1[NUM_SLICES/2]);
          end
          {VEC_MODE32, 1'b0}: begin
            dot_l3_acc_out_s1[0] = $signed(mac_l3_acc_s1[0]);
          end
          {VEC_MODE32, 1'b1}: begin
            dot_l3_acc_out_s1[0] = $signed(mac_l2_acc_s1[0]);
            dot_l3_acc_out_s1[1] = $signed(mac_l2_acc_s1[NUM_SLICES/4]);
          end
          default: ;
        endcase
      end
    end



    always_comb begin : gen_acc_1_op
      acc_1_in_a_s1 = '0;
      acc_1_in_b_s1 = '0;

      for (int i=0; i<NUM_SLICES/2; i++) begin
        acc_1_in_a_s1[(i+1)*(2*ATOM_WIDTH+6)-1] = ~op_signed_mask_s1[i%4];
      end

      unique case ({vector_mode_s1, operator_s1})
        {VEC_MODE16, MUL_MAC}: begin
          for (int i=0; i<NUM_SLICES/2; i++) begin
            acc_1_in_a_s1[i*(2*ATOM_WIDTH+6)+:(2*ATOM_WIDTH+5)] = mac_l2_out_ext_s1[i/2][i%2*(2*ATOM_WIDTH+5)+:(2*ATOM_WIDTH+5)];
          end
        end 
        {VEC_MODE32, MUL_MAC}: begin
          for (int i=0; i<NUM_SLICES/2; i++) begin
            acc_1_in_a_s1[i*(2*ATOM_WIDTH+6)+:(2*ATOM_WIDTH+5)] = mac_l3_out_ext_s1[i/4][i%4*(2*ATOM_WIDTH+5)+:(2*ATOM_WIDTH+5)];
          end
        end 
        {VEC_MODE16, MUL_CMAC}: begin
          for (int i=0; i<NUM_SLICES/2; i++) begin
            acc_1_in_a_s1[i*(2*ATOM_WIDTH+6)+:(2*ATOM_WIDTH+5)] = mac_l2_cr_ext_s1[i];
          end
        end 
        {VEC_MODE32, MUL_CMAC}: begin
          for (int i=0; i<NUM_SLICES/2; i++) begin
            acc_1_in_a_s1[i*(2*ATOM_WIDTH+6)+:(2*ATOM_WIDTH+5)] = mac_l3_cr_ext_s1[i/2][i%2*(2*ATOM_WIDTH+5)+:(2*ATOM_WIDTH+5)];
          end
        end 
        {VEC_MODE16, MUL_DOT}: begin
          for (int i=0; i<NUM_SLICES/2; i++) begin
            acc_1_in_a_s1[i*(2*ATOM_WIDTH+6)+:(2*ATOM_WIDTH+5)] = mac_l2_out_ext_s1[i/2*2][i%2*(2*ATOM_WIDTH+5)+:(2*ATOM_WIDTH+5)];
          end
        end
        {VEC_MODE32, MUL_DOT}: begin
          for (int i=0; i<NUM_SLICES/2; i++) begin
            acc_1_in_a_s1[i*(2*ATOM_WIDTH+6)+:(2*ATOM_WIDTH+5)] = mac_l3_out_ext_s1[i/4*2][i%4*(2*ATOM_WIDTH+5)+:(2*ATOM_WIDTH+5)];
          end
        end
        {VEC_MODE16, MUL_CDOT}: begin
          for (int i=0; i<NUM_SLICES/2; i++) begin
            acc_1_in_a_s1[i*(2*ATOM_WIDTH+6)+:(2*ATOM_WIDTH+5)] = mac_l2_cr_ext_s1[i*2];
          end
        end 
        {VEC_MODE32, MUL_CDOT}: begin
          for (int i=0; i<NUM_SLICES/2; i++) begin
            acc_1_in_a_s1[i*(2*ATOM_WIDTH+6)+:(2*ATOM_WIDTH+5)] = mac_l3_cr_ext_s1[i/2*2][i%2*(2*ATOM_WIDTH+5)+:(2*ATOM_WIDTH+5)];
          end
        end 
        default: ;
      endcase

      unique case (operator_s1)
        MUL_MAC: begin
          for (int i=0; i<NUM_SLICES/2; i++) begin
            acc_1_in_b_s1[i*(2*ATOM_WIDTH+6)+:(2*ATOM_WIDTH+5)] = acc_0_out_s1[i*(2*ATOM_WIDTH+6)+:(2*ATOM_WIDTH+5)];
          end
        end
        MUL_DOT: begin
          unique case (vector_mode_s1)
            VEC_MODE16: begin
              for (int i=0; i<NUM_SLICES/2; i++) begin
                acc_1_in_b_s1[i*(2*ATOM_WIDTH+6)+:(2*ATOM_WIDTH+5)] = mac_l2_out_ext_s1[i/2*2+1][i%2*(2*ATOM_WIDTH+5)+:(2*ATOM_WIDTH+5)];
              end
            end 
            VEC_MODE32: begin
              for (int i=0; i<NUM_SLICES/2; i++) begin
                acc_1_in_b_s1[i*(2*ATOM_WIDTH+6)+:(2*ATOM_WIDTH+5)] = mac_l3_out_ext_s1[i/4*2+1][i%4*(2*ATOM_WIDTH+5)+:(2*ATOM_WIDTH+5)];
              end
            end 
            default: ;
          endcase
        end
        MUL_CMAC: begin
          unique case (vector_mode_s1)
            VEC_MODE16: begin
              for (int i=0; i<NUM_SLICES/2; i++) begin
                acc_1_in_b_s1[i*(2*ATOM_WIDTH+6)+:(2*ATOM_WIDTH+5)] = acc_0_out_s1[(i*2+1)*(2*ATOM_WIDTH+6)+:(2*ATOM_WIDTH+5)];
              end
            end 
            VEC_MODE32: begin
              for (int i=0; i<NUM_SLICES/2; i++) begin
                acc_1_in_b_s1[i*(2*ATOM_WIDTH+6)+:(2*ATOM_WIDTH+5)] = acc_0_out_s1[((i/2+1)*2+i)*(2*ATOM_WIDTH+6)+:(2*ATOM_WIDTH+5)];
              end
            end 
            default: ;
          endcase
        end
        MUL_CDOT: begin
          unique case (vector_mode_s1)
            VEC_MODE16: begin
              for (int i=0; i<NUM_SLICES/2; i++) begin
                acc_1_in_b_s1[i*(2*ATOM_WIDTH+6)+:(2*ATOM_WIDTH+5)] = mac_l2_cr_ext_s1[i*2+1];
              end
            end 
            VEC_MODE32: begin
              for (int i=0; i<NUM_SLICES/2; i++) begin
                acc_1_in_b_s1[i*(2*ATOM_WIDTH+6)+:(2*ATOM_WIDTH+5)] = mac_l3_cr_ext_s1[i/2*2+1][i%2*(2*ATOM_WIDTH+5)+:(2*ATOM_WIDTH+5)];
              end
            end 
            default: ;
          endcase
        end
        default: ;
      endcase
    end

    
    always_comb begin : gen_acc_2_op
      acc_2_in_a_s1 = '0;
      acc_2_in_b_s1 = '0;

      for (int i=0; i<NUM_SLICES/2; i++) begin
        acc_2_in_a_s1[(i+1)*(2*ATOM_WIDTH+6)-1] = ~op_signed_mask_s1[i%4];
      end

      unique case ({vector_mode_s1, operator_s1})
        {VEC_MODE32, MUL_MAC}: begin
          for (int i=0; i<NUM_SLICES/2; i++) begin
            acc_2_in_a_s1[i*(2*ATOM_WIDTH+6)+:(2*ATOM_WIDTH+5)] = mac_l3_out_ext_s1[(i+NUM_SLICES/2)/4][i%4*(2*ATOM_WIDTH+5)+:(2*ATOM_WIDTH+5)];
          end
        end 
        {VEC_MODE16, MUL_CMAC}: begin
          for (int i=0; i<NUM_SLICES/2; i++) begin
            acc_2_in_a_s1[i*(2*ATOM_WIDTH+6)+:(2*ATOM_WIDTH+5)] = mac_l2_ci_ext_s1[i];
          end
        end 
        {VEC_MODE32, MUL_CMAC}: begin
          for (int i=0; i<NUM_SLICES/2; i++) begin
            acc_2_in_a_s1[i*(2*ATOM_WIDTH+6)+:(2*ATOM_WIDTH+5)] = mac_l3_ci_ext_s1[i/2][i%2*(2*ATOM_WIDTH+5)+:(2*ATOM_WIDTH+5)];
          end
        end 
        {VEC_MODE32, MUL_DOT}: begin
          for (int i=0; i<NUM_SLICES/2; i++) begin
            acc_2_in_a_s1[i*(2*ATOM_WIDTH+6)+:(2*ATOM_WIDTH+5)] = acc_1_out_s1[i*(2*ATOM_WIDTH+6)+:(2*ATOM_WIDTH+5)];
          end
        end
        {VEC_MODE16, MUL_CDOT}: begin
          for (int i=0; i<NUM_SLICES/2; i++) begin
            acc_2_in_a_s1[i*(2*ATOM_WIDTH+6)+:(2*ATOM_WIDTH+5)] = mac_l2_ci_ext_s1[i*2];
          end
        end 
        {VEC_MODE32, MUL_CDOT}: begin
          for (int i=0; i<NUM_SLICES/2; i++) begin
            acc_2_in_a_s1[i*(2*ATOM_WIDTH+6)+:(2*ATOM_WIDTH+5)] = mac_l3_ci_ext_s1[i/2*2][i%2*(2*ATOM_WIDTH+5)+:(2*ATOM_WIDTH+5)];
          end
        end 
        default: ;
      endcase

      unique case (operator_s1)
        MUL_MAC: begin
          unique case (vector_mode_s1)
            VEC_MODE32: begin
              for (int i=0; i<NUM_SLICES/2; i++) begin
                acc_2_in_b_s1[i*(2*ATOM_WIDTH+6)+:(2*ATOM_WIDTH+5)] = acc_0_out_s1[(i+NUM_SLICES/2)*(2*ATOM_WIDTH+6)+:(2*ATOM_WIDTH+5)];
              end
            end 
            default: ;
          endcase
        end
        MUL_DOT: begin
          unique case (vector_mode_s1)
            VEC_MODE32: begin
              for (int i=0; i<NUM_SLICES/2; i++) begin
                acc_2_in_b_s1[i*(2*ATOM_WIDTH+6)+:(2*ATOM_WIDTH+5)] = acc_0_out_s1[i*(2*ATOM_WIDTH+6)+:(2*ATOM_WIDTH+5)];
              end
            end 
            default: ;
          endcase
        end
        MUL_CMAC: begin
          unique case (vector_mode_s1)
            VEC_MODE16: begin
              for (int i=0; i<NUM_SLICES/2; i++) begin
                acc_2_in_b_s1[i*(2*ATOM_WIDTH+6)+:(2*ATOM_WIDTH+5)] = acc_0_out_s1[(i*2)*(2*ATOM_WIDTH+6)+:(2*ATOM_WIDTH+5)];
              end
            end 
            VEC_MODE32: begin
              for (int i=0; i<NUM_SLICES/2; i++) begin
                acc_2_in_b_s1[i*(2*ATOM_WIDTH+6)+:(2*ATOM_WIDTH+5)] = acc_0_out_s1[(i/2*2+i)*(2*ATOM_WIDTH+6)+:(2*ATOM_WIDTH+5)];
              end
            end 
            default: ;
          endcase
        end
        MUL_CDOT: begin
          unique case (vector_mode_s1)
            VEC_MODE16: begin
              for (int i=0; i<NUM_SLICES/2; i++) begin
                acc_2_in_b_s1[i*(2*ATOM_WIDTH+6)+:(2*ATOM_WIDTH+5)] = mac_l2_ci_ext_s1[i*2+1];
              end
            end 
            VEC_MODE32: begin
              for (int i=0; i<NUM_SLICES/2; i++) begin
                acc_2_in_b_s1[i*(2*ATOM_WIDTH+6)+:(2*ATOM_WIDTH+5)] = mac_l3_ci_ext_s1[i/2*2+1][i%2*(2*ATOM_WIDTH+5)+:(2*ATOM_WIDTH+5)];
              end
            end 
            default: ;
          endcase
        end
        default: ;
      endcase
    end


    always_comb begin : gen_acc_3_op
      acc_3_in_a_s1 = '0;
      acc_3_in_b_s1 = '0;

      for (int i=0; i<NUM_SLICES/4; i++) begin
        acc_3_in_a_s1[(i+1)*(2*ATOM_WIDTH+6)-1] = ~op_signed_mask_s1[(i+NUM_SLICES/2)%4];
      end

      unique case ({vector_mode_s1, operator_s1})
        {VEC_MODE16, MUL_MAC}: begin
          for (int i=0; i<NUM_SLICES/4; i++) begin
            acc_3_in_a_s1[i*(2*ATOM_WIDTH+6)+:(2*ATOM_WIDTH+5)] = mac_l2_out_ext_s1[(i+NUM_SLICES/2)/2][(i+NUM_SLICES/2)%2*(2*ATOM_WIDTH+5)+:(2*ATOM_WIDTH+5)];
          end
        end 
        {VEC_MODE16, MUL_CMAC}: begin
          for (int i=0; i<NUM_SLICES/4; i++) begin
            acc_3_in_a_s1[i*(2*ATOM_WIDTH+6)+:(2*ATOM_WIDTH+5)] = mac_l2_cr_ext_s1[(i+NUM_SLICES/2)];
          end
        end 
        {VEC_MODE32, MUL_CMAC}: begin
          for (int i=0; i<NUM_SLICES/4; i++) begin
            acc_3_in_a_s1[i*(2*ATOM_WIDTH+6)+:(2*ATOM_WIDTH+5)] = mac_l3_cr_ext_s1[(i+NUM_SLICES/2)/2][(i+NUM_SLICES/2)%2*(2*ATOM_WIDTH+5)+:(2*ATOM_WIDTH+5)];
          end
        end 
        {VEC_MODE8, MUL_DOT}: begin
          for (int i=0; i<NUM_SLICES/4; i++) begin
            acc_3_in_a_s1[i*(2*ATOM_WIDTH+6)+:(2*ATOM_WIDTH+5)] = dot_l1_out_ext_s1[i*2];
          end
        end
        {VEC_MODE16, MUL_CDOT}: begin
          for (int i=0; i<NUM_SLICES/4; i++) begin
            acc_3_in_a_s1[i*(2*ATOM_WIDTH+6)+:(2*ATOM_WIDTH+5)] = acc_1_out_s1[i*2*(2*ATOM_WIDTH+6)+:(2*ATOM_WIDTH+5)];
          end
        end
        {VEC_MODE16, MUL_DOT}: begin
          for (int i=0; i<NUM_SLICES/4; i++) begin
            acc_3_in_a_s1[i*(2*ATOM_WIDTH+6)+:(2*ATOM_WIDTH+5)] = acc_1_out_s1[i*(2*ATOM_WIDTH+6)+:(2*ATOM_WIDTH+5)];
          end
        end
        default: ;
      endcase

      unique case (operator_s1)
        MUL_MAC: begin
          unique case (vector_mode_s1)
            VEC_MODE8, VEC_MODE16: begin
              for (int i=0; i<NUM_SLICES/4; i++) begin
                acc_3_in_b_s1[i*(2*ATOM_WIDTH+6)+:(2*ATOM_WIDTH+5)] = acc_0_out_s1[(i+NUM_SLICES/2)*(2*ATOM_WIDTH+6)+:(2*ATOM_WIDTH+5)];
              end
            end 
            default: ;
          endcase
        end
        MUL_DOT: begin
          unique case (vector_mode_s1)
            VEC_MODE8: begin
              for (int i=0; i<NUM_SLICES/4; i++) begin
                acc_3_in_b_s1[i*(2*ATOM_WIDTH+6)+:(2*ATOM_WIDTH+5)] = dot_l1_out_ext_s1[i*2+1];
              end
            end 
            VEC_MODE16: begin
              for (int i=0; i<NUM_SLICES/4; i++) begin
                acc_3_in_b_s1[i*(2*ATOM_WIDTH+6)+:(2*ATOM_WIDTH+5)] = acc_1_out_s1[(i+NUM_SLICES/4)*(2*ATOM_WIDTH+6)+:(2*ATOM_WIDTH+5)];
              end
            end 
            default: ;
          endcase
        end
        MUL_CMAC: begin
          unique case (vector_mode_s1)
            VEC_MODE16: begin
              for (int i=0; i<NUM_SLICES/4; i++) begin
                acc_3_in_b_s1[i*(2*ATOM_WIDTH+6)+:(2*ATOM_WIDTH+5)] = acc_0_out_s1[(i*2+1)*(2*ATOM_WIDTH+6)+:(2*ATOM_WIDTH+5)];
              end
            end 
            VEC_MODE32: begin
              for (int i=0; i<NUM_SLICES/4; i++) begin
                acc_3_in_b_s1[i*(2*ATOM_WIDTH+6)+:(2*ATOM_WIDTH+5)] = acc_0_out_s1[((i/2+1)*2+i)*(2*ATOM_WIDTH+6)+:(2*ATOM_WIDTH+5)];
              end
            end 
            default: ;
          endcase
        end
        MUL_CDOT: begin
          unique case (vector_mode_s1)
            VEC_MODE16: begin
              for (int i=0; i<NUM_SLICES/4; i++) begin
                acc_3_in_b_s1[i*(2*ATOM_WIDTH+6)+:(2*ATOM_WIDTH+5)] = acc_1_out_s1[(i*2+1)*(2*ATOM_WIDTH+6)+:(2*ATOM_WIDTH+5)];
              end
            end 
            default: ;
          endcase
        end
        default: ;
      endcase
    end


    always_comb begin : gen_acc_4_op
      acc_4_in_a_s1 = '0;
      acc_4_in_b_s1 = '0;


      unique case ({vector_mode_s1, operator_s1})
        {VEC_MODE8, MUL_DOT}: begin
          for (int i=0; i<NUM_SLICES/8; i++) begin
            acc_4_in_a_s1[i*(2*ATOM_WIDTH+6)+:(2*ATOM_WIDTH+5)] = acc_3_out_s1[i*2*(2*ATOM_WIDTH+6)+:(2*ATOM_WIDTH+5)];
            acc_4_in_b_s1[i*(2*ATOM_WIDTH+6)+:(2*ATOM_WIDTH+5)] = acc_3_out_s1[(i*2+1)*(2*ATOM_WIDTH+6)+:(2*ATOM_WIDTH+5)];
          end
        end
        default: ;
      endcase
    end

    always_comb begin : gen_acc_5_op
      acc_5_in_a_s1 = '0;
      acc_5_in_b_s1 = '0;


      unique case ({vector_mode_s1, operator_s1})
        {VEC_MODE8, MUL_DOT}: begin
          for (int i=0; i<NUM_SLICES/8; i++) begin
            acc_5_in_a_s1[i*(2*ATOM_WIDTH+18)+:(2*ATOM_WIDTH+17)] = $signed(acc_4_out_s1[i*(2*ATOM_WIDTH+6)+:(2*ATOM_WIDTH+5)]);
            acc_5_in_b_s1[i*(2*ATOM_WIDTH+18)+:(2*ATOM_WIDTH+17)] = dot_l3_acc_out_s1[0];
          end
        end
        default: ;
      endcase
    end



    always_comb begin : gen_acc_6_op
      acc_6_in_a_s1 = '0;
      acc_6_in_b_s1 = '0;

      for (int i=0; i<NUM_SLICES/4; i++) begin
        acc_6_in_a_s1[(i+1)*(2*ATOM_WIDTH+6)-1] = ~op_signed_mask_s1[(i+NUM_SLICES/2)%4];
      end

      unique case ({vector_mode_s1, operator_s1})
        {VEC_MODE16, MUL_CMAC}: begin
          for (int i=0; i<NUM_SLICES/4; i++) begin
            acc_6_in_a_s1[i*(2*ATOM_WIDTH+6)+:(2*ATOM_WIDTH+5)] = mac_l2_ci_ext_s1[(i+NUM_SLICES/2)];
            acc_6_in_b_s1[i*(2*ATOM_WIDTH+6)+:(2*ATOM_WIDTH+5)] = acc_0_out_s1[(i*2)*(2*ATOM_WIDTH+6)+:(2*ATOM_WIDTH+5)];
          end
        end 
        {VEC_MODE32, MUL_CMAC}: begin
          for (int i=0; i<NUM_SLICES/4; i++) begin
            acc_6_in_a_s1[i*(2*ATOM_WIDTH+6)+:(2*ATOM_WIDTH+5)] = mac_l3_ci_ext_s1[(i+NUM_SLICES/2)/2][(i+NUM_SLICES/2)%2*(2*ATOM_WIDTH+5)+:(2*ATOM_WIDTH+5)];
            acc_6_in_b_s1[i*(2*ATOM_WIDTH+6)+:(2*ATOM_WIDTH+5)] = acc_0_out_s1[(i/2*2+i)*(2*ATOM_WIDTH+6)+:(2*ATOM_WIDTH+5)];
          end
        end 
        {VEC_MODE16, MUL_CDOT}: begin
          for (int i=0; i<NUM_SLICES/4; i++) begin
            acc_6_in_a_s1[i*(2*ATOM_WIDTH+6)+:(2*ATOM_WIDTH+5)] = acc_2_out_s1[i*2*(2*ATOM_WIDTH+6)+:(2*ATOM_WIDTH+5)];
            acc_6_in_b_s1[i*(2*ATOM_WIDTH+6)+:(2*ATOM_WIDTH+5)] = acc_2_out_s1[(i*2+1)*(2*ATOM_WIDTH+6)+:(2*ATOM_WIDTH+5)];
          end
        end
        default: ;
      endcase
    end


    always_comb begin : gen_acc_7_op
      acc_7_in_a_s1 = '0;
      acc_7_in_b_s1 = '0;

      for (int i=0; i<NUM_SLICES/4; i++) begin
        acc_7_in_a_s1[(i+1)*(2*ATOM_WIDTH+6)-1] = ~op_signed_mask_s1[(i+NUM_SLICES/4*3)%4];
      end

      unique case ({vector_mode_s1, operator_s1})
        {VEC_MODE16, MUL_CMAC}: begin
          for (int i=0; i<NUM_SLICES/4; i++) begin
            acc_7_in_a_s1[i*(2*ATOM_WIDTH+6)+:(2*ATOM_WIDTH+5)] = mac_l2_ci_ext_s1[(i+NUM_SLICES/4*3)];
            acc_7_in_b_s1[i*(2*ATOM_WIDTH+6)+:(2*ATOM_WIDTH+5)] = acc_0_out_s1[(i+NUM_SLICES/4)*2*(2*ATOM_WIDTH+6)+:(2*ATOM_WIDTH+5)];
          end
        end 
        {VEC_MODE32, MUL_CMAC}: begin
          for (int i=0; i<NUM_SLICES/4; i++) begin
            acc_7_in_a_s1[i*(2*ATOM_WIDTH+6)+:(2*ATOM_WIDTH+5)] = mac_l3_ci_ext_s1[(i+NUM_SLICES/4*3)/2][(i+NUM_SLICES/2)%2*(2*ATOM_WIDTH+5)+:(2*ATOM_WIDTH+5)];
            acc_7_in_b_s1[i*(2*ATOM_WIDTH+6)+:(2*ATOM_WIDTH+5)] = acc_0_out_s1[((i/2+NUM_SLICES/4)*2+i)*(2*ATOM_WIDTH+6)+:(2*ATOM_WIDTH+5)];
          end
        end 
        default: ;
      endcase
    end


    always_comb begin : gen_acc_8_op
      acc_8_in_a_s1 = '0;
      acc_8_in_b_s1 = '0;

      for (int i=0; i<NUM_SLICES/4; i++) begin
        acc_8_in_a_s1[(i+1)*(2*ATOM_WIDTH+6)-1] = ~op_signed_mask_s1[(i+NUM_SLICES/4*3)%4];
      end

      unique case ({vector_mode_s1, operator_s1})
        {VEC_MODE16, MUL_MAC}: begin
          for (int i=0; i<NUM_SLICES/4; i++) begin
            acc_8_in_a_s1[i*(2*ATOM_WIDTH+6)+:(2*ATOM_WIDTH+5)] = mac_l2_out_ext_s1[(i+NUM_SLICES/4*3)/2][i%2*(2*ATOM_WIDTH+5)+:(2*ATOM_WIDTH+5)];
            acc_8_in_b_s1[i*(2*ATOM_WIDTH+6)+:(2*ATOM_WIDTH+5)] = acc_0_out_s1[(i+NUM_SLICES/4*3)*(2*ATOM_WIDTH+6)+:(2*ATOM_WIDTH+5)];
          end
        end 
        {VEC_MODE16, MUL_CMAC}: begin
          for (int i=0; i<NUM_SLICES/4; i++) begin
            acc_8_in_a_s1[i*(2*ATOM_WIDTH+6)+:(2*ATOM_WIDTH+5)] = mac_l2_cr_ext_s1[(i+NUM_SLICES/4*3)];
            acc_8_in_b_s1[i*(2*ATOM_WIDTH+6)+:(2*ATOM_WIDTH+5)] = acc_0_out_s1[(i*2+1+NUM_SLICES/2)*(2*ATOM_WIDTH+6)+:(2*ATOM_WIDTH+5)];
          end
        end 
        {VEC_MODE32, MUL_CMAC}: begin
          for (int i=0; i<NUM_SLICES/4; i++) begin
            acc_8_in_a_s1[i*(2*ATOM_WIDTH+6)+:(2*ATOM_WIDTH+5)] = mac_l3_cr_ext_s1[(i+NUM_SLICES/4*3)/2][(i+NUM_SLICES/2)%2*(2*ATOM_WIDTH+5)+:(2*ATOM_WIDTH+5)];
            acc_8_in_b_s1[i*(2*ATOM_WIDTH+6)+:(2*ATOM_WIDTH+5)] = acc_0_out_s1[((i/2+1+NUM_SLICES/4)*2+i)*(2*ATOM_WIDTH+6)+:(2*ATOM_WIDTH+5)];
          end
        end 
        default: ;
      endcase
    end   





    assign acc_1_out_s1 = $signed(acc_1_in_a_s1) + $signed(acc_1_in_b_s1);
    assign acc_2_out_s1 = $signed(acc_2_in_a_s1) + $signed(acc_2_in_b_s1);
    assign acc_3_out_s1 = $signed(acc_3_in_a_s1) + $signed(acc_3_in_b_s1);
    assign acc_4_out_s1 = $signed(acc_4_in_a_s1) + $signed(acc_4_in_b_s1);
    assign acc_5_out_s1 = $signed(acc_5_in_a_s1) + $signed(acc_5_in_b_s1);
    assign acc_6_out_s1 = $signed(acc_6_in_a_s1) + $signed(acc_6_in_b_s1);
    assign acc_7_out_s1 = $signed(acc_7_in_a_s1) + $signed(acc_7_in_b_s1);
    assign acc_8_out_s1 = $signed(acc_8_in_a_s1) + $signed(acc_8_in_b_s1);

    always_comb begin: gen_l1_out_tmp_s1
      for (int i = 0; i < NUM_SLICES; i++) begin
        l1_result_s1_tmp[i] = '0;
        l1_result_j_s1_tmp[i] = '0;
      end

      unique case ({vector_mode_s1, operator_s1})
        {VEC_MODE8, MUL_DOT}: begin
          for (int i = 0; i < 1; i++) begin
            l1_result_s1_tmp[i] = acc_5_out_s1[i*(2*ATOM_WIDTH+6)+:(2*ATOM_WIDTH+5)];
          end
          for (int i = 0; i < NUM_SLICES-1; i++) begin
            l1_result_s1_tmp[i+1] = '0;
          end
        end
        {VEC_MODE16, MUL_CMAC}: begin
          for (int i = 0; i < NUM_SLICES/2; i++) begin
            l1_result_s1_tmp[i*2] = acc_2_out_s1[i*(2*ATOM_WIDTH+6)+:(2*ATOM_WIDTH+5)];
            l1_result_s1_tmp[i*2+1] = acc_1_out_s1[i*(2*ATOM_WIDTH+6)+:(2*ATOM_WIDTH+5)];
          end
          for (int i = 0; i < NUM_SLICES/4; i++) begin
            l1_result_j_s1_tmp[i*2] = acc_6_out_s1[i*(2*ATOM_WIDTH+6)+:(2*ATOM_WIDTH+5)];
            l1_result_j_s1_tmp[i*2+1] = acc_3_out_s1[i*(2*ATOM_WIDTH+6)+:(2*ATOM_WIDTH+5)];
          end
          for (int i = 0; i < NUM_SLICES/4; i++) begin
            l1_result_j_s1_tmp[i*2+NUM_SLICES/2] = acc_7_out_s1[i*(2*ATOM_WIDTH+6)+:(2*ATOM_WIDTH+5)]; 
            l1_result_j_s1_tmp[i*2+1+NUM_SLICES/2] = acc_8_out_s1[i*(2*ATOM_WIDTH+6)+:(2*ATOM_WIDTH+5)];
          end
        end
        default: ;
      endcase
    end

    always_comb begin: gen_l2_out_tmp_s1
      for (int i = 0; i < NUM_SLICES/2; i++) begin
        l2_result_s1_tmp[i] = '0;
        l2_result_j_s1_tmp[i] = '0;
      end

      unique case ({vector_mode_s1, operator_s1})
        {VEC_MODE16, MUL_MAC}: begin
          for (int i = 0; i < NUM_SLICES/2; i++) begin
            l2_result_s1_tmp[i/2][i%2*(2*ATOM_WIDTH+5)+:(2*ATOM_WIDTH+5)] = acc_1_out_s1[i*(2*ATOM_WIDTH+6)+:(2*ATOM_WIDTH+5)];
          end
          for (int i = 0; i < NUM_SLICES/4; i++) begin
            l2_result_s1_tmp[(i+NUM_SLICES/2)/2][i%2*(2*ATOM_WIDTH+5)+:(2*ATOM_WIDTH+5)] = acc_3_out_s1[i*(2*ATOM_WIDTH+6)+:(2*ATOM_WIDTH+5)];
          end
          for (int i = 0; i < NUM_SLICES/4; i++) begin
            l2_result_s1_tmp[(i+NUM_SLICES/4*3)/2][i%2*(2*ATOM_WIDTH+5)+:(2*ATOM_WIDTH+5)] = acc_8_out_s1[i*(2*ATOM_WIDTH+6)+:(2*ATOM_WIDTH+5)];
          end
        end 
        {VEC_MODE32, MUL_CMAC}: begin
          for (int i = 0; i < NUM_SLICES/2; i++) begin
            l2_result_s1_tmp[i/2*2][i%2*(2*ATOM_WIDTH+5)+:(2*ATOM_WIDTH+5)] = acc_2_out_s1[i*(2*ATOM_WIDTH+6)+:(2*ATOM_WIDTH+5)];
            l2_result_s1_tmp[i/2*2+1][i%2*(2*ATOM_WIDTH+5)+:(2*ATOM_WIDTH+5)] = acc_1_out_s1[i*(2*ATOM_WIDTH+6)+:(2*ATOM_WIDTH+5)];
          end
          for (int i = 0; i < NUM_SLICES/4; i++) begin
            l2_result_j_s1_tmp[i/2*2][i%2*(2*ATOM_WIDTH+5)+:(2*ATOM_WIDTH+5)] = acc_6_out_s1[i*(2*ATOM_WIDTH+6)+:(2*ATOM_WIDTH+5)];
            l2_result_j_s1_tmp[i/2*2+1][i%2*(2*ATOM_WIDTH+5)+:(2*ATOM_WIDTH+5)] = acc_3_out_s1[i*(2*ATOM_WIDTH+6)+:(2*ATOM_WIDTH+5)];
          end
          for (int i = 0; i < NUM_SLICES/4; i++) begin
            l2_result_j_s1_tmp[i/2*2+NUM_SLICES/4][i%2*(2*ATOM_WIDTH+5)+:(2*ATOM_WIDTH+5)] = acc_7_out_s1[i*(2*ATOM_WIDTH+6)+:(2*ATOM_WIDTH+5)]; 
            l2_result_j_s1_tmp[i/2*2+1+NUM_SLICES/4][i%2*(2*ATOM_WIDTH+5)+:(2*ATOM_WIDTH+5)] = acc_8_out_s1[i*(2*ATOM_WIDTH+6)+:(2*ATOM_WIDTH+5)];
          end
        end
        default: ;
      endcase
    end

    always_comb begin: gen_l3_out_tmp_s1
      for (int i = 0; i < NUM_SLICES/4; i++) begin
        l3_result_s1_tmp[i] = '0;
      end

      unique case ({vector_mode_s1, operator_s1})
        {VEC_MODE32, MUL_MAC}: begin
          for (int i = 0; i < NUM_SLICES/2; i++) begin
            l3_result_s1_tmp[i/4][i%4*(2*ATOM_WIDTH+5)+:(2*ATOM_WIDTH+5)] = acc_1_out_s1[i*(2*ATOM_WIDTH+6)+:(2*ATOM_WIDTH+5)];
          end
          for (int i = 0; i < NUM_SLICES/2; i++) begin
            l3_result_s1_tmp[(i+NUM_SLICES/2)/4][i%4*(2*ATOM_WIDTH+5)+:(2*ATOM_WIDTH+5)] = acc_2_out_s1[i*(2*ATOM_WIDTH+6)+:(2*ATOM_WIDTH+5)];
          end
        end 
        default: ;
      endcase
    end


    assign l1_dot_ext_result_s1 = $signed(acc_5_out_s1) >>> o_shift_imm_s1;

    generate
      for (i=0; i < NUM_SLICES; i++) begin: gen_l1_out_s1
        assign l1_result_s1_q[i] = $signed(l1_result_s1_tmp[i]) >>> o_shift_imm_s1[0+:$clog2(ATOM_WIDTH*2)];
        assign l1_result_j_s1_q[i] = $signed(l1_result_j_s1_tmp[i]) >>> o_shift_imm_s1[0+:$clog2(ATOM_WIDTH*2)];
        assign l1_result_s1[i*ATOM_WIDTH+:ATOM_WIDTH] = (dot_ext_en_s1) ? l1_dot_ext_result_s1[i*ATOM_WIDTH+:ATOM_WIDTH] : l1_result_s1_q[i][0+:ATOM_WIDTH];
        assign l1_result_c_s1[i*ATOM_WIDTH+:ATOM_WIDTH] = l1_result_j_s1_q[i][0+:ATOM_WIDTH];
      end

      for (i=0; i < NUM_SLICES/2; i++) begin: gen_l2_out_s1
        assign l2_result_s1_q[i] = $signed(l2_result_s1_tmp[i]) >>> o_shift_imm_s1[0+:$clog2(ATOM_WIDTH*4)];
        assign l2_result_j_s1_q[i] = $signed(l2_result_j_s1_tmp[i]) >>> o_shift_imm_s1[0+:$clog2(ATOM_WIDTH*4)];
        assign l2_result_s1[i*ATOM_WIDTH*2+:ATOM_WIDTH*2] = l2_result_s1_q[i][0+:ATOM_WIDTH*2];
        assign l2_result_c_s1[i*ATOM_WIDTH*2+:ATOM_WIDTH*2] = l2_result_j_s1_q[i][0+:ATOM_WIDTH*2];
      end

      for (i=0; i < NUM_SLICES/4; i++) begin: gen_l3_out_s1
        assign l3_result_s1_q[i] = $signed(l3_result_s1_tmp[i]) >>> o_shift_imm_s1[0+:$clog2(ATOM_WIDTH*8)];
        assign l3_result_s1[i*ATOM_WIDTH*4+:ATOM_WIDTH*4] = l3_result_s1_q[i][0+:ATOM_WIDTH*4];
      end
    endgenerate



    always_comb begin : gen_acc_s1_fw
      for (int i = 0; i < 4; i++) begin
        acc_s1_fw[i] = '0;
      end
      unique case ({vector_mode_s1, operator_s1})
        {VEC_MODE32, MUL_DOT}: begin
          for (int i = 0; i < NUM_SLICES/4; i++) begin
            acc_s1_fw[0][i*(2*ATOM_WIDTH+5)+:(2*ATOM_WIDTH+5)] = acc_1_out_s1[i*(2*ATOM_WIDTH+6)+:(2*ATOM_WIDTH+5)];
            acc_s1_fw[1][i*(2*ATOM_WIDTH+5)+:(2*ATOM_WIDTH+5)] = acc_1_out_s1[(i+NUM_SLICES/4)*(2*ATOM_WIDTH+6)+:(2*ATOM_WIDTH+5)];
          end
        end
        {VEC_MODE16, MUL_DOT}: begin
          for (int i = 0; i < NUM_SLICES/4; i++) begin
            acc_s1_fw[0][i*(2*ATOM_WIDTH+5)+:(2*ATOM_WIDTH+5)] = acc_3_out_s1[i*(2*ATOM_WIDTH+6)+:(2*ATOM_WIDTH+5)];
          end
        end
        {VEC_MODE32, MUL_CDOT}: begin
          for (int i = 0; i < NUM_SLICES/4; i++) begin
            acc_s1_fw[0][i*(2*ATOM_WIDTH+5)+:(2*ATOM_WIDTH+5)] = acc_1_out_s1[i*(2*ATOM_WIDTH+6)+:(2*ATOM_WIDTH+5)];
            acc_s1_fw[1][i*(2*ATOM_WIDTH+5)+:(2*ATOM_WIDTH+5)] = acc_1_out_s1[(i+NUM_SLICES/4)*(2*ATOM_WIDTH+6)+:(2*ATOM_WIDTH+5)];
            acc_s1_fw[2][i*(2*ATOM_WIDTH+5)+:(2*ATOM_WIDTH+5)] = acc_2_out_s1[i*(2*ATOM_WIDTH+6)+:(2*ATOM_WIDTH+5)];
            acc_s1_fw[3][i*(2*ATOM_WIDTH+5)+:(2*ATOM_WIDTH+5)] = acc_2_out_s1[(i+NUM_SLICES/4)*(2*ATOM_WIDTH+6)+:(2*ATOM_WIDTH+5)];
          end
        end
        {VEC_MODE16, MUL_CDOT}: begin
          for (int i = 0; i < NUM_SLICES/4; i++) begin
            acc_s1_fw[0][i*(2*ATOM_WIDTH+5)+:(2*ATOM_WIDTH+5)] = acc_3_out_s1[i*(2*ATOM_WIDTH+6)+:(2*ATOM_WIDTH+5)];
            acc_s1_fw[2][i*(2*ATOM_WIDTH+5)+:(2*ATOM_WIDTH+5)] = acc_6_out_s1[i*(2*ATOM_WIDTH+6)+:(2*ATOM_WIDTH+5)];
          end
        end
        default: ;
      endcase
    end



    always_comb begin : signed_bits_mask_s2
      unique case (vector_mode_s2)
        VEC_MODE32: op_signed_mask_s2 = is_cplx_s2 ? 4'b1010 : 4'b1000;
        VEC_MODE16: op_signed_mask_s2 = is_cplx_s2 ? 4'b1111 : 4'b1010;
        VEC_MODE8: op_signed_mask_s2 = 4'b1111;
        default: op_signed_mask_s2 = '0;
      endcase
    end

    always_comb begin
      unique case (operator_s2)
        MUL_MAC, MUL_DOT: is_cplx_s2 = 1'b0;
        MUL_CMAC, MUL_CDOT: is_cplx_s2 = 1'b1; 
        default: is_cplx_s2 = 1'b0;
      endcase
    end


        

    generate
      for (i = 0; i<NUM_SLICES/4; i++) begin
        assign acc_3_9_in_a_s2_tmp[i*(2*ATOM_WIDTH+5)+:(2*ATOM_WIDTH+5)] = ( operator_s2 == MUL_CDOT && vector_mode_s2 == VEC_MODE32 ) ? acc_fw_s2[0][i*(2*ATOM_WIDTH+5)+:(2*ATOM_WIDTH+5)] : '0;
      end
    endgenerate

    assign acc_3_9_in_a_s2 = $signed(acc_3_9_in_a_s2_tmp);
    assign acc_3_9_in_b_s2 = ( operator_s2 == MUL_CDOT && vector_mode_s2 == VEC_MODE32 ) ? dot_l3_acc_out_s2[1] : '0;

    generate
      for (i = 0; i<NUM_SLICES/4; i++) begin
        assign acc_6_9_in_a_s2_tmp[i*(2*ATOM_WIDTH+5)+:(2*ATOM_WIDTH+5)] = ( operator_s2 == MUL_CDOT && vector_mode_s2 == VEC_MODE32 ) ? acc_fw_s2[1][i*(2*ATOM_WIDTH+5)+:(2*ATOM_WIDTH+5)] : '0;
      end
    endgenerate

    assign acc_6_9_in_a_s2 = $signed(acc_6_9_in_a_s2_tmp);
    assign acc_6_9_in_b_s2 = ( operator_s2 == MUL_CDOT && vector_mode_s2 == VEC_MODE32 ) ? dot_l3_acc_out_s2[0] : '0;

    generate
      for (i = 0; i<NUM_SLICES/4; i++) begin
        assign acc_1_9_in_a_s2_tmp[i*(2*ATOM_WIDTH+5)+:(2*ATOM_WIDTH+5)] = ( operator_s2 == MUL_DOT && vector_mode_s2 == VEC_MODE32 ) ? acc_fw_s2[0][i%2*(2*ATOM_WIDTH+5)+:(2*ATOM_WIDTH+5)] : '0;
        assign acc_1_9_in_a_s2_tmp[(i+NUM_SLICES/4)*(2*ATOM_WIDTH+5)+:(2*ATOM_WIDTH+5)] = ( operator_s2 == MUL_DOT && vector_mode_s2 == VEC_MODE32 ) ? acc_fw_s2_h[0][i%2*(2*ATOM_WIDTH+5)+:(2*ATOM_WIDTH+5)] : '0;
      end
    endgenerate

    assign acc_1_9_in_a_s2 = $signed(acc_1_9_in_a_s2_tmp);
    assign acc_1_9_in_b_s2 = ( operator_s2 == MUL_DOT && vector_mode_s2 == VEC_MODE32 ) ? dot_l3_acc_out_s2[0] : '0;
    
    always_comb begin : gen_acc_9_op
      acc_9_in_a_s2 = '0;
      acc_9_in_b_s2 = '0;

      for (int i=0; i<NUM_SLICES/2; i++) begin
        acc_9_in_a_s2[(i+1)*(2*ATOM_WIDTH+10)-1] = ~op_signed_mask_s2[i%4];
      end

      unique case ({vector_mode_s2, operator_s2})
        {VEC_MODE32, MUL_CDOT}: begin
          for (int i=0; i<NUM_SLICES/4; i++) begin
            acc_9_in_a_s2[i*(2*ATOM_WIDTH+10)+:(2*ATOM_WIDTH+9)] = acc_3_9_in_a_s2[i*(2*ATOM_WIDTH+9)+:(2*ATOM_WIDTH+9)];
            acc_9_in_b_s2[i*(2*ATOM_WIDTH+10)+:(2*ATOM_WIDTH+9)] = acc_3_9_in_b_s2[i*(2*ATOM_WIDTH+9)+:(2*ATOM_WIDTH+9)];
            acc_9_in_a_s2[(i+NUM_SLICES/4)*(2*ATOM_WIDTH+10)+:(2*ATOM_WIDTH+9)] = acc_6_9_in_a_s2[i*(2*ATOM_WIDTH+9)+:(2*ATOM_WIDTH+9)];
            acc_9_in_b_s2[(i+NUM_SLICES/4)*(2*ATOM_WIDTH+10)+:(2*ATOM_WIDTH+9)] = acc_6_9_in_b_s2[i*(2*ATOM_WIDTH+9)+:(2*ATOM_WIDTH+9)];
          end
        end
        {VEC_MODE32, MUL_DOT}: begin
          for (int i=0; i<NUM_SLICES/2; i++) begin
            acc_9_in_a_s2[i*(2*ATOM_WIDTH+10)+:(2*ATOM_WIDTH+9)] = acc_1_9_in_a_s2[i*(2*ATOM_WIDTH+9)+:(2*ATOM_WIDTH+9)];
            acc_9_in_b_s2[i*(2*ATOM_WIDTH+10)+:(2*ATOM_WIDTH+9)] = acc_1_9_in_b_s2[i*(2*ATOM_WIDTH+9)+:(2*ATOM_WIDTH+9)];
          end
        end
        default: ;
      endcase
    end

    always_comb begin : gen_acc_8_10_op
      acc_8_10_in_a_s2_tmp = '0;
      acc_8_10_in_b_s2 = '0;
      unique case ({vector_mode_s2, operator_s2})
        {VEC_MODE16, MUL_DOT}: begin
          for (int i=0; i<NUM_SLICES/4; i++) begin
            acc_8_10_in_a_s2_tmp[i*(2*ATOM_WIDTH+5)+:(2*ATOM_WIDTH+5)] = acc_fw_s2[0][i*(2*ATOM_WIDTH+5)+:(2*ATOM_WIDTH+5)];
            acc_8_10_in_b_s2 = dot_l3_acc_out_s2[0];
          end
        end 
        {VEC_MODE16, MUL_CDOT}: begin
          for (int i=0; i<NUM_SLICES/4; i++) begin
            acc_8_10_in_a_s2_tmp[i*(2*ATOM_WIDTH+5)+:(2*ATOM_WIDTH+5)] = acc_fw_s2[0][i*(2*ATOM_WIDTH+5)+:(2*ATOM_WIDTH+5)];
            acc_8_10_in_b_s2[i*(2*ATOM_WIDTH+17)+:(2*ATOM_WIDTH+17)] = dot_l3_acc_out_s2[1];
          end
        end
        {VEC_MODE32, MUL_CDOT}: begin
          for (int i=0; i<NUM_SLICES/4; i++) begin
            acc_8_10_in_a_s2_tmp[i*(2*ATOM_WIDTH+5)+:(2*ATOM_WIDTH+5)] = acc_fw_s2_h[0][i*(2*ATOM_WIDTH+5)+:(2*ATOM_WIDTH+5)];
            acc_8_10_in_b_s2 = dot_l3_acc_out_s2[1];
          end
        end
        default: ;
      endcase
    end

    always_comb begin : gen_acc_8_10_op_a
      acc_8_10_in_a_s2 = '0;
      unique case ({vector_mode_s2, operator_s2})
        {VEC_MODE16, MUL_DOT}, {VEC_MODE32, MUL_CDOT}: begin
          acc_8_10_in_a_s2 = $signed(acc_8_10_in_a_s2_tmp);
        end 
        {VEC_MODE16, MUL_CDOT}: begin
          for (int i=0; i<NUM_SLICES/4; i++) begin
            acc_8_10_in_a_s2[i*(2*ATOM_WIDTH+17)+:(2*ATOM_WIDTH+17)] = $signed(acc_8_10_in_a_s2_tmp[i*(2*ATOM_WIDTH+5)+:(2*ATOM_WIDTH+5)]);
          end
        end
        default: ;
      endcase
    end


    generate
      for (i=0; i<NUM_SLICES/4; i++) begin : gen_acc_10_op
        assign acc_10_in_a_s2[(i+1)*(2*ATOM_WIDTH+18)-1] = ~op_signed_mask_s2[(i+NUM_SLICES/2)%4];
        assign acc_10_in_b_s2[(i+1)*(2*ATOM_WIDTH+18)-1] = 1'b0;
        assign acc_10_in_a_s2[i*(2*ATOM_WIDTH+18)+:(2*ATOM_WIDTH+17)] = acc_8_10_in_a_s2[i*(2*ATOM_WIDTH+17)+:(2*ATOM_WIDTH+17)];
        assign acc_10_in_b_s2[i*(2*ATOM_WIDTH+18)+:(2*ATOM_WIDTH+17)] = acc_8_10_in_b_s2[i*(2*ATOM_WIDTH+17)+:(2*ATOM_WIDTH+17)];
      end
    endgenerate
    
    always_comb begin : gen_acc_7_11_op
      acc_7_11_in_a_s2_tmp = '0;
      acc_7_11_in_b_s2 = '0;
      unique case ({vector_mode_s2, operator_s2})
        {VEC_MODE16, MUL_CDOT}: begin
          for (int i=0; i<NUM_SLICES/4; i++) begin
            acc_7_11_in_a_s2_tmp[i*(2*ATOM_WIDTH+5)+:(2*ATOM_WIDTH+5)] = acc_fw_s2[1][i*(2*ATOM_WIDTH+5)+:(2*ATOM_WIDTH+5)];
            acc_7_11_in_b_s2[i*(2*ATOM_WIDTH+17)+:(2*ATOM_WIDTH+17)] = dot_l3_acc_out_s2[0];
          end
        end
        {VEC_MODE32, MUL_CDOT}: begin
          for (int i=0; i<NUM_SLICES/4; i++) begin
            acc_7_11_in_a_s2_tmp[i*(2*ATOM_WIDTH+5)+:(2*ATOM_WIDTH+5)] = acc_fw_s2_h[1][i*(2*ATOM_WIDTH+5)+:(2*ATOM_WIDTH+5)];
            acc_7_11_in_b_s2 = dot_l3_acc_out_s2[0];
          end
        end
        default: ;
      endcase
    end

    always_comb begin : gen_acc_7_11_op_a
      acc_7_11_in_a_s2 = '0;
      unique case ({vector_mode_s2, operator_s2})
        {VEC_MODE32, MUL_CDOT}: begin
          acc_7_11_in_a_s2 = $signed(acc_7_11_in_a_s2_tmp);
        end 
        {VEC_MODE16, MUL_CDOT}: begin
          for (int i=0; i<NUM_SLICES/4; i++) begin
            acc_7_11_in_a_s2[i*(2*ATOM_WIDTH+17)+:(2*ATOM_WIDTH+17)] = $signed(acc_7_11_in_a_s2_tmp[i*(2*ATOM_WIDTH+5)+:(2*ATOM_WIDTH+5)]);
          end
        end
        default: ;
      endcase
    end

    generate
      for (i=0; i<NUM_SLICES/4; i++) begin : gen_acc_11_op
        assign acc_11_in_a_s2[(i+1)*(2*ATOM_WIDTH+18)-1] = ~op_signed_mask_s2[(i+NUM_SLICES/2)%4];
        assign acc_11_in_b_s2[(i+1)*(2*ATOM_WIDTH+18)-1] = 1'b0;
        assign acc_11_in_a_s2[i*(2*ATOM_WIDTH+18)+:(2*ATOM_WIDTH+17)] = acc_7_11_in_a_s2[i*(2*ATOM_WIDTH+17)+:(2*ATOM_WIDTH+17)];
        assign acc_11_in_b_s2[i*(2*ATOM_WIDTH+18)+:(2*ATOM_WIDTH+17)] = acc_7_11_in_b_s2[i*(2*ATOM_WIDTH+17)+:(2*ATOM_WIDTH+17)];
      end
    endgenerate
    
    assign acc_9_out_s2 = $signed(acc_9_in_a_s2) + $signed(acc_9_in_b_s2);
    assign acc_10_out_s2 = $signed(acc_10_in_a_s2) + $signed(acc_10_in_b_s2);
    assign acc_11_out_s2 = $signed(acc_11_in_a_s2) + $signed(acc_11_in_b_s2);




    generate
      for (i = 0; i < 2; i++) begin: gen_l1_out_tmp_s2
        assign l1_result_s2_tmp[i] = ((vector_mode_s2 == VEC_MODE16) && (operator_s2 == MUL_CDOT)) ? acc_10_out_s2[i*(2*ATOM_WIDTH+18)+:(2*ATOM_WIDTH+17)] : '0;
        assign l1_result_j_s2_tmp[i] = ((vector_mode_s2 == VEC_MODE16) && (operator_s2 == MUL_CDOT)) ? acc_11_out_s2[i*(2*ATOM_WIDTH+18)+:(2*ATOM_WIDTH+17)] : '0;
      end
    endgenerate

    always_comb begin: gen_l2_out_tmp_s2
      for (int i = 0; i < 2; i++) begin
        l2_result_s2_tmp[i] = '0;
        l2_result_j_s2_tmp[i] = '0;
      end

      unique case ({vector_mode_s2, operator_s2})
        {VEC_MODE16, MUL_DOT}: begin
          for (int i = 0; i < 2; i++) begin
            l2_result_s2_tmp[0][i*(2*ATOM_WIDTH+17)+:(2*ATOM_WIDTH+17)] = acc_10_out_s2[i*(2*ATOM_WIDTH+18)+:(2*ATOM_WIDTH+17)];
          end
        end

        {VEC_MODE32, MUL_CDOT}: begin
          l2_result_s2_tmp[0] = $signed({acc_9_out_s2[(2*ATOM_WIDTH+10)+:(2*ATOM_WIDTH+9)], acc_9_out_s2[0+:(2*ATOM_WIDTH+9)]});
          l2_result_s2_tmp[1] = $signed({acc_10_out_s2[(2*ATOM_WIDTH+18)+:(2*ATOM_WIDTH+17)], acc_10_out_s2[0+:(2*ATOM_WIDTH+17)]});
          l2_result_j_s2_tmp[0] = $signed({acc_9_out_s2[3*(2*ATOM_WIDTH+10)+:(2*ATOM_WIDTH+9)], acc_9_out_s2[2*(2*ATOM_WIDTH+10)+:(2*ATOM_WIDTH+9)]});
          l2_result_j_s2_tmp[1] = $signed({acc_11_out_s2[(2*ATOM_WIDTH+18)+:(2*ATOM_WIDTH+17)], acc_11_out_s2[0+:(2*ATOM_WIDTH+17)]});
        end
        default: ;
      endcase
    end


    generate
      for (i = 0; i < 4; i++) begin: gen_l3_out_tmp_s2
        assign l3_result_s2_tmp[i*(2*ATOM_WIDTH+9)+:(2*ATOM_WIDTH+9)] = ((vector_mode_s2 == VEC_MODE32) && (operator_s2 == MUL_DOT)) ? acc_9_out_s2[i*(2*ATOM_WIDTH+10)+:(2*ATOM_WIDTH+9)] : '0;
      end
    endgenerate

    generate
      for (i = 0; i < 2; i++) begin
        assign l1_result_s2_q[i] = $signed(l1_result_s2_tmp[i]) >>> o_shift_imm_s2[0+:$clog2(ATOM_WIDTH*4)];
        assign l1_result_j_s2_q[i] = $signed(l1_result_j_s2_tmp[i]) >>> o_shift_imm_s2[0+:$clog2(ATOM_WIDTH*4)];
        assign l2_result_s2_q[i] = $signed(l2_result_s2_tmp[i]) >>> o_shift_imm_s2[0+:$clog2(ATOM_WIDTH*8)];
        assign l2_result_j_s2_q[i] = $signed(l2_result_j_s2_tmp[i]) >>> o_shift_imm_s2[0+:$clog2(ATOM_WIDTH*8)];
      end
      assign l3_result_s2_q = $signed(l3_result_s2_tmp) >>> o_shift_imm_s2;
    endgenerate

    assign l1_result_s2 = ((vector_mode_s2 == VEC_MODE16) && (operator_s2 == MUL_CDOT)) ? {l1_result_s2_q[0][0+:D_WIDTH/2], l1_result_j_s2_q[0][0+:D_WIDTH/2]} : '0;
    assign l1_result_c_s2 = ((vector_mode_s2 == VEC_MODE16) && (operator_s2 == MUL_CDOT)) ? {l1_result_s2_q[1][0+:D_WIDTH/2], l1_result_j_s2_q[1][0+:D_WIDTH/2]} : '0;

    always_comb begin : gen_l2_out_s2
      l2_result_s2 = '0;
      l2_result_c_s2 = '0;
      unique case ({vector_mode_s2, operator_s2})
        {VEC_MODE16, MUL_DOT}: begin
          l2_result_s2 = l2_result_s2_q[0][0+:D_WIDTH];
        end

        {VEC_MODE32, MUL_CDOT}: begin
          l2_result_s2 = {l2_result_s2_q[0][0+:D_WIDTH/2], l2_result_j_s2_q[0][0+:D_WIDTH/2]};
          l2_result_c_s2 = {l2_result_s2_q[1][0+:D_WIDTH/2], l2_result_j_s2_q[1][0+:D_WIDTH/2]};
        end
        default: ;
      endcase
    end

    assign l3_result_s2 = ((vector_mode_s2 == VEC_MODE32) && (operator_s2 == MUL_DOT)) ? l3_result_s2_q[0+:D_WIDTH] : '0;


    always_ff @( posedge clk ) begin : s1_ctrl_sync
      if ( reset | fu_local_reset_data ) begin
        vector_mode_s1 <= 0;
        operator_s1 <= 0;
      end
      else if ( fu_sync_dry_run & ~fu_dry_run_done ) begin
        vector_mode_s1 <= vector_mode_s1_ini;
        operator_s1 <= operator_s1_ini;
      end
      else if (recv_rdy[0] & recv_en[0]) begin
        operator_s1 <= operator_i;
        vector_mode_s1 <= vector_mode_i;
      end
    end
    
    always_ff @( posedge clk ) begin : s1_buf_sync
      if ( reset | fu_local_reset_data ) begin
        for (int i = 0; i < NUM_SLICES/2; i++) begin
          dot_l1_out_s1[i] <= 0;
        end
        for (int i = 0; i < NUM_SLICES/2; i++) begin
          mac_l2_out_s1[i] <= 0;
        end
        for (int i = 0; i < NUM_SLICES; i++) begin
          mac_l2_ci_s1[i] <= 0;
          mac_l2_cr_s1[i] <= 0;
        end
        accumulator_s1 <= 0;
        
        op_signed_c_s1 <= 0;
        round_en_s1 <= 0;
        dot_ext_en_s1 <= 0;
        
        o_shift_imm_s1 <= 0;
        op_predicate_s1 <= 1;
      end
      else begin
        if (recv_rdy[0] & recv_en[0]) begin
          for (int i = 0; i < NUM_SLICES/2; i++) begin
            dot_l1_out_s1[i] <= dot_l1_out_s0[i];
          end
          for (int i = 0; i < NUM_SLICES/2; i++) begin
            mac_l2_out_s1[i] <= mac_l2_out_s0[i];
          end
          for (int i = 0; i < NUM_SLICES; i++) begin
            mac_l2_ci_s1[i] <= mac_l2_ci_s0[i];
            mac_l2_cr_s1[i] <= mac_l2_cr_s0[i];
          end
          accumulator_s1 <= op_c_i;
          op_signed_c_s1 <= op_signed_i[2];
          round_en_s1 <= round_en_i;
          dot_ext_en_s1 <= dot_ext_en_i;
          o_shift_imm_s1 <= o_imm_i;
          op_predicate_s1 <= op_predicate_i;
        end
      end
    end

    always_ff @( posedge clk ) begin : s1_buf_sync_h
      if ( reset | fu_local_reset_data ) begin
        for (int i = 0; i < NUM_SLICES/2; i++) begin
          mac_l2_out_h_s1[i] <= 0;
        end
      end
      else begin
        if (recv_rdy[0] & recv_en[0] & l3_p_en_s0 ) begin
          for (int i = 0; i < NUM_SLICES/2; i++) begin
            mac_l2_out_h_s1[i] <= mac_l2_out_h_s0[i];
          end
        end
      end
    end

    always_ff @( posedge clk ) begin : s2_ctrl_sync
      if ( reset | fu_local_reset_data ) begin
        vector_mode_s2 <= 0;
        operator_s2 <= 0;
      end
      else if ( fu_sync_dry_run & ~fu_dry_run_done ) begin
        vector_mode_s2 <= vector_mode_s2_ini;
        operator_s2 <= operator_s2_ini;
      end
      else if (recv_rdy[1] & recv_en[1]) begin
        operator_s2 <= operator_s1;
        vector_mode_s2 <= vector_mode_s1;
      end
    end

    always_ff @( posedge clk ) begin : s2_buf_sync
      if ( reset | fu_local_reset_data ) begin
        for (int i = 0; i < 2; i++) begin
          acc_fw_s2[i] <= 0;
          dot_l3_acc_out_s2[i] <= 0;
        end
        o_shift_imm_s2 <= 0;
        op_predicate_s2 <= 1;
      end
      else begin
        if (recv_rdy[1] & recv_en[1]) begin
          for (int i = 0; i < 2; i++) begin
            acc_fw_s2[i] <= acc_s1_fw[i*2];
            dot_l3_acc_out_s2[i] <= dot_l3_acc_out_s1[i];
          end
          o_shift_imm_s2 <= o_shift_imm_s1;
          op_predicate_s2 <= op_predicate_s1;
        end
      end
    end

    always_ff @( posedge clk ) begin : s2_buf_sync_h
      if ( reset | fu_local_reset_data ) begin
        for (int i = 0; i < 2; i++) begin
          acc_fw_s2_h[i] <= 0;
        end
      end
      else begin
        if (recv_rdy[1] & recv_en[1] & (vector_mode_s1 == VEC_MODE32) ) begin
          for (int i = 0; i < 2; i++) begin
            acc_fw_s2_h[i] <= acc_s1_fw[i*2+1];
          end
        end
      end
    end



    always_comb begin
      result_o[0] = '0;
      result_o[1] = '0;

      if (is_ff_rdy_s0) begin
        result_o[0] = l1_result_s0;
      end
      else if (is_ff_rdy_s1) begin
        unique case ({vector_mode_s1, operator_s1})

          {VEC_MODE8, MUL_DOT}: result_o[0] = l1_result_s1;
          {VEC_MODE16, MUL_MAC}: result_o[0] = l2_result_s1;
          {VEC_MODE32, MUL_MAC}: result_o[0] = l3_result_s1;
          {VEC_MODE16, MUL_CMAC}: begin
            result_o[0] = l1_result_s1;
            result_o[1] = l1_result_c_s1;
          end
          {VEC_MODE32, MUL_CMAC}: begin
            result_o[0] = l2_result_s1;
            result_o[1] = l2_result_c_s1;
          end
          default: ;  // default case to suppress unique warning
        endcase
      end
      else begin
        unique case ({vector_mode_s2, operator_s2})
          {VEC_MODE16, MUL_DOT}: result_o[0] = l2_result_s2;
          {VEC_MODE32, MUL_DOT}: result_o[0] = l3_result_s2;
          {VEC_MODE16, MUL_CDOT}: begin
            result_o[0] = l1_result_s2;
            result_o[1] = l1_result_c_s2;
          end
          {VEC_MODE32, MUL_CDOT}: begin
            result_o[0] = l2_result_s2;
            result_o[1] = l2_result_c_s2;
          end
          default: ;  // default case to suppress unique warning
        endcase
      end
    end

    assign result_predicate_o = is_ff_rdy_s0 ? op_predicate_i : ( is_ff_rdy_s1 ? op_predicate_s1 : op_predicate_s2 );






endmodule

`endif /* VEC_MUL */


`ifndef VEC_MUL_NOPARAM
`define VEC_MUL_NOPARAM

module VEC_MUL_noparam
(
  input logic [1-1:0] clk ,
  input logic [1-1:0] ex_en_i ,
  output logic [1-1:0] ex_rdy_o ,
  input logic [1-1:0] fu_dry_run_done ,
  input logic [1-1:0] fu_local_reset_ctrl ,
  input logic [1-1:0] fu_local_reset_data ,
  input logic [1-1:0] fu_local_reset_stage ,
  input logic [1-1:0] fu_sync_dry_run ,
  output logic [1-1:0] mul_is_ff_cc_rdy_o ,
  input logic [6-1:0] o_imm_i ,
  input logic [64-1:0] op_a_i ,
  input logic [64-1:0] op_b_i ,
  input logic [64-1:0] op_c_i ,
  input logic [1-1:0] op_predicate_i ,
  input logic [3-1:0] op_signed_i ,
  input logic [1-1:0] operator_ext_en_i ,
  input logic [2-1:0] operator_i ,
  output logic [1-1:0] out_en_o ,
  input logic [1-1:0] out_rdy_i ,
  input logic [1-1:0] reset ,
  output logic [64-1:0] result_o [0:1],
  output logic [1-1:0] result_predicate_o ,
  input logic [1-1:0] round_en_i ,
  input logic [2-1:0] vector_mode_i 
);
  vec_mult
  #(
  ) v
  (
    .clk( clk ),
    .ex_en_i( ex_en_i ),
    .ex_rdy_o( ex_rdy_o ),
    .fu_dry_run_done( fu_dry_run_done ),
    .fu_local_reset_ctrl( fu_local_reset_ctrl ),
    .fu_local_reset_data( fu_local_reset_data ),
    .fu_local_reset_stage( fu_local_reset_stage ),
    .fu_sync_dry_run( fu_sync_dry_run ),
    .mul_is_ff_cc_rdy_o( mul_is_ff_cc_rdy_o ),
    .o_imm_i( o_imm_i ),
    .op_a_i( op_a_i ),
    .op_b_i( op_b_i ),
    .op_c_i( op_c_i ),
    .op_predicate_i( op_predicate_i ),
    .op_signed_i( op_signed_i ),
    .operator_ext_en_i( operator_ext_en_i ),
    .operator_i( operator_i ),
    .out_en_o( out_en_o ),
    .out_rdy_i( out_rdy_i ),
    .reset( reset ),
    .result_o( result_o ),
    .result_predicate_o( result_predicate_o ),
    .round_en_i( round_en_i ),
    .vector_mode_i( vector_mode_i )
  );
endmodule

`endif /* VEC_MUL_NOPARAM */




module MULRTL__e9baeef75836042d
(
  input  logic [0:0] clk ,
  output logic [0:0] ex_mul_is_ff_cc_rdy_o ,
  input  logic [2:0] ex_operand_signed_i ,
  input  logic [1:0] ex_operator_i ,
  input  logic [0:0] ex_round_enable_i ,
  input  logic [0:0] fu_dry_run_done ,
  input  logic [0:0] fu_local_reset_a ,
  input  logic [0:0] fu_local_reset_c ,
  input  logic [0:0] fu_sync_dry_run ,
  input  logic [5:0] o_imm_i ,
  input  CGRAData_64_1__payload_64__predicate_1 operand_a_i ,
  input  CGRAData_64_1__payload_64__predicate_1 operand_b_i ,
  input  CGRAData_64_1__payload_64__predicate_1 operand_c_i ,
  input  logic [0:0] operator_ext_en_i ,
  input  logic [0:0] opt_launch_en_i ,
  output logic [0:0] opt_launch_rdy_o ,
  input  logic [0:0] output_rdy_i ,
  input  logic [0:0] recv_predicate_en ,
  input  CGRAData_1__predicate_1 recv_predicate_msg ,
  input  logic [0:0] reset ,
  input  logic [1:0] vector_mode_i ,
  output logic [0:0] send_out__en [0:1] ,
  output CGRAData_64_1__payload_64__predicate_1 send_out__msg [0:1] ,
  input logic [0:0] send_out__rdy [0:1] 
);
  logic [0:0] mul_enable;
  CGRAData_64_1__payload_64__predicate_1 result_o_vector [0:1];
  logic [0:0] result_predicate;

  logic [0:0] mul_element_clk;
  logic [0:0] mul_element_ex_en_i;
  logic [0:0] mul_element_ex_rdy_o;
  logic [0:0] mul_element_fu_dry_run_done;
  logic [0:0] mul_element_fu_local_reset_ctrl;
  logic [0:0] mul_element_fu_local_reset_data;
  logic [0:0] mul_element_fu_local_reset_stage;
  logic [0:0] mul_element_fu_sync_dry_run;
  logic [0:0] mul_element_mul_is_ff_cc_rdy_o;
  logic [5:0] mul_element_o_imm_i;
  logic [63:0] mul_element_op_a_i;
  logic [63:0] mul_element_op_b_i;
  logic [63:0] mul_element_op_c_i;
  logic [0:0] mul_element_op_predicate_i;
  logic [2:0] mul_element_op_signed_i;
  logic [0:0] mul_element_operator_ext_en_i;
  logic [1:0] mul_element_operator_i;
  logic [0:0] mul_element_out_en_o;
  logic [0:0] mul_element_out_rdy_i;
  logic [0:0] mul_element_reset;
  logic [63:0] mul_element_result_o [0:1];
  logic [0:0] mul_element_result_predicate_o;
  logic [0:0] mul_element_round_en_i;
  logic [1:0] mul_element_vector_mode_i;

  VEC_MUL_noparam mul_element
  (
    .clk( mul_element_clk ),
    .ex_en_i( mul_element_ex_en_i ),
    .ex_rdy_o( mul_element_ex_rdy_o ),
    .fu_dry_run_done( mul_element_fu_dry_run_done ),
    .fu_local_reset_ctrl( mul_element_fu_local_reset_ctrl ),
    .fu_local_reset_data( mul_element_fu_local_reset_data ),
    .fu_local_reset_stage( mul_element_fu_local_reset_stage ),
    .fu_sync_dry_run( mul_element_fu_sync_dry_run ),
    .mul_is_ff_cc_rdy_o( mul_element_mul_is_ff_cc_rdy_o ),
    .o_imm_i( mul_element_o_imm_i ),
    .op_a_i( mul_element_op_a_i ),
    .op_b_i( mul_element_op_b_i ),
    .op_c_i( mul_element_op_c_i ),
    .op_predicate_i( mul_element_op_predicate_i ),
    .op_signed_i( mul_element_op_signed_i ),
    .operator_ext_en_i( mul_element_operator_ext_en_i ),
    .operator_i( mul_element_operator_i ),
    .out_en_o( mul_element_out_en_o ),
    .out_rdy_i( mul_element_out_rdy_i ),
    .reset( mul_element_reset ),
    .result_o( mul_element_result_o ),
    .result_predicate_o( mul_element_result_predicate_o ),
    .round_en_i( mul_element_round_en_i ),
    .vector_mode_i( mul_element_vector_mode_i )
  );


  
  always_comb begin : _lambda__s_tile_0__element_fu_1_mul_element_op_a_i
    mul_element_op_a_i = operand_a_i.payload & { { 63 { mul_enable[0] } }, mul_enable };
  end

  
  always_comb begin : _lambda__s_tile_0__element_fu_1_mul_element_op_b_i
    mul_element_op_b_i = operand_b_i.payload & { { 63 { mul_enable[0] } }, mul_enable };
  end

  
  always_comb begin : _lambda__s_tile_0__element_fu_1_mul_element_op_c_i
    mul_element_op_c_i = operand_c_i.payload & { { 63 { mul_enable[0] } }, mul_enable };
  end

  
  always_comb begin : _lambda__s_tile_0__element_fu_1_mul_element_op_predicate_i
    mul_element_op_predicate_i = result_predicate & mul_enable;
  end

  
  always_comb begin : predicate_handling
    result_predicate = 1'd0;
    if ( mul_enable ) begin
      result_predicate = ( ( operand_a_i.predicate & operand_b_i.predicate ) & operand_c_i.predicate ) & ( ~recv_predicate_en | recv_predicate_msg.predicate );
    end
  end

  assign mul_element_clk = clk;
  assign mul_element_reset = reset;
  assign mul_enable = opt_launch_en_i;
  assign mul_element_fu_local_reset_ctrl = fu_local_reset_c;
  assign mul_element_fu_local_reset_data = fu_local_reset_a;
  assign mul_element_fu_local_reset_stage = fu_local_reset_a;
  assign mul_element_fu_dry_run_done = fu_dry_run_done;
  assign mul_element_fu_sync_dry_run = fu_sync_dry_run;
  assign mul_element_vector_mode_i = vector_mode_i;
  assign mul_element_operator_i = ex_operator_i;
  assign mul_element_op_signed_i = ex_operand_signed_i;
  assign mul_element_round_en_i = ex_round_enable_i;
  assign mul_element_operator_ext_en_i = operator_ext_en_i;
  assign mul_element_o_imm_i = o_imm_i;
  assign result_o_vector[0].payload = mul_element_result_o[0];
  assign result_o_vector[0].predicate = mul_element_result_predicate_o;
  assign result_o_vector[1].payload = mul_element_result_o[1];
  assign result_o_vector[1].predicate = mul_element_result_predicate_o;
  assign mul_element_ex_en_i = mul_enable;
  assign mul_element_out_rdy_i = output_rdy_i;
  assign opt_launch_rdy_o = mul_element_ex_rdy_o;
  assign ex_mul_is_ff_cc_rdy_o = mul_element_mul_is_ff_cc_rdy_o;
  assign send_out__msg[0] = result_o_vector[0];
  assign send_out__en[0] = mul_element_out_en_o;
  assign send_out__msg[1] = result_o_vector[1];
  assign send_out__en[1] = mul_element_out_en_o;

endmodule





`ifndef VEC_LUT
`define VEC_LUT





module vec_lut #(
	parameter D_WIDTH        	= 64 ,
	parameter Q_WIDTH        	= 32 ,
	parameter ATOM_WIDTH     	= 8,
	parameter LUT_TYPE       	= 4 ,
	parameter LUT_SIZE       	= 16 ,
	parameter LUT_PRECISION  	= 8,
	parameter PIPELINE_STAGES 	= 4
)(
	input  logic clk,
	input  logic reset,
	input logic fu_local_reset_stage,
	input logic fu_local_reset_ctrl,
	input logic fu_local_reset_data,
	input logic fu_dry_run_done,
	input logic fu_sync_dry_run,
    input  logic [1:0] vector_mode_i,

	input logic [$clog2(LUT_PRECISION)-1:0] k_imm_i,
    input logic [$clog2(Q_WIDTH):0] o_imm_i,

	input  logic [D_WIDTH-1:0] data_i            ,
	input  logic [1:0]         op_signed_i       ,
    input logic       operator_ext_en_i,
	input  logic [$clog2(LUT_TYPE)-1:0] lut_mode_i,
	input  logic [LUT_PRECISION*LUT_SIZE-1:0] lut_k_i,
	input  logic [LUT_PRECISION*LUT_SIZE-1:0] lut_b_i,
	input  logic [LUT_PRECISION*LUT_SIZE-1:0] lut_p_i,

	output logic [$clog2(LUT_TYPE)-1:0] lut_sel_o,
	output logic [D_WIDTH-1:0] data_o,

	input logic op_predicate_i,
    output logic result_predicate_o,

	output logic out_en_o,
	input logic out_rdy_i,
    output logic ex_rdy_o,
    input  logic ex_en_i
);

	parameter LUT_IDX_BITS     = $clog2(LUT_SIZE);
	parameter LUT_TYPE_BITS    = $clog2(LUT_TYPE);

	localparam NUM_SLICES = D_WIDTH/ATOM_WIDTH;
 	localparam NUM_LUT_STAGES = $clog2(LUT_SIZE);

	parameter OPT_LUTA = 5'd28;
	parameter OPT_LUTB = 5'd29;
	parameter OPT_LUTC = 5'd30;
	parameter OPT_LUTD = 5'd31;

	parameter VEC_MODE32 = 2'b00;
	parameter VEC_MODE16 = 2'b10;
	parameter VEC_MODE8 = 2'b11;


	logic [D_WIDTH-1:0] bmask_tmp_s0;
  	logic [D_WIDTH-1:0] bmask_s0;
	logic [ATOM_WIDTH:0] lut_i_l1 [NUM_SLICES];
	logic [2*ATOM_WIDTH:0] lut_i_l2 [NUM_SLICES/2];
	logic [4*ATOM_WIDTH:0] lut_i_l3 [NUM_SLICES/4];

	logic [LUT_PRECISION-1:0] lut_key_s0 [NUM_SLICES];
	logic [LUT_PRECISION-1:0] lut_key_s1 [NUM_SLICES];
	logic [LUT_PRECISION-1:0] lut_key_s2 [NUM_SLICES];

	logic [1:0] op_signed_s1;
	logic [1:0] op_signed_s2;
	logic round_en_i;
	logic round_en_s1, round_en_s2, round_en_s3; 
	logic [1:0] vector_mode_s1;
	logic [1:0] vector_mode_s2;
	logic [1:0] vector_mode_s3;

  	logic [3:0] op_mask_s1;

	logic [LUT_TYPE_BITS-1:0] lut_idx_s1;

	logic [ATOM_WIDTH-1:0] lut_p_s1 [NUM_SLICES];

	logic [LUT_IDX_BITS+$clog2(LUT_PRECISION)-1:0] idx_lower_s1 [NUM_SLICES];
	logic [LUT_IDX_BITS+$clog2(LUT_PRECISION)-1:0] idx_upper_s1 [NUM_SLICES];
	logic [LUT_IDX_BITS+$clog2(LUT_PRECISION)-1:0] idx_mid_s1 [NUM_SLICES];
	logic [LUT_IDX_BITS+$clog2(LUT_PRECISION)-1:0] idx_fin_s1 [NUM_SLICES];

	logic [LUT_PRECISION-1:0] lut_k_s1 [NUM_SLICES];
	logic [LUT_PRECISION-1:0] lut_k_s2 [NUM_SLICES];
	logic [LUT_PRECISION-1:0] lut_b_s1 [NUM_SLICES];
	logic [LUT_PRECISION-1:0] lut_b_s2 [NUM_SLICES];
	
    logic [$clog2(LUT_PRECISION)-1:0] k_imm_s1;
    logic [$clog2(LUT_PRECISION)-1:0] k_imm_s2;

	logic [2*LUT_PRECISION+1:0] lut_approx_s2_tmp [NUM_SLICES];
	logic [2*LUT_PRECISION+2:0] lut_approx_s2 [NUM_SLICES];
	logic [2*LUT_PRECISION+2:0] lut_approx_s3 [NUM_SLICES];

	logic [$clog2(Q_WIDTH):0] o_imm_s1;
  	logic [$clog2(Q_WIDTH):0] o_imm_s2;
	logic [$clog2(Q_WIDTH):0] o_imm_s3;
	
	logic [D_WIDTH-1:0] bmask_tmp_s3;	
  	logic [D_WIDTH-1:0] bmask_s3;

	logic [2*LUT_PRECISION+3:0] lut_approx_sr_s3 [NUM_SLICES];
	logic [4*LUT_PRECISION+2:0] lut_approx_sl_s3 [NUM_SLICES];

	logic [ATOM_WIDTH-1:0] lut_result_l1_tmp_s3 [NUM_SLICES];
	logic [2*ATOM_WIDTH-1:0] lut_result_l2_tmp_s3 [NUM_SLICES/2];
	logic [4*ATOM_WIDTH-1:0] lut_result_l3_tmp_s3 [NUM_SLICES/4];

	logic [D_WIDTH-1:0] lut_result_l1;
	logic [D_WIDTH-1:0] lut_result_l2;
	logic [D_WIDTH-1:0] lut_result_l3;


	logic op_predicate_s1, op_predicate_s2, op_predicate_s3;

	genvar i, j, k;


	logic recv_en[PIPELINE_STAGES-1];
	logic recv_rdy[PIPELINE_STAGES-1];
	logic send_en[PIPELINE_STAGES-1];
	logic send_rdy[PIPELINE_STAGES-1];
	logic busy[PIPELINE_STAGES-1];

	logic busy_ini[PIPELINE_STAGES-1];

	always_ff @( posedge clk ) begin : pipeline_sync
		if ( reset | fu_local_reset_stage ) begin
			for (int i = 0; i < PIPELINE_STAGES - 1; i++) begin
				busy[i] <= 0;
			end
		end
		else if ( fu_sync_dry_run & ~fu_dry_run_done ) begin
			for (int i = 0; i < PIPELINE_STAGES - 1; i++) begin
				busy[i] <= busy_ini[i];
			end
		end
		else begin
			for (int i = 0; i < PIPELINE_STAGES - 1; i++) begin
				busy[i] <= recv_rdy[i] ? recv_en[i] : busy[i];
			end
		end
	end

	always_ff @( posedge clk ) begin
		if ( reset | fu_local_reset_ctrl ) begin
			for (int i = 0; i < PIPELINE_STAGES - 1; i++) begin
				busy_ini[i] <= 0;
			end
		end
		else if ( fu_dry_run_done ) begin
			for (int i = 0; i < PIPELINE_STAGES - 1; i++) begin
				busy_ini[i] <= busy[i];
			end
		end
	end

	generate
		for (i=1; i < PIPELINE_STAGES-1; i++) begin: pipeline_conn
			assign recv_en[i] = send_en[i-1];
			assign send_rdy[i-1] = recv_rdy[i];
		end
		for (i=0; i < PIPELINE_STAGES-1; i++) begin: pipeline_async
			assign recv_rdy[i] = ~(send_en[i] & ~send_rdy[i]);
			assign send_en[i] = busy[i];
		end
	endgenerate
	
	assign recv_en[0] = ex_en_i;
	assign send_rdy[PIPELINE_STAGES-2] = out_rdy_i;
	assign ex_rdy_o = recv_rdy[0];
	assign out_en_o = send_en[PIPELINE_STAGES-2];



	



	assign round_en_i = operator_ext_en_i;


	always_comb begin : data_i_q
		for (int m=0; m < NUM_SLICES; m++) begin
			lut_key_s0[m] = 0;
		end
		unique case (vector_mode_i)
			VEC_MODE8: begin
				for (int m=0; m < NUM_SLICES; m++) begin
					lut_key_s0[m] = data_i[m*ATOM_WIDTH+:ATOM_WIDTH];
				end
			end
			VEC_MODE16: begin
				for (int m=0; m < NUM_SLICES/2; m++) begin
					lut_key_s0[m*2] = data_i[m*2*ATOM_WIDTH+:ATOM_WIDTH];
				end
			end
			VEC_MODE32: begin
				for (int m=0; m < NUM_SLICES/4; m++) begin
					lut_key_s0[m*4] = data_i[m*4*ATOM_WIDTH+:ATOM_WIDTH];
				end
			end
			default: ;
		endcase
	end
	

	always_comb begin : bits_mask
		unique case (vector_mode_s1)
			VEC_MODE32: op_mask_s1 = 4'b0001;
			VEC_MODE16: op_mask_s1 = 4'b0101;
			VEC_MODE8: op_mask_s1 = 4'b1111;
			default: op_mask_s1 = '0;
		endcase
	end

	assign lut_sel_o = lut_idx_s1;

	generate
		for (i = 0; i < NUM_SLICES; i++) begin 
			always_comb begin: gen_lut_idx
				idx_lower_s1[i] = 0;
				idx_upper_s1[i] = LUT_SIZE-1;
				idx_fin_s1[i] = 0;

				for (int m=0; m < NUM_LUT_STAGES; m++) begin
					idx_mid_s1[i] = (idx_lower_s1[i] + idx_upper_s1[i]) >> 1;
					lut_p_s1[i] = lut_p_i[(idx_mid_s1[i] << $clog2(LUT_PRECISION)) +: LUT_PRECISION];
					if ( $signed({op_signed_s1[0] & lut_key_s1[i][LUT_PRECISION-1], lut_key_s1[i]}) <= $signed({op_signed_s1[0] & lut_p_s1[i][LUT_PRECISION-1], lut_p_s1[i]})) begin
						idx_upper_s1[i] = idx_mid_s1[i] - 1;
					end
					else begin
						idx_lower_s1[i] = idx_mid_s1[i] + 1;
					end
				end
				idx_fin_s1[i] = idx_lower_s1[i] << $clog2(LUT_PRECISION);
			end
		end
		
		for (i = 0; i < NUM_SLICES; i++) begin : gen_lut_k_b
			assign lut_k_s1[i] = lut_k_i[idx_fin_s1[i] +: LUT_PRECISION] & {LUT_PRECISION{op_mask_s1[i%4]}};
			assign lut_b_s1[i] = lut_b_i[idx_fin_s1[i] +: LUT_PRECISION] & {LUT_PRECISION{op_mask_s1[i%4]}};
		end
	endgenerate


	
	generate
		for (i = 0; i < NUM_SLICES ; i++ ) begin : gen_lut_approx
			assign lut_approx_s2_tmp[i] = $signed({op_signed_s2[0] & lut_key_s2[i][LUT_PRECISION-1], lut_key_s2[i]}) * $signed({op_signed_s2[1] & lut_k_s2[i][LUT_PRECISION-1], lut_k_s2[i]}); 
			assign lut_approx_s2[i] = $signed(lut_approx_s2_tmp[i]) + $signed({{(LUT_PRECISION+2){lut_b_s2[i][LUT_PRECISION-1]}}, lut_b_s2[i]} <<< k_imm_s2);
		end
	endgenerate


	assign bmask_tmp_s3 = 'b1 <<< o_imm_s3[$clog2(Q_WIDTH)-1 : 0];
  	assign bmask_s3 = round_en_s3 ? {1'b0, bmask_tmp_s3[D_WIDTH-1:1]} : '0;

	generate
		for (i = 0; i < NUM_SLICES ; i++ ) begin 
			assign lut_approx_sr_s3[i] = $signed($signed(lut_approx_s3[i]) + bmask_s3[0+:ATOM_WIDTH*2]) >>> o_imm_s3[$clog2(Q_WIDTH)-1 : 0];
			assign lut_approx_sl_s3[i] = $signed(lut_approx_s3[i]) <<< o_imm_s3[$clog2(Q_WIDTH)-1 : 0];			
		end
		
		for (i = 0; i < NUM_SLICES ; i++ ) begin 
			assign lut_result_l1_tmp_s3[i] = o_imm_s3[$clog2(Q_WIDTH)] ? $signed(lut_approx_sl_s3[i]) : $signed(lut_approx_sr_s3[i]);
			assign lut_result_l1[i*ATOM_WIDTH +: ATOM_WIDTH] = lut_result_l1_tmp_s3[i];			
		end

		for (i = 0; i < NUM_SLICES / 2 ; i++ ) begin 
			assign lut_result_l2_tmp_s3[i] = o_imm_s3[$clog2(Q_WIDTH)] ? $signed(lut_approx_sl_s3[i*2]) : $signed(lut_approx_sr_s3[i*2]);	
			assign lut_result_l2[i*ATOM_WIDTH*2 +: ATOM_WIDTH*2] = lut_result_l2_tmp_s3[i];		
		end

		for (i = 0; i < NUM_SLICES / 4 ; i++ ) begin 
			assign lut_result_l3_tmp_s3[i] = o_imm_s3[$clog2(Q_WIDTH)] ? $signed(lut_approx_sl_s3[i*4]) : $signed(lut_approx_sr_s3[i*4]);	
			assign lut_result_l3[i*ATOM_WIDTH*4 +: ATOM_WIDTH*4] = lut_result_l3_tmp_s3[i];
		end
	endgenerate



	always_ff @( posedge clk ) begin : s1_buf_sync
		if ( reset | fu_local_reset_data ) begin
			for (int m=0; m < NUM_SLICES; m++) begin
				lut_key_s1[m] <= 0;
			end
			lut_idx_s1 <= 0;
			round_en_s1 <= 0;
			op_signed_s1 <= 0;
			vector_mode_s1 <= 0;
			k_imm_s1 <= 0;
			o_imm_s1 <= 0;
			op_predicate_s1 <= 1;
		end
		else if (recv_rdy[0] & recv_en[0]) begin
			for (int m=0; m < NUM_SLICES; m++) begin
				lut_key_s1[m] <= lut_key_s0[m];
			end
			lut_idx_s1 <= lut_mode_i;
			round_en_s1 <= round_en_i;
			op_signed_s1 <= op_signed_i;
			vector_mode_s1 <= vector_mode_i;
			k_imm_s1 <= k_imm_i;
			o_imm_s1 <= o_imm_i;
			op_predicate_s1 <= op_predicate_i;
		end
	end

	always_ff @( posedge clk ) begin : s2_buf_sync
		if ( reset | fu_local_reset_data ) begin
			for (int m=0; m < NUM_SLICES; m++) begin
				lut_key_s2[m] <= 0;
				lut_k_s2[m] <= 0;
				lut_b_s2[m] <= 0;
			end
			round_en_s2 <= 0;
			op_signed_s2 <= 0;
			vector_mode_s2 <= 0;
			k_imm_s2 <= 0;
			o_imm_s2 <= 0;
			op_predicate_s2 <= 1;
		end
		else if (recv_rdy[1] & recv_en[1]) begin
			for (int m=0; m < NUM_SLICES; m++) begin
				lut_key_s2[m] <= lut_key_s1[m];
				lut_k_s2[m] <= lut_k_s1[m];
				lut_b_s2[m] <= lut_b_s1[m];
			end
			round_en_s2 <= round_en_s1;
			op_signed_s2 <= op_signed_s1;
			vector_mode_s2 <= vector_mode_s1;
			k_imm_s2 <= k_imm_s1;
			o_imm_s2 <= o_imm_s1;
			op_predicate_s2 <= op_predicate_s1;
		end
	end

	always_ff @( posedge clk ) begin : s3_buf_sync
		if ( reset | fu_local_reset_data ) begin
			for (int m=0; m < NUM_SLICES; m++) begin
				lut_approx_s3[m] <= 0;
			end
			round_en_s3 <= 0;
			vector_mode_s3 <= 0;
			o_imm_s3 <= 0;
			op_predicate_s3 <= 1;
		end
		else if (recv_rdy[2] & recv_en[2]) begin
			for (int m=0; m < NUM_SLICES; m++) begin
				lut_approx_s3[m] <= lut_approx_s2[m];
			end
			round_en_s3 <= round_en_s2;
			vector_mode_s3 <= vector_mode_s2;
			o_imm_s3 <= o_imm_s2;
			op_predicate_s3 <= op_predicate_s2;
		end
	end


	always_comb begin
		data_o = '0;

		unique case (vector_mode_s3)
			VEC_MODE8: data_o = lut_result_l1;
			VEC_MODE16: data_o = lut_result_l2;
			VEC_MODE32: data_o = lut_result_l3;
			default: ;  // default case to suppress unique warning
		endcase
	end

	assign result_predicate_o = op_predicate_s3;

endmodule

`endif /* VEC_LUT */


`ifndef VEC_LUT_NOPARAM
`define VEC_LUT_NOPARAM

module VEC_LUT_noparam
(
  input logic [1-1:0] clk ,
  input logic [64-1:0] data_i ,
  output logic [64-1:0] data_o ,
  input logic [1-1:0] ex_en_i ,
  output logic [1-1:0] ex_rdy_o ,
  input logic [1-1:0] fu_dry_run_done ,
  input logic [1-1:0] fu_local_reset_ctrl ,
  input logic [1-1:0] fu_local_reset_data ,
  input logic [1-1:0] fu_local_reset_stage ,
  input logic [1-1:0] fu_sync_dry_run ,
  input logic [3-1:0] k_imm_i ,
  input logic [128-1:0] lut_b_i ,
  input logic [128-1:0] lut_k_i ,
  input logic [2-1:0] lut_mode_i ,
  input logic [128-1:0] lut_p_i ,
  output logic [2-1:0] lut_sel_o ,
  input logic [6-1:0] o_imm_i ,
  input logic [1-1:0] op_predicate_i ,
  input logic [2-1:0] op_signed_i ,
  input logic [1-1:0] operator_ext_en_i ,
  output logic [1-1:0] out_en_o ,
  input logic [1-1:0] out_rdy_i ,
  input logic [1-1:0] reset ,
  output logic [1-1:0] result_predicate_o ,
  input logic [2-1:0] vector_mode_i 
);
  vec_lut
  #(
  ) v
  (
    .clk( clk ),
    .data_i( data_i ),
    .data_o( data_o ),
    .ex_en_i( ex_en_i ),
    .ex_rdy_o( ex_rdy_o ),
    .fu_dry_run_done( fu_dry_run_done ),
    .fu_local_reset_ctrl( fu_local_reset_ctrl ),
    .fu_local_reset_data( fu_local_reset_data ),
    .fu_local_reset_stage( fu_local_reset_stage ),
    .fu_sync_dry_run( fu_sync_dry_run ),
    .k_imm_i( k_imm_i ),
    .lut_b_i( lut_b_i ),
    .lut_k_i( lut_k_i ),
    .lut_mode_i( lut_mode_i ),
    .lut_p_i( lut_p_i ),
    .lut_sel_o( lut_sel_o ),
    .o_imm_i( o_imm_i ),
    .op_predicate_i( op_predicate_i ),
    .op_signed_i( op_signed_i ),
    .operator_ext_en_i( operator_ext_en_i ),
    .out_en_o( out_en_o ),
    .out_rdy_i( out_rdy_i ),
    .reset( reset ),
    .result_predicate_o( result_predicate_o ),
    .vector_mode_i( vector_mode_i )
  );
endmodule

`endif /* VEC_LUT_NOPARAM */




module LUTRTL__e9baeef75836042d
(
  input  logic [0:0] clk ,
  input  logic [1:0] ex_operand_signed_i ,
  input  logic [1:0] ex_operator_i ,
  input  logic [0:0] fu_dry_run_done ,
  input  logic [0:0] fu_local_reset_a ,
  input  logic [0:0] fu_local_reset_c ,
  input  logic [0:0] fu_sync_dry_run ,
  input  logic [2:0] k_imm_i ,
  input  logic [127:0] lut_b_i ,
  input  logic [127:0] lut_k_i ,
  input  logic [127:0] lut_p_i ,
  output logic [1:0] lut_sel_o ,
  input  logic [5:0] o_imm_i ,
  input  CGRAData_64_1__payload_64__predicate_1 operand_a_i ,
  input  logic [0:0] operator_ext_en_i ,
  input  logic [0:0] opt_launch_en_i ,
  output logic [0:0] opt_launch_rdy_o ,
  input  logic [0:0] output_rdy_i ,
  input  logic [0:0] recv_predicate_en ,
  input  CGRAData_1__predicate_1 recv_predicate_msg ,
  input  logic [0:0] reset ,
  input  logic [1:0] vector_mode_i ,
  output logic [0:0] send_out__en [0:1] ,
  output CGRAData_64_1__payload_64__predicate_1 send_out__msg [0:1] ,
  input logic [0:0] send_out__rdy [0:1] 
);
  logic [0:0] lut_enable;
  CGRAData_64_1__payload_64__predicate_1 result_o_vector;
  logic [0:0] result_predicate;

  logic [0:0] lut_element_clk;
  logic [63:0] lut_element_data_i;
  logic [63:0] lut_element_data_o;
  logic [0:0] lut_element_ex_en_i;
  logic [0:0] lut_element_ex_rdy_o;
  logic [0:0] lut_element_fu_dry_run_done;
  logic [0:0] lut_element_fu_local_reset_ctrl;
  logic [0:0] lut_element_fu_local_reset_data;
  logic [0:0] lut_element_fu_local_reset_stage;
  logic [0:0] lut_element_fu_sync_dry_run;
  logic [2:0] lut_element_k_imm_i;
  logic [127:0] lut_element_lut_b_i;
  logic [127:0] lut_element_lut_k_i;
  logic [1:0] lut_element_lut_mode_i;
  logic [127:0] lut_element_lut_p_i;
  logic [1:0] lut_element_lut_sel_o;
  logic [5:0] lut_element_o_imm_i;
  logic [0:0] lut_element_op_predicate_i;
  logic [1:0] lut_element_op_signed_i;
  logic [0:0] lut_element_operator_ext_en_i;
  logic [0:0] lut_element_out_en_o;
  logic [0:0] lut_element_out_rdy_i;
  logic [0:0] lut_element_reset;
  logic [0:0] lut_element_result_predicate_o;
  logic [1:0] lut_element_vector_mode_i;

  VEC_LUT_noparam lut_element
  (
    .clk( lut_element_clk ),
    .data_i( lut_element_data_i ),
    .data_o( lut_element_data_o ),
    .ex_en_i( lut_element_ex_en_i ),
    .ex_rdy_o( lut_element_ex_rdy_o ),
    .fu_dry_run_done( lut_element_fu_dry_run_done ),
    .fu_local_reset_ctrl( lut_element_fu_local_reset_ctrl ),
    .fu_local_reset_data( lut_element_fu_local_reset_data ),
    .fu_local_reset_stage( lut_element_fu_local_reset_stage ),
    .fu_sync_dry_run( lut_element_fu_sync_dry_run ),
    .k_imm_i( lut_element_k_imm_i ),
    .lut_b_i( lut_element_lut_b_i ),
    .lut_k_i( lut_element_lut_k_i ),
    .lut_mode_i( lut_element_lut_mode_i ),
    .lut_p_i( lut_element_lut_p_i ),
    .lut_sel_o( lut_element_lut_sel_o ),
    .o_imm_i( lut_element_o_imm_i ),
    .op_predicate_i( lut_element_op_predicate_i ),
    .op_signed_i( lut_element_op_signed_i ),
    .operator_ext_en_i( lut_element_operator_ext_en_i ),
    .out_en_o( lut_element_out_en_o ),
    .out_rdy_i( lut_element_out_rdy_i ),
    .reset( lut_element_reset ),
    .result_predicate_o( lut_element_result_predicate_o ),
    .vector_mode_i( lut_element_vector_mode_i )
  );


  
  always_comb begin : _lambda__s_tile_0__element_fu_2_lut_element_data_i
    lut_element_data_i = operand_a_i.payload & { { 63 { lut_enable[0] } }, lut_enable };
  end

  
  always_comb begin : _lambda__s_tile_0__element_fu_2_lut_element_op_predicate_i
    lut_element_op_predicate_i = result_predicate & lut_enable;
  end

  
  always_comb begin : predicate_handling
    result_predicate = 1'd0;
    if ( lut_enable ) begin
      result_predicate = operand_a_i.predicate & ( ~recv_predicate_en | recv_predicate_msg.predicate );
    end
  end

  assign lut_element_clk = clk;
  assign lut_element_reset = reset;
  assign lut_enable = opt_launch_en_i;
  assign lut_element_fu_local_reset_ctrl = fu_local_reset_c;
  assign lut_element_fu_local_reset_data = fu_local_reset_a;
  assign lut_element_fu_local_reset_stage = fu_local_reset_a;
  assign lut_element_fu_dry_run_done = fu_dry_run_done;
  assign lut_element_fu_sync_dry_run = fu_sync_dry_run;
  assign lut_element_vector_mode_i = vector_mode_i;
  assign lut_element_operator_ext_en_i = operator_ext_en_i;
  assign lut_element_lut_mode_i = ex_operator_i;
  assign lut_element_o_imm_i = o_imm_i;
  assign lut_element_k_imm_i = k_imm_i;
  assign lut_element_op_signed_i = ex_operand_signed_i;
  assign lut_element_lut_k_i = lut_k_i;
  assign lut_element_lut_b_i = lut_b_i;
  assign lut_element_lut_p_i = lut_p_i;
  assign lut_element_ex_en_i = lut_enable;
  assign lut_element_out_rdy_i = output_rdy_i;
  assign result_o_vector.payload = lut_element_data_o;
  assign result_o_vector.predicate = lut_element_result_predicate_o;
  assign lut_sel_o = lut_element_lut_sel_o;
  assign opt_launch_rdy_o = lut_element_ex_rdy_o;
  assign send_out__msg[0] = result_o_vector;
  assign send_out__en[0] = lut_element_out_en_o;
  assign send_out__msg[1] = { 64'd0, 1'd0 };
  assign send_out__en[1] = 1'd0;

endmodule





`ifndef COREV_DECODERRTL
`define COREV_DECODERRTL





module cgra_fu_decoder
(
    input logic [1:0]          cgra_signed_mode_i,
    input logic [1:0]          cgra_vec_mode_i,
    input logic [9:0]        id_operator_i, 

    output logic [6:0]       id_alu_operator_o,
    output logic [2:0]       id_alu_ext_mode_o,
    output logic             id_alu_enable_o,
    output logic [1:0]       id_mult_operator_o,
    output logic             id_mult_enable_o,

    output logic [2:0]       id_lut_k_imm_o,
    output logic [1:0]       id_lut_operator_o,
    output logic             id_lut_enable_o,

    output logic             id_nah_opt_o,

    output logic [2:0]       id_signed_mode_o,

    output logic             id_const_enable_o,
    output logic             id_round_enable_o,

    output logic [1:0]       id_operand_b_sel_o,
    output logic [1:0]       id_operand_c_sel_o,
    output logic             id_operand_b_repl_o,
    output logic             id_operand_c_repl_o
);

  localparam ALU_ADD = 7'b0011000;
	localparam ALU_SUB = 7'b0011001;
	localparam ALU_XOR = 7'b0101111;
	localparam ALU_OR = 7'b0101110;
	localparam ALU_AND = 7'b0010101;
	localparam ALU_SRA = 7'b0100100;
	localparam ALU_SRL = 7'b0100101;
	localparam ALU_SLL = 7'b0100111;
	localparam ALU_ABS = 7'b0010100;
	localparam ALU_GT = 7'b0001000;
	localparam ALU_GE = 7'b0001010;
	localparam ALU_EQ  = 7'b0001100;
	localparam ALU_MAX  = 7'b0010010;
	localparam ALU_MIN  = 7'b0010000;

	localparam ALU_PHI  = 7'b0111001;
	localparam ALU_SHUF  = 7'b0111010;

	localparam ALU_RADD = 7'b0110000;

  parameter OPT_NAH = 5'd0;

  parameter OPT_ADD = 5'd1;
  parameter OPT_SUB = 5'd2;
  parameter OPT_RADD = 5'd3;

  parameter OPT_MUL = 5'd4;
  parameter OPT_MAC = 5'd5; 
  parameter OPT_MAC_CONST = 5'd6;
  parameter OPT_DOT = 5'd7;
  parameter OPT_DOT_CONST = 5'd8;

  parameter OPT_SLL = 5'd9;
  parameter OPT_SRL = 5'd10;
  parameter OPT_SRA = 5'd11;
  parameter OPT_MIN = 5'd12;
  parameter OPT_MAX = 5'd13;
  parameter OPT_ABS = 5'd14;
  parameter OPT_XOR = 5'd15;
  parameter OPT_OR = 5'd16;
  parameter OPT_AND = 5'd17;

  parameter OPT_ROT = 5'd18;  
  parameter OPT_PHI = 5'd19;  
  
  parameter OPT_CMUL = 5'd20;
  parameter OPT_CMAC = 5'd21; 
  parameter OPT_CMAC_CONST = 5'd22;
  parameter OPT_CDOT = 5'd23;
  parameter OPT_CDOT_CONST = 5'd24;

  parameter OPT_EQ = 5'd25;  
  parameter OPT_GT = 5'd26; 
  parameter OPT_GE = 5'd27; 


  parameter OPT_LUTA = 5'd28;
  parameter OPT_LUTB = 5'd29;
  parameter OPT_LUTC = 5'd30;
  parameter OPT_LUTD = 5'd31;

  localparam MUL_MAC = 2'b00;
  localparam MUL_DOT = 2'b01;
  localparam MUL_CMAC = 2'b10;
  localparam MUL_CDOT = 2'b11;

  localparam VEC_MODE32 = 2'b00;
  localparam VEC_MODE16 = 2'b10;
  localparam VEC_MODE8 = 2'b11;

  always_comb begin : alu_instruction_decoder
    id_alu_operator_o = ALU_ADD;
    id_alu_enable_o = 1'b1;

    unique case (id_operator_i[4:0])
      OPT_ADD: id_alu_operator_o = ALU_ADD;
      OPT_RADD: id_alu_operator_o = ALU_RADD;
      OPT_SUB: id_alu_operator_o = ALU_SUB;
      OPT_SLL: id_alu_operator_o = ALU_SLL;
      OPT_SRL: id_alu_operator_o = ALU_SRL;
      OPT_SRA: id_alu_operator_o = ALU_SRA;
      OPT_XOR: id_alu_operator_o = ALU_XOR;
      OPT_OR: id_alu_operator_o = ALU_OR;
      OPT_AND: id_alu_operator_o = ALU_AND;
      OPT_ABS: id_alu_operator_o = ALU_ABS;
      OPT_MIN: id_alu_operator_o = ALU_MIN;
      OPT_MAX: id_alu_operator_o = ALU_MAX;
      OPT_EQ: id_alu_operator_o = ALU_EQ;
      OPT_GT: id_alu_operator_o = ALU_GT;
      OPT_GE: id_alu_operator_o = ALU_GE;
      OPT_PHI: id_alu_operator_o = ALU_PHI;
      OPT_ROT: id_alu_operator_o = ALU_SHUF;
      default: id_alu_enable_o = 1'b0;
    endcase
  end


  always_comb begin : mult_instruction_decoder
    id_mult_operator_o = MUL_MAC;
    id_mult_enable_o = 1'b1;
    unique case (id_operator_i[4:0])
      OPT_MUL: id_mult_operator_o = MUL_MAC;
      OPT_MAC: id_mult_operator_o = MUL_MAC;
      OPT_MAC_CONST: id_mult_operator_o = MUL_MAC;
      OPT_DOT: id_mult_operator_o = MUL_DOT;
      OPT_DOT_CONST: id_mult_operator_o = MUL_DOT;

      OPT_CMUL: id_mult_operator_o = MUL_CMAC;
      OPT_CMAC: id_mult_operator_o = MUL_CMAC;
      OPT_CMAC_CONST: id_mult_operator_o = MUL_CMAC;
      OPT_CDOT: id_mult_operator_o = MUL_CDOT;
      OPT_CDOT_CONST: id_mult_operator_o = MUL_CDOT;

      default: id_mult_enable_o = 1'b0;
    endcase
  end

  always_comb begin : const_mux_selector_b
    id_operand_b_sel_o = 2'b10;
    unique case (id_operator_i[4:0])
      OPT_ADD, OPT_SUB, OPT_SLL, OPT_SRL, OPT_SRA,
      OPT_RADD, OPT_MUL,
      OPT_MIN, OPT_MAX, OPT_XOR, OPT_OR, OPT_AND, OPT_PHI, 
      OPT_CMUL, OPT_EQ, OPT_GT, OPT_GE: begin
        id_operand_b_sel_o = id_operator_i[9] ? 2'b10 : ( id_operator_i[5] ? 2'b01 : 2'b00);
      end
      OPT_ROT: id_operand_b_sel_o = id_operator_i[5] ? 2'b01 : 2'b00;
      OPT_MAC, OPT_CMAC, OPT_DOT, OPT_CDOT: begin
        id_operand_b_sel_o = {id_operator_i[5], id_operator_i[5]};
      end
      OPT_MAC_CONST, OPT_CMAC_CONST, OPT_DOT_CONST, OPT_CDOT_CONST: begin
        id_operand_b_sel_o = {1'b0, id_operator_i[5]};
      end
      default: ;
    endcase    
  end

  always_comb begin : const_mux_selector_c
    id_operand_c_sel_o = 2'b10;

    unique case (id_operator_i[4:0])
      OPT_PHI: id_operand_c_sel_o = id_operator_i[8] ? 2'b00 : 2'b10;
      OPT_MAC, OPT_CMAC, OPT_DOT, OPT_CDOT: begin
        id_operand_c_sel_o = {id_operator_i[5], id_operator_i[5]};
      end
      OPT_MAC_CONST, OPT_CMAC_CONST, OPT_DOT_CONST, OPT_CDOT_CONST: begin
        id_operand_c_sel_o = {1'b0, ~id_operator_i[5]};
      end
      default: ;
    endcase    
  end

  assign id_signed_mode_o[0] = cgra_signed_mode_i[0];
  assign id_signed_mode_o[1] = cgra_signed_mode_i[1];
  assign id_signed_mode_o[2] = (id_operand_c_sel_o == 2'b00) ? cgra_signed_mode_i[1] : 1'b1;

  always_comb begin : scalar_repl_selector
    id_operand_b_repl_o = 1'b0;
    id_operand_c_repl_o = 1'b0;  

    unique case (id_operator_i[4:0])
      OPT_ADD, OPT_SUB, OPT_MUL, OPT_SLL, OPT_SRL, OPT_SRA,
      OPT_MIN, OPT_MAX, OPT_XOR, OPT_OR, OPT_AND, OPT_ROT, OPT_PHI, 
      OPT_CMUL, OPT_EQ, OPT_GT, OPT_GE,
      OPT_MAC, OPT_CMAC,
      OPT_MAC_CONST, OPT_CMAC_CONST: begin
        id_operand_b_repl_o = (id_operand_b_sel_o == 2'b00) ? id_operator_i[6] : 1'b0;
        id_operand_c_repl_o = (id_operand_c_sel_o == 2'b00) ? id_operator_i[6] : 1'b0;
      end
      
      OPT_RADD: begin
        id_operand_b_repl_o = 1'b0;
      end
      OPT_DOT, OPT_CDOT,
      OPT_DOT_CONST, OPT_CDOT_CONST: begin
        id_operand_b_repl_o = (id_operand_b_sel_o == 2'b00) ? id_operator_i[6] : 1'b0;
        id_operand_c_repl_o = 1'b0;
      end
      default: ;
    endcase    
  end



    

  assign id_const_enable_o = id_operand_c_sel_o[0] | id_operand_b_sel_o[0];
  assign id_round_enable_o = id_operator_i[7] && ~id_lut_enable_o;
  assign id_alu_ext_mode_o = (id_alu_operator_o == ALU_SHUF) ? id_operator_i[9:7] : '0;

  assign id_lut_enable_o = (id_operator_i[4:2] == 3'b111);
  assign id_lut_operator_o = (id_lut_enable_o) ? id_operator_i[1:0] : '0;
  assign id_lut_k_imm_o = (id_lut_enable_o) ? id_operator_i[7:5] : '0;
  
  assign id_nah_opt_o = (id_operator_i[4:0] == OPT_NAH);

endmodule
`endif /* COREV_DECODERRTL */


`ifndef COREV_DECODERRTL_NOPARAM
`define COREV_DECODERRTL_NOPARAM

module CoreV_DecoderRTL_noparam
(
  input logic reset,
  input logic clk,
  input logic [2-1:0] cgra_signed_mode_i ,
  input logic [2-1:0] cgra_vec_mode_i ,
  output logic [1-1:0] id_alu_enable_o ,
  output logic [3-1:0] id_alu_ext_mode_o ,
  output logic [7-1:0] id_alu_operator_o ,
  output logic [1-1:0] id_const_enable_o ,
  output logic [1-1:0] id_lut_enable_o ,
  output logic [3-1:0] id_lut_k_imm_o ,
  output logic [2-1:0] id_lut_operator_o ,
  output logic [1-1:0] id_mult_enable_o ,
  output logic [2-1:0] id_mult_operator_o ,
  output logic [1-1:0] id_nah_opt_o ,
  output logic [1-1:0] id_operand_b_repl_o ,
  output logic [2-1:0] id_operand_b_sel_o ,
  output logic [1-1:0] id_operand_c_repl_o ,
  output logic [2-1:0] id_operand_c_sel_o ,
  input logic [10-1:0] id_operator_i ,
  output logic [1-1:0] id_round_enable_o ,
  output logic [3-1:0] id_signed_mode_o 
);
  cgra_fu_decoder
  #(
  ) v
  (
    .cgra_signed_mode_i( cgra_signed_mode_i ),
    .cgra_vec_mode_i( cgra_vec_mode_i ),
    .id_alu_enable_o( id_alu_enable_o ),
    .id_alu_ext_mode_o( id_alu_ext_mode_o ),
    .id_alu_operator_o( id_alu_operator_o ),
    .id_const_enable_o( id_const_enable_o ),
    .id_lut_enable_o( id_lut_enable_o ),
    .id_lut_k_imm_o( id_lut_k_imm_o ),
    .id_lut_operator_o( id_lut_operator_o ),
    .id_mult_enable_o( id_mult_enable_o ),
    .id_mult_operator_o( id_mult_operator_o ),
    .id_nah_opt_o( id_nah_opt_o ),
    .id_operand_b_repl_o( id_operand_b_repl_o ),
    .id_operand_b_sel_o( id_operand_b_sel_o ),
    .id_operand_c_repl_o( id_operand_c_repl_o ),
    .id_operand_c_sel_o( id_operand_c_sel_o ),
    .id_operator_i( id_operator_i ),
    .id_round_enable_o( id_round_enable_o ),
    .id_signed_mode_o( id_signed_mode_o )
  );
endmodule

`endif /* COREV_DECODERRTL_NOPARAM */






`ifndef COREV_OPRANDMUXRTL
`define COREV_OPRANDMUXRTL





module cgra_fu_oprand_mux
(
    input logic [1:0]        ex_mult_operator,
    input logic [1:0]        ex_operand_b_sel,
    input logic [1:0]        ex_operand_c_sel,
    input logic              ex_operand_b_repl,
    input logic              ex_operand_c_repl,
    input logic [1:0]          ex_vec_mode,
    input logic [63:0]          ex_operand_b_i,
    input logic [63:0]          ex_operand_c_i,

    input logic          ex_operand_b_pred_i,
    input logic          ex_operand_c_pred_i,

    input logic [31:0]          ex_constant_i,

    output logic [63:0]          ex_operand_b_o,
    output logic [63:0]          ex_operand_c_o,

    output logic          ex_operand_b_pred_o,
    output logic          ex_operand_c_pred_o
);
  localparam VEC_MODE32 = 2'b00;
  localparam VEC_MODE16 = 2'b10;
  localparam VEC_MODE8 = 2'b11;

  localparam MUL_MAC = 2'b00;
  localparam MUL_DOT = 2'b01;
  localparam MUL_CMAC = 2'b10;
  localparam MUL_CDOT = 2'b11;
  
  logic [63:0]          operand_b_mux_o;
  logic [63:0]          operand_c_mux_o;

  logic          operand_b_mux_pred_o;
  logic          operand_c_mux_pred_o;

  always_comb begin : operand_mux_b

    unique case (ex_operand_b_sel)
      2'b00: begin
        operand_b_mux_o = ex_operand_b_i;
        operand_b_mux_pred_o = ex_operand_b_pred_i;
      end
      2'b01: begin
        operand_b_mux_o = {32'b0, ex_constant_i};
        operand_b_mux_pred_o = 1'b1;
      end
      2'b10: begin
        operand_b_mux_o = '0;
        operand_b_mux_pred_o = 1'b1;
      end
      2'b11: begin
        operand_b_mux_o = {48'b0, ex_constant_i[15:0]};
        operand_b_mux_pred_o = 1'b1;
      end
    endcase
  end

  always_comb begin : operand_mux_c
    unique case (ex_operand_c_sel)
      2'b00: begin
        operand_c_mux_o = ex_operand_c_i;
        operand_c_mux_pred_o = ex_operand_c_pred_i;
      end
      2'b01: begin
        operand_c_mux_o = {32'b0, ex_constant_i};
        operand_c_mux_pred_o = 1'b1;
      end
      2'b10: begin
        operand_c_mux_o = '0;
        operand_c_mux_pred_o = 1'b1;
      end
      2'b11: begin
        operand_c_mux_o = {48'b0, ex_constant_i[31:16]};
        operand_c_mux_pred_o = 1'b1;
      end
    endcase
  end

  always_comb begin : operand_repl_b
    ex_operand_b_o = operand_b_mux_o; 
    ex_operand_b_pred_o = operand_b_mux_pred_o;
    if (ex_operand_b_repl) begin
      unique case (ex_vec_mode)
        VEC_MODE8: begin
          ex_operand_b_o = {8{operand_b_mux_o[7:0]}};
        end 
        VEC_MODE16: begin
          ex_operand_b_o = {4{operand_b_mux_o[15:0]}};
        end 
        VEC_MODE32: begin
          ex_operand_b_o = {2{operand_b_mux_o[31:0]}};
        end 
        default: ;
      endcase
    end
  end

  always_comb begin : operand_repl_c
    ex_operand_c_o = operand_c_mux_o; 
    ex_operand_c_pred_o = operand_c_mux_pred_o;
    if (ex_mult_operator == MUL_CDOT) begin
      unique case (ex_operand_c_sel)
        2'b01: begin
          ex_operand_c_o = {16'b0, operand_c_mux_o[31:16], 16'b0, operand_c_mux_o[15:0]};
        end
        2'b11: begin
          ex_operand_c_o = {24'b0, operand_c_mux_o[15:8], 24'b0, operand_c_mux_o[7:0]};
        end
        default: ; 
    endcase
    end
    else if (ex_operand_c_repl) begin
      unique case (ex_vec_mode)
        VEC_MODE8: begin
          ex_operand_c_o = {8{operand_c_mux_o[7:0]}};
        end 
        VEC_MODE16: begin
          ex_operand_c_o = {4{operand_c_mux_o[15:0]}};
        end 
        VEC_MODE32: begin
          ex_operand_c_o = {2{operand_c_mux_o[31:0]}};
        end 
        default: ;
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
  input logic [32-1:0] ex_constant_i ,
  input logic [2-1:0] ex_mult_operator ,
  input logic [64-1:0] ex_operand_b_i ,
  output logic [64-1:0] ex_operand_b_o ,
  input logic [1-1:0] ex_operand_b_pred_i ,
  output logic [1-1:0] ex_operand_b_pred_o ,
  input logic [1-1:0] ex_operand_b_repl ,
  input logic [2-1:0] ex_operand_b_sel ,
  input logic [64-1:0] ex_operand_c_i ,
  output logic [64-1:0] ex_operand_c_o ,
  input logic [1-1:0] ex_operand_c_pred_i ,
  output logic [1-1:0] ex_operand_c_pred_o ,
  input logic [1-1:0] ex_operand_c_repl ,
  input logic [2-1:0] ex_operand_c_sel ,
  input logic [2-1:0] ex_vec_mode 
);
  cgra_fu_oprand_mux
  #(
  ) v
  (
    .ex_constant_i( ex_constant_i ),
    .ex_mult_operator( ex_mult_operator ),
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
    .ex_operand_c_sel( ex_operand_c_sel ),
    .ex_vec_mode( ex_vec_mode )
  );
endmodule

`endif /* COREV_OPRANDMUXRTL_NOPARAM */




module CGRAFURTL__0090f6af61ee96c5
(
  input  logic [5:0] cgra_o_imm_bmask_i ,
  input  logic [1:0] cgra_signed_mode_i ,
  input  logic [1:0] cgra_vec_mode_i ,
  input  logic [0:0] clk ,
  input  logic [0:0] exe_fsafe_en ,
  input  logic [0:0] execution_ini ,
  input  logic [0:0] fu_dry_run_ack ,
  input  logic [0:0] fu_dry_run_done ,
  input  logic [0:0] fu_local_reset_a ,
  input  logic [0:0] fu_local_reset_c ,
  input  logic [0:0] fu_opt_enable ,
  input  logic [0:0] fu_propagate_en ,
  output logic [0:0] fu_propagate_rdy ,
  input  logic [0:0] fu_sync_dry_run ,
  input  logic [31:0] recv_const_data ,
  output logic [0:0] recv_const_rdy ,
  input  logic [127:0] recv_lut_b_data ,
  input  logic [127:0] recv_lut_k_data ,
  input  logic [127:0] recv_lut_p_data ,
  input  logic [9:0] recv_opt_msg_ctrl ,
  input  logic [2:0] recv_opt_msg_fu_in [0:2],
  input  logic [3:0] recv_opt_msg_fu_in_nupd ,
  input  logic [2:0] recv_opt_msg_out_routine ,
  input  logic [0:0] recv_opt_msg_predicate ,
  input  CGRAData_64_1__payload_64__predicate_1 recv_port_data [0:3],
  input  logic [3:0] recv_port_en ,
  output logic [3:0] recv_port_rdy ,
  input  CGRAData_1__predicate_1 recv_predicate_data ,
  input  logic [0:0] recv_predicate_en ,
  output logic [0:0] recv_predicate_rdy ,
  input  logic [0:0] reset ,
  output logic [1:0] send_lut_sel ,
  output CGRAData_64_1__payload_64__predicate_1 send_port_data [0:1],
  output logic [1:0] send_port_en ,
  input  logic [1:0] send_port_rdy 
);
  localparam logic [1:0] __const__num_xbar_outports_at_decode_process  = 2'd3;
  localparam logic [2:0] __const__num_xbar_inports_at_decode_process  = 3'd4;
  localparam logic [1:0] __const__num_xbar_outports_at_opt_propagate  = 2'd3;
  localparam logic [2:0] __const__num_xbar_inports_at_opt_propagate  = 3'd4;
  localparam logic [2:0] __const__num_xbar_inports_at_handshake_process  = 3'd4;
  localparam logic [1:0] __const__num_xbar_outports_at_handshake_process  = 2'd3;
  localparam logic [1:0] __const__fu_list_size_at_handshake_process  = 2'd3;
  localparam logic [1:0] __const__num_outports_at_handshake_process  = 2'd2;
  localparam logic [1:0] __const__num_xbar_outports_at_fu_propagate_sync  = 2'd3;
  localparam logic [1:0] __const__num_xbar_outports_at_data_routing  = 2'd3;
  localparam logic [1:0] __const__num_outports_at_data_routing  = 2'd2;
  localparam logic [2:0] __const__num_xbar_inports_at_data_routing  = 3'd4;
  logic [0:0] ex_alu_enable;
  logic [2:0] ex_alu_ext_mode;
  logic [6:0] ex_alu_operator;
  logic [0:0] ex_lut_enable;
  logic [2:0] ex_lut_k_imm;
  logic [1:0] ex_lut_operator;
  logic [0:0] ex_mult_enable;
  logic [1:0] ex_mult_operator;
  logic [0:0] ex_nah_enable;
  logic [5:0] ex_o_imm_bmask;
  logic [0:0] ex_operand_b_repl;
  logic [1:0] ex_operand_b_sel;
  logic [0:0] ex_operand_c_repl;
  logic [1:0] ex_operand_c_sel;
  logic [0:0] ex_operator_ext_en;
  logic [0:0] ex_round_enable;
  logic [2:0] ex_signed_mode;
  logic [1:0] ex_vec_mode;
  logic [3:0] fu_in_nupd;
  logic [4:0] fu_inport_handshake;
  logic [2:0] fu_launch_handshake;
  logic [2:0] fu_launch_rdy_vector;
  logic [2:0] fu_opt_en_vector;
  logic [2:0] fu_out_routine;
  logic [2:0] fu_pop_rdy_vector;
  logic [2:0] fu_push_en_vector;
  logic [0:0] fu_push_handshake;
  logic [0:0] fu_recv_const_req_nxt;
  logic [1:0] fu_result_handshake;
  logic [0:0] fu_send_out_done;
  logic [0:0] fu_send_out_done_nxt;
  logic [0:0] fu_send_out_handshake;
  logic [2:0] fu_send_port_valid_vector [0:1];
  logic [0:0] fu_xbar_done;
  logic [0:0] fu_xbar_done_nxt;
  logic [0:0] fu_xbar_handshake;
  logic [2:0] fu_xbar_inport_nupd [0:3];
  logic [2:0] fu_xbar_inport_sel [0:3];
  logic [3:0] fu_xbar_outport_sel [0:2];
  logic [3:0] fu_xbar_outport_sel_nxt [0:2];
  logic [4:0] fu_xbar_outport_sel_nxt_decode [0:2];
  logic [0:0] fu_xbar_recv_const_req;
  logic [0:0] fu_xbar_recv_predicate_req;
  CGRAData_64_1__payload_64__predicate_1 fu_xbar_send_data [0:2];
  logic [0:0] lc_downstream_rdy;
  logic [0:0] lc_upstream_en;
  logic [0:0] recv_predicate_req_nxt;
  logic [3:0] xbar_recv_port_nupd;
  logic [3:0] xbar_recv_port_req;

  logic [5:0] fu_0__bmask_b_i;
  logic [0:0] fu_0__clk;
  logic [2:0] fu_0__ex_alu_ext_mode_i;
  logic [2:0] fu_0__ex_operand_signed_i;
  logic [6:0] fu_0__ex_operator_i;
  logic [0:0] fu_0__ex_round_enable_i;
  CGRAData_64_1__payload_64__predicate_1 fu_0__operand_a_i;
  CGRAData_64_1__payload_64__predicate_1 fu_0__operand_b_i;
  CGRAData_64_1__payload_64__predicate_1 fu_0__operand_c_i;
  logic [0:0] fu_0__operator_ext_en_i;
  logic [0:0] fu_0__opt_launch_en_i;
  logic [0:0] fu_0__opt_launch_rdy_o;
  logic [0:0] fu_0__output_rdy_i;
  logic [0:0] fu_0__recv_predicate_en;
  CGRAData_1__predicate_1 fu_0__recv_predicate_msg;
  logic [0:0] fu_0__reset;
  logic [1:0] fu_0__vector_mode_i;
  logic [0:0] fu_0__send_out__en [0:1];
  CGRAData_64_1__payload_64__predicate_1 fu_0__send_out__msg [0:1];
  logic [0:0] fu_0__send_out__rdy [0:1];

  ALURTL__e9baeef75836042d fu_0
  (
    .bmask_b_i( fu_0__bmask_b_i ),
    .clk( fu_0__clk ),
    .ex_alu_ext_mode_i( fu_0__ex_alu_ext_mode_i ),
    .ex_operand_signed_i( fu_0__ex_operand_signed_i ),
    .ex_operator_i( fu_0__ex_operator_i ),
    .ex_round_enable_i( fu_0__ex_round_enable_i ),
    .operand_a_i( fu_0__operand_a_i ),
    .operand_b_i( fu_0__operand_b_i ),
    .operand_c_i( fu_0__operand_c_i ),
    .operator_ext_en_i( fu_0__operator_ext_en_i ),
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
  logic [0:0] fu_1__ex_mul_is_ff_cc_rdy_o;
  logic [2:0] fu_1__ex_operand_signed_i;
  logic [1:0] fu_1__ex_operator_i;
  logic [0:0] fu_1__ex_round_enable_i;
  logic [0:0] fu_1__fu_dry_run_done;
  logic [0:0] fu_1__fu_local_reset_a;
  logic [0:0] fu_1__fu_local_reset_c;
  logic [0:0] fu_1__fu_sync_dry_run;
  logic [5:0] fu_1__o_imm_i;
  CGRAData_64_1__payload_64__predicate_1 fu_1__operand_a_i;
  CGRAData_64_1__payload_64__predicate_1 fu_1__operand_b_i;
  CGRAData_64_1__payload_64__predicate_1 fu_1__operand_c_i;
  logic [0:0] fu_1__operator_ext_en_i;
  logic [0:0] fu_1__opt_launch_en_i;
  logic [0:0] fu_1__opt_launch_rdy_o;
  logic [0:0] fu_1__output_rdy_i;
  logic [0:0] fu_1__recv_predicate_en;
  CGRAData_1__predicate_1 fu_1__recv_predicate_msg;
  logic [0:0] fu_1__reset;
  logic [1:0] fu_1__vector_mode_i;
  logic [0:0] fu_1__send_out__en [0:1];
  CGRAData_64_1__payload_64__predicate_1 fu_1__send_out__msg [0:1];
  logic [0:0] fu_1__send_out__rdy [0:1];

  MULRTL__e9baeef75836042d fu_1
  (
    .clk( fu_1__clk ),
    .ex_mul_is_ff_cc_rdy_o( fu_1__ex_mul_is_ff_cc_rdy_o ),
    .ex_operand_signed_i( fu_1__ex_operand_signed_i ),
    .ex_operator_i( fu_1__ex_operator_i ),
    .ex_round_enable_i( fu_1__ex_round_enable_i ),
    .fu_dry_run_done( fu_1__fu_dry_run_done ),
    .fu_local_reset_a( fu_1__fu_local_reset_a ),
    .fu_local_reset_c( fu_1__fu_local_reset_c ),
    .fu_sync_dry_run( fu_1__fu_sync_dry_run ),
    .o_imm_i( fu_1__o_imm_i ),
    .operand_a_i( fu_1__operand_a_i ),
    .operand_b_i( fu_1__operand_b_i ),
    .operand_c_i( fu_1__operand_c_i ),
    .operator_ext_en_i( fu_1__operator_ext_en_i ),
    .opt_launch_en_i( fu_1__opt_launch_en_i ),
    .opt_launch_rdy_o( fu_1__opt_launch_rdy_o ),
    .output_rdy_i( fu_1__output_rdy_i ),
    .recv_predicate_en( fu_1__recv_predicate_en ),
    .recv_predicate_msg( fu_1__recv_predicate_msg ),
    .reset( fu_1__reset ),
    .vector_mode_i( fu_1__vector_mode_i ),
    .send_out__en( fu_1__send_out__en ),
    .send_out__msg( fu_1__send_out__msg ),
    .send_out__rdy( fu_1__send_out__rdy )
  );



  logic [0:0] fu_2__clk;
  logic [1:0] fu_2__ex_operand_signed_i;
  logic [1:0] fu_2__ex_operator_i;
  logic [0:0] fu_2__fu_dry_run_done;
  logic [0:0] fu_2__fu_local_reset_a;
  logic [0:0] fu_2__fu_local_reset_c;
  logic [0:0] fu_2__fu_sync_dry_run;
  logic [2:0] fu_2__k_imm_i;
  logic [127:0] fu_2__lut_b_i;
  logic [127:0] fu_2__lut_k_i;
  logic [127:0] fu_2__lut_p_i;
  logic [1:0] fu_2__lut_sel_o;
  logic [5:0] fu_2__o_imm_i;
  CGRAData_64_1__payload_64__predicate_1 fu_2__operand_a_i;
  logic [0:0] fu_2__operator_ext_en_i;
  logic [0:0] fu_2__opt_launch_en_i;
  logic [0:0] fu_2__opt_launch_rdy_o;
  logic [0:0] fu_2__output_rdy_i;
  logic [0:0] fu_2__recv_predicate_en;
  CGRAData_1__predicate_1 fu_2__recv_predicate_msg;
  logic [0:0] fu_2__reset;
  logic [1:0] fu_2__vector_mode_i;
  logic [0:0] fu_2__send_out__en [0:1];
  CGRAData_64_1__payload_64__predicate_1 fu_2__send_out__msg [0:1];
  logic [0:0] fu_2__send_out__rdy [0:1];

  LUTRTL__e9baeef75836042d fu_2
  (
    .clk( fu_2__clk ),
    .ex_operand_signed_i( fu_2__ex_operand_signed_i ),
    .ex_operator_i( fu_2__ex_operator_i ),
    .fu_dry_run_done( fu_2__fu_dry_run_done ),
    .fu_local_reset_a( fu_2__fu_local_reset_a ),
    .fu_local_reset_c( fu_2__fu_local_reset_c ),
    .fu_sync_dry_run( fu_2__fu_sync_dry_run ),
    .k_imm_i( fu_2__k_imm_i ),
    .lut_b_i( fu_2__lut_b_i ),
    .lut_k_i( fu_2__lut_k_i ),
    .lut_p_i( fu_2__lut_p_i ),
    .lut_sel_o( fu_2__lut_sel_o ),
    .o_imm_i( fu_2__o_imm_i ),
    .operand_a_i( fu_2__operand_a_i ),
    .operator_ext_en_i( fu_2__operator_ext_en_i ),
    .opt_launch_en_i( fu_2__opt_launch_en_i ),
    .opt_launch_rdy_o( fu_2__opt_launch_rdy_o ),
    .output_rdy_i( fu_2__output_rdy_i ),
    .recv_predicate_en( fu_2__recv_predicate_en ),
    .recv_predicate_msg( fu_2__recv_predicate_msg ),
    .reset( fu_2__reset ),
    .vector_mode_i( fu_2__vector_mode_i ),
    .send_out__en( fu_2__send_out__en ),
    .send_out__msg( fu_2__send_out__msg ),
    .send_out__rdy( fu_2__send_out__rdy )
  );



  logic [1:0] fu_decoder_cgra_signed_mode_i;
  logic [1:0] fu_decoder_cgra_vec_mode_i;
  logic [0:0] fu_decoder_clk;
  logic [0:0] fu_decoder_id_alu_enable_o;
  logic [2:0] fu_decoder_id_alu_ext_mode_o;
  logic [6:0] fu_decoder_id_alu_operator_o;
  logic [0:0] fu_decoder_id_const_enable_o;
  logic [0:0] fu_decoder_id_lut_enable_o;
  logic [2:0] fu_decoder_id_lut_k_imm_o;
  logic [1:0] fu_decoder_id_lut_operator_o;
  logic [0:0] fu_decoder_id_mult_enable_o;
  logic [1:0] fu_decoder_id_mult_operator_o;
  logic [0:0] fu_decoder_id_nah_opt_o;
  logic [0:0] fu_decoder_id_operand_b_repl_o;
  logic [1:0] fu_decoder_id_operand_b_sel_o;
  logic [0:0] fu_decoder_id_operand_c_repl_o;
  logic [1:0] fu_decoder_id_operand_c_sel_o;
  logic [9:0] fu_decoder_id_operator_i;
  logic [0:0] fu_decoder_id_round_enable_o;
  logic [2:0] fu_decoder_id_signed_mode_o;
  logic [0:0] fu_decoder_reset;

  CoreV_DecoderRTL_noparam fu_decoder
  (
    .cgra_signed_mode_i( fu_decoder_cgra_signed_mode_i ),
    .cgra_vec_mode_i( fu_decoder_cgra_vec_mode_i ),
    .clk( fu_decoder_clk ),
    .id_alu_enable_o( fu_decoder_id_alu_enable_o ),
    .id_alu_ext_mode_o( fu_decoder_id_alu_ext_mode_o ),
    .id_alu_operator_o( fu_decoder_id_alu_operator_o ),
    .id_const_enable_o( fu_decoder_id_const_enable_o ),
    .id_lut_enable_o( fu_decoder_id_lut_enable_o ),
    .id_lut_k_imm_o( fu_decoder_id_lut_k_imm_o ),
    .id_lut_operator_o( fu_decoder_id_lut_operator_o ),
    .id_mult_enable_o( fu_decoder_id_mult_enable_o ),
    .id_mult_operator_o( fu_decoder_id_mult_operator_o ),
    .id_nah_opt_o( fu_decoder_id_nah_opt_o ),
    .id_operand_b_repl_o( fu_decoder_id_operand_b_repl_o ),
    .id_operand_b_sel_o( fu_decoder_id_operand_b_sel_o ),
    .id_operand_c_repl_o( fu_decoder_id_operand_c_repl_o ),
    .id_operand_c_sel_o( fu_decoder_id_operand_c_sel_o ),
    .id_operator_i( fu_decoder_id_operator_i ),
    .id_round_enable_o( fu_decoder_id_round_enable_o ),
    .id_signed_mode_o( fu_decoder_id_signed_mode_o ),
    .reset( fu_decoder_reset )
  );



  logic [0:0] fu_operand_mux_clk;
  logic [31:0] fu_operand_mux_ex_constant_i;
  logic [1:0] fu_operand_mux_ex_mult_operator;
  logic [63:0] fu_operand_mux_ex_operand_b_i;
  logic [63:0] fu_operand_mux_ex_operand_b_o;
  logic [0:0] fu_operand_mux_ex_operand_b_pred_i;
  logic [0:0] fu_operand_mux_ex_operand_b_pred_o;
  logic [0:0] fu_operand_mux_ex_operand_b_repl;
  logic [1:0] fu_operand_mux_ex_operand_b_sel;
  logic [63:0] fu_operand_mux_ex_operand_c_i;
  logic [63:0] fu_operand_mux_ex_operand_c_o;
  logic [0:0] fu_operand_mux_ex_operand_c_pred_i;
  logic [0:0] fu_operand_mux_ex_operand_c_pred_o;
  logic [0:0] fu_operand_mux_ex_operand_c_repl;
  logic [1:0] fu_operand_mux_ex_operand_c_sel;
  logic [1:0] fu_operand_mux_ex_vec_mode;
  logic [0:0] fu_operand_mux_reset;

  CoreV_OprandMuxRTL_noparam fu_operand_mux
  (
    .clk( fu_operand_mux_clk ),
    .ex_constant_i( fu_operand_mux_ex_constant_i ),
    .ex_mult_operator( fu_operand_mux_ex_mult_operator ),
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
    .ex_vec_mode( fu_operand_mux_ex_vec_mode ),
    .reset( fu_operand_mux_reset )
  );


  
  always_comb begin : _lambda__s_tile_0__element_fu_decoder_id_operator_i
    fu_decoder_id_operator_i = recv_opt_msg_ctrl & { { 9 { fu_opt_enable[0] } }, fu_opt_enable };
  end

  
  always_comb begin : data_routing
    for ( int unsigned i = 1'd0; i < 2'( __const__num_xbar_outports_at_data_routing ); i += 1'd1 )
      fu_xbar_send_data[2'(i)] = { 64'd0, 1'd0 };
    for ( int unsigned i = 1'd0; i < 2'( __const__num_outports_at_data_routing ); i += 1'd1 )
      send_port_data[1'(i)] = { 64'd0, 1'd0 };
    for ( int unsigned i = 1'd0; i < 2'( __const__num_xbar_outports_at_data_routing ); i += 1'd1 )
      for ( int unsigned j = 1'd0; j < 3'( __const__num_xbar_inports_at_data_routing ); j += 1'd1 ) begin
        fu_xbar_send_data[2'(i)].payload = fu_xbar_send_data[2'(i)].payload | ( recv_port_data[2'(j)].payload & { { 63 { fu_xbar_outport_sel[2'(i)][2'(j)] } }, fu_xbar_outport_sel[2'(i)][2'(j)] } );
        fu_xbar_send_data[2'(i)].predicate = fu_xbar_send_data[2'(i)].predicate | ( recv_port_data[2'(j)].predicate & fu_xbar_outport_sel[2'(i)][2'(j)] );
      end
    for ( int unsigned i = 1'd0; i < 2'( __const__num_outports_at_data_routing ); i += 1'd1 ) begin
      send_port_data[1'(i)].payload = ( ( send_port_data[1'(i)].payload | ( fu_0__send_out__msg[1'(i)].payload & { { 63 { fu_send_port_valid_vector[1'(i)][2'd0] } }, fu_send_port_valid_vector[1'(i)][2'd0] } ) ) | ( fu_1__send_out__msg[1'(i)].payload & { { 63 { fu_send_port_valid_vector[1'(i)][2'd1] } }, fu_send_port_valid_vector[1'(i)][2'd1] } ) ) | ( fu_2__send_out__msg[1'(i)].payload & { { 63 { fu_send_port_valid_vector[1'(i)][2'd2] } }, fu_send_port_valid_vector[1'(i)][2'd2] } );
      send_port_data[1'(i)].predicate = ( ( send_port_data[1'(i)].predicate | ( fu_0__send_out__msg[1'(i)].predicate & fu_send_port_valid_vector[1'(i)][2'd0] ) ) | ( fu_1__send_out__msg[1'(i)].predicate & fu_send_port_valid_vector[1'(i)][2'd1] ) ) | ( fu_2__send_out__msg[1'(i)].predicate & fu_send_port_valid_vector[1'(i)][2'd2] );
    end
  end

  
  always_comb begin : decode_process
    for ( int unsigned i = 1'd0; i < 2'( __const__num_xbar_outports_at_decode_process ); i += 1'd1 ) begin
      fu_xbar_outport_sel_nxt_decode[2'(i)] = 5'd0;
      fu_xbar_outport_sel_nxt[2'(i)] = 4'd0;
    end
    recv_predicate_req_nxt = 1'd0;
    if ( fu_opt_enable ) begin
      for ( int unsigned i = 1'd0; i < 2'( __const__num_xbar_outports_at_decode_process ); i += 1'd1 )
        if ( recv_opt_msg_fu_in[2'(i)] != 3'd0 ) begin
          fu_xbar_outport_sel_nxt_decode[2'(i)][recv_opt_msg_fu_in[2'(i)]] = 1'd1;
        end
      for ( int unsigned i = 1'd0; i < 2'( __const__num_xbar_outports_at_decode_process ); i += 1'd1 )
        fu_xbar_outport_sel_nxt[2'(i)] = fu_xbar_outport_sel_nxt_decode[2'(i)][3'd4:3'd1];
      if ( recv_opt_msg_predicate == 1'd1 ) begin
        recv_predicate_req_nxt = 1'd1;
      end
    end
  end

  
  always_comb begin : handshake_process
    for ( int unsigned i = 1'd0; i < 3'( __const__num_xbar_inports_at_handshake_process ); i += 1'd1 ) begin
      for ( int unsigned j = 1'd0; j < 2'( __const__num_xbar_outports_at_handshake_process ); j += 1'd1 )
        fu_xbar_inport_nupd[2'(i)][2'(j)] = fu_xbar_inport_sel[2'(i)][2'(j)] & fu_in_nupd[2'(j)];
      xbar_recv_port_req[2'(i)] = ( | fu_xbar_inport_sel[2'(i)] );
      xbar_recv_port_nupd[2'(i)] = ( | fu_xbar_inport_nupd[2'(i)] );
    end
    for ( int unsigned i = 1'd0; i < 3'( __const__num_xbar_inports_at_handshake_process ); i += 1'd1 )
      fu_inport_handshake[3'(i)] = xbar_recv_port_req[2'(i)] & ( ~recv_port_en[2'(i)] );
    fu_inport_handshake[3'( __const__num_xbar_inports_at_handshake_process )] = fu_xbar_recv_predicate_req & ( ~recv_predicate_en );
    for ( int unsigned i = 1'd0; i < 2'( __const__fu_list_size_at_handshake_process ); i += 1'd1 )
      fu_launch_handshake[2'(i)] = fu_opt_en_vector[2'(i)] & ( ~fu_launch_rdy_vector[2'(i)] );
    lc_downstream_rdy = ( ~( | fu_launch_handshake ) ) | ex_nah_enable;
    lc_upstream_en = ~( | fu_inport_handshake );
    fu_xbar_handshake = ( lc_downstream_rdy & ( lc_upstream_en | exe_fsafe_en ) ) & ( ~fu_xbar_done );
    fu_push_handshake = ( lc_upstream_en | exe_fsafe_en ) & ( ~fu_xbar_done );
    for ( int unsigned i = 1'd0; i < 2'( __const__fu_list_size_at_handshake_process ); i += 1'd1 )
      fu_push_en_vector[2'(i)] = fu_opt_en_vector[2'(i)] & fu_push_handshake;
    for ( int unsigned i = 1'd0; i < 3'( __const__num_xbar_inports_at_handshake_process ); i += 1'd1 )
      recv_port_rdy[2'(i)] = ( xbar_recv_port_req[2'(i)] & fu_xbar_handshake ) & ( ~xbar_recv_port_nupd[2'(i)] );
    recv_predicate_rdy = ( fu_xbar_recv_predicate_req & fu_xbar_handshake ) & ( ~( | fu_in_nupd ) );
    recv_const_rdy = ( fu_xbar_recv_const_req & fu_xbar_handshake ) & ( ~fu_in_nupd[2'( __const__num_xbar_outports_at_handshake_process )] );
    for ( int unsigned port = 1'd0; port < 2'( __const__num_outports_at_handshake_process ); port += 1'd1 ) begin
      fu_send_port_valid_vector[1'(port)][2'd0] = fu_0__send_out__en[1'(port)] & fu_out_routine[2'd0];
      fu_send_port_valid_vector[1'(port)][2'd1] = fu_1__send_out__en[1'(port)] & fu_out_routine[2'd1];
      fu_send_port_valid_vector[1'(port)][2'd2] = fu_2__send_out__en[1'(port)] & fu_out_routine[2'd2];
    end
    for ( int unsigned i = 1'd0; i < 2'( __const__num_outports_at_handshake_process ); i += 1'd1 )
      send_port_en[1'(i)] = ( ( | fu_send_port_valid_vector[1'(i)] ) | fu_dry_run_ack ) & ( ~fu_send_out_done );
    for ( int unsigned i = 1'd0; i < 2'( __const__num_outports_at_handshake_process ); i += 1'd1 )
      fu_result_handshake[1'(i)] = ( send_port_rdy[1'(i)] | exe_fsafe_en ) & ( ~send_port_en[1'(i)] );
    fu_send_out_handshake = ~( | fu_result_handshake );
    for ( int unsigned i = 1'd0; i < 2'( __const__fu_list_size_at_handshake_process ); i += 1'd1 )
      fu_pop_rdy_vector[2'(i)] = ( fu_send_out_handshake & fu_out_routine[2'(i)] ) & ( ~fu_send_out_done );
    fu_xbar_done_nxt = fu_xbar_handshake | fu_xbar_done;
    fu_send_out_done_nxt = fu_send_out_handshake | fu_send_out_done;
    fu_propagate_rdy = fu_xbar_done_nxt & fu_send_out_done_nxt;
  end

  
  always_comb begin : opt_propagate
    for ( int unsigned i = 1'd0; i < 2'( __const__num_xbar_outports_at_opt_propagate ); i += 1'd1 )
      for ( int unsigned j = 1'd0; j < 3'( __const__num_xbar_inports_at_opt_propagate ); j += 1'd1 )
        fu_xbar_inport_sel[2'(j)][2'(i)] = fu_xbar_outport_sel[2'(i)][2'(j)];
  end

  
  always_ff @(posedge clk) begin : fsm_update
    if ( reset ) begin
      fu_xbar_done <= 1'd0;
      fu_send_out_done <= 1'd0;
    end
    else if ( fu_propagate_en ) begin
      fu_xbar_done <= 1'd0;
      fu_send_out_done <= 1'd0;
    end
    else begin
      fu_xbar_done <= fu_xbar_done_nxt;
      fu_send_out_done <= fu_send_out_done_nxt;
    end
  end

  
  always_ff @(posedge clk) begin : fu_propagate_sync
    if ( ( reset | fu_local_reset_a ) | execution_ini ) begin
      fu_xbar_recv_const_req <= 1'd0;
      fu_xbar_recv_predicate_req <= 1'd0;
      for ( int unsigned i = 1'd0; i < 2'( __const__num_xbar_outports_at_fu_propagate_sync ); i += 1'd1 )
        fu_xbar_outport_sel[2'(i)] <= 4'd0;
      fu_out_routine <= 3'd0;
      fu_in_nupd <= 4'd0;
      ex_alu_ext_mode <= 3'd0;
      ex_alu_operator <= 7'd0;
      ex_alu_enable <= 1'd0;
      ex_operand_b_sel <= 2'd0;
      ex_operand_c_sel <= 2'd0;
      ex_operand_b_repl <= 1'd0;
      ex_operand_c_repl <= 1'd0;
      ex_mult_operator <= 2'd0;
      ex_mult_enable <= 1'd0;
      ex_round_enable <= 1'd0;
      ex_lut_operator <= 2'd0;
      ex_lut_enable <= 1'd0;
      ex_lut_k_imm <= 3'd0;
      ex_nah_enable <= 1'd0;
      ex_o_imm_bmask <= 6'd0;
      ex_signed_mode <= 3'd0;
      ex_vec_mode <= 2'd0;
      ex_operator_ext_en <= 1'd0;
    end
    else if ( fu_propagate_en ) begin
      for ( int unsigned i = 1'd0; i < 2'( __const__num_xbar_outports_at_fu_propagate_sync ); i += 1'd1 )
        fu_xbar_outport_sel[2'(i)] <= fu_xbar_outport_sel_nxt[2'(i)];
      fu_xbar_recv_const_req <= fu_recv_const_req_nxt;
      fu_xbar_recv_predicate_req <= recv_predicate_req_nxt;
      fu_out_routine <= recv_opt_msg_out_routine;
      fu_in_nupd <= recv_opt_msg_fu_in_nupd;
      ex_alu_ext_mode <= fu_decoder_id_alu_ext_mode_o;
      ex_alu_operator <= fu_decoder_id_alu_operator_o;
      ex_alu_enable <= fu_decoder_id_alu_enable_o;
      ex_operand_b_sel <= fu_decoder_id_operand_b_sel_o;
      ex_operand_c_sel <= fu_decoder_id_operand_c_sel_o;
      ex_operand_b_repl <= fu_decoder_id_operand_b_repl_o;
      ex_operand_c_repl <= fu_decoder_id_operand_c_repl_o;
      ex_mult_operator <= fu_decoder_id_mult_operator_o;
      ex_mult_enable <= fu_decoder_id_mult_enable_o;
      ex_lut_operator <= fu_decoder_id_lut_operator_o;
      ex_lut_enable <= fu_decoder_id_lut_enable_o;
      ex_lut_k_imm <= fu_decoder_id_lut_k_imm_o;
      ex_nah_enable <= fu_decoder_id_nah_opt_o;
      ex_o_imm_bmask <= cgra_o_imm_bmask_i;
      ex_signed_mode <= fu_decoder_id_signed_mode_o;
      ex_vec_mode <= cgra_vec_mode_i;
      ex_round_enable <= fu_decoder_id_round_enable_o;
      ex_operator_ext_en <= recv_opt_msg_ctrl[4'd8];
    end
  end

  assign fu_decoder_clk = clk;
  assign fu_decoder_reset = reset;
  assign fu_operand_mux_clk = clk;
  assign fu_operand_mux_reset = reset;
  assign fu_0__clk = clk;
  assign fu_0__reset = reset;
  assign fu_1__clk = clk;
  assign fu_1__reset = reset;
  assign fu_2__clk = clk;
  assign fu_2__reset = reset;
  assign fu_launch_rdy_vector[0:0] = fu_0__opt_launch_rdy_o;
  assign fu_launch_rdy_vector[1:1] = fu_1__opt_launch_rdy_o;
  assign fu_launch_rdy_vector[2:2] = fu_2__opt_launch_rdy_o;
  assign fu_opt_en_vector[0:0] = ex_alu_enable;
  assign fu_opt_en_vector[1:1] = ex_mult_enable;
  assign fu_opt_en_vector[2:2] = ex_lut_enable;
  assign fu_decoder_cgra_vec_mode_i = cgra_vec_mode_i;
  assign fu_decoder_cgra_signed_mode_i = cgra_signed_mode_i;
  assign fu_recv_const_req_nxt = fu_decoder_id_const_enable_o;
  assign fu_operand_mux_ex_vec_mode = ex_vec_mode;
  assign fu_operand_mux_ex_mult_operator = ex_mult_operator;
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
  assign fu_0__opt_launch_en_i = fu_push_en_vector[0:0];
  assign fu_0__vector_mode_i = ex_vec_mode;
  assign fu_0__output_rdy_i = fu_pop_rdy_vector[0:0];
  assign fu_1__recv_predicate_msg = recv_predicate_data;
  assign fu_1__recv_predicate_en = fu_xbar_recv_predicate_req;
  assign fu_1__opt_launch_en_i = fu_push_en_vector[1:1];
  assign fu_1__vector_mode_i = ex_vec_mode;
  assign fu_1__output_rdy_i = fu_pop_rdy_vector[1:1];
  assign fu_2__recv_predicate_msg = recv_predicate_data;
  assign fu_2__recv_predicate_en = fu_xbar_recv_predicate_req;
  assign fu_2__opt_launch_en_i = fu_push_en_vector[2:2];
  assign fu_2__vector_mode_i = ex_vec_mode;
  assign fu_2__output_rdy_i = fu_pop_rdy_vector[2:2];
  assign fu_0__ex_alu_ext_mode_i = ex_alu_ext_mode;
  assign fu_0__ex_operator_i = ex_alu_operator;
  assign fu_0__ex_operand_signed_i = ex_signed_mode;
  assign fu_0__ex_round_enable_i = ex_round_enable;
  assign fu_0__operand_a_i = fu_xbar_send_data[0];
  assign fu_0__operand_b_i.payload = fu_operand_mux_ex_operand_b_o;
  assign fu_0__operand_b_i.predicate = fu_operand_mux_ex_operand_b_pred_o;
  assign fu_0__operand_c_i.payload = fu_operand_mux_ex_operand_c_o;
  assign fu_0__operand_c_i.predicate = fu_operand_mux_ex_operand_c_pred_o;
  assign fu_0__bmask_b_i = ex_o_imm_bmask;
  assign fu_0__operator_ext_en_i = ex_operator_ext_en;
  assign fu_1__fu_local_reset_c = fu_local_reset_c;
  assign fu_1__fu_local_reset_a = fu_local_reset_a;
  assign fu_1__fu_dry_run_done = fu_dry_run_done;
  assign fu_1__fu_sync_dry_run = fu_sync_dry_run;
  assign fu_1__ex_operator_i = ex_mult_operator;
  assign fu_1__ex_operand_signed_i = ex_signed_mode;
  assign fu_1__ex_round_enable_i = ex_round_enable;
  assign fu_1__o_imm_i = ex_o_imm_bmask;
  assign fu_1__operand_a_i = fu_xbar_send_data[0];
  assign fu_1__operand_b_i.payload = fu_operand_mux_ex_operand_b_o;
  assign fu_1__operand_b_i.predicate = fu_operand_mux_ex_operand_b_pred_o;
  assign fu_1__operand_c_i.payload = fu_operand_mux_ex_operand_c_o;
  assign fu_1__operand_c_i.predicate = fu_operand_mux_ex_operand_c_pred_o;
  assign fu_1__operator_ext_en_i = ex_operator_ext_en;
  assign fu_2__fu_local_reset_c = fu_local_reset_c;
  assign fu_2__fu_local_reset_a = fu_local_reset_a;
  assign fu_2__fu_dry_run_done = fu_dry_run_done;
  assign fu_2__fu_sync_dry_run = fu_sync_dry_run;
  assign fu_2__ex_operator_i = ex_lut_operator;
  assign fu_2__ex_operand_signed_i = ex_signed_mode[1:0];
  assign fu_2__operator_ext_en_i = ex_operator_ext_en;
  assign fu_2__operand_a_i = fu_xbar_send_data[0];
  assign fu_2__o_imm_i = ex_o_imm_bmask;
  assign fu_2__k_imm_i = ex_lut_k_imm;
  assign fu_2__lut_k_i = recv_lut_k_data;
  assign fu_2__lut_b_i = recv_lut_b_data;
  assign fu_2__lut_p_i = recv_lut_p_data;
  assign send_lut_sel = fu_2__lut_sel_o;

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



module NormalQueueDpath__2b0cbb41a869ddc6
(
  input  logic [0:0] clk ,
  output CGRAData_1__predicate_1 deq_msg ,
  input  CGRAData_1__predicate_1 enq_msg ,
  input  logic [0:0] local_reset_data ,
  input  logic [1:0] raddr ,
  input  logic [0:0] ren ,
  input  logic [0:0] reset ,
  input  logic [1:0] waddr ,
  input  logic [0:0] wen 
);
  localparam CGRAData_1__predicate_1 default_value  = { 1'd1 };
  localparam logic [2:0] __const__num_entries_at_up_rf_write  = 3'd4;
  CGRAData_1__predicate_1 regs [0:3];
  CGRAData_1__predicate_1 regs_rdata;

  
  always_comb begin : _lambda__s_tile_0__reg_predicate_queue_dpath_deq_msg
    deq_msg = regs[raddr];
  end

  
  always_ff @(posedge clk) begin : up_rf_write
    if ( reset | local_reset_data ) begin
      for ( int unsigned i = 1'd0; i < 3'( __const__num_entries_at_up_rf_write ); i += 1'd1 )
        regs[2'(i)] <= default_value;
    end
    else if ( wen ) begin
      regs[waddr] <= enq_msg;
    end
  end

endmodule



module NormalQueue__fa01e9285553b23f
(
  input  logic [0:0] clk ,
  input  logic [0:0] dry_run_ack ,
  input  logic [0:0] dry_run_done ,
  input  logic [0:0] local_reset_b ,
  input  logic [0:0] local_reset_c ,
  input  logic [0:0] recv_en_i ,
  input  CGRAData_1__predicate_1 recv_msg ,
  output logic [0:0] recv_rdy_o ,
  input  logic [0:0] reset ,
  input  logic [0:0] send_en_i ,
  output CGRAData_1__predicate_1 send_msg ,
  output logic [0:0] send_valid_o ,
  input  logic [0:0] sync_dry_run 
);

  logic [0:0] ctrl__clk;
  logic [0:0] ctrl__dry_run_ack;
  logic [0:0] ctrl__dry_run_done;
  logic [0:0] ctrl__local_reset_ctrl;
  logic [0:0] ctrl__local_reset_stage;
  logic [1:0] ctrl__raddr;
  logic [0:0] ctrl__recv_en_i;
  logic [0:0] ctrl__recv_rdy_o;
  logic [0:0] ctrl__ren;
  logic [0:0] ctrl__reset;
  logic [0:0] ctrl__send_en_i;
  logic [0:0] ctrl__send_valid_o;
  logic [0:0] ctrl__sync_dry_run;
  logic [1:0] ctrl__waddr;
  logic [0:0] ctrl__wen;

  NormalQueueCtrl__num_entries_4__dry_run_enable_True ctrl
  (
    .clk( ctrl__clk ),
    .dry_run_ack( ctrl__dry_run_ack ),
    .dry_run_done( ctrl__dry_run_done ),
    .local_reset_ctrl( ctrl__local_reset_ctrl ),
    .local_reset_stage( ctrl__local_reset_stage ),
    .raddr( ctrl__raddr ),
    .recv_en_i( ctrl__recv_en_i ),
    .recv_rdy_o( ctrl__recv_rdy_o ),
    .ren( ctrl__ren ),
    .reset( ctrl__reset ),
    .send_en_i( ctrl__send_en_i ),
    .send_valid_o( ctrl__send_valid_o ),
    .sync_dry_run( ctrl__sync_dry_run ),
    .waddr( ctrl__waddr ),
    .wen( ctrl__wen )
  );



  logic [0:0] dpath__clk;
  CGRAData_1__predicate_1 dpath__deq_msg;
  CGRAData_1__predicate_1 dpath__enq_msg;
  logic [0:0] dpath__local_reset_data;
  logic [1:0] dpath__raddr;
  logic [0:0] dpath__ren;
  logic [0:0] dpath__reset;
  logic [1:0] dpath__waddr;
  logic [0:0] dpath__wen;

  NormalQueueDpath__2b0cbb41a869ddc6 dpath
  (
    .clk( dpath__clk ),
    .deq_msg( dpath__deq_msg ),
    .enq_msg( dpath__enq_msg ),
    .local_reset_data( dpath__local_reset_data ),
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
  assign dpath__local_reset_data = local_reset_b;
  assign ctrl__local_reset_stage = local_reset_b;
  assign ctrl__local_reset_ctrl = local_reset_c;
  assign ctrl__dry_run_ack = dry_run_ack;
  assign ctrl__dry_run_done = dry_run_done;
  assign ctrl__sync_dry_run = sync_dry_run;
  assign dpath__wen = ctrl__wen;
  assign dpath__ren = ctrl__ren;
  assign dpath__waddr = ctrl__waddr;
  assign dpath__raddr = ctrl__raddr;
  assign ctrl__recv_en_i = recv_en_i;
  assign recv_rdy_o = ctrl__recv_rdy_o;
  assign ctrl__send_en_i = send_en_i;
  assign send_valid_o = ctrl__send_valid_o;
  assign dpath__enq_msg = recv_msg;
  assign send_msg = dpath__deq_msg;

endmodule



module ChannelRTL__7cdc7a9725e49c50
(
  input  logic [0:0] clk ,
  input  logic [0:0] dry_run_ack ,
  input  logic [0:0] dry_run_done ,
  input  logic [0:0] local_reset_b ,
  input  logic [0:0] local_reset_c ,
  input  logic [0:0] recv_en_i ,
  input  CGRAData_1__predicate_1 recv_msg ,
  output logic [0:0] recv_rdy_o ,
  input  logic [0:0] reset ,
  input  logic [0:0] send_en_i ,
  output CGRAData_1__predicate_1 send_msg ,
  output logic [0:0] send_valid_o ,
  input  logic [0:0] sync_dry_run 
);

  logic [0:0] queue__clk;
  logic [0:0] queue__dry_run_ack;
  logic [0:0] queue__dry_run_done;
  logic [0:0] queue__local_reset_b;
  logic [0:0] queue__local_reset_c;
  logic [0:0] queue__recv_en_i;
  CGRAData_1__predicate_1 queue__recv_msg;
  logic [0:0] queue__recv_rdy_o;
  logic [0:0] queue__reset;
  logic [0:0] queue__send_en_i;
  CGRAData_1__predicate_1 queue__send_msg;
  logic [0:0] queue__send_valid_o;
  logic [0:0] queue__sync_dry_run;

  NormalQueue__fa01e9285553b23f queue
  (
    .clk( queue__clk ),
    .dry_run_ack( queue__dry_run_ack ),
    .dry_run_done( queue__dry_run_done ),
    .local_reset_b( queue__local_reset_b ),
    .local_reset_c( queue__local_reset_c ),
    .recv_en_i( queue__recv_en_i ),
    .recv_msg( queue__recv_msg ),
    .recv_rdy_o( queue__recv_rdy_o ),
    .reset( queue__reset ),
    .send_en_i( queue__send_en_i ),
    .send_msg( queue__send_msg ),
    .send_valid_o( queue__send_valid_o ),
    .sync_dry_run( queue__sync_dry_run )
  );


  assign queue__clk = clk;
  assign queue__reset = reset;
  assign queue__recv_en_i = recv_en_i;
  assign queue__recv_msg = recv_msg;
  assign recv_rdy_o = queue__recv_rdy_o;
  assign queue__send_en_i = send_en_i;
  assign send_msg = queue__send_msg;
  assign send_valid_o = queue__send_valid_o;
  assign queue__local_reset_b = local_reset_b;
  assign queue__local_reset_c = local_reset_c;
  assign queue__dry_run_ack = dry_run_ack;
  assign queue__dry_run_done = dry_run_done;
  assign queue__sync_dry_run = sync_dry_run;

endmodule



module Mux__Type_CGRAConfig_10_3_6_8_3__877613aa0dfe8ae0__ninputs_2
(
  input  logic [0:0] clk ,
  input  CGRAConfig_10_3_6_8_3__877613aa0dfe8ae0 in_ [0:1],
  output CGRAConfig_10_3_6_8_3__877613aa0dfe8ae0 out ,
  input  logic [0:0] reset ,
  input  logic [0:0] sel 
);

  
  always_comb begin : up_mux
    out = in_[sel];
  end

endmodule



module TileRTL__ea67303889430dc3
(
  input  logic [0:0] clk ,
  input  logic [4:0] config_cmd_counter_base ,
  input  logic [4:0] config_cmd_counter_th ,
  input  logic [31:0] config_cmd_iter_counter_th ,
  input  logic [4:0] config_data_counter_base ,
  input  logic [4:0] config_data_counter_th ,
  input  logic [0:0] ctrl_slice_idx ,
  input  logic [31:0] recv_const ,
  input  logic [0:0] recv_const_en ,
  input  logic [3:0] recv_const_waddr ,
  input  CGRAData_64_1__payload_64__predicate_1 recv_data [0:3],
  output logic [0:0] recv_data_ack [0:3],
  input  logic [0:0] recv_data_valid [0:3],
  input  logic [127:0] recv_lut_b ,
  input  logic [127:0] recv_lut_k ,
  input  logic [127:0] recv_lut_p ,
  input  logic [3:0] recv_opt_waddr ,
  input  logic [0:0] recv_opt_waddr_en ,
  input  logic [31:0] recv_wopt ,
  input  logic [0:0] recv_wopt_en ,
  input  logic [0:0] reset ,
  output CGRAData_64_1__payload_64__predicate_1 send_data [0:3],
  input  logic [0:0] send_data_ack [0:3],
  output logic [0:0] send_data_valid [0:3],
  output logic [1:0] send_lut_sel ,
  input  logic [0:0] tile_cmd_el_mode_en ,
  input  logic [0:0] tile_config_ini_begin ,
  input  logic [0:0] tile_dry_run_ack ,
  input  logic [0:0] tile_dry_run_done ,
  input  logic [0:0] tile_exe_fsafe_en ,
  input  logic [0:0] tile_execution_ini_begin ,
  input  logic [0:0] tile_execution_valid ,
  output logic [0:0] tile_fu_propagate_rdy ,
  output logic [0:0] tile_iter_th_hit_nxt ,
  input  logic [0:0] tile_local_reset_a ,
  input  logic [0:0] tile_local_reset_b ,
  input  logic [0:0] tile_local_reset_c ,
  input  logic [0:0] tile_re_execution_ini_begin ,
  input  logic [0:0] tile_sync_dry_run_begin ,
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
  localparam logic [0:0] __const__i_at__lambda__s_tile_0__channel_a_0__recv_msg  = 1'd0;
  localparam logic [0:0] __const__i_at__lambda__s_tile_0__channel_a_1__recv_msg  = 1'd1;
  localparam logic [1:0] __const__i_at__lambda__s_tile_0__channel_a_2__recv_msg  = 2'd2;
  localparam logic [1:0] __const__i_at__lambda__s_tile_0__channel_a_3__recv_msg  = 2'd3;
  localparam logic [0:0] __const__i_at__lambda__s_tile_0__channel_b_0__recv_msg  = 1'd0;
  localparam logic [2:0] __const__num_connect_outports_at__lambda__s_tile_0__channel_b_0__recv_msg  = 3'd4;
  localparam logic [0:0] __const__i_at__lambda__s_tile_0__channel_b_1__recv_msg  = 1'd1;
  localparam logic [2:0] __const__num_connect_outports_at__lambda__s_tile_0__channel_b_1__recv_msg  = 3'd4;
  localparam logic [1:0] __const__i_at__lambda__s_tile_0__channel_b_2__recv_msg  = 2'd2;
  localparam logic [2:0] __const__num_connect_outports_at__lambda__s_tile_0__channel_b_2__recv_msg  = 3'd4;
  localparam logic [1:0] __const__i_at__lambda__s_tile_0__channel_b_3__recv_msg  = 2'd3;
  localparam logic [2:0] __const__num_connect_outports_at__lambda__s_tile_0__channel_b_3__recv_msg  = 3'd4;
  localparam logic [0:0] __const__i_at__lambda__s_tile_0__mux_bypass_data_0__in__0_  = 1'd0;
  localparam logic [0:0] __const__i_at__lambda__s_tile_0__mux_bypass_data_1__in__0_  = 1'd1;
  localparam logic [1:0] __const__i_at__lambda__s_tile_0__mux_bypass_data_2__in__0_  = 2'd2;
  localparam logic [1:0] __const__i_at__lambda__s_tile_0__mux_bypass_data_3__in__0_  = 2'd3;
  localparam logic [0:0] __const__i_at__lambda__s_tile_0__element_recv_port_data_0_  = 1'd0;
  localparam logic [0:0] __const__i_at__lambda__s_tile_0__element_recv_port_data_1_  = 1'd1;
  localparam logic [1:0] __const__i_at__lambda__s_tile_0__element_recv_port_data_2_  = 2'd2;
  localparam logic [1:0] __const__i_at__lambda__s_tile_0__element_recv_port_data_3_  = 2'd3;
  CGRAConfig_10_3_6_8_3__877613aa0dfe8ae0 tile_ctrl_msg;
  logic [0:0] tile_dry_run_begin;
  logic [0:0] tile_opt_enable;
  logic [0:0] tile_propagate_en;

  logic [0:0] channel_a__clk [0:3];
  logic [0:0] channel_a__dry_run_ack [0:3];
  logic [0:0] channel_a__dry_run_done [0:3];
  logic [0:0] channel_a__local_reset_b [0:3];
  logic [0:0] channel_a__local_reset_c [0:3];
  logic [0:0] channel_a__recv_en_i [0:3];
  CGRAData_64_1__payload_64__predicate_1 channel_a__recv_msg [0:3];
  logic [0:0] channel_a__recv_rdy_o [0:3];
  logic [0:0] channel_a__reset [0:3];
  logic [0:0] channel_a__send_en_i [0:3];
  CGRAData_64_1__payload_64__predicate_1 channel_a__send_msg [0:3];
  logic [0:0] channel_a__send_valid_o [0:3];
  logic [0:0] channel_a__sync_dry_run [0:3];

  ChannelRTL__511b7cda5540ec2e channel_a__0
  (
    .clk( channel_a__clk[0] ),
    .dry_run_ack( channel_a__dry_run_ack[0] ),
    .dry_run_done( channel_a__dry_run_done[0] ),
    .local_reset_b( channel_a__local_reset_b[0] ),
    .local_reset_c( channel_a__local_reset_c[0] ),
    .recv_en_i( channel_a__recv_en_i[0] ),
    .recv_msg( channel_a__recv_msg[0] ),
    .recv_rdy_o( channel_a__recv_rdy_o[0] ),
    .reset( channel_a__reset[0] ),
    .send_en_i( channel_a__send_en_i[0] ),
    .send_msg( channel_a__send_msg[0] ),
    .send_valid_o( channel_a__send_valid_o[0] ),
    .sync_dry_run( channel_a__sync_dry_run[0] )
  );

  ChannelRTL__511b7cda5540ec2e channel_a__1
  (
    .clk( channel_a__clk[1] ),
    .dry_run_ack( channel_a__dry_run_ack[1] ),
    .dry_run_done( channel_a__dry_run_done[1] ),
    .local_reset_b( channel_a__local_reset_b[1] ),
    .local_reset_c( channel_a__local_reset_c[1] ),
    .recv_en_i( channel_a__recv_en_i[1] ),
    .recv_msg( channel_a__recv_msg[1] ),
    .recv_rdy_o( channel_a__recv_rdy_o[1] ),
    .reset( channel_a__reset[1] ),
    .send_en_i( channel_a__send_en_i[1] ),
    .send_msg( channel_a__send_msg[1] ),
    .send_valid_o( channel_a__send_valid_o[1] ),
    .sync_dry_run( channel_a__sync_dry_run[1] )
  );

  ChannelRTL__511b7cda5540ec2e channel_a__2
  (
    .clk( channel_a__clk[2] ),
    .dry_run_ack( channel_a__dry_run_ack[2] ),
    .dry_run_done( channel_a__dry_run_done[2] ),
    .local_reset_b( channel_a__local_reset_b[2] ),
    .local_reset_c( channel_a__local_reset_c[2] ),
    .recv_en_i( channel_a__recv_en_i[2] ),
    .recv_msg( channel_a__recv_msg[2] ),
    .recv_rdy_o( channel_a__recv_rdy_o[2] ),
    .reset( channel_a__reset[2] ),
    .send_en_i( channel_a__send_en_i[2] ),
    .send_msg( channel_a__send_msg[2] ),
    .send_valid_o( channel_a__send_valid_o[2] ),
    .sync_dry_run( channel_a__sync_dry_run[2] )
  );

  ChannelRTL__511b7cda5540ec2e channel_a__3
  (
    .clk( channel_a__clk[3] ),
    .dry_run_ack( channel_a__dry_run_ack[3] ),
    .dry_run_done( channel_a__dry_run_done[3] ),
    .local_reset_b( channel_a__local_reset_b[3] ),
    .local_reset_c( channel_a__local_reset_c[3] ),
    .recv_en_i( channel_a__recv_en_i[3] ),
    .recv_msg( channel_a__recv_msg[3] ),
    .recv_rdy_o( channel_a__recv_rdy_o[3] ),
    .reset( channel_a__reset[3] ),
    .send_en_i( channel_a__send_en_i[3] ),
    .send_msg( channel_a__send_msg[3] ),
    .send_valid_o( channel_a__send_valid_o[3] ),
    .sync_dry_run( channel_a__sync_dry_run[3] )
  );



  logic [0:0] channel_b__clk [0:3];
  logic [0:0] channel_b__dry_run_ack [0:3];
  logic [0:0] channel_b__dry_run_done [0:3];
  logic [0:0] channel_b__local_reset_b [0:3];
  logic [0:0] channel_b__local_reset_c [0:3];
  logic [0:0] channel_b__recv_en_i [0:3];
  CGRAData_64_1__payload_64__predicate_1 channel_b__recv_msg [0:3];
  logic [0:0] channel_b__recv_rdy_o [0:3];
  logic [0:0] channel_b__reset [0:3];
  logic [0:0] channel_b__send_en_i [0:3];
  CGRAData_64_1__payload_64__predicate_1 channel_b__send_msg [0:3];
  logic [0:0] channel_b__send_valid_o [0:3];
  logic [0:0] channel_b__sync_dry_run [0:3];

  ChannelRTL__1f55b6dac6c8e5a7 channel_b__0
  (
    .clk( channel_b__clk[0] ),
    .dry_run_ack( channel_b__dry_run_ack[0] ),
    .dry_run_done( channel_b__dry_run_done[0] ),
    .local_reset_b( channel_b__local_reset_b[0] ),
    .local_reset_c( channel_b__local_reset_c[0] ),
    .recv_en_i( channel_b__recv_en_i[0] ),
    .recv_msg( channel_b__recv_msg[0] ),
    .recv_rdy_o( channel_b__recv_rdy_o[0] ),
    .reset( channel_b__reset[0] ),
    .send_en_i( channel_b__send_en_i[0] ),
    .send_msg( channel_b__send_msg[0] ),
    .send_valid_o( channel_b__send_valid_o[0] ),
    .sync_dry_run( channel_b__sync_dry_run[0] )
  );

  ChannelRTL__1f55b6dac6c8e5a7 channel_b__1
  (
    .clk( channel_b__clk[1] ),
    .dry_run_ack( channel_b__dry_run_ack[1] ),
    .dry_run_done( channel_b__dry_run_done[1] ),
    .local_reset_b( channel_b__local_reset_b[1] ),
    .local_reset_c( channel_b__local_reset_c[1] ),
    .recv_en_i( channel_b__recv_en_i[1] ),
    .recv_msg( channel_b__recv_msg[1] ),
    .recv_rdy_o( channel_b__recv_rdy_o[1] ),
    .reset( channel_b__reset[1] ),
    .send_en_i( channel_b__send_en_i[1] ),
    .send_msg( channel_b__send_msg[1] ),
    .send_valid_o( channel_b__send_valid_o[1] ),
    .sync_dry_run( channel_b__sync_dry_run[1] )
  );

  ChannelRTL__1f55b6dac6c8e5a7 channel_b__2
  (
    .clk( channel_b__clk[2] ),
    .dry_run_ack( channel_b__dry_run_ack[2] ),
    .dry_run_done( channel_b__dry_run_done[2] ),
    .local_reset_b( channel_b__local_reset_b[2] ),
    .local_reset_c( channel_b__local_reset_c[2] ),
    .recv_en_i( channel_b__recv_en_i[2] ),
    .recv_msg( channel_b__recv_msg[2] ),
    .recv_rdy_o( channel_b__recv_rdy_o[2] ),
    .reset( channel_b__reset[2] ),
    .send_en_i( channel_b__send_en_i[2] ),
    .send_msg( channel_b__send_msg[2] ),
    .send_valid_o( channel_b__send_valid_o[2] ),
    .sync_dry_run( channel_b__sync_dry_run[2] )
  );

  ChannelRTL__1f55b6dac6c8e5a7 channel_b__3
  (
    .clk( channel_b__clk[3] ),
    .dry_run_ack( channel_b__dry_run_ack[3] ),
    .dry_run_done( channel_b__dry_run_done[3] ),
    .local_reset_b( channel_b__local_reset_b[3] ),
    .local_reset_c( channel_b__local_reset_c[3] ),
    .recv_en_i( channel_b__recv_en_i[3] ),
    .recv_msg( channel_b__recv_msg[3] ),
    .recv_rdy_o( channel_b__recv_rdy_o[3] ),
    .reset( channel_b__reset[3] ),
    .send_en_i( channel_b__send_en_i[3] ),
    .send_msg( channel_b__send_msg[3] ),
    .send_valid_o( channel_b__send_valid_o[3] ),
    .sync_dry_run( channel_b__sync_dry_run[3] )
  );



  logic [0:0] const_queue__clk;
  logic [4:0] const_queue__data_counter_base;
  logic [4:0] const_queue__data_counter_th;
  logic [0:0] const_queue__dry_run_done;
  logic [0:0] const_queue__execution_ini;
  logic [31:0] const_queue__recv_const;
  logic [0:0] const_queue__recv_const_en;
  logic [3:0] const_queue__recv_const_waddr;
  logic [0:0] const_queue__reset;
  logic [0:0] const_queue__send_const_en;
  logic [31:0] const_queue__send_const_msg;

  ConstQueueRTL__a54094f779e9bc58 const_queue
  (
    .clk( const_queue__clk ),
    .data_counter_base( const_queue__data_counter_base ),
    .data_counter_th( const_queue__data_counter_th ),
    .dry_run_done( const_queue__dry_run_done ),
    .execution_ini( const_queue__execution_ini ),
    .recv_const( const_queue__recv_const ),
    .recv_const_en( const_queue__recv_const_en ),
    .recv_const_waddr( const_queue__recv_const_waddr ),
    .reset( const_queue__reset ),
    .send_const_en( const_queue__send_const_en ),
    .send_const_msg( const_queue__send_const_msg )
  );



  logic [3:0] crossbar__bp_port_en;
  logic [3:0] crossbar__bp_port_rdy;
  logic [3:0] crossbar__bp_port_sel;
  logic [0:0] crossbar__clk;
  logic [0:0] crossbar__exe_fsafe_en;
  logic [0:0] crossbar__execution_ini;
  logic [2:0] crossbar__recv_opt_msg_outport [0:8];
  CGRAData_64_1__payload_64__predicate_1 crossbar__recv_port_data [0:5];
  logic [5:0] crossbar__recv_port_en;
  logic [5:0] crossbar__recv_port_rdy;
  logic [0:0] crossbar__reset;
  CGRAData_64_1__payload_64__predicate_1 crossbar__send_bp_data [0:3];
  CGRAData_64_1__payload_64__predicate_1 crossbar__send_port_data [0:7];
  logic [7:0] crossbar__send_port_en;
  logic [7:0] crossbar__send_port_rdy;
  CGRAData_1__predicate_1 crossbar__send_predicate;
  logic [0:0] crossbar__send_predicate_en;
  logic [0:0] crossbar__send_predicate_rdy;
  logic [0:0] crossbar__xbar_opt_enable;
  logic [0:0] crossbar__xbar_propagate_en;
  logic [0:0] crossbar__xbar_propagate_rdy;

  CrossbarRTL__549e61f8d5b6eb92 crossbar
  (
    .bp_port_en( crossbar__bp_port_en ),
    .bp_port_rdy( crossbar__bp_port_rdy ),
    .bp_port_sel( crossbar__bp_port_sel ),
    .clk( crossbar__clk ),
    .exe_fsafe_en( crossbar__exe_fsafe_en ),
    .execution_ini( crossbar__execution_ini ),
    .recv_opt_msg_outport( crossbar__recv_opt_msg_outport ),
    .recv_port_data( crossbar__recv_port_data ),
    .recv_port_en( crossbar__recv_port_en ),
    .recv_port_rdy( crossbar__recv_port_rdy ),
    .reset( crossbar__reset ),
    .send_bp_data( crossbar__send_bp_data ),
    .send_port_data( crossbar__send_port_data ),
    .send_port_en( crossbar__send_port_en ),
    .send_port_rdy( crossbar__send_port_rdy ),
    .send_predicate( crossbar__send_predicate ),
    .send_predicate_en( crossbar__send_predicate_en ),
    .send_predicate_rdy( crossbar__send_predicate_rdy ),
    .xbar_opt_enable( crossbar__xbar_opt_enable ),
    .xbar_propagate_en( crossbar__xbar_propagate_en ),
    .xbar_propagate_rdy( crossbar__xbar_propagate_rdy )
  );



  logic [0:0] ctrl_mem__clk;
  logic [4:0] ctrl_mem__cmd_counter_base;
  logic [4:0] ctrl_mem__cmd_counter_th;
  logic [0:0] ctrl_mem__cmd_el_mode_en;
  logic [0:0] ctrl_mem__cmd_iter_th_hit_nxt;
  logic [31:0] ctrl_mem__cmd_iter_th_info;
  logic [0:0] ctrl_mem__execution_ini;
  logic [0:0] ctrl_mem__nxt_ctrl_en;
  logic [0:0] ctrl_mem__re_execution_ini;
  CGRAConfig_10_3_6_8_3__877613aa0dfe8ae0 ctrl_mem__recv_ctrl_msg;
  logic [31:0] ctrl_mem__recv_ctrl_slice;
  logic [0:0] ctrl_mem__recv_ctrl_slice_en;
  logic [0:0] ctrl_mem__recv_ctrl_slice_idx;
  logic [3:0] ctrl_mem__recv_waddr;
  logic [0:0] ctrl_mem__recv_waddr_en;
  logic [0:0] ctrl_mem__reset;
  CGRAConfig_10_3_6_8_3__877613aa0dfe8ae0 ctrl_mem__send_ctrl_msg;

  CtrlMemRTL__d3d31847de3fc702 ctrl_mem
  (
    .clk( ctrl_mem__clk ),
    .cmd_counter_base( ctrl_mem__cmd_counter_base ),
    .cmd_counter_th( ctrl_mem__cmd_counter_th ),
    .cmd_el_mode_en( ctrl_mem__cmd_el_mode_en ),
    .cmd_iter_th_hit_nxt( ctrl_mem__cmd_iter_th_hit_nxt ),
    .cmd_iter_th_info( ctrl_mem__cmd_iter_th_info ),
    .execution_ini( ctrl_mem__execution_ini ),
    .nxt_ctrl_en( ctrl_mem__nxt_ctrl_en ),
    .re_execution_ini( ctrl_mem__re_execution_ini ),
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



  logic [5:0] element__cgra_o_imm_bmask_i;
  logic [1:0] element__cgra_signed_mode_i;
  logic [1:0] element__cgra_vec_mode_i;
  logic [0:0] element__clk;
  logic [0:0] element__exe_fsafe_en;
  logic [0:0] element__execution_ini;
  logic [0:0] element__fu_dry_run_ack;
  logic [0:0] element__fu_dry_run_done;
  logic [0:0] element__fu_local_reset_a;
  logic [0:0] element__fu_local_reset_c;
  logic [0:0] element__fu_opt_enable;
  logic [0:0] element__fu_propagate_en;
  logic [0:0] element__fu_propagate_rdy;
  logic [0:0] element__fu_sync_dry_run;
  logic [31:0] element__recv_const_data;
  logic [0:0] element__recv_const_rdy;
  logic [127:0] element__recv_lut_b_data;
  logic [127:0] element__recv_lut_k_data;
  logic [127:0] element__recv_lut_p_data;
  logic [9:0] element__recv_opt_msg_ctrl;
  logic [2:0] element__recv_opt_msg_fu_in [0:2];
  logic [3:0] element__recv_opt_msg_fu_in_nupd;
  logic [2:0] element__recv_opt_msg_out_routine;
  logic [0:0] element__recv_opt_msg_predicate;
  CGRAData_64_1__payload_64__predicate_1 element__recv_port_data [0:3];
  logic [3:0] element__recv_port_en;
  logic [3:0] element__recv_port_rdy;
  CGRAData_1__predicate_1 element__recv_predicate_data;
  logic [0:0] element__recv_predicate_en;
  logic [0:0] element__recv_predicate_rdy;
  logic [0:0] element__reset;
  logic [1:0] element__send_lut_sel;
  CGRAData_64_1__payload_64__predicate_1 element__send_port_data [0:1];
  logic [1:0] element__send_port_en;
  logic [1:0] element__send_port_rdy;

  CGRAFURTL__0090f6af61ee96c5 element
  (
    .cgra_o_imm_bmask_i( element__cgra_o_imm_bmask_i ),
    .cgra_signed_mode_i( element__cgra_signed_mode_i ),
    .cgra_vec_mode_i( element__cgra_vec_mode_i ),
    .clk( element__clk ),
    .exe_fsafe_en( element__exe_fsafe_en ),
    .execution_ini( element__execution_ini ),
    .fu_dry_run_ack( element__fu_dry_run_ack ),
    .fu_dry_run_done( element__fu_dry_run_done ),
    .fu_local_reset_a( element__fu_local_reset_a ),
    .fu_local_reset_c( element__fu_local_reset_c ),
    .fu_opt_enable( element__fu_opt_enable ),
    .fu_propagate_en( element__fu_propagate_en ),
    .fu_propagate_rdy( element__fu_propagate_rdy ),
    .fu_sync_dry_run( element__fu_sync_dry_run ),
    .recv_const_data( element__recv_const_data ),
    .recv_const_rdy( element__recv_const_rdy ),
    .recv_lut_b_data( element__recv_lut_b_data ),
    .recv_lut_k_data( element__recv_lut_k_data ),
    .recv_lut_p_data( element__recv_lut_p_data ),
    .recv_opt_msg_ctrl( element__recv_opt_msg_ctrl ),
    .recv_opt_msg_fu_in( element__recv_opt_msg_fu_in ),
    .recv_opt_msg_fu_in_nupd( element__recv_opt_msg_fu_in_nupd ),
    .recv_opt_msg_out_routine( element__recv_opt_msg_out_routine ),
    .recv_opt_msg_predicate( element__recv_opt_msg_predicate ),
    .recv_port_data( element__recv_port_data ),
    .recv_port_en( element__recv_port_en ),
    .recv_port_rdy( element__recv_port_rdy ),
    .recv_predicate_data( element__recv_predicate_data ),
    .recv_predicate_en( element__recv_predicate_en ),
    .recv_predicate_rdy( element__recv_predicate_rdy ),
    .reset( element__reset ),
    .send_lut_sel( element__send_lut_sel ),
    .send_port_data( element__send_port_data ),
    .send_port_en( element__send_port_en ),
    .send_port_rdy( element__send_port_rdy )
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
  logic [0:0] reg_predicate__dry_run_ack;
  logic [0:0] reg_predicate__dry_run_done;
  logic [0:0] reg_predicate__local_reset_b;
  logic [0:0] reg_predicate__local_reset_c;
  logic [0:0] reg_predicate__recv_en_i;
  CGRAData_1__predicate_1 reg_predicate__recv_msg;
  logic [0:0] reg_predicate__recv_rdy_o;
  logic [0:0] reg_predicate__reset;
  logic [0:0] reg_predicate__send_en_i;
  CGRAData_1__predicate_1 reg_predicate__send_msg;
  logic [0:0] reg_predicate__send_valid_o;
  logic [0:0] reg_predicate__sync_dry_run;

  ChannelRTL__7cdc7a9725e49c50 reg_predicate
  (
    .clk( reg_predicate__clk ),
    .dry_run_ack( reg_predicate__dry_run_ack ),
    .dry_run_done( reg_predicate__dry_run_done ),
    .local_reset_b( reg_predicate__local_reset_b ),
    .local_reset_c( reg_predicate__local_reset_c ),
    .recv_en_i( reg_predicate__recv_en_i ),
    .recv_msg( reg_predicate__recv_msg ),
    .recv_rdy_o( reg_predicate__recv_rdy_o ),
    .reset( reg_predicate__reset ),
    .send_en_i( reg_predicate__send_en_i ),
    .send_msg( reg_predicate__send_msg ),
    .send_valid_o( reg_predicate__send_valid_o ),
    .sync_dry_run( reg_predicate__sync_dry_run )
  );



  logic [0:0] tile_ctrl_mux__clk;
  CGRAConfig_10_3_6_8_3__877613aa0dfe8ae0 tile_ctrl_mux__in_ [0:1];
  CGRAConfig_10_3_6_8_3__877613aa0dfe8ae0 tile_ctrl_mux__out;
  logic [0:0] tile_ctrl_mux__reset;
  logic [0:0] tile_ctrl_mux__sel;

  Mux__Type_CGRAConfig_10_3_6_8_3__877613aa0dfe8ae0__ninputs_2 tile_ctrl_mux
  (
    .clk( tile_ctrl_mux__clk ),
    .in_( tile_ctrl_mux__in_ ),
    .out( tile_ctrl_mux__out ),
    .reset( tile_ctrl_mux__reset ),
    .sel( tile_ctrl_mux__sel )
  );


  
  always_comb begin : _lambda__s_tile_0__channel_a_0__recv_msg
    channel_a__recv_msg[2'd0] = tile_dry_run_ack ? { 64'd0, 1'd1 } : crossbar__send_port_data[3'( __const__i_at__lambda__s_tile_0__channel_a_0__recv_msg )];
  end

  
  always_comb begin : _lambda__s_tile_0__channel_a_1__recv_msg
    channel_a__recv_msg[2'd1] = tile_dry_run_ack ? { 64'd0, 1'd1 } : crossbar__send_port_data[3'( __const__i_at__lambda__s_tile_0__channel_a_1__recv_msg )];
  end

  
  always_comb begin : _lambda__s_tile_0__channel_a_2__recv_msg
    channel_a__recv_msg[2'd2] = tile_dry_run_ack ? { 64'd0, 1'd1 } : crossbar__send_port_data[3'( __const__i_at__lambda__s_tile_0__channel_a_2__recv_msg )];
  end

  
  always_comb begin : _lambda__s_tile_0__channel_a_3__recv_msg
    channel_a__recv_msg[2'd3] = tile_dry_run_ack ? { 64'd0, 1'd1 } : crossbar__send_port_data[3'( __const__i_at__lambda__s_tile_0__channel_a_3__recv_msg )];
  end

  
  always_comb begin : _lambda__s_tile_0__channel_b_0__recv_msg
    channel_b__recv_msg[2'd0] = tile_dry_run_ack ? { 64'd0, 1'd1 } : crossbar__send_port_data[3'( __const__i_at__lambda__s_tile_0__channel_b_0__recv_msg ) + 3'( __const__num_connect_outports_at__lambda__s_tile_0__channel_b_0__recv_msg )];
  end

  
  always_comb begin : _lambda__s_tile_0__channel_b_1__recv_msg
    channel_b__recv_msg[2'd1] = tile_dry_run_ack ? { 64'd0, 1'd1 } : crossbar__send_port_data[3'( __const__i_at__lambda__s_tile_0__channel_b_1__recv_msg ) + 3'( __const__num_connect_outports_at__lambda__s_tile_0__channel_b_1__recv_msg )];
  end

  
  always_comb begin : _lambda__s_tile_0__channel_b_2__recv_msg
    channel_b__recv_msg[2'd2] = tile_dry_run_ack ? { 64'd0, 1'd1 } : crossbar__send_port_data[3'( __const__i_at__lambda__s_tile_0__channel_b_2__recv_msg ) + 3'( __const__num_connect_outports_at__lambda__s_tile_0__channel_b_2__recv_msg )];
  end

  
  always_comb begin : _lambda__s_tile_0__channel_b_3__recv_msg
    channel_b__recv_msg[2'd3] = tile_dry_run_ack ? { 64'd0, 1'd1 } : crossbar__send_port_data[3'( __const__i_at__lambda__s_tile_0__channel_b_3__recv_msg ) + 3'( __const__num_connect_outports_at__lambda__s_tile_0__channel_b_3__recv_msg )];
  end

  
  always_comb begin : _lambda__s_tile_0__element_recv_port_data_0_
    element__recv_port_data[2'd0] = tile_dry_run_ack ? { 64'd0, 1'd1 } : channel_b__send_msg[2'( __const__i_at__lambda__s_tile_0__element_recv_port_data_0_ )];
  end

  
  always_comb begin : _lambda__s_tile_0__element_recv_port_data_1_
    element__recv_port_data[2'd1] = tile_dry_run_ack ? { 64'd0, 1'd1 } : channel_b__send_msg[2'( __const__i_at__lambda__s_tile_0__element_recv_port_data_1_ )];
  end

  
  always_comb begin : _lambda__s_tile_0__element_recv_port_data_2_
    element__recv_port_data[2'd2] = tile_dry_run_ack ? { 64'd0, 1'd1 } : channel_b__send_msg[2'( __const__i_at__lambda__s_tile_0__element_recv_port_data_2_ )];
  end

  
  always_comb begin : _lambda__s_tile_0__element_recv_port_data_3_
    element__recv_port_data[2'd3] = tile_dry_run_ack ? { 64'd0, 1'd1 } : channel_b__send_msg[2'( __const__i_at__lambda__s_tile_0__element_recv_port_data_3_ )];
  end

  
  always_comb begin : _lambda__s_tile_0__element_recv_predicate_data
    element__recv_predicate_data = tile_dry_run_ack ? 1'd1 : reg_predicate__send_msg;
  end

  
  always_comb begin : _lambda__s_tile_0__mux_bypass_data_0__in__0_
    mux_bypass_data__in_[2'd0][1'd0] = tile_dry_run_ack ? { 64'd0, 1'd1 } : channel_a__send_msg[2'( __const__i_at__lambda__s_tile_0__mux_bypass_data_0__in__0_ )];
  end

  
  always_comb begin : _lambda__s_tile_0__mux_bypass_data_1__in__0_
    mux_bypass_data__in_[2'd1][1'd0] = tile_dry_run_ack ? { 64'd0, 1'd1 } : channel_a__send_msg[2'( __const__i_at__lambda__s_tile_0__mux_bypass_data_1__in__0_ )];
  end

  
  always_comb begin : _lambda__s_tile_0__mux_bypass_data_2__in__0_
    mux_bypass_data__in_[2'd2][1'd0] = tile_dry_run_ack ? { 64'd0, 1'd1 } : channel_a__send_msg[2'( __const__i_at__lambda__s_tile_0__mux_bypass_data_2__in__0_ )];
  end

  
  always_comb begin : _lambda__s_tile_0__mux_bypass_data_3__in__0_
    mux_bypass_data__in_[2'd3][1'd0] = tile_dry_run_ack ? { 64'd0, 1'd1 } : channel_a__send_msg[2'( __const__i_at__lambda__s_tile_0__mux_bypass_data_3__in__0_ )];
  end

  
  always_comb begin : _lambda__s_tile_0__reg_predicate_recv_msg
    reg_predicate__recv_msg = tile_dry_run_ack ? 1'd1 : crossbar__send_predicate;
  end

  
  always_comb begin : _lambda__s_tile_0__tile_opt_enable
    tile_opt_enable = tile_dry_run_begin | tile_re_execution_ini_begin;
  end

  
  always_comb begin : _lambda__s_tile_0__tile_propagate_en
    tile_propagate_en = ( crossbar__xbar_propagate_rdy & element__fu_propagate_rdy ) & tile_opt_enable;
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
  assign channel_a__clk[0] = clk;
  assign channel_a__reset[0] = reset;
  assign channel_a__clk[1] = clk;
  assign channel_a__reset[1] = reset;
  assign channel_a__clk[2] = clk;
  assign channel_a__reset[2] = reset;
  assign channel_a__clk[3] = clk;
  assign channel_a__reset[3] = reset;
  assign channel_b__clk[0] = clk;
  assign channel_b__reset[0] = reset;
  assign channel_b__clk[1] = clk;
  assign channel_b__reset[1] = reset;
  assign channel_b__clk[2] = clk;
  assign channel_b__reset[2] = reset;
  assign channel_b__clk[3] = clk;
  assign channel_b__reset[3] = reset;
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
  assign const_queue__execution_ini = tile_execution_ini_begin;
  assign const_queue__dry_run_done = tile_dry_run_done;
  assign const_queue__data_counter_th = config_data_counter_th;
  assign const_queue__data_counter_base = config_data_counter_base;
  assign const_queue__recv_const = recv_const;
  assign const_queue__recv_const_en = recv_const_en;
  assign const_queue__recv_const_waddr = recv_const_waddr;
  assign ctrl_mem__recv_ctrl_slice_idx = ctrl_slice_idx;
  assign ctrl_mem__recv_waddr = recv_opt_waddr;
  assign ctrl_mem__recv_waddr_en = recv_opt_waddr_en;
  assign ctrl_mem__recv_ctrl_slice = recv_wopt;
  assign ctrl_mem__recv_ctrl_slice_en = recv_wopt_en;
  assign ctrl_mem__cmd_counter_th = config_cmd_counter_th;
  assign ctrl_mem__cmd_counter_base = config_cmd_counter_base;
  assign ctrl_mem__cmd_iter_th_info = config_cmd_iter_counter_th;
  assign ctrl_mem__execution_ini = tile_execution_ini_begin;
  assign ctrl_mem__re_execution_ini = tile_re_execution_ini_begin;
  assign ctrl_mem__cmd_el_mode_en = tile_cmd_el_mode_en;
  assign ctrl_mem__nxt_ctrl_en = tile_propagate_en;
  assign tile_iter_th_hit_nxt = ctrl_mem__cmd_iter_th_hit_nxt;
  assign channel_a__local_reset_b[0] = tile_local_reset_b;
  assign channel_a__local_reset_c[0] = tile_local_reset_c;
  assign channel_a__dry_run_ack[0] = tile_dry_run_ack;
  assign channel_a__dry_run_done[0] = tile_dry_run_done;
  assign channel_a__sync_dry_run[0] = tile_sync_dry_run_begin;
  assign channel_a__local_reset_b[1] = tile_local_reset_b;
  assign channel_a__local_reset_c[1] = tile_local_reset_c;
  assign channel_a__dry_run_ack[1] = tile_dry_run_ack;
  assign channel_a__dry_run_done[1] = tile_dry_run_done;
  assign channel_a__sync_dry_run[1] = tile_sync_dry_run_begin;
  assign channel_a__local_reset_b[2] = tile_local_reset_b;
  assign channel_a__local_reset_c[2] = tile_local_reset_c;
  assign channel_a__dry_run_ack[2] = tile_dry_run_ack;
  assign channel_a__dry_run_done[2] = tile_dry_run_done;
  assign channel_a__sync_dry_run[2] = tile_sync_dry_run_begin;
  assign channel_a__local_reset_b[3] = tile_local_reset_b;
  assign channel_a__local_reset_c[3] = tile_local_reset_c;
  assign channel_a__dry_run_ack[3] = tile_dry_run_ack;
  assign channel_a__dry_run_done[3] = tile_dry_run_done;
  assign channel_a__sync_dry_run[3] = tile_sync_dry_run_begin;
  assign channel_b__local_reset_b[0] = tile_local_reset_b;
  assign channel_b__local_reset_c[0] = tile_local_reset_c;
  assign channel_b__dry_run_ack[0] = tile_dry_run_ack;
  assign channel_b__dry_run_done[0] = tile_dry_run_done;
  assign channel_b__sync_dry_run[0] = tile_sync_dry_run_begin;
  assign channel_b__local_reset_b[1] = tile_local_reset_b;
  assign channel_b__local_reset_c[1] = tile_local_reset_c;
  assign channel_b__dry_run_ack[1] = tile_dry_run_ack;
  assign channel_b__dry_run_done[1] = tile_dry_run_done;
  assign channel_b__sync_dry_run[1] = tile_sync_dry_run_begin;
  assign channel_b__local_reset_b[2] = tile_local_reset_b;
  assign channel_b__local_reset_c[2] = tile_local_reset_c;
  assign channel_b__dry_run_ack[2] = tile_dry_run_ack;
  assign channel_b__dry_run_done[2] = tile_dry_run_done;
  assign channel_b__sync_dry_run[2] = tile_sync_dry_run_begin;
  assign channel_b__local_reset_b[3] = tile_local_reset_b;
  assign channel_b__local_reset_c[3] = tile_local_reset_c;
  assign channel_b__dry_run_ack[3] = tile_dry_run_ack;
  assign channel_b__dry_run_done[3] = tile_dry_run_done;
  assign channel_b__sync_dry_run[3] = tile_sync_dry_run_begin;
  assign reg_predicate__local_reset_b = tile_local_reset_b;
  assign reg_predicate__local_reset_c = tile_local_reset_c;
  assign reg_predicate__dry_run_ack = tile_dry_run_ack;
  assign reg_predicate__dry_run_done = tile_dry_run_done;
  assign reg_predicate__sync_dry_run = tile_sync_dry_run_begin;
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
  assign crossbar__recv_opt_msg_outport[8] = tile_ctrl_msg.outport[8];
  assign crossbar__execution_ini = tile_execution_ini_begin;
  assign crossbar__xbar_opt_enable = tile_opt_enable;
  assign crossbar__exe_fsafe_en = tile_exe_fsafe_en;
  assign crossbar__xbar_propagate_en = tile_propagate_en;
  assign crossbar__recv_port_data[0] = recv_data[0];
  assign recv_data_ack[0] = crossbar__recv_port_rdy[0:0];
  assign crossbar__recv_port_en[0:0] = recv_data_valid[0];
  assign crossbar__recv_port_data[1] = recv_data[1];
  assign recv_data_ack[1] = crossbar__recv_port_rdy[1:1];
  assign crossbar__recv_port_en[1:1] = recv_data_valid[1];
  assign crossbar__recv_port_data[2] = recv_data[2];
  assign recv_data_ack[2] = crossbar__recv_port_rdy[2:2];
  assign crossbar__recv_port_en[2:2] = recv_data_valid[2];
  assign crossbar__recv_port_data[3] = recv_data[3];
  assign recv_data_ack[3] = crossbar__recv_port_rdy[3:3];
  assign crossbar__recv_port_en[3:3] = recv_data_valid[3];
  assign channel_a__recv_en_i[0] = crossbar__send_port_en[0:0];
  assign crossbar__send_port_rdy[0:0] = channel_a__recv_rdy_o[0];
  assign channel_a__recv_en_i[1] = crossbar__send_port_en[1:1];
  assign crossbar__send_port_rdy[1:1] = channel_a__recv_rdy_o[1];
  assign channel_a__recv_en_i[2] = crossbar__send_port_en[2:2];
  assign crossbar__send_port_rdy[2:2] = channel_a__recv_rdy_o[2];
  assign channel_a__recv_en_i[3] = crossbar__send_port_en[3:3];
  assign crossbar__send_port_rdy[3:3] = channel_a__recv_rdy_o[3];
  assign channel_b__recv_en_i[0] = crossbar__send_port_en[4:4];
  assign crossbar__send_port_rdy[4:4] = channel_b__recv_rdy_o[0];
  assign channel_b__recv_en_i[1] = crossbar__send_port_en[5:5];
  assign crossbar__send_port_rdy[5:5] = channel_b__recv_rdy_o[1];
  assign channel_b__recv_en_i[2] = crossbar__send_port_en[6:6];
  assign crossbar__send_port_rdy[6:6] = channel_b__recv_rdy_o[2];
  assign channel_b__recv_en_i[3] = crossbar__send_port_en[7:7];
  assign crossbar__send_port_rdy[7:7] = channel_b__recv_rdy_o[3];
  assign crossbar__send_predicate_rdy = reg_predicate__recv_rdy_o;
  assign reg_predicate__recv_en_i = crossbar__send_predicate_en;
  assign demux_bypass_ack__in_[0] = send_data_ack[0];
  assign channel_a__send_en_i[0] = demux_bypass_ack__out[0][0];
  assign crossbar__bp_port_rdy[0:0] = demux_bypass_ack__out[0][1];
  assign demux_bypass_ack__sel[0] = crossbar__bp_port_sel[0:0];
  assign mux_bypass_valid__in_[0][0] = channel_a__send_valid_o[0];
  assign mux_bypass_valid__in_[0][1] = crossbar__bp_port_en[0:0];
  assign send_data_valid[0] = mux_bypass_valid__out[0];
  assign mux_bypass_valid__sel[0] = crossbar__bp_port_sel[0:0];
  assign mux_bypass_data__in_[0][1] = crossbar__send_bp_data[0];
  assign send_data[0] = mux_bypass_data__out[0];
  assign mux_bypass_data__sel[0] = crossbar__bp_port_sel[0:0];
  assign demux_bypass_ack__in_[1] = send_data_ack[1];
  assign channel_a__send_en_i[1] = demux_bypass_ack__out[1][0];
  assign crossbar__bp_port_rdy[1:1] = demux_bypass_ack__out[1][1];
  assign demux_bypass_ack__sel[1] = crossbar__bp_port_sel[1:1];
  assign mux_bypass_valid__in_[1][0] = channel_a__send_valid_o[1];
  assign mux_bypass_valid__in_[1][1] = crossbar__bp_port_en[1:1];
  assign send_data_valid[1] = mux_bypass_valid__out[1];
  assign mux_bypass_valid__sel[1] = crossbar__bp_port_sel[1:1];
  assign mux_bypass_data__in_[1][1] = crossbar__send_bp_data[1];
  assign send_data[1] = mux_bypass_data__out[1];
  assign mux_bypass_data__sel[1] = crossbar__bp_port_sel[1:1];
  assign demux_bypass_ack__in_[2] = send_data_ack[2];
  assign channel_a__send_en_i[2] = demux_bypass_ack__out[2][0];
  assign crossbar__bp_port_rdy[2:2] = demux_bypass_ack__out[2][1];
  assign demux_bypass_ack__sel[2] = crossbar__bp_port_sel[2:2];
  assign mux_bypass_valid__in_[2][0] = channel_a__send_valid_o[2];
  assign mux_bypass_valid__in_[2][1] = crossbar__bp_port_en[2:2];
  assign send_data_valid[2] = mux_bypass_valid__out[2];
  assign mux_bypass_valid__sel[2] = crossbar__bp_port_sel[2:2];
  assign mux_bypass_data__in_[2][1] = crossbar__send_bp_data[2];
  assign send_data[2] = mux_bypass_data__out[2];
  assign mux_bypass_data__sel[2] = crossbar__bp_port_sel[2:2];
  assign demux_bypass_ack__in_[3] = send_data_ack[3];
  assign channel_a__send_en_i[3] = demux_bypass_ack__out[3][0];
  assign crossbar__bp_port_rdy[3:3] = demux_bypass_ack__out[3][1];
  assign demux_bypass_ack__sel[3] = crossbar__bp_port_sel[3:3];
  assign mux_bypass_valid__in_[3][0] = channel_a__send_valid_o[3];
  assign mux_bypass_valid__in_[3][1] = crossbar__bp_port_en[3:3];
  assign send_data_valid[3] = mux_bypass_valid__out[3];
  assign mux_bypass_valid__sel[3] = crossbar__bp_port_sel[3:3];
  assign mux_bypass_data__in_[3][1] = crossbar__send_bp_data[3];
  assign send_data[3] = mux_bypass_data__out[3];
  assign mux_bypass_data__sel[3] = crossbar__bp_port_sel[3:3];
  assign element__recv_opt_msg_ctrl = tile_ctrl_msg.ctrl;
  assign element__recv_opt_msg_predicate = tile_ctrl_msg.predicate;
  assign element__recv_opt_msg_out_routine = tile_ctrl_msg.out_routine;
  assign element__recv_opt_msg_fu_in_nupd = tile_ctrl_msg.fu_in_nupd;
  assign element__recv_opt_msg_fu_in[0] = tile_ctrl_msg.fu_in[0];
  assign element__recv_opt_msg_fu_in[1] = tile_ctrl_msg.fu_in[1];
  assign element__recv_opt_msg_fu_in[2] = tile_ctrl_msg.fu_in[2];
  assign element__cgra_vec_mode_i = tile_ctrl_msg.vec_mode;
  assign element__cgra_o_imm_bmask_i = tile_ctrl_msg.o_imm_bmask;
  assign element__cgra_signed_mode_i = tile_ctrl_msg.signed_mode;
  assign element__fu_dry_run_ack = tile_dry_run_ack;
  assign element__fu_local_reset_a = tile_local_reset_a;
  assign element__fu_local_reset_c = tile_local_reset_c;
  assign element__fu_dry_run_done = tile_dry_run_done;
  assign element__fu_sync_dry_run = tile_sync_dry_run_begin;
  assign element__exe_fsafe_en = tile_exe_fsafe_en;
  assign element__execution_ini = tile_execution_ini_begin;
  assign element__fu_opt_enable = tile_opt_enable;
  assign element__fu_propagate_en = tile_propagate_en;
  assign element__recv_port_en[0:0] = channel_b__send_valid_o[0];
  assign channel_b__send_en_i[0] = element__recv_port_rdy[0:0];
  assign element__recv_port_en[1:1] = channel_b__send_valid_o[1];
  assign channel_b__send_en_i[1] = element__recv_port_rdy[1:1];
  assign element__recv_port_en[2:2] = channel_b__send_valid_o[2];
  assign channel_b__send_en_i[2] = element__recv_port_rdy[2:2];
  assign element__recv_port_en[3:3] = channel_b__send_valid_o[3];
  assign channel_b__send_en_i[3] = element__recv_port_rdy[3:3];
  assign element__recv_predicate_en = reg_predicate__send_valid_o;
  assign reg_predicate__send_en_i = element__recv_predicate_rdy;
  assign element__recv_const_data = const_queue__send_const_msg;
  assign const_queue__send_const_en = element__recv_const_rdy;
  assign crossbar__recv_port_data[4] = element__send_port_data[0];
  assign crossbar__recv_port_en[4:4] = element__send_port_en[0:0];
  assign element__send_port_rdy[0:0] = crossbar__recv_port_rdy[4:4];
  assign crossbar__recv_port_data[5] = element__send_port_data[1];
  assign crossbar__recv_port_en[5:5] = element__send_port_en[1:1];
  assign element__send_port_rdy[1:1] = crossbar__recv_port_rdy[5:5];
  assign element__recv_lut_k_data = recv_lut_k;
  assign element__recv_lut_b_data = recv_lut_b;
  assign element__recv_lut_p_data = recv_lut_p;
  assign send_lut_sel = element__send_lut_sel;
  assign tile_xbar_propagate_rdy = crossbar__xbar_propagate_rdy;
  assign tile_fu_propagate_rdy = element__fu_propagate_rdy;

endmodule



module CGRARTL__top
(
  output logic [31:0] cgra_csr_ro [0:10],
  input  logic [31:0] cgra_csr_rw [0:36],
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
  localparam logic [0:0] __const__i_at__lambda__s_cgra_send_ni_data_0__en  = 1'd0;
  localparam logic [0:0] __const__i_at__lambda__s_tile_send_ni_data_rdy_0_1_  = 1'd0;
  localparam logic [0:0] __const__i_at__lambda__s_cgra_recv_ni_data_1__rdy  = 1'd1;
  localparam logic [0:0] __const__i_at__lambda__s_cgra_send_ni_data_1__en  = 1'd1;
  localparam logic [0:0] __const__i_at__lambda__s_tile_send_ni_data_rdy_1_2_  = 1'd1;
  localparam logic [1:0] __const__i_at__lambda__s_cgra_recv_ni_data_2__rdy  = 2'd2;
  localparam logic [1:0] __const__i_at__lambda__s_cgra_send_ni_data_2__en  = 2'd2;
  localparam logic [1:0] __const__i_at__lambda__s_tile_send_ni_data_rdy_2_3_  = 2'd2;
  localparam logic [1:0] __const__i_at__lambda__s_cgra_recv_ni_data_3__rdy  = 2'd3;
  localparam logic [1:0] __const__i_at__lambda__s_cgra_send_ni_data_3__en  = 2'd3;
  localparam logic [1:0] __const__i_at__lambda__s_tile_send_ni_data_rdy_3_4_  = 2'd3;
  localparam logic [2:0] __const__i_at__lambda__s_cgra_recv_ni_data_4__rdy  = 3'd4;
  localparam logic [2:0] __const__i_at__lambda__s_cgra_send_ni_data_4__en  = 3'd4;
  localparam logic [2:0] __const__i_at__lambda__s_tile_send_ni_data_rdy_4_5_  = 3'd4;
  localparam logic [2:0] __const__i_at__lambda__s_cgra_recv_ni_data_5__rdy  = 3'd5;
  localparam logic [2:0] __const__i_at__lambda__s_cgra_send_ni_data_5__en  = 3'd5;
  localparam logic [2:0] __const__i_at__lambda__s_tile_send_ni_data_rdy_5_6_  = 3'd5;
  localparam logic [2:0] __const__i_at__lambda__s_cgra_recv_ni_data_6__rdy  = 3'd6;
  localparam logic [2:0] __const__i_at__lambda__s_cgra_send_ni_data_6__en  = 3'd6;
  localparam logic [2:0] __const__i_at__lambda__s_tile_send_ni_data_rdy_6_7_  = 3'd6;
  localparam logic [2:0] __const__i_at__lambda__s_cgra_recv_ni_data_7__rdy  = 3'd7;
  localparam logic [2:0] __const__i_at__lambda__s_cgra_send_ni_data_7__en  = 3'd7;
  localparam logic [2:0] __const__i_at__lambda__s_tile_send_ni_data_rdy_7_8_  = 3'd7;
  localparam logic [3:0] __const__STAGE_IDLE  = 4'd0;
  localparam logic [3:0] __const__STAGE_CONFIG_CTRLREG  = 4'd1;
  localparam logic [3:0] __const__STAGE_CONFIG_LUT  = 4'd2;
  localparam logic [3:0] __const__STAGE_CONFIG_DATA  = 4'd3;
  localparam logic [3:0] __const__STAGE_CONFIG_CMD  = 4'd4;
  localparam logic [3:0] __const__STAGE_CONFIG_DONE  = 4'd5;
  localparam logic [3:0] __const__STAGE_COMP  = 4'd6;
  localparam logic [3:0] __const__STAGE_COMP_HALT  = 4'd10;
  localparam logic [0:0] __const__i_at__lambda__s_cgra_cycle_th_hit_0_1_  = 1'd0;
  localparam logic [0:0] __const__i_at__lambda__s_cgra_cycle_th_hit_1_2_  = 1'd1;
  localparam logic [1:0] __const__i_at__lambda__s_cgra_cycle_th_hit_2_3_  = 2'd2;
  localparam logic [1:0] __const__i_at__lambda__s_cgra_cycle_th_hit_3_4_  = 2'd3;
  localparam logic [0:0] __const__i_at__lambda__s_tile_dry_run_ack_0_  = 1'd0;
  localparam logic [0:0] __const__i_at__lambda__s_tile_dry_run_ack_1_  = 1'd1;
  localparam logic [1:0] __const__i_at__lambda__s_tile_dry_run_ack_2_  = 2'd2;
  localparam logic [1:0] __const__i_at__lambda__s_tile_dry_run_ack_3_  = 2'd3;
  localparam logic [2:0] __const__i_at__lambda__s_tile_dry_run_ack_4_  = 3'd4;
  localparam logic [2:0] __const__i_at__lambda__s_tile_dry_run_ack_5_  = 3'd5;
  localparam logic [2:0] __const__i_at__lambda__s_tile_dry_run_ack_6_  = 3'd6;
  localparam logic [2:0] __const__i_at__lambda__s_tile_dry_run_ack_7_  = 3'd7;
  localparam logic [3:0] __const__i_at__lambda__s_tile_dry_run_ack_8_  = 4'd8;
  localparam logic [3:0] __const__i_at__lambda__s_tile_dry_run_ack_9_  = 4'd9;
  localparam logic [3:0] __const__i_at__lambda__s_tile_dry_run_ack_10_  = 4'd10;
  localparam logic [3:0] __const__i_at__lambda__s_tile_dry_run_ack_11_  = 4'd11;
  localparam logic [3:0] __const__i_at__lambda__s_tile_dry_run_ack_12_  = 4'd12;
  localparam logic [3:0] __const__i_at__lambda__s_tile_dry_run_ack_13_  = 4'd13;
  localparam logic [3:0] __const__i_at__lambda__s_tile_dry_run_ack_14_  = 4'd14;
  localparam logic [3:0] __const__i_at__lambda__s_tile_dry_run_ack_15_  = 4'd15;
  logic [0:0] cgra_chaining_en;
  logic [0:0] cgra_clear_pipe_en;
  logic [0:0] cgra_cmd_dry_run_begin;
  logic [0:0] cgra_cmd_el_mode_en;
  logic [0:0] cgra_computation_en;
  logic [0:0] cgra_config_cmd_begin;
  logic [4:0] cgra_config_cmd_counter_th;
  logic [0:0] cgra_config_cmd_done;
  logic [0:0] cgra_config_cmd_dry_run_done;
  logic [0:0] cgra_config_cmd_en;
  logic [0:0] cgra_config_cmd_wopt_done;
  logic [0:0] cgra_config_data_begin;
  logic [4:0] cgra_config_data_counter_th;
  logic [0:0] cgra_config_data_done;
  logic [0:0] cgra_config_data_en;
  logic [4:0] cgra_config_dry_run_counter_th;
  logic [0:0] cgra_config_ini_begin;
  logic [0:0] cgra_config_ini_en;
  logic [0:0] cgra_config_lut_begin;
  logic [0:0] cgra_config_lut_done;
  logic [0:0] cgra_config_lut_en;
  logic [0:0] cgra_csr_rdy;
  logic [15:0] cgra_cur_stage_info;
  logic [3:0] cgra_cycle_th_hit;
  logic [1:0] cgra_dmem_io_mode;
  logic [0:0] cgra_dry_run_ack;
  logic [0:0] cgra_dry_run_fin;
  logic [0:0] cgra_exe_fsafe_en;
  logic [0:0] cgra_execution_ini_begin;
  logic [0:0] cgra_execution_valid;
  logic [15:0] cgra_nxt_stage_info;
  logic [31:0] cgra_pref_counter;
  logic [31:0] cgra_pref_counter_ckpt [0:6];
  logic [31:0] cgra_propagate_rdy_info;
  logic [15:0] cgra_re_execution_begin;
  logic [511:0] cgra_recv_wi_data;
  logic [0:0] cgra_recv_wi_data_ack;
  logic [0:0] cgra_recv_wi_data_rdy;
  logic [0:0] cgra_recv_wi_data_valid;
  logic [0:0] cgra_reset_ini_en;
  logic [0:0] cgra_restart_comp_en;
  logic [3:0] cgra_sub_stage_en;
  logic [31:0] cgra_sub_stage_iter_th [0:3];
  logic [0:0] cgra_sync_dry_run_begin;
  logic [4:0] cgra_tile_cmd_base [0:15];
  logic [4:0] cgra_tile_cmd_th [0:15];
  logic [4:0] cgra_tile_data_base [0:15];
  logic [4:0] cgra_tile_data_th [0:15];
  logic [31:0] cgra_tile_iter_th [0:15];
  logic [31:0] cgra_tile_local_ctrl_1 [0:15];
  logic [31:0] cgra_tile_local_ctrl_2 [0:15];
  logic [0:0] cgra_tile_local_reset;
  logic [0:0] cgra_tile_local_reset_a;
  logic [0:0] cgra_tile_local_reset_b;
  logic [0:0] cgra_tile_local_reset_c;
  logic [4:0] counter_config_cmd_addr;
  logic [0:0] counter_config_cmd_slice;
  logic [4:0] counter_config_data_addr;
  logic [1:0] counter_config_lut_addr;
  logic [3:0] cur_stage;
  logic [3:0] nxt_stage;
  logic [511:0] recv_wconst_flattened;
  logic [0:0] recv_wconst_flattened_en;
  logic [0:0] recv_wconst_flattened_rdy;
  logic [511:0] recv_wlut_flattened;
  logic [0:0] recv_wlut_flattened_en;
  logic [0:0] recv_wlut_flattened_rdy;
  logic [511:0] recv_wopt_sliced_flattened;
  logic [0:0] recv_wopt_sliced_flattened_en;
  logic [0:0] recv_wopt_sliced_flattened_rdy;
  logic [3:0] sub_stage_done [0:15];
  logic [3:0] sub_stage_done_nxt [0:15];
  logic [15:0] sub_stage_done_t [0:3];
  logic [3:0] sub_stage_sel [0:15];
  logic [0:0] tile_dry_run_ack [0:15];
  logic [15:0] tile_fu_propagate_rdy_vector;
  logic [7:0] tile_recv_ni_data_ack;
  logic [7:0] tile_recv_ni_data_valid;
  logic [0:0] tile_recv_opt_waddr_en;
  logic [7:0] tile_send_ni_data_rdy;
  logic [7:0] tile_send_ni_data_valid;
  logic [15:0] tile_xbar_propagate_rdy_vector;

  logic [0:0] lut_array__clk;
  logic [511:0] lut_array__recv_lut_data;
  logic [1:0] lut_array__recv_raddr [0:15];
  logic [1:0] lut_array__recv_waddr;
  logic [0:0] lut_array__recv_waddr_en;
  logic [0:0] lut_array__reset;
  logic [127:0] lut_array__send_lut_b [0:15];
  logic [127:0] lut_array__send_lut_k [0:15];
  logic [127:0] lut_array__send_lut_p [0:15];

  LookUpTableRTL__3312552a84abe6da lut_array
  (
    .clk( lut_array__clk ),
    .recv_lut_data( lut_array__recv_lut_data ),
    .recv_raddr( lut_array__recv_raddr ),
    .recv_waddr( lut_array__recv_waddr ),
    .recv_waddr_en( lut_array__recv_waddr_en ),
    .reset( lut_array__reset ),
    .send_lut_b( lut_array__send_lut_b ),
    .send_lut_k( lut_array__send_lut_k ),
    .send_lut_p( lut_array__send_lut_p )
  );



  logic [0:0] tile__clk [0:15];
  logic [4:0] tile__config_cmd_counter_base [0:15];
  logic [4:0] tile__config_cmd_counter_th [0:15];
  logic [31:0] tile__config_cmd_iter_counter_th [0:15];
  logic [4:0] tile__config_data_counter_base [0:15];
  logic [4:0] tile__config_data_counter_th [0:15];
  logic [0:0] tile__ctrl_slice_idx [0:15];
  logic [31:0] tile__recv_const [0:15];
  logic [0:0] tile__recv_const_en [0:15];
  logic [3:0] tile__recv_const_waddr [0:15];
  CGRAData_64_1__payload_64__predicate_1 tile__recv_data [0:15][0:3];
  logic [0:0] tile__recv_data_ack [0:15][0:3];
  logic [0:0] tile__recv_data_valid [0:15][0:3];
  logic [127:0] tile__recv_lut_b [0:15];
  logic [127:0] tile__recv_lut_k [0:15];
  logic [127:0] tile__recv_lut_p [0:15];
  logic [3:0] tile__recv_opt_waddr [0:15];
  logic [0:0] tile__recv_opt_waddr_en [0:15];
  logic [31:0] tile__recv_wopt [0:15];
  logic [0:0] tile__recv_wopt_en [0:15];
  logic [0:0] tile__reset [0:15];
  CGRAData_64_1__payload_64__predicate_1 tile__send_data [0:15][0:3];
  logic [0:0] tile__send_data_ack [0:15][0:3];
  logic [0:0] tile__send_data_valid [0:15][0:3];
  logic [1:0] tile__send_lut_sel [0:15];
  logic [0:0] tile__tile_cmd_el_mode_en [0:15];
  logic [0:0] tile__tile_config_ini_begin [0:15];
  logic [0:0] tile__tile_dry_run_ack [0:15];
  logic [0:0] tile__tile_dry_run_done [0:15];
  logic [0:0] tile__tile_exe_fsafe_en [0:15];
  logic [0:0] tile__tile_execution_ini_begin [0:15];
  logic [0:0] tile__tile_execution_valid [0:15];
  logic [0:0] tile__tile_fu_propagate_rdy [0:15];
  logic [0:0] tile__tile_iter_th_hit_nxt [0:15];
  logic [0:0] tile__tile_local_reset_a [0:15];
  logic [0:0] tile__tile_local_reset_b [0:15];
  logic [0:0] tile__tile_local_reset_c [0:15];
  logic [0:0] tile__tile_re_execution_ini_begin [0:15];
  logic [0:0] tile__tile_sync_dry_run_begin [0:15];
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

  TileRTL__ea67303889430dc3 tile__0
  (
    .clk( tile__clk[0] ),
    .config_cmd_counter_base( tile__config_cmd_counter_base[0] ),
    .config_cmd_counter_th( tile__config_cmd_counter_th[0] ),
    .config_cmd_iter_counter_th( tile__config_cmd_iter_counter_th[0] ),
    .config_data_counter_base( tile__config_data_counter_base[0] ),
    .config_data_counter_th( tile__config_data_counter_th[0] ),
    .ctrl_slice_idx( tile__ctrl_slice_idx[0] ),
    .recv_const( tile__recv_const[0] ),
    .recv_const_en( tile__recv_const_en[0] ),
    .recv_const_waddr( tile__recv_const_waddr[0] ),
    .recv_data( tile__recv_data[0] ),
    .recv_data_ack( tile__recv_data_ack[0] ),
    .recv_data_valid( tile__recv_data_valid[0] ),
    .recv_lut_b( tile__recv_lut_b[0] ),
    .recv_lut_k( tile__recv_lut_k[0] ),
    .recv_lut_p( tile__recv_lut_p[0] ),
    .recv_opt_waddr( tile__recv_opt_waddr[0] ),
    .recv_opt_waddr_en( tile__recv_opt_waddr_en[0] ),
    .recv_wopt( tile__recv_wopt[0] ),
    .recv_wopt_en( tile__recv_wopt_en[0] ),
    .reset( tile__reset[0] ),
    .send_data( tile__send_data[0] ),
    .send_data_ack( tile__send_data_ack[0] ),
    .send_data_valid( tile__send_data_valid[0] ),
    .send_lut_sel( tile__send_lut_sel[0] ),
    .tile_cmd_el_mode_en( tile__tile_cmd_el_mode_en[0] ),
    .tile_config_ini_begin( tile__tile_config_ini_begin[0] ),
    .tile_dry_run_ack( tile__tile_dry_run_ack[0] ),
    .tile_dry_run_done( tile__tile_dry_run_done[0] ),
    .tile_exe_fsafe_en( tile__tile_exe_fsafe_en[0] ),
    .tile_execution_ini_begin( tile__tile_execution_ini_begin[0] ),
    .tile_execution_valid( tile__tile_execution_valid[0] ),
    .tile_fu_propagate_rdy( tile__tile_fu_propagate_rdy[0] ),
    .tile_iter_th_hit_nxt( tile__tile_iter_th_hit_nxt[0] ),
    .tile_local_reset_a( tile__tile_local_reset_a[0] ),
    .tile_local_reset_b( tile__tile_local_reset_b[0] ),
    .tile_local_reset_c( tile__tile_local_reset_c[0] ),
    .tile_re_execution_ini_begin( tile__tile_re_execution_ini_begin[0] ),
    .tile_sync_dry_run_begin( tile__tile_sync_dry_run_begin[0] ),
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

  TileRTL__ea67303889430dc3 tile__1
  (
    .clk( tile__clk[1] ),
    .config_cmd_counter_base( tile__config_cmd_counter_base[1] ),
    .config_cmd_counter_th( tile__config_cmd_counter_th[1] ),
    .config_cmd_iter_counter_th( tile__config_cmd_iter_counter_th[1] ),
    .config_data_counter_base( tile__config_data_counter_base[1] ),
    .config_data_counter_th( tile__config_data_counter_th[1] ),
    .ctrl_slice_idx( tile__ctrl_slice_idx[1] ),
    .recv_const( tile__recv_const[1] ),
    .recv_const_en( tile__recv_const_en[1] ),
    .recv_const_waddr( tile__recv_const_waddr[1] ),
    .recv_data( tile__recv_data[1] ),
    .recv_data_ack( tile__recv_data_ack[1] ),
    .recv_data_valid( tile__recv_data_valid[1] ),
    .recv_lut_b( tile__recv_lut_b[1] ),
    .recv_lut_k( tile__recv_lut_k[1] ),
    .recv_lut_p( tile__recv_lut_p[1] ),
    .recv_opt_waddr( tile__recv_opt_waddr[1] ),
    .recv_opt_waddr_en( tile__recv_opt_waddr_en[1] ),
    .recv_wopt( tile__recv_wopt[1] ),
    .recv_wopt_en( tile__recv_wopt_en[1] ),
    .reset( tile__reset[1] ),
    .send_data( tile__send_data[1] ),
    .send_data_ack( tile__send_data_ack[1] ),
    .send_data_valid( tile__send_data_valid[1] ),
    .send_lut_sel( tile__send_lut_sel[1] ),
    .tile_cmd_el_mode_en( tile__tile_cmd_el_mode_en[1] ),
    .tile_config_ini_begin( tile__tile_config_ini_begin[1] ),
    .tile_dry_run_ack( tile__tile_dry_run_ack[1] ),
    .tile_dry_run_done( tile__tile_dry_run_done[1] ),
    .tile_exe_fsafe_en( tile__tile_exe_fsafe_en[1] ),
    .tile_execution_ini_begin( tile__tile_execution_ini_begin[1] ),
    .tile_execution_valid( tile__tile_execution_valid[1] ),
    .tile_fu_propagate_rdy( tile__tile_fu_propagate_rdy[1] ),
    .tile_iter_th_hit_nxt( tile__tile_iter_th_hit_nxt[1] ),
    .tile_local_reset_a( tile__tile_local_reset_a[1] ),
    .tile_local_reset_b( tile__tile_local_reset_b[1] ),
    .tile_local_reset_c( tile__tile_local_reset_c[1] ),
    .tile_re_execution_ini_begin( tile__tile_re_execution_ini_begin[1] ),
    .tile_sync_dry_run_begin( tile__tile_sync_dry_run_begin[1] ),
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

  TileRTL__ea67303889430dc3 tile__2
  (
    .clk( tile__clk[2] ),
    .config_cmd_counter_base( tile__config_cmd_counter_base[2] ),
    .config_cmd_counter_th( tile__config_cmd_counter_th[2] ),
    .config_cmd_iter_counter_th( tile__config_cmd_iter_counter_th[2] ),
    .config_data_counter_base( tile__config_data_counter_base[2] ),
    .config_data_counter_th( tile__config_data_counter_th[2] ),
    .ctrl_slice_idx( tile__ctrl_slice_idx[2] ),
    .recv_const( tile__recv_const[2] ),
    .recv_const_en( tile__recv_const_en[2] ),
    .recv_const_waddr( tile__recv_const_waddr[2] ),
    .recv_data( tile__recv_data[2] ),
    .recv_data_ack( tile__recv_data_ack[2] ),
    .recv_data_valid( tile__recv_data_valid[2] ),
    .recv_lut_b( tile__recv_lut_b[2] ),
    .recv_lut_k( tile__recv_lut_k[2] ),
    .recv_lut_p( tile__recv_lut_p[2] ),
    .recv_opt_waddr( tile__recv_opt_waddr[2] ),
    .recv_opt_waddr_en( tile__recv_opt_waddr_en[2] ),
    .recv_wopt( tile__recv_wopt[2] ),
    .recv_wopt_en( tile__recv_wopt_en[2] ),
    .reset( tile__reset[2] ),
    .send_data( tile__send_data[2] ),
    .send_data_ack( tile__send_data_ack[2] ),
    .send_data_valid( tile__send_data_valid[2] ),
    .send_lut_sel( tile__send_lut_sel[2] ),
    .tile_cmd_el_mode_en( tile__tile_cmd_el_mode_en[2] ),
    .tile_config_ini_begin( tile__tile_config_ini_begin[2] ),
    .tile_dry_run_ack( tile__tile_dry_run_ack[2] ),
    .tile_dry_run_done( tile__tile_dry_run_done[2] ),
    .tile_exe_fsafe_en( tile__tile_exe_fsafe_en[2] ),
    .tile_execution_ini_begin( tile__tile_execution_ini_begin[2] ),
    .tile_execution_valid( tile__tile_execution_valid[2] ),
    .tile_fu_propagate_rdy( tile__tile_fu_propagate_rdy[2] ),
    .tile_iter_th_hit_nxt( tile__tile_iter_th_hit_nxt[2] ),
    .tile_local_reset_a( tile__tile_local_reset_a[2] ),
    .tile_local_reset_b( tile__tile_local_reset_b[2] ),
    .tile_local_reset_c( tile__tile_local_reset_c[2] ),
    .tile_re_execution_ini_begin( tile__tile_re_execution_ini_begin[2] ),
    .tile_sync_dry_run_begin( tile__tile_sync_dry_run_begin[2] ),
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

  TileRTL__ea67303889430dc3 tile__3
  (
    .clk( tile__clk[3] ),
    .config_cmd_counter_base( tile__config_cmd_counter_base[3] ),
    .config_cmd_counter_th( tile__config_cmd_counter_th[3] ),
    .config_cmd_iter_counter_th( tile__config_cmd_iter_counter_th[3] ),
    .config_data_counter_base( tile__config_data_counter_base[3] ),
    .config_data_counter_th( tile__config_data_counter_th[3] ),
    .ctrl_slice_idx( tile__ctrl_slice_idx[3] ),
    .recv_const( tile__recv_const[3] ),
    .recv_const_en( tile__recv_const_en[3] ),
    .recv_const_waddr( tile__recv_const_waddr[3] ),
    .recv_data( tile__recv_data[3] ),
    .recv_data_ack( tile__recv_data_ack[3] ),
    .recv_data_valid( tile__recv_data_valid[3] ),
    .recv_lut_b( tile__recv_lut_b[3] ),
    .recv_lut_k( tile__recv_lut_k[3] ),
    .recv_lut_p( tile__recv_lut_p[3] ),
    .recv_opt_waddr( tile__recv_opt_waddr[3] ),
    .recv_opt_waddr_en( tile__recv_opt_waddr_en[3] ),
    .recv_wopt( tile__recv_wopt[3] ),
    .recv_wopt_en( tile__recv_wopt_en[3] ),
    .reset( tile__reset[3] ),
    .send_data( tile__send_data[3] ),
    .send_data_ack( tile__send_data_ack[3] ),
    .send_data_valid( tile__send_data_valid[3] ),
    .send_lut_sel( tile__send_lut_sel[3] ),
    .tile_cmd_el_mode_en( tile__tile_cmd_el_mode_en[3] ),
    .tile_config_ini_begin( tile__tile_config_ini_begin[3] ),
    .tile_dry_run_ack( tile__tile_dry_run_ack[3] ),
    .tile_dry_run_done( tile__tile_dry_run_done[3] ),
    .tile_exe_fsafe_en( tile__tile_exe_fsafe_en[3] ),
    .tile_execution_ini_begin( tile__tile_execution_ini_begin[3] ),
    .tile_execution_valid( tile__tile_execution_valid[3] ),
    .tile_fu_propagate_rdy( tile__tile_fu_propagate_rdy[3] ),
    .tile_iter_th_hit_nxt( tile__tile_iter_th_hit_nxt[3] ),
    .tile_local_reset_a( tile__tile_local_reset_a[3] ),
    .tile_local_reset_b( tile__tile_local_reset_b[3] ),
    .tile_local_reset_c( tile__tile_local_reset_c[3] ),
    .tile_re_execution_ini_begin( tile__tile_re_execution_ini_begin[3] ),
    .tile_sync_dry_run_begin( tile__tile_sync_dry_run_begin[3] ),
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

  TileRTL__ea67303889430dc3 tile__4
  (
    .clk( tile__clk[4] ),
    .config_cmd_counter_base( tile__config_cmd_counter_base[4] ),
    .config_cmd_counter_th( tile__config_cmd_counter_th[4] ),
    .config_cmd_iter_counter_th( tile__config_cmd_iter_counter_th[4] ),
    .config_data_counter_base( tile__config_data_counter_base[4] ),
    .config_data_counter_th( tile__config_data_counter_th[4] ),
    .ctrl_slice_idx( tile__ctrl_slice_idx[4] ),
    .recv_const( tile__recv_const[4] ),
    .recv_const_en( tile__recv_const_en[4] ),
    .recv_const_waddr( tile__recv_const_waddr[4] ),
    .recv_data( tile__recv_data[4] ),
    .recv_data_ack( tile__recv_data_ack[4] ),
    .recv_data_valid( tile__recv_data_valid[4] ),
    .recv_lut_b( tile__recv_lut_b[4] ),
    .recv_lut_k( tile__recv_lut_k[4] ),
    .recv_lut_p( tile__recv_lut_p[4] ),
    .recv_opt_waddr( tile__recv_opt_waddr[4] ),
    .recv_opt_waddr_en( tile__recv_opt_waddr_en[4] ),
    .recv_wopt( tile__recv_wopt[4] ),
    .recv_wopt_en( tile__recv_wopt_en[4] ),
    .reset( tile__reset[4] ),
    .send_data( tile__send_data[4] ),
    .send_data_ack( tile__send_data_ack[4] ),
    .send_data_valid( tile__send_data_valid[4] ),
    .send_lut_sel( tile__send_lut_sel[4] ),
    .tile_cmd_el_mode_en( tile__tile_cmd_el_mode_en[4] ),
    .tile_config_ini_begin( tile__tile_config_ini_begin[4] ),
    .tile_dry_run_ack( tile__tile_dry_run_ack[4] ),
    .tile_dry_run_done( tile__tile_dry_run_done[4] ),
    .tile_exe_fsafe_en( tile__tile_exe_fsafe_en[4] ),
    .tile_execution_ini_begin( tile__tile_execution_ini_begin[4] ),
    .tile_execution_valid( tile__tile_execution_valid[4] ),
    .tile_fu_propagate_rdy( tile__tile_fu_propagate_rdy[4] ),
    .tile_iter_th_hit_nxt( tile__tile_iter_th_hit_nxt[4] ),
    .tile_local_reset_a( tile__tile_local_reset_a[4] ),
    .tile_local_reset_b( tile__tile_local_reset_b[4] ),
    .tile_local_reset_c( tile__tile_local_reset_c[4] ),
    .tile_re_execution_ini_begin( tile__tile_re_execution_ini_begin[4] ),
    .tile_sync_dry_run_begin( tile__tile_sync_dry_run_begin[4] ),
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

  TileRTL__ea67303889430dc3 tile__5
  (
    .clk( tile__clk[5] ),
    .config_cmd_counter_base( tile__config_cmd_counter_base[5] ),
    .config_cmd_counter_th( tile__config_cmd_counter_th[5] ),
    .config_cmd_iter_counter_th( tile__config_cmd_iter_counter_th[5] ),
    .config_data_counter_base( tile__config_data_counter_base[5] ),
    .config_data_counter_th( tile__config_data_counter_th[5] ),
    .ctrl_slice_idx( tile__ctrl_slice_idx[5] ),
    .recv_const( tile__recv_const[5] ),
    .recv_const_en( tile__recv_const_en[5] ),
    .recv_const_waddr( tile__recv_const_waddr[5] ),
    .recv_data( tile__recv_data[5] ),
    .recv_data_ack( tile__recv_data_ack[5] ),
    .recv_data_valid( tile__recv_data_valid[5] ),
    .recv_lut_b( tile__recv_lut_b[5] ),
    .recv_lut_k( tile__recv_lut_k[5] ),
    .recv_lut_p( tile__recv_lut_p[5] ),
    .recv_opt_waddr( tile__recv_opt_waddr[5] ),
    .recv_opt_waddr_en( tile__recv_opt_waddr_en[5] ),
    .recv_wopt( tile__recv_wopt[5] ),
    .recv_wopt_en( tile__recv_wopt_en[5] ),
    .reset( tile__reset[5] ),
    .send_data( tile__send_data[5] ),
    .send_data_ack( tile__send_data_ack[5] ),
    .send_data_valid( tile__send_data_valid[5] ),
    .send_lut_sel( tile__send_lut_sel[5] ),
    .tile_cmd_el_mode_en( tile__tile_cmd_el_mode_en[5] ),
    .tile_config_ini_begin( tile__tile_config_ini_begin[5] ),
    .tile_dry_run_ack( tile__tile_dry_run_ack[5] ),
    .tile_dry_run_done( tile__tile_dry_run_done[5] ),
    .tile_exe_fsafe_en( tile__tile_exe_fsafe_en[5] ),
    .tile_execution_ini_begin( tile__tile_execution_ini_begin[5] ),
    .tile_execution_valid( tile__tile_execution_valid[5] ),
    .tile_fu_propagate_rdy( tile__tile_fu_propagate_rdy[5] ),
    .tile_iter_th_hit_nxt( tile__tile_iter_th_hit_nxt[5] ),
    .tile_local_reset_a( tile__tile_local_reset_a[5] ),
    .tile_local_reset_b( tile__tile_local_reset_b[5] ),
    .tile_local_reset_c( tile__tile_local_reset_c[5] ),
    .tile_re_execution_ini_begin( tile__tile_re_execution_ini_begin[5] ),
    .tile_sync_dry_run_begin( tile__tile_sync_dry_run_begin[5] ),
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

  TileRTL__ea67303889430dc3 tile__6
  (
    .clk( tile__clk[6] ),
    .config_cmd_counter_base( tile__config_cmd_counter_base[6] ),
    .config_cmd_counter_th( tile__config_cmd_counter_th[6] ),
    .config_cmd_iter_counter_th( tile__config_cmd_iter_counter_th[6] ),
    .config_data_counter_base( tile__config_data_counter_base[6] ),
    .config_data_counter_th( tile__config_data_counter_th[6] ),
    .ctrl_slice_idx( tile__ctrl_slice_idx[6] ),
    .recv_const( tile__recv_const[6] ),
    .recv_const_en( tile__recv_const_en[6] ),
    .recv_const_waddr( tile__recv_const_waddr[6] ),
    .recv_data( tile__recv_data[6] ),
    .recv_data_ack( tile__recv_data_ack[6] ),
    .recv_data_valid( tile__recv_data_valid[6] ),
    .recv_lut_b( tile__recv_lut_b[6] ),
    .recv_lut_k( tile__recv_lut_k[6] ),
    .recv_lut_p( tile__recv_lut_p[6] ),
    .recv_opt_waddr( tile__recv_opt_waddr[6] ),
    .recv_opt_waddr_en( tile__recv_opt_waddr_en[6] ),
    .recv_wopt( tile__recv_wopt[6] ),
    .recv_wopt_en( tile__recv_wopt_en[6] ),
    .reset( tile__reset[6] ),
    .send_data( tile__send_data[6] ),
    .send_data_ack( tile__send_data_ack[6] ),
    .send_data_valid( tile__send_data_valid[6] ),
    .send_lut_sel( tile__send_lut_sel[6] ),
    .tile_cmd_el_mode_en( tile__tile_cmd_el_mode_en[6] ),
    .tile_config_ini_begin( tile__tile_config_ini_begin[6] ),
    .tile_dry_run_ack( tile__tile_dry_run_ack[6] ),
    .tile_dry_run_done( tile__tile_dry_run_done[6] ),
    .tile_exe_fsafe_en( tile__tile_exe_fsafe_en[6] ),
    .tile_execution_ini_begin( tile__tile_execution_ini_begin[6] ),
    .tile_execution_valid( tile__tile_execution_valid[6] ),
    .tile_fu_propagate_rdy( tile__tile_fu_propagate_rdy[6] ),
    .tile_iter_th_hit_nxt( tile__tile_iter_th_hit_nxt[6] ),
    .tile_local_reset_a( tile__tile_local_reset_a[6] ),
    .tile_local_reset_b( tile__tile_local_reset_b[6] ),
    .tile_local_reset_c( tile__tile_local_reset_c[6] ),
    .tile_re_execution_ini_begin( tile__tile_re_execution_ini_begin[6] ),
    .tile_sync_dry_run_begin( tile__tile_sync_dry_run_begin[6] ),
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

  TileRTL__ea67303889430dc3 tile__7
  (
    .clk( tile__clk[7] ),
    .config_cmd_counter_base( tile__config_cmd_counter_base[7] ),
    .config_cmd_counter_th( tile__config_cmd_counter_th[7] ),
    .config_cmd_iter_counter_th( tile__config_cmd_iter_counter_th[7] ),
    .config_data_counter_base( tile__config_data_counter_base[7] ),
    .config_data_counter_th( tile__config_data_counter_th[7] ),
    .ctrl_slice_idx( tile__ctrl_slice_idx[7] ),
    .recv_const( tile__recv_const[7] ),
    .recv_const_en( tile__recv_const_en[7] ),
    .recv_const_waddr( tile__recv_const_waddr[7] ),
    .recv_data( tile__recv_data[7] ),
    .recv_data_ack( tile__recv_data_ack[7] ),
    .recv_data_valid( tile__recv_data_valid[7] ),
    .recv_lut_b( tile__recv_lut_b[7] ),
    .recv_lut_k( tile__recv_lut_k[7] ),
    .recv_lut_p( tile__recv_lut_p[7] ),
    .recv_opt_waddr( tile__recv_opt_waddr[7] ),
    .recv_opt_waddr_en( tile__recv_opt_waddr_en[7] ),
    .recv_wopt( tile__recv_wopt[7] ),
    .recv_wopt_en( tile__recv_wopt_en[7] ),
    .reset( tile__reset[7] ),
    .send_data( tile__send_data[7] ),
    .send_data_ack( tile__send_data_ack[7] ),
    .send_data_valid( tile__send_data_valid[7] ),
    .send_lut_sel( tile__send_lut_sel[7] ),
    .tile_cmd_el_mode_en( tile__tile_cmd_el_mode_en[7] ),
    .tile_config_ini_begin( tile__tile_config_ini_begin[7] ),
    .tile_dry_run_ack( tile__tile_dry_run_ack[7] ),
    .tile_dry_run_done( tile__tile_dry_run_done[7] ),
    .tile_exe_fsafe_en( tile__tile_exe_fsafe_en[7] ),
    .tile_execution_ini_begin( tile__tile_execution_ini_begin[7] ),
    .tile_execution_valid( tile__tile_execution_valid[7] ),
    .tile_fu_propagate_rdy( tile__tile_fu_propagate_rdy[7] ),
    .tile_iter_th_hit_nxt( tile__tile_iter_th_hit_nxt[7] ),
    .tile_local_reset_a( tile__tile_local_reset_a[7] ),
    .tile_local_reset_b( tile__tile_local_reset_b[7] ),
    .tile_local_reset_c( tile__tile_local_reset_c[7] ),
    .tile_re_execution_ini_begin( tile__tile_re_execution_ini_begin[7] ),
    .tile_sync_dry_run_begin( tile__tile_sync_dry_run_begin[7] ),
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

  TileRTL__ea67303889430dc3 tile__8
  (
    .clk( tile__clk[8] ),
    .config_cmd_counter_base( tile__config_cmd_counter_base[8] ),
    .config_cmd_counter_th( tile__config_cmd_counter_th[8] ),
    .config_cmd_iter_counter_th( tile__config_cmd_iter_counter_th[8] ),
    .config_data_counter_base( tile__config_data_counter_base[8] ),
    .config_data_counter_th( tile__config_data_counter_th[8] ),
    .ctrl_slice_idx( tile__ctrl_slice_idx[8] ),
    .recv_const( tile__recv_const[8] ),
    .recv_const_en( tile__recv_const_en[8] ),
    .recv_const_waddr( tile__recv_const_waddr[8] ),
    .recv_data( tile__recv_data[8] ),
    .recv_data_ack( tile__recv_data_ack[8] ),
    .recv_data_valid( tile__recv_data_valid[8] ),
    .recv_lut_b( tile__recv_lut_b[8] ),
    .recv_lut_k( tile__recv_lut_k[8] ),
    .recv_lut_p( tile__recv_lut_p[8] ),
    .recv_opt_waddr( tile__recv_opt_waddr[8] ),
    .recv_opt_waddr_en( tile__recv_opt_waddr_en[8] ),
    .recv_wopt( tile__recv_wopt[8] ),
    .recv_wopt_en( tile__recv_wopt_en[8] ),
    .reset( tile__reset[8] ),
    .send_data( tile__send_data[8] ),
    .send_data_ack( tile__send_data_ack[8] ),
    .send_data_valid( tile__send_data_valid[8] ),
    .send_lut_sel( tile__send_lut_sel[8] ),
    .tile_cmd_el_mode_en( tile__tile_cmd_el_mode_en[8] ),
    .tile_config_ini_begin( tile__tile_config_ini_begin[8] ),
    .tile_dry_run_ack( tile__tile_dry_run_ack[8] ),
    .tile_dry_run_done( tile__tile_dry_run_done[8] ),
    .tile_exe_fsafe_en( tile__tile_exe_fsafe_en[8] ),
    .tile_execution_ini_begin( tile__tile_execution_ini_begin[8] ),
    .tile_execution_valid( tile__tile_execution_valid[8] ),
    .tile_fu_propagate_rdy( tile__tile_fu_propagate_rdy[8] ),
    .tile_iter_th_hit_nxt( tile__tile_iter_th_hit_nxt[8] ),
    .tile_local_reset_a( tile__tile_local_reset_a[8] ),
    .tile_local_reset_b( tile__tile_local_reset_b[8] ),
    .tile_local_reset_c( tile__tile_local_reset_c[8] ),
    .tile_re_execution_ini_begin( tile__tile_re_execution_ini_begin[8] ),
    .tile_sync_dry_run_begin( tile__tile_sync_dry_run_begin[8] ),
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

  TileRTL__ea67303889430dc3 tile__9
  (
    .clk( tile__clk[9] ),
    .config_cmd_counter_base( tile__config_cmd_counter_base[9] ),
    .config_cmd_counter_th( tile__config_cmd_counter_th[9] ),
    .config_cmd_iter_counter_th( tile__config_cmd_iter_counter_th[9] ),
    .config_data_counter_base( tile__config_data_counter_base[9] ),
    .config_data_counter_th( tile__config_data_counter_th[9] ),
    .ctrl_slice_idx( tile__ctrl_slice_idx[9] ),
    .recv_const( tile__recv_const[9] ),
    .recv_const_en( tile__recv_const_en[9] ),
    .recv_const_waddr( tile__recv_const_waddr[9] ),
    .recv_data( tile__recv_data[9] ),
    .recv_data_ack( tile__recv_data_ack[9] ),
    .recv_data_valid( tile__recv_data_valid[9] ),
    .recv_lut_b( tile__recv_lut_b[9] ),
    .recv_lut_k( tile__recv_lut_k[9] ),
    .recv_lut_p( tile__recv_lut_p[9] ),
    .recv_opt_waddr( tile__recv_opt_waddr[9] ),
    .recv_opt_waddr_en( tile__recv_opt_waddr_en[9] ),
    .recv_wopt( tile__recv_wopt[9] ),
    .recv_wopt_en( tile__recv_wopt_en[9] ),
    .reset( tile__reset[9] ),
    .send_data( tile__send_data[9] ),
    .send_data_ack( tile__send_data_ack[9] ),
    .send_data_valid( tile__send_data_valid[9] ),
    .send_lut_sel( tile__send_lut_sel[9] ),
    .tile_cmd_el_mode_en( tile__tile_cmd_el_mode_en[9] ),
    .tile_config_ini_begin( tile__tile_config_ini_begin[9] ),
    .tile_dry_run_ack( tile__tile_dry_run_ack[9] ),
    .tile_dry_run_done( tile__tile_dry_run_done[9] ),
    .tile_exe_fsafe_en( tile__tile_exe_fsafe_en[9] ),
    .tile_execution_ini_begin( tile__tile_execution_ini_begin[9] ),
    .tile_execution_valid( tile__tile_execution_valid[9] ),
    .tile_fu_propagate_rdy( tile__tile_fu_propagate_rdy[9] ),
    .tile_iter_th_hit_nxt( tile__tile_iter_th_hit_nxt[9] ),
    .tile_local_reset_a( tile__tile_local_reset_a[9] ),
    .tile_local_reset_b( tile__tile_local_reset_b[9] ),
    .tile_local_reset_c( tile__tile_local_reset_c[9] ),
    .tile_re_execution_ini_begin( tile__tile_re_execution_ini_begin[9] ),
    .tile_sync_dry_run_begin( tile__tile_sync_dry_run_begin[9] ),
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

  TileRTL__ea67303889430dc3 tile__10
  (
    .clk( tile__clk[10] ),
    .config_cmd_counter_base( tile__config_cmd_counter_base[10] ),
    .config_cmd_counter_th( tile__config_cmd_counter_th[10] ),
    .config_cmd_iter_counter_th( tile__config_cmd_iter_counter_th[10] ),
    .config_data_counter_base( tile__config_data_counter_base[10] ),
    .config_data_counter_th( tile__config_data_counter_th[10] ),
    .ctrl_slice_idx( tile__ctrl_slice_idx[10] ),
    .recv_const( tile__recv_const[10] ),
    .recv_const_en( tile__recv_const_en[10] ),
    .recv_const_waddr( tile__recv_const_waddr[10] ),
    .recv_data( tile__recv_data[10] ),
    .recv_data_ack( tile__recv_data_ack[10] ),
    .recv_data_valid( tile__recv_data_valid[10] ),
    .recv_lut_b( tile__recv_lut_b[10] ),
    .recv_lut_k( tile__recv_lut_k[10] ),
    .recv_lut_p( tile__recv_lut_p[10] ),
    .recv_opt_waddr( tile__recv_opt_waddr[10] ),
    .recv_opt_waddr_en( tile__recv_opt_waddr_en[10] ),
    .recv_wopt( tile__recv_wopt[10] ),
    .recv_wopt_en( tile__recv_wopt_en[10] ),
    .reset( tile__reset[10] ),
    .send_data( tile__send_data[10] ),
    .send_data_ack( tile__send_data_ack[10] ),
    .send_data_valid( tile__send_data_valid[10] ),
    .send_lut_sel( tile__send_lut_sel[10] ),
    .tile_cmd_el_mode_en( tile__tile_cmd_el_mode_en[10] ),
    .tile_config_ini_begin( tile__tile_config_ini_begin[10] ),
    .tile_dry_run_ack( tile__tile_dry_run_ack[10] ),
    .tile_dry_run_done( tile__tile_dry_run_done[10] ),
    .tile_exe_fsafe_en( tile__tile_exe_fsafe_en[10] ),
    .tile_execution_ini_begin( tile__tile_execution_ini_begin[10] ),
    .tile_execution_valid( tile__tile_execution_valid[10] ),
    .tile_fu_propagate_rdy( tile__tile_fu_propagate_rdy[10] ),
    .tile_iter_th_hit_nxt( tile__tile_iter_th_hit_nxt[10] ),
    .tile_local_reset_a( tile__tile_local_reset_a[10] ),
    .tile_local_reset_b( tile__tile_local_reset_b[10] ),
    .tile_local_reset_c( tile__tile_local_reset_c[10] ),
    .tile_re_execution_ini_begin( tile__tile_re_execution_ini_begin[10] ),
    .tile_sync_dry_run_begin( tile__tile_sync_dry_run_begin[10] ),
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

  TileRTL__ea67303889430dc3 tile__11
  (
    .clk( tile__clk[11] ),
    .config_cmd_counter_base( tile__config_cmd_counter_base[11] ),
    .config_cmd_counter_th( tile__config_cmd_counter_th[11] ),
    .config_cmd_iter_counter_th( tile__config_cmd_iter_counter_th[11] ),
    .config_data_counter_base( tile__config_data_counter_base[11] ),
    .config_data_counter_th( tile__config_data_counter_th[11] ),
    .ctrl_slice_idx( tile__ctrl_slice_idx[11] ),
    .recv_const( tile__recv_const[11] ),
    .recv_const_en( tile__recv_const_en[11] ),
    .recv_const_waddr( tile__recv_const_waddr[11] ),
    .recv_data( tile__recv_data[11] ),
    .recv_data_ack( tile__recv_data_ack[11] ),
    .recv_data_valid( tile__recv_data_valid[11] ),
    .recv_lut_b( tile__recv_lut_b[11] ),
    .recv_lut_k( tile__recv_lut_k[11] ),
    .recv_lut_p( tile__recv_lut_p[11] ),
    .recv_opt_waddr( tile__recv_opt_waddr[11] ),
    .recv_opt_waddr_en( tile__recv_opt_waddr_en[11] ),
    .recv_wopt( tile__recv_wopt[11] ),
    .recv_wopt_en( tile__recv_wopt_en[11] ),
    .reset( tile__reset[11] ),
    .send_data( tile__send_data[11] ),
    .send_data_ack( tile__send_data_ack[11] ),
    .send_data_valid( tile__send_data_valid[11] ),
    .send_lut_sel( tile__send_lut_sel[11] ),
    .tile_cmd_el_mode_en( tile__tile_cmd_el_mode_en[11] ),
    .tile_config_ini_begin( tile__tile_config_ini_begin[11] ),
    .tile_dry_run_ack( tile__tile_dry_run_ack[11] ),
    .tile_dry_run_done( tile__tile_dry_run_done[11] ),
    .tile_exe_fsafe_en( tile__tile_exe_fsafe_en[11] ),
    .tile_execution_ini_begin( tile__tile_execution_ini_begin[11] ),
    .tile_execution_valid( tile__tile_execution_valid[11] ),
    .tile_fu_propagate_rdy( tile__tile_fu_propagate_rdy[11] ),
    .tile_iter_th_hit_nxt( tile__tile_iter_th_hit_nxt[11] ),
    .tile_local_reset_a( tile__tile_local_reset_a[11] ),
    .tile_local_reset_b( tile__tile_local_reset_b[11] ),
    .tile_local_reset_c( tile__tile_local_reset_c[11] ),
    .tile_re_execution_ini_begin( tile__tile_re_execution_ini_begin[11] ),
    .tile_sync_dry_run_begin( tile__tile_sync_dry_run_begin[11] ),
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

  TileRTL__ea67303889430dc3 tile__12
  (
    .clk( tile__clk[12] ),
    .config_cmd_counter_base( tile__config_cmd_counter_base[12] ),
    .config_cmd_counter_th( tile__config_cmd_counter_th[12] ),
    .config_cmd_iter_counter_th( tile__config_cmd_iter_counter_th[12] ),
    .config_data_counter_base( tile__config_data_counter_base[12] ),
    .config_data_counter_th( tile__config_data_counter_th[12] ),
    .ctrl_slice_idx( tile__ctrl_slice_idx[12] ),
    .recv_const( tile__recv_const[12] ),
    .recv_const_en( tile__recv_const_en[12] ),
    .recv_const_waddr( tile__recv_const_waddr[12] ),
    .recv_data( tile__recv_data[12] ),
    .recv_data_ack( tile__recv_data_ack[12] ),
    .recv_data_valid( tile__recv_data_valid[12] ),
    .recv_lut_b( tile__recv_lut_b[12] ),
    .recv_lut_k( tile__recv_lut_k[12] ),
    .recv_lut_p( tile__recv_lut_p[12] ),
    .recv_opt_waddr( tile__recv_opt_waddr[12] ),
    .recv_opt_waddr_en( tile__recv_opt_waddr_en[12] ),
    .recv_wopt( tile__recv_wopt[12] ),
    .recv_wopt_en( tile__recv_wopt_en[12] ),
    .reset( tile__reset[12] ),
    .send_data( tile__send_data[12] ),
    .send_data_ack( tile__send_data_ack[12] ),
    .send_data_valid( tile__send_data_valid[12] ),
    .send_lut_sel( tile__send_lut_sel[12] ),
    .tile_cmd_el_mode_en( tile__tile_cmd_el_mode_en[12] ),
    .tile_config_ini_begin( tile__tile_config_ini_begin[12] ),
    .tile_dry_run_ack( tile__tile_dry_run_ack[12] ),
    .tile_dry_run_done( tile__tile_dry_run_done[12] ),
    .tile_exe_fsafe_en( tile__tile_exe_fsafe_en[12] ),
    .tile_execution_ini_begin( tile__tile_execution_ini_begin[12] ),
    .tile_execution_valid( tile__tile_execution_valid[12] ),
    .tile_fu_propagate_rdy( tile__tile_fu_propagate_rdy[12] ),
    .tile_iter_th_hit_nxt( tile__tile_iter_th_hit_nxt[12] ),
    .tile_local_reset_a( tile__tile_local_reset_a[12] ),
    .tile_local_reset_b( tile__tile_local_reset_b[12] ),
    .tile_local_reset_c( tile__tile_local_reset_c[12] ),
    .tile_re_execution_ini_begin( tile__tile_re_execution_ini_begin[12] ),
    .tile_sync_dry_run_begin( tile__tile_sync_dry_run_begin[12] ),
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

  TileRTL__ea67303889430dc3 tile__13
  (
    .clk( tile__clk[13] ),
    .config_cmd_counter_base( tile__config_cmd_counter_base[13] ),
    .config_cmd_counter_th( tile__config_cmd_counter_th[13] ),
    .config_cmd_iter_counter_th( tile__config_cmd_iter_counter_th[13] ),
    .config_data_counter_base( tile__config_data_counter_base[13] ),
    .config_data_counter_th( tile__config_data_counter_th[13] ),
    .ctrl_slice_idx( tile__ctrl_slice_idx[13] ),
    .recv_const( tile__recv_const[13] ),
    .recv_const_en( tile__recv_const_en[13] ),
    .recv_const_waddr( tile__recv_const_waddr[13] ),
    .recv_data( tile__recv_data[13] ),
    .recv_data_ack( tile__recv_data_ack[13] ),
    .recv_data_valid( tile__recv_data_valid[13] ),
    .recv_lut_b( tile__recv_lut_b[13] ),
    .recv_lut_k( tile__recv_lut_k[13] ),
    .recv_lut_p( tile__recv_lut_p[13] ),
    .recv_opt_waddr( tile__recv_opt_waddr[13] ),
    .recv_opt_waddr_en( tile__recv_opt_waddr_en[13] ),
    .recv_wopt( tile__recv_wopt[13] ),
    .recv_wopt_en( tile__recv_wopt_en[13] ),
    .reset( tile__reset[13] ),
    .send_data( tile__send_data[13] ),
    .send_data_ack( tile__send_data_ack[13] ),
    .send_data_valid( tile__send_data_valid[13] ),
    .send_lut_sel( tile__send_lut_sel[13] ),
    .tile_cmd_el_mode_en( tile__tile_cmd_el_mode_en[13] ),
    .tile_config_ini_begin( tile__tile_config_ini_begin[13] ),
    .tile_dry_run_ack( tile__tile_dry_run_ack[13] ),
    .tile_dry_run_done( tile__tile_dry_run_done[13] ),
    .tile_exe_fsafe_en( tile__tile_exe_fsafe_en[13] ),
    .tile_execution_ini_begin( tile__tile_execution_ini_begin[13] ),
    .tile_execution_valid( tile__tile_execution_valid[13] ),
    .tile_fu_propagate_rdy( tile__tile_fu_propagate_rdy[13] ),
    .tile_iter_th_hit_nxt( tile__tile_iter_th_hit_nxt[13] ),
    .tile_local_reset_a( tile__tile_local_reset_a[13] ),
    .tile_local_reset_b( tile__tile_local_reset_b[13] ),
    .tile_local_reset_c( tile__tile_local_reset_c[13] ),
    .tile_re_execution_ini_begin( tile__tile_re_execution_ini_begin[13] ),
    .tile_sync_dry_run_begin( tile__tile_sync_dry_run_begin[13] ),
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

  TileRTL__ea67303889430dc3 tile__14
  (
    .clk( tile__clk[14] ),
    .config_cmd_counter_base( tile__config_cmd_counter_base[14] ),
    .config_cmd_counter_th( tile__config_cmd_counter_th[14] ),
    .config_cmd_iter_counter_th( tile__config_cmd_iter_counter_th[14] ),
    .config_data_counter_base( tile__config_data_counter_base[14] ),
    .config_data_counter_th( tile__config_data_counter_th[14] ),
    .ctrl_slice_idx( tile__ctrl_slice_idx[14] ),
    .recv_const( tile__recv_const[14] ),
    .recv_const_en( tile__recv_const_en[14] ),
    .recv_const_waddr( tile__recv_const_waddr[14] ),
    .recv_data( tile__recv_data[14] ),
    .recv_data_ack( tile__recv_data_ack[14] ),
    .recv_data_valid( tile__recv_data_valid[14] ),
    .recv_lut_b( tile__recv_lut_b[14] ),
    .recv_lut_k( tile__recv_lut_k[14] ),
    .recv_lut_p( tile__recv_lut_p[14] ),
    .recv_opt_waddr( tile__recv_opt_waddr[14] ),
    .recv_opt_waddr_en( tile__recv_opt_waddr_en[14] ),
    .recv_wopt( tile__recv_wopt[14] ),
    .recv_wopt_en( tile__recv_wopt_en[14] ),
    .reset( tile__reset[14] ),
    .send_data( tile__send_data[14] ),
    .send_data_ack( tile__send_data_ack[14] ),
    .send_data_valid( tile__send_data_valid[14] ),
    .send_lut_sel( tile__send_lut_sel[14] ),
    .tile_cmd_el_mode_en( tile__tile_cmd_el_mode_en[14] ),
    .tile_config_ini_begin( tile__tile_config_ini_begin[14] ),
    .tile_dry_run_ack( tile__tile_dry_run_ack[14] ),
    .tile_dry_run_done( tile__tile_dry_run_done[14] ),
    .tile_exe_fsafe_en( tile__tile_exe_fsafe_en[14] ),
    .tile_execution_ini_begin( tile__tile_execution_ini_begin[14] ),
    .tile_execution_valid( tile__tile_execution_valid[14] ),
    .tile_fu_propagate_rdy( tile__tile_fu_propagate_rdy[14] ),
    .tile_iter_th_hit_nxt( tile__tile_iter_th_hit_nxt[14] ),
    .tile_local_reset_a( tile__tile_local_reset_a[14] ),
    .tile_local_reset_b( tile__tile_local_reset_b[14] ),
    .tile_local_reset_c( tile__tile_local_reset_c[14] ),
    .tile_re_execution_ini_begin( tile__tile_re_execution_ini_begin[14] ),
    .tile_sync_dry_run_begin( tile__tile_sync_dry_run_begin[14] ),
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

  TileRTL__ea67303889430dc3 tile__15
  (
    .clk( tile__clk[15] ),
    .config_cmd_counter_base( tile__config_cmd_counter_base[15] ),
    .config_cmd_counter_th( tile__config_cmd_counter_th[15] ),
    .config_cmd_iter_counter_th( tile__config_cmd_iter_counter_th[15] ),
    .config_data_counter_base( tile__config_data_counter_base[15] ),
    .config_data_counter_th( tile__config_data_counter_th[15] ),
    .ctrl_slice_idx( tile__ctrl_slice_idx[15] ),
    .recv_const( tile__recv_const[15] ),
    .recv_const_en( tile__recv_const_en[15] ),
    .recv_const_waddr( tile__recv_const_waddr[15] ),
    .recv_data( tile__recv_data[15] ),
    .recv_data_ack( tile__recv_data_ack[15] ),
    .recv_data_valid( tile__recv_data_valid[15] ),
    .recv_lut_b( tile__recv_lut_b[15] ),
    .recv_lut_k( tile__recv_lut_k[15] ),
    .recv_lut_p( tile__recv_lut_p[15] ),
    .recv_opt_waddr( tile__recv_opt_waddr[15] ),
    .recv_opt_waddr_en( tile__recv_opt_waddr_en[15] ),
    .recv_wopt( tile__recv_wopt[15] ),
    .recv_wopt_en( tile__recv_wopt_en[15] ),
    .reset( tile__reset[15] ),
    .send_data( tile__send_data[15] ),
    .send_data_ack( tile__send_data_ack[15] ),
    .send_data_valid( tile__send_data_valid[15] ),
    .send_lut_sel( tile__send_lut_sel[15] ),
    .tile_cmd_el_mode_en( tile__tile_cmd_el_mode_en[15] ),
    .tile_config_ini_begin( tile__tile_config_ini_begin[15] ),
    .tile_dry_run_ack( tile__tile_dry_run_ack[15] ),
    .tile_dry_run_done( tile__tile_dry_run_done[15] ),
    .tile_exe_fsafe_en( tile__tile_exe_fsafe_en[15] ),
    .tile_execution_ini_begin( tile__tile_execution_ini_begin[15] ),
    .tile_execution_valid( tile__tile_execution_valid[15] ),
    .tile_fu_propagate_rdy( tile__tile_fu_propagate_rdy[15] ),
    .tile_iter_th_hit_nxt( tile__tile_iter_th_hit_nxt[15] ),
    .tile_local_reset_a( tile__tile_local_reset_a[15] ),
    .tile_local_reset_b( tile__tile_local_reset_b[15] ),
    .tile_local_reset_c( tile__tile_local_reset_c[15] ),
    .tile_re_execution_ini_begin( tile__tile_re_execution_ini_begin[15] ),
    .tile_sync_dry_run_begin( tile__tile_sync_dry_run_begin[15] ),
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
    cgra_config_cmd_done = ( cgra_config_cmd_wopt_done & cgra_config_cmd_dry_run_done ) & ( ( cgra_dry_run_fin | cgra_chaining_en ) | ( cgra_config_cmd_counter_th != cgra_config_dry_run_counter_th ) );
  end

  
  always_comb begin : _lambda__s_cgra_config_cmd_dry_run_done
    cgra_config_cmd_dry_run_done = counter_config_cmd_addr >= cgra_config_dry_run_counter_th;
  end

  
  always_comb begin : _lambda__s_cgra_config_cmd_wopt_done
    cgra_config_cmd_wopt_done = counter_config_cmd_addr == cgra_config_cmd_counter_th;
  end

  
  always_comb begin : _lambda__s_cgra_config_data_done
    cgra_config_data_done = counter_config_data_addr == cgra_config_data_counter_th;
  end

  
  always_comb begin : _lambda__s_cgra_config_lut_done
    cgra_config_lut_done = counter_config_lut_addr == 2'd3;
  end

  
  always_comb begin : _lambda__s_cgra_csr_ro_10_
    cgra_csr_ro[4'd10] = { sub_stage_done_t[2'd3], sub_stage_done_t[2'd2] };
  end

  
  always_comb begin : _lambda__s_cgra_csr_ro_8_
    cgra_csr_ro[4'd8] = { cgra_cur_stage_info, cgra_nxt_stage_info };
  end

  
  always_comb begin : _lambda__s_cgra_csr_ro_9_
    cgra_csr_ro[4'd9] = { sub_stage_done_t[2'd1], sub_stage_done_t[2'd0] };
  end

  
  always_comb begin : _lambda__s_cgra_cur_stage_info
    cgra_cur_stage_info = { { 12 { 1'b0 } }, cur_stage };
  end

  
  always_comb begin : _lambda__s_cgra_cycle_th_hit_0_1_
    cgra_cycle_th_hit[2'd0:2'd0] = ( & sub_stage_done_t[2'( __const__i_at__lambda__s_cgra_cycle_th_hit_0_1_ )] );
  end

  
  always_comb begin : _lambda__s_cgra_cycle_th_hit_1_2_
    cgra_cycle_th_hit[2'd1:2'd1] = ( & sub_stage_done_t[2'( __const__i_at__lambda__s_cgra_cycle_th_hit_1_2_ )] );
  end

  
  always_comb begin : _lambda__s_cgra_cycle_th_hit_2_3_
    cgra_cycle_th_hit[2'd2:2'd2] = ( & sub_stage_done_t[2'( __const__i_at__lambda__s_cgra_cycle_th_hit_2_3_ )] );
  end

  
  always_comb begin : _lambda__s_cgra_cycle_th_hit_3_4_
    cgra_cycle_th_hit[2'd3:2'd3] = ( & sub_stage_done_t[2'( __const__i_at__lambda__s_cgra_cycle_th_hit_3_4_ )] );
  end

  
  always_comb begin : _lambda__s_cgra_nxt_stage_info
    cgra_nxt_stage_info = { { 12 { 1'b0 } }, nxt_stage };
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

  
  always_comb begin : _lambda__s_cgra_recv_wi_data_rdy
    cgra_recv_wi_data_rdy = ( recv_wopt_sliced_flattened_rdy | recv_wconst_flattened_rdy ) | recv_wlut_flattened_rdy;
  end

  
  always_comb begin : _lambda__s_cgra_recv_wi_data_valid
    cgra_recv_wi_data_valid = ( & tile_recv_ni_data_valid );
  end

  
  always_comb begin : _lambda__s_cgra_send_ni_data_0__en
    cgra_send_ni_data__en[3'd0] = tile_send_ni_data_valid[3'( __const__i_at__lambda__s_cgra_send_ni_data_0__en )] & cgra_execution_valid;
  end

  
  always_comb begin : _lambda__s_cgra_send_ni_data_1__en
    cgra_send_ni_data__en[3'd1] = tile_send_ni_data_valid[3'( __const__i_at__lambda__s_cgra_send_ni_data_1__en )] & cgra_execution_valid;
  end

  
  always_comb begin : _lambda__s_cgra_send_ni_data_2__en
    cgra_send_ni_data__en[3'd2] = tile_send_ni_data_valid[3'( __const__i_at__lambda__s_cgra_send_ni_data_2__en )] & cgra_execution_valid;
  end

  
  always_comb begin : _lambda__s_cgra_send_ni_data_3__en
    cgra_send_ni_data__en[3'd3] = tile_send_ni_data_valid[3'( __const__i_at__lambda__s_cgra_send_ni_data_3__en )] & cgra_execution_valid;
  end

  
  always_comb begin : _lambda__s_cgra_send_ni_data_4__en
    cgra_send_ni_data__en[3'd4] = tile_send_ni_data_valid[3'( __const__i_at__lambda__s_cgra_send_ni_data_4__en )] & cgra_execution_valid;
  end

  
  always_comb begin : _lambda__s_cgra_send_ni_data_5__en
    cgra_send_ni_data__en[3'd5] = tile_send_ni_data_valid[3'( __const__i_at__lambda__s_cgra_send_ni_data_5__en )] & cgra_execution_valid;
  end

  
  always_comb begin : _lambda__s_cgra_send_ni_data_6__en
    cgra_send_ni_data__en[3'd6] = tile_send_ni_data_valid[3'( __const__i_at__lambda__s_cgra_send_ni_data_6__en )] & cgra_execution_valid;
  end

  
  always_comb begin : _lambda__s_cgra_send_ni_data_7__en
    cgra_send_ni_data__en[3'd7] = tile_send_ni_data_valid[3'( __const__i_at__lambda__s_cgra_send_ni_data_7__en )] & cgra_execution_valid;
  end

  
  always_comb begin : _lambda__s_recv_wconst_flattened
    recv_wconst_flattened = recv_wconst_flattened_en ? cgra_recv_wi_data : 512'd0;
  end

  
  always_comb begin : _lambda__s_recv_wconst_flattened_en
    recv_wconst_flattened_en = ( cgra_recv_wi_data_rdy & cgra_recv_wi_data_valid ) & cgra_config_data_begin;
  end

  
  always_comb begin : _lambda__s_recv_wlut_flattened
    recv_wlut_flattened = recv_wlut_flattened_en ? cgra_recv_wi_data : 512'd0;
  end

  
  always_comb begin : _lambda__s_recv_wlut_flattened_en
    recv_wlut_flattened_en = ( cgra_recv_wi_data_rdy & cgra_recv_wi_data_valid ) & cgra_config_lut_begin;
  end

  
  always_comb begin : _lambda__s_recv_wopt_sliced_flattened
    recv_wopt_sliced_flattened = recv_wopt_sliced_flattened_en ? cgra_recv_wi_data : 512'd0;
  end

  
  always_comb begin : _lambda__s_recv_wopt_sliced_flattened_en
    recv_wopt_sliced_flattened_en = ( cgra_recv_wi_data_rdy & cgra_recv_wi_data_valid ) & cgra_config_cmd_begin;
  end

  
  always_comb begin : _lambda__s_tile_dry_run_ack_0_
    tile_dry_run_ack[4'd0] = cgra_dry_run_ack & ( counter_config_cmd_addr <= cgra_tile_local_ctrl_1[4'( __const__i_at__lambda__s_tile_dry_run_ack_0_ )][5'd12:5'd8] );
  end

  
  always_comb begin : _lambda__s_tile_dry_run_ack_10_
    tile_dry_run_ack[4'd10] = cgra_dry_run_ack & ( counter_config_cmd_addr <= cgra_tile_local_ctrl_1[4'( __const__i_at__lambda__s_tile_dry_run_ack_10_ )][5'd12:5'd8] );
  end

  
  always_comb begin : _lambda__s_tile_dry_run_ack_11_
    tile_dry_run_ack[4'd11] = cgra_dry_run_ack & ( counter_config_cmd_addr <= cgra_tile_local_ctrl_1[4'( __const__i_at__lambda__s_tile_dry_run_ack_11_ )][5'd12:5'd8] );
  end

  
  always_comb begin : _lambda__s_tile_dry_run_ack_12_
    tile_dry_run_ack[4'd12] = cgra_dry_run_ack & ( counter_config_cmd_addr <= cgra_tile_local_ctrl_1[4'( __const__i_at__lambda__s_tile_dry_run_ack_12_ )][5'd12:5'd8] );
  end

  
  always_comb begin : _lambda__s_tile_dry_run_ack_13_
    tile_dry_run_ack[4'd13] = cgra_dry_run_ack & ( counter_config_cmd_addr <= cgra_tile_local_ctrl_1[4'( __const__i_at__lambda__s_tile_dry_run_ack_13_ )][5'd12:5'd8] );
  end

  
  always_comb begin : _lambda__s_tile_dry_run_ack_14_
    tile_dry_run_ack[4'd14] = cgra_dry_run_ack & ( counter_config_cmd_addr <= cgra_tile_local_ctrl_1[4'( __const__i_at__lambda__s_tile_dry_run_ack_14_ )][5'd12:5'd8] );
  end

  
  always_comb begin : _lambda__s_tile_dry_run_ack_15_
    tile_dry_run_ack[4'd15] = cgra_dry_run_ack & ( counter_config_cmd_addr <= cgra_tile_local_ctrl_1[4'( __const__i_at__lambda__s_tile_dry_run_ack_15_ )][5'd12:5'd8] );
  end

  
  always_comb begin : _lambda__s_tile_dry_run_ack_1_
    tile_dry_run_ack[4'd1] = cgra_dry_run_ack & ( counter_config_cmd_addr <= cgra_tile_local_ctrl_1[4'( __const__i_at__lambda__s_tile_dry_run_ack_1_ )][5'd12:5'd8] );
  end

  
  always_comb begin : _lambda__s_tile_dry_run_ack_2_
    tile_dry_run_ack[4'd2] = cgra_dry_run_ack & ( counter_config_cmd_addr <= cgra_tile_local_ctrl_1[4'( __const__i_at__lambda__s_tile_dry_run_ack_2_ )][5'd12:5'd8] );
  end

  
  always_comb begin : _lambda__s_tile_dry_run_ack_3_
    tile_dry_run_ack[4'd3] = cgra_dry_run_ack & ( counter_config_cmd_addr <= cgra_tile_local_ctrl_1[4'( __const__i_at__lambda__s_tile_dry_run_ack_3_ )][5'd12:5'd8] );
  end

  
  always_comb begin : _lambda__s_tile_dry_run_ack_4_
    tile_dry_run_ack[4'd4] = cgra_dry_run_ack & ( counter_config_cmd_addr <= cgra_tile_local_ctrl_1[4'( __const__i_at__lambda__s_tile_dry_run_ack_4_ )][5'd12:5'd8] );
  end

  
  always_comb begin : _lambda__s_tile_dry_run_ack_5_
    tile_dry_run_ack[4'd5] = cgra_dry_run_ack & ( counter_config_cmd_addr <= cgra_tile_local_ctrl_1[4'( __const__i_at__lambda__s_tile_dry_run_ack_5_ )][5'd12:5'd8] );
  end

  
  always_comb begin : _lambda__s_tile_dry_run_ack_6_
    tile_dry_run_ack[4'd6] = cgra_dry_run_ack & ( counter_config_cmd_addr <= cgra_tile_local_ctrl_1[4'( __const__i_at__lambda__s_tile_dry_run_ack_6_ )][5'd12:5'd8] );
  end

  
  always_comb begin : _lambda__s_tile_dry_run_ack_7_
    tile_dry_run_ack[4'd7] = cgra_dry_run_ack & ( counter_config_cmd_addr <= cgra_tile_local_ctrl_1[4'( __const__i_at__lambda__s_tile_dry_run_ack_7_ )][5'd12:5'd8] );
  end

  
  always_comb begin : _lambda__s_tile_dry_run_ack_8_
    tile_dry_run_ack[4'd8] = cgra_dry_run_ack & ( counter_config_cmd_addr <= cgra_tile_local_ctrl_1[4'( __const__i_at__lambda__s_tile_dry_run_ack_8_ )][5'd12:5'd8] );
  end

  
  always_comb begin : _lambda__s_tile_dry_run_ack_9_
    tile_dry_run_ack[4'd9] = cgra_dry_run_ack & ( counter_config_cmd_addr <= cgra_tile_local_ctrl_1[4'( __const__i_at__lambda__s_tile_dry_run_ack_9_ )][5'd12:5'd8] );
  end

  
  always_comb begin : _lambda__s_tile_recv_opt_waddr_en
    tile_recv_opt_waddr_en = cgra_cmd_dry_run_begin & cgra_config_cmd_begin;
  end

  
  always_comb begin : _lambda__s_tile_send_ni_data_rdy_0_1_
    tile_send_ni_data_rdy[3'd0:3'd0] = cgra_send_ni_data__rdy[3'( __const__i_at__lambda__s_tile_send_ni_data_rdy_0_1_ )] | tile_dry_run_ack[4'( __const__i_at__lambda__s_tile_send_ni_data_rdy_0_1_ )];
  end

  
  always_comb begin : _lambda__s_tile_send_ni_data_rdy_1_2_
    tile_send_ni_data_rdy[3'd1:3'd1] = cgra_send_ni_data__rdy[3'( __const__i_at__lambda__s_tile_send_ni_data_rdy_1_2_ )] | tile_dry_run_ack[4'( __const__i_at__lambda__s_tile_send_ni_data_rdy_1_2_ )];
  end

  
  always_comb begin : _lambda__s_tile_send_ni_data_rdy_2_3_
    tile_send_ni_data_rdy[3'd2:3'd2] = cgra_send_ni_data__rdy[3'( __const__i_at__lambda__s_tile_send_ni_data_rdy_2_3_ )] | tile_dry_run_ack[4'( __const__i_at__lambda__s_tile_send_ni_data_rdy_2_3_ )];
  end

  
  always_comb begin : _lambda__s_tile_send_ni_data_rdy_3_4_
    tile_send_ni_data_rdy[3'd3:3'd3] = cgra_send_ni_data__rdy[3'( __const__i_at__lambda__s_tile_send_ni_data_rdy_3_4_ )] | tile_dry_run_ack[4'( __const__i_at__lambda__s_tile_send_ni_data_rdy_3_4_ )];
  end

  
  always_comb begin : _lambda__s_tile_send_ni_data_rdy_4_5_
    tile_send_ni_data_rdy[3'd4:3'd4] = cgra_send_ni_data__rdy[3'( __const__i_at__lambda__s_tile_send_ni_data_rdy_4_5_ )] | tile_dry_run_ack[4'( __const__i_at__lambda__s_tile_send_ni_data_rdy_4_5_ )];
  end

  
  always_comb begin : _lambda__s_tile_send_ni_data_rdy_5_6_
    tile_send_ni_data_rdy[3'd5:3'd5] = cgra_send_ni_data__rdy[3'( __const__i_at__lambda__s_tile_send_ni_data_rdy_5_6_ )] | tile_dry_run_ack[4'( __const__i_at__lambda__s_tile_send_ni_data_rdy_5_6_ )];
  end

  
  always_comb begin : _lambda__s_tile_send_ni_data_rdy_6_7_
    tile_send_ni_data_rdy[3'd6:3'd6] = cgra_send_ni_data__rdy[3'( __const__i_at__lambda__s_tile_send_ni_data_rdy_6_7_ )] | tile_dry_run_ack[4'( __const__i_at__lambda__s_tile_send_ni_data_rdy_6_7_ )];
  end

  
  always_comb begin : _lambda__s_tile_send_ni_data_rdy_7_8_
    tile_send_ni_data_rdy[3'd7:3'd7] = cgra_send_ni_data__rdy[3'( __const__i_at__lambda__s_tile_send_ni_data_rdy_7_8_ )] | tile_dry_run_ack[4'( __const__i_at__lambda__s_tile_send_ni_data_rdy_7_8_ )];
  end

  
  always_comb begin : fsm_ctrl_signals
    cgra_config_ini_begin = 1'd0;
    cgra_config_lut_begin = 1'd0;
    cgra_config_data_begin = 1'd0;
    cgra_config_cmd_begin = 1'd0;
    cgra_execution_ini_begin = 1'd0;
    cgra_sync_dry_run_begin = 1'd0;
    cgra_execution_valid = 1'd0;
    cgra_csr_rdy = 1'd0;
    cgra_re_execution_begin = 16'd0;
    cgra_tile_local_reset = 1'd0;
    cgra_tile_local_reset_a = 1'd0;
    cgra_tile_local_reset_b = 1'd0;
    cgra_tile_local_reset_c = 1'd0;
    if ( nxt_stage == 4'( __const__STAGE_CONFIG_CTRLREG ) ) begin
      cgra_config_ini_begin = 1'd1;
      cgra_sync_dry_run_begin = ~cgra_chaining_en;
    end
    if ( nxt_stage == 4'( __const__STAGE_CONFIG_LUT ) ) begin
      cgra_config_lut_begin = 1'd1;
    end
    if ( nxt_stage == 4'( __const__STAGE_CONFIG_DATA ) ) begin
      cgra_config_data_begin = 1'd1;
    end
    if ( nxt_stage == 4'( __const__STAGE_CONFIG_CMD ) ) begin
      cgra_config_cmd_begin = 1'd1;
    end
    if ( nxt_stage == 4'( __const__STAGE_CONFIG_DONE ) ) begin
      cgra_execution_ini_begin = 1'd1;
    end
    if ( ( cur_stage == 4'( __const__STAGE_CONFIG_DONE ) ) | ( cur_stage == 4'( __const__STAGE_COMP ) ) ) begin
      for ( int unsigned i = 1'd0; i < 5'd16; i += 1'd1 )
        cgra_re_execution_begin[4'(i)] = ( | sub_stage_sel[4'(i)] ) & cgra_computation_en;
    end
    if ( cur_stage == 4'( __const__STAGE_COMP ) ) begin
      cgra_execution_valid = 1'd1;
    end
    if ( ( ( ( cur_stage == 4'( __const__STAGE_IDLE ) ) | ( cur_stage == 4'( __const__STAGE_CONFIG_CTRLREG ) ) ) | ( cur_stage == 4'( __const__STAGE_CONFIG_DONE ) ) ) | ( cur_stage == 4'( __const__STAGE_COMP_HALT ) ) ) begin
      cgra_csr_rdy = 1'd1;
    end
    if ( cur_stage == 4'( __const__STAGE_COMP_HALT ) ) begin
      cgra_tile_local_reset = cgra_reset_ini_en & cgra_restart_comp_en;
      cgra_tile_local_reset_a = cgra_tile_local_reset & cgra_clear_pipe_en;
      cgra_tile_local_reset_b = cgra_tile_local_reset & ( ~cgra_chaining_en );
      cgra_tile_local_reset_c = cgra_tile_local_reset_b & cgra_config_cmd_en;
    end
  end

  
  always_comb begin : fsm_nxt_stage
    nxt_stage = cur_stage;
    if ( cur_stage == 4'( __const__STAGE_IDLE ) ) begin
      if ( cgra_config_ini_en ) begin
        nxt_stage = 4'( __const__STAGE_CONFIG_CTRLREG );
      end
    end
    if ( cur_stage == 4'( __const__STAGE_CONFIG_CTRLREG ) ) begin
      if ( cgra_config_lut_en ) begin
        nxt_stage = 4'( __const__STAGE_CONFIG_LUT );
      end
      else if ( cgra_config_data_en ) begin
        nxt_stage = 4'( __const__STAGE_CONFIG_DATA );
      end
      else if ( cgra_config_cmd_en ) begin
        nxt_stage = 4'( __const__STAGE_CONFIG_CMD );
      end
      else
        nxt_stage = 4'( __const__STAGE_CONFIG_DONE );
    end
    if ( cur_stage == 4'( __const__STAGE_CONFIG_LUT ) ) begin
      if ( cgra_config_lut_done ) begin
        if ( cgra_config_data_en ) begin
          nxt_stage = 4'( __const__STAGE_CONFIG_DATA );
        end
        else if ( cgra_config_cmd_en ) begin
          nxt_stage = 4'( __const__STAGE_CONFIG_CMD );
        end
        else
          nxt_stage = 4'( __const__STAGE_CONFIG_DONE );
      end
    end
    if ( cur_stage == 4'( __const__STAGE_CONFIG_DATA ) ) begin
      if ( cgra_config_data_done ) begin
        if ( cgra_config_cmd_en ) begin
          nxt_stage = 4'( __const__STAGE_CONFIG_CMD );
        end
        else
          nxt_stage = 4'( __const__STAGE_CONFIG_DONE );
      end
    end
    if ( cur_stage == 4'( __const__STAGE_CONFIG_CMD ) ) begin
      if ( cgra_config_cmd_done ) begin
        nxt_stage = 4'( __const__STAGE_CONFIG_DONE );
      end
    end
    if ( cur_stage == 4'( __const__STAGE_CONFIG_DONE ) ) begin
      if ( cgra_computation_en ) begin
        nxt_stage = 4'( __const__STAGE_COMP );
      end
    end
    if ( cur_stage == 4'( __const__STAGE_COMP ) ) begin
      if ( ( & cgra_cycle_th_hit ) ) begin
        nxt_stage = 4'( __const__STAGE_COMP_HALT );
      end
    end
    if ( cur_stage == 4'( __const__STAGE_COMP_HALT ) ) begin
      if ( cgra_restart_comp_en ) begin
        nxt_stage = 4'( __const__STAGE_CONFIG_CTRLREG );
      end
    end
  end

  
  always_comb begin : sub_fsm_ctrl_signals
    for ( int unsigned i = 1'd0; i < 5'd16; i += 1'd1 ) begin
      sub_stage_done_nxt[4'(i)] = cgra_execution_ini_begin ? ~cgra_sub_stage_en : sub_stage_done[4'(i)];
      sub_stage_sel[4'(i)][2'd0] = ~sub_stage_done[4'(i)][2'd0];
      sub_stage_sel[4'(i)][2'd1] = ( ~sub_stage_done[4'(i)][2'd1] ) & sub_stage_done[4'(i)][2'd0];
      sub_stage_sel[4'(i)][2'd2] = ( ( ~sub_stage_done[4'(i)][2'd2] ) & sub_stage_done[4'(i)][2'd1] ) & sub_stage_done[4'(i)][2'd0];
      sub_stage_sel[4'(i)][2'd3] = ( ( ( ~sub_stage_done[4'(i)][2'd3] ) & sub_stage_done[4'(i)][2'd2] ) & sub_stage_done[4'(i)][2'd1] ) & sub_stage_done[4'(i)][2'd0];
      cgra_tile_cmd_th[4'(i)] = ( ( ( cgra_tile_local_ctrl_1[4'(i)][5'd12:5'd8] & { { 4 { sub_stage_sel[4'(i)][2'd0] } }, sub_stage_sel[4'(i)][2'd0] } ) | ( cgra_tile_local_ctrl_1[4'(i)][5'd20:5'd16] & { { 4 { sub_stage_sel[4'(i)][2'd1] } }, sub_stage_sel[4'(i)][2'd1] } ) ) | ( cgra_tile_local_ctrl_1[4'(i)][5'd28:5'd24] & { { 4 { sub_stage_sel[4'(i)][2'd2] } }, sub_stage_sel[4'(i)][2'd2] } ) ) | ( cgra_config_cmd_counter_th & { { 4 { sub_stage_sel[4'(i)][2'd3] } }, sub_stage_sel[4'(i)][2'd3] } );
      cgra_tile_cmd_base[4'(i)] = ( ( ( cgra_tile_local_ctrl_1[4'(i)][5'd4:5'd0] & { { 4 { sub_stage_sel[4'(i)][2'd0] } }, sub_stage_sel[4'(i)][2'd0] } ) | ( cgra_tile_local_ctrl_1[4'(i)][5'd12:5'd8] & { { 4 { sub_stage_sel[4'(i)][2'd1] } }, sub_stage_sel[4'(i)][2'd1] } ) ) | ( cgra_tile_local_ctrl_1[4'(i)][5'd20:5'd16] & { { 4 { sub_stage_sel[4'(i)][2'd2] } }, sub_stage_sel[4'(i)][2'd2] } ) ) | ( cgra_tile_local_ctrl_1[4'(i)][5'd28:5'd24] & { { 4 { sub_stage_sel[4'(i)][2'd3] } }, sub_stage_sel[4'(i)][2'd3] } );
      cgra_tile_data_th[4'(i)] = ( ( ( cgra_tile_local_ctrl_2[4'(i)][5'd12:5'd8] & { { 4 { sub_stage_sel[4'(i)][2'd0] } }, sub_stage_sel[4'(i)][2'd0] } ) | ( cgra_tile_local_ctrl_2[4'(i)][5'd20:5'd16] & { { 4 { sub_stage_sel[4'(i)][2'd1] } }, sub_stage_sel[4'(i)][2'd1] } ) ) | ( cgra_tile_local_ctrl_2[4'(i)][5'd28:5'd24] & { { 4 { sub_stage_sel[4'(i)][2'd2] } }, sub_stage_sel[4'(i)][2'd2] } ) ) | ( cgra_config_data_counter_th & { { 4 { sub_stage_sel[4'(i)][2'd3] } }, sub_stage_sel[4'(i)][2'd3] } );
      cgra_tile_data_base[4'(i)] = ( ( ( cgra_tile_local_ctrl_2[4'(i)][5'd4:5'd0] & { { 4 { sub_stage_sel[4'(i)][2'd0] } }, sub_stage_sel[4'(i)][2'd0] } ) | ( cgra_tile_local_ctrl_2[4'(i)][5'd12:5'd8] & { { 4 { sub_stage_sel[4'(i)][2'd1] } }, sub_stage_sel[4'(i)][2'd1] } ) ) | ( cgra_tile_local_ctrl_2[4'(i)][5'd20:5'd16] & { { 4 { sub_stage_sel[4'(i)][2'd2] } }, sub_stage_sel[4'(i)][2'd2] } ) ) | ( cgra_tile_local_ctrl_2[4'(i)][5'd28:5'd24] & { { 4 { sub_stage_sel[4'(i)][2'd3] } }, sub_stage_sel[4'(i)][2'd3] } );
      cgra_tile_iter_th[4'(i)] = ( ( ( cgra_sub_stage_iter_th[2'd0] & { { 31 { sub_stage_sel[4'(i)][2'd0] } }, sub_stage_sel[4'(i)][2'd0] } ) | ( cgra_sub_stage_iter_th[2'd1] & { { 31 { sub_stage_sel[4'(i)][2'd1] } }, sub_stage_sel[4'(i)][2'd1] } ) ) | ( cgra_sub_stage_iter_th[2'd2] & { { 31 { sub_stage_sel[4'(i)][2'd2] } }, sub_stage_sel[4'(i)][2'd2] } ) ) | ( cgra_sub_stage_iter_th[2'd3] & { { 31 { sub_stage_sel[4'(i)][2'd3] } }, sub_stage_sel[4'(i)][2'd3] } );
      if ( cgra_re_execution_begin ) begin
        for ( int unsigned j = 1'd0; j < 3'd4; j += 1'd1 )
          sub_stage_done_nxt[4'(i)][2'(j)] = sub_stage_done_nxt[4'(i)][2'(j)] | ( ( ( sub_stage_sel[4'(i)][2'(j)] & tile__tile_iter_th_hit_nxt[4'(i)] ) & tile__tile_fu_propagate_rdy[4'(i)] ) & tile__tile_xbar_propagate_rdy[4'(i)] );
      end
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

  
  always_ff @(posedge clk) begin : csr_rw_buffer_sync
    if ( reset ) begin
      cgra_reset_ini_en <= 1'd0;
      cgra_config_ini_en <= 1'd0;
      cgra_restart_comp_en <= 1'd0;
      cgra_config_lut_en <= 1'd0;
      cgra_config_data_en <= 1'd0;
      cgra_config_cmd_en <= 1'd0;
      cgra_computation_en <= 1'd0;
      cgra_chaining_en <= 1'd0;
      cgra_clear_pipe_en <= 1'd0;
      cgra_exe_fsafe_en <= 1'd0;
      cgra_sub_stage_en <= 4'd0;
      cgra_cmd_el_mode_en <= 1'd0;
      cgra_config_data_counter_th <= 5'd0;
      cgra_config_cmd_counter_th <= 5'd0;
      cgra_config_dry_run_counter_th <= 5'd0;
      for ( int unsigned i = 1'd0; i < 5'd16; i += 1'd1 ) begin
        cgra_tile_local_ctrl_1[4'(i)] <= { 8'd3, 8'd2, 8'd1, 8'd0 };
        cgra_tile_local_ctrl_2[4'(i)] <= { 8'd0, 8'd0, 8'd0, 8'd0 };
      end
      for ( int unsigned i = 1'd0; i < 3'd4; i += 1'd1 )
        cgra_sub_stage_iter_th[2'(i)] <= 32'd1;
    end
    else if ( cgra_csr_rw_valid & cgra_csr_rdy ) begin
      cgra_reset_ini_en <= cgra_csr_rw[6'd0][5'd31];
      cgra_config_ini_en <= cgra_csr_rw[6'd0][5'd30];
      cgra_restart_comp_en <= cgra_csr_rw[6'd0][5'd29];
      cgra_config_lut_en <= cgra_csr_rw[6'd0][5'd28];
      cgra_config_data_en <= cgra_csr_rw[6'd0][5'd27];
      cgra_config_cmd_en <= cgra_csr_rw[6'd0][5'd26];
      cgra_computation_en <= cgra_csr_rw[6'd0][5'd25];
      cgra_chaining_en <= cgra_csr_rw[6'd0][5'd24];
      cgra_clear_pipe_en <= cgra_csr_rw[6'd0][5'd23];
      cgra_exe_fsafe_en <= cgra_csr_rw[6'd0][5'd22];
      cgra_cmd_el_mode_en <= cgra_csr_rw[6'd0][5'd21];
      cgra_sub_stage_en <= cgra_csr_rw[6'd0][5'd18:5'd15];
      cgra_config_dry_run_counter_th <= 5'( cgra_csr_rw[6'd0][5'd14:5'd10] );
      cgra_config_cmd_counter_th <= 5'( cgra_csr_rw[6'd0][5'd9:5'd5] );
      cgra_config_data_counter_th <= 5'( cgra_csr_rw[6'd0][5'd4:5'd0] );
      for ( int unsigned i = 1'd0; i < 5'd16; i += 1'd1 ) begin
        cgra_tile_local_ctrl_1[4'(i)] <= cgra_csr_rw[6'(i) + 6'd1];
        cgra_tile_local_ctrl_2[4'(i)] <= cgra_csr_rw[6'(i) + 6'd17];
      end
      for ( int unsigned i = 1'd0; i < 3'd4; i += 1'd1 )
        cgra_sub_stage_iter_th[2'(i)] <= cgra_csr_rw[6'(i) + 6'd33];
    end
  end

  
  always_ff @(posedge clk) begin : dry_run_ack
    if ( ( reset | ( ~cgra_config_cmd_begin ) ) | cgra_config_cmd_dry_run_done ) begin
      cgra_dry_run_ack <= 1'd0;
    end
    else if ( ~cgra_config_cmd_dry_run_done ) begin
      cgra_dry_run_ack <= tile_recv_opt_waddr_en & ( ~cgra_chaining_en );
    end
  end

  
  always_ff @(posedge clk) begin : dry_run_fin
    if ( reset ) begin
      cgra_dry_run_fin <= 1'd0;
    end
    else
      cgra_dry_run_fin <= cgra_dry_run_ack;
  end

  
  always_ff @(posedge clk) begin : fsm_update
    if ( reset ) begin
      cur_stage <= 4'( __const__STAGE_IDLE );
    end
    else
      cur_stage <= nxt_stage;
  end

  
  always_ff @(posedge clk) begin : perf_counter_process
    if ( reset | cgra_tile_local_reset ) begin
      cgra_pref_counter <= 32'd1;
      for ( int unsigned i = 1'd0; i < 3'd7; i += 1'd1 )
        cgra_pref_counter_ckpt[3'(i)] <= 32'd0;
    end
    else begin
      if ( ( nxt_stage != 4'( __const__STAGE_IDLE ) ) & ( nxt_stage != 4'( __const__STAGE_COMP_HALT ) ) ) begin
        cgra_pref_counter <= cgra_pref_counter + 32'd1;
      end
      if ( cgra_config_ini_begin ) begin
        cgra_pref_counter_ckpt[3'd0] <= cgra_pref_counter;
      end
      if ( ( cgra_config_lut_begin | cgra_config_data_begin ) | cgra_config_cmd_begin ) begin
        cgra_pref_counter_ckpt[3'd1] <= cgra_pref_counter;
      end
      if ( cgra_execution_ini_begin ) begin
        cgra_pref_counter_ckpt[3'd2] <= cgra_pref_counter;
      end
      if ( cgra_re_execution_begin ) begin
        for ( int unsigned i = 1'd0; i < 3'd4; i += 1'd1 )
          if ( ~cgra_cycle_th_hit[2'(i)] ) begin
            cgra_pref_counter_ckpt[3'(i) + 3'd3] <= cgra_pref_counter;
          end
      end
    end
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

  
  always_ff @(posedge clk) begin : stage_ctrl_config_lut
    if ( reset | ( ~cgra_config_lut_begin ) ) begin
      counter_config_lut_addr <= 2'd0;
    end
    else if ( recv_wlut_flattened_en & ( ~cgra_config_lut_done ) ) begin
      counter_config_lut_addr <= counter_config_lut_addr + 2'd1;
    end
  end

  
  always_ff @(posedge clk) begin : sub_fsm_update
    if ( reset | cgra_config_ini_begin ) begin
      for ( int unsigned i = 1'd0; i < 5'd16; i += 1'd1 )
        sub_stage_done[4'(i)] <= 4'd0;
    end
    else
      for ( int unsigned i = 1'd0; i < 5'd16; i += 1'd1 )
        sub_stage_done[4'(i)] <= sub_stage_done_nxt[4'(i)];
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
  assign cgra_recv_wi_data_ack = cgra_recv_wi_data_rdy;
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
  assign lut_array__clk = clk;
  assign lut_array__reset = reset;
  assign cgra_csr_ro[0] = cgra_pref_counter;
  assign cgra_csr_ro[1] = cgra_pref_counter_ckpt[0];
  assign cgra_csr_ro[2] = cgra_pref_counter_ckpt[1];
  assign cgra_csr_ro[3] = cgra_pref_counter_ckpt[2];
  assign cgra_csr_ro[4] = cgra_pref_counter_ckpt[3];
  assign cgra_csr_ro[5] = cgra_pref_counter_ckpt[4];
  assign cgra_csr_ro[6] = cgra_pref_counter_ckpt[5];
  assign cgra_csr_ro[7] = cgra_pref_counter_ckpt[6];
  assign recv_wlut_flattened_rdy = cgra_config_lut_begin;
  assign recv_wconst_flattened_rdy = cgra_config_data_begin;
  assign recv_wopt_sliced_flattened_rdy = cgra_config_cmd_begin;
  assign cgra_csr_rw_ack = cgra_csr_rdy;
  assign sub_stage_done_t[0][0:0] = sub_stage_done[0][0:0];
  assign sub_stage_done_t[0][1:1] = sub_stage_done[1][0:0];
  assign sub_stage_done_t[0][2:2] = sub_stage_done[2][0:0];
  assign sub_stage_done_t[0][3:3] = sub_stage_done[3][0:0];
  assign sub_stage_done_t[0][4:4] = sub_stage_done[4][0:0];
  assign sub_stage_done_t[0][5:5] = sub_stage_done[5][0:0];
  assign sub_stage_done_t[0][6:6] = sub_stage_done[6][0:0];
  assign sub_stage_done_t[0][7:7] = sub_stage_done[7][0:0];
  assign sub_stage_done_t[0][8:8] = sub_stage_done[8][0:0];
  assign sub_stage_done_t[0][9:9] = sub_stage_done[9][0:0];
  assign sub_stage_done_t[0][10:10] = sub_stage_done[10][0:0];
  assign sub_stage_done_t[0][11:11] = sub_stage_done[11][0:0];
  assign sub_stage_done_t[0][12:12] = sub_stage_done[12][0:0];
  assign sub_stage_done_t[0][13:13] = sub_stage_done[13][0:0];
  assign sub_stage_done_t[0][14:14] = sub_stage_done[14][0:0];
  assign sub_stage_done_t[0][15:15] = sub_stage_done[15][0:0];
  assign sub_stage_done_t[1][0:0] = sub_stage_done[0][1:1];
  assign sub_stage_done_t[1][1:1] = sub_stage_done[1][1:1];
  assign sub_stage_done_t[1][2:2] = sub_stage_done[2][1:1];
  assign sub_stage_done_t[1][3:3] = sub_stage_done[3][1:1];
  assign sub_stage_done_t[1][4:4] = sub_stage_done[4][1:1];
  assign sub_stage_done_t[1][5:5] = sub_stage_done[5][1:1];
  assign sub_stage_done_t[1][6:6] = sub_stage_done[6][1:1];
  assign sub_stage_done_t[1][7:7] = sub_stage_done[7][1:1];
  assign sub_stage_done_t[1][8:8] = sub_stage_done[8][1:1];
  assign sub_stage_done_t[1][9:9] = sub_stage_done[9][1:1];
  assign sub_stage_done_t[1][10:10] = sub_stage_done[10][1:1];
  assign sub_stage_done_t[1][11:11] = sub_stage_done[11][1:1];
  assign sub_stage_done_t[1][12:12] = sub_stage_done[12][1:1];
  assign sub_stage_done_t[1][13:13] = sub_stage_done[13][1:1];
  assign sub_stage_done_t[1][14:14] = sub_stage_done[14][1:1];
  assign sub_stage_done_t[1][15:15] = sub_stage_done[15][1:1];
  assign sub_stage_done_t[2][0:0] = sub_stage_done[0][2:2];
  assign sub_stage_done_t[2][1:1] = sub_stage_done[1][2:2];
  assign sub_stage_done_t[2][2:2] = sub_stage_done[2][2:2];
  assign sub_stage_done_t[2][3:3] = sub_stage_done[3][2:2];
  assign sub_stage_done_t[2][4:4] = sub_stage_done[4][2:2];
  assign sub_stage_done_t[2][5:5] = sub_stage_done[5][2:2];
  assign sub_stage_done_t[2][6:6] = sub_stage_done[6][2:2];
  assign sub_stage_done_t[2][7:7] = sub_stage_done[7][2:2];
  assign sub_stage_done_t[2][8:8] = sub_stage_done[8][2:2];
  assign sub_stage_done_t[2][9:9] = sub_stage_done[9][2:2];
  assign sub_stage_done_t[2][10:10] = sub_stage_done[10][2:2];
  assign sub_stage_done_t[2][11:11] = sub_stage_done[11][2:2];
  assign sub_stage_done_t[2][12:12] = sub_stage_done[12][2:2];
  assign sub_stage_done_t[2][13:13] = sub_stage_done[13][2:2];
  assign sub_stage_done_t[2][14:14] = sub_stage_done[14][2:2];
  assign sub_stage_done_t[2][15:15] = sub_stage_done[15][2:2];
  assign sub_stage_done_t[3][0:0] = sub_stage_done[0][3:3];
  assign sub_stage_done_t[3][1:1] = sub_stage_done[1][3:3];
  assign sub_stage_done_t[3][2:2] = sub_stage_done[2][3:3];
  assign sub_stage_done_t[3][3:3] = sub_stage_done[3][3:3];
  assign sub_stage_done_t[3][4:4] = sub_stage_done[4][3:3];
  assign sub_stage_done_t[3][5:5] = sub_stage_done[5][3:3];
  assign sub_stage_done_t[3][6:6] = sub_stage_done[6][3:3];
  assign sub_stage_done_t[3][7:7] = sub_stage_done[7][3:3];
  assign sub_stage_done_t[3][8:8] = sub_stage_done[8][3:3];
  assign sub_stage_done_t[3][9:9] = sub_stage_done[9][3:3];
  assign sub_stage_done_t[3][10:10] = sub_stage_done[10][3:3];
  assign sub_stage_done_t[3][11:11] = sub_stage_done[11][3:3];
  assign sub_stage_done_t[3][12:12] = sub_stage_done[12][3:3];
  assign sub_stage_done_t[3][13:13] = sub_stage_done[13][3:3];
  assign sub_stage_done_t[3][14:14] = sub_stage_done[14][3:3];
  assign sub_stage_done_t[3][15:15] = sub_stage_done[15][3:3];
  assign tile__tile_config_ini_begin[0] = cgra_config_ini_begin;
  assign tile__tile_execution_ini_begin[0] = cgra_execution_ini_begin;
  assign tile__tile_sync_dry_run_begin[0] = cgra_sync_dry_run_begin;
  assign tile__tile_execution_valid[0] = cgra_execution_valid;
  assign tile__tile_dry_run_done[0] = cgra_config_cmd_done;
  assign tile__tile_exe_fsafe_en[0] = cgra_exe_fsafe_en;
  assign tile__tile_cmd_el_mode_en[0] = cgra_cmd_el_mode_en;
  assign tile__tile_dry_run_ack[0] = tile_dry_run_ack[0];
  assign tile__config_cmd_counter_th[0] = cgra_tile_cmd_th[0];
  assign tile__config_cmd_counter_base[0] = cgra_tile_cmd_base[0];
  assign tile__config_data_counter_th[0] = cgra_tile_data_th[0];
  assign tile__config_data_counter_base[0] = cgra_tile_data_base[0];
  assign tile__config_cmd_iter_counter_th[0] = cgra_tile_iter_th[0];
  assign tile__tile_local_reset_a[0] = cgra_tile_local_reset_a;
  assign tile__tile_local_reset_b[0] = cgra_tile_local_reset_b;
  assign tile__tile_local_reset_c[0] = cgra_tile_local_reset_c;
  assign tile__tile_re_execution_ini_begin[0] = cgra_re_execution_begin[0:0];
  assign tile__tile_config_ini_begin[1] = cgra_config_ini_begin;
  assign tile__tile_execution_ini_begin[1] = cgra_execution_ini_begin;
  assign tile__tile_sync_dry_run_begin[1] = cgra_sync_dry_run_begin;
  assign tile__tile_execution_valid[1] = cgra_execution_valid;
  assign tile__tile_dry_run_done[1] = cgra_config_cmd_done;
  assign tile__tile_exe_fsafe_en[1] = cgra_exe_fsafe_en;
  assign tile__tile_cmd_el_mode_en[1] = cgra_cmd_el_mode_en;
  assign tile__tile_dry_run_ack[1] = tile_dry_run_ack[1];
  assign tile__config_cmd_counter_th[1] = cgra_tile_cmd_th[1];
  assign tile__config_cmd_counter_base[1] = cgra_tile_cmd_base[1];
  assign tile__config_data_counter_th[1] = cgra_tile_data_th[1];
  assign tile__config_data_counter_base[1] = cgra_tile_data_base[1];
  assign tile__config_cmd_iter_counter_th[1] = cgra_tile_iter_th[1];
  assign tile__tile_local_reset_a[1] = cgra_tile_local_reset_a;
  assign tile__tile_local_reset_b[1] = cgra_tile_local_reset_b;
  assign tile__tile_local_reset_c[1] = cgra_tile_local_reset_c;
  assign tile__tile_re_execution_ini_begin[1] = cgra_re_execution_begin[1:1];
  assign tile__tile_config_ini_begin[2] = cgra_config_ini_begin;
  assign tile__tile_execution_ini_begin[2] = cgra_execution_ini_begin;
  assign tile__tile_sync_dry_run_begin[2] = cgra_sync_dry_run_begin;
  assign tile__tile_execution_valid[2] = cgra_execution_valid;
  assign tile__tile_dry_run_done[2] = cgra_config_cmd_done;
  assign tile__tile_exe_fsafe_en[2] = cgra_exe_fsafe_en;
  assign tile__tile_cmd_el_mode_en[2] = cgra_cmd_el_mode_en;
  assign tile__tile_dry_run_ack[2] = tile_dry_run_ack[2];
  assign tile__config_cmd_counter_th[2] = cgra_tile_cmd_th[2];
  assign tile__config_cmd_counter_base[2] = cgra_tile_cmd_base[2];
  assign tile__config_data_counter_th[2] = cgra_tile_data_th[2];
  assign tile__config_data_counter_base[2] = cgra_tile_data_base[2];
  assign tile__config_cmd_iter_counter_th[2] = cgra_tile_iter_th[2];
  assign tile__tile_local_reset_a[2] = cgra_tile_local_reset_a;
  assign tile__tile_local_reset_b[2] = cgra_tile_local_reset_b;
  assign tile__tile_local_reset_c[2] = cgra_tile_local_reset_c;
  assign tile__tile_re_execution_ini_begin[2] = cgra_re_execution_begin[2:2];
  assign tile__tile_config_ini_begin[3] = cgra_config_ini_begin;
  assign tile__tile_execution_ini_begin[3] = cgra_execution_ini_begin;
  assign tile__tile_sync_dry_run_begin[3] = cgra_sync_dry_run_begin;
  assign tile__tile_execution_valid[3] = cgra_execution_valid;
  assign tile__tile_dry_run_done[3] = cgra_config_cmd_done;
  assign tile__tile_exe_fsafe_en[3] = cgra_exe_fsafe_en;
  assign tile__tile_cmd_el_mode_en[3] = cgra_cmd_el_mode_en;
  assign tile__tile_dry_run_ack[3] = tile_dry_run_ack[3];
  assign tile__config_cmd_counter_th[3] = cgra_tile_cmd_th[3];
  assign tile__config_cmd_counter_base[3] = cgra_tile_cmd_base[3];
  assign tile__config_data_counter_th[3] = cgra_tile_data_th[3];
  assign tile__config_data_counter_base[3] = cgra_tile_data_base[3];
  assign tile__config_cmd_iter_counter_th[3] = cgra_tile_iter_th[3];
  assign tile__tile_local_reset_a[3] = cgra_tile_local_reset_a;
  assign tile__tile_local_reset_b[3] = cgra_tile_local_reset_b;
  assign tile__tile_local_reset_c[3] = cgra_tile_local_reset_c;
  assign tile__tile_re_execution_ini_begin[3] = cgra_re_execution_begin[3:3];
  assign tile__tile_config_ini_begin[4] = cgra_config_ini_begin;
  assign tile__tile_execution_ini_begin[4] = cgra_execution_ini_begin;
  assign tile__tile_sync_dry_run_begin[4] = cgra_sync_dry_run_begin;
  assign tile__tile_execution_valid[4] = cgra_execution_valid;
  assign tile__tile_dry_run_done[4] = cgra_config_cmd_done;
  assign tile__tile_exe_fsafe_en[4] = cgra_exe_fsafe_en;
  assign tile__tile_cmd_el_mode_en[4] = cgra_cmd_el_mode_en;
  assign tile__tile_dry_run_ack[4] = tile_dry_run_ack[4];
  assign tile__config_cmd_counter_th[4] = cgra_tile_cmd_th[4];
  assign tile__config_cmd_counter_base[4] = cgra_tile_cmd_base[4];
  assign tile__config_data_counter_th[4] = cgra_tile_data_th[4];
  assign tile__config_data_counter_base[4] = cgra_tile_data_base[4];
  assign tile__config_cmd_iter_counter_th[4] = cgra_tile_iter_th[4];
  assign tile__tile_local_reset_a[4] = cgra_tile_local_reset_a;
  assign tile__tile_local_reset_b[4] = cgra_tile_local_reset_b;
  assign tile__tile_local_reset_c[4] = cgra_tile_local_reset_c;
  assign tile__tile_re_execution_ini_begin[4] = cgra_re_execution_begin[4:4];
  assign tile__tile_config_ini_begin[5] = cgra_config_ini_begin;
  assign tile__tile_execution_ini_begin[5] = cgra_execution_ini_begin;
  assign tile__tile_sync_dry_run_begin[5] = cgra_sync_dry_run_begin;
  assign tile__tile_execution_valid[5] = cgra_execution_valid;
  assign tile__tile_dry_run_done[5] = cgra_config_cmd_done;
  assign tile__tile_exe_fsafe_en[5] = cgra_exe_fsafe_en;
  assign tile__tile_cmd_el_mode_en[5] = cgra_cmd_el_mode_en;
  assign tile__tile_dry_run_ack[5] = tile_dry_run_ack[5];
  assign tile__config_cmd_counter_th[5] = cgra_tile_cmd_th[5];
  assign tile__config_cmd_counter_base[5] = cgra_tile_cmd_base[5];
  assign tile__config_data_counter_th[5] = cgra_tile_data_th[5];
  assign tile__config_data_counter_base[5] = cgra_tile_data_base[5];
  assign tile__config_cmd_iter_counter_th[5] = cgra_tile_iter_th[5];
  assign tile__tile_local_reset_a[5] = cgra_tile_local_reset_a;
  assign tile__tile_local_reset_b[5] = cgra_tile_local_reset_b;
  assign tile__tile_local_reset_c[5] = cgra_tile_local_reset_c;
  assign tile__tile_re_execution_ini_begin[5] = cgra_re_execution_begin[5:5];
  assign tile__tile_config_ini_begin[6] = cgra_config_ini_begin;
  assign tile__tile_execution_ini_begin[6] = cgra_execution_ini_begin;
  assign tile__tile_sync_dry_run_begin[6] = cgra_sync_dry_run_begin;
  assign tile__tile_execution_valid[6] = cgra_execution_valid;
  assign tile__tile_dry_run_done[6] = cgra_config_cmd_done;
  assign tile__tile_exe_fsafe_en[6] = cgra_exe_fsafe_en;
  assign tile__tile_cmd_el_mode_en[6] = cgra_cmd_el_mode_en;
  assign tile__tile_dry_run_ack[6] = tile_dry_run_ack[6];
  assign tile__config_cmd_counter_th[6] = cgra_tile_cmd_th[6];
  assign tile__config_cmd_counter_base[6] = cgra_tile_cmd_base[6];
  assign tile__config_data_counter_th[6] = cgra_tile_data_th[6];
  assign tile__config_data_counter_base[6] = cgra_tile_data_base[6];
  assign tile__config_cmd_iter_counter_th[6] = cgra_tile_iter_th[6];
  assign tile__tile_local_reset_a[6] = cgra_tile_local_reset_a;
  assign tile__tile_local_reset_b[6] = cgra_tile_local_reset_b;
  assign tile__tile_local_reset_c[6] = cgra_tile_local_reset_c;
  assign tile__tile_re_execution_ini_begin[6] = cgra_re_execution_begin[6:6];
  assign tile__tile_config_ini_begin[7] = cgra_config_ini_begin;
  assign tile__tile_execution_ini_begin[7] = cgra_execution_ini_begin;
  assign tile__tile_sync_dry_run_begin[7] = cgra_sync_dry_run_begin;
  assign tile__tile_execution_valid[7] = cgra_execution_valid;
  assign tile__tile_dry_run_done[7] = cgra_config_cmd_done;
  assign tile__tile_exe_fsafe_en[7] = cgra_exe_fsafe_en;
  assign tile__tile_cmd_el_mode_en[7] = cgra_cmd_el_mode_en;
  assign tile__tile_dry_run_ack[7] = tile_dry_run_ack[7];
  assign tile__config_cmd_counter_th[7] = cgra_tile_cmd_th[7];
  assign tile__config_cmd_counter_base[7] = cgra_tile_cmd_base[7];
  assign tile__config_data_counter_th[7] = cgra_tile_data_th[7];
  assign tile__config_data_counter_base[7] = cgra_tile_data_base[7];
  assign tile__config_cmd_iter_counter_th[7] = cgra_tile_iter_th[7];
  assign tile__tile_local_reset_a[7] = cgra_tile_local_reset_a;
  assign tile__tile_local_reset_b[7] = cgra_tile_local_reset_b;
  assign tile__tile_local_reset_c[7] = cgra_tile_local_reset_c;
  assign tile__tile_re_execution_ini_begin[7] = cgra_re_execution_begin[7:7];
  assign tile__tile_config_ini_begin[8] = cgra_config_ini_begin;
  assign tile__tile_execution_ini_begin[8] = cgra_execution_ini_begin;
  assign tile__tile_sync_dry_run_begin[8] = cgra_sync_dry_run_begin;
  assign tile__tile_execution_valid[8] = cgra_execution_valid;
  assign tile__tile_dry_run_done[8] = cgra_config_cmd_done;
  assign tile__tile_exe_fsafe_en[8] = cgra_exe_fsafe_en;
  assign tile__tile_cmd_el_mode_en[8] = cgra_cmd_el_mode_en;
  assign tile__tile_dry_run_ack[8] = tile_dry_run_ack[8];
  assign tile__config_cmd_counter_th[8] = cgra_tile_cmd_th[8];
  assign tile__config_cmd_counter_base[8] = cgra_tile_cmd_base[8];
  assign tile__config_data_counter_th[8] = cgra_tile_data_th[8];
  assign tile__config_data_counter_base[8] = cgra_tile_data_base[8];
  assign tile__config_cmd_iter_counter_th[8] = cgra_tile_iter_th[8];
  assign tile__tile_local_reset_a[8] = cgra_tile_local_reset_a;
  assign tile__tile_local_reset_b[8] = cgra_tile_local_reset_b;
  assign tile__tile_local_reset_c[8] = cgra_tile_local_reset_c;
  assign tile__tile_re_execution_ini_begin[8] = cgra_re_execution_begin[8:8];
  assign tile__tile_config_ini_begin[9] = cgra_config_ini_begin;
  assign tile__tile_execution_ini_begin[9] = cgra_execution_ini_begin;
  assign tile__tile_sync_dry_run_begin[9] = cgra_sync_dry_run_begin;
  assign tile__tile_execution_valid[9] = cgra_execution_valid;
  assign tile__tile_dry_run_done[9] = cgra_config_cmd_done;
  assign tile__tile_exe_fsafe_en[9] = cgra_exe_fsafe_en;
  assign tile__tile_cmd_el_mode_en[9] = cgra_cmd_el_mode_en;
  assign tile__tile_dry_run_ack[9] = tile_dry_run_ack[9];
  assign tile__config_cmd_counter_th[9] = cgra_tile_cmd_th[9];
  assign tile__config_cmd_counter_base[9] = cgra_tile_cmd_base[9];
  assign tile__config_data_counter_th[9] = cgra_tile_data_th[9];
  assign tile__config_data_counter_base[9] = cgra_tile_data_base[9];
  assign tile__config_cmd_iter_counter_th[9] = cgra_tile_iter_th[9];
  assign tile__tile_local_reset_a[9] = cgra_tile_local_reset_a;
  assign tile__tile_local_reset_b[9] = cgra_tile_local_reset_b;
  assign tile__tile_local_reset_c[9] = cgra_tile_local_reset_c;
  assign tile__tile_re_execution_ini_begin[9] = cgra_re_execution_begin[9:9];
  assign tile__tile_config_ini_begin[10] = cgra_config_ini_begin;
  assign tile__tile_execution_ini_begin[10] = cgra_execution_ini_begin;
  assign tile__tile_sync_dry_run_begin[10] = cgra_sync_dry_run_begin;
  assign tile__tile_execution_valid[10] = cgra_execution_valid;
  assign tile__tile_dry_run_done[10] = cgra_config_cmd_done;
  assign tile__tile_exe_fsafe_en[10] = cgra_exe_fsafe_en;
  assign tile__tile_cmd_el_mode_en[10] = cgra_cmd_el_mode_en;
  assign tile__tile_dry_run_ack[10] = tile_dry_run_ack[10];
  assign tile__config_cmd_counter_th[10] = cgra_tile_cmd_th[10];
  assign tile__config_cmd_counter_base[10] = cgra_tile_cmd_base[10];
  assign tile__config_data_counter_th[10] = cgra_tile_data_th[10];
  assign tile__config_data_counter_base[10] = cgra_tile_data_base[10];
  assign tile__config_cmd_iter_counter_th[10] = cgra_tile_iter_th[10];
  assign tile__tile_local_reset_a[10] = cgra_tile_local_reset_a;
  assign tile__tile_local_reset_b[10] = cgra_tile_local_reset_b;
  assign tile__tile_local_reset_c[10] = cgra_tile_local_reset_c;
  assign tile__tile_re_execution_ini_begin[10] = cgra_re_execution_begin[10:10];
  assign tile__tile_config_ini_begin[11] = cgra_config_ini_begin;
  assign tile__tile_execution_ini_begin[11] = cgra_execution_ini_begin;
  assign tile__tile_sync_dry_run_begin[11] = cgra_sync_dry_run_begin;
  assign tile__tile_execution_valid[11] = cgra_execution_valid;
  assign tile__tile_dry_run_done[11] = cgra_config_cmd_done;
  assign tile__tile_exe_fsafe_en[11] = cgra_exe_fsafe_en;
  assign tile__tile_cmd_el_mode_en[11] = cgra_cmd_el_mode_en;
  assign tile__tile_dry_run_ack[11] = tile_dry_run_ack[11];
  assign tile__config_cmd_counter_th[11] = cgra_tile_cmd_th[11];
  assign tile__config_cmd_counter_base[11] = cgra_tile_cmd_base[11];
  assign tile__config_data_counter_th[11] = cgra_tile_data_th[11];
  assign tile__config_data_counter_base[11] = cgra_tile_data_base[11];
  assign tile__config_cmd_iter_counter_th[11] = cgra_tile_iter_th[11];
  assign tile__tile_local_reset_a[11] = cgra_tile_local_reset_a;
  assign tile__tile_local_reset_b[11] = cgra_tile_local_reset_b;
  assign tile__tile_local_reset_c[11] = cgra_tile_local_reset_c;
  assign tile__tile_re_execution_ini_begin[11] = cgra_re_execution_begin[11:11];
  assign tile__tile_config_ini_begin[12] = cgra_config_ini_begin;
  assign tile__tile_execution_ini_begin[12] = cgra_execution_ini_begin;
  assign tile__tile_sync_dry_run_begin[12] = cgra_sync_dry_run_begin;
  assign tile__tile_execution_valid[12] = cgra_execution_valid;
  assign tile__tile_dry_run_done[12] = cgra_config_cmd_done;
  assign tile__tile_exe_fsafe_en[12] = cgra_exe_fsafe_en;
  assign tile__tile_cmd_el_mode_en[12] = cgra_cmd_el_mode_en;
  assign tile__tile_dry_run_ack[12] = tile_dry_run_ack[12];
  assign tile__config_cmd_counter_th[12] = cgra_tile_cmd_th[12];
  assign tile__config_cmd_counter_base[12] = cgra_tile_cmd_base[12];
  assign tile__config_data_counter_th[12] = cgra_tile_data_th[12];
  assign tile__config_data_counter_base[12] = cgra_tile_data_base[12];
  assign tile__config_cmd_iter_counter_th[12] = cgra_tile_iter_th[12];
  assign tile__tile_local_reset_a[12] = cgra_tile_local_reset_a;
  assign tile__tile_local_reset_b[12] = cgra_tile_local_reset_b;
  assign tile__tile_local_reset_c[12] = cgra_tile_local_reset_c;
  assign tile__tile_re_execution_ini_begin[12] = cgra_re_execution_begin[12:12];
  assign tile__tile_config_ini_begin[13] = cgra_config_ini_begin;
  assign tile__tile_execution_ini_begin[13] = cgra_execution_ini_begin;
  assign tile__tile_sync_dry_run_begin[13] = cgra_sync_dry_run_begin;
  assign tile__tile_execution_valid[13] = cgra_execution_valid;
  assign tile__tile_dry_run_done[13] = cgra_config_cmd_done;
  assign tile__tile_exe_fsafe_en[13] = cgra_exe_fsafe_en;
  assign tile__tile_cmd_el_mode_en[13] = cgra_cmd_el_mode_en;
  assign tile__tile_dry_run_ack[13] = tile_dry_run_ack[13];
  assign tile__config_cmd_counter_th[13] = cgra_tile_cmd_th[13];
  assign tile__config_cmd_counter_base[13] = cgra_tile_cmd_base[13];
  assign tile__config_data_counter_th[13] = cgra_tile_data_th[13];
  assign tile__config_data_counter_base[13] = cgra_tile_data_base[13];
  assign tile__config_cmd_iter_counter_th[13] = cgra_tile_iter_th[13];
  assign tile__tile_local_reset_a[13] = cgra_tile_local_reset_a;
  assign tile__tile_local_reset_b[13] = cgra_tile_local_reset_b;
  assign tile__tile_local_reset_c[13] = cgra_tile_local_reset_c;
  assign tile__tile_re_execution_ini_begin[13] = cgra_re_execution_begin[13:13];
  assign tile__tile_config_ini_begin[14] = cgra_config_ini_begin;
  assign tile__tile_execution_ini_begin[14] = cgra_execution_ini_begin;
  assign tile__tile_sync_dry_run_begin[14] = cgra_sync_dry_run_begin;
  assign tile__tile_execution_valid[14] = cgra_execution_valid;
  assign tile__tile_dry_run_done[14] = cgra_config_cmd_done;
  assign tile__tile_exe_fsafe_en[14] = cgra_exe_fsafe_en;
  assign tile__tile_cmd_el_mode_en[14] = cgra_cmd_el_mode_en;
  assign tile__tile_dry_run_ack[14] = tile_dry_run_ack[14];
  assign tile__config_cmd_counter_th[14] = cgra_tile_cmd_th[14];
  assign tile__config_cmd_counter_base[14] = cgra_tile_cmd_base[14];
  assign tile__config_data_counter_th[14] = cgra_tile_data_th[14];
  assign tile__config_data_counter_base[14] = cgra_tile_data_base[14];
  assign tile__config_cmd_iter_counter_th[14] = cgra_tile_iter_th[14];
  assign tile__tile_local_reset_a[14] = cgra_tile_local_reset_a;
  assign tile__tile_local_reset_b[14] = cgra_tile_local_reset_b;
  assign tile__tile_local_reset_c[14] = cgra_tile_local_reset_c;
  assign tile__tile_re_execution_ini_begin[14] = cgra_re_execution_begin[14:14];
  assign tile__tile_config_ini_begin[15] = cgra_config_ini_begin;
  assign tile__tile_execution_ini_begin[15] = cgra_execution_ini_begin;
  assign tile__tile_sync_dry_run_begin[15] = cgra_sync_dry_run_begin;
  assign tile__tile_execution_valid[15] = cgra_execution_valid;
  assign tile__tile_dry_run_done[15] = cgra_config_cmd_done;
  assign tile__tile_exe_fsafe_en[15] = cgra_exe_fsafe_en;
  assign tile__tile_cmd_el_mode_en[15] = cgra_cmd_el_mode_en;
  assign tile__tile_dry_run_ack[15] = tile_dry_run_ack[15];
  assign tile__config_cmd_counter_th[15] = cgra_tile_cmd_th[15];
  assign tile__config_cmd_counter_base[15] = cgra_tile_cmd_base[15];
  assign tile__config_data_counter_th[15] = cgra_tile_data_th[15];
  assign tile__config_data_counter_base[15] = cgra_tile_data_base[15];
  assign tile__config_cmd_iter_counter_th[15] = cgra_tile_iter_th[15];
  assign tile__tile_local_reset_a[15] = cgra_tile_local_reset_a;
  assign tile__tile_local_reset_b[15] = cgra_tile_local_reset_b;
  assign tile__tile_local_reset_c[15] = cgra_tile_local_reset_c;
  assign tile__tile_re_execution_ini_begin[15] = cgra_re_execution_begin[15:15];
  assign lut_array__recv_waddr = counter_config_lut_addr[1:0];
  assign lut_array__recv_waddr_en = recv_wlut_flattened_en;
  assign lut_array__recv_lut_data = recv_wlut_flattened;
  assign lut_array__recv_raddr[0] = tile__send_lut_sel[0];
  assign tile__recv_lut_k[0] = lut_array__send_lut_k[0];
  assign tile__recv_lut_b[0] = lut_array__send_lut_b[0];
  assign tile__recv_lut_p[0] = lut_array__send_lut_p[0];
  assign lut_array__recv_raddr[1] = tile__send_lut_sel[1];
  assign tile__recv_lut_k[1] = lut_array__send_lut_k[1];
  assign tile__recv_lut_b[1] = lut_array__send_lut_b[1];
  assign tile__recv_lut_p[1] = lut_array__send_lut_p[1];
  assign lut_array__recv_raddr[2] = tile__send_lut_sel[2];
  assign tile__recv_lut_k[2] = lut_array__send_lut_k[2];
  assign tile__recv_lut_b[2] = lut_array__send_lut_b[2];
  assign tile__recv_lut_p[2] = lut_array__send_lut_p[2];
  assign lut_array__recv_raddr[3] = tile__send_lut_sel[3];
  assign tile__recv_lut_k[3] = lut_array__send_lut_k[3];
  assign tile__recv_lut_b[3] = lut_array__send_lut_b[3];
  assign tile__recv_lut_p[3] = lut_array__send_lut_p[3];
  assign lut_array__recv_raddr[4] = tile__send_lut_sel[4];
  assign tile__recv_lut_k[4] = lut_array__send_lut_k[4];
  assign tile__recv_lut_b[4] = lut_array__send_lut_b[4];
  assign tile__recv_lut_p[4] = lut_array__send_lut_p[4];
  assign lut_array__recv_raddr[5] = tile__send_lut_sel[5];
  assign tile__recv_lut_k[5] = lut_array__send_lut_k[5];
  assign tile__recv_lut_b[5] = lut_array__send_lut_b[5];
  assign tile__recv_lut_p[5] = lut_array__send_lut_p[5];
  assign lut_array__recv_raddr[6] = tile__send_lut_sel[6];
  assign tile__recv_lut_k[6] = lut_array__send_lut_k[6];
  assign tile__recv_lut_b[6] = lut_array__send_lut_b[6];
  assign tile__recv_lut_p[6] = lut_array__send_lut_p[6];
  assign lut_array__recv_raddr[7] = tile__send_lut_sel[7];
  assign tile__recv_lut_k[7] = lut_array__send_lut_k[7];
  assign tile__recv_lut_b[7] = lut_array__send_lut_b[7];
  assign tile__recv_lut_p[7] = lut_array__send_lut_p[7];
  assign lut_array__recv_raddr[8] = tile__send_lut_sel[8];
  assign tile__recv_lut_k[8] = lut_array__send_lut_k[8];
  assign tile__recv_lut_b[8] = lut_array__send_lut_b[8];
  assign tile__recv_lut_p[8] = lut_array__send_lut_p[8];
  assign lut_array__recv_raddr[9] = tile__send_lut_sel[9];
  assign tile__recv_lut_k[9] = lut_array__send_lut_k[9];
  assign tile__recv_lut_b[9] = lut_array__send_lut_b[9];
  assign tile__recv_lut_p[9] = lut_array__send_lut_p[9];
  assign lut_array__recv_raddr[10] = tile__send_lut_sel[10];
  assign tile__recv_lut_k[10] = lut_array__send_lut_k[10];
  assign tile__recv_lut_b[10] = lut_array__send_lut_b[10];
  assign tile__recv_lut_p[10] = lut_array__send_lut_p[10];
  assign lut_array__recv_raddr[11] = tile__send_lut_sel[11];
  assign tile__recv_lut_k[11] = lut_array__send_lut_k[11];
  assign tile__recv_lut_b[11] = lut_array__send_lut_b[11];
  assign tile__recv_lut_p[11] = lut_array__send_lut_p[11];
  assign lut_array__recv_raddr[12] = tile__send_lut_sel[12];
  assign tile__recv_lut_k[12] = lut_array__send_lut_k[12];
  assign tile__recv_lut_b[12] = lut_array__send_lut_b[12];
  assign tile__recv_lut_p[12] = lut_array__send_lut_p[12];
  assign lut_array__recv_raddr[13] = tile__send_lut_sel[13];
  assign tile__recv_lut_k[13] = lut_array__send_lut_k[13];
  assign tile__recv_lut_b[13] = lut_array__send_lut_b[13];
  assign tile__recv_lut_p[13] = lut_array__send_lut_p[13];
  assign lut_array__recv_raddr[14] = tile__send_lut_sel[14];
  assign tile__recv_lut_k[14] = lut_array__send_lut_k[14];
  assign tile__recv_lut_b[14] = lut_array__send_lut_b[14];
  assign tile__recv_lut_p[14] = lut_array__send_lut_p[14];
  assign lut_array__recv_raddr[15] = tile__send_lut_sel[15];
  assign tile__recv_lut_k[15] = lut_array__send_lut_k[15];
  assign tile__recv_lut_b[15] = lut_array__send_lut_b[15];
  assign tile__recv_lut_p[15] = lut_array__send_lut_p[15];
  assign tile__ctrl_slice_idx[0] = counter_config_cmd_slice;
  assign tile__recv_opt_waddr[0] = counter_config_cmd_addr[3:0];
  assign tile__recv_opt_waddr_en[0] = tile_recv_opt_waddr_en;
  assign tile__recv_wopt[0] = recv_wopt_sliced_flattened[31:0];
  assign tile__recv_wopt_en[0] = recv_wopt_sliced_flattened_en;
  assign tile__recv_const_waddr[0] = counter_config_data_addr[3:0];
  assign tile__recv_const[0] = recv_wconst_flattened[31:0];
  assign tile__recv_const_en[0] = recv_wconst_flattened_en;
  assign tile__recv_data[4][1] = tile__send_data[0][0];
  assign tile__recv_data_valid[4][1] = tile__send_data_valid[0][0];
  assign tile__send_data_ack[0][0] = tile__recv_data_ack[4][1];
  assign tile__recv_data[1][2] = tile__send_data[0][3];
  assign tile__recv_data_valid[1][2] = tile__send_data_valid[0][3];
  assign tile__send_data_ack[0][3] = tile__recv_data_ack[1][2];
  assign tile__send_data_ack[0][1] = tile_send_ni_data_rdy[4:4];
  assign tile_send_ni_data_valid[4:4] = tile__send_data_valid[0][1];
  assign cgra_send_ni_data__msg[4] = tile__send_data[0][1].payload;
  assign tile__recv_data_valid[0][1] = 1'd0;
  assign tile__recv_data[0][1] = { 64'd0, 1'd0 };
  assign tile__send_data_ack[0][2] = 1'd0;
  assign tile_recv_ni_data_ack[0:0] = tile__recv_data_ack[0][2];
  assign tile__recv_data_valid[0][2] = cgra_recv_ni_data__en[0];
  assign tile__recv_data[0][2].payload = cgra_recv_ni_data__msg[0];
  assign tile__recv_data[0][2].predicate = 1'd1;
  assign tile__to_mem_raddr__rdy[0] = 1'd0;
  assign tile__from_mem_rdata__en[0] = 1'd0;
  assign tile__from_mem_rdata__msg[0] = { 64'd0, 1'd0 };
  assign tile__to_mem_waddr__rdy[0] = 1'd0;
  assign tile__to_mem_wdata__rdy[0] = 1'd0;
  assign tile__ctrl_slice_idx[1] = counter_config_cmd_slice;
  assign tile__recv_opt_waddr[1] = counter_config_cmd_addr[3:0];
  assign tile__recv_opt_waddr_en[1] = tile_recv_opt_waddr_en;
  assign tile__recv_wopt[1] = recv_wopt_sliced_flattened[63:32];
  assign tile__recv_wopt_en[1] = recv_wopt_sliced_flattened_en;
  assign tile__recv_const_waddr[1] = counter_config_data_addr[3:0];
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
  assign tile__send_data_ack[1][1] = tile_send_ni_data_rdy[5:5];
  assign tile_send_ni_data_valid[5:5] = tile__send_data_valid[1][1];
  assign cgra_send_ni_data__msg[5] = tile__send_data[1][1].payload;
  assign tile__recv_data_valid[1][1] = 1'd0;
  assign tile__recv_data[1][1] = { 64'd0, 1'd0 };
  assign tile__to_mem_raddr__rdy[1] = 1'd0;
  assign tile__from_mem_rdata__en[1] = 1'd0;
  assign tile__from_mem_rdata__msg[1] = { 64'd0, 1'd0 };
  assign tile__to_mem_waddr__rdy[1] = 1'd0;
  assign tile__to_mem_wdata__rdy[1] = 1'd0;
  assign tile__ctrl_slice_idx[2] = counter_config_cmd_slice;
  assign tile__recv_opt_waddr[2] = counter_config_cmd_addr[3:0];
  assign tile__recv_opt_waddr_en[2] = tile_recv_opt_waddr_en;
  assign tile__recv_wopt[2] = recv_wopt_sliced_flattened[95:64];
  assign tile__recv_wopt_en[2] = recv_wopt_sliced_flattened_en;
  assign tile__recv_const_waddr[2] = counter_config_data_addr[3:0];
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
  assign tile__send_data_ack[2][1] = tile_send_ni_data_rdy[6:6];
  assign tile_send_ni_data_valid[6:6] = tile__send_data_valid[2][1];
  assign cgra_send_ni_data__msg[6] = tile__send_data[2][1].payload;
  assign tile__recv_data_valid[2][1] = 1'd0;
  assign tile__recv_data[2][1] = { 64'd0, 1'd0 };
  assign tile__to_mem_raddr__rdy[2] = 1'd0;
  assign tile__from_mem_rdata__en[2] = 1'd0;
  assign tile__from_mem_rdata__msg[2] = { 64'd0, 1'd0 };
  assign tile__to_mem_waddr__rdy[2] = 1'd0;
  assign tile__to_mem_wdata__rdy[2] = 1'd0;
  assign tile__ctrl_slice_idx[3] = counter_config_cmd_slice;
  assign tile__recv_opt_waddr[3] = counter_config_cmd_addr[3:0];
  assign tile__recv_opt_waddr_en[3] = tile_recv_opt_waddr_en;
  assign tile__recv_wopt[3] = recv_wopt_sliced_flattened[127:96];
  assign tile__recv_wopt_en[3] = recv_wopt_sliced_flattened_en;
  assign tile__recv_const_waddr[3] = counter_config_data_addr[3:0];
  assign tile__recv_const[3] = recv_wconst_flattened[127:96];
  assign tile__recv_const_en[3] = recv_wconst_flattened_en;
  assign tile__recv_data[7][1] = tile__send_data[3][0];
  assign tile__recv_data_valid[7][1] = tile__send_data_valid[3][0];
  assign tile__send_data_ack[3][0] = tile__recv_data_ack[7][1];
  assign tile__recv_data[2][3] = tile__send_data[3][2];
  assign tile__recv_data_valid[2][3] = tile__send_data_valid[3][2];
  assign tile__send_data_ack[3][2] = tile__recv_data_ack[2][3];
  assign tile__send_data_ack[3][1] = tile_send_ni_data_rdy[7:7];
  assign tile_send_ni_data_valid[7:7] = tile__send_data_valid[3][1];
  assign cgra_send_ni_data__msg[7] = tile__send_data[3][1].payload;
  assign tile__recv_data_valid[3][1] = 1'd0;
  assign tile__recv_data[3][1] = { 64'd0, 1'd0 };
  assign tile__send_data_ack[3][3] = tile_send_ni_data_rdy[0:0];
  assign tile_send_ni_data_valid[0:0] = tile__send_data_valid[3][3];
  assign cgra_send_ni_data__msg[0] = tile__send_data[3][3].payload;
  assign tile__recv_data_valid[3][3] = 1'd0;
  assign tile__recv_data[3][3] = { 64'd0, 1'd0 };
  assign tile__to_mem_raddr__rdy[3] = 1'd0;
  assign tile__from_mem_rdata__en[3] = 1'd0;
  assign tile__from_mem_rdata__msg[3] = { 64'd0, 1'd0 };
  assign tile__to_mem_waddr__rdy[3] = 1'd0;
  assign tile__to_mem_wdata__rdy[3] = 1'd0;
  assign tile__ctrl_slice_idx[4] = counter_config_cmd_slice;
  assign tile__recv_opt_waddr[4] = counter_config_cmd_addr[3:0];
  assign tile__recv_opt_waddr_en[4] = tile_recv_opt_waddr_en;
  assign tile__recv_wopt[4] = recv_wopt_sliced_flattened[159:128];
  assign tile__recv_wopt_en[4] = recv_wopt_sliced_flattened_en;
  assign tile__recv_const_waddr[4] = counter_config_data_addr[3:0];
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
  assign tile__recv_data[4][2].predicate = 1'd1;
  assign tile__to_mem_raddr__rdy[4] = 1'd0;
  assign tile__from_mem_rdata__en[4] = 1'd0;
  assign tile__from_mem_rdata__msg[4] = { 64'd0, 1'd0 };
  assign tile__to_mem_waddr__rdy[4] = 1'd0;
  assign tile__to_mem_wdata__rdy[4] = 1'd0;
  assign tile__ctrl_slice_idx[5] = counter_config_cmd_slice;
  assign tile__recv_opt_waddr[5] = counter_config_cmd_addr[3:0];
  assign tile__recv_opt_waddr_en[5] = tile_recv_opt_waddr_en;
  assign tile__recv_wopt[5] = recv_wopt_sliced_flattened[191:160];
  assign tile__recv_wopt_en[5] = recv_wopt_sliced_flattened_en;
  assign tile__recv_const_waddr[5] = counter_config_data_addr[3:0];
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
  assign tile__recv_opt_waddr[6] = counter_config_cmd_addr[3:0];
  assign tile__recv_opt_waddr_en[6] = tile_recv_opt_waddr_en;
  assign tile__recv_wopt[6] = recv_wopt_sliced_flattened[223:192];
  assign tile__recv_wopt_en[6] = recv_wopt_sliced_flattened_en;
  assign tile__recv_const_waddr[6] = counter_config_data_addr[3:0];
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
  assign tile__recv_opt_waddr[7] = counter_config_cmd_addr[3:0];
  assign tile__recv_opt_waddr_en[7] = tile_recv_opt_waddr_en;
  assign tile__recv_wopt[7] = recv_wopt_sliced_flattened[255:224];
  assign tile__recv_wopt_en[7] = recv_wopt_sliced_flattened_en;
  assign tile__recv_const_waddr[7] = counter_config_data_addr[3:0];
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
  assign tile__send_data_ack[7][3] = tile_send_ni_data_rdy[1:1];
  assign tile_send_ni_data_valid[1:1] = tile__send_data_valid[7][3];
  assign cgra_send_ni_data__msg[1] = tile__send_data[7][3].payload;
  assign tile__recv_data_valid[7][3] = 1'd0;
  assign tile__recv_data[7][3] = { 64'd0, 1'd0 };
  assign tile__to_mem_raddr__rdy[7] = 1'd0;
  assign tile__from_mem_rdata__en[7] = 1'd0;
  assign tile__from_mem_rdata__msg[7] = { 64'd0, 1'd0 };
  assign tile__to_mem_waddr__rdy[7] = 1'd0;
  assign tile__to_mem_wdata__rdy[7] = 1'd0;
  assign tile__ctrl_slice_idx[8] = counter_config_cmd_slice;
  assign tile__recv_opt_waddr[8] = counter_config_cmd_addr[3:0];
  assign tile__recv_opt_waddr_en[8] = tile_recv_opt_waddr_en;
  assign tile__recv_wopt[8] = recv_wopt_sliced_flattened[287:256];
  assign tile__recv_wopt_en[8] = recv_wopt_sliced_flattened_en;
  assign tile__recv_const_waddr[8] = counter_config_data_addr[3:0];
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
  assign tile__recv_data[8][2].predicate = 1'd1;
  assign tile__to_mem_raddr__rdy[8] = 1'd0;
  assign tile__from_mem_rdata__en[8] = 1'd0;
  assign tile__from_mem_rdata__msg[8] = { 64'd0, 1'd0 };
  assign tile__to_mem_waddr__rdy[8] = 1'd0;
  assign tile__to_mem_wdata__rdy[8] = 1'd0;
  assign tile__ctrl_slice_idx[9] = counter_config_cmd_slice;
  assign tile__recv_opt_waddr[9] = counter_config_cmd_addr[3:0];
  assign tile__recv_opt_waddr_en[9] = tile_recv_opt_waddr_en;
  assign tile__recv_wopt[9] = recv_wopt_sliced_flattened[319:288];
  assign tile__recv_wopt_en[9] = recv_wopt_sliced_flattened_en;
  assign tile__recv_const_waddr[9] = counter_config_data_addr[3:0];
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
  assign tile__recv_opt_waddr[10] = counter_config_cmd_addr[3:0];
  assign tile__recv_opt_waddr_en[10] = tile_recv_opt_waddr_en;
  assign tile__recv_wopt[10] = recv_wopt_sliced_flattened[351:320];
  assign tile__recv_wopt_en[10] = recv_wopt_sliced_flattened_en;
  assign tile__recv_const_waddr[10] = counter_config_data_addr[3:0];
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
  assign tile__recv_opt_waddr[11] = counter_config_cmd_addr[3:0];
  assign tile__recv_opt_waddr_en[11] = tile_recv_opt_waddr_en;
  assign tile__recv_wopt[11] = recv_wopt_sliced_flattened[383:352];
  assign tile__recv_wopt_en[11] = recv_wopt_sliced_flattened_en;
  assign tile__recv_const_waddr[11] = counter_config_data_addr[3:0];
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
  assign tile__send_data_ack[11][3] = tile_send_ni_data_rdy[2:2];
  assign tile_send_ni_data_valid[2:2] = tile__send_data_valid[11][3];
  assign cgra_send_ni_data__msg[2] = tile__send_data[11][3].payload;
  assign tile__recv_data_valid[11][3] = 1'd0;
  assign tile__recv_data[11][3] = { 64'd0, 1'd0 };
  assign tile__to_mem_raddr__rdy[11] = 1'd0;
  assign tile__from_mem_rdata__en[11] = 1'd0;
  assign tile__from_mem_rdata__msg[11] = { 64'd0, 1'd0 };
  assign tile__to_mem_waddr__rdy[11] = 1'd0;
  assign tile__to_mem_wdata__rdy[11] = 1'd0;
  assign tile__ctrl_slice_idx[12] = counter_config_cmd_slice;
  assign tile__recv_opt_waddr[12] = counter_config_cmd_addr[3:0];
  assign tile__recv_opt_waddr_en[12] = tile_recv_opt_waddr_en;
  assign tile__recv_wopt[12] = recv_wopt_sliced_flattened[415:384];
  assign tile__recv_wopt_en[12] = recv_wopt_sliced_flattened_en;
  assign tile__recv_const_waddr[12] = counter_config_data_addr[3:0];
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
  assign tile__recv_data[12][0].predicate = 1'd1;
  assign tile__send_data_ack[12][2] = 1'd0;
  assign tile_recv_ni_data_ack[3:3] = tile__recv_data_ack[12][2];
  assign tile__recv_data_valid[12][2] = cgra_recv_ni_data__en[3];
  assign tile__recv_data[12][2].payload = cgra_recv_ni_data__msg[3];
  assign tile__recv_data[12][2].predicate = 1'd1;
  assign tile__to_mem_raddr__rdy[12] = 1'd0;
  assign tile__from_mem_rdata__en[12] = 1'd0;
  assign tile__from_mem_rdata__msg[12] = { 64'd0, 1'd0 };
  assign tile__to_mem_waddr__rdy[12] = 1'd0;
  assign tile__to_mem_wdata__rdy[12] = 1'd0;
  assign tile__ctrl_slice_idx[13] = counter_config_cmd_slice;
  assign tile__recv_opt_waddr[13] = counter_config_cmd_addr[3:0];
  assign tile__recv_opt_waddr_en[13] = tile_recv_opt_waddr_en;
  assign tile__recv_wopt[13] = recv_wopt_sliced_flattened[447:416];
  assign tile__recv_wopt_en[13] = recv_wopt_sliced_flattened_en;
  assign tile__recv_const_waddr[13] = counter_config_data_addr[3:0];
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
  assign tile__recv_data[13][0].predicate = 1'd1;
  assign tile__to_mem_raddr__rdy[13] = 1'd0;
  assign tile__from_mem_rdata__en[13] = 1'd0;
  assign tile__from_mem_rdata__msg[13] = { 64'd0, 1'd0 };
  assign tile__to_mem_waddr__rdy[13] = 1'd0;
  assign tile__to_mem_wdata__rdy[13] = 1'd0;
  assign tile__ctrl_slice_idx[14] = counter_config_cmd_slice;
  assign tile__recv_opt_waddr[14] = counter_config_cmd_addr[3:0];
  assign tile__recv_opt_waddr_en[14] = tile_recv_opt_waddr_en;
  assign tile__recv_wopt[14] = recv_wopt_sliced_flattened[479:448];
  assign tile__recv_wopt_en[14] = recv_wopt_sliced_flattened_en;
  assign tile__recv_const_waddr[14] = counter_config_data_addr[3:0];
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
  assign tile__recv_data[14][0].predicate = 1'd1;
  assign tile__to_mem_raddr__rdy[14] = 1'd0;
  assign tile__from_mem_rdata__en[14] = 1'd0;
  assign tile__from_mem_rdata__msg[14] = { 64'd0, 1'd0 };
  assign tile__to_mem_waddr__rdy[14] = 1'd0;
  assign tile__to_mem_wdata__rdy[14] = 1'd0;
  assign tile__ctrl_slice_idx[15] = counter_config_cmd_slice;
  assign tile__recv_opt_waddr[15] = counter_config_cmd_addr[3:0];
  assign tile__recv_opt_waddr_en[15] = tile_recv_opt_waddr_en;
  assign tile__recv_wopt[15] = recv_wopt_sliced_flattened[511:480];
  assign tile__recv_wopt_en[15] = recv_wopt_sliced_flattened_en;
  assign tile__recv_const_waddr[15] = counter_config_data_addr[3:0];
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
  assign tile__recv_data[15][0].predicate = 1'd1;
  assign tile__send_data_ack[15][3] = tile_send_ni_data_rdy[3:3];
  assign tile_send_ni_data_valid[3:3] = tile__send_data_valid[15][3];
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
