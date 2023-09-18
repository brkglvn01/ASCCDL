classdef Lab01_UserApp_exported < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure                matlab.ui.Figure
        GridLayout              matlab.ui.container.GridLayout
        LeftPanel               matlab.ui.container.Panel
        SaturationSpinner       matlab.ui.control.Spinner
        SaturationSpinnerLabel  matlab.ui.control.Label
        RSpinner                matlab.ui.control.Spinner
        RSpinnerLabel           matlab.ui.control.Label
        BSpinner                matlab.ui.control.Spinner
        BSpinnerLabel           matlab.ui.control.Label
        GSpinner                matlab.ui.control.Spinner
        GSpinnerLabel           matlab.ui.control.Label
        LiftSpinnerLabel        matlab.ui.control.Label
        LiftSpinner             matlab.ui.control.Spinner
        PowerSpinnerLabel       matlab.ui.control.Label
        PowerSpinner            matlab.ui.control.Spinner
        OffsetSpinnerLabel      matlab.ui.control.Label
        OffsetSpinner           matlab.ui.control.Spinner
        SlopeSpinner            matlab.ui.control.Spinner
        SlopeSpinnerLabel       matlab.ui.control.Label
        UIAxes2                 matlab.ui.control.UIAxes
        RightPanel              matlab.ui.container.Panel
        UIAxes                  matlab.ui.control.UIAxes
    end

    % Properties that correspond to apps with auto-reflow
    properties (Access = private)
        onePanelWidth = 576;
    end

    
    properties (Access = private)  
        % Setting parameters
        slope = 1;
        lift = 1;
        offset = 0;
        power = 1;
        out_R = 0;
        out_G = 0;
        out_B = 0;
        sat = 1; 
        src_norm = max(load('src.mat').src/(2^10), 0);

    end
    
    

    % Callbacks that handle component events
    methods (Access = private)

        % Callback function: SlopeSpinner, SlopeSpinner
        function SlopeKnobValueChanged(app, event)
            app.slope = event.Value;
            app.lift = app.slope;

            % Update plot
            x = app.src_norm;
            y = apply_sop(app.src_norm, app.slope, app.offset, app.power);
            plot(app.UIAxes, x, y);
            app.UIAxes.YLim = [0 1];
            app.UIAxes.XLim = [0 1];
        end

        % Callback function: OffsetSpinner, OffsetSpinner
        function OffsetKnobValueChanged(app, event)
            app.offset = event.Value;
            app.lift = app.offset + 1;

            % Update plot
            x = app.src_norm;
            y = apply_sop(app.src_norm, app.slope, app.offset, app.power);
            plot(app.UIAxes, x, y);
            app.UIAxes.YLim = [0 1];
            app.UIAxes.XLim = [0 1];
        end

        % Callback function: PowerSpinner, PowerSpinner
        function PowerKnobValueChanged(app, event)
            app.power = event.Value;

            % Update plot
            x = app.src_norm;
            y = apply_sop(app.src_norm, app.slope, app.offset, app.power);
            plot(app.UIAxes, x, y);
            app.UIAxes.YLim = [0 1];
            app.UIAxes.XLim = [0 1];
        end

        % Callback function: LiftSpinner, LiftSpinner
        function LiftKnobValueChanged(app, event)
            app.lift = event.Value;
            app.slope = app.lift;
            app.offset = 1-app.lift;

            % Update plot
            x = app.src_norm;
            y = apply_sop(app.src_norm, app.slope, app.offset, app.power);
            plot(app.UIAxes, x, y);
            app.UIAxes.YLim = [0 1];
            app.UIAxes.XLim = [0 1];
        end

        % Value changed function: RSpinner
        function RSpinnerValueChanged(app, event)
            app.out_R = app.RSpinner.Value;

            % Update color patch
            x = [0 1 1 0];
            y = [0 0 1 1];
            patch(app.UIAxes2, x, y,[app.out_R app.out_G app.out_B]);
        end

        % Value changed function: BSpinner
        function BSpinnerValueChanged(app, event)
            app.out_B = app.BSpinner.Value;

            % Update color patch
            x = [0 1 1 0];
            y = [0 0 1 1];
            patch(app.UIAxes2, x, y,[app.out_R app.out_G app.out_B]);
        end

        % Value changed function: GSpinner
        function GSpinnerValueChanged(app, event)
            app.out_G = app.GSpinner.Value;

            % Update color patch
            x = [0 1 1 0];
            y = [0 0 1 1];
            patch(app.UIAxes2, x, y,[app.out_R app.out_G app.out_B]);
        end

        % Value changed function: SaturationSpinner
        function SaturationSpinnerValueChanged(app, event)
            app.sat = app.SaturationSpinner.Value;
            
            % Apply saturation adjustments
            RGB_out = apply_saturation(app.out_R,app.out_G, app.out_B, app.sat);
            
            % Update color patch
            x = [0 1 1 0];
            y = [0 0 1 1];
            patch(app.UIAxes2, x, y,RGB_out);
        end

        % Changes arrangement of the app based on UIFigure width
        function updateAppLayout(app, event)
            currentFigureWidth = app.UIFigure.Position(3);
            if(currentFigureWidth <= app.onePanelWidth)
                % Change to a 2x1 grid
                app.GridLayout.RowHeight = {480, 480};
                app.GridLayout.ColumnWidth = {'1x'};
                app.RightPanel.Layout.Row = 2;
                app.RightPanel.Layout.Column = 1;
            else
                % Change to a 1x2 grid
                app.GridLayout.RowHeight = {'1x'};
                app.GridLayout.ColumnWidth = {220, '1x'};
                app.RightPanel.Layout.Row = 1;
                app.RightPanel.Layout.Column = 2;
            end
        end
    end

    % Component initialization
    methods (Access = private)

        % Create UIFigure and components
        function createComponents(app)

            % Create UIFigure and hide until all components are created
            app.UIFigure = uifigure('Visible', 'off');
            app.UIFigure.AutoResizeChildren = 'off';
            app.UIFigure.Position = [100 100 640 480];
            app.UIFigure.Name = 'MATLAB App';
            app.UIFigure.SizeChangedFcn = createCallbackFcn(app, @updateAppLayout, true);

            % Create GridLayout
            app.GridLayout = uigridlayout(app.UIFigure);
            app.GridLayout.ColumnWidth = {220, '1x'};
            app.GridLayout.RowHeight = {'1x'};
            app.GridLayout.ColumnSpacing = 0;
            app.GridLayout.RowSpacing = 0;
            app.GridLayout.Padding = [0 0 0 0];
            app.GridLayout.Scrollable = 'on';

            % Create LeftPanel
            app.LeftPanel = uipanel(app.GridLayout);
            app.LeftPanel.Layout.Row = 1;
            app.LeftPanel.Layout.Column = 1;

            % Create UIAxes2
            app.UIAxes2 = uiaxes(app.LeftPanel);
            app.UIAxes2.XTick = [];
            app.UIAxes2.XTickLabel = '';
            app.UIAxes2.YTick = [];
            app.UIAxes2.YTickLabel = '';
            app.UIAxes2.Position = [34 11 152 137];

            % Create SlopeSpinnerLabel
            app.SlopeSpinnerLabel = uilabel(app.LeftPanel);
            app.SlopeSpinnerLabel.HorizontalAlignment = 'right';
            app.SlopeSpinnerLabel.Position = [34 412 36 22];
            app.SlopeSpinnerLabel.Text = 'Slope';

            % Create SlopeSpinner
            app.SlopeSpinner = uispinner(app.LeftPanel);
            app.SlopeSpinner.Step = 0.05;
            app.SlopeSpinner.ValueChangingFcn = createCallbackFcn(app, @SlopeKnobValueChanged, true);
            app.SlopeSpinner.Limits = [0.5 2];
            app.SlopeSpinner.ValueChangedFcn = createCallbackFcn(app, @SlopeKnobValueChanged, true);
            app.SlopeSpinner.Position = [85 412 100 22];
            app.SlopeSpinner.Value = 1;

            % Create OffsetSpinner
            app.OffsetSpinner = uispinner(app.LeftPanel);
            app.OffsetSpinner.Step = 0.05;
            app.OffsetSpinner.ValueChangingFcn = createCallbackFcn(app, @OffsetKnobValueChanged, true);
            app.OffsetSpinner.Limits = [-0.5 0.5];
            app.OffsetSpinner.ValueChangedFcn = createCallbackFcn(app, @OffsetKnobValueChanged, true);
            app.OffsetSpinner.Position = [85 371 100 22];

            % Create OffsetSpinnerLabel
            app.OffsetSpinnerLabel = uilabel(app.LeftPanel);
            app.OffsetSpinnerLabel.HorizontalAlignment = 'right';
            app.OffsetSpinnerLabel.Position = [33 371 37 22];
            app.OffsetSpinnerLabel.Text = 'Offset';

            % Create PowerSpinner
            app.PowerSpinner = uispinner(app.LeftPanel);
            app.PowerSpinner.Step = 0.05;
            app.PowerSpinner.ValueChangingFcn = createCallbackFcn(app, @PowerKnobValueChanged, true);
            app.PowerSpinner.Limits = [0.5 2];
            app.PowerSpinner.ValueChangedFcn = createCallbackFcn(app, @PowerKnobValueChanged, true);
            app.PowerSpinner.Position = [85 325 100 22];
            app.PowerSpinner.Value = 1;

            % Create PowerSpinnerLabel
            app.PowerSpinnerLabel = uilabel(app.LeftPanel);
            app.PowerSpinnerLabel.HorizontalAlignment = 'right';
            app.PowerSpinnerLabel.Position = [31 325 39 22];
            app.PowerSpinnerLabel.Text = 'Power';

            % Create LiftSpinner
            app.LiftSpinner = uispinner(app.LeftPanel);
            app.LiftSpinner.Step = 0.05;
            app.LiftSpinner.ValueChangingFcn = createCallbackFcn(app, @LiftKnobValueChanged, true);
            app.LiftSpinner.Limits = [0.5 2];
            app.LiftSpinner.ValueChangedFcn = createCallbackFcn(app, @LiftKnobValueChanged, true);
            app.LiftSpinner.Position = [85 272 100 22];
            app.LiftSpinner.Value = 1;

            % Create LiftSpinnerLabel
            app.LiftSpinnerLabel = uilabel(app.LeftPanel);
            app.LiftSpinnerLabel.HorizontalAlignment = 'right';
            app.LiftSpinnerLabel.Position = [45 272 25 22];
            app.LiftSpinnerLabel.Text = 'Lift';

            % Create GSpinnerLabel
            app.GSpinnerLabel = uilabel(app.LeftPanel);
            app.GSpinnerLabel.HorizontalAlignment = 'center';
            app.GSpinnerLabel.Position = [96 224 25 22];
            app.GSpinnerLabel.Text = 'G';

            % Create GSpinner
            app.GSpinner = uispinner(app.LeftPanel);
            app.GSpinner.Step = 0.05;
            app.GSpinner.Limits = [0 1];
            app.GSpinner.ValueChangedFcn = createCallbackFcn(app, @GSpinnerValueChanged, true);
            app.GSpinner.Position = [81 192 55 33];
            app.GSpinner.Value = 1;

            % Create BSpinnerLabel
            app.BSpinnerLabel = uilabel(app.LeftPanel);
            app.BSpinnerLabel.HorizontalAlignment = 'center';
            app.BSpinnerLabel.Position = [150 224 25 22];
            app.BSpinnerLabel.Text = 'B';

            % Create BSpinner
            app.BSpinner = uispinner(app.LeftPanel);
            app.BSpinner.Step = 0.05;
            app.BSpinner.Limits = [0 1];
            app.BSpinner.ValueChangedFcn = createCallbackFcn(app, @BSpinnerValueChanged, true);
            app.BSpinner.Position = [135 192 55 33];
            app.BSpinner.Value = 1;

            % Create RSpinnerLabel
            app.RSpinnerLabel = uilabel(app.LeftPanel);
            app.RSpinnerLabel.HorizontalAlignment = 'center';
            app.RSpinnerLabel.Position = [42 224 25 22];
            app.RSpinnerLabel.Text = 'R';

            % Create RSpinner
            app.RSpinner = uispinner(app.LeftPanel);
            app.RSpinner.Step = 0.05;
            app.RSpinner.Limits = [0 1];
            app.RSpinner.ValueChangedFcn = createCallbackFcn(app, @RSpinnerValueChanged, true);
            app.RSpinner.Position = [27 192 55 33];
            app.RSpinner.Value = 1;

            % Create SaturationSpinnerLabel
            app.SaturationSpinnerLabel = uilabel(app.LeftPanel);
            app.SaturationSpinnerLabel.HorizontalAlignment = 'center';
            app.SaturationSpinnerLabel.Position = [80 167 60 22];
            app.SaturationSpinnerLabel.Text = 'Saturation';

            % Create SaturationSpinner
            app.SaturationSpinner = uispinner(app.LeftPanel);
            app.SaturationSpinner.Step = 0.05;
            app.SaturationSpinner.Limits = [0 1];
            app.SaturationSpinner.ValueChangedFcn = createCallbackFcn(app, @SaturationSpinnerValueChanged, true);
            app.SaturationSpinner.Position = [82 135 55 33];
            app.SaturationSpinner.Value = 1;

            % Create RightPanel
            app.RightPanel = uipanel(app.GridLayout);
            app.RightPanel.Layout.Row = 1;
            app.RightPanel.Layout.Column = 2;

            % Create UIAxes
            app.UIAxes = uiaxes(app.RightPanel);
            title(app.UIAxes, 'Slope, Offset, and Power Transfer Functions Applied')
            xlabel(app.UIAxes, 'Input')
            ylabel(app.UIAxes, 'Output')
            zlabel(app.UIAxes, 'Z')
            app.UIAxes.Position = [25 26 373 429];

            % Show the figure after all components are created
            app.UIFigure.Visible = 'on';
        end
    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = Lab01_UserApp_exported

            % Create UIFigure and components
            createComponents(app)

            % Register the app with App Designer
            registerApp(app, app.UIFigure)

            if nargout == 0
                clear app
            end
        end

        % Code that executes before app deletion
        function delete(app)

            % Delete UIFigure when app is deleted
            delete(app.UIFigure)
        end
    end
end