%%% ACCUMULATE WARPS
function[ A2, T2 ] = accumulatewarp( Acum, Tcum, A, T )
A2 = A * Acum;
T2 = A*Tcum + T;