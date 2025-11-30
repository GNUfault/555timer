`define VA

module timer555 (vcc, gnd, trig, thres, reset, ctrl, out, disch);
    inout vcc, gnd;
    input trig, thres, reset, ctrl;
    output out, disch;

    electrical vcc, gnd, trig, thres, reset, ctrl, out, disch;

    parameter real v_reset_thresh = 0.7;
    parameter real v_out_rise     = 1n;
    parameter real v_out_fall     = 1n;
    parameter real r_out_drive    = 10.0;
    parameter real r_out_pull     = 10.0;
    parameter real r_disch_on     = 10.0;
    parameter real r_disch_off    = 1e9;
    parameter real ctrl_enable    = 1;

    integer latch;
    real vcc_val;
    real vlow, vhigh;
    real v_ctrl_ref;

    analog begin
        vcc_val = V(vcc, gnd);
        v_ctrl_ref = (ctrl_enable != 0) ? V(ctrl, gnd) : (2.0/3.0) * vcc_val;
        vhigh = v_ctrl_ref;
        vlow  = 0.5 * v_ctrl_ref;

        if (V(reset, gnd) < v_reset_thresh) begin
            latch = 0;
        end else begin
            if (V(trig, gnd) < vlow) latch = 1;
            if (V(thres, gnd) > vhigh) latch = 0;
        end

        if (latch == 1) begin
            V(out, gnd) <+ transition(vcc_val, v_out_rise, v_out_fall);
            I(out, gnd) <+ (V(out, gnd) - vcc_val) / r_out_drive;
        end else begin
            V(out, gnd) <+ transition(0.0, v_out_rise, v_out_fall);
            I(out, gnd) <+ (V(out, gnd) - 0.0) / r_out_pull;
        end

        I(disch, gnd) <+ V(disch, gnd) / (latch == 0 ? r_disch_on : r_disch_off);
    end
endmodule
