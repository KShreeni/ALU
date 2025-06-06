// defines
`include "alu_final.v"
//`define IS_MUL_OP
`define PASS 1'b1
`define FAIL 1'b0
`define no_of_testcase 130

// Test bench for ALU design
module test_bench_alu();
parameter width_OP = 8, width_cmd = 4;
`ifdef IS_MUL_OP
  localparam width = width_OP*2;

`else
  localparam width = width_OP+1;
`endif

localparam pack_size = width+(width_OP*2)+ width_cmd+19;
        reg [pack_size-1:0] curr_test_case =0;
        reg [pack_size-1:0] stimulus_mem [0:`no_of_testcase-1];
        reg [pack_size+width+6:0] response_packet;

//Decl for giving the Stimulus
        integer i,j;
        reg CLK,RST,CE; //inputs
        event fetch_stimulus;
        reg [width_OP-1:0]OPA,OPB; //inputs
        reg [width_cmd-1:0]CMD; //inputs
        reg MODE,CIN; //inputs
        reg [7:0] Feature_ID;
        reg [2:0] Comparison_EGL;  //expected output
        reg [width-1:0] Expected_RES; //expected output data
        reg err,cout,ov;
        reg [1:0] INP_VALID;

//Decl to Cop UP the DUT OPERATION
        wire  [width-1:0] RES;
        wire ERR,OFLOW,COUT;
        wire [2:0]EGL;
        wire [width+5:0] expected_data;
        reg [width+5:0]exact_data;

//READ DATA FROM THE TEXT VECTOR FILE
        task read_stimulus();
                begin
                  #10 $readmemb ("stimulus1.txt",stimulus_mem);
               end
        endtask

   alu_final #(.width_OP(width_OP),.width_cmd(width_cmd))inst_dut(.OPA(OPA),.OPB(OPB),.CIN(CIN),.CLK(CLK),.CMD(CMD),.CE(CE),.MODE(MODE),.INP_VALID(INP_VALID),            .COUT(COUT),.OFLOW(OFLOW),.RES(RES),.G(EGL[1]),.E(EGL[2]),.L(EGL[0]),.ERR(ERR),.RST(RST));

//STIMULUS GENERATOR

integer stim_mem_ptr = 0,stim_stimulus_mem_ptr = 0,fid =0 , pointer =0 ;

 always@(fetch_stimulus)
       begin
             curr_test_case=stimulus_mem[stim_mem_ptr];          
             $display ("stimulus_mem data=%0b\n",stimulus_mem[stim_mem_ptr]); 
             $display ("packet data = %0b \n",curr_test_case);
             stim_mem_ptr=stim_mem_ptr+1;
       end

//INITIALIZING CLOCK
        initial
                begin CLK=0;
                        forever #60 CLK=~CLK;
                end

//DRIVER MODULE
  task driver ();
       begin
       ->fetch_stimulus;
         @(posedge CLK);

       Feature_ID=curr_test_case[(width_OP*2)+width_cmd+width+9+2+7:(width_OP*2)+width_cmd+width+9+2];                                                                                                             
       INP_VALID =curr_test_case[(width_OP*2)+width_cmd+width+9+1:(width_OP*2)+width_cmd+width+9];                                                       
       OPA=curr_test_case[(width_OP*2)-1+width_cmd+width+9:width_OP+width_cmd+width+9];                                                                                                                        
  OPB=curr_test_case[width_OP-1+width_cmd+width+9:width_cmd+width+9];                                                                                                            
                  CMD =curr_test_case[width_cmd-1+width+9:width+9];
                  CIN =curr_test_case[width+8];
                  CE  = curr_test_case[width+7];
                  MODE =curr_test_case[width+6];
                  Expected_RES =curr_test_case[width-1+6:6];
                  cout =curr_test_case[5];
                  Comparison_EGL=curr_test_case[4:2];
                  ov =curr_test_case[1];
                  err =curr_test_case[0];
                 $display("At time (%0t), Feature_ID = %8b, INP_VALID = %2b, OPA = %b, OPB = %b, CMD = %b, CIN = %1b, CE = %1b, MODE = %1b, expected_result = %b , cout = %1b, Comparison_EGL = %3b, ov = %1b,err=%1b",$time,Feature_ID,INP_VALID,OPA,OPB,CMD,CIN,CE,MODE, Expected_RES,cout,Comparison_EGL,ov,err);                                                                                                                                                                                                                                                                                                                                     
                end
        endtask

//GLOBAL DUT RESET
        task dut_reset ();
                begin
                CE=1;
                #10 RST=1;
                #20 RST=0;
                end
        endtask

//GLOBAL INITIALIZATION
        task global_init ();
                begin
                curr_test_case=0;
                response_packet=0;
                stim_mem_ptr=0;
                end
        endtask


//MONITOR PROGRAM


task monitor ();
                begin
                
                 `ifdef IS_MUL_OP
                         repeat(4)@(posedge CLK);
                 `else
                  repeat(3)@(posedge CLK);
                 `endif
                #5 response_packet[pack_size-1:0]=curr_test_case;
                response_packet[pack_size]=ERR;
                response_packet[pack_size+1]=OFLOW;
                response_packet[pack_size+4:pack_size+2]={EGL};
                response_packet[pack_size+5]=COUT;
                response_packet[width+pack_size+6-1:pack_size+6]=RES;
                response_packet[width+pack_size+6]=0; // Reserved Bit
                $display("Monitor: At time (%0t), RES = %b, COUT = %1b, EGL = %3b, OFLOW = %1b, ERR = %1b",$time,RES,COUT,{EGL},OFLOW,ERR);                                                                                                             
                exact_data ={RES,COUT,{EGL},OFLOW,ERR};
                end
        endtask

assign expected_data = {Expected_RES,cout,Comparison_EGL,ov,err};

//SCORE BOARD PROGRAM TO CHECK THE DUT OP WITH EXPECTD OP

   reg [pack_size-8:0] scb_stimulus_mem [0:`no_of_testcase-1];

task score_board();
   reg [width+5:0] expected_res;
   reg [7:0] feature_id;
   reg [width+5:0] response_data;
                begin
                #5;
                feature_id = curr_test_case[(width_OP*2)+width_cmd+width+9+2+7:( width_OP*2)+width_cmd+width+9+2];                                                                                                            
                expected_res = curr_test_case[width-1+6:6];
                response_data = response_packet[width+pack_size+6:pack_size];
                $display("expected result = %b ,response data = %b",expected_data,exact_data);                                                                                                             
                 if(expected_data === exact_data)
                     scb_stimulus_mem[stim_stimulus_mem_ptr] = {1'b0,feature_id,expected_res,response_data, 1'b0,`PASS};                                                                                                              
                 else
                     scb_stimulus_mem[stim_stimulus_mem_ptr] = {1'b0,feature_id,expected_res,response_data, 1'b0,`FAIL};                                                                                                              
            stim_stimulus_mem_ptr = stim_stimulus_mem_ptr + 1;
        end
endtask


//Generating the report `no_of_testcase-1
task gen_report;
integer file_id,pointer;
reg [pack_size-8:0] status;
                begin
                   file_id = $fopen("results.txt", "w");
                   for(pointer = 0; pointer <= `no_of_testcase-1 ; pointer = pointer+1 )                                                                                                             
                   begin
                     status = scb_stimulus_mem[pointer];
                     if(status[0])
                       $fdisplay(file_id, "Feature ID %8b : PASS", status[pack_size-8-1:pack_size-9-7]);                                                                                                             
                     else
                       $fdisplay(file_id, "Feature ID %8b : FAIL", status[pack_size-8-1:pack_size-9-7]);                                                                                                             
                   end
                end
endtask

  initial begin
     $dumpfile("test_bench_alu.vcd");
    $dumpvars(0, test_bench_alu);
  end

initial
               begin
               #10;
                global_init();
                dut_reset();
                read_stimulus();
                for(j=0;j<=`no_of_testcase-1;j=j+1)
                begin
                        fork
                          driver();
                          monitor();
                         join
                        score_board();
               end

               gen_report();
               $fclose(fid);
               #400 $finish();
               end
endmodule
