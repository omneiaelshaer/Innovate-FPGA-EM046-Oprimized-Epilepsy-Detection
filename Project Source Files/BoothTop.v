module BoothTop
(
	input[15:0] M,
	input[15:0] Q,
	output[31:0] Z
);

wire [15:0] A_out1;
wire [16:0] Q_out1;

wire [15:0] A_out2;
wire [16:0] Q_out2;

wire [15:0] A_out3;
wire [16:0] Q_out3;

wire [15:0] A_out4;
wire [16:0] Q_out4;

wire [15:0] A_out5;
wire [16:0] Q_out5;

wire [15:0] A_out6;
wire [16:0] Q_out6;

wire [15:0] A_out7;
wire [16:0] Q_out7;

wire [15:0] A_out8;
wire [16:0] Q_out8;

wire [15:0] A_out9;
wire [16:0] Q_out9;

wire [15:0] A_out10;
wire [16:0] Q_out10;

wire [15:0] A_out11;
wire [16:0] Q_out11;

wire [15:0] A_out12;
wire [16:0] Q_out12;

wire [15:0] A_out13;
wire [16:0] Q_out13;

wire [15:0] A_out14;
wire [16:0] Q_out14;

wire [15:0] A_out15;
wire [16:0] Q_out15;

wire [15:0] A_out16;
wire [16:0] Q_out16;

Booth booth1
(
	.A_in(16'b0000000000000000),
	.M(M),
	.Q_in({Q,1'b0}),
	.A_out(A_out1),
	.Q_out(Q_out1)
);

Booth booth2
(
	.A_in(A_out1),
	.M(M),
	.Q_in(Q_out1),
	.A_out(A_out2),
	.Q_out(Q_out2)
);

Booth booth3
(
	.A_in(A_out2),
	.M(M),
	.Q_in(Q_out2),
	.A_out(A_out3),
	.Q_out(Q_out3)
);

Booth booth4
(
	.A_in(A_out3),
	.M(M),
	.Q_in(Q_out3),
	.A_out(A_out4),
	.Q_out(Q_out4)
);

Booth booth5
(
	.A_in(A_out4),
	.M(M),
	.Q_in(Q_out4),
	.A_out(A_out5),
	.Q_out(Q_out5)
);

Booth booth6
(
	.A_in(A_out5),
	.M(M),
	.Q_in(Q_out5),
	.A_out(A_out6),
	.Q_out(Q_out6)
);

Booth booth7
(
	.A_in(A_out6),
	.M(M),
	.Q_in(Q_out6),
	.A_out(A_out7),
	.Q_out(Q_out7)
);

Booth booth8
(
	.A_in(A_out7),
	.M(M),
	.Q_in(Q_out7),
	.A_out(A_out8),
	.Q_out(Q_out8)
);

Booth booth9
(
	.A_in(A_out8),
	.M(M),
	.Q_in(Q_out8),
	.A_out(A_out9),
	.Q_out(Q_out9)
);

Booth booth10
(
	.A_in(A_out9),
	.M(M),
	.Q_in(Q_out9),
	.A_out(A_out10),
	.Q_out(Q_out10)
);

Booth booth11
(
	.A_in(A_out10),
	.M(M),
	.Q_in(Q_out10),
	.A_out(A_out11),
	.Q_out(Q_out11)
);

Booth booth12
(
	.A_in(A_out11),
	.M(M),
	.Q_in(Q_out11),
	.A_out(A_out12),
	.Q_out(Q_out12)
);

Booth booth13
(
	.A_in(A_out12),
	.M(M),
	.Q_in(Q_out12),
	.A_out(A_out13),
	.Q_out(Q_out13)
);

Booth booth14
(
	.A_in(A_out13),
	.M(M),
	.Q_in(Q_out13),
	.A_out(A_out14),
	.Q_out(Q_out14)
);

Booth booth15
(
	.A_in(A_out14),
	.M(M),
	.Q_in(Q_out14),
	.A_out(A_out15),
	.Q_out(Q_out15)
);

Booth booth16
(
	.A_in(A_out15),
	.M(M),
	.Q_in(Q_out15),
	.A_out(A_out16),
	.Q_out(Q_out16)
);
assign Z={A_out16,Q_out16[16:1]};
endmodule 