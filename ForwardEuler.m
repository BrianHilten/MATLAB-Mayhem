%ForwardEuler.m
%y(n+1)=y(n)+h(f(t(n),y(n))
%Function to use Forward Euler to numerically approximate solutions to IVPs.
%Inputs: 
% t0(number, starting time)
% tf(number, final time)
% h(number, step size)
% y0(number, initial value of solution at t0)
% f(function handle, derivative of solution. Takes 2 inputs(t,y))
%Outputs:
% [t] vector storing time the solution is evaluated
% [y] vector storing the solution evaluated at t
function [t,y] = ForwardEuler(t0,tf,h,y0,f)
    t = t0:h:tf; %Initialize time vector
    y = zeros(size(t)); %Initialize solution vector
    y(1) = y0; %Set y0 to first entry in [y]
    %Compute solution
    for n=1:length(t)-1
        y(n+1) = y(n) + h*f(t(n),y(n));
    end
end