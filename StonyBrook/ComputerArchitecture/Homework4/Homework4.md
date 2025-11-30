# Task 1: Implement a Direct-Mapped Cache

Here is the code for my cache controller
```Verilog
// Direct-mapped cache (8KB, 32-byte blocks, write-back, write-allocate)
module cache_controller(
    input wire clk,
    input wire reset,
    input wire cpu_read,
    input wire cpu_write,
    input wire [31:0] cpu_addr,
    input wire [31:0] cpu_write_data,
    output reg [31:0] cpu_read_data,
    output reg cache_stall,
    output reg mem_write_en,
    output reg [31:0] mem_write_addr,
    output reg [31:0] mem_write_data,
    output reg mem_read_en,
    output reg [31:0] mem_read_addr,
    input wire [31:0] mem_read_data
);
    // 8KB cache / 32 bytes per block = 256 blocks
    // Direct-mapped: index = 8 bits
    // Block offset = 5 bits (32 bytes = 8 words)
    // Tag = 32 - 8 - 5 = 19 bits
    
    parameter INDEX_BITS = 8;
    parameter OFFSET_BITS = 5;
    parameter TAG_BITS = 19;
    parameter NUM_BLOCKS = 256;
    parameter WORDS_PER_BLOCK = 8;
    
    reg valid_bit [0:NUM_BLOCKS-1];
    reg dirty_bit [0:NUM_BLOCKS-1];
    reg [TAG_BITS-1:0] tag_field [0:NUM_BLOCKS-1];
    reg [31:0] data_block [0:NUM_BLOCKS-1][0:WORDS_PER_BLOCK-1];
    
    wire [TAG_BITS-1:0] addr_tag = cpu_addr[31:31-TAG_BITS+1];
    wire [INDEX_BITS-1:0] addr_index = cpu_addr[31-TAG_BITS:OFFSET_BITS];
    wire [2:0] addr_word_offset = cpu_addr[4:2];
    
    parameter IDLE = 3'b000;
    parameter COMPARE_TAG = 3'b001;
    parameter WRITE_BACK = 3'b010;
    parameter ALLOCATE = 3'b011;
    parameter WRITE_HIT = 3'b100;
    
    reg [2:0] state;
    reg [2:0] wb_counter;
    reg [2:0] alloc_counter;
    reg was_read;  // Remember if original request was read or write
    
    wire cache_hit = valid_bit[addr_index] && (tag_field[addr_index] == addr_tag);
    
    integer i, j;
    
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            state <= IDLE;
            cache_stall <= 1'b0;
            mem_write_en <= 1'b0;
            mem_read_en <= 1'b0;
            cpu_read_data <= 32'b0;
            wb_counter <= 3'b0;
            alloc_counter <= 3'b0;
            
            for (i = 0; i < NUM_BLOCKS; i = i + 1) begin
                valid_bit[i] <= 1'b0;
                dirty_bit[i] <= 1'b0;
                tag_field[i] <= {TAG_BITS{1'b0}};
                for (j = 0; j < WORDS_PER_BLOCK; j = j + 1) begin
                    data_block[i][j] <= 32'b0;
                end
            end
        end else begin
            case (state)
                IDLE: begin
                    cache_stall <= 1'b0;
                    mem_write_en <= 1'b0;
                    mem_read_en <= 1'b0;
                    
                    if (cpu_read || cpu_write) begin
                        state <= COMPARE_TAG;
                        cache_stall <= 1'b1;
                    end
                end
                
                COMPARE_TAG: begin
                    if (cache_hit) begin
                        if (cpu_read) begin
                            cpu_read_data <= data_block[addr_index][addr_word_offset];
                            cache_stall <= 1'b0;
                            state <= IDLE;
                        end else if (cpu_write) begin
                            state <= WRITE_HIT;
                        end
                    end else begin
                        // Save whether this is a read or write for later
                        was_read <= cpu_read;
                        if (valid_bit[addr_index] && dirty_bit[addr_index]) begin
                            state <= WRITE_BACK;
                            wb_counter <= 3'b0;
                        end else begin
                            state <= ALLOCATE;
                            alloc_counter <= 3'b0;
                        end
                    end
                end
                
                WRITE_HIT: begin
                    data_block[addr_index][addr_word_offset] <= cpu_write_data;
                    dirty_bit[addr_index] <= 1'b1;
                    cache_stall <= 1'b0;
                    state <= IDLE;
                end
                
                WRITE_BACK: begin
                    mem_write_en <= 1'b1;
                    mem_write_addr <= {tag_field[addr_index], addr_index, wb_counter, 2'b00};
                    mem_write_data <= data_block[addr_index][wb_counter];
                    
                    if (wb_counter == 3'd7) begin
                        mem_write_en <= 1'b0;
                        state <= ALLOCATE;
                        alloc_counter <= 3'b0;
                        wb_counter <= 3'b0;
                    end else begin
                        wb_counter <= wb_counter + 1;
                    end
                end
                
                ALLOCATE: begin
                    mem_read_en <= 1'b1;
                    mem_read_addr <= {addr_tag, addr_index, alloc_counter, 2'b00};
                    
                    if (alloc_counter > 0 || mem_read_en) begin
                        data_block[addr_index][alloc_counter - 1] <= mem_read_data;
                    end
                    
                    if (alloc_counter == 3'd7) begin
                        data_block[addr_index][3'd7] <= mem_read_data;
                        
                        valid_bit[addr_index] <= 1'b1;
                        tag_field[addr_index] <= addr_tag;
                        dirty_bit[addr_index] <= 1'b0;
                        
                        mem_read_en <= 1'b0;
                        alloc_counter <= 3'b0;
                        
                        // Use saved request type, not current cpu_read/cpu_write
                        if (was_read) begin
                            cpu_read_data <= data_block[addr_index][addr_word_offset];
                            cache_stall <= 1'b0;
                            state <= IDLE;
                        end else begin
                            state <= WRITE_HIT;
                        end
                    end else begin
                        alloc_counter <= alloc_counter + 1;
                    end
                end
                
                default: begin
                    state <= IDLE;
                end
            endcase
        end
    end
endmodule
```


## Cache Statistics

| Metric                  | Test 6 |
|-------------------------|--------|
| Total memory accesses   | 87     |
| Cache hits              | 74     |
| Cache misses            | 13     |
| Hit rate                | 85.06% |

# Task 2: Implement a Set-Associative Cache

I added an LRU bit for each set, and used 20 bits for the tag, and 7 bits for the index

```Verilog
module cache_controller(
    input wire clk,
    input wire reset,
    input wire cpu_read,
    input wire cpu_write,
    input wire [31:0] cpu_addr,
    input wire [31:0] cpu_write_data,
    output reg [31:0] cpu_read_data,
    output reg cache_stall,
    output reg mem_write_en,
    output reg [31:0] mem_write_addr,
    output reg [31:0] mem_write_data,
    output reg mem_read_en,
    output reg [31:0] mem_read_addr,
    input wire [31:0] mem_read_data
);
    // 8KB cache / 32 bytes per block = 256 blocks
    // 2-way set-associative: 256 blocks / 2 ways = 128 sets
    // Index = 7 bits (128 sets)
    // Block offset = 5 bits (32 bytes = 8 words)
    // Tag = 32 - 7 - 5 = 20 bits
    
    parameter WAYS = 2;
    parameter INDEX_BITS = 7;
    parameter OFFSET_BITS = 5;
    parameter TAG_BITS = 20;
    parameter NUM_SETS = 128;
    parameter WORDS_PER_BLOCK = 8;
    
    reg valid_bit [0:NUM_SETS-1][0:WAYS-1];
    reg dirty_bit [0:NUM_SETS-1][0:WAYS-1];
    reg [TAG_BITS-1:0] tag_field [0:NUM_SETS-1][0:WAYS-1];
    reg [31:0] data_block [0:NUM_SETS-1][0:WAYS-1][0:WORDS_PER_BLOCK-1];
    reg lru_bit [0:NUM_SETS-1];  // 0 = way 0 is LRU, 1 = way 1 is LRU
    
    wire [TAG_BITS-1:0] addr_tag = cpu_addr[31:31-TAG_BITS+1];
    wire [INDEX_BITS-1:0] addr_index = cpu_addr[31-TAG_BITS:OFFSET_BITS];
    wire [2:0] addr_word_offset = cpu_addr[4:2];
    
    parameter IDLE = 3'b000;
    parameter COMPARE_TAG = 3'b001;
    parameter WRITE_BACK = 3'b010;
    parameter ALLOCATE = 3'b011;
    parameter WRITE_HIT = 3'b100;
    
    reg [2:0] state;
    reg [2:0] wb_counter;
    reg [2:0] alloc_counter;
    reg was_read;  
    reg hit_way;   
    reg victim_way; 
    
    
    reg [TAG_BITS-1:0] saved_tag;
    reg [INDEX_BITS-1:0] saved_index;
    reg [2:0] saved_word_offset;
    reg saved_cpu_read;
    reg saved_cpu_write;
    
    wire way0_hit = valid_bit[saved_index][0] && (tag_field[saved_index][0] == saved_tag);
    wire way1_hit = valid_bit[saved_index][1] && (tag_field[saved_index][1] == saved_tag);
    wire cache_hit = way0_hit || way1_hit;
    
    integer i, j, k;
    
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            state <= IDLE;
            cache_stall <= 1'b0;
            mem_write_en <= 1'b0;
            mem_read_en <= 1'b0;
            cpu_read_data <= 32'b0;
            wb_counter <= 3'b0;
            alloc_counter <= 3'b0;
            
            for (i = 0; i < NUM_SETS; i = i + 1) begin
                lru_bit[i] <= 1'b0;
                for (k = 0; k < WAYS; k = k + 1) begin
                    valid_bit[i][k] <= 1'b0;
                    dirty_bit[i][k] <= 1'b0;
                    tag_field[i][k] <= {TAG_BITS{1'b0}};
                    for (j = 0; j < WORDS_PER_BLOCK; j = j + 1) begin
                        data_block[i][k][j] <= 32'b0;
                    end
                end
            end
        end else begin
            case (state)
                IDLE: begin
                    cache_stall <= 1'b0;
                    mem_write_en <= 1'b0;
                    mem_read_en <= 1'b0;
                    
                    if (cpu_read || cpu_write) begin
                        saved_tag <= addr_tag;
                        saved_index <= addr_index;
                        saved_word_offset <= addr_word_offset;
                        saved_cpu_read <= cpu_read;
                        saved_cpu_write <= cpu_write;
                        
                        state <= COMPARE_TAG;
                        cache_stall <= 1'b1;
                    end
                end
                
                COMPARE_TAG: begin
                    if (cache_hit) begin
                        hit_way <= way0_hit ? 1'b0 : 1'b1;
                        
                        if (saved_cpu_read) begin
                            cpu_read_data <= way0_hit ? data_block[saved_index][0][saved_word_offset] 
                                                      : data_block[saved_index][1][saved_word_offset];
                            cache_stall <= 1'b0;
                            state <= IDLE;
                            lru_bit[saved_index] <= way0_hit ? 1'b1 : 1'b0;
                        end else if (saved_cpu_write) begin
                            state <= WRITE_HIT;
                        end
                    end else begin
                        was_read <= saved_cpu_read;
                        
                        if (!valid_bit[saved_index][0]) begin
                            victim_way <= 1'b0;
                        end else if (!valid_bit[saved_index][1]) begin
                            victim_way <= 1'b1;
                        end else begin
                            victim_way <= lru_bit[saved_index];
                        end
                        
                        if ((valid_bit[saved_index][lru_bit[saved_index]] && 
                             dirty_bit[saved_index][lru_bit[saved_index]]) ||
                            (!valid_bit[saved_index][0] && valid_bit[saved_index][1] && dirty_bit[saved_index][1]) ||
                            (!valid_bit[saved_index][1] && valid_bit[saved_index][0] && dirty_bit[saved_index][0])) begin
                            state <= WRITE_BACK;
                            wb_counter <= 3'b0;
                        end else begin
                            state <= ALLOCATE;
                            alloc_counter <= 3'b0;
                        end
                    end
                end
                
                WRITE_HIT: begin
                    data_block[saved_index][hit_way][saved_word_offset] <= cpu_write_data;
                    dirty_bit[saved_index][hit_way] <= 1'b1;
                    cache_stall <= 1'b0;
                    state <= IDLE;
                    lru_bit[saved_index] <= hit_way ? 1'b0 : 1'b1;
                end
                
                WRITE_BACK: begin
                    mem_write_en <= 1'b1;
                    mem_write_addr <= {tag_field[saved_index][victim_way], saved_index, wb_counter, 2'b00};
                    mem_write_data <= data_block[saved_index][victim_way][wb_counter];
                    
                    if (wb_counter == 3'd7) begin
                        mem_write_en <= 1'b0;
                        state <= ALLOCATE;
                        alloc_counter <= 3'b0;
                        wb_counter <= 3'b0;
                    end else begin
                        wb_counter <= wb_counter + 1;
                    end
                end
                
                ALLOCATE: begin
                    mem_read_en <= 1'b1;
                    mem_read_addr <= {saved_tag, saved_index, alloc_counter, 2'b00};
                    
                    if (alloc_counter > 0 || mem_read_en) begin
                        data_block[saved_index][victim_way][alloc_counter - 1] <= mem_read_data;
                    end
                    
                    if (alloc_counter == 3'd7) begin
                        data_block[saved_index][victim_way][3'd7] <= mem_read_data;
                        
                        valid_bit[saved_index][victim_way] <= 1'b1;
                        tag_field[saved_index][victim_way] <= saved_tag;
                        dirty_bit[saved_index][victim_way] <= 1'b0;
                        
                        mem_read_en <= 1'b0;
                        alloc_counter <= 3'b0;
                        
                        lru_bit[saved_index] <= victim_way ? 1'b0 : 1'b1;
                        
                        if (was_read) begin
                            cpu_read_data <= data_block[saved_index][victim_way][saved_word_offset];
                            cache_stall <= 1'b0;
                            state <= IDLE;
                        end else begin
                            hit_way <= victim_way;
                            state <= WRITE_HIT;
                        end
                    end else begin
                        alloc_counter <= alloc_counter + 1;
                    end
                end
                
                default: begin
                    state <= IDLE;
                end
            endcase
        end
    end
endmodule
```

## Cache Statistics

| Metric                  | Test 6 |
|-------------------------|--------|
| Total memory accesses   | 87     |
| Cache hits              | 74     |
| Cache misses            | 13     |
| Hit rate                | 85.06% |



## My own tests

I felt that the statistics didnt show enough of a difference so I created my own test case to illustrate the benefit of set-associative caches over direct-mapped

```
addi $t0, $0, 0
addi $t1, $0, 8192
addi $t2, $0, 32
loop3: lw $t3, 0($t0)
    nop
    nop
    lw $t4, 0($t1)
    nop
    nop
    addi $t2, $t2, -1
    bne $t2, $0, loop3
halt
```

The results of this test are as follows:

| Cache Type | Total Accesses | Cache Hits | Cache Misses | Hit Rate | Cycles |
|------------|----------------|------------|--------------|----------|--------|
| Direct-Mapped | 43 | 21 | 22 | 48.84% | 325 |
| 2-Way Set-Associative | 62 | 60 | 2 | 96.77% | 325 |