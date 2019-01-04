function [xlim,ylim] = canvas_size(H, colsize, rowsize)
H = H.T;
lim = zeros(4,2);
count = 1;
for i = 1:2
    for j = 1:2
        ht = H * [colsize(i); rowsize(j); 1];
        ht = ht./ht(3);
        lim(count,:) = ht(1:2)';
        count = count +1;
    end
end
xlim = [min(lim(:,1)),max(lim(:,1))];
ylim = [min(lim(:,2)),max(lim(:,2))];
end