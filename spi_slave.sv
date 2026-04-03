module spi_slave (
    input logic sclk,
    input logic mosi,
    output logic miso,
    input logic cs_n,
    input logic [7:0] response_data,  // Data to send back to master
    output logic [7:0] received_data   // Data received from master
);

    // Internal registers
    logic [7:0] shift_reg_rx;          // Shift register for incoming data
    logic [7:0] shift_reg_tx;          // Shift register for outgoing data
    logic [3:0] bit_count;             // Counter for bits received (0-8)

    // SPI slave logic
    always_ff @(posedge sclk) begin
        if (cs_n) begin
            // Reset on chip select inactive (CS high)
            shift_reg_rx <= 8'b0;
            shift_reg_tx <= 8'b0;
            bit_count <= 0;
        end else begin
            // Shift in the incoming bit from MOSI (MSB first)
            shift_reg_rx <= {shift_reg_rx[6:0], mosi};
            
            // Load response data at the start of transmission
            if (bit_count == 0) begin
                shift_reg_tx <= response_data;
            end
            
            // Shift out the next bit on MISO
            miso <= shift_reg_tx[7];
            shift_reg_tx <= {shift_reg_tx[6:0], 1'b0}; // Shift left
            
            bit_count <= bit_count + 1;
        end
    end

    // Output the received data
    assign received_data = shift_reg_rx;

endmodule
