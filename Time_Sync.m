%% Function Time_Sync
% Time sync of the argument signals
% Return value syncronised x1 with respect to x2

% The signals cant lag more than 10 samples
function [s1,t_lag] = Time_Sync_m(SDR_ref,SDR_sig_to_sync)
MAX_LAG= 10;
% If t_lag is postitive SDR_sig_to_sync lags behind SDR_ref
% If t_lag is negative SDR_ref lags behind SDR_sig_to_sync
t_lag=finddelay(SDR_ref,SDR_sig_to_sync)
    if(t_lag>0)
        % If ref signal is before the signal to be synced
        % The signal to be synced will be clipped
        % the amount of t_lag
        s1=[SDR_sig_to_sync(t_lag+1:end)];
    else
        % If the signal that is suppose to be synced
        % is before the ref signal
        % The signal to be synced is zero padded
        s1 = [zeros(1,abs(t_lag)) SDR_sig_to_sync];
    end

end