%%%  Apply slope, offset, and power
%%%  \file /apply_sop.m
%%%  \author Brooke Galvin
%%%  \date 14 September, 2023
%% Creating function for saturation calculation

function out = apply_saturation(out_R,out_G, out_B, sat)
    %%% Calculate luma
    luma = .2126*out_R + .7152*out_G + .0722*out_B;

    %%% Calculating Saturation
    dst(:,1) = luma + sat*(out_R-luma);
    dst(:,2) = luma + sat*(out_G-luma);
    dst(:,3) = luma + sat*(out_B-luma);
    
    %%% Clamp values 0-1
   dst=min(dst,1);
   out=max(dst, 0);

end
