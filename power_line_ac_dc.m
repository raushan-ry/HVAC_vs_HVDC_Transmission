clc;
clear;
close all;

%% SYSTEM DATA

P_load = 100e6;      % 100 MW

V_ac = 220e3;
V_dc = 500e3;

pf = 0.95;

distance = 50:50:1200;

%% LINE PARAMETERS

R_ac_per_km = 0.03;     % HVAC line resistance
R_dc_per_km = 0.015;    % HVDC line resistance

%% HVDC CONVERTER EFFICIENCY

rectifier_eff = 0.985;
inverter_eff  = 0.985;

converter_eff = rectifier_eff * inverter_eff;

%% CURRENT

I_ac = P_load/(sqrt(3)*V_ac*pf);

I_dc = P_load/V_dc;

%% ARRAYS

eff_ac = zeros(size(distance));
eff_dc = zeros(size(distance));

loss_ac = zeros(size(distance));
loss_dc = zeros(size(distance));

%% LOOP

for k = 1:length(distance)

    D = distance(k);

    %% HVAC

    R_ac = R_ac_per_km * D;

    loss_ac(k) = 3 * I_ac^2 * R_ac;

    P_recv_ac = P_load - loss_ac(k);

    eff_ac(k) = P_recv_ac/P_load*100;

    %% HVDC

    R_dc = R_dc_per_km * D;

    line_loss_dc = I_dc^2 * R_dc;

    P_after_line = P_load - line_loss_dc;

    P_recv_dc = P_after_line * converter_eff;

    loss_dc(k) = P_load - P_recv_dc;

    eff_dc(k) = P_recv_dc/P_load*100;

end

%% TABLE

Results = table(distance',...
                loss_ac'/1e6,...
                loss_dc'/1e6,...
                eff_ac',...
                eff_dc',...
'VariableNames',...
{'Distance_km',...
'HVAC_Loss_MW',...
'HVDC_Loss_MW',...
'HVAC_Efficiency',...
'HVDC_Efficiency'});

disp(Results);

%% BREAK EVEN POINT

difference = eff_dc - eff_ac;

idx = find(difference > 0,1);

if ~isempty(idx)

    fprintf('\n');
    fprintf('HVDC becomes better after approximately %.0f km\n',...
             distance(idx));

end

%% EFFICIENCY GRAPH

figure;

plot(distance,...
     eff_ac,...
     'LineWidth',3);

hold on;

plot(distance,...
     eff_dc,...
     'LineWidth',3);

grid on;

xlabel('Distance (km)');
ylabel('Efficiency (%)');

title('HVAC vs HVDC Efficiency');

legend('HVAC','HVDC',...
       'Location','southwest');

%% LOSSES GRAPH

figure;

plot(distance,...
     loss_ac/1e6,...
     'LineWidth',3);

hold on;

plot(distance,...
     loss_dc/1e6,...
     'LineWidth',3);

grid on;

xlabel('Distance (km)');
ylabel('Loss (MW)');

title('HVAC vs HVDC Power Loss');

legend('HVAC','HVDC');