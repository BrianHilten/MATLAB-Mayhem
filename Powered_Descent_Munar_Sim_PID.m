% 2D Munar Descent Sim:
%{ 
    This script (roughly) simulates the physics of a body in freefall in two dimensions,
as well as allowing for the user to tune a basic nested PID controller to
determine the proper gain values for each controller without having to waste time running the companion kOS script 
in lengthy test scenarios in game over and over. It is intended to be used with pid_descent.ks,
my kOS script which actually implements the controller for use in Kerbal Space Program. Once you use this sim to
figure out the best gain values for your craft, you can just plug them into
the kOS script and never have to worry about your poor piloting skills ever
again! Only my poor programming skills...

    This can be easily updated to fit the flight characteristics of any
spacecraft. Of note, this model is specific to the Mun, which has no atmosphere. It would
be easy to change this for any other body without atmosphere (Minmus, Vall, etc.) should
you so desire. For a body with atmosphere, things would be slightly more complicated, but it should be doable.
Feel free to make any changes you want and to use as you desire.

    Future Ideas:
    -Gain scheduling
    -Kalman Filter for the main script to deal with noisy altitude data
    from the radar altimeter
%}
clear; close all
% ----------------------------------------------------------------------- %
%% Constants & Parameters:
% Universal constants~
g0 = 1.63; % Maximum Munar Gravitational Acceleration (m/s^2)
G = 6.67*10^-11; % Universal Gravitational Constant (N*m^2/kg^2)
% Planetary Body Parameters~
mass_body = 9.76*10^20; % Mun's mass (kg)
equatorial_radius = 200000; % Equatorial radius of Mun (m)
surface_vel_body = 9.04; % Speed at which the surface of the planet rotates (m/s)
% Engine Parameters~
max_thrust = 100000; % Max Engine Thrust (N)
engine_isp = 270; % Engine Isp (seconds)
% Orbital Parameters~
initial_orbital_alt = 50000; % Initial Altitude (m)
target_alt = 0; % Targeted altitude (m)
orbital_vel_initial = sqrt(G*mass_body/(initial_orbital_alt+equatorial_radius)); % Initial Orbital Velocity (m/s) calculated using orbit velocity formula for circular orbits SQRT(GM/R)
% Spacecraft Parameters~
mass_wet = 3631; % Craft wet-mass (kg) (Full fuel)
mass_dry = 1700; % Craft dry-mass (kg) (Empty fuel)
% Miscellaneous~
last_time = 0; % This is used to make the inner and outer PIDs update at different rates (outer updates every tick, inner updates every 5 ticks)
total_P = 0; % For keeping track of total error in throttle PID
last_P = 0; % For integrating and differentiating within inner throttle PID controller
last_P_h = 0; % For integrating and differentiating within inner tilt PID controller
total_P_h = 0; % For keeping track of total error in tilt PID
% ----------------------------------------------------------------------- %
%% Set Up:
% Declare Arrays:
n = 500000; % Number of time steps
t = zeros(n,1); % Time
r = zeros(n,2); % Position Vector
r_mag = zeros(n,1); % Position vector magnitude
v = zeros(n,2); % Velocity Vector
v_mag = zeros(n,1); % Magnitude of velocity vector
a = zeros(n,2); % Acceleration Vector
% v_x = zeros(n,1); % Horizontal Velocity Vector
% v_y = zeros(n,1); % Vertical Velocity Vector
% a_x = zeros(n,1); % Horizontal Acceleration Vector
% a_y = zeros(n,1); % Vertical Acceleration Vector
gravity = zeros(n,2); % Gravity Vector
g_mag = zeros(n,1); % Magnitude of gravity vector

m_t = zeros(n,1); % Mass Flow Rate
throttle = zeros(n,1); % Commanded throttle at any given timestep
thrust = zeros(n,1); % Thrust output based off of throttle given by PID controller
tilt = zeros(n,1); % Commanded tilt at any given timestep

% Initial Conditions:
r(1,1) = 0; % X-Coordinates, with our starting point (Apoapsis) being considered "0".
r(1,2) = initial_orbital_alt + equatorial_radius; % Y-Coordinates, with the center of the celestial body being considered "0".
r_mag(1) = norm(r(1,:)); % Initial magnitude of position vector
g_mag(1) = G*mass_body/(r_mag(1)+equatorial_radius)^2; % Basic inverse square calculation (GM/r^2)
v(1,:) = [510, 0];  % Initial velocities
% v_y(1) = 0; % Should be 0 m/s since we are starting at apoapsis
% v_x(1) = (orbital_vel_initial - surface_vel_body); % Velocity is entirely horizontal at apoapsis, and we want to calculate relative surface velocity
m_t(1) = mass_wet; % Assuming starting at full fuel
tilt(1) = 90; % 0 = Craft pointing straight "up", 90 = Craft perp. to horizon, aft pointing toward direction of travel
% ----------------------------------------------------------------------- %
%% Main Loop
dt = 0.01; % Time step
run_control = false; % Are we running our PID controllers? Or just letting gravity do its thing
for i = 1:n-1
    t(i+1) = t(i) + dt; % Update time
    r_mag(i) = norm(r(i,:)); % Update position vector magnitude 
    v_mag(i) = norm(v(i,:)); % Update velocity vector magnitude
    gravity(i,:) = (G*mass_body/r_mag(i)^3)*-[r(i,1), r(i,2)]; % Update gravity vector
    g_mag(i) = norm(gravity(i,:)); % Update gravity vector magnitude
    
    if(run_control == true)
    % Run Outer PID each time step
    target_v = pid_control_alt(target_alt, y_pos(i));
    
    % Check to see if Inner PID should run
    if(t(i) - last_time >= 0.05) % Update throttle & tilt
        last_time = t(i);

        % Update our tilt angle to burn off horizontal velocity
        if(y_pos(i) > 15000)
            target_v_h = -100; % We want no horizontal velocity by the time we land!
        else
            target_v_h = 0; % We want no horizontal velocity by the time we land!
        end
        [tilt(i+1), last_P_h, total_P_h] = pid_control_tilt(target_v_h, v_x(i), last_P_h, total_P_h, t(i));
        
        % Update throttle
        hover_throttle = m_t(i)*gy_mag(i)/max_thrust*sind(tilt(i+1)+90); % Gravity feedforward to ease burden on integral term
        [throttle(i+1), last_P, total_P] = pid_control_vel(target_v, v_y(i), last_P, total_P, t(i), hover_throttle); 
         
    else % Keep throttle and tilt at last value
        throttle(i+1) = throttle(i);
        tilt(i+1) = tilt(i);
    end

    end
    % Update thrust
    thrust(i) = max_thrust*(throttle(i+1));
    thrust_x = thrust(i)*sind(tilt(i));
    thrust_y = thrust(i)*cosd(tilt(i));

    % Update mass (m_t)
    if(m_t(i) >= mass_dry)
        m_t(i+1) = m_t(i) - (thrust(i)/(engine_isp*9.8)*dt); % Update Mass
    else
        m_t(i) = mass_dry; % Clamping for running out of fuel
        thrust(i) = 0;
    end
    
    % Update Acceleration
    a(i,:) = gravity(i,:); % Negative if accelerating towards prograde vector (engine pointed at retrograde AKA slowing down)

    % Update Velocity Vector
    v(i+1,:) = v(i,:) + a(i,:)*dt; % Positive to start, should gradually decrease as we slow
 
    % Update Position Vector
    r(i+1,:) = r(i,:) + v(i,:)*dt;
 
end

% ----------------------------------------------------------------------- %
%% PID Controllers:
%{ 
    This is our "outer" PID Controller which compares our current altitude
    with our target altitude and determines our desired target velocity for
    input into the "inner" PID Controller
%}
function [target_v] = pid_control_alt(target_alt, altitude)
    % Controller Gain Value
    kP_alt = 0.1; % higher values --> fall towards our target altitude faster

    alt_error = altitude - target_alt;
    target_v = max(-60, min(-kP_alt*alt_error,2)); % Clamping for target velocity will only allow us to fall down up to -150 m/s at most, and 2 m/s up at minimum
end

%{ 
    This is our "inner" PID Controller which takes in a target velocity
    generated by the outer PID controller and comapres it against the current
    velocity, outputing a desired throttle value.
%}
function [throttle, last_P, total_P] = pid_control_vel(target_v, v_y, last_P, total_P, t, hover_throttle)
    dt = 0.05; % Internal dt to function workspace which should be updated to match any changes to dt in the main loop!

    % Controller Gain Values (edit these to tune the controller and observe how the system responds)
    kP = 0.05; % Proportionality Constant, corrects for current error
    kI = 0.0009; % Integral Constant, corrects for past/steady state error
    kD = 0.002; % Derivative Constant, corrects for anticipated future error

    % Compute Error
    P = target_v - v_y;

    if(t > 0)
        I = total_P + (last_P + P)/2 * dt;
        D = (P-last_P)/dt;
    else
        I = 0;
        D = 0;
    end
    
    unclamped_throttle = kP*P + kI*I + kD*D;

    if(unclamped_throttle > 0 && unclamped_throttle < 1) % To combat Integrator Windup when throttle is saturated
        total_P = I;
    end
    last_P = P;
    throttle = max(0, min(unclamped_throttle + hover_throttle,1)); % Clamp our throttle output to keep it between 0 and 1
end

function [tilt, last_P, total_P] = pid_control_tilt(target_v_h, v_x, last_P, total_P, t)
    dt = 0.05; % To match our refresh rate in main loop

    % Controller Gain Values (edit these to tune the controller and observe how the system responds)
    kP = 0.9;
    kI = 0.0001; 
    kD = 0.005;

    P = -v_x - target_v_h; % Compute our error

    if(t > 0)
        I = total_P + (P+last_P)/2 * dt; % Integrate
        D = (P - last_P)/dt; % Differentiate
    else
        I = 0;
        D = 0;
    end

    last_P = P;
    commanded_tilt = kP*P + kI*I + kD*D; % Compute commanded tilt

    if(commanded_tilt <= 90 && commanded_tilt >= 0) % Anti-windup
        total_P = I;
    end

    if(-v_x < 0.5) % Prevents direction reversals
        tilt = 0;
        total_P = 0;
        last_P = 0;
    else
        tilt = max(0, min(90,commanded_tilt)); % Returns tilt angles between 0 (craft pointing straight down) and 90 (craft perpendicular to horizon, aft towards direction of travel)
    end
end
% ----------------------------------------------------------------------- %
%% Plot Results:
% % Altitude v Time:
% plot(t,y_pos)
% yline(target_alt,'r--','LineWidth',2)
% title("Altitude v Time")
% xlabel("Time(s)")
% ylabel("Altitude(m)")
% legend('Altitude', 'Target Altitude')

% Uncomment plots as desired:
% % Distance v Time:
% figure()
% plot(t,x_pos)
% title("Distance v Time")
% xlabel("Time(s)")
% ylabel("Distance(m)")

% Position Vector:
% figure()
% x = zeros(n,1);
% y = zeros(n,1);
% quiver(x,y,r(:,1),r(:,2));
% yline(equatorial_radius,'r--','LineWidth',2)

figure()
hold on
plot(r(:,1),r(:,2))
xlabel('x (m)')
ylabel('y (m)')
axis equal
circle(0,0,200000)
legend('Orbit', 'Body')
hold off
% Velocity v Time:
figure()
hold on
plot(t,v(:,1))
plot(t,v(:,2))
title("Velocity v Time")
xlabel("Time(s)")
ylabel("Velocity(m/s)")
legend('v_x','v_y')
hold off
% 
% % Horizontal Velocity v Time:
% figure()
% plot(t,v_x)
% title("Horizontal Velocity v Time")
% xlabel("Time(s)")
% ylabel("Velocity(m/s)")

% Gravity v Time
figure()
plot(t,g_mag)
xlabel("Time(s)")
ylabel("Acceleration(m/s^2)")

% Vertical Acceleration v Time:
% figure()
% plot(t,a_y)
% title("Vertical Acceleration v Time")
% xlabel("Time(s)")
% ylabel("Acceleration(m/s^2)")
% 
% % Horizontal Acceleration v Time:
% figure()
% plot(t,a_x)
% title("Horizontal Acceleration v Time")
% xlabel("Time(s)")
% ylabel("Acceleration(m/s^2)")

% Mass v Time:
% figure()
% plot(t,m_t)
% title("Mass v Time")
% xlabel("Time(s)")
% ylabel("Mass(kg)")

% % Throttle v Time:
% figure()
% plot(t, throttle)
% title("Throttle v Time")
% xlabel("Time(s)")
% ylabel("Throttle(unitless)")

% Thrust v Time:
% figure()
% plot(t, thrust)
% title("Thrust v Time")
% xlabel("Time(s)")
% ylabel("Thrust(N)")

% Tilt v Time:
% figure()
% plot(t, tilt)
% title("Tilt v Time")
% xlabel("Time(s)")
% ylabel("Tilt(degrees)")
% 
% % gx_mg v Time:
% figure()
% plot(t, gravity(:,1))
% title("Gx v Time")
% xlabel("Time(s)")
% ylabel("Gx")
% % gy_mg v Time:
% figure()
% plot(t, gravity(:,2))
% title("Gy v Time")
% xlabel("Time(s)")
% ylabel("Gy")