
function plot_graph_function(R, E, M, ...
                             E0, R0, xS0, yS0, yD0, ...
                             P_raf, P_ext, xS_target)
% PLOT_GRAPH_FUNCTION
% -------------------------------------------------------------------------
% Generates the graphical representation of the equilibrium and operating
% lines for the LL extraction process, including:
%   - Equilibrium curves (raffinate and extract)
%   - Raffinate, extract and mixing points at each stage
%   - Distribution lines between extract and raffinate
%   - Feed lines between raffinate stages and fresh extract
%   - Target final raffinate composition
%
% INPUTS:
%   R          - Raffinate compositions [xS, xD] at each stage
%   E          - Extract compositions  [yS, yD] at each stage
%   M          - Mixing points [zMs, zMd]
%   E0         - Extract feed flow rate [kg/h]
%   R0         - Raffinate feed flow rate [kg/h]
%   xS0        - Solute mass fraction in raffinate feed
%   yS0        - Solute mass fraction in extract feed
%   yD0        - Solvent mass fraction in extract feed
%   P_raf      - Polynomial coefficients for raffinate equilibrium curve
%   P_ext      - Polynomial coefficients for extract equilibrium curve
%   xS_target  - Target final raffinate solute mass fraction
% -------------------------------------------------------------------------

    %% Plot settings and label offsets

    % Offsets for text labels (extract points)
    h_offset_E = 0.00;   % Horizontal offset for extract point labels
    v_offset_E = 0.045;  % Vertical   offset for extract point labels

    % Offsets for text labels (raffinate points)
    h_offset_R = 0.005;  % Horizontal offset for raffinate point labels
    v_offset_R = -0.030; % Vertical   offset for raffinate point labels

    % Offsets for text labels (mixing points)
    h_offset_M = 0.005;  % Horizontal offset for mixing point labels
    v_offset_M = 0.010;  % Vertical   offset for mixing point labels

    % Marker size for all points
    markerSize = 7;

    %% Equilibrium curves

    interval = linspace(0, xS0 + 0.1, 80);

    eq_raffinate = polyval(P_raf, interval); % xD vs xS
    eq_extract   = polyval(P_ext, interval); % yD vs yS (plotted vs same interval)

    figure;
    plot(interval, eq_extract, 'k');  % Extract equilibrium curve
    hold on;
    plot(interval, eq_raffinate, 'k');% Raffinate equilibrium curve

    title(sprintf('Graphical representation of stage calculation (R_0 = %.1f, E_0 = %.1f kg/h)', ...
                  R0, E0));
    xlabel('x_S , y_S');
    ylabel('x_D , y_D');
    grid on;
    box on;

    %% Distribution lines (between extract and raffinate at each stage)

    nStages = size(E, 1);

    for i = 1:(nStages - 1)
        plot([E(i+1,1), R(i+1,1)], ...
             [E(i+1,2), R(i+1,2)], ...
             'Color', [0.8500, 0.3250, 0.0980]); % Orange line
    end

    %% Feed lines (between raffinate and fresh extract feed)

    for i = 1:(nStages - 1)
        plot([R(i,1), yS0], ...
             [R(i,2), yD0], ...
             'Color', [0, 0.4470, 0.7410]); % Blue line
    end

    %% Raffinate and extract points

    stageIndex = 0:(nStages - 1);

    for i = 1:nStages

        % Raffinate point
        plot(R(i,1), R(i,2), 'o', ...
             'MarkerSize', markerSize, ...
             'MarkerFaceColor', 'g', ...
             'MarkerEdgeColor', 'k');

        label_R = sprintf('R%d', stageIndex(i));
        text(R(i,1) + h_offset_R, ...
             R(i,2) + v_offset_R, ...
             {label_R});

        % Extract point
        plot(E(i,1), E(i,2), 'o', ...
             'MarkerSize', markerSize, ...
             'MarkerFaceColor', 'g', ...
             'MarkerEdgeColor', 'k');

        label_E = sprintf('E%d', stageIndex(i));
        text(E(i,1) + h_offset_E, ...
             E(i,2) + v_offset_E, ...
             {label_E});

    end

    %% Mixing points

    nMix = size(M, 1);

    for i = 1:(nMix - 1)
        plot(M(i,1), M(i,2), 'o', ...
             'MarkerSize', markerSize, ...
             'MarkerFaceColor', 'g', ...
             'MarkerEdgeColor', 'k');

        label_M = sprintf('M%d', stageIndex(i+1));
        text(M(i,1) + h_offset_M, ...
             M(i,2) + v_offset_M, ...
             {label_M});
    end

    %% Target separation point (desired final raffinate composition)

    plot(xS_target, polyval(P_raf, xS_target), '^', ...
         'MarkerSize', 5, ...
         'MarkerFaceColor', 'r', ...
         'MarkerEdgeColor', 'k');

end
