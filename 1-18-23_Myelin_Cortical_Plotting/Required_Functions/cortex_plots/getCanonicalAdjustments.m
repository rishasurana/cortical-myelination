function adj = getCanonicalAdjustments(surfs2load)
%         views = {'lat_L' 'lat_R' 'med_L' 'med_R' 'ant'  'pos' 'dor' 'ven'};
adj.trans       = [-0.400  -0.20   -0.20   -0.40    0.00   0.00  0.20  0.20; ...
                    0.00    0.00    0.00    0.00    0.00   0.00  0.00  0.00; ...
                    0.00    0.00   -0.15   -0.15    0.00  -0.15  0.00 -0.15];
adj.rot         = [ 0.00    0.00    0.00    0.00    0.00   0.00 -0.50  0.50; ...
                    0.00    0.00    0.00    0.00    0.00   0.00  0.50 -0.50; ...
                   -0.50    0.50    0.50   -0.50    1.00   0.00  0.00  0.00];
adj.scale       = zeros(1,length(surfs2load));
adj.separation  = 30;
adj.scale(strcmpi(surfs2load,'inflated')) = 0.65; % canonical scaling for the inflated surface
if length(surfs2load) == 3
    adj.shifts = [1 0 -1].*0.3;
elseif length(surfs2load) == 2
    adj.shifts = [1   -1].*0.15;
elseif length(surfs2load) == 1
    adj.shifts = 0.00;
end
return