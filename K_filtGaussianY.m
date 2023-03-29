function yy = K_filtGaussianY(y, size, sigma)
% yy = K_filtGaussianY(y, size, sigma)
%
% input variables
% y       real vector
% size    positive real number that specifies the width of the Gaussian
%         filter in points
% sigma   positive real number that specifies the standard deviation of the
%         Gaussian PDF in points

%% parse

narginchk(3,3);

p = inputParser;

vf_y = @(x) isvector(x) && all(isnumeric(x)) && all(isreal(x));
vf_size = @(x) isscalar(x) && x > 0 ; % width in points
vf_sigma = @(x) isscalar(x) && x > 0 ; % SD in points

addRequired(p, 'y', vf_y);
addRequired(p, 'size', vf_size);
addRequired(p, 'sigma', vf_sigma);

parse(p, y, size, sigma);


%% job

X = fix(-size/2):fix(size/2);
gaussFilter = normpdf(X, 0, sigma);
% figure;plot(gaussFilter);

yy = conv(y, gaussFilter, 'same');

end



