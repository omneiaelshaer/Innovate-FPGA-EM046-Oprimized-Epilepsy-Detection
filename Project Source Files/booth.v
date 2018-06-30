module Booth
(
	input[15:0] A_in,
	input[15:0] M,
	input[16:0] Q_in,
	output[15:0] A_out,
	output[16:0] Q_out
);

reg [15:0] A_temp;
reg [16:0] Q_temp; 

wire [15:0] A_sum= A_in + M;
wire [15:0] A_sub= A_in + -M ;

always @ (A_in,M,Q_in,A_sum,A_sub)  begin
	
	case(Q_in[1:0])

	2'b00,2'b11:    begin  
				A_temp={A_in[15],A_in[15:1]};
    		      		Q_temp={A_in[0],Q_in[16:1]};
			end
	
	2'b01: 		begin
				A_temp={A_sum[15],A_sum[15:1]};
    		      		Q_temp={A_sum[0],Q_in[16:1]};
			end

	2'b10:		begin 
				A_temp={A_sub[15],A_sub[15:1]};
    		      		Q_temp={A_sub[0],Q_in[16:1]};
			end

	endcase
end

assign A_out=A_temp;
assign Q_out=Q_temp;
endmodule 