function [l_I,l_U,l_O] = GetLoadingTimes(I,U,O,s_l_fix,s_l_var)
% Return loading time in minutes
l_I = (I.Quantity1/1000) * s_l_var + s_l_fix;
l_U = (U.Quantity1/1000) * s_l_var + s_l_fix;
l_O = (O.Quantity1/1000) * s_l_var + s_l_fix;

end
