module spi_testbench;

    // Clock and reset signals
    logic sclk;
    logic [7:0] master_data_in;
    logic master_load;
    logic master_done;
    logic [7:0] master_data_out;
    logic cs0_n, cs1_n, cs2_n;
    
    // Expected data
    logic [7:0] expected_slave0_response = 8'hA5;
    logic [7:0] expected_slave1_response = 8'h5A;
    logic [7:0] expected_slave2_response = 8'h55;
    
    // Test counters
    int test_count = 0;
    int pass_count = 0;
    int fail_count = 0;
    
    // Test 4 response variables
    logic [7:0] first_response;
    logic [7:0] second_response;
    
    // Instantiate the DUT (Design Under Test)
    spi_top dut (
        .sclk(sclk),
        .master_data_in(master_data_in),
        .master_load(master_load),
        .master_done(master_done),
        .master_data_out(master_data_out),
        .cs0_n(cs0_n),
        .cs1_n(cs1_n),
        .cs2_n(cs2_n)
    );
    
    // Clock generation: 10 MHz clock (100ns period)
    initial begin
        sclk = 0;
        forever begin
            #50 sclk = ~sclk;  // 50ns high, 50ns low = 100ns period
        end
    end
    
    // Test stimulus
    initial begin
        $display("=========================================");
        $display("     SPI Master-Slave Communication Test");
        $display("=========================================");
        $display("Time: %0t", $time);
        
        // Initialize signals
        master_load = 0;
        master_data_in = 8'h00;
        cs0_n = 1;
        cs1_n = 1;
        cs2_n = 1;
        
        // Wait for a few clock cycles to stabilize
        repeat(2) @(posedge sclk);
        
        // ===== TEST 1: Communicate with Slave 0 =====
        $display("\n[TEST 1] Communicating with Slave 0");
        $display("Master sends: 0xAA, Slave 0 responds: 0xA5");
        test_count++;
        
        cs0_n = 0;  // Select Slave 0
        cs1_n = 1;  // Deselect other slaves
        cs2_n = 1;
        
        @(posedge sclk);
        master_data_in = 8'hAA;
        master_load = 1;
        @(posedge sclk);
        master_load = 0;
        
        // Wait for transmission to complete (8 bits + 1 extra clock)
        wait(master_done == 1);
        @(posedge sclk);
        
        $display("Time: %0t, Master received: 0x%02H (expected: 0x%02H)", 
                 $time, master_data_out, expected_slave0_response);
        
        if (master_data_out == expected_slave0_response) begin
            $display("✓ TEST 1 PASSED");
            pass_count++;
        end else begin
            $display("✗ TEST 1 FAILED");
            fail_count++;
        end
        
        // Deselect Slave 0
        cs0_n = 1;
        @(posedge sclk);
        repeat(2) @(posedge sclk);
        
        // ===== TEST 2: Communicate with Slave 1 =====
        $display("\n[TEST 2] Communicating with Slave 1");
        $display("Master sends: 0x55, Slave 1 responds: 0x5A");
        test_count++;
        
        cs1_n = 0;  // Select Slave 1
        cs0_n = 1;  // Deselect other slaves
        cs2_n = 1;
        
        @(posedge sclk);
        master_data_in = 8'h55;
        master_load = 1;
        @(posedge sclk);
        master_load = 0;
        
        // Wait for transmission to complete
        wait(master_done == 1);
        @(posedge sclk);
        
        $display("Time: %0t, Master received: 0x%02H (expected: 0x%02H)", 
                 $time, master_data_out, expected_slave1_response);
        
        if (master_data_out == expected_slave1_response) begin
            $display("✓ TEST 2 PASSED");
            pass_count++;
        end else begin
            $display("✗ TEST 2 FAILED");
            fail_count++;
        end
        
        // Deselect Slave 1
        cs1_n = 1;
        @(posedge sclk);
        repeat(2) @(posedge sclk);
        
        // ===== TEST 3: Communicate with Slave 2 =====
        $display("\n[TEST 3] Communicating with Slave 2");
        $display("Master sends: 0xFF, Slave 2 responds: 0x55");
        test_count++;
        
        cs2_n = 0;  // Select Slave 2
        cs0_n = 1;  // Deselect other slaves
        cs1_n = 1;
        
        @(posedge sclk);
        master_data_in = 8'hFF;
        master_load = 1;
        @(posedge sclk);
        master_load = 0;
        
        // Wait for transmission to complete
        wait(master_done == 1);
        @(posedge sclk);
        
        $display("Time: %0t, Master received: 0x%02H (expected: 0x%02H)", 
                 $time, master_data_out, expected_slave2_response);
        
        if (master_data_out == expected_slave2_response) begin
            $display("✓ TEST 3 PASSED");
            pass_count++;
        end else begin
            $display("✗ TEST 3 FAILED");
            fail_count++;
        end
        
        // Deselect Slave 2
        cs2_n = 1;
        @(posedge sclk);
        repeat(2) @(posedge sclk);
        
        // ===== TEST 4: Back-to-back transmission to same slave =====
        $display("\n[TEST 4] Back-to-back transmission to Slave 0");
        $display("First transfer: 0x12, Second transfer: 0x34");
        test_count++;
        
        cs0_n = 0;  // Select Slave 0
        cs1_n = 1;
        cs2_n = 1;
        
        // First transfer
        @(posedge sclk);
        master_data_in = 8'h12;
        master_load = 1;
        @(posedge sclk);
        master_load = 0;
        
        wait(master_done == 1);
        first_response = master_data_out;
        @(posedge sclk);
        
        $display("Time: %0t, First transfer - Master received: 0x%02H", 
                 $time, first_response);
        
        // Second transfer immediately after
        @(posedge sclk);
        master_data_in = 8'h34;
        master_load = 1;
        @(posedge sclk);
        master_load = 0;
        
        wait(master_done == 1);
        second_response = master_data_out;
        @(posedge sclk);
        
        $display("Time: %0t, Second transfer - Master received: 0x%02H", 
                 $time, second_response);
        
        if ((first_response == expected_slave0_response) && 
            (second_response == expected_slave0_response)) begin
            $display("✓ TEST 4 PASSED");
            pass_count++;
        end else begin
            $display("✗ TEST 4 FAILED");
            fail_count++;
        end
        
        // Deselect
        cs0_n = 1;
        repeat(2) @(posedge sclk);
        
        // ===== Print Test Summary =====
        $display("\n=========================================");
        $display("           Test Summary");
        $display("=========================================");
        $display("Total Tests: %0d", test_count);
        $display("Passed: %0d", pass_count);
        $display("Failed: %0d", fail_count);
        
        if (fail_count == 0) begin
            $display("\n✓ ALL TESTS PASSED!");
        end else begin
            $display("\n✗ SOME TESTS FAILED!");
        end
        $display("=========================================\n");
        
        $finish;
    end
    
    // Monitor to display key signals in real-time
    initial begin
        $monitor("Time: %0t | sclk=%b | cs0=%b cs1=%b cs2=%b | load=%b | mosi=%b | data_out=0x%02H | done=%b", 
                 $time, sclk, cs0_n, cs1_n, cs2_n, master_load, dut.mosi, master_data_out, master_done);
    end
    
endmodule
