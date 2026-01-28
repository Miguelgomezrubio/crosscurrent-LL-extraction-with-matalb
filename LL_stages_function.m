function [Number_of_equilibrium_stages, R, E, R_massFlow, E_massFlow, ...
          P_raf, P_ext, P_equ, M] = LL_stages_function( ...
                xS_eq, xD_eq, P_degree, ...
                yS_eq, yD_eq, xSn, ...
                Ro, xSo, xDo, ...
                Eo, ySo, yDo)
% LL_STAGES_FUNCTION
% -------------------------------------------------------------------------
% Computes the number of equilibrium stages in a counter-current LL
% extraction process and the compositions/flow rates of all streams.
%
% INPUTS:
%   xS_eq      - Solute mass fraction in raffinate equilibrium data
%   xD_eq      - Solvent mass fraction in raffinate equilibrium data
%   P_degree   - Polynomial degree for equilibrium correlation
%   yS_eq      - Solute mass fraction in extract equilibrium data
%   yD_eq      - Solvent mass fraction in extract equilibrium data
%   xSn        - Target final raffinate solute mass fraction
%   Ro         - Raffinate feed flow rate [kg/h]
%   xSo        - Solute mass fraction in raffinate feed
%   xDo        - Solvent mass fraction in raffinate feed
%   Eo         - Extract feed flow rate [kg/h]
%   ySo        - Solute mass fraction in extract feed
%   yDo        - Solvent mass fraction in extract feed
%
% OUTPUTS:
%   Number_of_equilibrium_stages - Number of theoretical stages
%   R          - Raffinate compositions [xS, xD] at each stage
%   E          - Extract compositions  [yS, yD] at each stage
%   R_massFlow - Raffinate mass flow rate at each stage
%   E_massFlow - Extract mass flow rate at each stage
%   P_raf      - Polynomial coefficients for raffinate equilibrium curve
%   P_ext      - Polynomial coefficients for extract equilibrium curve
%   P_equ      - Polynomial coefficients for tie-line correlations
%   M          - Mixing points [zMs, zMd] at each stage
% -------------------------------------------------------------------------

%% Equilibrium correlations

P_raf = polyfit(xS_eq, xD_eq, P_degree);  % Raffinate curve: xD = f(xS)
P_ext = polyfit(yS_eq, yD_eq, P_degree);  % Extract curve:  yD = g(yS)
P_equ = polyfit(yS_eq, xS_eq, P_degree);  % Tie line:      xS = h(yS)

%% Initial mixing point (overall mixture)

zMs0 = (Ro*xSo + Eo*ySo) / (Ro + Eo);   % Overall solute mass fraction (M)
zMd0 = (Ro*xDo + Eo*yDo) / (Ro + Eo);   % Overall solvent mass fraction (M)

%% Initialization of arrays

R_massFlow = Ro;   % Initial raffinate flow rate
E_massFlow = Eo;   % Initial extract flow rate

E = [ySo, yDo];    % First extract composition
M = [zMs0, zMd0];  % First mixing point
R = [xSo, xDo];    % First raffinate composition

xs_current = 1.1;  % Dummy value to start the iteration
n           = 1;   % Stage counter

FO_history = [];   % Objective function values at each stage (for diagnostics)

%% Stage-by-stage construction

while xs_current > xSn

    % Safety limit on the maximum number of stages
    if n < 130

        % Optimization bounds depend on the stage
        if n == 1
            [ys, FO] = fminbnd(@(ys) stage_function(ys, P_raf, P_equ, P_ext, ...
                                                    n, R, yDo, ySo, M), ...
                               0, 1);
        else
            [ys, FO] = fminbnd(@(ys) stage_function(ys, P_raf, P_equ, P_ext, ...
                                                    n, R, yDo, ySo, M), ...
                               0, E(n,1));
        end

        FO_history = [FO_history; FO];

    else
        warning('Convergence problem or excessively high number of stages.');
        return;
    end

    % Equilibrium compositions corresponding to the optimized yS
    yd = polyval(P_ext, ys);  % yD
    xs = polyval(P_equ, ys);  % xS
    xd = polyval(P_raf, xs);  % xD

    % Update raffinate and extract compositions
    R = [R; [xs, xd]];
    E = [E; [ys, yd]];

    % Mass balance to obtain extract mass flow at this stage
    E_massFlow_add = ( R_massFlow(n)*R(n,1) + Eo*ySo ...
                       - (R_massFlow(n) + Eo)*R(n+1,1) ) ...
                     / (E(n+1,1) - R(n+1,1));

    R_massFlow_add = R_massFlow(n) + Eo - E_massFlow_add;

    E_massFlow = [E_massFlow; E_massFlow_add];
    R_massFlow = [R_massFlow; R_massFlow_add];

    % Overall mixture at the new stage
    M_total  = R_massFlow(n+1) + Eo;
    zMs_new  = (R_massFlow(n+1)*xs + Eo*ySo) / M_total;
    zMd_new  = (R_massFlow(n+1)*xd + Eo*yDo) / M_total;

    M = [M; [zMs_new, zMd_new]];

    % Update stage counter and convergence variable
    n          = n + 1;
    xs_current = xs;

end

Number_of_equilibrium_stages = n - 1;

end % LL_stages_function


%% ========================================================================
%% =                            SUB-FUNCTIONS                             =
%% ========================================================================

function FO = stage_function(ys, P_raf, P_equ, P_ext, n, R, yDo, ySo, M)
% STAGE_FUNCTION
% Objective function for the minimization at a given stage. It measures the
% squared distance between the current mixing point and the intersection of
% two straight lines:
%   - The tie line (raffinate–extract equilibrium)
%   - The operating line defined by feed and stage compositions

    % Equilibrium compositions given yS
    yd = polyval(P_ext, ys);  % Extract solvent fraction
    xs = polyval(P_equ, ys);  % Raffinate solute fraction
    xd = polyval(P_raf, xs);  % Raffinate solvent fraction

    % Intersection between:
    % 1) Line through (ys, yd) and (xs, xd)
    % 2) Line through (ySo, yDo) and (R(n,1), R(n,2))
    [zMs, zMd] = intersection_function( ...
                        ys,  yd, ...
                        xs,  xd, ...
                        ySo, yDo, ...
                        R(n,1), R(n,2));

    % Squared distance between actual and intersection mixing point
    FO = (M(n,1) - zMs)^2 + (M(n,2) - zMd)^2;

end


function [zMs, zMd] = intersection_function(x1, y1, x2, y2, x3, y3, x4, y4)
% INTERSECTION_FUNCTION
% Computes the intersection point (zMs, zMd) of two straight lines:
%   Line 1: points (x1, y1) and (x2, y2)
%   Line 2: points (x3, y3) and (x4, y4)

    % Line 1: y = m1 * x + b1
    m1 = (y2 - y1) / (x2 - x1);
    b1 = y1 - m1 * x1;

    % Line 2: y = m2 * x + b2
    m2 = (y4 - y3) / (x4 - x3);
    b2 = y3 - m2 * x3;

    % Intersection
    zMs = (b2 - b1) / (m1 - m2);  % x-coordinate
    zMd = m1 * zMs + b1;          % y-coordinate

end

