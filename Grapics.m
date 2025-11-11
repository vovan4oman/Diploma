% Дані для тангажу
pitch_theoretical = [0, 0.3, 0.5, 0.8, 1, 5, 10, 15, 30, 45, 60, 85];
pitch_measured = [0.01, 0.31, 0.55, 0.79, 1.02, 5.03, 10.04, 15.05, 30.1, 45.3, 60.5, 85.9];

% Графік для тангажу
figure;
plot(pitch_theoretical, pitch_theoretical, 'bo-', 'LineWidth', 1.5, 'DisplayName', 'Теоретичні значення');
hold on;
plot(pitch_theoretical, pitch_measured, 'rs-', 'LineWidth', 1.5, 'DisplayName', 'Виміряні значення');
xlabel('Теоретичний тангаж (°)');
ylabel('Значення тангажу (°)');
title('Порівняння теоретичних і виміряних значень тангажу');
legend('Location', 'northwest');
grid on;

% Дані для крену
roll_theoretical = [0, 0.3, 0.5, 0.8, 1, 5, 10, 15, 30, 45, 60, 85];
roll_measured = [0.06, 0.35, 0.56, 0.86, 1.07, 5.05, 10.04, 15.02, 29.97, 44.95, 59.58, 84.8];

% Графік для крену
figure;
plot(roll_theoretical, roll_theoretical, 'bo-', 'LineWidth', 1.5, 'DisplayName', 'Теоретичні значення');
hold on;
plot(roll_theoretical, roll_measured, 'rs-', 'LineWidth', 1.5, 'DisplayName', 'Виміряні значення');
xlabel('Теоретичний крен (°)');
ylabel('Значення крену (°)');
title('Порівняння теоретичних і виміряних значень крену');
legend('Location', 'northwest');
grid on;

% Абсолютна похибка для тангажу
pitch_error = abs(pitch_theoretical - pitch_measured);
figure;
plot(pitch_theoretical, pitch_error, 'm-o', 'LineWidth', 1.5);
xlabel('Теоретичний тангаж (°)');
ylabel('Абсолютна похибка (°)');
title('Абсолютна похибка кута тангажу');
grid on;

% Абсолютна похибка для крену
roll_error = abs(roll_theoretical - roll_measured);
figure;
plot(roll_theoretical, roll_error, 'c-o', 'LineWidth', 1.5);
xlabel('Теоретичний крен (°)');
ylabel('Абсолютна похибка (°)');
title('Абсолютна похибка кута крену');
grid on;
