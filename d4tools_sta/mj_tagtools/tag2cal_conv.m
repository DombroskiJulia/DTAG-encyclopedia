function     tag2cal_conv(tag)
%
%     [A M p t vb condv mb pb] = tag2cal(s,tagrun,[p])
%     Correct accelerometer, magnetometer, temperature and 
%     pressure time series for offset and scale.
%       s is the raw sensor matrix from wavread()
%       tagrun is the name of the deployment e.g., 'sw03_156a'
%       scal is the calibrated sensor matrix with columns:
%          scal = [A M d t vb cond mb pb]
%       where:
%       A is the corrected accelerometer signals, A=[ax,ay,az],
%            The units are g.
%       M is the corrected magnetometer signals, M=[mx,my,mz],
%            The units are uTesla.
%       d is the corrected pressure signal in m water depth.
%       t is the corrected temperature signal in Celcius.
%       vb is the battery voltage signal in Volts
%       condv is the conductivity signal in mhos.
%       mb is the magnetometer bridge voltage offset from the 20C
%            value in Volts
%       pb is the pressure bridge voltage offset from the 20C
%            value in Volts
%
%     Output sampling rate is the same as the input sampling rate.
%
%     DTAG V2 Script Set
%     mark johnson, WHOI
%     Last modified May 2004

ORIENT = 0 ;        % default orientation

% latest (August 2005) pressure calibrations
% 207:   [1311.6 1180.7]  [36 1312.2 1179.5]       (2004)
% 210:   [1109.6 897.3]   [-38.5 1092.9 901.7]     (2005)
% 211:   [1317.5 1082.1]  [-59.6 1280.3 1083]      (2005)
% 212:   [1312.1 1066.5]  [-62.1 1276.4 1067.7]    (2005)
% 214:   [1383.2 1151.7]  [-56.1 1345.4 1152.2]    (2005)

switch tag,
   case 'sw03_162a'
      % id = 204, 96kHz sampling
      id = 4 ;
      a_cal = [-6.623 1.721;
              7.077 -1.573;
              -6.694 1.566] ;
      ax_cal = [0.079e-3 -4.6e-3 1 0 0.035;
              0.128e-3 0 0 1 0;
              0.009e-3 -1.2e-3 0 0 1] ;
      m_cal = [2.171 0.516;      % SIGNS SUSPECT !!!
               -2.055 0.209;
               2.121 0.365] ;
      mx_cal = [0.07 1 0 0;
               0.154 -0.016 1 0.006;
               0.434 0 0 1] ;
      B = 49 ;            % field strength in uT
      k = 1:1.83e4 ;

   case 'sw03_165a'
      % id = 204, 96kHz sampling
      id = 4 ;
      a_cal = [-6.623 1.721;
              -7.077 -(-1.573+0.015);
              6.694 -1.566] ;
      ax_cal = [0.079e-3 -4.6e-3 1 0 0.035;
              -0.128e-3 -0.6e-3 0 1 0;
              -0.009e-3 1.2e-3 0 0 1] ;
      m_cal = [-2.171 -0.496;       % signs correct for upside-down tag
               -2.055 0.228;
               2.121 0.363] ;
      mx_cal = [0.04e-3 -0.07 1 0 0;
               -0.024e-3 0.154 0.016 1 0.006;
               -0.01e-3 0.434 0 0 1] ;
      B = 49 ;            % field strength in uT
      k = 45175:294e3 ;
      
   case 'sw03_165b'
      % id = 202, 96kHz sampling
      id = 2 ;
      %p_cal = [1316.9 1204.9 0.00385 -0.0079] ;
      p_cal = [1326.3 1216.2-6.4 0] ;
      a_cal = [-6.663 1.571;
              -7.077 1.633;
              7.062 -1.442] ;
      ax_cal = [-1.3e-5 -4.6e-3 1 0 -0.035;
              -1.77e-4 0 0 1 0;
              4.5e-5 1.2e-3 0 0 1] ;
      m_cal = [-2.05 0.353;     % SIGNS SUSPECT !!!
               -1.933 0.431;
               1.975 -0.450] ;
      mx_cal = [-0.19e-3 0.73 1 0 0;
               -0.0e-3 -0.12 0 1 -0.023;
               -0.007e-3 -0.34 0 0 1] ;
      B = 49 ;            % field strength in uT


   case 'sw03_167a'
      % id = 202, 96kHz sampling
      id = 2 ;
      p_cal = [1326.3 1212.5 0] ;
      a_cal = [-6.623 1.721+0.12;
              -7.077 1.573-0.086;
              -6.694 1.566+0.222] ;
      ax_cal = [-0.01e-3 -6e-3 1 0 0;
              -0.12e-3 0 0 1 0;
              0.1e-3 -3e-3 0 0 1] ;
      m_cal = [-2.171 -0.516+0.449;     % SIGNS SUSPECT !!!
               -2.055 0.209-0.63;
               -2.121 -0.365+0.569] ;
      mx_cal = [0.035 1 0 0;
               -0.594 0 1 0;
               0.078 0 0 1] ;
      B = 49*0.969 ;            % field strength in uT
      k = 1:4.71e4 ;

  case 'sw03_247a'
 	  % id = 202, 96kHz sampling
      id = 2 ;
      p_cal = [1345 1237 0] ;
      a_cal = [-7.082-.3895 1.96+.0272-.1009+.1194+.1103;
               6.993+.3846 -1.436+.0187-.0089+.0089-.0780;
              -5.678-.3123  1.645-.1075-.0431+.0458+.0847] ;
      ax_cal = [0 0.006 1 0 0;
                0.0002 0.0004 0 1 0;
                0 0.0023 0 0 1] ;
      m_cal = [-2.05 -0.104+.3278-.3191;
                1.92 -0.365+1.1319-.4226;
               -1.98 -0.141-.0263+.2952] ;
      mx_cal = [-0.0783 1 0 0;
                -0.1035 0 1 0;
                0.0720 0 0 1] ;
      B = 49;            % field strength in uT
      
  case 'sw03_249a'
      % id = 205, 96kHz sampling
      id = 5 ;
     
      a_cal = [-6.849 1.632+.0085+.0516-.0505;
               7.018 -1.613-.0163+.0478-.0213;
              -7.107  1.415+.0022-.0472+.0181] ;
      ax_cal = [0 -0.0025 1 0 0;
                0.0002 -0.0011 0 1 0;
                0 0.0009 0 0 1] ;
      m_cal = [-2.05 0.0027-.4443+.45;
                1.945 .369-.9263+.2026;
               -1.98 -0.43+.6696+.1641] ;
      mx_cal = [0.1117 1 0 0;
                0.0502 0 1 0;
                0.0405 0 0 1] ;
      B = 49;            % field strength in uT
      
 case 'sw03_249b'
 	  % id = 204, 96kHz sampling
       id = 4 ; 
       a_cal = [-6.74 1.76-.0355;
                 7.15 -1.6-.0323;
                -6.74  1.56+.0154] ;
      ax_cal = [.0002 0 1 0 0;
                .0002 0 0 1 0;
                 0 0 0 0 1] ;
      m_cal = [-2.05 -.603+.00355;
               1.98 .304-.605;
               -2.04 -.406+.02486] ;
      mx_cal = [ 0 1 0 0;
                 0 0 1 0 ;
                 0 0 0 1] ;
      B = 49 ;            % field strength in uT
      %k = 1:2.008e5 ;
      
 case 'sw03_249c'
      % id = 204, 96kHz sampling
      id = 4 ;
      a_cal = [-6.74 1.76+.0041+.0187;
              7.15 -1.6+.0059+.0300;
              -6.74  1.56-.0139+.0317] ;
      ax_cal = [.0001 0 1 0 0;
                .0001 0 0 1 0;
                 0 0 0 0 1] ;
      m_cal = [-2.05 -.603+.013;
               1.98 -.304+.037;
               -2.04 -.406+.08] ;
      mx_cal = [ -.173 1 0 0;
                -.449 0 1 0 ;
                -.742 0 0 1] ;
      B = 49 ;            % field strength in uT
      k = 1:2.008e5 ;
      
 case 'sw03_251a'
      % id = 202, 96kHz sampling
      id = 2 ;
      p_cal = [1316.9 1204.9 0.00385 -0.0079] ;
      a_cal = [-7.116 1.971;
               6.918 -1.377;
               -6.735 1.761] ;
      ax_cal = [6e-5 0 1 0 0;
                1.5e-4 0 0 1 0;
                5.9e-5 0 0 0 1] ;
      m_cal = [-2.206 -0.115;
                2.064 0.438;
               -2.116 0.170] ;
      mx_cal = [-0.252 1 0 0;
                0.786 0 1 0;
                0.132 0 0 1] ;
      B = 45;            % field strength in uT
      k = 1:136500 ;      

   case 'sw03_253a'
      % id = 205, 96kHz sampling
      id = 5 ;
     
      a_cal = [-6.849 1.632+.0099+.0049+.0257-.0296;
               7.018 -1.613+.0024+.0115+.0158-.0220;
              -7.107  1.415-.0138-.0008-.0232+.0268] ;
      ax_cal = [0 -0.0015 1 0 0;
                0.0002 -0.0011 0 1 0;
                0 0.0013 0 0 1] ;
      m_cal = [-2.05 -.021-.1326+.1579;
                1.945 .339-.6799-.0049;
               -1.98 -0.417+.7639+.0437] ;
      mx_cal = [0.0402 1 0 0;
                -0.0012 0 1 0;
                0.0111 0 0 1] ;
      B = 49;            % field strength in uT

   case 'sw03_253b'
      % id = 204, 96kHz sampling
      id = 4 ;
      a_cal = [-6.74 1.76+.0136+.0618-.0677;
              7.15 -1.6+.0121+.0513-.0488;
              -6.74  1.56+.0004+.0670-.0635] ;
      ax_cal = [0.0001 -.0034 1 0 0;
                0.0001 -.0024 0 1 0;
                 0 -.0032 0 0 1] ;
      m_cal = [-2.05 .496-1.13+.0161;
               1.98 .314-.553-.0637;
               -2.04 .171-.456-.0379] ;
      mx_cal = [ .0046 1 0 0;
                -.017 0 1 0 ;
                -.01 0 0 1] ;
      B = 49 ;            % field strength in uT
      %k = 1:2.008e5 ;

case 'sw03_253c'
          % id = 207, 96kHz sampling
      id = 7 ;
      a_cal = [-6.973 1.533+.0341;
                7.100 -1.749+.0303;
              -6.926 1.693+.0155] ;
      ax_cal = [0.0001 0 1 0 0;
                0.0002 0 0 1 0;
                0.0002 0 0 0 1] ;
      m_cal = [-2.086 0.041+.0569-.1435;
               1.962 .0732-.2414+.0660;
               -1.978 -0.28+.6482-.0975] ;
      mx_cal = [-.0367 1 0 0;
                .0168 0 1 0;
                -.0249 0 0 1] ;
      B = 49 ;            % field strength in uT

case 'pw03_306b'
      % id = 204, 96kHz sampling
      % Acal is based on finding a subset of the rough-calibrated A data with low temporal variation
      %    dA = diff(A)*fs ;
      %    vA = sqrt(dA.^2*[1;1;1]) ;
      %    k = find(vA<0.2) ;
      % result gives std of A(k,:) of 0.029 with |A|=1
      id = 4 ;
      p_cal = [1339.9 1214.64 0.0055 -0.042] ;
      a_cal = [-6.795 1.799;
              7.261 -1.629;
              -6.868 1.564] ;
      ax_cal = [0.11e-3 0 1 0 0;
              0.17e-3 0 0 1 0;
              -0.011e-3 0 0 0 1] ;
      m_cal = [-2.171 -(0.516+0.087);  % mcal not calculated as data set has bad M
               2.055 -(0.209+0.084);   % (no set/reset after demag)
               -2.121 -(0.365-0.027)] ;
      mx_cal = [-(0.07+0.33) 1 0 0;
               -0.154 -0.016 1 0.006;
              -(0.434+0.4) 0 0 1] ;
      B = 49 ;            % field strength in uT
      k = 1:166800 ;

case 'pw03_307a'
      % id = 204, 96kHz sampling
      % Acal is based on finding a subset of the rough-calibrated A data with low temporal variation
      %    dA = diff(A)*fs ;
      %    vA = sqrt(dA.^2*[1;1;1]) ;
      %    k = find(vA<0.2) ;
      % result gives std of A(k,:) of 0.029 with |A|=1
      id = 4 ;
      p_cal = [1339.9 1214.64 0.0055 -0.042] ;
      a_cal = [-6.795 1.779;
              7.261 -1.645;
              -6.868 1.60] ;
      ax_cal = [0.154e-3 0 1 0 0;
              0.193e-3 0 0 1 0;
              0 0 0 0 1] ;
      m_cal = [-2.171 -0.584;
               2.055 -0.307;   
               -2.121 -0.338] ;
      mx_cal = [-0.40 1 0 0;
               -0.154 -0.016 1 0.006;
              -0.834 0 0 1] ;
      B = 49 ;            % field strength scalar
      k = 1:100400 ;

 case 'sw03_163a'    % KB
      % id = 204, 96kHz sampling
      id = 4 ;

      % old version by MJ
      %a_cal = [-6.623 1.721;
      %        7.077 -1.573;
      %        -6.694 1.566] ;
      %ax_cal = [0.079e-3 -4.6e-3 1 0 0.035;
      %        0.128e-3 0 0 1 0;
      %        0.009e-3 -1.2e-3 0 0 1] ;
      %m_cal = [2.171 0.516;
      %         -2.055 0.209;
      %         2.121 0.365] ;
      %mx_cal = [0.07 1 0 0;
      %         0.154 -0.016 1 0.006;
      %         0.434 0 0 1] ;

      % revised by KB
      p_cal = [1325.4 1199.9+1.4 0] ;
      a_cal = [-6.74 1.76-.0159;
              7.15 -1.60+.033;
              -6.74 1.56+.0004] ;
      ax_cal = [0 0 1 0 0;
              0 0 0 1 0;
              0 0 0 0 1] ;
      m_cal = [-2.177 0.460-1.017;
               2.041 0.240-.474;
               -2.101 0.399-.838] ;
      mx_cal = [4e-4 1 0 0;
               0 0 1 0;
               1.1e-3 0 0 1] ;
      B = 49 ;            % field strength in uT
     
 case 'sw03_164a'    % KB
      % id = 202, 96kHz sampling
      id = 2 ;

      % old version by MJ
      %p_cal = [1326.3 1216.2-6.4 0] ;
      %a_cal = [-6.623 1.721;
      %        7.077 -1.573;
      %        -6.694 1.566] ;
      %ax_cal = [0.079e-3 -4.6e-3 1 0 0.035;
      %        0.128e-3 0 0 1 0;
      %        0.009e-3 -1.2e-3 0 0 1] ;
      %m_cal = [2.171 0.516;
      %         -2.055 0.209;
      %         2.121 0.365] ;
      %mx_cal = [0.07 1 0 0;
      %         0.154 -0.016 1 0.006;
      %         0.434 0 0 1] ;

      % revised by KB
      p_cal = [1316.9 1207.8-3.9 0] ;
      a_cal = [-7.082 1.969+.03;
              6.993 -1.436+.0285;
              -5.678*(1+.15) 1.645+.1744 ] ;
      ax_cal = [0 0 1 0 0;
              0 0 0 1 0;
              0 0 0 0 1] ;
      m_cal = [-2.114 0.095-.2154;
               1.991 -0.401+.7119;
               -2.049 -.224+.4724] ;
      mx_cal = [4e-4 1 0 0;
               2e-3 0 1 0;
               -3e-3 0 0 1] ;
      B = 49 ;            % field strength in uT
      k = 1:1.96e5 ;

 case 'sw03_201b'    % KB
        % id = 207, 96kHz sampling
      id = 7 ;
      p_cal = [1314.6 1182.7+6 0] ;
      a_cal = [-6.973*(1+.01) 1.533+.0474;
                7.100*(1+.01) -1.749+.1591;
              -6.926*(1) 1.693+.0824] ;
      ax_cal = [0 0 1 0 0;
                0 0 0 1 0;
                0 0 0 0 1] ;
      m_cal = [-1.973 -0.059+.0565;
               1.861 -.097+.0062;
               -1.88 .254-.0083] ;
      mx_cal = [0 1 0 0;
                1.5e-3 0 1 0;
                7e-4 0 0 1] ;
      B = 53 ;           % field strength in uT (Atlantic coast)

 case 'sw03_202a'    % KB
      % id = 202, 96kHz sampling
      id = 2 ;
      p_cal = [1316.9 1207.8-3 0] ;
      a_cal = [-7.10 1.97+.0259;
              6.980 -1.42+.0312;
              -5.678*(1+.2) 1.645+.1126] ;
      ax_cal = [0 0 1 0 0;
              0 0 0 1 0;
              0 0 0 0 1] ;
      m_cal = [-1.954 0.062-.1239;
               1.841 -0.413+.7569;
               -1.894 -0.175+.3331] ;
      mx_cal = [0 1 0 0;
               0 0 1 0;
               0 0 0 1] ;
      B = 53 ;  
      k = 1:1.5e4 ;
        
 case 'sw03_206a'    % KB
      % id = 202, 96kHz sampling
      id = 2 ;
      p_cal = [1316.9 1207.8-3 0] ;
      a_cal = [-7.10 1.97+.055;
              6.980 -1.42+.0918;
              -5.678*(1+.2) 1.645+.1835] ;
      ax_cal = [0 0 1 0 0;
              0 0 0 1 0;
              0 0 0 0 1] ;
      m_cal = [-1.954 0.0849-.1509;
               1.841 -0.421+.7291;
               -1.894 -.188+.3288] ;
      mx_cal = [0 1 0 0;
               0 0 1 0;
               0 0 0 1] ;
      B = 53 ;  %field strength in uT
      k = 1:6.8e4 ;
      
 case 'sw03_247a'    % KB
 	  % id = 202, 96kHz sampling
      id = 2 ;
      p_cal = [1316.9 1207.8-3 0] ;
      a_cal = [-7.082*(1+.0029) 1.969+.0325;
               6.993*(1) -1.436+.1044;
              -5.678*(1+.1271) 1.645+.0258] ;
      ax_cal = [0 0 1 0 0;
                0 0 0 1 0;
                0 0 0 0 1] ;
      m_cal = [-2.11*(1+.0137) -0.107+.0476-.0495;
                1.99*(1-.0049) -0.379+.8009-.0512;
               -2.05*(1+.0102-.0022) -0.146+.2279+.0577] ;
      mx_cal = [-.0029 1 0 0;
                -.0029 0 1 0;
                .0036 0 0 1] ;
      B = 49;            % field strength in uT
      k=1:6.73e4 ;
 
 case 'sw03_249a'    % KB
      % id = 205, 96kHz sampling
      id = 5 ;
      p_cal = [1318.9 1208.3-4 0] ;
      a_cal = [-6.849 1.632+.0085+.0516-.0505;
               7.018 -1.613-.0163+.0478-.0213;
              -7.107  1.415+.0022-.0472+.0181] ;
      ax_cal = [0 -0.0025 1 0 0;
                0.0002 -0.0011 0 1 0;
                0 0.0009 0 0 1] ;
      m_cal = [-2.05 0.0027-.4443+.45;
                1.945 .369-.9263+.2026;
               -1.98 -0.43+.6696+.1641] ;
      mx_cal = [0.1117 1 0 0;
                0.0502 0 1 0;
                0.0405 0 0 1] ;
      B = 49;            % field strength in uT
      
 case 'sw03_249b'    % KB
 	  % id = 204, 96kHz sampling
       id = 4 ; 
       p_cal = [1325.4 1199.9 0] ;
       a_cal = [-6.74 1.76-.0355;
                 7.15 -1.60-.0323;
                -6.74  1.56+.0154] ;
      ax_cal = [0.0002 0 1 0 0;
                0.0002 0 0 1 0;
                 0 0 0 0 1] ;
      m_cal = [-2.18 -.64-.0119;
               2.04 .313-.6197;
               -2.10 -.418+.0272] ;
      mx_cal = [ 0 1 0 0;
                 0 0 1 0 ;
                 0 0 0 1] ;
      B = 49 ;            % field strength in uT
      k = 1:8.68e3 ;
      
 case 'sw03_249c'    % KB
      % id = 204, 96kHz sampling
      id = 4 ;
      p_cal = [1325.4 1199.9+2 0] ;
      a_cal = [-6.74 1.76+.0041+.0187;
              7.15 -1.6+.0059+.0300;
              -6.74  1.56-.0139+.0317] ;
      ax_cal = [.0001 0 1 0 0;
                .0001 0 0 1 0;
                 0 0 0 0 1] ;
      m_cal = [-2.18 -.64;
               2.04 .313-.616;
               -2.10 -.418+.0246] ;
      mx_cal = [ 0 1 0 0;
                 0 0 1 0 ;
                 0 0 0 1] ;
      B = 49 ;            % field strength in uT
      k = 1:2.024e5 ;
      
 case 'sw03_251a'    % KB
      % id = 202, 96kHz sampling
      id = 2 ;
      p_cal = [1316.9 1207.8-3 0] ;
      a_cal = [-7.116 1.971;
               6.981 -1.337;
              -6.735 1.761] ;
      ax_cal = [6e-5 0 1 0 0;
                1.5e-4 0 0 1 0;
                5.9e-5 0 0 0 1] ;
      m_cal = [-2.206 -.115;
                2.064 .438;
               -2.116 .170] ;
      mx_cal = [-.252 1 0 0;
                0.786 0 1 0;
                .132 0 0 1] ;
      B = 45;            % field strength in uT
      k=1:136500 ;
      
 case 'sw03_253a'    % KB
      % id = 205, 96kHz sampling
      id = 5 ;
      p_cal = [1318.9 1208.3-4 0] ;
      a_cal = [-6.849*(1+.0029) 1.632+.0097;
               7.018 -1.613+.1283;
              -7.107*(1-.0066) 1.415-.0357] ;
      ax_cal = [0 0 1 0 0;
                0 0 0 1 0;
                0 0 0 0 1] ;
       m_cal = [-2.10*(1+.0215) .022-.2386;
                1.991*(1+.0037) .347-.609;
               -2.034 .429-.126] ;
      mx_cal = [0 1 0 0;
                0 0 1 0;
                0 0 0 1] ;
      B = 49;            % field strength in uT
      k=1:1.1e5 ;
      
 case 'sw03_253b'    % KB
      % id = 204, 96kHz sampling
      id = 4 ;
      p_cal = [1325.4 1199.9+2 0] ;
      a_cal = [-6.74 1.76+.0136+.0618-.0677;
              7.15 -1.6+.0121+.0513-.0488;
              -6.74  1.56+.0004+.0670-.0635] ;
      ax_cal = [0.0001 -.0034 1 0 0;
                0.0001 -.0024 0 1 0;
                 0 -.0032 0 0 1] ;
      m_cal = [-2.18 -.527-.1293;
               2.04 .324-.635;
               -2.10 -.375+.0397] ;
      mx_cal = [ 0 1 0 0;
                 0 0 1 0 ;
                 0 0 0 1] ;
      B = 49 ;            % field strength in uT
      k = 1:2.008e5 ;
      
 case 'sw03_253c'    % KB
          % id = 207, 96kHz sampling
      id = 7 ;
      p_cal = [1314.6 1182.7+6 0] ;
      a_cal = [-6.973 1.533+.0341;
                7.100 -1.749+.0303;
              -6.926 1.693+.0155] ;
      ax_cal = [0.0001 0 1 0 0;
                0.0002 0 0 1 0;
                0.0002 0 0 0 1] ;
      m_cal = [-2.13 -0.042-.011;
               2.01 .075-.1728;
               -2.03 0.288-.0176] ;
      mx_cal = [0 1 0 0;
                0 0 1 0;
                0 0 0 1] ;
      B = 49 ;            % field strength in uT
      k=1:9.03e4 ;

   case 'zc03_260a'                 % A not great, M good
      % id = 204, 96kHz sampling
      id = 4 ;
      p_cal = [1342.3 1216.7 1] ;
      a_cal = [-6.623 1.721-0.05;
              7.077 -1.546-0.074;
              -6.694 1.566-0.067] ;
      ax_cal = [0.16e-3 0 1 0 0;
              0.14e-3 0 0 1 0;
              0.03e-3 0 0 0 1] ;
      m_cal = [-2.171*1.007 -0.516-0.084-0.052;
               2.055 -0.209-0.067;
               -2.121 -0.365+0.011-0.066] ;
      mx_cal = [19e-6 -0.03 1 0 0;
               12e-6 -0.26 -0.016 1 0.002;
               54e-6 -0.18 -0.016 0 1] ;
      B = 49 ;            % field strength in uT
      k = 1:50000 ;

   case 'zc03_263a'
      % id = 204, 96kHz sampling
      id = 4 ;
      p_cal = [1342.3 1216.7 1] ;
      a_cal = [-6.623 1.721+0.02;
              7.077 -(1.573-0.027);
              -6.694 1.566+0.004] ;
      ax_cal = [0.14e-3 0 1 0 0;
              0.14e-3 0 0 1 0;
              -0.014e-3 0 0 0 1] ;
      m_cal = [-2.171 -(0.516+0.087);
               2.055 -(0.209+0.084);
               -2.121 -(0.365-0.027)] ;
      mx_cal = [-(0.07+0.33) 1 0 0;
               -0.154 -0.016 1 0.006;
              -(0.434+0.4) 0 0 1] ;
      B = 49 ;            % field strength in uT

   case 'md03_284a'
      % id = 207, 96kHz sampling
      id = 7 ;
      p_cal = [1311.6 1185.9 0 0.17] ;    % was [1342.3 1214 -3] which is not correct (10/25/05)
      a_cal = [-7.121 1.595;
              7.221 -1.78;
              -7.081 1.759] ;
      ax_cal = [0.16e-3 0 1 0 0;
              0.21e-3 0 0 1 0;
              0.2e-3 0 0 0 1] ;
      m_cal = [-2.63 -0.05;
               2.44 -0.17;
               -2.5 0.33] ;
      mx_cal = [-0.23 1 0 0;
               0.34 0 1 0;
               -0.04 0 0 1] ;
      B = 42 ;            % field strength in uT

   case 'md03_298a'
      % id = 204, 96kHz sampling
      id = 4 ;
      p_cal = [1342.3 1216.2 1] ;
      a_cal = [-6.623 1.764;
              7.077 -1.577;
              -6.694 1.518] ;
      ax_cal = [0.15e-3 0 1 0 0;
              0.13e-3 0 0 1 0;
              0.02e-3 0 0 0 1] ;
      m_cal = [-2.171 -0.571;
               2.055 -0.295;
               -2.121 -0.357] ;
      mx_cal = [-0.37 1 0 0;
               -0.221 -0.016 1 0.006;
              -0.7 0 0 1] ;
      B = 50 ;            % field strength in uT
      k = 1:5.4e4 ;
      
case 'zc04_160a'
          % id = 207, 96kHz sampling
      id = 7 ;
      p_cal = [1311.6 1188.8 -1.5] ;
      a_cal = 1.017*[-6.973 1.547;
                7.100 -1.717;
              -6.926 1.681] ;
      ax_cal = [0.14e-3 0 1 0 0;
                0.2e-3 0 0 1 0;
                0.2e-3 0 0 0 1] ;
      m_cal = [-2.086 -0.016-0.036;
               1.962 -0.187+0.025;
               -1.978*1.002 0.302-0.041] ;
      mx_cal = [0.021e-3 -0.154+0.322 1 0 -0.012;
                -0.011e-3 0.602-0.165 -0.014 1 -0.003;
                0.014e-3 -0.195+0.236 -0.003 0 1] ;
      B = 49 ;            % field strength in uT
      k=1:1e5 ;

  case 'zc04_161a'          % M ok, A good upto sample 3.8e4, tag loose thereafter
      % id = 203, 96kHz sampling
      id = 3 ;
      p_cal = [1304.7 1235.6-20.5 0] ;
      a_cal = [-6.805 1.597;
                6.986 -1.562;
              -6.805 1.772] ;
      ax_cal = [0.083e-3 0 1 0 0;
                0.34e-3 0 0 1 0;
                0.05e-3 0 0 0 1] ;
      m_cal = [-2.088 -0.496+0.037;
               1.924 -0.067-0.024;
               -2.079 -0.369-0.031] ;
      mx_cal = [0.006e-3 0.12+0.02 1 -0.009 0;
                0.012e-3 -0.48+0.1 -0.027 1 0;
                0.021e-3 -0.67+0.116 -0.020 0.024 1] ;
      B = 49 ;            % field strength in uT
      %k=1:1.6e5 ;
      k=1:3.8e4 ;       % only first long dive is good - A is noisy for rest of record
      
 case 'zc04_161b'
      % id = 204, 96kHz sampling
      id = 4 ;
      p_cal = [1342.3 1216.4 0 -0.1] ;    % was [1325.4 1202 0] but scalar not correct (10/25/05)
      a_cal = [-6.74 1.765;
              7.15 -1.613;
              -6.74 1.551] ;
      ax_cal = [0.13e-3 0 1 0 0;
                0.17e-3 0 0 1 0;
                0.03e-3 0 0 0 1] ;
      m_cal = [-2.177 -0.608;
               2.041 -0.307;
               -2.101 -0.376] ;
      mx_cal = [0.019e-3 -0.22 1 -0.013 -0.015;
                0.017e-3 -0.34 0 1 0 ;
                0.054e-3 -0.29 0 0 1] ;
      B = 49 ;            % field strength in uT
      %k = 1:2.024e5 ;

      
 case 'zc04_175a'
      % id = 212, 192kHz, stereo sampling
      id = 12 ;
      p_cal = [1312.1 1051.4 0 -0.33] ;    % was 1374 - fixed 10/26/05
      a_cal = [-6.953 1.744+0.004;
              7.004 -1.602+0.03;
              -7.024 1.726+0.024] ;
      ax_cal = [-0.04e-3 0 1 0 0;
                0.25e-3 0 0 1 0;
                -0.16e-3 0 0 0 1] ;
      m_cal = [-2.229 -0.081-0.077-0.056;
               2.168 0.290-0.041+0.004;
               -2.258 0.213+0.022+0.0203] ;
      mx_cal = [0.0156 1.9e-6 0.567-0.051 1 0 -0.008;
                -0.002 -4.3e-6 0.311-0.094 -0.07 1 -0.016 ;
                -0.006 2.5e-6 -0.131+0.026 -0.043 0 1] ;
      B = 46 ;            % field strength in uT
      %k = 1:2.024e5 ;

      
 case 'zc04_179a'
      % id = 212, 192kHz, stereo sampling
      id = 12 ;
      p_cal = [1312.1 1051.5 0 -0.3] ;    % was 1374 - fixed 10/26/05
      a_cal = [-6.953 1.748;
              7.004 -1.572;
              -7.024 1.75] ;
      ax_cal = [-0.04e-3 0 1 0 0;
                0.25e-3 0 0 1 0;
                -0.16e-3 0 0 0 1] ;
      m_cal = [-2.229 -0.155;
               2.168 0.264;
               -2.258 0.266] ;
      mx_cal = [-1.54e-3 1.9e-6 0.450 1 0 -0.008;
                -1.82e-3 -4.3e-6 0.190 -0.07 1 -0.016 ;
                -6.45e-3 2.5e-6 -0.062 -0.043 0 1] ;
      M_tcal = [0.164 0.104 0.057 0.06] ;
      B = 44.45 ;            % scalar to achieve local field strength in uT
      k = 2001:6.8e4 ;

 case 'md04_287a'
      % id = 212, 192kHz, stereo sampling
      id = 12 ;
      p_cal = [1312.1 1050.5 0 -0.3] ;       % was 1374 - fixed 10/26/05
      a_cal = [-6.953 1.748-0.029;
              7.004 -1.572+0.004;
              -7.024 1.75] ;
      ax_cal = [-0.04e-3 0 1 0 0;
                0.26e-3 0 0 1 0;
                -0.13e-3 0 0 0 1] ;
      m_cal = [-2.229 -0.155+0.029;
               2.168 0.264+0.011;
               -2.258 0.266+0.031] ;
      mx_cal = [-1.54e-3 1.9e-6 0.450 1 0 -0.008;
                -1.82e-3 -4.3e-6 0.190 -0.07 1 -0.016 ;
                -6.45e-3 2.5e-6 -0.062 -0.043 0 1] ;
      M_tcal = [0.164 0.104 0.057 0.06] ;
      B = 44.45 ;            % scalar to achieve local field strength in uT
      %k = 2001:6.8e4 ;

   case 'mm04_224a'
      % id = 208, 96kHz sampling
      id = 8 ;
      p_cal = [1342.3 1223.3 1] ;
      a_cal = [-6.623*0.93*1.1 1.764-0.05;
              7.077*0.87*1.1 -1.577+0.13;
              -6.694*1.1 1.518+0.44] ;
      ax_cal = [0 0 1 0 0;
              0 0 0 1 0;
              0 0 0 0 1] ;
      m_cal = [-2.171*0.97 -0.571+.4508;
               2.055*0.96 -0.295+.4595+.0016;
               -2.121 -0.357+.756-.019-.004] ;
      mx_cal = [2.263 1 0 -.021;
               -0.411 -.047 1 0;
              2.691 0 -.01 1] ;
      B = 50 ;            % reference field strength in uT
      k = 5001:45700 ;
      
   case 'zc05_167a'
      % id = 214, 192kHz, stereo sampling
      id = 14 ;
		p_cal = [1383.2 1151.7-5.8 0 -0.2] ;
      a_cal = [-6.801 1.68;
              7.048 -1.524;
              -6.902 1.79] ;
      ax_cal = [-0.17e-3 0 1 0 0;
                0.4e-3 0 0 1 0;
                0.26e-3 0 0 0 1] ;
      m_cal = [-1.975 0.176+0.011;
               1.946 -0.456+0.002;
               -2.189 -0.124+0.073] ;
      mx_cal = [0 -0.021e-3 0 1 -0.005 -0.0;
                0 0 0.0 -0.06 1 -0.0 ;
                0 -0.01e-3 -0.0 -0.04 0.015 1] ;
      %M_tcal = [0.164 0.104 0.057 0.06] ;
      B = 44.45 ;            % scalar to achieve local field strength in uT
      k = 10500:1.3e5 ;

 case 'zc05_170a'
      % id = 212, 192kHz, stereo sampling
      id = 12 ;
      p_cal = [1312.1 1050.5 0 -0.3] ;
      a_cal = [-6.953 1.748-0.074;
              7.004 -1.572+0.032;
              -7.024 1.75] ;
      ax_cal = [0.16e-3 0 1 0 0;
                0.26e-3 0 0 1 0;
                -0.16e-3 0 0 0 1] ;
      m_cal = [-2.229 -0.155-0.012;
               2.168 0.264-0.035;
               -2.258 0.266-0.013] ;
      mx_cal = [-1.54e-3 1.9e-6 0.430 1 0 -0.008;
                -1.82e-3 -6e-6 0.30 -0.07 1 -0.016 ;
                -6.45e-3 2.5e-6 -0.092 -0.043 0 1] ;
      M_tcal = [0.164 0.104 0.057 0.06] ;
      B = 44.45 ;            % scalar to achieve local field strength in uT
      k = 13000:2.1e5 ;
      
   case 'sw05_199a'
      % id = 210, 96kHz, stereo sampling
      id = 10 ;
		p_cal = [1109.6 897-1.7 0 -0.26] ;
      a_cal = [-6.878 2.024+0.038;
                7.106*0.99 -1.692+0.023;
               -7.131*0.97 2.003-0.035] ;
      ax_cal = [0.19e-3 0 1 0 0;
                0.17e-3 0 0 1 0;
                0.13e-3 0 -0.065 0 1] ;
      m_cal = [-103.95 -2.89-5.10+0.2-0.09;
                101.00 2.94-4.03+0.05;
               -111.16*0.96 -4.36+3.39-0.36+1.9] ;
      mx_cal = [0 17.9 1 -0.058 0;
                0 3.3 -0.058 1 0 ;
                0 -47.9 0 0 1] ;
      B = 1 ;     % scalar to achieve local field strength in uT
      k = 1000:4e5 ;
      
   case 'sw05_199b'
      % id = 212, 96kHz, stereo sampling
      id = 12 ;
      p_cal = [1312.1 1066.5-8.6 -0.39] ;            % nominal pressure cal (tag 212)
      a_cal = [-6.953 1.748-0.074+0.01;    % std of 
              7.004 -1.572+0.032-0.03;
              -7.024 1.75+0.038] ;
      ax_cal = [0.12e-3 0 1 0 0;
                0.29e-3 0 0 1 0;
                -0.16e-3 0 0 0 1] ;
      m_cal = [-2.229 -0.155-0.012+0.08;   % std of uT
               2.168 0.264-0.035+0.066;
               -2.258 0.266-0.013+0.082] ;
      mx_cal = [-1.54e-3 1.9e-6 0.32 1 0 -0.008;
                -1.82e-3 1e-6 0.36 -0.07 1 -0.016 ;
                -6.45e-3 -7.5e-6 -0.22 -0.043 0 1] ;
      B = 44.45 ;     % scalar to achieve local field strength in uT
      k = 1000:1.6e5 ;
      
   case 'md05_285a'
      % id = 214, 192kHz, stereo sampling
      id = 14 ;
		p_cal = [1383.2 1151.7-5.8 0 -0.23] ;
      a_cal = [-6.801 1.68+0.014;
              7.048 -1.524-0.076;
              -6.902 1.79-0.029] ;
      ax_cal = [-0.17e-3 0 1 0 0;
                0.4e-3 0 0 1 0;
                0.26e-3 0 0 0 1] ;
      m_cal = [-1.975 0.176-0.039;
               1.946 -0.456+0.020;
               -2.189 -0.124+0.011] ;
      mx_cal = [0 -0.035e-3 0 1 -0.005 -0.0;
                0 0 0.0 -0.06 1 -0.0 ;
                0 -0.01e-3 -0.0 -0.04 0.015 1] ;
      B = 44.45 ;            % scalar to achieve local field strength in uT
      k = 5000:2.5e5 ;
      
   case 'md05_294a'
      % id = 214, 192kHz, stereo sampling
      id = 14 ;
      p_cal = [1383.2 1151.7-5.9 0 -0.23] ;
      p2_cal = [-56.1 1345.4 1152.2+0.7 -0.23] ;
      a_cal = [-6.801 1.68+0.014;       % std of 0.07g for A due to tag placement?
              7.048 -1.524-0.076;
              -6.902 1.79-0.029] ;
      ax_cal = [-0.17e-3 0 1 0 0;
                0.4e-3 0 0 1 0;
                0.26e-3 0 0 0 1] ;
      m_cal = [-1.975 0.126;            % std of 0.19uT
               1.946 -0.453;
               -2.189 -0.126] ;
      mx_cal = [0 -0.02e-3 0 1 -0.005 -0.0;
                0 0 0.0 -0.06 1 -0.0 ;
                0 -0.028e-3 -0.0 -0.04 0.015 1] ;
      B = 44.45 ;            % scalar to achieve local field strength in uT
      k = 1000:52.8e3 ;

 case 'md05_294b'
      % id = 212, 192kHz, stereo sampling
      id = 12 ;
      p_cal = [1312.1 1050.5 0 -0.3] ;
      p2_cal = [-62.1 1276.4 1067.7-6 -0.3] ;
      a_cal = [-6.953 1.748-0.074-0.012;    % std of 0.031
              7.004 -1.572+0.032-0.066;
              -7.024 1.75+0.051] ;
      ax_cal = [0.14e-3 0 1 0 0;
                0.30e-3 0 0 1 0;
                -0.21e-3 0 0 0 1] ;
      m_cal = [-2.229 -0.155-0.012+0.076;   % std of 0.20uT
               2.168 0.264-0.035+0.073;
               -2.258 0.266-0.013+0.096] ;
      mx_cal = [-1.54e-3 1.9e-6 0.430 1 0 -0.008;
                -1.82e-3 1e-6 0.30 -0.07 1 -0.016 ;
                -6.45e-3 -7.5e-6 -0.092 -0.043 0 1] ;
      M_tcal = [0.164 0.104 0.057 0.06] ;
      B = 44.45 ;            % scalar to achieve local field strength in uT
      k = 1000:139e3 ;

 otherwise
      fprintf('Unknown experiment\n') ;
      return ;
end

if ~exist('p_cal','var')
   switch id
      case 4
         p_cal = [1342.3 1216.2 1] ;
      case 5
         p_cal = [1332.1 1217.9 1.8] ;
      case 7
         p_cal = [1342.3 1214 -3] ;
      otherwise
         fprintf('Pressure cal unknown for tag %d\n', id) ;
         return ;
   end
end

% retrieve other tag-dependent calibration parameters
switch id,
   case 2
      t_cal = [125 75] ;            % degrees C
      vb_cal = [5 5] ;              % volts
      pb_cal = [2.5 2.5-3.36] ;     % volts offset wrt 20C
      mb_cal = [2.5 2.5-2.83] ;     % volts offset wrt 20C
   case 3
      t_cal = [125 75] ;            % degrees C
      vb_cal = [5 5] ;              % volts
      pb_cal = [2.5 2.5-3.36] ;     % volts offset wrt 20C
      mb_cal = [2.5 2.5-2.83] ;     % volts offset wrt 20C
   case 4
      t_cal = [125 75] ;            % degrees C
      vb_cal = [5 5] ;              % volts
      pb_cal = [2.5 2.5-2.89] ;     % volts offset wrt 20C
      mb_cal = [2.5 2.5-2.68] ;     % volts offset wrt 20C
   case 5
      t_cal = [125 75] ;            % degrees C
      vb_cal = [5 5] ;              % volts
      pb_cal = [2.5 2.5-3.35] ;     % volts offset wrt 20C
      mb_cal = [2.5 2.5-2.81] ;     % volts offset wrt 20C    
  case 7
      t_cal = [125 75] ;            % degrees C
      vb_cal = [5 5] ;              % volts
      pb_cal = [2.5 2.5-2.89] ;     % volts offset wrt 20C
      mb_cal = [2.5 2.5-2.68] ;     % volts offset wrt 20C
  case 8
      t_cal = [125 75] ;            % degrees C
      vb_cal = [5 5] ;              % volts
      pb_cal = [2.5 2.5-2.89] ;     % volts offset wrt 20C
      mb_cal = [2.5 2.5-2.68] ;     % volts offset wrt 20C
  case 10
      t_cal = [125 75] ;            % degrees C
      vb_cal = [5 5] ;              % volts
      pb_cal = [2.5 2.5-2.89] ;     % volts offset wrt 20C
      mb_cal = [2.5 2.5-2.68] ;     % volts offset wrt 20C
  case 12
      t_cal = [125 75] ;            % degrees C
      vb_cal = [5 5] ;              % volts
      pb_cal = [2.5 2.5-2.89] ;     % volts offset wrt 20C
      mb_cal = [2.5 2.5-2.68] ;     % volts offset wrt 20C
  case 14
      t_cal = [125 75] ;            % degrees C
      vb_cal = [5 5] ;              % volts
      pb_cal = [2.5 2.5-2.89] ;     % volts offset wrt 20C
      mb_cal = [2.5 2.5-2.68] ;     % volts offset wrt 20C
   otherwise
      fprintf('Unknown tag %d\n', id) ;
      return ;
end

load tag2cues
C = getfield(CUES,tag);

savecal(tag,1,'TAGID',C.id,'TAGON',C.on,'AUTHOR','tag2cal_conv','CUETAB',C.N) ;

CAL.TAG = C.id ;
if exist('p2_cal','var'),        % new square-law calibration
   CAL.PCAL = p2_cal(1:3) ;
   CAL.PTC = p2_cal(4) ;
else
   CAL.PCAL = p_cal(1:2) ;
   if length(p_cal)>2,
      CAL.PTC = p_cal(end) ;
   end
end
CAL.TCAL = t_cal ;
CAL.VB = vb_cal ;
CAL.MB = mb_cal ;
CAL.PB = pb_cal ;
CAL.TREF = 20 ;
CAL.MBTREF = 20 ;
CAL.PBTREF = 20 ;
CAL.Pr0 = 130 ;
CAL.Pi0 = 0.88e-3 ;
CAL.ACAL = a_cal ;
CAL.MCAL = m_cal ;
CAL.APC = ax_cal(:,1)' ;
CAL.ATC = ax_cal(:,2)' ;
CAL.AXC = eye(3) ;
CAL.MMBC = [0 0 0] ;
CAL.MPC = [0 0 0] ;
CAL.MXC = eye(3) ;
savecal(tag,1,'CAL',CAL) ;
