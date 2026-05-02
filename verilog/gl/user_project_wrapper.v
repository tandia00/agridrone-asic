// This is the unpowered netlist.
module user_project_wrapper (user_clock2,
    vccd2,
    vdda1,
    vdda2,
    vssa1,
    vssa2,
    vssd2,
    wb_clk_i,
    wb_rst_i,
    wbs_ack_o,
    wbs_cyc_i,
    wbs_stb_i,
    wbs_we_i,
    analog_io,
    io_in,
    io_oeb,
    io_out,
    la_data_in,
    la_data_out,
    la_oenb,
    user_irq,
    wbs_adr_i,
    wbs_dat_i,
    wbs_dat_o,
    wbs_sel_i);
 input user_clock2;
 inout vccd2;
 inout vdda1;
 inout vdda2;
 inout vssa1;
 inout vssa2;
 inout vssd2;
 input wb_clk_i;
 input wb_rst_i;
 output wbs_ack_o;
 input wbs_cyc_i;
 input wbs_stb_i;
 input wbs_we_i;
 inout [28:0] analog_io;
 input [37:0] io_in;
 output [37:0] io_oeb;
 output [37:0] io_out;
 input [127:0] la_data_in;
 output [127:0] la_data_out;
 input [127:0] la_oenb;
 output [2:0] user_irq;
 input [31:0] wbs_adr_i;
 input [31:0] wbs_dat_i;
 output [31:0] wbs_dat_o;
 input [3:0] wbs_sel_i;

 wire net1;
 wire net14;
 wire net15;
 wire net16;
 wire net17;
 wire net18;
 wire net19;
 wire net20;
 wire net21;
 wire net22;
 wire net23;
 wire net24;
 wire net25;
 wire net26;
 wire net27;
 wire net28;
 wire net29;
 wire net30;
 wire net31;
 wire net32;
 wire net33;
 wire net34;
 wire net35;
 wire net36;
 wire net37;
 wire net38;
 wire net39;
 wire net40;
 wire net41;
 wire net42;
 wire net43;
 wire net44;
 wire net45;
 wire net46;
 wire net47;
 wire net48;
 wire net49;
 wire net50;
 wire net59;
 wire spi_miso;
 wire net60;
 wire net61;
 wire spray_pwm;
 wire net62;
 wire kill_n;
 wire armed_led;
 wire wdog_trip_led;
 wire net63;
 wire net64;
 wire net65;
 wire net66;
 wire net67;
 wire net68;
 wire net69;
 wire net70;
 wire net71;
 wire net72;
 wire net73;
 wire net74;
 wire net75;
 wire net76;
 wire net77;
 wire net78;
 wire net79;
 wire net80;
 wire net81;
 wire net82;
 wire net83;
 wire net84;
 wire net85;
 wire net86;
 wire net87;
 wire net88;
 wire net89;
 wire net90;
 wire net91;
 wire net92;
 wire net93;
 wire net94;
 wire net95;
 wire net96;
 wire net97;
 wire net98;
 wire net99;
 wire net100;
 wire net101;
 wire net102;
 wire net103;
 wire net104;
 wire net105;
 wire net106;
 wire net107;
 wire net108;
 wire net109;
 wire net110;
 wire net111;
 wire net112;
 wire net113;
 wire net114;
 wire net115;
 wire net116;
 wire net117;
 wire net118;
 wire net119;
 wire net120;
 wire net121;
 wire net122;
 wire net123;
 wire net124;
 wire net125;
 wire net126;
 wire net127;
 wire net128;
 wire net129;
 wire net130;
 wire net131;
 wire net132;
 wire net133;
 wire net134;
 wire net135;
 wire net136;
 wire net137;
 wire net138;
 wire net139;
 wire net140;
 wire net141;
 wire net142;
 wire net143;
 wire net144;
 wire net145;
 wire net146;
 wire net147;
 wire net148;
 wire net149;
 wire net150;
 wire net151;
 wire net152;
 wire net153;
 wire net154;
 wire net155;
 wire net156;
 wire net157;
 wire net158;
 wire net159;
 wire net160;
 wire net161;
 wire net162;
 wire net163;
 wire net164;
 wire net165;
 wire net166;
 wire net167;
 wire net168;
 wire net169;
 wire net170;
 wire net171;
 wire net172;
 wire net173;
 wire net174;
 wire net175;
 wire net176;
 wire net177;
 wire net178;
 wire net179;
 wire net180;
 wire net181;
 wire net182;
 wire net183;
 wire net184;
 wire net185;
 wire net186;
 wire net187;
 wire net188;
 wire net189;
 wire net190;
 wire net191;
 wire net192;
 wire net193;
 wire net194;
 wire net195;
 wire net196;
 wire net197;
 wire net198;
 wire net199;
 wire net200;
 wire net201;
 wire net202;
 wire net203;
 wire net204;
 wire net205;
 wire net206;
 wire net207;
 wire net208;
 wire net209;
 wire net210;
 wire net211;
 wire net212;
 wire net213;
 wire net214;
 wire net215;
 wire net216;
 wire net217;
 wire net218;
 wire net219;
 wire net220;
 wire net221;
 wire net222;
 wire net223;
 wire net224;
 wire net225;
 wire net226;
 wire net227;
 wire net228;
 wire net229;
 wire net230;
 wire net231;
 wire net232;
 wire net233;
 wire net234;
 wire net235;
 wire net236;
 wire net237;
 wire net238;
 wire net239;
 wire net240;
 wire net241;
 wire net242;
 wire net243;
 wire net244;
 wire net245;
 wire net246;
 wire net247;
 wire net10;
 wire net11;
 wire net12;
 wire net13;
 wire net2;
 wire net3;
 wire net4;
 wire net5;
 wire net51;
 wire net52;
 wire net53;
 wire net54;
 wire net55;
 wire net56;
 wire net57;
 wire net58;
 wire net6;
 wire net7;
 wire net8;
 wire net9;
 wire rst_n;

 top agridrone_inst (.armed_led(net2),
    .clk(wb_clk_i),
    .flow_pulse(io_in[21]),
    .kill_n(net11),
    .rst_n(rst_n),
    .spi_cs_n(io_in[11]),
    .spi_miso(net12),
    .spi_mosi(io_in[9]),
    .spi_sclk(io_in[8]),
    .spray_pwm(net13),
    .wdog_trip_led(net52),
    .pwm_out({net10,
    net9,
    net8,
    net7,
    net6,
    net5,
    net4,
    net3}));
 sky130_fd_sc_hd__buf_12 fanout53 (.A(net55),
    .X(net53));
 sky130_fd_sc_hd__clkbuf_4 fanout54 (.A(net55),
    .X(net54));
 sky130_fd_sc_hd__buf_12 fanout55 (.A(net51),
    .X(net55));
 sky130_fd_sc_hd__buf_6 fanout56 (.A(net57),
    .X(net56));
 sky130_fd_sc_hd__buf_12 fanout57 (.A(net58),
    .X(net57));
 sky130_fd_sc_hd__buf_12 input1 (.A(wb_rst_i),
    .X(net51));
 sky130_fd_sc_hd__buf_4 output10 (.A(net10),
    .X(io_out[19]));
 sky130_fd_sc_hd__buf_4 output11 (.A(net11),
    .X(kill_n));
 sky130_fd_sc_hd__buf_4 output12 (.A(net12),
    .X(spi_miso));
 sky130_fd_sc_hd__buf_4 output13 (.A(net13),
    .X(spray_pwm));
 sky130_fd_sc_hd__buf_4 output14 (.A(net55),
    .X(net1));
 sky130_fd_sc_hd__buf_4 output15 (.A(net53),
    .X(net14));
 sky130_fd_sc_hd__buf_4 output16 (.A(net53),
    .X(net15));
 sky130_fd_sc_hd__buf_4 output17 (.A(net58),
    .X(net16));
 sky130_fd_sc_hd__buf_4 output18 (.A(net56),
    .X(net17));
 sky130_fd_sc_hd__buf_4 output19 (.A(net56),
    .X(net18));
 sky130_fd_sc_hd__buf_4 output2 (.A(net2),
    .X(armed_led));
 sky130_fd_sc_hd__buf_4 output20 (.A(net56),
    .X(net19));
 sky130_fd_sc_hd__buf_4 output21 (.A(net56),
    .X(net20));
 sky130_fd_sc_hd__buf_4 output22 (.A(net56),
    .X(net21));
 sky130_fd_sc_hd__buf_4 output23 (.A(net56),
    .X(net22));
 sky130_fd_sc_hd__buf_4 output24 (.A(net56),
    .X(net23));
 sky130_fd_sc_hd__buf_4 output25 (.A(net55),
    .X(net24));
 sky130_fd_sc_hd__buf_4 output26 (.A(net56),
    .X(net25));
 sky130_fd_sc_hd__buf_4 output27 (.A(net56),
    .X(net26));
 sky130_fd_sc_hd__buf_4 output28 (.A(net56),
    .X(net27));
 sky130_fd_sc_hd__buf_4 output29 (.A(net57),
    .X(net28));
 sky130_fd_sc_hd__buf_4 output3 (.A(net3),
    .X(io_out[12]));
 sky130_fd_sc_hd__buf_4 output30 (.A(net57),
    .X(net29));
 sky130_fd_sc_hd__buf_4 output31 (.A(net53),
    .X(net30));
 sky130_fd_sc_hd__buf_4 output32 (.A(net53),
    .X(net31));
 sky130_fd_sc_hd__buf_4 output33 (.A(net54),
    .X(net32));
 sky130_fd_sc_hd__buf_4 output34 (.A(net54),
    .X(net33));
 sky130_fd_sc_hd__buf_4 output35 (.A(net54),
    .X(net34));
 sky130_fd_sc_hd__buf_4 output36 (.A(net55),
    .X(net35));
 sky130_fd_sc_hd__buf_4 output37 (.A(net54),
    .X(net36));
 sky130_fd_sc_hd__buf_4 output38 (.A(net54),
    .X(net37));
 sky130_fd_sc_hd__buf_4 output39 (.A(net54),
    .X(net38));
 sky130_fd_sc_hd__buf_4 output4 (.A(net4),
    .X(io_out[13]));
 sky130_fd_sc_hd__buf_4 output40 (.A(net54),
    .X(net39));
 sky130_fd_sc_hd__buf_4 output41 (.A(net54),
    .X(net40));
 sky130_fd_sc_hd__buf_4 output42 (.A(net57),
    .X(net41));
 sky130_fd_sc_hd__buf_4 output43 (.A(net57),
    .X(net42));
 sky130_fd_sc_hd__buf_4 output44 (.A(net57),
    .X(net43));
 sky130_fd_sc_hd__buf_4 output45 (.A(net55),
    .X(net44));
 sky130_fd_sc_hd__buf_4 output46 (.A(net53),
    .X(net45));
 sky130_fd_sc_hd__buf_4 output47 (.A(net53),
    .X(net46));
 sky130_fd_sc_hd__buf_4 output48 (.A(net53),
    .X(net47));
 sky130_fd_sc_hd__buf_4 output49 (.A(net53),
    .X(net48));
 sky130_fd_sc_hd__buf_4 output5 (.A(net5),
    .X(io_out[14]));
 sky130_fd_sc_hd__buf_4 output50 (.A(net53),
    .X(net49));
 sky130_fd_sc_hd__buf_4 output51 (.A(net53),
    .X(net50));
 sky130_fd_sc_hd__buf_4 output52 (.A(net52),
    .X(wdog_trip_led));
 sky130_fd_sc_hd__buf_4 output6 (.A(net6),
    .X(io_out[15]));
 sky130_fd_sc_hd__buf_4 output7 (.A(net7),
    .X(io_out[16]));
 sky130_fd_sc_hd__buf_4 output8 (.A(net8),
    .X(io_out[17]));
 sky130_fd_sc_hd__buf_4 output9 (.A(net9),
    .X(io_out[18]));
 sky130_fd_sc_hd__inv_2 rst_inv_inst (.A(net51),
    .Y(rst_n));
 sky130_fd_sc_hd__conb_1 user_project_wrapper_100 (.LO(net100));
 sky130_fd_sc_hd__conb_1 user_project_wrapper_101 (.LO(net101));
 sky130_fd_sc_hd__conb_1 user_project_wrapper_102 (.LO(net102));
 sky130_fd_sc_hd__conb_1 user_project_wrapper_103 (.LO(net103));
 sky130_fd_sc_hd__conb_1 user_project_wrapper_104 (.LO(net104));
 sky130_fd_sc_hd__conb_1 user_project_wrapper_105 (.LO(net105));
 sky130_fd_sc_hd__conb_1 user_project_wrapper_106 (.LO(net106));
 sky130_fd_sc_hd__conb_1 user_project_wrapper_107 (.LO(net107));
 sky130_fd_sc_hd__conb_1 user_project_wrapper_108 (.LO(net108));
 sky130_fd_sc_hd__conb_1 user_project_wrapper_109 (.LO(net109));
 sky130_fd_sc_hd__conb_1 user_project_wrapper_110 (.LO(net110));
 sky130_fd_sc_hd__conb_1 user_project_wrapper_111 (.LO(net111));
 sky130_fd_sc_hd__conb_1 user_project_wrapper_112 (.LO(net112));
 sky130_fd_sc_hd__conb_1 user_project_wrapper_113 (.LO(net113));
 sky130_fd_sc_hd__conb_1 user_project_wrapper_114 (.LO(net114));
 sky130_fd_sc_hd__conb_1 user_project_wrapper_115 (.LO(net115));
 sky130_fd_sc_hd__conb_1 user_project_wrapper_116 (.LO(net116));
 sky130_fd_sc_hd__conb_1 user_project_wrapper_117 (.LO(net117));
 sky130_fd_sc_hd__conb_1 user_project_wrapper_118 (.LO(net118));
 sky130_fd_sc_hd__conb_1 user_project_wrapper_119 (.LO(net119));
 sky130_fd_sc_hd__conb_1 user_project_wrapper_120 (.LO(net120));
 sky130_fd_sc_hd__conb_1 user_project_wrapper_121 (.LO(net121));
 sky130_fd_sc_hd__conb_1 user_project_wrapper_122 (.LO(net122));
 sky130_fd_sc_hd__conb_1 user_project_wrapper_123 (.LO(net123));
 sky130_fd_sc_hd__conb_1 user_project_wrapper_124 (.LO(net124));
 sky130_fd_sc_hd__conb_1 user_project_wrapper_125 (.LO(net125));
 sky130_fd_sc_hd__conb_1 user_project_wrapper_126 (.LO(net126));
 sky130_fd_sc_hd__conb_1 user_project_wrapper_127 (.LO(net127));
 sky130_fd_sc_hd__conb_1 user_project_wrapper_128 (.LO(net128));
 sky130_fd_sc_hd__conb_1 user_project_wrapper_129 (.LO(net129));
 sky130_fd_sc_hd__conb_1 user_project_wrapper_130 (.LO(net130));
 sky130_fd_sc_hd__conb_1 user_project_wrapper_131 (.LO(net131));
 sky130_fd_sc_hd__conb_1 user_project_wrapper_132 (.LO(net132));
 sky130_fd_sc_hd__conb_1 user_project_wrapper_133 (.LO(net133));
 sky130_fd_sc_hd__conb_1 user_project_wrapper_134 (.LO(net134));
 sky130_fd_sc_hd__conb_1 user_project_wrapper_135 (.LO(net135));
 sky130_fd_sc_hd__conb_1 user_project_wrapper_136 (.LO(net136));
 sky130_fd_sc_hd__conb_1 user_project_wrapper_137 (.LO(net137));
 sky130_fd_sc_hd__conb_1 user_project_wrapper_138 (.LO(net138));
 sky130_fd_sc_hd__conb_1 user_project_wrapper_139 (.LO(net139));
 sky130_fd_sc_hd__conb_1 user_project_wrapper_140 (.LO(net140));
 sky130_fd_sc_hd__conb_1 user_project_wrapper_141 (.LO(net141));
 sky130_fd_sc_hd__conb_1 user_project_wrapper_142 (.LO(net142));
 sky130_fd_sc_hd__conb_1 user_project_wrapper_143 (.LO(net143));
 sky130_fd_sc_hd__conb_1 user_project_wrapper_144 (.LO(net144));
 sky130_fd_sc_hd__conb_1 user_project_wrapper_145 (.LO(net145));
 sky130_fd_sc_hd__conb_1 user_project_wrapper_146 (.LO(net146));
 sky130_fd_sc_hd__conb_1 user_project_wrapper_147 (.LO(net147));
 sky130_fd_sc_hd__conb_1 user_project_wrapper_148 (.LO(net148));
 sky130_fd_sc_hd__conb_1 user_project_wrapper_149 (.LO(net149));
 sky130_fd_sc_hd__conb_1 user_project_wrapper_150 (.LO(net150));
 sky130_fd_sc_hd__conb_1 user_project_wrapper_151 (.LO(net151));
 sky130_fd_sc_hd__conb_1 user_project_wrapper_152 (.LO(net152));
 sky130_fd_sc_hd__conb_1 user_project_wrapper_153 (.LO(net153));
 sky130_fd_sc_hd__conb_1 user_project_wrapper_154 (.LO(net154));
 sky130_fd_sc_hd__conb_1 user_project_wrapper_155 (.LO(net155));
 sky130_fd_sc_hd__conb_1 user_project_wrapper_156 (.LO(net156));
 sky130_fd_sc_hd__conb_1 user_project_wrapper_157 (.LO(net157));
 sky130_fd_sc_hd__conb_1 user_project_wrapper_158 (.LO(net158));
 sky130_fd_sc_hd__conb_1 user_project_wrapper_159 (.LO(net159));
 sky130_fd_sc_hd__conb_1 user_project_wrapper_160 (.LO(net160));
 sky130_fd_sc_hd__conb_1 user_project_wrapper_161 (.LO(net161));
 sky130_fd_sc_hd__conb_1 user_project_wrapper_162 (.LO(net162));
 sky130_fd_sc_hd__conb_1 user_project_wrapper_163 (.LO(net163));
 sky130_fd_sc_hd__conb_1 user_project_wrapper_164 (.LO(net164));
 sky130_fd_sc_hd__conb_1 user_project_wrapper_165 (.LO(net165));
 sky130_fd_sc_hd__conb_1 user_project_wrapper_166 (.LO(net166));
 sky130_fd_sc_hd__conb_1 user_project_wrapper_167 (.LO(net167));
 sky130_fd_sc_hd__conb_1 user_project_wrapper_168 (.LO(net168));
 sky130_fd_sc_hd__conb_1 user_project_wrapper_169 (.LO(net169));
 sky130_fd_sc_hd__conb_1 user_project_wrapper_170 (.LO(net170));
 sky130_fd_sc_hd__conb_1 user_project_wrapper_171 (.LO(net171));
 sky130_fd_sc_hd__conb_1 user_project_wrapper_172 (.LO(net172));
 sky130_fd_sc_hd__conb_1 user_project_wrapper_173 (.LO(net173));
 sky130_fd_sc_hd__conb_1 user_project_wrapper_174 (.LO(net174));
 sky130_fd_sc_hd__conb_1 user_project_wrapper_175 (.LO(net175));
 sky130_fd_sc_hd__conb_1 user_project_wrapper_176 (.LO(net176));
 sky130_fd_sc_hd__conb_1 user_project_wrapper_177 (.LO(net177));
 sky130_fd_sc_hd__conb_1 user_project_wrapper_178 (.LO(net178));
 sky130_fd_sc_hd__conb_1 user_project_wrapper_179 (.LO(net179));
 sky130_fd_sc_hd__conb_1 user_project_wrapper_180 (.LO(net180));
 sky130_fd_sc_hd__conb_1 user_project_wrapper_181 (.LO(net181));
 sky130_fd_sc_hd__conb_1 user_project_wrapper_182 (.LO(net182));
 sky130_fd_sc_hd__conb_1 user_project_wrapper_183 (.LO(net183));
 sky130_fd_sc_hd__conb_1 user_project_wrapper_184 (.LO(net184));
 sky130_fd_sc_hd__conb_1 user_project_wrapper_185 (.LO(net185));
 sky130_fd_sc_hd__conb_1 user_project_wrapper_186 (.LO(net186));
 sky130_fd_sc_hd__conb_1 user_project_wrapper_187 (.LO(net187));
 sky130_fd_sc_hd__conb_1 user_project_wrapper_188 (.LO(net188));
 sky130_fd_sc_hd__conb_1 user_project_wrapper_189 (.LO(net189));
 sky130_fd_sc_hd__conb_1 user_project_wrapper_190 (.LO(net190));
 sky130_fd_sc_hd__conb_1 user_project_wrapper_191 (.LO(net191));
 sky130_fd_sc_hd__conb_1 user_project_wrapper_192 (.LO(net192));
 sky130_fd_sc_hd__conb_1 user_project_wrapper_193 (.LO(net193));
 sky130_fd_sc_hd__conb_1 user_project_wrapper_194 (.LO(net194));
 sky130_fd_sc_hd__conb_1 user_project_wrapper_195 (.LO(net195));
 sky130_fd_sc_hd__conb_1 user_project_wrapper_196 (.LO(net196));
 sky130_fd_sc_hd__conb_1 user_project_wrapper_197 (.LO(net197));
 sky130_fd_sc_hd__conb_1 user_project_wrapper_198 (.LO(net198));
 sky130_fd_sc_hd__conb_1 user_project_wrapper_199 (.LO(net199));
 sky130_fd_sc_hd__conb_1 user_project_wrapper_200 (.LO(net200));
 sky130_fd_sc_hd__conb_1 user_project_wrapper_201 (.LO(net201));
 sky130_fd_sc_hd__conb_1 user_project_wrapper_202 (.LO(net202));
 sky130_fd_sc_hd__conb_1 user_project_wrapper_203 (.LO(net203));
 sky130_fd_sc_hd__conb_1 user_project_wrapper_204 (.LO(net204));
 sky130_fd_sc_hd__conb_1 user_project_wrapper_205 (.LO(net205));
 sky130_fd_sc_hd__conb_1 user_project_wrapper_206 (.LO(net206));
 sky130_fd_sc_hd__conb_1 user_project_wrapper_207 (.LO(net207));
 sky130_fd_sc_hd__conb_1 user_project_wrapper_208 (.LO(net208));
 sky130_fd_sc_hd__conb_1 user_project_wrapper_209 (.LO(net209));
 sky130_fd_sc_hd__conb_1 user_project_wrapper_210 (.LO(net210));
 sky130_fd_sc_hd__conb_1 user_project_wrapper_211 (.LO(net211));
 sky130_fd_sc_hd__conb_1 user_project_wrapper_212 (.LO(net212));
 sky130_fd_sc_hd__conb_1 user_project_wrapper_213 (.LO(net213));
 sky130_fd_sc_hd__conb_1 user_project_wrapper_214 (.LO(net214));
 sky130_fd_sc_hd__conb_1 user_project_wrapper_215 (.LO(net215));
 sky130_fd_sc_hd__conb_1 user_project_wrapper_216 (.LO(net216));
 sky130_fd_sc_hd__conb_1 user_project_wrapper_217 (.LO(net217));
 sky130_fd_sc_hd__conb_1 user_project_wrapper_218 (.LO(net218));
 sky130_fd_sc_hd__conb_1 user_project_wrapper_219 (.LO(net219));
 sky130_fd_sc_hd__conb_1 user_project_wrapper_220 (.LO(net220));
 sky130_fd_sc_hd__conb_1 user_project_wrapper_221 (.LO(net221));
 sky130_fd_sc_hd__conb_1 user_project_wrapper_222 (.LO(net222));
 sky130_fd_sc_hd__conb_1 user_project_wrapper_223 (.LO(net223));
 sky130_fd_sc_hd__conb_1 user_project_wrapper_224 (.LO(net224));
 sky130_fd_sc_hd__conb_1 user_project_wrapper_225 (.LO(net225));
 sky130_fd_sc_hd__conb_1 user_project_wrapper_226 (.LO(net226));
 sky130_fd_sc_hd__conb_1 user_project_wrapper_227 (.LO(net227));
 sky130_fd_sc_hd__conb_1 user_project_wrapper_228 (.LO(net228));
 sky130_fd_sc_hd__conb_1 user_project_wrapper_229 (.LO(net229));
 sky130_fd_sc_hd__conb_1 user_project_wrapper_230 (.LO(net230));
 sky130_fd_sc_hd__conb_1 user_project_wrapper_231 (.LO(net231));
 sky130_fd_sc_hd__conb_1 user_project_wrapper_232 (.LO(net232));
 sky130_fd_sc_hd__conb_1 user_project_wrapper_233 (.LO(net233));
 sky130_fd_sc_hd__conb_1 user_project_wrapper_234 (.LO(net234));
 sky130_fd_sc_hd__conb_1 user_project_wrapper_235 (.LO(net235));
 sky130_fd_sc_hd__conb_1 user_project_wrapper_236 (.LO(net236));
 sky130_fd_sc_hd__conb_1 user_project_wrapper_237 (.LO(net237));
 sky130_fd_sc_hd__conb_1 user_project_wrapper_238 (.LO(net238));
 sky130_fd_sc_hd__conb_1 user_project_wrapper_239 (.LO(net239));
 sky130_fd_sc_hd__conb_1 user_project_wrapper_240 (.LO(net240));
 sky130_fd_sc_hd__conb_1 user_project_wrapper_241 (.LO(net241));
 sky130_fd_sc_hd__conb_1 user_project_wrapper_242 (.LO(net242));
 sky130_fd_sc_hd__conb_1 user_project_wrapper_243 (.LO(net243));
 sky130_fd_sc_hd__conb_1 user_project_wrapper_244 (.LO(net244));
 sky130_fd_sc_hd__conb_1 user_project_wrapper_245 (.LO(net245));
 sky130_fd_sc_hd__conb_1 user_project_wrapper_246 (.LO(net246));
 sky130_fd_sc_hd__conb_1 user_project_wrapper_247 (.LO(net247));
 sky130_fd_sc_hd__conb_1 user_project_wrapper_59 (.LO(net59));
 sky130_fd_sc_hd__conb_1 user_project_wrapper_60 (.LO(net60));
 sky130_fd_sc_hd__conb_1 user_project_wrapper_61 (.LO(net61));
 sky130_fd_sc_hd__conb_1 user_project_wrapper_62 (.LO(net62));
 sky130_fd_sc_hd__conb_1 user_project_wrapper_63 (.LO(net63));
 sky130_fd_sc_hd__conb_1 user_project_wrapper_64 (.LO(net64));
 sky130_fd_sc_hd__conb_1 user_project_wrapper_65 (.LO(net65));
 sky130_fd_sc_hd__conb_1 user_project_wrapper_66 (.LO(net66));
 sky130_fd_sc_hd__conb_1 user_project_wrapper_67 (.LO(net67));
 sky130_fd_sc_hd__conb_1 user_project_wrapper_68 (.LO(net68));
 sky130_fd_sc_hd__conb_1 user_project_wrapper_69 (.LO(net69));
 sky130_fd_sc_hd__conb_1 user_project_wrapper_70 (.LO(net70));
 sky130_fd_sc_hd__conb_1 user_project_wrapper_71 (.LO(net71));
 sky130_fd_sc_hd__conb_1 user_project_wrapper_72 (.LO(net72));
 sky130_fd_sc_hd__conb_1 user_project_wrapper_73 (.LO(net73));
 sky130_fd_sc_hd__conb_1 user_project_wrapper_74 (.LO(net74));
 sky130_fd_sc_hd__conb_1 user_project_wrapper_75 (.LO(net75));
 sky130_fd_sc_hd__conb_1 user_project_wrapper_76 (.LO(net76));
 sky130_fd_sc_hd__conb_1 user_project_wrapper_77 (.LO(net77));
 sky130_fd_sc_hd__conb_1 user_project_wrapper_78 (.LO(net78));
 sky130_fd_sc_hd__conb_1 user_project_wrapper_79 (.LO(net79));
 sky130_fd_sc_hd__conb_1 user_project_wrapper_80 (.LO(net80));
 sky130_fd_sc_hd__conb_1 user_project_wrapper_81 (.LO(net81));
 sky130_fd_sc_hd__conb_1 user_project_wrapper_82 (.LO(net82));
 sky130_fd_sc_hd__conb_1 user_project_wrapper_83 (.LO(net83));
 sky130_fd_sc_hd__conb_1 user_project_wrapper_84 (.LO(net84));
 sky130_fd_sc_hd__conb_1 user_project_wrapper_85 (.LO(net85));
 sky130_fd_sc_hd__conb_1 user_project_wrapper_86 (.LO(net86));
 sky130_fd_sc_hd__conb_1 user_project_wrapper_87 (.LO(net87));
 sky130_fd_sc_hd__conb_1 user_project_wrapper_88 (.LO(net88));
 sky130_fd_sc_hd__conb_1 user_project_wrapper_89 (.LO(net89));
 sky130_fd_sc_hd__conb_1 user_project_wrapper_90 (.LO(net90));
 sky130_fd_sc_hd__conb_1 user_project_wrapper_91 (.LO(net91));
 sky130_fd_sc_hd__conb_1 user_project_wrapper_92 (.LO(net92));
 sky130_fd_sc_hd__conb_1 user_project_wrapper_93 (.LO(net93));
 sky130_fd_sc_hd__conb_1 user_project_wrapper_94 (.LO(net94));
 sky130_fd_sc_hd__conb_1 user_project_wrapper_95 (.LO(net95));
 sky130_fd_sc_hd__conb_1 user_project_wrapper_96 (.LO(net96));
 sky130_fd_sc_hd__conb_1 user_project_wrapper_97 (.LO(net97));
 sky130_fd_sc_hd__conb_1 user_project_wrapper_98 (.LO(net98));
 sky130_fd_sc_hd__conb_1 user_project_wrapper_99 (.LO(net99));
 sky130_fd_sc_hd__buf_12 wire58 (.A(net51),
    .X(net58));
 assign io_oeb[0] = net1;
 assign io_oeb[10] = net14;
 assign io_oeb[11] = net15;
 assign io_oeb[12] = net16;
 assign io_oeb[13] = net17;
 assign io_oeb[14] = net18;
 assign io_oeb[15] = net19;
 assign io_oeb[16] = net20;
 assign io_oeb[17] = net21;
 assign io_oeb[18] = net22;
 assign io_oeb[19] = net23;
 assign io_oeb[1] = net24;
 assign io_oeb[20] = net25;
 assign io_oeb[21] = net26;
 assign io_oeb[22] = net27;
 assign io_oeb[23] = net28;
 assign io_oeb[24] = net29;
 assign io_oeb[25] = net30;
 assign io_oeb[26] = net31;
 assign io_oeb[27] = net32;
 assign io_oeb[28] = net33;
 assign io_oeb[29] = net34;
 assign io_oeb[2] = net35;
 assign io_oeb[30] = net36;
 assign io_oeb[31] = net37;
 assign io_oeb[32] = net38;
 assign io_oeb[33] = net39;
 assign io_oeb[34] = net40;
 assign io_oeb[35] = net41;
 assign io_oeb[36] = net42;
 assign io_oeb[37] = net43;
 assign io_oeb[3] = net44;
 assign io_oeb[4] = net45;
 assign io_oeb[5] = net46;
 assign io_oeb[6] = net47;
 assign io_oeb[7] = net48;
 assign io_oeb[8] = net49;
 assign io_oeb[9] = net50;
 assign io_out[0] = net59;
 assign io_out[10] = spi_miso;
 assign io_out[11] = net60;
 assign io_out[1] = net61;
 assign io_out[20] = spray_pwm;
 assign io_out[21] = net62;
 assign io_out[22] = kill_n;
 assign io_out[23] = armed_led;
 assign io_out[24] = wdog_trip_led;
 assign io_out[25] = net63;
 assign io_out[26] = net64;
 assign io_out[27] = net65;
 assign io_out[28] = net66;
 assign io_out[29] = net67;
 assign io_out[2] = net68;
 assign io_out[30] = net69;
 assign io_out[31] = net70;
 assign io_out[32] = net71;
 assign io_out[33] = net72;
 assign io_out[34] = net73;
 assign io_out[35] = net74;
 assign io_out[36] = net75;
 assign io_out[37] = net76;
 assign io_out[3] = net77;
 assign io_out[4] = net78;
 assign io_out[5] = net79;
 assign io_out[6] = net80;
 assign io_out[7] = net81;
 assign io_out[8] = net82;
 assign io_out[9] = net83;
 assign la_data_out[0] = net84;
 assign la_data_out[100] = net85;
 assign la_data_out[101] = net86;
 assign la_data_out[102] = net87;
 assign la_data_out[103] = net88;
 assign la_data_out[104] = net89;
 assign la_data_out[105] = net90;
 assign la_data_out[106] = net91;
 assign la_data_out[107] = net92;
 assign la_data_out[108] = net93;
 assign la_data_out[109] = net94;
 assign la_data_out[10] = net95;
 assign la_data_out[110] = net96;
 assign la_data_out[111] = net97;
 assign la_data_out[112] = net98;
 assign la_data_out[113] = net99;
 assign la_data_out[114] = net100;
 assign la_data_out[115] = net101;
 assign la_data_out[116] = net102;
 assign la_data_out[117] = net103;
 assign la_data_out[118] = net104;
 assign la_data_out[119] = net105;
 assign la_data_out[11] = net106;
 assign la_data_out[120] = net107;
 assign la_data_out[121] = net108;
 assign la_data_out[122] = net109;
 assign la_data_out[123] = net110;
 assign la_data_out[124] = net111;
 assign la_data_out[125] = net112;
 assign la_data_out[126] = net113;
 assign la_data_out[127] = net114;
 assign la_data_out[12] = net115;
 assign la_data_out[13] = net116;
 assign la_data_out[14] = net117;
 assign la_data_out[15] = net118;
 assign la_data_out[16] = net119;
 assign la_data_out[17] = net120;
 assign la_data_out[18] = net121;
 assign la_data_out[19] = net122;
 assign la_data_out[1] = net123;
 assign la_data_out[20] = net124;
 assign la_data_out[21] = net125;
 assign la_data_out[22] = net126;
 assign la_data_out[23] = net127;
 assign la_data_out[24] = net128;
 assign la_data_out[25] = net129;
 assign la_data_out[26] = net130;
 assign la_data_out[27] = net131;
 assign la_data_out[28] = net132;
 assign la_data_out[29] = net133;
 assign la_data_out[2] = net134;
 assign la_data_out[30] = net135;
 assign la_data_out[31] = net136;
 assign la_data_out[32] = net137;
 assign la_data_out[33] = net138;
 assign la_data_out[34] = net139;
 assign la_data_out[35] = net140;
 assign la_data_out[36] = net141;
 assign la_data_out[37] = net142;
 assign la_data_out[38] = net143;
 assign la_data_out[39] = net144;
 assign la_data_out[3] = net145;
 assign la_data_out[40] = net146;
 assign la_data_out[41] = net147;
 assign la_data_out[42] = net148;
 assign la_data_out[43] = net149;
 assign la_data_out[44] = net150;
 assign la_data_out[45] = net151;
 assign la_data_out[46] = net152;
 assign la_data_out[47] = net153;
 assign la_data_out[48] = net154;
 assign la_data_out[49] = net155;
 assign la_data_out[4] = net156;
 assign la_data_out[50] = net157;
 assign la_data_out[51] = net158;
 assign la_data_out[52] = net159;
 assign la_data_out[53] = net160;
 assign la_data_out[54] = net161;
 assign la_data_out[55] = net162;
 assign la_data_out[56] = net163;
 assign la_data_out[57] = net164;
 assign la_data_out[58] = net165;
 assign la_data_out[59] = net166;
 assign la_data_out[5] = net167;
 assign la_data_out[60] = net168;
 assign la_data_out[61] = net169;
 assign la_data_out[62] = net170;
 assign la_data_out[63] = net171;
 assign la_data_out[64] = net172;
 assign la_data_out[65] = net173;
 assign la_data_out[66] = net174;
 assign la_data_out[67] = net175;
 assign la_data_out[68] = net176;
 assign la_data_out[69] = net177;
 assign la_data_out[6] = net178;
 assign la_data_out[70] = net179;
 assign la_data_out[71] = net180;
 assign la_data_out[72] = net181;
 assign la_data_out[73] = net182;
 assign la_data_out[74] = net183;
 assign la_data_out[75] = net184;
 assign la_data_out[76] = net185;
 assign la_data_out[77] = net186;
 assign la_data_out[78] = net187;
 assign la_data_out[79] = net188;
 assign la_data_out[7] = net189;
 assign la_data_out[80] = net190;
 assign la_data_out[81] = net191;
 assign la_data_out[82] = net192;
 assign la_data_out[83] = net193;
 assign la_data_out[84] = net194;
 assign la_data_out[85] = net195;
 assign la_data_out[86] = net196;
 assign la_data_out[87] = net197;
 assign la_data_out[88] = net198;
 assign la_data_out[89] = net199;
 assign la_data_out[8] = net200;
 assign la_data_out[90] = net201;
 assign la_data_out[91] = net202;
 assign la_data_out[92] = net203;
 assign la_data_out[93] = net204;
 assign la_data_out[94] = net205;
 assign la_data_out[95] = net206;
 assign la_data_out[96] = net207;
 assign la_data_out[97] = net208;
 assign la_data_out[98] = net209;
 assign la_data_out[99] = net210;
 assign la_data_out[9] = net211;
 assign user_irq[0] = net212;
 assign user_irq[1] = net213;
 assign user_irq[2] = net214;
 assign wbs_ack_o = net215;
 assign wbs_dat_o[0] = net216;
 assign wbs_dat_o[10] = net217;
 assign wbs_dat_o[11] = net218;
 assign wbs_dat_o[12] = net219;
 assign wbs_dat_o[13] = net220;
 assign wbs_dat_o[14] = net221;
 assign wbs_dat_o[15] = net222;
 assign wbs_dat_o[16] = net223;
 assign wbs_dat_o[17] = net224;
 assign wbs_dat_o[18] = net225;
 assign wbs_dat_o[19] = net226;
 assign wbs_dat_o[1] = net227;
 assign wbs_dat_o[20] = net228;
 assign wbs_dat_o[21] = net229;
 assign wbs_dat_o[22] = net230;
 assign wbs_dat_o[23] = net231;
 assign wbs_dat_o[24] = net232;
 assign wbs_dat_o[25] = net233;
 assign wbs_dat_o[26] = net234;
 assign wbs_dat_o[27] = net235;
 assign wbs_dat_o[28] = net236;
 assign wbs_dat_o[29] = net237;
 assign wbs_dat_o[2] = net238;
 assign wbs_dat_o[30] = net239;
 assign wbs_dat_o[31] = net240;
 assign wbs_dat_o[3] = net241;
 assign wbs_dat_o[4] = net242;
 assign wbs_dat_o[5] = net243;
 assign wbs_dat_o[6] = net244;
 assign wbs_dat_o[7] = net245;
 assign wbs_dat_o[8] = net246;
 assign wbs_dat_o[9] = net247;
endmodule

