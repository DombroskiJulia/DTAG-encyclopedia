function h = compare_bottom(timedate, p, bton, btoff, bton2, btoff2);
% 
% COMPARE_BOTTOM (timedate, p, bton, btoff, bton2, btoff2)
% plots depth and time, and overlays bottom time shown by different methods
% colours red for bottom time 1
% colours blue for bottom time 2

clf
% plot the full dive profile
plot(timedate, p, 'k', 'LineWidth', 1); axis ij;hold on;
% plot markers at the start and end of the bottom time
plot(timedate([bton;btoff]), p([bton;btoff]), 'ro', 'MarkerSize', 8, 'LineWidth', 1.5); 
% plot the dive profile during the bottom time
for i=1:length(bton);
    plot(timedate(bton(i):btoff(i)), p(bton(i):btoff(i)), 'r:', 'LineWidth', 2); 
end

% repeat for the second bottom time measure
plot(timedate([bton2;btoff2]), p([bton2;btoff2]), 'bo', 'MarkerSize', 8, 'LineWidth', 1.5); 
for i=1:length(bton2); 
    plot(timedate(bton2(i):btoff2(i)), p(bton2(i):btoff2(i)), 'b:', 'LineWidth', 2); 
end  	

end

