% 1D Hover Sim:
%{ 
    This script (roughly) simulates the physics of a body in freefall in one dimension,
as well as allowing for the user to tune a basic nested PID controller to
determine the proper gain for each controller. It is intended to be
used with pid_drop.ks, my kOS script which actually implements the
controller for use in Kerbal Space Program. Once you use this sim to
figure out the best gain values for your craft, you can just plug them into
the kOS script!

    This can be easily updated to fit the flight characteristics of any
spacecraft. Of note, this model is specific to Kerbin and thus takes
atmospheric drag into account (physics teachers are shaking rn). It would
be easy to change this for any other body(Mun, Minmus, Duna, etc.) should
you so desire. Obviously, a 1D freefall model isn't that useful, but this actually
provides an excellent starting point to extending it to a more usable 2D simulation.
Feel free to make any changes you want and to use as you desire.
%}
clear; close all
% ----------------------------------------------------------------------- %
%% Constants & Parameters:
% Universal constants~
g0 = 9.8; % Maximum Kerbin Gravitational Acceleration (m/s^2)
G = 6.67*10^-11; % Universal Gravitational Constant (N*m^2/kg^2)
% Planetary Body Parameters~
mass_body = 5.2915158*10^22; % Kerbin's mass (kg)
equatorial_radius = 600000; % Equatorial radius of Kerbin (m)
% Engine Parameters~
max_thrust = 88890; % Max Engine Thrust (N)
engine_isp = 240; % Engine Isp (seconds)
% Orbital Parameters~
initial_alt = 4065; % Initial Altitude (m)
target_alt = 0; % Targeted hover altitude (m)
% Spacecraft Parameters~
Cd = 0.8; % Coefficient of Drag (there is no easy way to calculate this without some experimentation unfortunately)
A = 1.23; % Cross Sectional Area (m^2) (Also good luck figuring this out. KSP isn't very helpful here. I used the diameter of the fuel tank attached to the engine to calculate, check the ksp wiki)
mass_wet = 3700; % Craft wet-mass (kg) (Full fuel)
mass_dry = 1700; % Craft dry-mass (kg) (Empty fuel)
% Miscellaneous~
last_time = 0; % This is used to make the inner and outer PIDs update at different rates (outer updates every tick, inner updates every 5 ticks)
total_P = 0; % For keeping track of total error
last_P = 0; % For integrating and differentiating within inner PID controller
% ----------------------------------------------------------------------- %
%% Set Up:
% Declare Arrays:
n = 25000; % Number of time steps
t = zeros(n,1); % Time
altitude = zeros(n,1); % Altitude
v_y = zeros(n,1); % Vertical Velocity Vector
a_y = zeros(n,1); % Vertical Acceleration Vector
m_t = zeros(n,1); % Mass Flow Rate
gravity = zeros(n,1); % To account for changing gravitational acceleration based on altitude
F_drag = zeros(n,1); % Force of drag
throttle = zeros(n,1); % Commanded Throttle at any given timestep
thrust = zeros(n,1); % Thrust output based off of throttle given by PID controller
p = zeros(n,1); % Atmospheric Density at a given altitude

% Initial Conditions:
altitude(1) = initial_alt; % Our starting altitude
gravity(1) = G*mass_body/(altitude(1)+equatorial_radius)^2; % Basic inverse square calculation (GM/r^2)
m_t(1) = mass_wet; % Assuming starting at full fuel
v_y(1) = 0; % Assuming starting at 0 m/s (you could change this if you so desire to simulate falling at speed)

% ----------------------------------------------------------------------- %
%% Main Loop
dt = 0.01; % Time step
for i = 1:n-1
    t(i+1) = t(i) + dt; % Update time
    gravity(i) = G*mass_body/(altitude(i)+equatorial_radius)^2; % Update gravity
    hover_throttle = m_t(i)*gravity(i)/max_thrust; % Gravity feedforward added to throttle input to ease burden on integral term
    % Run Outer PID each time step
    target_v = pid_control_alt(target_alt, altitude(i));

    % Check to see if Inner PID should run
    if(t(i) - last_time >= 0.05) % Update throttle every 0.05 seconds
        last_time = t(i);
        [throttle(i+1), last_P, total_P] = pid_control_vel(target_v, v_y(i), last_P, total_P, t(i), hover_throttle); 
    else % Keep throttle at last value
        throttle(i+1) = throttle(i);
    end

    
    % Update thrust
    thrust(i) = max_thrust*(throttle(i+1)); 

    % Update mass (m_t)
    if(m_t(i) >= mass_dry)
        m_t(i+1) = m_t(i) - (thrust(i)/(engine_isp*9.8)*dt); % Update Mass
    else
        m_t(i) = 1600; % Clamping for running out of fuel
        thrust(i) = 0;
        throttle(i+1) = 0;
    end
    
    % Update atmospheric density
    p(i) = 1.25078*exp(-0.000142693*altitude(i)); % This is not a perfect model, but it's decently close-ish

    % Update Force of Drag (F_drag)
    F_drag(i) = -0.5*Cd*A*p(i)*v_y(i)*abs(v_y(i)); % F_d = 0.5*Cd*A*p*v^2, drag should always oppose direction of motion

    % Update Vertical Acceleration (a_y)
    if(altitude(i) == 0)
        a_y(i) = 0; % If you're on the ground...
    else
        a_y(i) = (thrust(i) + F_drag(i))/m_t(i) - gravity(i); % Negative if net acceleration is down towards the surface
    end

    % Update Vertical Velocity (v_y)
    if(altitude(i) == 0)
        v_y(i+1) = 0; % If you're on the ground...
    else
        v_y(i+1) = v_y(i) + a_y(i)*dt; % Negative if falling
    end

    % Update Altitude
    altitude(i+1) = max(altitude(i) + v_y(i)*dt, 0); % Clamping to prevent negative altitudes

end

% ----------------------------------------------------------------------- %
%% PID Controllers:
%{ 
    This is our "outer" PID Controller which compares our current altitude
    with our target altitude and determines our desired target velocity for
    input into the "inner" PID Controller
%}
function [target_v] = pid_control_alt(target_alt, altitude)
    % Controller Gain Value (edit this to see how the system responds. I find this one to be the most critical to tune correctly to avoid overshoots.
    kP_alt = 0.22; % higher values --> fall towards our target altitude faster

    alt_error = altitude - target_alt;
    target_v = max(-150, min(-kP_alt*alt_error,2)); % Clamping for target velocity will only allow us to fall down up to -150 m/s at most, and 2 m/s up at minimum
end

%{ 
    This is our "inner" PID Controller which takes in a target velocity
    generated by the outer PID controller and comapres it against the current
    velocity, outputing a desired throttle value.
%}
function [throttle, last_P, total_P] = pid_control_vel(target_v, v_y, last_P, total_P, t, hover_throttle)
    dt_inner = 0.05; % Internal dt to function workspace which should be updated to match any changes to the frequency inner controller runs in the main loop!

    % Controller Gain Values (edit these to tune the controller and observe how the system responds)
    kP_vel = 0.05; % Proportionality Constant, corrects for current error
    kI_vel = 0.005; % Integral Constant, corrects for past/steady state error
    kD_vel = 0.01; % Derivative Constant, corrects for anticipated future error

    % Compute Error
    P = target_v - v_y;

    if(t > 0)
        I = total_P + (last_P + P)/2 * dt_inner;
        D = (P-last_P)/dt_inner;
    else
        I = 0;
        D = 0;
    end
    
    unclamped_throttle = kP_vel*P + kI_vel*I + kD_vel*D;

    if(unclamped_throttle > 0 && unclamped_throttle < 1) % To combat Integrator Windup when throttle is saturated
        total_P = I;
    end
    last_P = P;
    throttle = max(0, min(unclamped_throttle + hover_throttle,1)); % Clamp our throttle output to keep it between 0 and 1
end

% ----------------------------------------------------------------------- %
%% Plot Results:
% Altitude v Time:
plot(t,altitude)
yline(target_alt,'r--','LineWidth',2)
title("Altitude v Time")
xlabel("Time(s)")
ylabel("Altitude(m)")
legend('Altitude', 'Target Altitude')

% Uncomment plots as desired:

% % Velocity v Time:
% figure()
% plot(t,v_y)
% title("Vertical Velocity v Time")
% xlabel("Time(s)")
% ylabel("Velocity(m/s)")
% 
% % Acceleration v Time:
% figure()
% plot(t,a_y)
% title("Vertical Acceleration v Time")
% xlabel("Time(s)")
% ylabel("Acceleration(m/s^2)")
% 
% % Mass v Time:
% figure()
% plot(t,m_t)
% title("Mass v Time")
% xlabel("Time(s)")
% ylabel("Mass(kg)")
% 
% % Throttle v Time:
% figure()
% plot(t, throttle)
% title("Throttle v Time")
% xlabel("Time(s)")
% ylabel("Throttle(unitless)")
% 
% % Thrust v Time:
% figure()
% plot(t, thrust)
% title("Thrust v Time")
% xlabel("Time(s)")
% ylabel("Thrust(N)")