%% MAIN SCRIPT FOR LL EXTRACTION STAGE CALCULATION
% This script demonstrates the basic usage of the liquid–liquid (LL)
% extraction functions for:
%   - Computing equilibrium stages and stream compositions
%   - Plotting the graphical construction of the stages
%
% The LL extraction system is ternary, but only the solute (S) and
% solvent (D) mass fractions are used explicitly. The third component
% mass fraction is obtained by:
%       x_3 = 1 - x_S - x_D

close all;
clear;
clc;

%% INPUT DATA

% Equilibrium (mass fraction) data for the raffinate phase
xS_eq = [0.0596 0.1397 0.1905 0.2300 0.2692 0.2763 0.3088 0.3573 0.4090 0.4605 0.5178 0.5800];
xD_eq = [0.0052 0.0068 0.0079 0.0100 0.0102 0.0104 0.0117 0.0160 0.0210 0.0375 0.0652 0.1460];

% Equilibrium (mass fraction) data for the extract phase
yS_eq = [0.0875 0.2078 0.2766 0.3706 0.3852 0.3939 0.4297 0.4821 0.5395 0.5740 0.6034 0.5800];
yD_eq = [0.9093 0.7832 0.7101 0.6085 0.5921 0.5821 0.5392 0.4757 0.4000 0.3370 0.2626 0.1460];

% Desired raffinate solute mass fraction at the final stage
xSn = 0.06;

% RAFFINATE FEED SPECIFICATION
Ro  = 800;   % Raffinate feed flow rate [kg/h]
xSo = 0.45;  % Solute mass fraction in raffinate feed
xDo = 0.00;  % Solvent mass fraction in raffinate feed

% EXTRACT FEED SPECIFICATION
Eo  = 200;   % Extract feed flow rate [kg/h]
ySo = 0.00;  % Solute mass fraction in extract feed
yDo = 1.00;  % Solvent mass fraction in extract feed

% Polynomial degree for equilibrium correlation (recommended: 2)
P_degree = 2;

%% STAGE CALCULATION

% Compute the number of equilibrium stages and all associated streams
[Number_of_equilibrium_stages, R, E, R_massFlow, E_massFlow, ...
    P_raf, P_ext, P_equ, M] = LL_stages_function( ...
        xS_eq, xD_eq, P_degree, ...
        yS_eq, yD_eq, xSn, ...
        Ro, xSo, xDo, ...
        Eo, ySo, yDo);

fprintf('Number of equilibrium stages required for the specified separation: %d\n', Number_of_equilibrium_stages);

%% GRAPHICAL PLOT

plot_graph_function(R, E, M, ...
                    Eo, Ro, xSo, ySo, yDo, ...
                    P_raf, P_ext, xSn);



