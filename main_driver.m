clc; clear all; close all
addpath('/DFS-L/DATA/primeau/weilewang/my_func/')
addpath('/DFS-L/DATA/primeau/weilewang/DATA/')
addpath('/DFS-L/DATA/primeau/weilewang/DATA/OCIM2')
addpath('/DFS-L/DATA/primeau/weilewang/GREG/Couple_CP/')
on = true; off = false;
global GC GO
version = 90;

load transport_v4.mat
load Sobs_90x180x24.mat
load tempobs_90x180x24.mat
load theta_from_qqq.mat theta
%
load human_co2
load GLODAP_grid_dic
load GLODAP_grid_Alk
load po4obs_90x180x24.mat % WOA PO4 observation
load raw_o2obs_90x180x24.mat o2raw
load raw_po4obs_90x180x24.mat po4raw
load raw_sio4obs_90x180x24.mat sio4raw
load sio4obs_90x180x24.mat sio4obs
load splco2_mod_monthly % monthly CO2 data
load co2syspar90.mat co2syspar

load npp_90x180.mat % Satellite NPP in C unit;
load kw660.mat Kw660 p4
load constant_b_C.mat
load constant_b_O2.mat

format long
grd  = grid         ;
iwet = find(M3d(:)) ;
nwet = length(iwet) ;
% define some constants;
spd  = 24*60^2;
spa  = 365*spd;
zc   = sum(grd.zt(1:2));
%
% convert unit form [ml/l] to [umol/l].
o2raw = o2raw.*44.661;  
% o2 correction based on Bianchi et al.(2012) [umol/l] .
o2raw_c = o2raw.*1.009-2.523;
% find out negative values and set them to zero.
ineg = find(o2raw_c(:)<0);
o2raw_c(ineg) = 0;
parm.o2raw = o2raw_c;
%
MSK_now = M3d;
parm.Salt  = Sobs    ;
parm.Temp  = tempobs ;
parm.ALK   = TAstar  ;
parm.dVt   = dVt     ;
parm.Kw660 = Kw660   ;
parm.p4    = p4      ;
parm.c2p   = 110     ;
parm.M3d   = M3d     ;
parm.iwet  = iwet    ;
parm.nwet  = nwet    ;
parm.TRdiv = -TR     ;
parm.grd   = grd     ;
parm.I     = speye(nwet);
parm.aveT  = nanmean(tempobs(:,:,1:8),3);
parm.Tobs  = tempobs;
parm.rho   = 1024.5         ; % seawater density;
permil     = parm.rho*1e-3  ; % from umol/kg to mmol/m3;
parm.theta = theta;
%
parm.SIL     = sio4obs;
parm.po4obs  = po4obs;
parm.po4raw  = po4raw;
parm.sio4raw = sio4raw;

parm.DICobs = dic*permil; % GLODAP dic obs [mmol/m3];
parm.TAobs  = TAstar*permil ; % GLODAP TA obs [mmol/m3];
parm.human_co2 = human_co2*permil;

GC = real([DIC(iwet); POC(iwet); DOC(iwet); CaC(iwet)]);
GO = real(O2(iwet)) + 1e-5*randn(parm.nwet,1);

% transiant CO2 concentraion;
parm.year      = splco2_mod(:,1) ;
parm.pco2_air  = splco2_mod(:,2) ;
parm.co2syspar = co2syspar       ;

iwet_msk = find(MSK_now(:))      ;

parm.kappa_g = 1/(1e6*spa); % geological restoring time [1/s];
parm.SILbar  = nansum(sio4obs(iocn).*dVt(iocn))/nansum(dVt(iocn));
parm.DIPbar  = nansum(po4obs(iwet).*dVt(iwet))/nansum(dVt(iwet)); % volume
parm.taup    = 720*60^2; % (s) pic dissolution time-scale
parm.tau_TA  = 1./parm.taup;
par.kappa_da = 0.5e-7    ;
% PME part;
[sst,ss] = PME(parm) ;
parm.ss  = ss        ;
parm.sst = sst       ;
%
% P model parameters;
par.sigma    = 2.72e-01 ;    ; % production to DOC ratio
par.slopep   = 0;
par.interpp  = 8.90e-01 ;
par.kappa_dp = 5.48e-08 ;
par.alpha    = 5.43e-03 ;
par.beta     = 4.19e-01 ;
                          
% C model parameters                                      
par.slopec   = 0;
par.interpc  = 1.15e+00 ;
par.kappa_dc = 3.69e-08 ;
par.RR       = 7.66e-02 ;
par.d        = 2.56e+03 ;
par.cc       = 0; %1.21e-03 ;
par.dd       = 1/117; % 7.17e-03 ;
%
% O model parameters
par.slopeo   = -5.00e+00 ;
par.interpo  = 2.95e+02 ;

% Si model parameters
par.bsi = 0.33;
par.at = 1.32e16/spd;
par.bt = 11481;
par.aa = 1;
par.bb = 0.968;
par.kappa_gs = 1/(1e6*spa); % geological restoring time [1/s];
%% -------------------------------------------------------------
par.Cmodel = on;
par.Omodel = on;
par.Simodel = off;
%
% P model parameters
par.opt_beta = on;
par.opt_alpha = on;
par.opt_sigma = on; 
par.opt_slopep = on; 
par.opt_interpp = on;
par.opt_kappa_dp = on;
% C model parameters
par.opt_d = on; % 
par.opt_RR = on; % 
par.opt_cc = off;
par.opt_dd = off;
par.opt_slopec = on;
par.opt_interpc = on; %
par.opt_kappa_dc = on; %
% O model parameters
par.opt_slopeo = on; 
par.opt_interpo = on; 
% Si model parameters
par.opt_bsi = on;
par.opt_at = on;
par.opt_bt = off;
par.opt_aa = on;
par.opt_bb = on;
par.opt_kappa_gs = off;
%% -------------------------------------------------------------
p0 = [];
% sigma 
if (par.opt_sigma == on)
    sigma = par.sigma; lsigma = log(sigma);
    strt = length(p0) + 1;
    p0 = [p0; lsigma];
    par.pindx.lsigma = strt : length(p0);
end 
% kappa_dp 
if (par.opt_kappa_dp == on)
    kappa_dp = par.kappa_dp; lkappa_dp = log(kappa_dp);
    strt = length(p0) + 1;
    p0 = [p0; lkappa_dp];
    par.pindx.lkappa_dp = strt : length(p0);
end
% slopep
if (par.opt_slopep == on)
    slopep = par.slopep;
    strt = length(p0) + 1;
    p0 = [p0; slopep];
    par.pindx.slopep = strt : length(p0);
end 
% interpp
if (par.opt_interpp == on)
    interpp = par.interpp; linterpp = log(interpp);
    strt = length(p0) + 1;
    p0 = [p0; linterpp];
    par.pindx.linterpp = strt : length(p0);
end 
% alpha 
if (par.opt_alpha == on)
    alpha = par.alpha; lalpha = log(alpha);
    strt = length(p0) + 1;
    p0 = [p0; lalpha];
    par.pindx.lalpha = strt : length(p0);
end 
% beta
if (par.opt_beta == on)
    beta = par.beta; lbeta = log(beta);
    strt = length(p0) + 1;
    p0 = [p0; lbeta];
    par.pindx.lbeta = strt : length(p0);
end
%
if (par.Cmodel == on)
    % slopec
    if (par.opt_slopec == on)
        slopec = par.slopec;
        strt = length(p0) + 1;
        p0 = [p0; slopec];
        par.pindx.slopec = strt : length(p0);
    end 
    % interpc
    if (par.opt_interpc == on)
        interpc = par.interpc; linterpc = log(interpc);
        strt = length(p0) + 1;
        p0 = [p0; linterpc];
        par.pindx.linterpc = strt : length(p0);
    end 
    % d
    if (par.opt_d == on)
        d = par.d; ld = log(d);
        strt = length(p0) + 1;
        p0 = [p0; ld];
        par.pindx.ld = strt : length(p0);
    end 
    % kappa_dc
    if (par.opt_kappa_dc == on)
        kappa_dc = par.kappa_dc; lkappa_dc = log(kappa_dc);
        strt = length(p0) + 1;
        p0 = [p0; lkappa_dc];
        par.pindx.lkappa_dc = strt : length(p0);
    end 
    % RR
    if (par.opt_RR == on)
        RR = par.RR; lRR = log(RR);
        strt = length(p0) + 1;
        p0 = [p0; lRR];
        par.pindx.lRR = strt : length(p0);
    end
    % cc
    if (par.opt_cc == on)
        cc = par.cc; lcc = log(cc);
        strt = length(p0) + 1;
        p0 = [p0; lcc];
        par.pindx.lcc = strt : length(p0);
    end
    % dd
    if (par.opt_dd == on)
        dd = par.dd; ldd = log(dd);
        strt = length(p0) + 1;
        p0 = [p0; ldd];
        par.pindx.ldd = strt : length(p0);
    end
end
if par.Omodel == on
    % slopeo
    if (par.opt_slopeo == on)
        slopeo = par.slopeo; 
        strt = length(p0) + 1;
        p0 = [p0; slopeo];
        par.pindx.slopeo = strt : length(p0);
    end 
    % interpo
    if (par.opt_interpo == on)
        interpo = par.interpo; linterpo = log(interpo);
        strt = length(p0) + 1;
        p0 = [p0; linterpo];
        par.pindx.linterpo = strt : length(p0);
    end
end 
if par.Simodel == on 
    % bsi
    if (par.opt_bsi == on)
        bsi = par.bsi; lbsi = log(bsi);
        strt = length(p0) + 1;
        p0 = [p0; lbsi];
        par.pindx.lbsi = strt : length(p0);
    end
    % at 
    if (par.opt_at == on)
        at = par.at; lat = log(at);
        strt = length(p0) + 1;
        p0 = [p0; lat];
        par.pindx.lat = strt : length(p0);
    end
    % bt
    if (par.opt_bt == on)
        bt = par.bt; lbt = log(bt);
        strt = length(p0) + 1;
        p0 = [p0; lbt];
        par.pindx.lbt = strt : length(p0);
    end
    % aa
    if (par.opt_aa == on)
        aa = par.aa;
        strt = length(p0) + 1;
        p0 = [p0; aa];
        par.pindx.aa = strt : length(p0);
    end
    % bb
    if (par.opt_bb == on)
        bb = par.bb; lbb = log(bb);
        strt = length(p0) + 1;
        p0 = [p0; lbb];
        par.pindx.lbb = strt : length(p0);
    end
    % kappa_gs
    if (par.opt_kappa_gs == on)
        kappa_gs = par.kappa_gs; lkappa_gs = log(kappa_gs);
        strt = length(p0) + 1;
        p0 = [p0; lkappa_gs];
        par.pindx.lkappa_gs = strt : length(p0);
    end
end
%
%% -------------------------------------------------------------
%
parm.kappa_p = 1/(720*60^2) ;
parm.p2c = 0.006+0.0069*po4obs;
parm.nzo = 2;
%%%%%%% prepare NPP for the model %%%%%%%%
inan = find(isnan(npp(:)));
npp(inan) = 0;
% tmp = squeeze(M3d(:,:,1));
% tmp(1:15,:) = nan; % SO
% tmp(65:78,55:125) = nan; % NP
% tmp(35:55,90:145) = nan; % EP
% iso = find(isnan(tmp));
% npp(iso) = npp(iso)*0.5;
parm.npp    = npp/(12*spd);
parm.Lambda = M3d*0;
parm.Lambda(:,:,1) = 0.5*(1/grd.dzt(1))*parm.p2c(:,:,1)./(1e-9+po4obs(:,:,1));
parm.Lambda(:,:,2) = 0.5*(1/grd.dzt(2))*parm.p2c(:,:,2)./(1e-9+po4obs(:,:,2));
parm.Lambda(:,:,3:end) = 0;
%%%%%%%%%%%%%%%%%%%% end %%%%%%%%%%%%%%%%%
parm.p0 = p0;
x0 = p0;
%
myfun = @(x) neglogpost(x, parm, par);
%
options = optimoptions(@fminunc                  , ...
                       'Algorithm','trust-region', ...
                       'GradObj','on'            , ...
                       'Hessian','on'            , ...
                       'Display','iter'          , ...
                       'MaxFunEvals',2000        , ...
                       'MaxIter',2000            , ...
                       'TolX',5e-7               , ...
                       'TolFun',5e-7             , ...
                       'DerivativeCheck','off'   , ...
                       'FinDiffType','central'   , ...
                       'PrecondBandWidth',Inf)   ;
%
G_test = off;
nip    = length(x0);
if(G_test);
    dx = sqrt(-1)*eps.^3*eye(nip);
    for ii = 1:nip
        x  = real(x0)+dx(:,ii);
        [f,fx,fxx] = neglogpost(x, parm, par) ;
        diff = real(fx(ii)) - imag(f)/eps.^3 ;
        fprintf('%i %e  \n',ii,diff);
        diffx = real(fxx(:,ii)) - imag(fx)/eps.^3;
        for jj = 1:length(fx)
            fprintf('%e  ', diffx(jj));
        end
        fprintf('\n');
        keyboard
    end
else
    [xhat,fval,exitflag] = fminunc(myfun,x0,options);
    [f,fx,fxx] = neglogpost(xhat,parm,par);
    save temp_PCO_const_c2p_xhat xhat fx fxx
end

fprintf('------------ END! ---------------\n');