//////////////////////////////////////////////////////////////////////////////
//  File name : s25fl008a.v
//////////////////////////////////////////////////////////////////////////////
//  Copyright (C) 2004-2005 Free Model Foundry; http://www.FreeModelFoundry.com
//
//  This program is free software; you can redistribute it and/or modify
//  it under the terms of the GNU General Public License version 2 as
//  published by the Free Software Foundation.
//
//  MODIFICATION HISTORY :
//
//  version: |   author:      | mod date: | changes made:
//    V1.0    J.Bogosavljevic   04 Aug 16   Initial release
//    V1.1    R. Munden         05 Mar 09  Nomenclature changed from s25fl008m
//    V1.2    M. Vlahovic       07 Jul 06  One byte page program enabled
//
//////////////////////////////////////////////////////////////////////////////
//  PART DESCRIPTION:
//
//  Library:        FLASH
//  Technology:     Flash Memory
//  Part:           S25FL008A
//
//  Description: 8 Megabit Serial Flash Memory
//
//////////////////////////////////////////////////////////////////////////////
//  Known Bugs:
//
//////////////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////////////
// MODULE DECLARATION                                                       //
//////////////////////////////////////////////////////////////////////////////
`timescale 1 ns/1 ns
module s25fl008a
(
    SCK      ,
    SI       ,
    CSNeg    ,
    HOLDNeg  ,
    WNeg     ,
    SO
);

////////////////////////////////////////////////////////////////////////
// Port / Part Pin Declarations
////////////////////////////////////////////////////////////////////////
    input  SCK     ;
    input  SI      ;
    input  CSNeg   ;
    input  HOLDNeg ;
    input  WNeg    ;

    output SO      ;

// interconnect path delay signals
    wire  SCK_ipd      ;
    wire  SI_ipd       ;
    wire  CSNeg_ipd    ;
    wire  HOLDNeg_ipd  ;
    wire  WNeg_ipd     ;

//  internal delays
    reg PP_in       ;
    reg PP_out      ;
    reg PE_in       ;
    reg PE_out      ;
    reg BE_in       ;
    reg BE_out      ;
    reg SE_in       ;
    reg SE_out      ;
    reg WR_in       ;
    reg WR_out      ;
    reg DP_in       ;
    reg DP_out      ;
    reg RES_in      ;
    reg RES_out     ;

    reg SO_zd;
    reg SO_z;

    parameter UserPreload     = 1'b1;
    parameter mem_file_name   = "../../tb/s25fl008a.mem";

    parameter TimingModel = "DefaultTimingModel";

    parameter PartID = "s25fl008a";
    parameter MaxData = 255;
    parameter SecSize  = 16'hFFFF;
    parameter SecNum = 15;
    parameter HiAddrBit = 23;
    parameter HiAddrBitUsed = 19;
    parameter AddrRANGE = 20'hFFFFF;
    parameter BYTE = 8;
    parameter ES = 8'h14;
    parameter DeviceID = 24'h010207;

    // powerup
    reg PoweredUp = 1'bx;

    reg PDONE    ; ////Prog. Done
    reg PSTART   ; ////Start Programming

    reg EDONE    ; ////Era. Done
    reg ESTART   ; ////Start Erasing

    reg WDONE    ; //// Writing Done
    reg WSTART   ; ////Start writing

    //Command Register
    reg write;
    reg read_out;

    //Status reg.
    reg[7:0] Status_reg = 8'b0;
    reg[7:0] Status_reg_in = 8'b0;

    integer SA      = 0;         // 0 TO SecNum+1
    integer Byte_number = 0;

    //Address
    integer Address = 0;         // 0 - AddrRANGE
    reg change_addr;
    reg  rd_fast;// = 1'b1;
    reg  rd_slow;
    wire fast_rd;
    wire rd;

    //Sector Protection Status
    reg [SecNum:0] Sec_Prot;

    // timing check violation
    reg Viol = 1'b0;

    integer Mem[0:AddrRANGE];

    integer WByte[0:255];

    integer AddrLo;
    integer AddrHi;

    reg[7:0]  old_bit, new_bit;
    integer old_int, new_int;
    integer wr_cnt;

    integer read_cnt = 0;
    integer read_addr = 0;
    reg[7:0] data_out;
    reg[23:0] ident_out;

    reg oe = 1'b0;
    event oe_event;

///////////////////////////////////////////////////////////////////////////////
//Interconnect Path Delay Section
///////////////////////////////////////////////////////////////////////////////

 buf   (SCK_ipd, SCK);
 buf   (SI_ipd, SI);
 buf   (CSNeg_ipd, CSNeg);
 buf   (HOLDNeg_ipd, HOLDNeg);
 buf   (WNeg_ipd, WNeg);

///////////////////////////////////////////////////////////////////////////////
// Propagation  delay Section
///////////////////////////////////////////////////////////////////////////////
    nmos   (SO, SO_z, 1);

 specify
        // tipd delays: interconnect path delays , mapped to input port delays.
        // In Verilog is not necessary to declare any tipd_ delay variables,
        // they can be taken from SDF file
        // With all the other delays real delays would be taken from SDF file

                        // tpd delays
     specparam           tpd_SCK_SO              =0;
     specparam           tpd_CSNeg_SO            =1;
     specparam           tpd_HOLDNeg_SO          =1;

     specparam           tsetup_SI_SCK           =1;   //tsuDAT /
     specparam           tsetup_CSNeg_SCK        =1;   // tCSS /
     specparam           tsetup_HOLDNeg_SCK      =1;   //tHD /
     specparam           tsetup_WNeg_CSNeg       =1;   //tWPS \

                          // thold values: hold times
     specparam           thold_SI_SCK            =1; //thdDAT /
     specparam           thold_CSNeg_SCK         =1; //tCSH /
     specparam           thold_HOLDNeg_SCK       =1; //tCD /
     specparam           thold_WNeg_CSNeg        =1; //tWPH \

        // tpw values: pulse width
     specparam           tpw_SCK_posedge         =1; //tWH
     specparam           tpw_SCK_negedge         =1; //tWL
     specparam           tpw_CSNeg_posedge       =1; //tCS

        // tperiod min (calculated as 1/max freq)
     specparam           tperiod_SCK_rd          =1; // fSCK = 33MHz
     specparam           tperiod_SCK_fast_rd     =1; // fSCK = 50MHz

        // tdevice values: values for internal delays

            // Page Program Operation
     specparam   tdevice_PP                     = 3000000; //3 ms;
            //Sector Erase Operation
     specparam   tdevice_SE                     = 3e9; //3 sec;
            //Bulk Erase Operation
     specparam   tdevice_BE                     = 96e9; //96 sec;
            //Write Status Register Operation
     specparam   tdevice_WR                     = 67000000; // 67 ms;
            //Software Protect Mode
     specparam   tdevice_DP                     = 3000; // 3 us;
            //Release from Software Protect Mode
     specparam   tdevice_RES                    = 30000; // 30 us;
            //VCC (min) to CS# Low
     //specparam   tdevice_PU                     = 4000000; //4 ms;
     specparam   tdevice_PU                     = 4000; 

///////////////////////////////////////////////////////////////////////////////
// Input Port  Delays  don't require Verilog description
///////////////////////////////////////////////////////////////////////////////
// Path delays                                                               //
///////////////////////////////////////////////////////////////////////////////
  if (~CSNeg )
  (SCK => SO) = tpd_SCK_SO;
  (CSNeg => SO) = tpd_CSNeg_SO;
  (HOLDNeg => SO) = tpd_HOLDNeg_SO;

////////////////////////////////////////////////////////////////////////////////
// Timing Violation                                                           //
////////////////////////////////////////////////////////////////////////////////
    $setup ( WNeg , negedge CSNeg, tsetup_WNeg_CSNeg, Viol);
    $hold ( posedge CSNeg, WNeg,  thold_WNeg_CSNeg, Viol);

    $setuphold ( posedge SCK, HOLDNeg, tsetup_HOLDNeg_SCK,
                                                thold_HOLDNeg_SCK, Viol);
    $setuphold ( posedge SCK, SI, tsetup_SI_SCK, thold_SI_SCK, Viol);
    $setuphold ( posedge SCK, CSNeg, tsetup_CSNeg_SCK,
                                                  thold_CSNeg_SCK, Viol);

    $width (posedge SCK, tpw_SCK_posedge);
    $width (negedge SCK, tpw_SCK_negedge);

    $width (posedge CSNeg, tpw_CSNeg_posedge);

    $period (posedge SCK &&& rd, tperiod_SCK_rd);
    $period (posedge SCK &&& fast_rd, tperiod_SCK_fast_rd);

    endspecify

////////////////////////////////////////////////////////////////////////////////
// Main Behavior Block                                                        //
////////////////////////////////////////////////////////////////////////////////
// FSM states
 parameter IDLE            =4'd0;
 parameter WRITE_SR        =4'd1;
 parameter DP_DOWN         =4'd2;
 parameter SECTOR_ER       =4'd3;
 parameter BULK_ER         =4'd4;
 parameter PAGE_PG         =4'd5;

 reg [3:0] current_state;
 reg [3:0] next_state;

// Instructions
 parameter NONE            =5'd0;
 parameter WREN            =5'd1;
 parameter WRDI            =5'd2;
 parameter WRSR            =5'd3;
 parameter RDSR            =5'd4;
 parameter READ            =5'd5;
 parameter FAST_READ       =5'd6;
 parameter SE              =5'd8;
 parameter BE              =5'd9;
 parameter PP              =5'd10;
 parameter DP              =5'd11;
 parameter RDID            =5'd12;
 parameter RES_READ_ES     =5'd13;

 reg [4:0] Instruct;

//Bus cycle states
 parameter STAND_BY        =3'd0;
 parameter CODE_BYTE       =3'd1;
 parameter ADDRESS_BYTES   =3'd2;
 parameter DUMMY_BYTES     =3'd3;
 parameter DATA_BYTES      =3'd4;

 reg [2:0] bus_cycle_state;

    initial
    begin : Init

        write    = 1'b0;
        read_out  = 1'b0;
        Address   = 0;
        change_addr = 1'b0;

        read_cnt = 0;
        read_addr = 0;

        PDONE    = 1'b1;
        PSTART   = 1'b0;

        EDONE    = 1'b1;
        ESTART   = 1'b0;

        WDONE    = 1'b1;
        WSTART   = 1'b0;

        DP_in = 1'b0;
        DP_out = 1'b0;
        RES_in = 1'b0;
        RES_out = 1'b0;
        Instruct = NONE;
    end

    // initialize memory
    initial
    begin: InitMemory
    integer i;

        for (i=0;i<=AddrRANGE;i=i+1)
        begin
            Mem[i] = MaxData;
        end

        if ((UserPreload) && !(mem_file_name == "none"))
        begin
           // Memory Preload
           //s25fl008a.mem, memory preload file
           //  @aaaaa  - <aaaaa> stands for address
           //  dd      - <dd> is byte to be written at Mem(aaaaa++)
           // (aaaaa is incremented at every load)
           $readmemh(mem_file_name,Mem);
        end
    end

    //Power Up time;
    initial
    begin
        #1 PoweredUp = 1'b0;
        #tdevice_PU PoweredUp = 1'b1;
    end

   always @(posedge DP_in)
   begin:TDPr
     #tdevice_DP DP_out = DP_in;
   end
   always @(negedge DP_in)
   begin:TDPf
     #1 DP_out = DP_in;
   end

   always @(posedge RES_in)
   begin:TRESr
     #tdevice_RES RES_out = RES_in;
   end
   always @(negedge RES_in)
   begin:TRESf
     #1 RES_out = RES_in;
   end

    always @(next_state or PoweredUp)
    begin: StateTransition
        if (PoweredUp)
            current_state = next_state;
        else
            current_state = IDLE;
    end

    always @(PoweredUp)
    begin:CheckCEOnPowerUP
        if ((~PoweredUp) && (~CSNeg_ipd))
            $display ("Device is selected during Power Up");
    end

//   ///////////////////////////////////////////////////////////////////////////
//   // Instruction cycle decode
//   ///////////////////////////////////////////////////////////////////////////
 integer data_cnt = 0;
 integer addr_cnt = 0;
 integer code_cnt = 0;
 integer dummy_cnt = 0;
 integer bit_cnt = 0;
 reg[2047:0] Data_in = 2048'b0;
 reg[7:0] code = 8'b0;
 reg[7:0] code_in = 8'b0;
 reg[7:0] Byte_slv = 8'b0;
 reg[HiAddrBitUsed:0] addr_bytes;
 reg[23:0] Address_in = 8'b0;

    always @(negedge CSNeg_ipd or PoweredUp)
    begin: Buscycle1
        if (PoweredUp != 1)
            bus_cycle_state = STAND_BY;
        else
            if (bus_cycle_state==STAND_BY)
            begin
                bus_cycle_state = CODE_BYTE;
                Instruct = NONE;
                write = 1'b1;
                code_cnt = 0;
                addr_cnt = 0;
                data_cnt = 0;
                dummy_cnt = 0;
            end
    end

    always @(posedge SCK_ipd or PoweredUp)
    begin: Buscycle2
    integer i;
        if (PoweredUp != 1)
            bus_cycle_state = IDLE;
        else
        if ( HOLDNeg_ipd)
        begin
            case (bus_cycle_state)
                CODE_BYTE :
                begin
                    code_in[code_cnt] = SI_ipd;
                    code_cnt = code_cnt + 1;
                    if (code_cnt == BYTE)
                    begin
                        for (i=0;i<=7;i=i+1)
                        begin
                            code[i] = code_in[7-i];
                        end
                        Instruct = NONE;
                        bus_cycle_state = IDLE;
                        case(code)
                            8'b00000110 :
                            begin
                                Instruct = WREN;
                                bus_cycle_state = DATA_BYTES;
                            end
                            8'b00000100 :
                            begin
                                Instruct = WRDI;
                                bus_cycle_state = DATA_BYTES;
                            end
                            8'b00000001 :
                            begin
                                Instruct = WRSR;
                                bus_cycle_state = DATA_BYTES;
                            end
                            8'b00000101 :
                            begin
                                Instruct = RDSR;
                                bus_cycle_state = DATA_BYTES;
                            end
                            8'b00000011 :
                            begin
                                Instruct = READ;
                                bus_cycle_state = ADDRESS_BYTES;
                            end
                            8'b00001011 :
                            begin
                                Instruct = FAST_READ;
                                bus_cycle_state = ADDRESS_BYTES;
                            end
                            8'b10101011 :
                            begin
                                Instruct = RES_READ_ES;
                                bus_cycle_state = DUMMY_BYTES;
                            end
                            8'b11011000 :
                            begin
                                Instruct = SE;
                                bus_cycle_state = ADDRESS_BYTES;
                            end
                            8'b11000111 :
                            begin
                                Instruct = BE;
                                bus_cycle_state = DATA_BYTES;
                            end
                            8'b00000010 :
                            begin
                                Instruct = PP;
                                bus_cycle_state = ADDRESS_BYTES;
                            end
                            8'b10111001 :
                            begin
                                Instruct = DP;
                                bus_cycle_state = DATA_BYTES;
                            end
                            8'b10011111 :
                            begin
                                Instruct = RDID;
                                bus_cycle_state = DATA_BYTES;
                            end
                        endcase
                    end
                end

                ADDRESS_BYTES :
                begin
                    Address_in[addr_cnt] = SI_ipd;
                    addr_cnt = addr_cnt + 1;
                    if (addr_cnt == 3*BYTE)
                    begin
                        for (i=HiAddrBit;i>=HiAddrBit-HiAddrBitUsed;i=i-1)
                        begin
                            addr_bytes[HiAddrBit-i] = Address_in[i];
                        end
                        Address = addr_bytes;
                        change_addr = 1'b1;
                        #1 change_addr = 1'b0;
                        if (Instruct == FAST_READ)
                            bus_cycle_state = DUMMY_BYTES;
                        else
                            bus_cycle_state = DATA_BYTES;
                    end
                end

                DUMMY_BYTES :
                begin
                    dummy_cnt = dummy_cnt + 1;
                    if ((dummy_cnt == BYTE && Instruct == FAST_READ) ||
                        (dummy_cnt == 3*BYTE && Instruct == RES_READ_ES))
                        bus_cycle_state = DATA_BYTES;
                end

                DATA_BYTES :
                begin
                    if (data_cnt > 2047)
                    //In case of PP, if more than 256 bytes are
                    //sent to the device
                    begin
                        if (bit_cnt == 0)
                        begin
                            for (i=0;i<=(255*BYTE-1);i=i+1)
                            begin
                                Data_in[i] = Data_in[i+8];
                            end
                        end
                        Data_in[2040 + bit_cnt] = SI_ipd;
                        bit_cnt = bit_cnt + 1;
                        if (bit_cnt == 8)
                        begin
                            bit_cnt = 0;
                        end
                        data_cnt = data_cnt + 1;
                    end
                    else
                    begin
                        Data_in[data_cnt] = SI_ipd;
                        data_cnt = data_cnt + 1;
                        bit_cnt = 0;
                    end
                end
            endcase
        end
    end

    always @(negedge SCK_ipd or PoweredUp)
    begin: Buscycle3
        if (PoweredUp == 1)
        if (bus_cycle_state==DATA_BYTES && (~CSNeg_ipd))
            if (Instruct == READ || Instruct == RES_READ_ES ||
                Instruct == FAST_READ || Instruct == RDSR ||
                Instruct == RDID)
                read_out = 1'b1;
                #1 read_out = 1'b0;
    end

    always @(posedge CSNeg_ipd or PoweredUp)
    begin: Buscycle4
    integer i;
    integer j;
        if (PoweredUp != 1)
            bus_cycle_state = IDLE;
        else
        if (bus_cycle_state == DATA_BYTES)
        begin
            bus_cycle_state = STAND_BY;
            if (HOLDNeg_ipd)
            begin
                case (Instruct)
                    WREN,
                    WRDI,
                    DP,
                    BE,
                    SE :
                    begin
                        if (data_cnt == 0)
                            write = 1'b0;
                    end

                    RES_READ_ES,
                    RDID :
                    begin
                        write = 1'b0;
                    end

                    WRSR :
                    begin
                        if (data_cnt == BYTE)
                            write = 1'b0;
                            Status_reg_in = Data_in[7:0];
                    end

                    PP :
                    begin
                        if ((data_cnt >= BYTE) && ((data_cnt % 8) == 0))
                        begin
                            write = 1'b0;
                            for (i=0;i<=255;i=i+1)
                            begin
                                for (j=7;j>=0;j=j-1)
                                begin
                                    Byte_slv[j] = Data_in[(i*8) + (7-j)];
                                end
                                WByte[i] = Byte_slv;
                            end
                            if (data_cnt > 256*BYTE)
                                Byte_number = 255;
                            else
                                Byte_number = ((data_cnt/8) - 1);
                        end
                    end
                endcase
            end
        end
        else if (bus_cycle_state==DUMMY_BYTES)
        begin
            bus_cycle_state = STAND_BY;
            if (Instruct == RES_READ_ES  && HOLDNeg_ipd && dummy_cnt==0)
            begin
                write = 1'b0;
            end
        end
        else
        begin
            bus_cycle_state = STAND_BY;
        end
    end

//   ///////////////////////////////////////////////////////////////////////////
//   // Timing control for the Program Operations
//   // start
//   ///////////////////////////////////////////////////////////////////////////

 event pdone_event;
    always @(PSTART)
    begin
      if (PSTART && PDONE)
        begin
            if (~(Sec_Prot[SA]))
            begin
                PDONE = 1'b0;
                ->pdone_event;
            end
        end
    end

    always @(pdone_event)
    begin:pdone_process
        PDONE = 1'b0;
        #tdevice_PP PDONE = 1'b1;
    end

//   ///////////////////////////////////////////////////////////////////////////
//   // Timing control for the Write Status Register Operation
//   // start
//   ///////////////////////////////////////////////////////////////////////////

 event wdone_event;

    always @(WSTART)
    begin
        if (WSTART && WDONE)
        begin
            WDONE = 1'b0;
            ->wdone_event;
        end
    end

    always @(wdone_event)
    begin:wdone_process
        WDONE = 1'b0;
        #tdevice_WR WDONE = 1'b1;
    end

//   ///////////////////////////////////////////////////////////////////////////
//   // Timing control for the Erase Operations
//   ///////////////////////////////////////////////////////////////////////////
 integer cnt_erase = 0;
 time duration_erase;

    event edone_event;

    always @(ESTART)
    begin: erase
        if (ESTART && EDONE)
        begin

            if (Instruct == BE)
            begin
                duration_erase = tdevice_BE;
            end
            else //if (Instruct == SE)
            begin
                duration_erase = tdevice_SE;
            end

            EDONE = 1'b0;
            ->edone_event;
        end
    end

    always @(edone_event)
    begin : edone_process
        EDONE = 1'b0;
        #duration_erase EDONE = 1'b1;
    end

//   ///////////////////////////////////////////////////////////////////////////
//   // Main Behavior Process
//   // combinational process for next state generation
//   ///////////////////////////////////////////////////////////////////////////

    integer sect;

    always @(negedge write or PoweredUp)
    begin: StateGen1
        if (PoweredUp !=1'b1)
            next_state = current_state;
        else
        case (current_state)
            IDLE :
            begin
                if (~write)
                begin
                    if (Instruct == WRSR && Status_reg[1])
                    begin
                        if (~(Status_reg[7] && (~WNeg_ipd)))
                            next_state = WRITE_SR;
                    end
                    else if (Instruct == PP && Status_reg[1])
                    begin
                        sect = Address / 24'h10000;
                        if (Sec_Prot[sect] == 1'b0)
                            next_state = PAGE_PG;
                    end
                    else if (Instruct == SE && Status_reg[1])
                    begin
                        sect = Address / 24'h10000;
                        if (Sec_Prot[sect] == 1'b0)
                            next_state = SECTOR_ER;
                    end
                    else if (Instruct == BE && Status_reg[1])
                    begin
                        if (Status_reg[2] == 1'b0 && Status_reg[3] == 1'b0
                            && Status_reg[4] == 1'b0)
                            next_state = BULK_ER;
                    end
                    else if (Instruct == DP)
                        next_state = DP_DOWN;
                    else
                        next_state = IDLE;
                end
            end

            DP_DOWN:
            begin
                if (~write)
                begin
                    if (Instruct == RES_READ_ES)
                        next_state = IDLE;
                end
            end

        endcase
    end

    always @(posedge PDONE or PoweredUp)
    begin: StateGen2
        if (PoweredUp !=1'b1)
            next_state = current_state;
        else
        begin
            if (current_state==PAGE_PG)
                next_state = IDLE;
        end
    end

    always @(posedge WDONE or PoweredUp)
    begin: StateGen3
        if (PoweredUp !=1'b1)
            next_state = current_state;
        else
        begin
            if (current_state==WRITE_SR)
                next_state = IDLE;
        end
    end

    always @(posedge EDONE or PoweredUp)
    begin: StateGen4
        if (PoweredUp !=1'b1)
            next_state = current_state;
        else
        begin
            if (current_state==SECTOR_ER || current_state==BULK_ER)
                next_state = IDLE;
        end
    end

    ///////////////////////////////////////////////////////////////////////////
    //FSM Output generation and general funcionality
    ///////////////////////////////////////////////////////////////////////////

    always @(posedge read_out)
    begin
        if (PoweredUp == 1 && HOLDNeg_ipd == 1)
            ->oe_event;
    end

    always @(oe_event)
    begin
        oe = 1'b1;
        #1 oe = 1'b0;
    end

    always @(Instruct)
    begin
        read_cnt = 0;
    end

    always @(change_addr)
    begin
        if (change_addr)
            read_addr = Address;
    end

    always @(Instruct)
    begin
        rd_fast = 1'b1;
        rd_slow = 1'b0;
    end

    always @(oe or current_state or PoweredUp)
    begin
        if (PoweredUp ==1'b1)
        case (current_state)
            IDLE :
            begin
                if (oe && RES_in == 1'b0)
                begin
                    if (Instruct == RDSR)
                    begin
                    //Read Status Register
                        SO_zd = Status_reg[7-read_cnt];
                        read_cnt = read_cnt + 1;
                        if (read_cnt == 8)
                            read_cnt = 0;
                    end
                    else if (Instruct == READ || Instruct == FAST_READ)
                    begin
                    //Read Memory array
                        if (Instruct == READ)
                        begin
                            rd_fast = 1'b0;
                            rd_slow = 1'b1;
                        end
                        data_out[7:0] = Mem[read_addr];
                        SO_zd = data_out[7-read_cnt];
                        read_cnt = read_cnt + 1;
                        if (read_cnt == 8)
                        begin
                            read_cnt = 0;
                            if (read_addr == AddrRANGE)
                                read_addr = 0;
                            else
                                read_addr = read_addr + 1;
                        end
                    end
                    else if (Instruct == RDID)
                    begin
                    // Read ID
                        ident_out[23:0] = DeviceID;
                        SO_zd = ident_out[23-read_cnt];
                        read_cnt = read_cnt + 1;
                        if (read_cnt == 24)
                            read_cnt = 0;
                    end
                end
                else if (oe && RES_in == 1'b1)
                begin
                    $display ("Command results can be corrupted");
                    SO_zd = 1'bX;
                    read_cnt = read_cnt + 1;
                    if (read_cnt == 8)
                        read_cnt = 0;
                end
            end

            WRITE_SR,
            SECTOR_ER,
            BULK_ER,
            PAGE_PG :
            begin
                if (oe && Instruct == RDSR)
                begin
                //Read Status Register
                    SO_zd = Status_reg[7-read_cnt];
                    read_cnt = read_cnt + 1;
                    if (read_cnt == 8)
                        read_cnt = 0;
                end
            end

            DP_DOWN :
            begin
                if (oe && Instruct == RES_READ_ES)
                begin
                // Read ID
                    data_out[7:0] = ES;
                    SO_zd = data_out[7-read_cnt];
                    read_cnt = read_cnt + 1;
                    if (read_cnt == 8)
                        read_cnt = 0;
                end
            end

        endcase
    end

    assign fast_rd = rd_fast;
    assign rd = rd_slow;

    integer sector;
    integer WData [0:255];
    integer Addr;

    always @(negedge write or PoweredUp)
    begin : Output_generation
    integer i;
        if (PoweredUp ==1'b1)
        case (current_state)
            IDLE :
            begin
                if (~write)
                begin
                        if (RES_in == 1'b1)
                        begin
                            $display ("Command results can be corrupted");
                        end
                        if (Instruct == WREN)
                            Status_reg[1] = 1'b1;
                        else if (Instruct == WRDI)
                            Status_reg[1] = 1'b0;
                        else if (Instruct == WRSR && Status_reg[1] &&
                                (~(Status_reg[7] == 1'b1 && WNeg_ipd == 1'b0)))
                        begin
                            WSTART = 1'b1;
                            WSTART <= #1 1'b0;
                            Status_reg[0] = 1'b1;
                        end
                        else if (Instruct == PP && Status_reg[1] == 1'b1)
                        begin
                            sector = Address / 20'h10000;
                            if (Sec_Prot[sector] == 1'b0)
                            begin
                                PSTART = 1'b1;
                                PSTART <= #1 1'b0;
                                Status_reg[0] = 1'b1;
                                Addr = Address;
                                SA = sector;
                                wr_cnt = Byte_number;
                                for (i=0;i<=wr_cnt;i=i+1)
                                begin
                                    if (Viol!=1'b0)
                                        WData[i] = -1;
                                    else
                                        WData[i] = WByte[i];
                                end
                            end
                        end
                        else if (Instruct == SE && Status_reg[1] == 1'b1)
                        begin
                            sector = Address / 20'h10000;
                            if (Sec_Prot[sector] == 1'b0)
                            begin
                                ESTART = 1'b1;
                                ESTART <= #1 1'b0;
                                Status_reg[0] = 1'b1;
                                Addr = Address;
                            end
                        end
                        else if (Instruct == BE && Status_reg[1] == 1'b1 &&
                              Status_reg[2] == 1'b0 && Status_reg[3] == 1'b0 &&
                              Status_reg[4] == 1'b0)
                        begin
                            ESTART = 1'b1;
                            ESTART <= #1 1'b0;
                            Status_reg[0] = 1'b1;
                        end
                    end

            end

            DP_DOWN :
            begin
                if (~write)
                begin
                    if (Instruct == RES_READ_ES)
                        RES_in = 1'b1;
                end
            end

        endcase
    end

    always @(RES_out)
    begin : DPDOWN1
        if (RES_out)
        begin
            RES_in = 1'b0;
        end
    end

    always @(current_state or EDONE)
    begin: ERASE1
    integer i;
        case (current_state)
            SECTOR_ER :
            begin
                ADDRHILO_SEC(AddrLo, AddrHi, Addr);
                for (i=AddrLo;i<=AddrHi;i=i+1)
                begin
                    Mem[i] = -1;
                end

                if (EDONE)
                begin
                    Status_reg[0] = 1'b0;
                    Status_reg[1] = 1'b0;
                    for (i=AddrLo;i<=AddrHi;i=i+1)
                    begin
                        Mem[i] = MaxData;
                    end
                end
            end

            BULK_ER :
            begin
                for (i=0;i<=AddrRANGE;i=i+1)
                begin
                    Mem[i] = -1;
                end

                if (EDONE)
                begin
                    Status_reg[0] = 1'b0;
                    Status_reg[1] = 1'b0;
                    for (i=0;i<=AddrRANGE;i=i+1)
                    begin
                        Mem[i] = MaxData;
                    end
                end
            end
        endcase
    end

    always @(current_state or WDONE or PoweredUp)
    begin: WRSR1
        if (PoweredUp ==1'b1)
        if (current_state == WRITE_SR)
        begin
            if (WDONE)
            begin
                Status_reg[0] = 1'b0;//WIP
                Status_reg[1] = 1'b0;//WEL
                Status_reg[7] = Status_reg_in[0];//MSB first, SRWD
                Status_reg[4] = Status_reg_in[3];//MSB first, BP2
                Status_reg[3] = Status_reg_in[4];//MSB first, BP1
                Status_reg[2] = Status_reg_in[5];//MSB first, BP0
                case (Status_reg[4:2])
                    3'b000 :
                    begin
                        Sec_Prot = 16'h0000;
                    end
                    3'b001 :
                    begin
                        Sec_Prot = 16'h8000;
                    end
                    3'b010 :
                    begin
                        Sec_Prot = 16'hC000;
                    end
                    3'b011 :
                    begin
                        Sec_Prot = 16'hF000;
                    end
                    3'b100 :
                    begin
                        Sec_Prot = 16'hFF00;
                    end
                    3'b101 :
                    begin
                        Sec_Prot = 16'hFFFF;
                    end
                    3'b110 :
                    begin
                        Sec_Prot = 16'hFFFF;
                    end
                    3'b111 :
                    begin
                        Sec_Prot = 16'hFFFF;
                    end
                endcase
            end
        end
    end

    always @(current_state or PDONE or PoweredUp)
    begin: PPPG1
    integer i, j;
        if (PoweredUp ==1'b1)
        if (current_state == PAGE_PG)
        begin
            ADDRHILO_PG(AddrLo, AddrHi, Addr);
            if ((Addr + wr_cnt) > AddrHi)
                wr_cnt = AddrHi - Addr;
            for (i=Addr;i<=Addr+wr_cnt;i=i+1)
            begin
                new_int = WData[i-Addr];
                old_int = Mem[i];
                if (new_int > -1)
                begin
                    new_bit = new_int;
                    if (old_int > -1)
                    begin
                        old_bit = old_int;
                        for(j=0;j<=7;j=j+1)
                            if (~old_bit[j])
                                new_bit[j]=1'b0;
                        new_int=new_bit;
                    end

                    WData[i-Addr]= new_int;
                end
                else
                begin
                    WData[i-Addr] = -1;
                end
            end

            for (i=Addr;i<=Addr+wr_cnt;i=i+1)
            begin
                Mem[i] = -1;
            end

            if (PDONE)
            begin
                Status_reg[0] = 1'b0;//wip
                Status_reg[1] = 1'b0;// wel
                for (i=Addr;i<=Addr+wr_cnt;i=i+1)
                begin
                    Mem[i] = WData[i-Addr];
                end
            end
        end
    end

// Output Control
    always @(CSNeg_ipd or HOLDNeg_ipd or SCK_ipd)
    begin
        //Output Disable Control
        if (CSNeg_ipd )
            SO_zd = 1'bZ;
     end

     always @(SO_zd or HOLDNeg_ipd)
     begin
         if (HOLDNeg_ipd == 1)
             SO_z = SO_zd;
         else
             SO_z = 1'bZ;
     end
// Procedure ADDRHILO_SEC
 task ADDRHILO_SEC;
 inout  AddrLOW;
 inout  AddrHIGH;
 input   Addr;
 integer AddrLOW;
 integer AddrHIGH;
 integer Addr;
 integer sector;
 begin

    sector = Addr / (SecSize + 1);//20'h10000;
    AddrLOW = sector * (SecSize + 1);//20'h10000;
    AddrHIGH = sector * (SecSize + 1)+ 16'hFFFF;//20'h10000 + 16'hFFFF;

 end
 endtask

// Procedure ADDRHILO_PG
 task ADDRHILO_PG;
 inout  AddrLOW;
 inout  AddrHIGH;
 input   Addr;
 integer AddrLOW;
 integer AddrHIGH;
 integer Addr;
 integer page;
 begin

    page = Addr / 16'h100;
    AddrLOW = page * 16'h100;
    AddrHIGH = page * 16'h100 + 8'hFF;

 end
 endtask

endmodule
