module spi_top (
    input logic sclk,
    input logic [7:0] master_data_in,
    input logic master_load,
    output logic master_done,
    output logic [7:0] master_data_out,
    output logic cs0_n, cs1_n, cs2_n  // Individual chip selects for each slave
);

    // Internal signals
    logic mosi;
    logic miso_s0, miso_s1, miso_s2;
    logic [7:0] slave0_rx, slave1_rx, slave2_rx;
    
    // Master instance
    spi_master m0 (
        .sclk(sclk),
        .data_in(master_data_in),
        .load(master_load),
        .cs_n(cs0_n),                    // Use cs0_n for now (can be extended)
        .mosi(mosi),
        .miso(miso_s0),                  // Receive from active slave
        .data_out(master_data_out),
        .done(master_done)
    );

    // Slave 0 instance
    spi_slave s0 (
        .sclk(sclk),
        .mosi(mosi),
        .miso(miso_s0),
        .cs_n(cs0_n),
        .response_data(8'hA5),           // Response data: 10100101
        .received_data(slave0_rx)
    );

    // Slave 1 instance
    spi_slave s1 (
        .sclk(sclk),
        .mosi(mosi),
        .miso(miso_s1),
        .cs_n(cs1_n),
        .response_data(8'h5A),           // Response data: 01011010
        .received_data(slave1_rx)
    );

    // Slave 2 instance
    spi_slave s2 (
        .sclk(sclk),
        .mosi(mosi),
        .miso(miso_s2),
        .cs_n(cs2_n),
        .response_data(8'h55),           // Response data: 01010101
        .received_data(slave2_rx)
    );

endmodule