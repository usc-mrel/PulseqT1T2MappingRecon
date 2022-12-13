function out = centeredCrop(in, Ncrop)
N = size(in);
N = N(1:3);
xcrop = (1+Ncrop(1)):(N(1)-Ncrop(1));
ycrop = (1+Ncrop(2)):(N(2)-Ncrop(2));
zcrop = (1+Ncrop(3)):(N(3)-Ncrop(3));
out = in(xcrop,ycrop,zcrop,:);
end