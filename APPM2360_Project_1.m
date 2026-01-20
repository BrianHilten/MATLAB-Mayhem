%APPM2360_Project_1.m
%Description: This script is for APPM2360 Project 1
%Authors: Brian Hilten & Ethan Sandersfield
%Date Last Modified: 9/27/2025
%% Task Set A
%Plotting d)
clear; close all
t = 0:1:24;
T = 0:1:24;
T2 = 0:1:24;
hold on
%Plot our graphs:
for i=1:25
    T(i) = 75 + (50-75)*exp(-0.25*i);
end
for i=1:25
    T2(i) = 75 + (80-75)*exp(-0.25*i);
end
plot(t,T,'y-')
plot(t,T2,'r-')
yline(75,'g--')
xlabel('Time (Hours)');
ylabel('Temperature (°F)');
title('Temperature of an Object Over Time');
hold off
legend('T(0) = 50','T(0) = 80','M = 75')
%----------------Different Values of k----------------
figure()
hold on
T3 = 0:1:24;
T4 = 0:1:24;
T5 = 0:1:24;
for i=1:25
    T3(i) = 75 + (50-75)*exp(-1.0*i);
end
for i=1:25
    T4(i) = 75 + (50-75)*exp(-0.5*i);
end
for i=1:25
    T5(i) = 75 + (50-75)*exp(-0.25*i);
end
plot(t,T3,'y')
plot(t,T4,'r')
plot(t,T5,'c')
yline(75,'g--')
xlabel('Time (Hours)');
ylabel('Temperature (°F)');
title('Temperature of an Object Over Time with Varying Values of k');
hold off
legend('k=1','k=0.5','k=0.25','M = 75')
%----------------------------END TASK SET A-------------------------------%
%% RK4 Function Test:
% function y = dT(t,w) %Function which returns our derivative dT/dt
% y = 0.25*(75-w);
% end
% f = @dT;
% %f = @(t,w) 0.25*(75-w); //another way to write the function above
% hold on
% [t,w] = rk4(0,24,240,50,f);
% plot(t,w)
% yline(75,'b--')
% hold off
%-------------------------------------------------------------------------%
%% Task Set B:
% Differential equation: dT/dt = 0.25*(75 - T), T(0) = 50
% Parameters
ti = 0;           %ti=initial value of independent variable
tf = 24;          %tf=right endpoint of interval over which solution is computed
npts = 240;       %npts=number of discrete points in the interval 
T0 = 50;

% Define function handle f(t,T)
f = @(t,T) 0.25*(75 - T);

% Solve numerically with RK4
[t_num, T_num] = rk4(ti, tf, npts, T0, f);

% Exact solution
T_exact = 75 + (T0 - 75) * exp(-0.25*t_num);

% Plot numerical vs exact solution
figure('Color','k'); % black background
ax1 = axes('Color','k');
hold on;

plot(t_num, T_exact, 'c-', 'LineWidth', 2);       % cyan exact solution
plot(t_num, T_num, 'ro', 'MarkerSize', 4, ...
    'MarkerFaceColor','k', 'MarkerEdgeColor','r'); % red RK4 points

xlabel('Time (Hours)', 'Color','w');
ylabel('Temperature (°F)', 'Color','w');
title('Exact vs RK4 Approximation', 'Color','w');
legend('Exact solution', 'RK4 approximation', ...
    'TextColor','w', 'Location','best');
grid on; 
ax1.GridColor = [0.5 0.5 0.5]; 
ax1.XColor = 'w'; 
ax1.YColor = 'w';

% Error analysis
error = abs(T_exact - T_num);

figure('Color','k');
ax2 = axes('Color','k');
plot(t_num, error, 'y-', 'LineWidth', 2); % yellow error line

xlabel('Time (Hours)', 'Color','w');
ylabel('|Error| (°F)', 'Color','w');
title('Absolute Error: Exact - RK4', 'Color','w');
grid on; 
ax2.GridColor = [0.5 0.5 0.5]; 
ax2.XColor = 'w'; 
ax2.YColor = 'w';

% Maximum absolute error
maxError = max(error);
fprintf('Maximum absolute error over [0,24]: %.4e °F\n', maxError);
hold off
%---------------------------END TASK SET B--------------------------------%
%% Task Set C:
% Parameters
k = 0.25;                % cooling constant
tspan = [0 24];
h = 0.1;
npts = (tspan(2)-tspan(1))/h;
T0 = 65;

% Define M(t) as function handle
Mfun = @(t,M0) M0 - 12*cos(pi*(t-5)/12);

% Define RHS of ODE: dT/dt = k*(M(t)-T)
f = @(t,T,M0) k*(Mfun(t,M0) - T);

%======================
% Case 1: M0 = 75
%======================
M0 = 75;
[t,T1] = rk4(tspan(1),tspan(2),npts,T0,@(t,T) f(t,T,M0));
Mvals1 = Mfun(t,M0);

[MaxM1,idxMmax1] = max(Mvals1);
[MinM1,idxMmin1] = min(Mvals1);
[MaxT1,idxTmax1] = max(T1);
[MinT1,idxTmin1] = min(T1);

% Plot Case 1
figure;
set(gcf,'Color','k'); % black background
plot(t,Mvals1,'y--','LineWidth',1.5); hold on;
plot(t,T1,'c','LineWidth',2);
xlabel('Time (Hours)','Color','w'); ylabel('Temperature (°F)','Color','w');
title('Case 1: Outside vs Inside Temperature (M0=75)','Color','w');
legend('Outside M(t)','Inside T(t)','TextColor','w','Location','Best'); grid on;
set(gca,'Color','k','XColor','w','YColor','w');

%======================
% Case 2: M0 = 35
%======================
M0 = 35;
[~,T2] = rk4(tspan(1),tspan(2),npts,T0,@(t,T) f(t,T,M0));
Mvals2 = Mfun(t,M0);

[MaxM2,idxMmax2] = max(Mvals2);
[MinM2,idxMmin2] = min(Mvals2);
[MaxT2,idxTmax2] = max(T2);
[MinT2,idxTmin2] = min(T2);

% Plot Case 2
figure();
set(gcf,'Color','k'); % black background
plot(t,Mvals2,'m--','LineWidth',1.5); hold on;
plot(t,T2,'g','LineWidth',2);
xlabel('Time (Hours)','Color','w'); ylabel('Temperature (°F)','Color','w');
title('Case 2: Outside vs Inside Temperature (M0=35)','Color','w');
legend('Outside M(t)','Inside T(t)','TextColor','w','Location','Best'); grid on;
set(gca,'Color','k','XColor','w','YColor','w');
hold off
%======================
% Display results (rounded, hh:mm format)
%======================
fprintf('\n=== Case 1: M0 = 75 ===\n');
fprintf('Outdoor Max: %.2f °F at %s\n', MaxM1, hmin(t(idxMmax1)));
fprintf('Outdoor Min: %.2f °F at %s\n', MinM1, hmin(t(idxMmin1)));
fprintf('Indoor Max:  %.2f °F at %s\n', MaxT1, hmin(t(idxTmax1)));
fprintf('Indoor Min:  %.2f °F at %s\n', MinT1, hmin(t(idxTmin1)));

fprintf('\n=== Case 2: M0 = 35 ===\n');
fprintf('Outdoor Max: %.2f °F at %s\n', MaxM2, hmin(t(idxMmax2)));
fprintf('Outdoor Min: %.2f °F at %s\n', MinM2, hmin(t(idxMmin2)));
fprintf('Indoor Max:  %.2f °F at %s\n', MaxT2, hmin(t(idxTmax2)));
fprintf('Indoor Min:  %.2f °F at %s\n', MinT2, hmin(t(idxTmin2)));

%======================
% Helper function: convert decimal hours to hh:mm string
%======================
function tstr = hmin(t)
    hr = floor(t);
    mn = round(60*(t-hr));
    if mn == 60   % handle rounding edge case
        hr = hr + 1;
        mn = 0;
    end
    tstr = sprintf('%02d:%02d',hr,mn);
end
hold off
%-----------------------------END TASK SET C------------------------------%
%% Task Set D:
% Graph solution to dT/dt = H(t)
function y = dT(t,w) %Function which returns our derivative dT/dt
y = 14/(exp(3/4*(t-10))+exp(-3/4*(t-10)));
end
f = @dT;
% f = @(t,w) 0.25*(75-w); //another way to write the function above
figure()
hold on
[t,w] = rk4(0,24,240,65,f);
[max_val_D, index_D] = max(w); %Find our max value in [w]
max_time_D = t(index_D); %Find what time our max value occurs
plot(t,w)
xlabel('Time (Hours)');
ylabel('Temperature (°F)');
title('Task Set D: Numeric Approximation of T(t)');
axis([0 25 50 100]); % [x_i x_f y_i y_f]
hold off
figure()
hold on
% Graph H(t)
t1 = 0:0.05:24;
y1 = zeros(size(t1));
n = numel(t1);
for i = 1:n
    y1(i) = 14/(exp(3/4*(t1(i)-10))+exp(-3/4*(t1(i)-10)));
end
plot(t1,y1)
xlabel('Time (Hours)');
ylabel('H(t)');
title('Task Set E: Graph of H(t)');
axis([0 25 0 10]);
hold off
%----------------------------END TASK SET D-------------------------------%
%% Task Set E
% Q(t)=kd(Td-T)
% a) kd = 0.2, y0 = 65
figure()
hold on
f = @(t,w) 0.2*(77-w);
[t,w] = rk4(0,24,240,65,f);
plot(t,w, 'r-')
% b) kd = 2.0, y0 = 65
f = @(t,w) 2.0*(77-w);
[t1,w1] = rk4(0,24,240,65,f);
plot(t1,w1, 'm-')
% c) kd = 0.2, y0 = 95
f = @(t,w) 0.2*(77-w);
[t2,w2] = rk4(0,24,240,95,f);
plot(t2,w2, 'g-')
% d) kd = 2.0, y0 = 95
f = @(t,w) 2.0*(77-w);
[t3,w3] = rk4(0,24,240,95,f);
plot(t3,w3, 'y-')
yline(77,'w--')
hold off
xlabel('Time (Hours)');
ylabel('Temperature (°F)');
title('Task Set E: Temperature Response');
legend('kd = 0.2', 'kd = 2.0','kd=0.2','kd=2.0','M=77');
axis([0 25 50 100]);
%In this scenario, kd could be the strength of the air conditioners/furnaces
%---------------------------------END TASK SET E-------------------------%
%% Task Set F:
% 1.
figure()
f = @(t,w) 14/(exp(3/4*(t-10))+exp(-3/4*(t-10))) + 2*(77-w);
[t4,w4] = rk4(0,24,240,75,f);
plot(t4,w4);
yline(77,'w--');
xlabel('Time (Hours)');
ylabel('Temperature (°F)');
legend('T(t), T(0)=75','Td = 77');
axis([0 25 70 85]);
title('Task Set F: Machinery, People, and Lighting with Air Conditioning');
% Max Temp: 80.03169 at 10.4 ~10:24am
[max_val_F1, index_F1] = max(w4);
max_time_F1 = t4(index_F1);
% 2.
f = @(t,w) 0.25*(85-10*cos(pi*(t-5)/12)-w);
[t5,w5] = rk4(0,24,240,75,f);
figure()
plot(t5,w5,'g-');
yline(81,'w--');
xlabel('Time (Hours)');
ylabel('Temperature (°F)');
legend('T(t), T(0) = 75', 'Equipment Temperature Threshold','Location','southeast');
title('Task Set F: A Hot Weekend');
% Find index at which equipment is damaged at T > 81:
F2_Damage = find(w5>81,1);
% Find the corresponding time t when T first exceeds 81: ~12:12pm
F2_Time = t5(F2_Damage);
% Find max temp the building will reach: ~91.8169
F2_Max = max(w5);
% 3.
figure()
f = @(t,w) 0.25*(85-10*cos(pi*(t-5)/12)-w)+2*(77-w); %kd = 2
f2 = @(t,w) 0.25*(85-10*cos(pi*(t-5)/12)-w)+0.5*(77-w); %kd =0.5
[t6,w6] = rk4(0,24,240,75,f);
[t7,w7] = rk4(0,24,240,75,f2);
hold on
plot(t6,w6, 'r-'); %kd = 2
plot(t7,w7, 'g-'); %kd = 0.5
yline(81, 'w--');
legend('kd = 2', 'kd = 0.5');
title('Task Set F: A Hot Weekend with Air Conditioning');
xlabel('Time (Hours)');
ylabel('Temperature (°F)');
hold off
%Max Temp when kd = 2: No damage to equipment
F3_Max = max(w6);
%Max Temp when kd = 0.5: Damage to equipment for ()
F3_Max2 = max(w7);
%Find how long the equipment is being damaged (T > 81)\
%Initial attempt at finding crossover points:
F3_DamageStart = [find(w7<81 & w7>80.9,1,"first"),find(w7>81,1,"first")]; % [Start_Bottom, Start_Top]
F3_DamageEnd = [find(w7>81 & w7<81.1,1,"last"),find(w7<81 & w7>80.9,1,"last")]; % [End_Top, End_Bottom]
F3_DamageTime = t(F3_DamageEnd(2))-t(F3_DamageStart(1)); %Initial estimate for damage time (not completely accurate)
% (without interpolation) Equipment is damaged for 8.8 hours (8 hours and 48 minutes)
%Refined attempt focusing on the first and last indices of the w7>81 range:
F3_Elegant = [find(w7>81,1,"first"),find(w7>81,1,"last")]; % [Start_Top, End_Top]
%The above two strategies both agree, so to find the actual intersects we
%need to interpolate:
F3_DamageTemp1 = w7(F3_DamageStart); %Find top/bottom values of w7 when damage first starts and ends (first intersect with y=81)
F3_DamageTemp2 = w7(F3_DamageEnd); %Find top/bottom values of w7 when damage ends (second intersect with y=81)
F3_DamageTimes_Start = t(F3_DamageStart); %Find top/bottom times when damage first starts and ends (first intersect with y=81)
F3_DamageTimes_End = t(F3_DamageEnd); %Find top/bottom times when damage ends (second intersect with y=81)
% Interpolate: Damage starts at approx. t=13.957(1:57pm), ends at approx. t=22.612(10:37pm)
% Equipment is damaged for ~(8 hours and 40 minutes)
% 4.
f = @(t,w) 0.25*(85-10*cos(pi*(t-5)/12)-w) + 14/(exp(3/4*(t-10))+exp(-3/4*(t-10))) + 2*(77-w); %yikes
[t8,w8] = rk4(0,72,720,75,f);
figure()
hold on
plot(t8,w8,'g-')
% Graph M(t)
tf = 0:0.05:72;
yf = zeros(size(tf));
n = numel(tf);
for i = 1:n
    yf(i) = 85-10*cos(pi*(tf(i)-5)/12);
end
w8_max = max(w8); %Max temp: 80.5956 (phew!)
plot(tf,yf,'c-')
yline(77, 'w--')
legend('Building Temperature', 'Ambient Temperature','Thermostat')
title('A Long Weekend')
xlabel('Time (Hours)')
ylabel('Temperature (°F)')
axis([0 72 60 100])
hold off

%% External Functions
%
% <include>rk4.m</include>
%
