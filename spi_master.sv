module spi_master (
    input logic sclk,
    input logic [7:0] data_in,      // Data to transmit
    input logic load,                 // Signal to load data
    input logic cs_n,                 // Chip select (active low)
    output logic mosi,                // Master out, slave in
    input logic miso,                 // Master in, slave out
    output logic [7:0] data_out,      // Received data
    output logic done                 // Transmission complete flag
);

    // Internal registers
    logic [7:0] shift_reg_tx;         // Shift register for outgoing data
    logic [7:0] shift_reg_rx;         // Shift register for incoming data
    logic [3:0] bit_count;            // Counter for bits sent (0-8)
    logic transmission_active;

    // SPI master logic
    always_ff @(posedge sclk) begin
        if (cs_n) begin
            // When CS is inactive, reset
            bit_count <= 0;
            transmission_active <= 0;
            done <= 0;
        end else begin
            // Transmission is active when CS is asserted
            transmission_active <= 1;
            
            if (load) begin
                // Load new data when load signal is asserted
                shift_reg_tx <= data_in;
                bit_count <= 0;
                done <= 0;
            end else if (bit_count < 8) begin
                // Shift out the next bit on MOSI (MSB first)
                mosi <= shift_reg_tx[7];
                shift_reg_tx <= {shift_reg_tx[6:0], 1'b0}; // Shift left
                
                // Shift in the incoming bit from MISO
                shift_reg_rx <= {shift_reg_rx[6:0], miso};
                
                bit_count <= bit_count + 1;
            end else if (bit_count == 8) begin
                // After sending 8 bits, mark as done
                done <= 1;
            end
        end
    end
    
    // Output the received data
    assign data_out = shift_reg_rx;

endmodule