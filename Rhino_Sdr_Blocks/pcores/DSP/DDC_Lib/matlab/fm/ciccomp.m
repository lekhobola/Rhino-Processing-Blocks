%% cic compensating filter design
%% Two design methods are listed/compared:
%%      fir2.m -- frequency sampling method; Signal Processing Toolbox Required
%%      firceqrip.m -- Equal Rippler Design Method; Filter Design Toolbox Required
%% Output: filter coefficients saved in fdcoeff.txt in the format that can
%%          be readily loaded by Altera FIR Compiler MegaCore
function [hcic,hcfir] = ciccomp();
%clear all
%close all

%%%%%% CIC filter parameters %%%%%%
R = 140;                                    %% Decimation factor
M = 1;                                      %% Differential Delay
N = 20;                                      %% Number of Stages
B = 18;                                     %% Number of bits to represent fixed point filter coefficients
Fs = 56e6;                                 %% (High) Sampling frequency in Hz (before decimation)
Fc = 90e3;                                   %% Passband edge in Hz
%%%%%%% fir2.m parameters %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
L = 16;                                     %% Order of filter taps; must be an even number
Fo = R*Fc/Fs;                             %% Normalized Cutoff freq; 0<Fo<=0.5/M; xdong: modified 10/30/06: taken out /M.
                                          %% Fo should be less than 1/(4M), if not, bad performance is guranteed                                 
% Fo = 0.5/M;                                 %% use Fo=0.5 if we don't care responses outside passband

%%%%%%% CIC Compensator Design using fir2.m %%%%%%
p = 2e3;                                    %% Granulatiry
s = 0.25/p;                               %% Stepsize
fp = [0:s:Fo];                              %% Passband frequency samples
                                            %% xdong: modified 10/30/06:
                                            %% taken out /M
fs = (Fo+s):s:0.5;                          %% Stopband frequency samples
f = [fp fs]*2;                            %% Noramlized frequency samples; 0<=f<=1; taken out *M 11/29/06
Mp = ones(1,length(fp));                    %% Passband response; Mp(1)=1
Mp(2:end) = abs( M*R*sin(pi*fp(2:end)/R)./sin(pi*M*fp(2:end))).^N; %% Inverse sinc
Mf = [Mp zeros(1,length(fs))];
f(end) = 1;
h = fir2(L,f,Mf);                           %% Filter length L+1
h = h/max(h);                              %% Floating point coefficients
hz = round(h*power(2,B-1)-1);                   %% Quantization of filter coefficients

%%%%%%% fixed point CIC filter response %%%%%%%%
hrec = ones(1,R*M);
tmph = hrec;

for k=1:N-1
    tmph = conv(hrec, tmph);
end;
hcic = tmph;
hcic=hcic/norm(hcic);

%%%%%%% Total Response %%%%%%%%%%%%%%%
hzp = upsample(hz,R);
hp = upsample(h, R);
ht = conv(hcic, hp);                        %% Concatenation of CIC and fir2 FIR at high freqency
hzt = conv(hcic, hzp);                      %% CIC + Fixed point fir2 at high frequency

hcfir = hp;

[Hcic, wt] = freqz(hcic, 1, 4096, Fs);      %% CIC Freq. Response
[Hciccomp, wt] = freqz(hp, 1, 4096, Fs);    %% CIC Comp. response using fir2
[Ht, wt] = freqz(ht, 1, 4096, Fs);          %% Total response for CIC + floating point fir2
[Hzt, wt] = freqz(hzt, 1, 4096, Fs);        %% Total response for CIC + fixed point fir2

Mcic = 20*log10(abs(Hcic)/max(abs(Hcic)));  %% CIC Freq. Response
Mciccomp = 20*log10(abs(Hciccomp)/max(abs(Hciccomp)));  %% CIC Comp. response using fir2
Mt = 20*log10(abs(Ht)/max(abs(Ht)));        %% Total response for CIC + floating point fir2
Mzt = 20*log10(abs(Hzt)/max(abs(Hzt)));     %% Total response for CIC + fixed point fir2

figure;
plot(wt, Mcic, wt, Mciccomp, wt, Mt,wt, Mzt);
legend('CIC','CIC Comp','Total Response (Floating Point)','Total Response (Fixed Point)')
ylim([-100 5]);
title('Frequency Sampling Method');
grid
xlabel('Frequency Hz');
ylabel('Filter Magnitude Response dB');


% %%%%%%%%%%% If no access to MATLAB Filter Design Toolbox, please comment
% %%%%%%%%%%% out from here %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %%%%%%% CIC Compensator Design using firceqrip.m %%%%%%%%%%%%%%%%%%%
% Ast = 90;                                   %% Stop band attenuation in dB
% Ap = 0.01;                                  %% Passband ripple in dB
% c = M/2;                                    %% Sinc frequency scaling
% Apass = power(10, Ap/20) - 1;               %% passband variation corresponding to Ap
% Astop = power(10, -Ast/20);                 %% stop band variation corresponding to Ast
% Aslope = 40;                                %% Slope in dB
% fc = Fo*2*M;                                %% Normalized cutoff frequency (to Nyquist freq.); 0<=fc<=1;
% heq = firceqrip(L, fc, [Apass, Astop], 'passedge', 'slope', Aslope, 'invsinc', [c, N]);
% heq = heq/norm(heq);                        %% Floating point coefficients
% hc = floor(heq*power(2,B));                 %% Quantization of filter coefficients
% 
% hcp = upsample(heq, R);
% hct = conv(hcic, hcp);                      %% CIC + Floating Point Equal Ripple FIR at high frequency
% [Het, wc] = freqz(hcp, 1, 4096, Fs);        %% Freq. Response of Equal Ripple FIR at high freq.
% [Hct, wc] = freqz(hct, 1, 4096, Fs);        %% CIC + floating point Equal Ripple FIR
% Me = 20*log10(abs(Het)/max(abs(Het)));      %% Freq. Response of Equal Ripple FIR at high freq.
% Mc = 20*log10(abs(Hct)/max(abs(Hct)));      %% CIC + floating point Equal Ripple FIR
% 
% figure;
% plot(wt, Mcic, wc, Me, wc, Mc);
% legend('CIC','CIC Comp','Total Response Floating Point')
% % xlim([0 2/R]);
% ylim([-100 5]);
% grid
% title('Equal Ripple Method');
% xlabel('Frequency Hz');
% ylabel('Filter Magnitude Response dB');
%%%%%%%%%%%% end of Comment Out %%%%%%%%%%%%%%%%%%%%%%


