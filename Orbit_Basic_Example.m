% Constants
G = 6.674e-11;        % Gravitational constant
mass_body = 5.972e24; % Earth mass (kg)
dt = 0.1;              % Time step (seconds)
n_steps = 90000;      % Number of steps

% Initial conditions
r = zeros(n_steps, 2);
v = zeros(n_steps, 2);
r(1,:) = [7000e3, 0];      % Start at 7000 km on x-axis
v(1,:) = [0, 7500];        % Initial velocity in y-direction (m/s)

% Simulation loop
for i = 1:(n_steps-1)
    % Calculate gravity acceleration
    r_mag = norm(r(i,:));
    a_grav = -(G*mass_body/r_mag^3) * r(i,:);
    
    % Update velocity and position (Euler method)
    v(i+1,:) = v(i,:) + a_grav * dt;
    r(i+1,:) = r(i,:) + v(i,:) * dt;
end

% Plot the orbit
plot(r(:,1), r(:,2))
axis equal
xlabel('x (m)')
ylabel('y (m)')