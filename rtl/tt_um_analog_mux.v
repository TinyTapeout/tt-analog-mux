/*
 * tt_um_analog_mux.v
 *
 * Analog Multiplexer for Tiny Tapeout 05
 *
 * Author: Uri Shaked
 */

`default_nettype none

/* verilator lint_off UNUSEDSIGNAL */

module tt_um_analog_mux #(
	parameter integer N_USER_MODULES = 4 /* Max of 7 */
) (
	input  wire [7:0] ui_in,	// Dedicated inputs
	output wire [7:0] uo_out,	// Dedicated outputs
	input  wire [7:0] uio_in,	// IOs: Input path
	output wire [7:0] uio_out,// IOs: Output path
	output wire [7:0] uio_oe,	// IOs: Enable path (active high: 0=input, 1=output)
	input  wire       ena,
	input  wire       clk,
	input  wire       rst_n,
	inout  wire [1:0] pad_analog, // Analog inputs
	inout  wire [N_USER_MODULES - 1:0] user_analog0,
	inout  wire [N_USER_MODULES - 1:0] user_analog1
);

	assign uo_out = {en, 3'b000, selected_design};
	assign uio_oe = 0;
	assign uio_out = 0;

	wire i_latch = ui_in[7];
	wire i_en = ui_in[6];
	wire [3:0] i_selected_design_in = ui_in[3:0];

	reg en = 0;
	reg [3:0] selected_design = 0;

  generate 
		genvar i;
		for (i = 0; i < N_USER_MODULES; i = i + 1) begin : sw_gen
			wire design_en = en && (selected_design == i);

			switch_5t sw0(
				.en(design_en),
				.en_b(!design_en),
				.in(pad_analog[0]),
				.out(user_analog0[i])
			);

			switch_5t sw1(
				.en(design_en),
				.en_b(!design_en),
				.in(pad_analog[1]),
				.out(user_analog1[i])
			);
		end
	endgenerate

	always @(posedge i_latch) begin
		en <= i_en;
		selected_design <= i_selected_design_in;
	end

endmodule // tt_um_analog_mux
