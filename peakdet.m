function [pks,dep,pid,did] = peakdet(sig, th, type, mdist)

pks = [];
dep = [];
pid = [];
did = [];

[m,n] = size(sig);
if m == 1 && n > 1
    sig = sig';
    [m,n] = size(sig);
end

if nargin < 2
    th = .5;
end

if length(th) > 1
    error('Input argument th (threshold) must be a scalar');
end

if th <= 0
    error('Input argument th (threshold) must be positive');
end

if ~exist('type', 'var')
    type = 'threshold';
end

if ~exist('mdist', 'var')
    mdist = 0;
end

if ~ischar(type)
    error('Input argument type must be string "threshold" or "zero"');
end

if strcmp(type,'threshold') || strcmp(type,'th')
    cross = th;
elseif strcmp(type,'zero')
    cross = 0;
else
    error('Input argument type must be string "threshold" or "zero"');
end

mn = Inf; mx = -Inf;
mnpos = NaN; mxpos = NaN;

idx = find(sig>th,1,'first');
idn = find(sig<th,1,'first');
if idx < idn
    lookpks = true;
else
    lookpks = false;
end

for ii = 1:m
    this = sig(ii);
    if this > mx, mx = this; mxpos = ii; end
    if this < mn, mn = this; mnpos = ii; end
    
    if lookpks
        if this < cross
            if mx >= th
                pks = [pks; mx];
                pid = [pid; mxpos];
            end
            mn = this; mnpos = ii;
            lookpks = false;
        end
    else
        if this > -cross
            if mn <= -th
                dep = [dep; mn];
                did = [did; mnpos];
            end
            mx = this; mxpos = ii;
            lookpks = true;
        end
    end
end

if lookpks
    if mx >= th
        pks = [pks; mx];
        pid = [pid; mxpos];
    end
else
    if mn <= -th
        dep = [dep; mn];
        did = [did; mnpos];
    end
end

% remove smaller peaks that are too close to other bigger peaks
if (mdist > 0)
    [val, subidx] = sort(pks, 'descend');
    idx = pid(subidx);
    todelete = false(size(val));
    N = length(val);
    for ii = 1:N
        if ~todelete(ii)
            % compute the distance of the other peaks to this one
            d = arrayfun(@(x) norm(x - idx(ii)), idx);
            todelete = todelete | (d < mdist);
            todelete(ii) = false;
        end
    end
    pks(subidx(todelete)) = [];
    pid(subidx(todelete)) = [];
    
    [val, subidx] = sort(dep);
    idx = did(subidx);
    todelete = false(size(val));
    N = length(val);
    for ii = 1:N
        if ~todelete(ii)
            % compute the distance of the other peaks to this one
            d = arrayfun(@(x) norm(x - idx(ii)), idx);
            todelete = todelete | (d < mdist);
            todelete(ii) = false;
        end
    end
    dep(subidx(todelete)) = [];
    did(subidx(todelete)) = [];
end

%-------------------------------- END CODE --------------------------------
