function logbeta = solubility(t,s,gas)
% lnbeta = solubility(t,s,gas)
% input: t  temperature (K)
%        s  slinity     (g/kg)
%        gas string with 'He','Ne','Ar','O2','N2','Kr','Xe','CH4',
%                         'CO2','N2O','Rn','SF6','DMS','CFC12','CFC11',
%                         'CH3Br','CCl4'
% output: logbeta the natural logarithm of the dimensionless Busen
% coefficient
% the solubility is expressed in mol/L/atm 
ig = containers.Map({'He', 'Ne', 'Ar', 'O2', 'N2', 'Kr', 'Xe', 'CH4', 'CO2', 'N2O', ...
    'Rn', 'SF6', 'DMS', 'CFC12', 'CFC11', 'CH3Br', 'CCl4'}, 1:17)

% Table 2 of Wanninkhof (2014) Limnology and Oceanography: Methods
% Relationship between wind speed and gas exchange over the ocean revisited
%    A1          A2           A3        B1           B2        B3
Table2 = ...
   [-34.6261 ,  43.0285 ,   14.1391 ,  -0.042340  ,  0.022624 , -0.0033120  ; ...
    -39.1971 ,  51.8013 ,   15.7699 ,  -0.124695  ,  0.078374 , -0.0127972  ; ...
    -55.6578 ,  82.0262 ,   22.5929 ,  -0.036267  ,  0.016241 , -0.0020114  ; ...
    -58.3877 ,  85.8079 ,   23.8439 ,  -0.034892  ,  0.015568 , -0.0019387  ; ...
    -59.6274 ,  85.7661 ,   24.3696 ,  -0.051580  ,  0.026329 , -0.0037252  ; ...
    -57.2596 ,  87.4242 ,   22.9332 ,  -0.008723  , -0.002793 ,  0.0012398  ; ...
    -7.48588 ,  5.08763 ,    4.22078,  -0.00817791, -0.0120172,  0          ; ...
    -68.8862 , 101.4956 ,   28.7314 ,  -0.076146  ,  0.043970 , -0.006872   ; ...
    -58.0931 ,  90.5069 ,   22.2940 ,   0.027766  , -0.025888 ,  0.0050578  ; ...  
    -62.7062 ,  97.3066 ,   24.1406 ,  -0.058420  ,  0.033193 , -0.0051313  ; ...
    -76.14   , 120.36   ,   31.26   ,  -0.2631    ,  0.1673   , -0.0270     ; ...     
    -96.5975 , 139.883  ,   37.8193 ,   0.0310693 , -0.0356385,  0.00743254 ; ... 
    -12.64   ,  35.47   ,   0       ,   0         ,  0        ,  0          ; ...        
    -122.3246, 182.5306 ,   50.5898 ,  -0.145633  ,  0.092509 , -0.0156627  ; ...   
    -134.1536, 203.2156 ,   56.2320 ,  -0.144449  ,  0.092952 , -0.0159977  ; ...   
    -171.2   , 254.3    ,   77.04   ,  -0.1828    ,  0.03142  ,  0          ; ...     
    -166.321 , 252.542  ,   71.5211 ,  -0.41216   ,  0.273093 , -0.0460112  ];

A1 = Table2(ig(gas),1); 
A2 = Table2(ig(gas),2); 
A3 = Table2(ig(gas),3)
B1 = Table2(ig(gas),4); 
B2 = Table2(ig(gas),5);
B3 = Table2(ig(gas),6);
t100 = t/100
logbeta = [t100(:).^[0:-1:-1], log(t100), s(:).*(t100(:).^[0:2])]*[A1;A2;A3;B1;B2;B3];

 
 
 
 
 
 
 

















 


 
 

