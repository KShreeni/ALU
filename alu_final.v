//`define IS_MUL_OP
`define INC1_MUL 4'b1001
`define SHL1_A_MULB 4'b1010

module alu_final #(parameter width_OP = 8, width_cmd = 4)(OPA,OPB,CIN,CLK,RST,CE,MODE,INP_VALID,CMD,RES,OFLOW,COUT,G,L,E,ERR);
`ifdef IS_MUL_OP
  localparam width = width_OP*2;

`else
  localparam width = width_OP+1;
`endif


  localparam ADD           = 4'b0000;
  localparam AND           = 4'b0000;

  localparam SUB           = 4'b0001;
  localparam NAND          = 4'b0001;
  localparam ADD_CIN       = 4'b0010;
  localparam OR            = 4'b0010;

  localparam SUB_CIN       = 4'b0011;
  localparam NOR           = 4'b0011;

  localparam INC_A         = 4'b0100;
  localparam XOR           = 4'b0100;

  localparam DEC_A         = 4'b0101;
  localparam XNOR          = 4'b0101;

  localparam INC_B         = 4'b0110;
  localparam NOT_A         = 4'b0110;

  localparam DEC_B         = 4'b0111;
  localparam NOT_B         = 4'b0111;

  localparam CMP           = 4'b1000;
  localparam SHR1_A        = 4'b1000;


  localparam SHL1_A        = 4'b1001;


  localparam SHR1_B        = 4'b1010;

  localparam S_UNS_ADD     = 4'b1011;
  localparam SHL1_B        = 4'b1011;

  localparam S_UNS_SUB     = 4'b1100;

  localparam ROL_A_B       = 4'b1100;
  localparam ROR_A_B       = 4'b1101;


input [width_OP-1:0] OPA,OPB;
input CIN,CLK,RST,CE,MODE;
input [1:0] INP_VALID;
input [width_cmd-1:0] CMD;
output reg[width-1:0] RES;      //Res is OP+1 bit
output reg OFLOW,COUT,G,L,E,ERR;

reg [2:0] VALID_PIPE;

reg [width_OP-1:0] OPA_S1,OPB_S1;
reg [$clog2(width_OP)-1:0] OPB_l;
  reg [width_OP-1:$clog2(width_OP)+1] OPB_H;
reg [width-1:0] OP_RES;
reg CIN_S1;
reg [width-1:0] OP_MUL;
reg signed [width-1:0] SOP_RES;
always@(posedge CLK or posedge RST)begin
if(RST)begin                // RST is asynchronous so does not depend on CE
     RES<={width{1'b0}};         //Res all bits z
     COUT<=1'b0;
     OFLOW<=1'b0;
     G<=1'b0;
     E<=1'b0;
     L<=1'b0;
     ERR<=1'b0;
     OPA_S1 <= 0;
     OPB_S1 <= 0;
     OP_MUL <= 0;
     OP_RES <= 0;
     VALID_PIPE <= 0;
end
else if(CE) begin
    if(MODE)begin
     RES<={width{1'b0}};
     COUT<=1'b0;
     OFLOW<=1'b0;
     G<=1'b0;
     E<=1'b0;
     L<=1'b0;
     ERR<=1'b0;
     VALID_PIPE <= 0;
    case(CMD)
     ADD : begin
        VALID_PIPE <= {VALID_PIPE[1:0],(INP_VALID==2'b11)};
        if(INP_VALID==2'b11) begin
            OP_RES <= OPA + OPB;
        end
        if(VALID_PIPE[0])begin
            RES <= OP_RES;
            COUT <= (OP_RES[width_OP])?1:0;
            ERR <= 0;
            OFLOW <= (OP_RES[width_OP])?1:0;
           end
        if(INP_VALID==2'b01 || INP_VALID==2'b10 || INP_VALID==2'b00) begin
            RES <= {width{1'b0}};
            ERR <= 1;
            COUT <= 0;
            OFLOW <= 0;
           end
     end
      

     SUB : begin
        VALID_PIPE <= {VALID_PIPE[1:0],(INP_VALID==2'b11)};
        if(INP_VALID==2'b11) begin
          OPA_S1 <= OPA;
          OPB_S1 <= OPB;
        end 
        if(VALID_PIPE[0])begin
          OFLOW <= (OPA_S1<OPB_S1)?1:0;
            RES <= OPA_S1 - OPB_S1;
            ERR <= 0;
           end
        if(INP_VALID==2'b01 || INP_VALID==2'b10 || INP_VALID==2'b00) begin
            ERR <= 1;
            OFLOW <= 0;
            RES <= {width{1'b0}};
           end
     end

     ADD_CIN : begin
         VALID_PIPE <= {VALID_PIPE[1:0],(INP_VALID==2'b11)};
         if(INP_VALID==2'b11) begin
           OP_RES <= OPA + OPB + CIN;
         end
         if(VALID_PIPE[0])begin
           RES <= OP_RES;
           COUT <= (OP_RES[width_OP])?1:0;
           ERR <= 0;
           OFLOW <= (OP_RES[width_OP])?1:0;
         end
         if(INP_VALID==2'b01 || INP_VALID==2'b10 || INP_VALID==2'b00) begin
            ERR <= 1;
            RES <= {width{1'b0}};
            COUT <= 0;
            OFLOW <= 0;
         end
     end

     SUB_CIN : begin
         VALID_PIPE <= {VALID_PIPE[1:0],(INP_VALID==2'b11)};
         if(INP_VALID==2'b11) begin
           OPA_S1 <= OPA;
           OPB_S1 <= OPB;
           CIN_S1 <= CIN;
         end
         if(VALID_PIPE[0])begin
           OFLOW <= (OPA_S1<(OPB_S1 + CIN_S1))?1:0;
           RES <= OPA_S1-OPB_S1-CIN_S1;
           ERR <= 0;
          end
         if(INP_VALID==2'b01 || INP_VALID==2'b10 || INP_VALID==2'b00) begin
           ERR <= 1;
           OFLOW <= 0;
           RES <= {width{1'b0}};
          end
     end

     INC_A : begin
         VALID_PIPE <= {VALID_PIPE[1:0],(INP_VALID==2'b01)};
         if(INP_VALID==2'b01) begin
           OP_RES <= OPA + 1;
         end
         if(VALID_PIPE[0])begin
            RES <= OP_RES;
           OFLOW <= (OP_RES[width_OP])?1:0;
            ERR <= 0;
          end
         if(INP_VALID==2'b11 || INP_VALID==2'b10 || INP_VALID==2'b00) begin
           ERR <= 1;
           OFLOW <= 0;
           RES <= {width{1'b0}};
          end
     end

     DEC_A : begin
         VALID_PIPE <= {VALID_PIPE[1:0],(INP_VALID==2'b01)};
         if(INP_VALID==2'b01) begin
           OP_RES <= OPA - 1;
         end
         if(VALID_PIPE[0])begin
            RES <= OP_RES;
           OFLOW <= (OP_RES[width_OP])?1:0;
            ERR <= 0;
          end
         if(INP_VALID==2'b11 || INP_VALID==2'b10 || INP_VALID==2'b00) begin
           ERR <= 1;
           OFLOW <= 0;
           RES <= {width{1'b0}};
          end
     end

     INC_B : begin
       VALID_PIPE <= {VALID_PIPE[1:0],(INP_VALID==2'b10)};
       if(INP_VALID==2'b10) begin
           OP_RES <= OPB + 1;
         end
         if(VALID_PIPE[0])begin
            RES <= OP_RES;
           OFLOW <= (OP_RES[width_OP])?1:0;
            ERR <= 0;
          end
         if(INP_VALID==2'b01 || INP_VALID==2'b11 || INP_VALID==2'b00) begin
           ERR <= 1;
           OFLOW <= 0;
           RES <= {width{1'b0}};
          end
     end

     DEC_B : begin
         VALID_PIPE <= {VALID_PIPE[1:0],(INP_VALID==2'b10)};
         if(INP_VALID==2'b10) begin
           OP_RES <= OPB - 1;
         end
         if(VALID_PIPE[0])begin
            RES <= OP_RES;
           OFLOW <= (OP_RES[width_OP])?1:0;
            ERR <= 0;
          end
         if(INP_VALID==2'b01 || INP_VALID==2'b11 || INP_VALID==2'b00) begin
           ERR <= 1;
           OFLOW <= 0;
           RES <= {width{1'b0}};
          end
     end

     CMP : begin
       VALID_PIPE <= {VALID_PIPE[1:0],(INP_VALID==2'b11)};
        if(INP_VALID==2'b11) begin
          OPA_S1 <= OPA;
          OPB_S1 <= OPB;
        end
        if(VALID_PIPE[0])begin
          RES <= {width{1'b0}};
          ERR<=0;
          if(OPA_S1==OPB_S1)begin
            E<=1'b1;
            G<=1'b0;
            L<=1'b0;
         end
          else if(OPA_S1>OPB_S1)begin
            E<=1'b0;
            G<=1'b1;
            L<=1'b0;
         end
          if(OPA_S1<OPB_S1)begin
            E<=1'b0;
            G<=1'b0;
            L<=1'b1;
         end
        end
         if(INP_VALID==2'b01 || INP_VALID==2'b10 || INP_VALID==2'b00) begin
        RES <= {width{1'b0}};
        ERR<=1;
       end
     end

    `INC1_MUL : begin
      VALID_PIPE <= {VALID_PIPE[1:0],(INP_VALID==2'b11)};
      if(INP_VALID==2'b11) begin
          OPA_S1 <= OPA;
          OPB_S1 <= OPB;
      end
      if(VALID_PIPE[0])begin
        OP_MUL<= (OPA_S1 + 1)*(OPB_S1 + 1);
      end
      if(VALID_PIPE[1])begin
          RES <= OP_MUL;
        end

       if(INP_VALID==2'b01 || INP_VALID==2'b10 || INP_VALID==2'b00) begin
          ERR <= 1;
          RES <= {width{1'b0}};
       end
    end

    `SHL1_A_MULB : begin
      VALID_PIPE <= {VALID_PIPE[1:0],(INP_VALID==2'b11)};
      if(INP_VALID==2'b11) begin
         OPA_S1 <= OPA<<1;
         OPB_S1 <= OPB;

      end
      if(VALID_PIPE[0])begin
         OP_MUL <= (OPA_S1)*OPB_S1;
      end
      if(VALID_PIPE[1])begin
         RES <= OP_MUL;
         ERR <= 0;
      end

       if(INP_VALID==2'b01 || INP_VALID==2'b10 || INP_VALID==2'b00) begin
         ERR <= 1;
         RES <= {width{1'b0}};
      end
    end

     S_UNS_ADD : begin
       VALID_PIPE <= {VALID_PIPE[1:0],(INP_VALID==2'b11)};
       if(INP_VALID==2'b11) begin
         SOP_RES <= $signed(OPA) + $signed(OPB);
       end
       if(VALID_PIPE[0])begin
         RES <= SOP_RES;
         if($signed(OPA)==$signed(OPB))begin
            E<=1'b1;
            G<=1'b0;
            L<=1'b0;
         end
         if($signed(OPA)>$signed(OPB))begin
            E<=1'b0;
            G<=1'b1;
            L<=1'b0;
         end
         if($signed(OPA)<$signed(OPB))begin
            E<=1'b0;
            G<=1'b0;
            L<=1'b1;
         end

         OFLOW <= (~OPA[width_OP-1] && ~OPB[width_OP-1] && SOP_RES[width_OP-1] || OPA[width_OP-1] && OPB[width_OP-1] && ~SOP_RES[width_OP-1])?1:0;
       end
        if(INP_VALID==2'b01 || INP_VALID==2'b10 || INP_VALID==2'b00) begin
         ERR <= 1;
         RES <= {width{1'b0}};
         OFLOW<=0;
      end
     end

     S_UNS_SUB : begin
       VALID_PIPE <= {VALID_PIPE[1:0],(INP_VALID==2'b11)};
       if(INP_VALID==2'b11) begin
         SOP_RES <= $signed(OPA) - $signed(OPB);
       end
       if(VALID_PIPE[0])begin
         RES <= SOP_RES;
         if($signed(OPA)==$signed(OPB))begin
            E<=1'b1;
            G<=1'b0;
            L<=1'b0;
         end
         if($signed(OPA)>$signed(OPB))begin
            E<=1'b0;
            G<=1'b1;
            L<=1'b0;
         end
         if($signed(OPA)<$signed(OPB))begin
            E<=1'b0;
            G<=1'b0;
            L<=1'b1;
         end
         OFLOW <= (OPA[width_OP-1] != OPB[width_OP-1]) && (SOP_RES[width_OP-1] != OPA[width_OP-1])?1:0;
       end
        if(INP_VALID==2'b01 || INP_VALID==2'b10 || INP_VALID==2'b00) begin
         ERR <= 1;
         RES <= {width{1'b0}};
         OFLOW<=0;
      end
     end
     default : begin
        ERR <= 1;
        RES <= 0;
     end
      endcase
    end

   else begin

     case(CMD)

       AND : begin
         VALID_PIPE <= {VALID_PIPE[1:0],(INP_VALID==2'b11)};
         if(INP_VALID==2'b11) begin
           OPA_S1 <= OPA;
           OPB_S1 <= OPB;
         end
         if(VALID_PIPE[0])begin
           RES <= OPA_S1&OPB_S1;
           ERR<=0;
         end
         if(INP_VALID==2'b01 || INP_VALID==2'b10 || INP_VALID==2'b00) begin
           ERR <= 1;
           RES <= {width{1'b0}};
         end
       end

       NAND : begin
         VALID_PIPE <= {VALID_PIPE[1:0],(INP_VALID==2'b11)};
         if(INP_VALID==2'b11) begin
           OPA_S1 <= OPA;
           OPB_S1 <= OPB;
         end
         if(VALID_PIPE[0])begin
           RES <= ~(OPA_S1&OPB_S1);
           ERR<=0;
         end
          if(INP_VALID==2'b01 || INP_VALID==2'b10 || INP_VALID==2'b00) begin
           ERR <= 1;
           RES <= {width{1'b0}};
         end
       end

       OR : begin
         VALID_PIPE <= {VALID_PIPE[1:0],(INP_VALID==2'b11)};
         if(INP_VALID==2'b11) begin
           OPA_S1 <= OPA;
           OPB_S1 <= OPB;
         end
         if(VALID_PIPE[0])begin
           RES <= OPA_S1|OPB_S1;
           ERR <= 0;
         end
          if(INP_VALID==2'b01 || INP_VALID==2'b10 || INP_VALID==2'b00) begin
           ERR <= 1;
           RES <= {width{1'b0}};
         end
       end

       NOR : begin
         VALID_PIPE <= {VALID_PIPE[1:0],(INP_VALID==2'b11)};
         if(INP_VALID==2'b11) begin
           OPA_S1 <= OPA;
           OPB_S1 <= OPB;
         end
         if(VALID_PIPE[0])begin
           RES <= ~(OPA_S1|OPB_S1);
           ERR <= 0;
         end
          if(INP_VALID==2'b01 || INP_VALID==2'b10 || INP_VALID==2'b00) begin
           ERR <= 1;
           RES <= {width{1'b0}};
         end
       end

       XOR : begin
         VALID_PIPE <= {VALID_PIPE[1:0],(INP_VALID==2'b11)};
         if(INP_VALID==2'b11) begin
           OPA_S1 <= OPA;
           OPB_S1 <= OPB;
         end
         if(VALID_PIPE[0])begin
           RES <= OPA_S1^OPB_S1;
           ERR <= 0;
         end
          if(INP_VALID==2'b01 || INP_VALID==2'b10 || INP_VALID==2'b00) begin
           ERR <= 1;
           RES <= {width{1'b0}};
         end
       end

       XNOR : begin
         VALID_PIPE <= {VALID_PIPE[1:0],(INP_VALID==2'b11)};
         if(INP_VALID==2'b11) begin
           OPA_S1 <= OPA;
           OPB_S1 <= OPB;
         end
         if(VALID_PIPE[0])begin
           RES <= ~(OPA_S1^OPB_S1);
           ERR <= 0;
         end
         if(INP_VALID==2'b01 || INP_VALID==2'b10 || INP_VALID==2'b00) begin
           ERR <= 1;
           RES <= {width{1'b0}};
         end
       end

       NOT_A : begin
         VALID_PIPE <= {VALID_PIPE[1:0],(INP_VALID==2'b01)};
         if(INP_VALID==2'b01) begin
           OPA_S1 <= OPA;
         end
         if(VALID_PIPE[0])begin
           RES <= ~OPA_S1;
           ERR <= 0;
         end
         if(INP_VALID==2'b11 || INP_VALID==2'b10 || INP_VALID==2'b00) begin
           ERR <= 1;
           RES <= {width{1'b0}};
         end
       end

       NOT_B : begin
         VALID_PIPE <= {VALID_PIPE[1:0],(INP_VALID==2'b10)};
         if(INP_VALID==2'b10) begin
           OPB_S1 <= OPB;
         end
         if(VALID_PIPE[0])begin
           RES <= ~OPB_S1;
           ERR <= 0;
         end
         if(INP_VALID==2'b01 || INP_VALID==2'b11 || INP_VALID==2'b00) begin
           ERR <= 1;
           RES <= {width{1'b0}};
         end
       end

       SHR1_A : begin
         VALID_PIPE <= {VALID_PIPE[1:0],(INP_VALID==2'b01)};
         if(INP_VALID==2'b01) begin
           OPA_S1 <= OPA;
         end
         if(VALID_PIPE[0])begin
           RES <= (OPA_S1>>1);
           ERR <= 0;
         end
         if(INP_VALID==2'b11 || INP_VALID==2'b10 || INP_VALID==2'b00) begin
           ERR <= 1;
           RES <= {width{1'b0}};
         end
       end

       SHL1_A : begin
         VALID_PIPE <= {VALID_PIPE[1:0],(INP_VALID==2'b01)};
         if(INP_VALID==2'b01) begin
           OPA_S1 <= OPA<<1;
         end
         if(VALID_PIPE[0])begin
           RES <= OPA_S1;
           ERR <= 0;
         end
         if(INP_VALID==2'b11 || INP_VALID==2'b10 || INP_VALID==2'b00) begin
           ERR <= 1;
           RES <= {width{1'b0}};
         end
       end

       SHR1_B : begin
         VALID_PIPE <= {VALID_PIPE[1:0],(INP_VALID==2'b10)};
         if(INP_VALID==2'b10) begin
           OPB_S1 <= OPB;
         end
         if(VALID_PIPE[0])begin
           RES <= (OPB_S1>>1);
           ERR <= 0;
         end
         if(INP_VALID==2'b01 || INP_VALID==2'b11 || INP_VALID==2'b00) begin
           ERR <= 1;
           RES <= {width{1'b0}};
         end
       end

       SHL1_B : begin
         VALID_PIPE <= {VALID_PIPE[1:0],(INP_VALID==2'b10)};
         if(INP_VALID==2'b10) begin
           OPB_S1 <= OPB<<1;
         end
         if(VALID_PIPE[0])begin
           RES <= (OPB_S1);
           ERR <= 0;
         end
         if(INP_VALID==2'b01 || INP_VALID==2'b11 || INP_VALID==2'b00) begin
           ERR <= 1;
           RES <= {width{1'b0}};
          end
        end

        ROL_A_B : begin
          VALID_PIPE <= {VALID_PIPE[1:0],(INP_VALID==2'b11)};
          if(INP_VALID==2'b11) begin
             OPA_S1 <= OPA;
             OPB_l <= OPB[$clog2(width_OP)-1:0];
            OPB_H <= OPB[width_OP-1:$clog2(width_OP)+1];
          end
          if(VALID_PIPE[0])begin
            RES <= {width{1'b0}};
            if(OPB_H>0)begin
              ERR <= 1;
              RES <= {width{1'b0}};
            end
            else begin
              RES[width_OP-1:0] <= OPA_S1<<OPB_l | OPA_S1>>(width_OP-OPB_l);
              ERR <= 0;
            end

          end
          if(INP_VALID==2'b01 || INP_VALID==2'b10 || INP_VALID==2'b00) begin
            ERR <= 1;
            RES <= {width{1'b0}};
           end
         end

         ROR_A_B : begin
          VALID_PIPE <= {VALID_PIPE[1:0],(INP_VALID==2'b11)};
          if(INP_VALID==2'b11) begin
             OPA_S1 <= OPA;
             OPB_l <= OPB[$clog2(width_OP)-1:0];
             OPB_H <= OPB[width_OP-1:$clog2(width_OP)];
          end
          if(VALID_PIPE[0])begin
            RES <= {width{1'b0}};
            if(OPB_H>0)begin
              ERR <= 1;
              RES <= {width{1'b0}};
            end
            else begin
              RES <= OPA_S1>>OPB_l | OPA_S1<<(width_OP-OPB_l);
            ERR <= 0;
            end

          end
          if(INP_VALID==2'b01 || INP_VALID==2'b10 || INP_VALID==2'b00) begin
            ERR <= 1;
            RES <= {width{1'b0}};
           end
         end
         default : begin
           ERR <= 1;
           RES <= 0;
         end
     endcase
   end
end
 else begin
    RES<={width{1'b0}};        
     COUT<=1'b0;
     OFLOW<=1'b0;
     G<=1'b0;
     E<=1'b0;
     L<=1'b0;
     ERR<=1'b0;
     OPA_S1 <= 0;
     OPB_S1 <= 0;
     OP_MUL <= 0;
     OP_RES <= 0;
     VALID_PIPE <= 0;
  end
 end
endmodule   

