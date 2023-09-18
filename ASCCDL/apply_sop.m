%%%  Apply slope, offset, and power
%%%  \file /apply_sop.m
%%%  \author Brooke Galvin
%%%  \date 14 September, 2023

%% Creating function for slope, offset, and power calculation
function out = apply_sop(src, slope, offset, power)

    %%% Apply slope adjustments
    sloped = src*slope; 

    %%% Apply offset
    offsetted = sloped+offset;

    %%% Apply power
    powered = offsetted.^power;
    
    %%% Clamp Values 0-1
    dst=min(powered,1);
    out=max(dst, 0);

end
